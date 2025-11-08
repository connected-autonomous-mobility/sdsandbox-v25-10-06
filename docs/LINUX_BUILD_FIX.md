# Linux Build Fix Documentation

## Problem Description

The Unity project was failing to compile on Linux systems (tested on Ubuntu 24.04.03) with errors referencing missing paths like `/home/bokken/...`. The same project compiled successfully on Mac systems.

## Root Cause

The `/home/bokken/` path is Unity's internal build server path. This path appears in the `com.unity.toolchain.win-x86_64-linux-x86_64` package, which is a cross-compilation toolchain designed specifically for **building Linux binaries from Windows**.

When this package is present:
- On Windows: It enables cross-compilation to Linux (intended use)
- On Mac/Linux: It causes build failures because it references non-existent hardcoded paths from Unity's build infrastructure

## Solution

Removed the Windows-to-Linux cross-compilation toolchain package from the Unity package manifest, allowing Unity to use native build tools on each platform.

### Files Modified

1. **sdsim/Packages/manifest.json**
   - Removed: `"com.unity.toolchain.win-x86_64-linux-x86_64": "0.1.19-preview"`

2. **sdsim/Packages/packages-lock.json**
   - Removed: `com.unity.toolchain.win-x86_64-linux-x86_64`
   - Removed: `com.unity.sysroot` (dependency)
   - Removed: `com.unity.sysroot.linux-x86_64` (dependency)

## Impact

### Positive Effects
- ✅ Fixes compilation errors on Linux systems
- ✅ Mac builds continue to work with native tools
- ✅ Linux builds use native Linux compilation tools
- ✅ No code changes required
- ✅ Smaller package dependency footprint

### Considerations
- ⚠️ Windows users who want to cross-compile to Linux will need to manually add the toolchain package back
- ⚠️ For Windows cross-compilation, add to `sdsim/Packages/manifest.json`:
  ```json
  "com.unity.toolchain.win-x86_64-linux-x86_64": "2.0.6"
  ```
  (Use version 2.0.6 or later for better compatibility)

## Platform-Specific Build Instructions

### Building on Mac
No special configuration needed. Unity will use the native Mac build tools.

### Building on Linux
No special configuration needed. Unity will use the native Linux build tools.

### Building on Windows for Linux Target
If you need to cross-compile from Windows to Linux:

1. Add the toolchain package to `sdsim/Packages/manifest.json`:
   ```json
   "com.unity.toolchain.win-x86_64-linux-x86_64": "2.0.6"
   ```

2. Install the Linux Build Support (IL2CPP) module via Unity Hub

3. Set the build target to Linux in Unity's Build Settings

## References

- [Unity Toolchain Documentation](https://docs.unity3d.com/Packages/com.unity.toolchain.win-x86_64-linux-x86_64@1.0/manual/index.html)
- [Unity Forum Discussion on Toolchain Issues](https://discussions.unity.com/tag/com_unity_toolchain_win-x86_64-linux-x86_64)
- [Stack Overflow: Linux IL2CPP Build Issues](https://stackoverflow.com/questions/73086079/unity-building-linux-il2cpp-player-requires-a-sysroot-toolchain-package-to-be-in)
