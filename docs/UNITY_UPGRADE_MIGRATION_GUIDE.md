# Unity 6.0 Migration Guide - Practical Steps

This guide provides hands-on, step-by-step instructions for upgrading SdSandbox from Unity 2020.3.49f1 to Unity 6.0 LTS.

**Prerequisites:** Read [UNITY_UPGRADE_EVALUATION_REPORT.md](./UNITY_UPGRADE_EVALUATION_REPORT.md) and [UNITY_UPGRADE_EXECUTIVE_SUMMARY.md](./UNITY_UPGRADE_EXECUTIVE_SUMMARY.md) first.

---

## Table of Contents
1. [Pre-Upgrade Checklist](#1-pre-upgrade-checklist)
2. [Backup Strategy](#2-backup-strategy)
3. [Environment Setup](#3-environment-setup)
4. [Incremental Upgrade Process](#4-incremental-upgrade-process)
5. [Package Migration](#5-package-migration)
6. [Code Updates](#6-code-updates)
7. [Testing Procedures](#7-testing-procedures)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Pre-Upgrade Checklist

### Before You Start
- [ ] Read full evaluation report
- [ ] Get stakeholder approval
- [ ] Allocate 6 weeks development time
- [ ] Ensure team availability
- [ ] Notify collaborators of upgrade plans

### System Requirements
- [ ] **OS:** Windows 10/11 64-bit, macOS 10.15+, or Ubuntu 20.04+
- [ ] **RAM:** 16GB+ recommended (8GB minimum)
- [ ] **Storage:** 20GB+ free space
- [ ] **Graphics:** DX11/Metal/Vulkan support
- [ ] **Unity Hub:** Latest version installed

### Development Environment
- [ ] Git installed and configured
- [ ] Python 3.7+ installed (for testing)
- [ ] All dependencies from `requirements.txt` installed
- [ ] Visual Studio Code or preferred IDE ready

---

## 2. Backup Strategy

### 2.1 Full Project Backup

```bash
# 1. Navigate to project parent directory
cd /path/to/sdsandbox-v25-10-06/..

# 2. Create timestamped backup
DATE=$(date +%Y%m%d-%H%M%S)
tar -czf sdsandbox-backup-${DATE}.tar.gz sdsandbox-v25-10-06/

# 3. Verify backup
tar -tzf sdsandbox-backup-${DATE}.tar.gz | head -20

# 4. Store backup in safe location
mv sdsandbox-backup-${DATE}.tar.gz ~/backups/
```

### 2.2 Git Repository Backup

```bash
cd /path/to/sdsandbox-v25-10-06

# 1. Ensure all changes are committed
git status
git add .
git commit -m "Pre-Unity-6-upgrade checkpoint"

# 2. Create backup branch
git branch backup/unity-2020.3-$(date +%Y%m%d)

# 3. Create upgrade branch
git checkout -b upgrade/unity-6.0-incremental

# 4. Push to remote
git push -u origin upgrade/unity-6.0-incremental
git push origin backup/unity-2020.3-$(date +%Y%m%d)
```

### 2.3 Document Current State

```bash
# Create baseline documentation directory
mkdir -p docs/upgrade-baseline

# 1. Record Unity version
cp sdsim/ProjectSettings/ProjectVersion.txt docs/upgrade-baseline/

# 2. Record package versions
cp sdsim/Packages/manifest.json docs/upgrade-baseline/

# 3. List all C# scripts with line counts
find sdsim/Assets/Scripts -name "*.cs" -exec wc -l {} \; > docs/upgrade-baseline/script-lines.txt

# 4. Git commit
git add docs/upgrade-baseline/
git commit -m "Add upgrade baseline documentation"
```

---

## 3. Environment Setup

### 3.1 Install Unity Hub

**Windows:**
```powershell
# Download from https://unity.com/download
# Or use Chocolatey:
choco install unityhub
```

**macOS:**
```bash
# Download from https://unity.com/download
# Or use Homebrew:
brew install --cask unity-hub
```

**Linux:**
```bash
# Download Unity Hub AppImage
wget https://public-cdn.cloud.unity3d.com/hub/prod/UnityHub.AppImage
chmod +x UnityHub.AppImage
./UnityHub.AppImage
```

### 3.2 Install Unity Versions

Using Unity Hub, install:
1. **Unity 2021.3 LTS** (latest patch, e.g., 2021.3.45f1)
2. **Unity 2022.3 LTS** (latest patch, e.g., 2022.3.52f1)
3. **Unity 6.0 LTS** (latest patch, e.g., 6.0.27f1)

**Include Modules:**
- [x] Windows Build Support (IL2CPP) [if on Windows]
- [x] Linux Build Support (Mono/IL2CPP) [if targeting Linux]
- [x] macOS Build Support [if targeting macOS]
- [x] Documentation (optional but helpful)

### 3.3 Test Environment

```bash
# Verify Unity versions installed
ls -la ~/Unity/Hub/Editor/  # macOS/Linux
dir "C:\Program Files\Unity\Hub\Editor\"  # Windows

# Expected output:
# 2021.3.45f1/
# 2022.3.52f1/
# 6.0.27f1/
```

---

## 4. Incremental Upgrade Process

### 4.1 Baseline Testing (Unity 2020.3)

```bash
cd /path/to/sdsandbox-v25-10-06

# 1. Open project in Unity 2020.3.49f1
# Via command line (adjust path to your Unity installation):
"/Applications/Unity/Hub/Editor/2020.3.49f1/Unity.app/Contents/MacOS/Unity" -projectPath "$(pwd)/sdsim" -quit

# 2. Manual testing checklist:
```

**Baseline Test Checklist:**
- [ ] Launch Unity, open `sdsim` project
- [ ] Load `Assets/Scenes/generated_road.unity`
- [ ] Click Play button
- [ ] Click "Generate Training Data"
- [ ] Verify car spawns and drives
- [ ] Check console for errors
- [ ] Record FPS (Window → Analysis → Profiler)
- [ ] Take screenshots of: car, camera view, UI
- [ ] Test at least 3 different scenes
- [ ] Save baseline data to `docs/upgrade-baseline/`

### 4.2 Upgrade to Unity 2021.3 LTS

```bash
# 1. Ensure upgrade branch is active
git checkout upgrade/unity-6.0-incremental
git status  # Should show clean working directory

# 2. Open project in Unity 2021.3 LTS
# Unity will automatically upgrade project files
"/Applications/Unity/Hub/Editor/2021.3.45f1/Unity.app/Contents/MacOS/Unity" -projectPath "$(pwd)/sdsim"
```

**During First Open:**
1. Unity will show "API Update Required" dialog → Click **I Made a Backup. Go Ahead!**
2. Unity will upgrade project automatically (may take 5-15 minutes)
3. Watch console for errors during import
4. If errors appear, document them in `docs/upgrade-notes.md`

**Post-Upgrade Validation:**
```bash
# Check Unity upgraded successfully
cat sdsim/ProjectSettings/ProjectVersion.txt
# Expected: m_EditorVersion: 2021.3.45f1 (or similar)

# Test basic functionality
# 1. Open Unity 2021.3 with project
# 2. Load generated_road scene
# 3. Click Play → Test car spawning
# 4. Check for console errors/warnings
# 5. Compare behavior to baseline
```

**If Successful:**
```bash
# Commit Unity 2021.3 upgrade
git add .
git commit -m "Upgrade to Unity 2021.3 LTS - automatic API update"
git push
```

**If Issues:**
- Document all errors in `docs/upgrade-notes.md`
- Try fixing compilation errors first
- If critical issues, rollback: `git reset --hard HEAD~1`

### 4.3 Upgrade to Unity 2022.3 LTS

```bash
# 1. Ensure Unity 2021.3 upgrade is committed
git status  # Should be clean

# 2. Open project in Unity 2022.3 LTS
"/Applications/Unity/Hub/Editor/2022.3.52f1/Unity.app/Contents/MacOS/Unity" -projectPath "$(pwd)/sdsim"
```

**Repeat validation steps from 4.2:**
- Allow API update
- Test scenes
- Check console
- Compare to baseline

**Commit if successful:**
```bash
git add .
git commit -m "Upgrade to Unity 2022.3 LTS - validation passed"
git push
```

### 4.4 Upgrade to Unity 6.0 LTS

```bash
# 1. Ensure Unity 2022.3 upgrade is committed
git status  # Should be clean

# 2. Open project in Unity 6.0 LTS
"/Applications/Unity/Hub/Editor/6.0.27f1/Unity.app/Contents/MacOS/Unity" -projectPath "$(pwd)/sdsim"
```

**Unity 6 Specific Notes:**
- Upgrade process may take longer (10-20 minutes)
- Watch for shader recompilation progress
- Package Manager may show "Resolving packages..." for several minutes

**Post-Unity-6 Validation:**
```bash
# Verify Unity 6
cat sdsim/ProjectSettings/ProjectVersion.txt
# Expected: m_EditorVersion: 6.0.27f1 (or similar)

# Check package versions were updated
cat sdsim/Packages/manifest.json
```

**Commit Unity 6 base upgrade:**
```bash
git add sdsim/ProjectSettings/ sdsim/Packages/
git commit -m "Upgrade to Unity 6.0 LTS - base upgrade complete"
git push
```

---

## 5. Package Migration

### 5.1 Update Package Versions

**Open Unity 6.0 Editor:**
1. Go to **Window → Package Manager**
2. Click **Packages: In Project** dropdown
3. For each package, click and select **Update to X.X.X**

**Packages to Update (verify latest versions):**
- `com.unity.collab-proxy`
- `com.unity.ide.rider`
- `com.unity.ide.visualstudio`
- `com.unity.ide.vscode`
- `com.unity.probuilder`
- `com.unity.test-framework`
- `com.unity.textmeshpro`
- `com.unity.timeline`
- `com.unity.ugui`

**After updating all packages:**
```bash
# Commit package updates
git add sdsim/Packages/
git commit -m "Update all Unity packages to Unity 6 compatible versions"
git push
```

### 5.2 Install Post-Processing v3

**Method 1: Via Package Manager (Recommended)**
1. Open **Window → Package Manager**
2. Click **+ (Add package)** → **Add package by name...**
3. Enter: `com.unity.postprocessing`
4. Click **Add**
5. Wait for installation to complete

**Method 2: Via manifest.json**
```bash
# Edit sdsim/Packages/manifest.json
# Add this line to "dependencies":
"com.unity.postprocessing": "3.4.0",
```

Save and return to Unity - it will auto-install.

**Verify Installation:**
```bash
grep "postprocessing" sdsim/Packages/manifest.json
# Expected output: "com.unity.postprocessing": "3.4.0",
```

### 5.3 Remove Old Post-Processing Stack v2

**IMPORTANT:** Do this AFTER installing v3 package!

1. In Unity Project panel, right-click `Assets/PostProcessing/`
2. Select **Delete**
3. Confirm deletion

**Or via command line (when Unity is CLOSED):**
```bash
# Backup old post-processing first
mkdir -p docs/upgrade-backup/
cp -r sdsim/Assets/PostProcessing docs/upgrade-backup/

# Remove old post-processing
rm -rf sdsim/Assets/PostProcessing
rm -f sdsim/Assets/PostProcessing.meta

# Commit
git add sdsim/Assets/
git commit -m "Remove deprecated Post-Processing Stack v2, using package v3"
git push
```

### 5.4 Remove Standard Assets

**Audit Usage First:**
```bash
# Search for Standard Assets references in scenes
grep -r "Standard Assets" sdsim/Assets/Scenes/*.unity | wc -l

# If count > 0, need to carefully extract those components
# If count = 0, safe to delete
```

**Assuming safe to delete:**
```bash
# Backup first
cp -r "sdsim/Assets/Standard Assets" docs/upgrade-backup/

# Remove Standard Assets
rm -rf "sdsim/Assets/Standard Assets"
rm -f "sdsim/Assets/Standard Assets.meta"

# Commit
git add sdsim/Assets/
git commit -m "Remove deprecated Standard Assets (Unity 6 incompatible)"
git push
```

---

## 6. Code Updates

### 6.1 Update .NET API Level

**In Unity Editor:**
1. Go to **Edit → Project Settings → Player**
2. Expand **Other Settings**
3. Find **Api Compatibility Level**
4. Change from **.NET Standard 2.0** to **.NET Standard 2.1**
5. Click **Apply**
6. Wait for scripts to recompile

**Verify:**
```bash
grep "apiCompatibilityLevel" sdsim/ProjectSettings/ProjectSettings.asset
# Expected: apiCompatibilityLevel: 6  (still 6, but now means 2.1)
```

### 6.2 Fix Compilation Errors

**Check Console:**
- Open Unity Editor
- Check **Console** window (Ctrl+Shift+C / Cmd+Shift+C)
- Filter by **Errors** only

**Common Issues and Fixes:**

#### Issue 1: WWWForm Deprecation (if applicable)
**File:** `sdsim/Assets/Scripts/SocketIO/JSONObject/JSONObject.cs`

**Current Code:**
```csharp
public static implicit operator WWWForm(JSONObject obj) {
    WWWForm form = new WWWForm();
    // ...
}
```

**Fix (if causes errors in Unity 6):**
```csharp
// Replace WWWForm with UnityWebRequest approach
// Or comment out if not used:
/*
public static implicit operator WWWForm(JSONObject obj) {
    WWWForm form = new WWWForm();
    // ...
}
*/
```

**Test if this code is even used:**
```bash
grep -r "WWWForm" sdsim/Assets/Scripts/*.cs | grep -v "JSONObject.cs" | wc -l
# If 0, then it's only in JSONObject.cs and likely unused - safe to comment out
```

#### Issue 2: Camera Rendering API (if errors occur)
**File:** `sdsim/Assets/Scripts/camera/CameraSensor.cs`

**If you get RenderTexture errors, no changes needed unless specifically required.**

**Performance Optimization (optional):**
```csharp
// Original ReadPixels approach works, but AsyncGPUReadback is faster:
// Add this method for async capture (Unity 6 optimized):
public async Task<byte[]> GetImageDataAsync()
{
    var request = AsyncGPUReadback.Request(sensorCam.targetTexture, 0, TextureFormat.RGB24);
    await request.WaitForCompletion();
    
    if (request.hasError)
    {
        Debug.LogError("GPU readback error");
        return null;
    }
    
    return request.GetData<byte>().ToArray();
}
```

**Only implement if current approach has performance issues.**

### 6.3 Test Network Code

**File:** `sdsim/Assets/Scripts/VersionCheck.cs`

This file should work as-is in Unity 6. Test by:
1. Opening `menu` scene
2. Clicking Play
3. Checking console for web request completion

**No code changes expected here.**

### 6.4 Validate WheelCollider Usage

**Files:** `Car.cs`, `WheelPhys.cs`

**No code changes needed initially.** WheelCollider API is stable.

**However, physics behavior may differ. Document in testing phase:**
```bash
# Create physics tuning document
cat > docs/physics-tuning.md << EOF
# Physics Tuning Notes - Unity 6

## Baseline (Unity 2020.3)
- maxSpeed: 30 m/s
- maxTorque: 50 Nm
- maxBreakTorque: 50 Nm
- maxSteer: 16 degrees

## Unity 6 Observations
[To be filled during testing]

## Adjustments Made
[To be filled during tuning]
EOF

git add docs/physics-tuning.md
git commit -m "Add physics tuning documentation template"
```

### 6.5 Commit Code Updates

```bash
git add sdsim/Assets/Scripts/ sdsim/ProjectSettings/
git commit -m "Update code for Unity 6 compatibility (.NET 2.1, API fixes)"
git push
```

---

## 7. Testing Procedures

### 7.1 Compilation Test

```bash
# In Unity Editor:
# 1. Close and reopen Unity to force full recompile
# 2. Check Console for errors
# 3. Ensure zero compilation errors
```

**Expected:** Console shows "0 errors" (warnings OK)

### 7.2 Scene Load Test

**Test all 18 scenes:**
```bash
# List all scenes
find sdsim/Assets/Scenes -name "*.unity" -type f
```

**For each scene:**
1. Open in Unity Editor
2. Click Play
3. Wait 10 seconds
4. Check for errors in Console
5. Take screenshot
6. Exit Play mode
7. Document any issues

**Create test log:**
```bash
cat > docs/scene-test-results.md << EOF
# Scene Test Results - Unity 6

| Scene Name | Loads? | Plays? | Errors | Notes |
|------------|--------|--------|--------|-------|
| generated_road | ✅ | ✅ | 0 | |
| circuit_launch | ✅ | ✅ | 0 | |
| ironcar | | | | |
| mountain_track | | | | |
| thunderhill | | | | |
| network_test | | | | |
| menu | | | | |
| mini_monaco | | | | |
| test_scene | | | | |
| warren | | | | |
| generated_track | | | | |
| waveshare | | | | |
| roboracingleague_1 | | | | |
| makerspace | | | | |
| calib | | | | |
| warehouse | | | | |
| sparkfun_avc | | | | |
| cloud_derby | | | | |

## Issues Found
[Document any problems]

EOF

git add docs/scene-test-results.md
```

### 7.3 Vehicle Physics Test

**Test Script:**
```bash
# Create automated test scene
# 1. Open generated_road scene
# 2. Click Play
# 3. Click "Generate Training Data"
# 4. Let car drive for 60 seconds
# 5. Observe:
#    - Car stays on track?
#    - Steering responsive?
#    - Speed seems correct?
#    - No physics glitches?
```

**Document observations:**
```bash
cat > docs/physics-test-$(date +%Y%m%d).md << EOF
# Physics Test - $(date)

## Unity Version: 6.0.27f1

## Test: generated_road Scene

### Behavior Observations:
- Steering: [Normal / Too sensitive / Too sluggish]
- Acceleration: [Normal / Too fast / Too slow]
- Braking: [Normal / Too strong / Too weak]
- Stability: [Stable / Wobbles / Flips]

### Comparison to Baseline:
[Same / Different - describe differences]

### Action Needed:
[None / Re-tune parameters / Investigate further]

EOF

git add docs/physics-test-*.md
```

### 7.4 Camera/Image Capture Test

**Test image generation:**
1. Open `generated_road` scene
2. Play mode
3. Click "Generate Training Data"
4. Check `sdsim/log/` folder for generated images
5. Verify:
   - Images are generated
   - Resolution correct (default 256x256)
   - Format correct (JPG/PNG/TGA)
   - Quality acceptable

**Compare images:**
```bash
# If you have baseline images from Unity 2020.3:
mkdir -p docs/image-comparison/
cp sdsim/log/image_0000.jpg docs/image-comparison/unity6-image.jpg
# Compare visually or with tool:
# diff docs/upgrade-baseline/image_0000.jpg docs/image-comparison/unity6-image.jpg
```

### 7.5 Python Integration Test

**Test with Python client:**
```bash
# 1. Start Unity, open generated_road scene
# 2. Click Play → "Use NN Steering"
# 3. In terminal, run Python client:
cd src/
python predict_client.py --model=../outputs/highway.h5

# Expected: Car spawns and drives with NN control
# Check for:
# - TCP connection successful
# - Images transmitted
# - Steering commands received
# - Car drives smoothly
```

**Document results:**
```bash
cat >> docs/integration-test-results.md << EOF
# Python Integration Test - $(date)

## Test: predict_client.py

- TCP Connection: [✅ Success / ❌ Failed]
- Image Transmission: [✅ Working / ❌ Broken]
- Steering Control: [✅ Working / ❌ Broken]
- Frame Rate: [XX FPS]

## Issues:
[None / List any problems]

EOF

git add docs/integration-test-results.md
```

### 7.6 Performance Benchmark

**Use Unity Profiler:**
1. Open **Window → Analysis → Profiler**
2. Enter Play mode in `generated_road` scene
3. Spawn 1 car → Record FPS
4. Spawn 5 cars → Record FPS
5. Spawn 10 cars → Record FPS

**Document results:**
```bash
cat > docs/performance-benchmark.md << EOF
# Performance Benchmark

## System Info:
- OS: [Your OS]
- CPU: [Your CPU]
- GPU: [Your GPU]
- RAM: [Your RAM]

## Unity 2020.3 Baseline:
| Cars | FPS | Frame Time |
|------|-----|------------|
| 1 | XX | XX ms |
| 5 | XX | XX ms |
| 10 | XX | XX ms |

## Unity 6.0 LTS:
| Cars | FPS | Frame Time |
|------|-----|------------|
| 1 | | |
| 5 | | |
| 10 | | |

## Improvement:
[XX% faster / XX% slower / Same]

EOF

git add docs/performance-benchmark.md
```

---

## 8. Troubleshooting

### Common Issues

#### Issue: "API Update Failed"
**Symptoms:** Unity shows API Update error on project open

**Solution:**
```bash
# 1. Close Unity
# 2. Delete Library folder
rm -rf sdsim/Library/

# 3. Reopen Unity - will reimport everything (may take 10-20 min)
```

#### Issue: "Package Resolution Failed"
**Symptoms:** Unity shows package errors in Package Manager

**Solution:**
```bash
# 1. Close Unity
# 2. Delete package cache
rm -rf sdsim/Library/PackageCache/
rm sdsim/Packages/packages-lock.json

# 3. Reopen Unity - will re-resolve packages
```

#### Issue: "Shader Compilation Errors"
**Symptoms:** Pink materials in scene, shader errors in console

**Solution:**
1. Select the shader in Project panel
2. Right-click → **Reimport**
3. If still errors, open shader and check for deprecated syntax
4. Consider using Unity Shader upgrader: **Edit → Render Pipeline → Upgrade Project Materials**

#### Issue: "Post-Processing Not Working"
**Symptoms:** No bloom, no color grading, flat visuals

**Solution:**
1. Verify Post-Processing v3 package installed: **Window → Package Manager**
2. Check camera has **Post Process Layer** component
3. Check scene has **Post Process Volume** with profile assigned
4. Check volume's **Is Global** is enabled OR trigger collider encompasses camera

#### Issue: "Car Physics Feels Wrong"
**Symptoms:** Car too sensitive, too sluggish, or unstable

**Solution:**
```csharp
// In Car.cs, adjust these values:
public float maxSpeed = 30f;      // Try: 25-35
public float maxTorque = 50f;     // Try: 40-60
public float maxBreakTorque = 50f; // Try: 40-60
public float maxSteer = 16.0f;    // Try: 12-20

// Save and test iteratively
```

#### Issue: "Network Connection Fails"
**Symptoms:** Python client can't connect, timeout errors

**Solution:**
1. Check Unity Console for TCP server startup message
2. Verify port not blocked by firewall
3. Try restarting both Unity and Python client
4. Check if `TcpServer.cs` has any errors

#### Issue: "Scene Won't Load"
**Symptoms:** Unity crashes or freezes when opening scene

**Solution:**
```bash
# 1. Check scene file not corrupted
git diff sdsim/Assets/Scenes/[scene_name].unity

# 2. If corrupted, restore from backup
git checkout backup/unity-2020.3-YYYYMMDD -- sdsim/Assets/Scenes/[scene_name].unity

# 3. Re-upgrade that scene manually
```

### Emergency Rollback

**If upgrade is unsuccessful after multiple attempts:**

```bash
# 1. Return to backup branch
git checkout backup/unity-2020.3-YYYYMMDD

# 2. Or restore from tarball
cd ..
tar -xzf ~/backups/sdsandbox-backup-TIMESTAMP.tar.gz

# 3. Document what went wrong
cat > docs/upgrade-failure-report.md << EOF
# Upgrade Failure Report

## Date: $(date)
## Unity Version Attempted: 6.0.27f1

## Issues Encountered:
[Describe all problems]

## Attempted Solutions:
[Describe what was tried]

## Recommendation:
[Wait for Unity 6.1? Try different approach? etc.]
EOF

git add docs/upgrade-failure-report.md
git commit -m "Document Unity 6 upgrade failure"
```

---

## Next Steps After Successful Migration

1. **Complete all testing phases** (functional, integration, performance)
2. **Document all changes** in release notes
3. **Update README.md** with Unity 6 requirements
4. **Train team** on Unity 6 features (4-8 hours)
5. **Monitor for issues** for 2-4 weeks
6. **Merge to main** branch after validation period
7. **Tag release** with `v2.0-unity6`

---

## Support Resources

- **Unity 6 Documentation:** https://docs.unity3d.com/6000.0/Documentation/Manual/
- **Unity Forums:** https://forum.unity.com/
- **Project GitHub Issues:** [Create issue for problems]
- **Team Slack/Discord:** [Contact development team]

---

**Document Version:** 1.0  
**Last Updated:** November 10, 2024  
**Maintained By:** Development Team
