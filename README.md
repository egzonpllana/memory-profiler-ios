# MemoryProfiler

A production-grade memory profiling SDK for iOS and macOS applications. Real-time monitoring, lifecycle-based leak detection, and snapshot diff analysis — all within a lightweight Swift Package.

## Why MemoryProfiler?

Memory is the silent architecture of every running application — invisible when managed well, catastrophic when neglected. MemoryProfiler is the sentinel that watches what you cannot see: the objects that refuse to leave, the allocations that grow without permission, the thresholds that approach without warning. It does not guess. It tracks weak references, diffs allocation snapshots, and reports what the runtime will not tell you on its own. Name it what it does — profile memory, precisely and without ceremony.

## Features

- **Real-time monitoring** via `mach_task_basic_info` with configurable intervals
- **Weak reference leak detection** — track objects, detect survivors past expected lifetime
- **Snapshot diff analysis** — flag monotonically growing allocation counts
- **DeinitTracker utility** — one-line verification that objects deallocate on time
- **Device-aware thresholds** — default warning at 70% of physical RAM
- **Runtime control** — enable/disable without recompilation
- **Environment gating** — `.debugOnly` (default) or `.all` builds
- **Thread-safe** — all mutable state protected by `os_unfair_lock`
- **Fully injectable** — every component is protocol-based for testability

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/egzonpllana/MemoryProfiler.git", from: "2.0.0")
]
```

## Quick Start

```swift
let profiler = MemoryProfilerService()
profiler.startMonitoring()
```

## Leak Detection

### Weak Reference Tracking

Register objects you expect to be deallocated. The profiler holds a weak reference and reports any that survive past their expected lifetime.

```swift
// When presenting a screen:
let viewModel = DetailViewModel()
profiler.trackObject(viewModel, expectedLifetime: .scopeBound)

// After dismissing, check:
let leaks = profiler.detectMemoryLeaks()
// Reports viewModel if still alive after grace period (default 3s)
```

Time-bound tracking for objects with known lifetimes:

```swift
profiler.trackObject(cache, expectedLifetime: .timeBound(seconds: 30))
```

### DeinitTracker (Standalone)

No profiler setup required. Drop this into any dismissal flow:

```swift
func dismiss() {
    DeinitTracker.expectDeinit(of: viewModel)
    navigationController?.popViewController(animated: true)
}
// Logs warning if viewModel is still alive after 2 seconds
```

### Snapshot Diffing

For long-running monitoring, track allocation counts across intervals:

```swift
let engine = SnapshotDiffEngine(consecutiveGrowthThreshold: 3)

// Record snapshots periodically:
engine.recordSnapshot(
    MemorySnapshot(
        typeCounts: ["DetailViewModel": liveCount],
        totalMemoryUsed: currentUsage
    )
)

// Analyze for monotonic growth:
let suspects = engine.analyzeGrowth()
```

## Memory Monitoring

```swift
// Get current stats
let stats = profiler.getMemoryStats()
let usedMB = stats.usedMemory / 1024 / 1024
let percentage = stats.memoryUsagePercentage

// Log at key points
profiler.logMemoryUsage(context: "After image processing")

// Custom threshold
profiler.setMemoryWarningThreshold(1024 * 1024 * 1024) // 1GB
```

## Configuration

```swift
// Debug-only (default) — no output in release builds
let profiler = MemoryProfilerService(
    isEnabled: true,
    environment: .debugOnly
)

// All builds — for staging/QA environments
let profiler = MemoryProfilerService(
    isEnabled: true,
    environment: .all
)

// Runtime control
profiler.disable()   // Stops all monitoring
profiler.enable()    // Re-enables (does not auto-restart monitoring)
```

## Dependency Injection

All components are protocol-based. Inject custom implementations for testing or custom logging:

```swift
let profiler = MemoryProfilerService(
    monitor: CustomMemoryMonitor(),
    scheduler: CustomScheduler(),
    leakDetector: CustomLeakDetector(),
    logger: CustomLogger()
)
```

Protocols: `MemoryMonitoring`, `MonitoringScheduling`, `LeakDetecting`, `MemoryLogging`.

## Console Output

```
[MemoryProfiler] Threshold set to 5376MB (70% of 7680MB total)
[MemoryProfiler] Started monitoring
[MemoryProfiler] Memory: 45.23% (used: 3456MB, available: 4224MB, total: 7680MB)
[MemoryProfiler] Periodic check: 3200MB used
[MemoryProfiler] WARNING: Memory exceeded threshold: 5500MB > 5376MB
[MemoryProfiler] Potential leak: DetailViewModel was not deallocated after 2.0s
```

## Architecture

```
Sources/MemoryProfiler/
  MemoryProfilerService.swift        -- facade coordinator
  MemoryProfilerServicing.swift      -- public protocol
  Models/                            -- MemoryStats, MemoryLeakInfo, MemorySnapshot, MonitoringState
  Monitoring/                        -- MemoryMonitoring protocol + SystemMemoryMonitor
  LeakDetection/                     -- LeakDetecting, WeakReferenceTracker, SnapshotDiffEngine, DeinitTracker
  Scheduling/                        -- MonitoringScheduling protocol + TimerBasedScheduler
  Logging/                           -- MemoryLogging protocol + ConsoleMemoryLogger
  Internal/                          -- UnfairLock, DebugLog
```

## Requirements

- Swift 5.9+
- iOS 16.0+ / macOS 13.0+

## License

See [LICENSE](LICENSE) for details.
