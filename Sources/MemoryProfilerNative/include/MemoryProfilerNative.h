//
//  MemoryProfilerNative.h
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#ifndef MEMORY_PROFILER_NATIVE_H
#define MEMORY_PROFILER_NATIVE_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Outcome of a heap introspection call.
typedef enum __attribute__((enum_extensibility(closed))) MPHeapStatus : int32_t {
    /// The walk completed and the output buffers are valid.
    MPHeapStatusSuccess = 0,
    /// Heap introspection is not compiled into this build or the runtime isa mask is missing.
    MPHeapStatusUnavailable = 1,
    /// The malloc zones could not be enumerated.
    MPHeapStatusZoneEnumerationFailed = 2,
    /// Scratch memory for the walk could not be allocated before locking the zones.
    MPHeapStatusOutOfMemory = 3,
    /// The arguments were inconsistent (null buffers or too many targets).
    MPHeapStatusInvalidArgument = 4
} MPHeapStatus;

/// Maximum number of target addresses accepted by `mp_heap_find_references`.
#define MP_HEAP_MAX_REFERENCE_TARGETS 64

/// A heap block that holds a pointer-sized word equal to one of the requested targets.
typedef struct {
    /// Start address of the referring malloc block.
    uintptr_t blockAddress;
    /// Size of the referring malloc block in bytes.
    size_t blockSize;
    /// First word of the block with the runtime isa mask applied. Only meaningful when it matches a known class.
    uintptr_t blockClass;
    /// Byte offset inside the block where the target pointer was found.
    size_t offset;
    /// Index into the targets array of the matched address.
    size_t targetIndex;
} MPHeapReference;

/// Footprint figures of the current task, read with `TASK_VM_INFO`.
typedef struct {
    /// Physical footprint in bytes (the value jetsam and Xcode's memory gauge use).
    uint64_t footprint;
    /// Lifetime peak footprint in bytes; equals `footprint` when the kernel does not report it.
    uint64_t peakFootprint;
    /// Bytes left before the task memory limit; zero when there is no limit or it is unknown.
    uint64_t limitBytesRemaining;
} MPTaskMemoryInfo;

/// Reads the footprint of the current task. Returns false when the kernel call fails.
bool mp_task_memory_info(MPTaskMemoryInfo *info);

/// Whether in-process heap introspection is compiled in and usable.
bool mp_heap_is_available(void);

/// Counts live instances per class by walking every in-use malloc block.
///
/// All scratch memory is allocated before any zone is locked; the per-block callback never allocates.
/// `counts` and `bytes` must hold `classCount` elements and are overwritten.
MPHeapStatus mp_heap_census(const uintptr_t *classes,
                            const size_t *instanceSizes,
                            size_t classCount,
                            uint64_t *counts,
                            uint64_t *bytes);

/// Input and output of a referrer scan.
typedef struct {
    /// Addresses to search for. At most `MP_HEAP_MAX_REFERENCE_TARGETS`.
    const uintptr_t *targets;
    size_t targetCount;
    /// Block start addresses that must never be reported (the caller's own bookkeeping).
    const uintptr_t *ignoredBlocks;
    size_t ignoredCount;
    /// Output buffer for matches.
    MPHeapReference *references;
    size_t referenceCapacity;
    /// Number of matches written to `references`.
    size_t referenceCount;
    /// Optional output with `targetCount` elements: the second word of each target block
    /// (the Swift inline reference count), read while its zone was locked. Zero when not found.
    uintptr_t *targetSecondWords;
} MPHeapReferenceQuery;

/// Finds heap blocks that contain a pointer-sized word equal to one of the query targets.
///
/// The scan is conservative: any aligned word with a matching value is reported, which includes
/// Objective-C weak and Swift unowned references. Ignored blocks and the query buffers are skipped.
MPHeapStatus mp_heap_find_references(MPHeapReferenceQuery *query);

#ifdef __cplusplus
}
#endif

#endif /* MEMORY_PROFILER_NATIVE_H */
