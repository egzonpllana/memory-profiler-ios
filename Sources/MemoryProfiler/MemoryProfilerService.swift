//
//  MemoryProfilerService.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.7.25.
//

import Foundation
import MachO
import Darwin

/// Production-grade memory profiling service implementation.
///
/// This service provides enterprise-level memory monitoring using system APIs
/// and integrates with the app's logging system for consistent output.
public final class MemoryProfilerService: MemoryProfilerServicing {
    
    // MARK: - Properties
    
    /// Whether memory monitoring is currently active
    private var isMonitoring = false
    
    /// Whether the service is enabled (can be toggled at runtime)
    private var isEnabled: Bool
    
    /// The environment configuration for the service
    public private(set) var environment: MemoryProfilerEnvironment
    
    /// Memory threshold that triggers warnings (in bytes)
    private var memoryWarningThreshold: UInt64 = 0
    
    /// Highest memory usage recorded since monitoring started
    private var peakMemoryUsage: UInt64 = 0
    
    /// History of memory statistics for trend analysis
    private var memoryHistory: [MemoryStats] = []
    
    /// Timer for periodic memory checks
    private var leakDetectionTimer: Timer?
    
    /// Count of different object types for leak detection
    private var objectCounts: [String: Int] = [:]
    
    // MARK: - Initialization
    
    /// Creates a new memory profiler service.
    ///
    /// Automatically sets the warning threshold to 70% of device RAM,
    /// which is the industry standard for memory warning thresholds.
    ///
    /// - Parameters:
    ///   - isEnabled: Whether the service should be enabled by default (default: true)
    ///   - environment: The environment configuration for the service (default: .debugOnly)
    public init(
        isEnabled: Bool = true,
        environment: MemoryProfilerEnvironment = .debugOnly
    ) {
        self.isEnabled = isEnabled
        self.environment = environment
        
        let total = MemoryProfilerService.totalMemory()
        memoryWarningThreshold = UInt64(Double(total) * 0.7)
        print("Memory warning threshold set to \(memoryWarningThreshold.inMB)MB (70% of \(total.inMB)MB total)")
    }
    
    // MARK: - Public Methods
    
    public func startMonitoring() {
        guard shouldRun() else { return }
        guard !isMonitoring else { return }
        
        isMonitoring = true
        print("🧠 Memory Profiler: Started monitoring")
        
        // Start periodic memory checks every 60 seconds (reduced frequency)
        leakDetectionTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.performMemoryCheck()
        }
        
        // Note: System memory warnings are handled differently in Swift Package
        // For now, we'll rely on periodic checks
    }
    
    public func stopMonitoring() {
        guard shouldRun() else { return }
        guard isMonitoring else { return }
        
        isMonitoring = false
        print("🧠 Memory Profiler: Stopped monitoring")
        
        leakDetectionTimer?.invalidate()
        leakDetectionTimer = nil
        
        // Memory warning observer cleanup not needed in Swift Package
    }
    
    public func getMemoryStats() -> MemoryStats {
        guard shouldRun() else {
            return MemoryStats(usedMemory: 0, availableMemory: 0, totalMemory: 0, peakMemoryUsage: 0)
        }
        
        let used = MemoryProfilerService.currentMemoryUsage()
        let total = MemoryProfilerService.totalMemory()
        let available = total > used ? total - used : 0
        
        let stats = MemoryStats(
            usedMemory: used,
            availableMemory: available,
            totalMemory: total,
            peakMemoryUsage: peakMemoryUsage
        )
        
        // Update peak memory usage
        if used > peakMemoryUsage {
            peakMemoryUsage = used
        }
        
        return stats
    }
    
    public func detectMemoryLeaks() -> [MemoryLeakInfo] {
        guard shouldRun() else { return [] }
        
        // TODO: Implement real leak detection using runtime introspection
        // For now, return empty array
        return []
    }
    
    public func logMemoryUsage(context: String = "") {
        guard shouldRun() else { return }
        
        let stats = getMemoryStats()
        let contextMessage = context.isEmpty ? "" : " [\(context)]"
        print("🧠 Memory usage: \(String(format: "%.2f", stats.memoryUsagePercentage))% (used: \(stats.usedMemory.inMB)MB, available: \(stats.availableMemory.inMB)MB, total: \(stats.totalMemory.inMB)MB)\(contextMessage)")
    }
    
    public func setMemoryWarningThreshold(_ threshold: UInt64) {
        guard shouldRun() else { return }
        
        memoryWarningThreshold = threshold
        print("Set memory warning threshold to \(threshold.inMB)MB")
    }
    
    /// Enables the memory profiler service.
    ///
    /// This will allow the service to start monitoring and logging memory usage.
    /// If monitoring was previously stopped, it will not automatically restart.
    public func enable() {
        isEnabled = true
        print("🧠 Memory Profiler: Enabled")
    }
    
    /// Disables the memory profiler service.
    ///
    /// This will stop all monitoring activities and clear any active timers.
    /// The service will not perform any operations until re-enabled.
    public func disable() {
        isEnabled = false
        
        // Stop monitoring if it was active
        if isMonitoring {
            stopMonitoring()
        }
        
        print("🧠 Memory Profiler: Disabled")
    }
    
    /// Returns whether the service is currently enabled.
    public var isServiceEnabled: Bool {
        return isEnabled
    }

    // MARK: - Private Methods
    
    /// Determines whether the service should run based on enabled state and environment configuration.
    private func shouldRun() -> Bool {
        // Check if service is enabled
        guard isEnabled else { return false }
        
        // Check environment configuration
        switch environment {
        case .debugOnly:
            #if DEBUG
            return true
            #else
            return false
            #endif
        case .all:
            return true
        }
    }
    
    /// Performs a periodic memory check and logs warnings if needed.
    private func performMemoryCheck() {
        let stats = getMemoryStats()
        
        if stats.usedMemory > memoryWarningThreshold {
            print("⚠️ WARNING: Memory usage exceeded threshold: \(stats.usedMemory.inMB)MB > \(memoryWarningThreshold.inMB)MB")
        } else {
            print("🧠 Periodic memory check: \(stats.usedMemory.inMB)MB used")
        }
    }
    
    /// Handles system memory warnings.
    private func handleMemoryWarning() {
        print("⚠️ Received system memory warning!")
    }
    
    // MARK: - System Memory APIs
    
    /// Gets the current memory usage of the app process.
    ///
    /// Uses `mach_task_basic_info` to get the resident size of the current process.
    /// This is the most accurate way to measure memory usage on iOS.
    ///
    /// - Returns: Current memory usage in bytes
    private static func currentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }
        
        return kerr == KERN_SUCCESS ? UInt64(info.resident_size) : 0
    }
    
    /// Gets the total physical memory on the device.
    ///
    /// Uses `ProcessInfo.processInfo.physicalMemory` to get the total RAM.
    ///
    /// - Returns: Total device memory in bytes
    private static func totalMemory() -> UInt64 {
        return ProcessInfo.processInfo.physicalMemory
    }
} 
