//
//  HeapZoneWalker.c
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#include "HeapZoneWalker.h"

#if MP_HEAP_INTROSPECTION

#if __has_feature(ptrauth_calls)
#include <ptrauth.h>
#endif

// Exported by libobjc for debuggers. Weak so a runtime without it degrades to "unavailable"
// instead of failing to load. Only referenced in Debug builds (MP_HEAP_INTROSPECTION).
extern const uintptr_t objc_debug_isa_class_mask __attribute__((weak_import));

static kern_return_t mp_in_process_reader(task_t task, vm_address_t address, vm_size_t size, void **localMemory) {
    (void)task;
    (void)size;
    *localMemory = (void *)address;
    return KERN_SUCCESS;
}

static bool mp_zone_is_walkable(const malloc_zone_t *zone) {
    if (zone == NULL || zone->introspect == NULL) {
        return false;
    }
    const malloc_introspection_t *introspect = zone->introspect;
    return introspect->enumerator != NULL && introspect->force_lock != NULL && introspect->force_unlock != NULL;
}

bool mp_heap_walker_is_available(void) {
    return &objc_debug_isa_class_mask != NULL && objc_debug_isa_class_mask != 0;
}

uintptr_t mp_heap_walker_class_of_block(uintptr_t blockAddress) {
    uintptr_t isa = *(const uintptr_t *)blockAddress;
#if __has_feature(ptrauth_calls)
    isa = (uintptr_t)ptrauth_strip((void *)isa, ptrauth_key_process_independent_data);
#endif
    return isa & objc_debug_isa_class_mask;
}

MPHeapStatus mp_heap_walker_walk(vm_range_recorder_t *recorder, void *context) {
    vm_address_t *zones = NULL;
    unsigned zoneCount = 0;
    kern_return_t result = malloc_get_all_zones(TASK_NULL, mp_in_process_reader, &zones, &zoneCount);
    if (result != KERN_SUCCESS || zones == NULL) {
        return MPHeapStatusZoneEnumerationFailed;
    }
    for (unsigned index = 0; index < zoneCount; index++) {
        malloc_zone_t *zone = (malloc_zone_t *)zones[index];
        if (!mp_zone_is_walkable(zone)) {
            continue;
        }
        zone->introspect->force_lock(zone);
        zone->introspect->enumerator(TASK_NULL, context, MALLOC_PTR_IN_USE_RANGE_TYPE,
                                     (vm_address_t)zone, mp_in_process_reader, recorder);
        zone->introspect->force_unlock(zone);
    }
    return MPHeapStatusSuccess;
}

#else

bool mp_heap_walker_is_available(void) {
    return false;
}

uintptr_t mp_heap_walker_class_of_block(uintptr_t blockAddress) {
    (void)blockAddress;
    return 0;
}

MPHeapStatus mp_heap_walker_walk(vm_range_recorder_t *recorder, void *context) {
    (void)recorder;
    (void)context;
    return MPHeapStatusUnavailable;
}

#endif
