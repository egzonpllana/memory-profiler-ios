//
//  HeapZoneWalker.h
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#ifndef MEMORY_PROFILER_HEAP_ZONE_WALKER_H
#define MEMORY_PROFILER_HEAP_ZONE_WALKER_H

#include "MemoryProfilerNative.h"
#include <mach/mach.h>
#include <malloc/malloc.h>

/// Whether the walker can run: introspection compiled in and the runtime isa mask exported.
bool mp_heap_walker_is_available(void);

/// Reads the first word of an in-use block and applies the runtime isa class mask.
/// The caller guarantees the block is at least pointer sized and currently locked by its zone.
uintptr_t mp_heap_walker_class_of_block(uintptr_t blockAddress);

/// Locks each malloc zone in turn and reports its in-use blocks to `recorder`.
/// The recorder runs while the zone is locked and must not allocate, free or take other locks.
MPHeapStatus mp_heap_walker_walk(vm_range_recorder_t *recorder, void *context);

#endif /* MEMORY_PROFILER_HEAP_ZONE_WALKER_H */
