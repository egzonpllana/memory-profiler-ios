//
//  TaskMemoryInfo.c
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

#include "MemoryProfilerNative.h"
#include <mach/mach.h>
#include <stddef.h>

// Revision-independent: the kernel reports how many words it filled, so each field is read
// only when the returned count covers it. This works with SDK headers of any revision.
#define MP_TASK_VM_INFO_COVERS(count, field) \
    ((count) >= (mach_msg_type_number_t)((offsetof(task_vm_info_data_t, field) + sizeof(((task_vm_info_data_t *)0)->field)) / sizeof(natural_t)))

bool mp_task_memory_info(MPTaskMemoryInfo *info) {
    if (info == NULL) {
        return false;
    }
    task_vm_info_data_t vmInfo = { 0 };
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t result = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&vmInfo, &count);
    if (result != KERN_SUCCESS || !MP_TASK_VM_INFO_COVERS(count, phys_footprint)) {
        return false;
    }
    info->footprint = vmInfo.phys_footprint;
    info->peakFootprint = vmInfo.phys_footprint;
    if (MP_TASK_VM_INFO_COVERS(count, ledger_phys_footprint_peak) && vmInfo.ledger_phys_footprint_peak > 0) {
        info->peakFootprint = (uint64_t)vmInfo.ledger_phys_footprint_peak;
    }
    info->limitBytesRemaining = 0;
    if (MP_TASK_VM_INFO_COVERS(count, limit_bytes_remaining)) {
        info->limitBytesRemaining = vmInfo.limit_bytes_remaining;
    }
    return true;
}
