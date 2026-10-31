//
//  SysctlDebuggerDetector.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 31.10.26.
//

import Darwin

/// Detects an attached debugger through the `P_TRACED` process flag.
struct SysctlDebuggerDetector: DebuggerDetecting {

    var isDebuggerAttached: Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var managementInformationBase: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        let result = sysctl(&managementInformationBase, UInt32(managementInformationBase.count), &info, &size, nil, 0)
        return result == 0 && (info.kp_proc.p_flag & P_TRACED) != 0
    }
}
