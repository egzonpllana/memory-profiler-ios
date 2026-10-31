//
//  HeapCensus.c
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#include "HeapZoneWalker.h"
#include <stdlib.h>
#include <string.h>

typedef struct {
    const uintptr_t *classes;
    const size_t *instanceSizes;
    int64_t *slots;
    size_t slotMask;
    uint64_t *counts;
    uint64_t *bytes;
} MPCensusContext;

static size_t mp_census_hash(uintptr_t value, size_t mask) {
    return (size_t)(((uint64_t)value >> 3) * 0x9E3779B97F4A7C15ULL) & mask;
}

static size_t mp_census_slot_count(size_t classCount) {
    size_t slotCount = 16;
    while (slotCount < classCount * 2) {
        slotCount <<= 1;
    }
    return slotCount;
}

static int64_t mp_census_lookup(const MPCensusContext *context, uintptr_t cls) {
    size_t slot = mp_census_hash(cls, context->slotMask);
    while (context->slots[slot] >= 0) {
        int64_t classIndex = context->slots[slot];
        if (context->classes[classIndex] == cls) {
            return classIndex;
        }
        slot = (slot + 1) & context->slotMask;
    }
    return -1;
}

static void mp_census_insert(MPCensusContext *context, size_t classIndex) {
    uintptr_t cls = context->classes[classIndex];
    if (cls == 0 || mp_census_lookup(context, cls) >= 0) {
        return;
    }
    size_t slot = mp_census_hash(cls, context->slotMask);
    while (context->slots[slot] >= 0) {
        slot = (slot + 1) & context->slotMask;
    }
    context->slots[slot] = (int64_t)classIndex;
}

// Runs with the zone locked: arithmetic and reads only, no allocation.
static void mp_census_recorder(task_t task, void *rawContext, unsigned type, vm_range_t *ranges, unsigned rangeCount) {
    (void)task;
    (void)type;
    MPCensusContext *context = rawContext;
    for (unsigned index = 0; index < rangeCount; index++) {
        vm_range_t range = ranges[index];
        if (range.size < sizeof(uintptr_t)) {
            continue;
        }
        int64_t classIndex = mp_census_lookup(context, mp_heap_walker_class_of_block(range.address));
        if (classIndex < 0 || range.size < context->instanceSizes[classIndex]) {
            continue;
        }
        context->counts[classIndex] += 1;
        context->bytes[classIndex] += range.size;
    }
}

bool mp_heap_is_available(void) {
    return mp_heap_walker_is_available();
}

MPHeapStatus mp_heap_census(const uintptr_t *classes,
                            const size_t *instanceSizes,
                            size_t classCount,
                            uint64_t *counts,
                            uint64_t *bytes) {
    if (!mp_heap_walker_is_available()) {
        return MPHeapStatusUnavailable;
    }
    if (classes == NULL || instanceSizes == NULL || counts == NULL || bytes == NULL || classCount == 0) {
        return MPHeapStatusInvalidArgument;
    }
    size_t slotCount = mp_census_slot_count(classCount);
    int64_t *slots = malloc(slotCount * sizeof(int64_t));
    if (slots == NULL) {
        return MPHeapStatusOutOfMemory;
    }
    memset(slots, 0xFF, slotCount * sizeof(int64_t));
    memset(counts, 0, classCount * sizeof(uint64_t));
    memset(bytes, 0, classCount * sizeof(uint64_t));
    MPCensusContext context = { classes, instanceSizes, slots, slotCount - 1, counts, bytes };
    for (size_t classIndex = 0; classIndex < classCount; classIndex++) {
        mp_census_insert(&context, classIndex);
    }
    MPHeapStatus status = mp_heap_walker_walk(mp_census_recorder, &context);
    free(slots);
    return status;
}
