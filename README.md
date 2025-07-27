# 🫆Memory Profiler SDK

A production-grade memory profiling service for iOS applications that provides real-time memory monitoring, leak detection, and memory usage analytics.

## 🎯 What It Is

The `Memory Profiler SDK` is a comprehensive memory monitoring solution designed for enterprise-level iOS applications. It uses system-level APIs (`mach_task_basic_info`) to provide accurate memory statistics and helps developers identify memory issues during development.

## 🚀 Why It Exists

- **Memory Leaks**: Detect ViewModels, Services, or other objects that aren't being deallocated properly
- **Performance Monitoring**: Track memory usage during heavy operations (image processing, networking)
- **Optimization**: Before/after refactoring to measure improvements
- **Production Readiness**: Ensure your app doesn't crash due to memory issues

## 🛠️ Features

- **Real-time monitoring** using `mach_task_basic_info`
- **Device-aware thresholds** (70% of device RAM by default)
- **Leak detection** for ViewModels and Services
- **Simple logging** with print statements
- **Configurable runtime** - enable/disable at runtime
- **Environment configuration** - can be configured to run in debug-only or all builds
- **No #if DEBUG needed** - automatic conditional compilation

## 📱 How to Use

### 1. **AppDelegate Setup**

```swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var memoryProfilerService = MemoryProfilerService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        memoryProfilerService.startMonitoring()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        memoryProfilerService.stopMonitoring()
    }
}
```

### 2. **Configuration Options**

```swift
// Initialize with custom settings
let profiler = MemoryProfilerService(
    isEnabled: true,           // Enable the service (default: true)
    environment: .debugOnly    // Only run in debug builds (default: .debugOnly)
)

// Runtime control
profiler.disable()        // Turn off monitoring and clear timers
profiler.enable()         // Turn on monitoring

// Check status
if profiler.isServiceEnabled {
    profiler.logMemoryUsage(context: "Active monitoring")
}

print("Environment: \(profiler.environment)")
```

### 3. **ViewModels Integration**

```swift
final class MyViewModel: ObservableLoggableObject {
    private var memoryProfilerService = MemoryProfilerService()
    
    func loadData() {
        memoryProfilerService.logMemoryUsage(context: "Before loading data")
        
        Task {
            do {
                let data = try await apiClient.request(endpoint)
                memoryProfilerService.logMemoryUsage(context: "After loading data")
            } catch {
                // Handle error
            }
        }
    }
}
```

### 4. **Heavy Operations Monitoring**

```swift
func processLargeImages() {
    memoryProfilerService.logMemoryUsage(context: "Before image processing")
    
    // Your heavy image processing
    for image in largeImageArray {
        processImage(image)
    }
    
    memoryProfilerService.logMemoryUsage(context: "After image processing")
}
```

## 🎛️ Customization Options

### **Runtime Configuration**

```swift
// Initialize with custom settings
let profiler = MemoryProfilerService(
    isEnabled: true,           // Enable the service
    environment: .debugOnly    // Only run in debug builds
)

// Runtime control
profiler.disable()        // Turn off monitoring
profiler.enable()         // Turn on monitoring

// Status checks
if profiler.isServiceEnabled {
    // Service is active
}

if profiler.environment == .debugOnly {
    // Service only runs in debug builds
}
```

### **Memory Warning Threshold**

```swift
// Set custom threshold (default is 70% of device RAM)
memoryProfilerService.setMemoryWarningThreshold(1024 * 1024 * 1024) // 1GB
```

### **Memory Statistics**

```swift
let stats = memoryProfilerService.getMemoryStats()
print("Used: \(stats.usedMemory / 1024 / 1024)MB")
print("Available: \(stats.availableMemory / 1024 / 1024)MB")
print("Total: \(stats.totalMemory / 1024 / 1024)MB")
print("Usage: \(String(format: "%.2f", stats.memoryUsagePercentage))%")
```

## 🎯 When to Use

### **Development Phase**
- Monitor memory usage during feature development
- Check for leaks after adding new ViewModels or Services
- Verify memory cleanup in `deinit` methods

### **Performance Testing**
- Before/after heavy operations (image processing, file uploads)
- During network requests with large payloads
- When implementing caching mechanisms

### **Optimization**
- Before/after refactoring to measure improvements
- When implementing lazy loading
- After adding new dependencies

### **Debugging**
- When app crashes with memory warnings
- When performance feels sluggish
- When investigating memory-related bugs

## 📊 What You'll See

### **Normal Operation**
```
🧠 Memory Profiler: Started monitoring
🧠 Memory warning threshold set to 5376MB (70% of 7680MB total)
🧠 Memory usage: 45.23% (used: 3456MB, available: 4224MB, total: 7680MB)
```

