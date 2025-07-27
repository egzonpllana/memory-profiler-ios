//
//  MemoryProfilerServicing.swift
//  MemoryProfiler
//
//  Created by Egzon Pllana on 26.7.25.
//

import Foundation

/// Environment configuration for the memory profiler service.
///
/// This enum determines when the memory profiler service should be active:
/// - `.debugOnly`: Only runs in debug builds
/// - `.all`: Runs in all builds (debug and release)
public enum MemoryProfilerEnvironment: Sendable {
    /// Only runs in debug builds
    case debugOnly
    /// Runs in all builds (debug and release)
    case all
}

/// A production-grade memory profiling service for iOS applications.
///
/// This service provides real-time memory monitoring, leak detection, and memory usage analytics
/// designed for enterprise-level applications. It uses system-level APIs to provide accurate
/// memory statistics and helps developers identify memory issues during development.
///
/// ## Overview
///
/// The `MemoryProfilerService` is designed to:
/// - Monitor real-time memory usage using `mach_task_basic_info`
/// - Detect potential memory leaks
/// - Provide memory usage analytics
/// - Automatically warn when memory usage exceeds thresholds
/// - Integrate with the app's logging system
///
/// ## Usage
///
/// ```swift
/// // In AppDelegate
/// @Injected private var memoryProfilerService: MemoryProfilerServicing
///
/// func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
///     memoryProfilerService.startMonitoring()
///     return true
/// }
///
/// // In ViewModels
/// func loadData() {
///     memoryProfilerService.logMemoryUsage(context: "Data loading")
///     // Your data loading logic
/// }
///
/// // Runtime configuration
/// memoryProfilerService.disable()  // Turn off monitoring
/// memoryProfilerService.enable()   // Turn on monitoring
/// ```
///
/// ## Features
///
/// - **Real-time monitoring**: Uses `mach_task_basic_info` for accurate memory usage
/// - **Device-aware thresholds**: Automatically sets warning thresholds based on device RAM
/// - **Leak detection**: Identifies potential memory leaks
/// - **Simple logging**: Uses print statements
/// - **Configurable runtime**: Enable/disable at runtime
/// - **Environment configuration**: Can be configured to run in debug-only or all builds
///
/// ## Memory Thresholds
///
/// The service automatically sets warning thresholds to 70% of device RAM:
/// - iPhone SE (2GB): ~1.4GB warning threshold
/// - iPhone 15 Pro Max (8GB): ~5.6GB warning threshold
///
/// ## When to Use
///
/// - **Development**: Monitor memory usage during feature development
/// - **Performance testing**: Identify memory spikes during heavy operations
/// - **Leak detection**: Find memory leaks in image processing, networking
/// - **Optimization**: Before/after refactoring to measure improvements
public protocol MemoryProfilerServicing {

    /// Starts monitoring memory usage and leak detection.
    ///
    /// This method:
    /// - Begins periodic memory checks (every 30 seconds)
    /// - Registers for system memory warnings
    /// - Starts logging memory usage statistics
    ///
    /// Call this once in your `AppDelegate` when the app launches.
    /// Only active based on the configured environment.
    func startMonitoring()

    /// Stops monitoring memory usage and leak detection.
    ///
    /// This method:
    /// - Stops periodic memory checks
    /// - Unregisters from system memory warnings
    /// - Cleans up monitoring resources
    ///
    /// Call this in your `AppDelegate` when the app terminates.
    func stopMonitoring()

    /// Gets current memory usage statistics.
    ///
    /// Returns a `MemoryStats` object containing:
    /// - Used memory (resident size)
    /// - Available memory
    /// - Total device memory
    /// - Memory usage percentage
    /// - Peak memory usage
    ///
    /// - Returns: Current memory statistics
    func getMemoryStats() -> MemoryStats

    /// Checks for potential memory leaks.
    ///
    /// Analyzes the current memory state and identifies potential leaks:
    /// - ViewModels that might be retained
    /// - Large image caches
    /// - Network tasks that haven't been cleaned up
    ///
    /// - Returns: Array of detected memory leaks
    func detectMemoryLeaks() -> [MemoryLeakInfo]

    /// Logs current memory usage to the console.
    ///
    /// Outputs a formatted message with:
    /// - Memory usage percentage
    /// - Used/available/total memory in MB
    /// - Peak memory usage
    ///
    /// Use this for debugging specific operations or monitoring memory trends.
    func logMemoryUsage(context: String)

    /// Sets the memory warning threshold.
    ///
    /// When memory usage exceeds this threshold, a warning is logged.
    /// The default is 70% of device RAM, but you can customize this
    /// based on your app's memory requirements.
    ///
    /// - Parameter threshold: Memory threshold in bytes
    func setMemoryWarningThreshold(_ threshold: UInt64)
    
    /// Enables the memory profiler service.
    ///
    /// This will allow the service to start monitoring and logging memory usage.
    /// If monitoring was previously stopped, it will not automatically restart.
    func enable()
    
    /// Disables the memory profiler service.
    ///
    /// This will stop all monitoring activities and clear any active timers.
    /// The service will not perform any operations until re-enabled.
    func disable()
    
    /// Returns whether the service is currently enabled.
    var isServiceEnabled: Bool { get }
    
    /// Returns the configured environment for the service.
    var environment: MemoryProfilerEnvironment { get }
} 
