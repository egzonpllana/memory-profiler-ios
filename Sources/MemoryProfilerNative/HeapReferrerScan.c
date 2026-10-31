//
//  HeapReferrerScan.c
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#include "HeapZoneWalker.h"
#include <stdlib.h>
#include <string.h>

#define MP_TARGET_SLOT_COUNT 128
#define MP_MAX_SCANNED_BLOCK_SIZE (32u * 1024u * 1024u)

typedef struct {
    uintptr_t slotValues[MP_TARGET_SLOT_COUNT];
    size_t slotIndices[MP_TARGET_SLOT_COUNT];
    uintptr_t minimumTarget;
    uintptr_t maximumTarget;
    const uintptr_t *ignoredBlocks;
    size_t ignoredCount;
    const void *excludedPointers[3];
    MPHeapReference *references;
    size_t capacity;
    size_t count;
    uintptr_t *targetSecondWords;
} MPReferenceContext;

static size_t mp_reference_hash(uintptr_t value) {
    return (size_t)(((uint64_t)value >> 3) * 0x9E3779B97F4A7C15ULL) & (MP_TARGET_SLOT_COUNT - 1);
}

static void mp_reference_insert_target(MPReferenceContext *context, uintptr_t target, size_t targetIndex) {
    size_t slot = mp_reference_hash(target);
    while (context->slotValues[slot] != 0 && context->slotValues[slot] != target) {
        slot = (slot + 1) & (MP_TARGET_SLOT_COUNT - 1);
    }
    context->slotValues[slot] = target;
    context->slotIndices[slot] = targetIndex;
    context->minimumTarget = target < context->minimumTarget ? target : context->minimumTarget;
    context->maximumTarget = target > context->maximumTarget ? target : context->maximumTarget;
}

static long mp_reference_lookup(const MPReferenceContext *context, uintptr_t value) {
    size_t slot = mp_reference_hash(value);
    while (context->slotValues[slot] != 0) {
        if (context->slotValues[slot] == value) {
            return (long)context->slotIndices[slot];
        }
        slot = (slot + 1) & (MP_TARGET_SLOT_COUNT - 1);
    }
    return -1;
}

static int mp_compare_addresses(const void *lhs, const void *rhs) {
    uintptr_t left = *(const uintptr_t *)lhs;
    uintptr_t right = *(const uintptr_t *)rhs;
    return (left > right) - (left < right);
}

static bool mp_reference_is_ignored(const MPReferenceContext *context, uintptr_t blockAddress) {
    size_t low = 0;
    size_t high = context->ignoredCount;
    while (low < high) {
        size_t middle = low + (high - low) / 2;
        uintptr_t candidate = context->ignoredBlocks[middle];
        if (candidate == blockAddress) {
            return true;
        }
        if (candidate < blockAddress) {
            low = middle + 1;
        } else {
            high = middle;
        }
    }
    return false;
}

static bool mp_reference_is_excluded(const MPReferenceContext *context, vm_range_t range) {
    if (range.size > MP_MAX_SCANNED_BLOCK_SIZE || range.size < sizeof(uintptr_t)) {
        return true;
    }
    for (size_t index = 0; index < 3; index++) {
        uintptr_t pointer = (uintptr_t)context->excludedPointers[index];
        if (pointer >= range.address && pointer < range.address + range.size) {
            return true;
        }
    }
    return mp_reference_is_ignored(context, range.address);
}

static void mp_reference_record(MPReferenceContext *context, vm_range_t range, size_t offset, size_t targetIndex) {
    if (context->count >= context->capacity) {
        return;
    }
    MPHeapReference *reference = &context->references[context->count];
    reference->blockAddress = range.address;
    reference->blockSize = range.size;
    reference->blockClass = mp_heap_walker_class_of_block(range.address);
    reference->offset = offset;
    reference->targetIndex = targetIndex;
    context->count += 1;
}

static void mp_reference_capture_target_header(MPReferenceContext *context, vm_range_t range, const uintptr_t *words) {
    if (context->targetSecondWords == NULL || range.size < 2 * sizeof(uintptr_t)) {
        return;
    }
    long targetIndex = mp_reference_lookup(context, range.address);
    if (targetIndex >= 0) {
        context->targetSecondWords[targetIndex] = words[1];
    }
}