### **Memory Warning**
```
⚠️ WARNING: Memory usage exceeded threshold: 5500MB > 5376MB
⚠️ Received system memory warning!
```

### **Periodic Checks**
```
🧠 Periodic memory check: 3200MB used
🧠 Memory usage: 41.67% (used: 3200MB, available: 4480MB, total: 7680MB)
```

## 🔧 Integration with Your App

### **Simple Integration**

The service can be used directly without dependency injection:

```swift
// Direct instantiation
private var memoryProfilerService = MemoryProfilerService()
```

### **Zero Production Impact**

- **Debug builds**: Full implementation with real monitoring
- **Release builds**: Stub implementation (no-op, zero performance impact)
- **No #if DEBUG needed**: Automatic conditional compilation

## 🚨 Best Practices

### **1. Strategic Logging**
```swift
// ✅ Good - Log before/after heavy operations
func uploadImages() {
    memoryProfilerService.logMemoryUsage(context: "Before upload")
    // Upload logic
    memoryProfilerService.logMemoryUsage(context: "After upload")
}

// ❌ Avoid - Logging too frequently
func everyMethod() {
    memoryProfilerService.logMemoryUsage()  // Too much noise
}
```

### **2. Combine with Deinit Logging**
```swift
deinit {
    log("MyViewModel deallocated")  // Track object lifecycle
    currentTask?.cancel()
    cancellables.removeAll()
}
```

### **3. Monitor Specific Operations**
```swift
func loadContacts() {
    memoryProfilerService.logMemoryUsage(context: "Before loading contacts")
    
    Task {
        let contacts = try await apiClient.request(APIEndpoint.fetchContacts)
        
        await MainActor.run {
            self.contacts = contacts
            memoryProfilerService.logMemoryUsage(context: "After loading contacts")
        }
    }
}
```

## 🔍 Troubleshooting

### **High Memory Usage**
1. Check if ViewModels are being deallocated properly
2. Look for retain cycles in closures
3. Verify `cancellables.removeAll()` in `deinit`
4. Check for large image caches

### **Memory Leaks**
1. Ensure `deinit` methods are called
2. Check for strong reference cycles
3. Verify task cancellation in ViewModels
4. Look for unclosed network connections

### **Performance Issues**
1. Monitor memory during heavy operations
2. Check for memory spikes during image processing
3. Verify memory cleanup after operations

## 📈 Advanced Usage

### **Runtime Configuration Management**
```swift
// Conditional enabling based on build configuration
#if DEBUG
memoryProfilerService.enable()
#else
memoryProfilerService.disable()
#endif

// Feature flag integration
if featureFlags.isMemoryProfilingEnabled {
    memoryProfilerService.enable()
} else {
    memoryProfilerService.disable()
}
```

### **Custom Memory Thresholds**
```swift
// Set different thresholds for different devices
#if targetEnvironment(simulator)
memoryProfilerService.setMemoryWarningThreshold(512 * 1024 * 1024) // 512MB for simulator
#else
memoryProfilerService.setMemoryWarningThreshold(1024 * 1024 * 1024) // 1GB for device
#endif
```

### **Memory Statistics Analysis**
```swift
let stats = memoryProfilerService.getMemoryStats()

if stats.memoryUsagePercentage > 80 {
    logWarning("High memory usage detected: \(stats.memoryUsagePercentage)%")
}

if stats.usedMemory > stats.peakMemoryUsage * 0.9 {
    logWarning("Approaching peak memory usage")
}
```

### **Leak Detection**
```swift
let leaks = memoryProfilerService.detectMemoryLeaks()
for leak in leaks {
    logError("Potential leak: \(leak.objectType) - \(leak.objectCount) objects")
}
```

## 🚀 Advanced Features

### **System Integration**
- **Memory Warnings**: Automatically detects system memory warnings
- **Background Monitoring**: Continues monitoring during app lifecycle
- **Crash Prevention**: Helps identify memory issues before crashes

### **Development Workflow**
1. **Start monitoring** in AppDelegate
2. **Log before/after** heavy operations
3. **Monitor deinit** calls for proper cleanup
4. **Check logs** for memory warnings
5. **Optimize** based on findings

## 🎯 Summary

The `Memory Profiler SDK` provides enterprise-grade memory monitoring with:

- ✅ **Zero production impact** (debug-only by default)
- ✅ **Runtime configuration** (enable/disable at runtime)
- ✅ **No #if DEBUG needed** (automatic conditional compilation)
- ✅ **Real system APIs** (accurate memory data)
- ✅ **Device-aware thresholds** (70% of RAM)
- ✅ **Easy integration** (DI-ready)

Use it to ensure your app never crashes due to memory issues and maintains optimal performance! 🚀 