// Runs with the zone locked: reads and writes into preallocated buffers only.
static void mp_reference_recorder(task_t task, void *rawContext, unsigned type, vm_range_t *ranges, unsigned rangeCount) {
    (void)task;
    (void)type;
    MPReferenceContext *context = rawContext;
    for (unsigned index = 0; index < rangeCount && context->count < context->capacity; index++) {
        vm_range_t range = ranges[index];
        if (mp_reference_is_excluded(context, range)) {
            continue;
        }
        const uintptr_t *words = (const uintptr_t *)range.address;
        size_t wordCount = range.size / sizeof(uintptr_t);
        mp_reference_capture_target_header(context, range, words);
        for (size_t word = 0; word < wordCount; word++) {
            uintptr_t value = words[word];
            if (value < context->minimumTarget || value > context->maximumTarget) {
                continue;
            }
            long targetIndex = mp_reference_lookup(context, value);
            if (targetIndex >= 0) {
                mp_reference_record(context, range, word * sizeof(uintptr_t), (size_t)targetIndex);
            }
        }
    }
}

static MPHeapStatus mp_reference_validate(const MPHeapReferenceQuery *query) {
    if (!mp_heap_walker_is_available()) {
        return MPHeapStatusUnavailable;
    }
    if (query == NULL || query->targets == NULL || query->references == NULL || query->referenceCapacity == 0) {
        return MPHeapStatusInvalidArgument;
    }
    if (query->targetCount == 0 || query->targetCount > MP_HEAP_MAX_REFERENCE_TARGETS) {
        return MPHeapStatusInvalidArgument;
    }
    return MPHeapStatusSuccess;
}

static MPHeapStatus mp_reference_copy_ignored(const MPHeapReferenceQuery *query, uintptr_t **sortedIgnored) {
    *sortedIgnored = NULL;
    if (query->ignoredBlocks == NULL || query->ignoredCount == 0) {
        return MPHeapStatusSuccess;
    }
    *sortedIgnored = malloc(query->ignoredCount * sizeof(uintptr_t));
    if (*sortedIgnored == NULL) {
        return MPHeapStatusOutOfMemory;
    }
    memcpy(*sortedIgnored, query->ignoredBlocks, query->ignoredCount * sizeof(uintptr_t));
    qsort(*sortedIgnored, query->ignoredCount, sizeof(uintptr_t), mp_compare_addresses);
    return MPHeapStatusSuccess;
}

static void mp_reference_prepare(MPReferenceContext *context, MPHeapReferenceQuery *query, const uintptr_t *sortedIgnored) {
    memset(context, 0, sizeof(*context));
    context->minimumTarget = UINTPTR_MAX;
    context->ignoredBlocks = sortedIgnored;
    context->ignoredCount = sortedIgnored == NULL ? 0 : query->ignoredCount;
    context->excludedPointers[0] = query->references;
    context->excludedPointers[1] = query->targets;
    context->excludedPointers[2] = query->ignoredBlocks;
    context->references = query->references;
    context->capacity = query->referenceCapacity;
    context->targetSecondWords = query->targetSecondWords;
    if (query->targetSecondWords != NULL) {
        memset(query->targetSecondWords, 0, query->targetCount * sizeof(uintptr_t));
    }
    for (size_t index = 0; index < query->targetCount; index++) {
        if (query->targets[index] != 0) {
            mp_reference_insert_target(context, query->targets[index], index);
        }
    }
}

MPHeapStatus mp_heap_find_references(MPHeapReferenceQuery *query) {
    MPHeapStatus status = mp_reference_validate(query);
    if (status != MPHeapStatusSuccess) {
        return status;
    }
    query->referenceCount = 0;
    uintptr_t *sortedIgnored = NULL;
    status = mp_reference_copy_ignored(query, &sortedIgnored);
    if (status != MPHeapStatusSuccess) {
        return status;
    }
    MPReferenceContext context;
    mp_reference_prepare(&context, query, sortedIgnored);
    status = mp_heap_walker_walk(mp_reference_recorder, &context);
    query->referenceCount = context.count;
    free(sortedIgnored);
    return status;
}
