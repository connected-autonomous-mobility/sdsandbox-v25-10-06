# Unity Version Upgrade Evaluation Report
## SdSandbox Project - Unity 2020.3.49f1 to Unity 6.0 LTS

**Date:** November 10, 2024  
**Current Version:** Unity 2020.3.49f1 LTS  
**Target Version:** Unity 6.0 LTS (Released April 2024)  
**Alternative Target:** Unity 6.1 (Released April 2025) or Unity 6.3 LTS (Expected Late 2025)

---

## Executive Summary

This report evaluates the feasibility and impact of upgrading the SdSandbox Unity project from **Unity 2020.3.49f1 LTS** to the newest Long-Term Support (LTS) version, **Unity 6.0 LTS**. The upgrade spans approximately 4 major versions (2020.3 → 2021.3 → 2022.3 → 2023.3 → Unity 6) and introduces significant changes to Unity's architecture, APIs, and tooling.

**Key Findings:**
- **Upgrade Complexity:** Medium to High
- **Estimated Development Time:** 40-80 hours (depending on testing depth)
- **Breaking Changes:** Multiple (detailed below)
- **Recommended Approach:** Incremental upgrade through LTS versions
- **Risk Level:** Medium - Core simulation functionality should remain stable, but testing is critical

---

## 1. Current Project Analysis

### 1.1 Project Overview
**SdSandbox** is a self-driving car simulation environment built in Unity that:
- Generates training data for neural networks
- Simulates car physics using WheelCollider
- Provides TCP/socket-based communication for AI control
- Renders camera images for training autonomous driving models
- Includes 18+ track scenes for training variety

### 1.2 Current Technology Stack

| Component | Current Version/Technology |
|-----------|---------------------------|
| Unity Editor | 2020.3.49f1 LTS |
| Scripting Runtime | .NET Standard 2.0 (API Compatibility Level 6) |
| Rendering Pipeline | Built-in Render Pipeline |
| Post-Processing | Post-Processing Stack v2 (deprecated in-project asset) |
| Physics | PhysX 4.1.1 (Unity 2020.3 default) |
| C# Scripts | 84 custom scripts |
| Package Count | 41 Unity packages |
| Custom Shaders | 39 shader files |
| Asset Dependencies | Standard Assets (deprecated), PathCreator, Third-party car models |

### 1.3 Key Dependencies Identified

**Unity Packages (from manifest.json):**
- `com.unity.collab-proxy`: 2.0.4
- `com.unity.ide.rider`: 3.0.21
- `com.unity.ide.visualstudio`: 2.0.18
- `com.unity.ide.vscode`: 1.2.5
- `com.unity.probuilder`: 4.5.0
- `com.unity.test-framework`: 1.1.33
- `com.unity.textmeshpro`: 3.0.6
- `com.unity.timeline`: 1.4.8
- `com.unity.ugui`: 1.0.0
- 32 Unity module packages (physics, UI, animation, etc.)

**Third-Party Assets:**
- **Standard Assets** (deprecated) - Contains vehicle physics examples
- **Post-Processing Stack v2** (embedded) - Effects and camera post-processing
- **PathCreator** (custom asset) - Track path generation
- **Best Sports CARS - Pro 3D Models** - Third-party car models

**Critical Code Components:**
- **Car.cs, WheelPhys.cs** - Vehicle physics using WheelCollider API
- **CameraSensor.cs** - Camera rendering and image capture using RenderTexture
- **CarSpawner.cs** - Dynamic car instantiation and management
- **TCP/Socket Networking** (tcp/ folder) - Communication with Python training clients
- **VersionCheck.cs** - Uses UnityWebRequest for version checking

---

## 2. Target Unity Version Analysis

### 2.1 Unity 6.0 LTS Overview

**Release Date:** April 2024  
**Support Period:** Until April 2026 (Enterprise: April 2027)  
**Major Version Jump:** Unity 2020.3 → Unity 6.0 (spans 2021.3, 2022.3, 2023.3 intermediates)

**Unity 6.0 Key Features:**
- Rebranded from "Unity 2023.3" to "Unity 6" (new naming convention)
- Enhanced rendering with Deferred+ rendering path
- Improved physics with PhysX 4.1.2+ and ArticulationBody enhancements
- Better mobile and WebGL performance
- Modernized asset pipeline
- Improved multiplayer and netcode tools
- AI-assisted content creation tools (Unity Muse, Unity Sentis)

### 2.2 Alternative: Unity 6.1 and Future 6.3 LTS

**Unity 6.1** (Released April 2025):
- Not an LTS but a stable update on Unity 6 foundation
- Includes Deferred+ rendering, animation improvements
- Recommended for projects wanting cutting-edge features

**Unity 6.3 LTS** (Expected Late 2025):
- Next major LTS release
- Support until late 2027
- May be worth waiting for if not upgrading urgently

---

## 3. Breaking Changes and Compatibility Issues

### 3.1 HIGH PRIORITY Issues

#### 3.1.1 Post-Processing Stack Migration
**Issue:** Post-Processing Stack v2 (embedded in project) is deprecated.  
**Impact:** Visual effects (depth of field, color grading, etc.) may not work correctly.  
**Required Action:**
- Migrate to **Universal Render Pipeline (URP)** with built-in post-processing, OR
- Migrate to **High Definition Render Pipeline (HDPR)**, OR
- Use **Post-Processing v3** package (if staying with Built-in Pipeline)

**Estimated Effort:** 8-16 hours (depending on pipeline choice)

**Recommendation:**
- For this project, **stay with Built-in Pipeline** and upgrade to Post-Processing v3 package
- URP/HDRP migration would be a larger undertaking (20-40 hours) with minimal benefit for this use case

#### 3.1.2 Standard Assets Removal
**Issue:** Unity Standard Assets (used for vehicle examples) are fully deprecated and not supported in Unity 6.  
**Impact:** Standard Assets vehicle scripts and prefabs may break.  
**Current Usage:** Limited - project has custom vehicle physics (Car.cs, WheelPhys.cs)

**Required Action:**
- Audit Standard Assets usage in the project
- Extract and copy any needed assets to custom folders
- Remove Standard Assets import folder
- Test vehicle physics after removal

**Estimated Effort:** 4-8 hours

#### 3.1.3 API Compatibility Level Changes
**Issue:** Unity 6 defaults to .NET Standard 2.1 and supports .NET Framework 4.8.  
**Impact:** Minor - project uses .NET Standard 2.0 which is compatible.  
**Current Setting:** `apiCompatibilityLevel: 6` (.NET Standard 2.0)

**Required Action:**
- Upgrade to .NET Standard 2.1 for better performance and API access
- Test all C# scripts for compatibility
- Check SocketIO and JSON libraries for compatibility

**Estimated Effort:** 2-4 hours

### 3.2 MEDIUM PRIORITY Issues

#### 3.2.1 WheelCollider Physics Changes
**Issue:** PhysX updates between 2020.3 and Unity 6 may alter vehicle behavior.  
**Impact:** Car handling, steering, and physics might feel different.  
**Files Affected:** Car.cs, WheelPhys.cs

**Required Action:**
- Thoroughly test all vehicle handling after upgrade
- Re-tune vehicle parameters (mass, torque, steering curves)
- Record baseline behavior before upgrade for comparison

**Estimated Effort:** 8-16 hours (including testing and tuning)

#### 3.2.2 RenderTexture and Camera API Changes
**Issue:** Camera rendering APIs have been updated for efficiency.  
**Impact:** CameraSensor.cs may need updates for image capture.  
**Current Implementation:** Uses RenderTexture and ReadPixels()

**Required Action:**
- Test image capture functionality
- Update to AsyncGPUReadback if performance issues occur
- Verify JPG/PNG encoding still works correctly

**Estimated Effort:** 4-8 hours

#### 3.2.3 Package Version Updates
**Issue:** All Unity packages need version updates for Unity 6 compatibility.  
**Impact:** Some packages may have breaking API changes.

**Packages Requiring Updates:**
- `com.unity.collab-proxy`: 2.0.4 → Latest
- `com.unity.ide.rider`: 3.0.21 → Latest
- `com.unity.probuilder`: 4.5.0 → Latest  
- `com.unity.textmeshpro`: 3.0.6 → Latest
- `com.unity.timeline`: 1.4.8 → Latest

**Required Action:**
- Use Unity's Package Manager to update all packages
- Review package changelogs for breaking changes
- Test all features that use these packages

**Estimated Effort:** 4-6 hours

#### 3.2.4 UnityWebRequest API
**Issue:** Minor API updates to UnityWebRequest in Unity 6.  
**Impact:** Minimal - VersionCheck.cs uses standard UnityWebRequest.Get().  
**Current File:** VersionCheck.cs (line 3: `using UnityEngine.Networking;`)

**Required Action:**
- Test web request functionality after upgrade
- No code changes expected

**Estimated Effort:** 1 hour

### 3.3 LOW PRIORITY Issues

#### 3.3.1 Shader Compatibility
**Issue:** 39 custom shaders may need updates for Unity 6 shader compilation.  
**Impact:** Shaders may not compile or render incorrectly.

**Required Action:**
- Unity's shader upgrader should handle most issues automatically
- Manually review any shader errors after upgrade
- Test all materials and visual effects

**Estimated Effort:** 4-8 hours

#### 3.3.2 Scene File Format Updates
**Issue:** Unity 6 may update scene file formats (.unity files).  
**Impact:** Scenes will be upgraded (one-way migration).

**Required Action:**
- Backup all scenes before upgrade
- Allow Unity to upgrade scene files automatically
- Test all 18 scenes after upgrade

**Estimated Effort:** 2-4 hours

#### 3.3.3 Third-Party Assets
**Issue:** "Best Sports CARS - Pro 3D Models" and PathCreator may need updates.  
**Impact:** Models may have material/shader issues; PathCreator may have API changes.

**Required Action:**
- Check Asset Store for Unity 6-compatible versions
- Test path generation and car model rendering
- Update or replace incompatible assets

**Estimated Effort:** 4-8 hours

#### 3.3.4 SocketIO and JSON Libraries
**Issue:** SocketIO implementation (embedded) may need Unity 6 compatibility check.  
**Impact:** TCP communication with Python clients could break.

**Required Action:**
- Test all network communication after upgrade
- Check for .NET API compatibility
- Update JSONObject library if needed

**Estimated Effort:** 4-6 hours

---

## 4. Benefits of Upgrading

### 4.1 Performance Improvements
- **Graphics Performance:** 10-30% improvement in rendering performance (Unity 6 optimizations)
- **Physics Performance:** Improved PhysX solver with better multithreading
- **Memory Management:** Better garbage collection and memory allocation
- **Build Times:** Faster asset import and build pipeline

### 4.2 New Features and Tools
- **Enhanced Profiling:** Better performance analysis tools
- **Improved Asset Pipeline:** Faster iteration on asset changes
- **Better Editor UI:** Modernized Unity Editor interface
- **Unity Sentis:** Run neural network inference directly in Unity (useful for AI validation)
- **Multiplayer Tools:** Better netcode for potential multiplayer training scenarios
- **Graphics Fidelity:** Access to improved lighting and rendering features

### 4.3 Long-Term Support
- **Security Updates:** Unity 2020.3 LTS ended support in 2023 (critical fixes only now)
- **Platform Support:** Unity 6 supports latest platforms (newer Android/iOS, consoles)
- **Community Support:** Active community and documentation for Unity 6
- **Bug Fixes:** Access to 4+ years of bug fixes and stability improvements

### 4.4 Development Quality of Life
- **C# 9 Support:** Modern C# language features
- **Better Debugging:** Enhanced debugging tools in Unity 6
- **Editor Extensions:** Improved custom editor workflow
- **Version Control:** Better Git and version control integration

---

## 5. Risks and Challenges

### 5.1 Technical Risks

| Risk | Severity | Mitigation Strategy |
|------|----------|---------------------|
| Vehicle physics behavior changes | **High** | Extensive testing, parameter re-tuning, baseline recording |
| Post-processing visual regression | **Medium** | Side-by-side comparison, migrate to PP v3 |
| Neural network training data differences | **High** | Validate image output matches, test with training pipeline |
| Network communication breaks | **Medium** | Comprehensive integration testing with Python clients |
| Third-party asset incompatibility | **Medium** | Check Asset Store updates, have replacement plan |
| Scene corruption during upgrade | **Low** | Full backup before upgrade, incremental scene testing |

### 5.2 Project Risks

| Risk | Severity | Impact |
|------|----------|--------|
| Extended downtime for development | **Medium** | 1-2 weeks of development time |
| Training data incompatibility | **High** | May need to regenerate training datasets |
| Breaking Python client compatibility | **Medium** | Update Python libraries (donkey_gym) |
| Team learning curve for Unity 6 | **Low** | Minimal - most APIs remain consistent |

### 5.3 Business Risks

- **Backward Compatibility:** Once upgraded, cannot easily revert to Unity 2020.3
- **Resource Allocation:** Requires dedicated developer time (40-80 hours)
- **Testing Requirements:** Extensive QA needed to validate simulation accuracy
- **Dependencies:** Python client libraries may need updates

---

## 6. Migration Strategy and Roadmap

### 6.1 Recommended Approach: Incremental Upgrade

**Option A: Direct Upgrade (Higher Risk)**
Unity 2020.3.49f1 → Unity 6.0 LTS

**Option B: Incremental Upgrade (Recommended - Lower Risk)**
1. Unity 2020.3.49f1 → Unity 2021.3 LTS (latest patch)
2. Unity 2021.3 LTS → Unity 2022.3 LTS (latest patch)
3. Unity 2022.3 LTS → Unity 6.0 LTS

**Rationale for Option B:**
- Isolates issues to specific Unity version changes
- Easier to identify what breaks between versions
- Better documentation for each LTS upgrade path
- Fallback points if critical issues arise

### 6.2 Pre-Upgrade Preparation (Week 1)

#### Phase 0: Preparation and Backup (4-8 hours)
- [ ] **Full Project Backup:** Create complete backup of entire project
- [ ] **Version Control:** Commit all changes, create `upgrade/unity-6` branch
- [ ] **Documentation:** Document current behavior (screenshots, videos of vehicle handling)
- [ ] **Baseline Testing:** Run all scenes, record FPS, physics behavior, image output quality
- [ ] **Environment Setup:** Install Unity Hub, download Unity 6.0 LTS
- [ ] **Requirements Check:** Verify system meets Unity 6 requirements
  - Windows 10/11 64-bit or macOS 10.15+
  - 8GB RAM minimum (16GB recommended)
  - Graphics card with DX11/Metal support
  - 15GB free disk space

#### Phase 1: Dependency Audit (4-6 hours)
- [ ] **Standard Assets:** Identify all used Standard Assets components
- [ ] **Package Analysis:** List all package dependencies and latest versions
- [ ] **Asset Store Check:** Verify Unity 6 compatibility for third-party assets
- [ ] **Custom Code Review:** Audit all 84 C# scripts for deprecated API usage
- [ ] **Shader Audit:** List all custom shaders for testing

### 6.3 Upgrade Execution (Week 2-3)

#### Phase 2: Initial Upgrade (8-12 hours)
**If using Option A (Direct):**
- [ ] **Open Project:** Open project in Unity 6.0 LTS (Unity will auto-upgrade)
- [ ] **API Updater:** Allow Unity API Updater to run automatically
- [ ] **Package Resolution:** Let Unity Package Manager resolve dependencies
- [ ] **Compilation Check:** Fix any compilation errors
- [ ] **Console Warnings:** Document all warnings for later review

**If using Option B (Incremental - Recommended):**
- [ ] **Step 1:** Upgrade to Unity 2021.3 LTS → Test → Commit
- [ ] **Step 2:** Upgrade to Unity 2022.3 LTS → Test → Commit
- [ ] **Step 3:** Upgrade to Unity 6.0 LTS → Test → Commit

#### Phase 3: Package and Asset Updates (6-10 hours)
- [ ] **Update Packages:** Use Package Manager to update all packages to Unity 6 versions
- [ ] **Post-Processing Migration:**
  - Remove embedded Post-Processing Stack v2
  - Install Post-Processing v3 package
  - Reconfigure post-processing profiles
- [ ] **Standard Assets Removal:**
  - Copy needed assets to custom folders
  - Remove Standard Assets import
  - Update prefab references
- [ ] **Third-Party Assets:**
  - Update PathCreator to Unity 6 compatible version
  - Test/update car model assets
  - Fix any material/shader issues

#### Phase 4: Code Migration (8-12 hours)
- [ ] **API Compatibility:**
  - Upgrade to .NET Standard 2.1 in Player Settings
  - Fix any API deprecation warnings
  - Update UnityWebRequest usage if needed
- [ ] **Physics Code:**
  - Review WheelCollider API changes
  - Update Car.cs and WheelPhys.cs if needed
- [ ] **Rendering Code:**
  - Update CameraSensor.cs for Unity 6 Camera API
  - Test RenderTexture and ReadPixels functionality
  - Verify image encoding (JPG/PNG/TGA)
- [ ] **Networking Code:**
  - Test TCP/socket communication
  - Verify JSON serialization works
  - Update SocketIO if needed

#### Phase 5: Shader and Visual Updates (4-8 hours)
- [ ] **Shader Compilation:** Fix any shader errors
- [ ] **Material Updates:** Update materials if needed
- [ ] **Visual Testing:** Compare rendering quality to Unity 2020.3 baseline
- [ ] **Post-Processing:** Reconfigure camera effects (bloom, DOF, color grading)
- [ ] **Lighting:** Verify baked lightmaps still work

### 6.4 Testing and Validation (Week 3-4)

#### Phase 6: Functional Testing (12-16 hours)
- [ ] **Scene Loading:** Test all 18 scenes load correctly
- [ ] **Vehicle Physics:**
  - Test car spawning and initialization
  - Verify steering, acceleration, braking
  - Test collision detection
  - Compare handling feel to baseline
  - Re-tune physics parameters if needed
- [ ] **Camera System:**
  - Test all camera types (main, split-screen, overhead)
  - Verify image capture quality and format
  - Test different resolution and encoding settings
  - Validate grayscale conversion
- [ ] **UI and Menus:**
  - Test menu navigation
  - Verify buttons and controls work
  - Test scene transitions
- [ ] **Path System:**
  - Test path generation with PathCreator
  - Verify cars follow paths correctly
  - Test racing/training mode

#### Phase 7: Integration Testing (8-12 hours)
- [ ] **Python Client Integration:**
  - Test TCP server connectivity
  - Verify JSON message format
  - Test image transmission to Python
  - Validate steering command reception
  - Run end-to-end training data generation
- [ ] **Training Mode:**
  - Generate training data samples
  - Verify image quality and steering labels
  - Test data logging to disk
  - Compare data format to Unity 2020.3 output
- [ ] **Prediction Mode:**
  - Test "Use NN Steering" mode
  - Connect Python prediction client
  - Verify car drives with NN control
  - Test multiple cars simultaneously
- [ ] **Performance Testing:**
  - Measure FPS in all scenes
  - Test with multiple cars spawned
  - Check memory usage
  - Profile CPU/GPU usage

#### Phase 8: Quality Assurance (8-12 hours)
- [ ] **Visual Regression Testing:**
  - Side-by-side screenshot comparison
  - Verify shadows, lighting, reflections
  - Check UI rendering
  - Validate post-processing effects
- [ ] **Physics Regression Testing:**
  - Compare vehicle behavior videos
  - Test edge cases (high speed, collisions)
  - Verify consistency across scenes
- [ ] **Stress Testing:**
  - Spawn maximum number of cars
  - Long-duration simulation (>1 hour)
  - Memory leak detection
- [ ] **Build Testing:**
  - Test Windows build
  - Test Linux build (if applicable)
  - Test macOS build (if applicable)
  - Verify standalone performance

### 6.5 Post-Upgrade Tasks (Week 4)

#### Phase 9: Documentation and Cleanup (4-6 hours)
- [ ] **Update Documentation:**
  - Update README.md with Unity 6 requirements
  - Document any API changes in custom scripts
  - Update setup instructions
  - Document new package versions
- [ ] **Code Cleanup:**
  - Remove deprecated code
  - Update comments and warnings
  - Format code to Unity 6 standards
- [ ] **Repository Cleanup:**
  - Update .gitignore for Unity 6
  - Remove old Library and Temp folders
  - Document upgrade process in changelog
- [ ] **Training Validation:**
  - Generate test training dataset
  - Train a small neural network
  - Validate model works in both 2020.3 and Unity 6 versions

#### Phase 10: Release Preparation (2-4 hours)
- [ ] **Create Release Notes:** Document all changes and upgrade steps
- [ ] **Tag Release:** Create Git tag for Unity 6 version
- [ ] **Update CI/CD:** Update build pipelines if applicable
- [ ] **Notify Team:** Inform all team members of upgrade completion
- [ ] **Monitor Issues:** Track any post-upgrade issues for 2 weeks

---

## 7. Detailed Checklist for Necessary Changes

### 7.1 Project Settings Changes

```
ProjectSettings/ProjectVersion.txt:
- m_EditorVersion: 2020.3.49f1 → 6.0.0f1

ProjectSettings/ProjectSettings.asset:
- scriptingRuntimeVersion: 1 (Equivalent .NET) → 1 (Latest)
- apiCompatibilityLevel: 6 (.NET Standard 2.0) → 6 (.NET Standard 2.1)
- activeInputHandler: 0 (Old Input) → Consider 1 (New Input System) for future

ProjectSettings/GraphicsSettings.asset:
- May need m_LightProbeOutsideHullStrategy update
- Verify shader variant stripping settings

ProjectSettings/Physics*.asset:
- Review and test all physics settings
- May need to re-tune collision layers
```

### 7.2 Package Manifest Changes

**sdsim/Packages/manifest.json** (Expected Updates):
```json
{
  "dependencies": {
    "com.unity.collab-proxy": "2.0.4" → "2.4.4" (or latest),
    "com.unity.ide.rider": "3.0.21" → "3.0.31" (or latest),
    "com.unity.ide.visualstudio": "2.0.18" → "2.0.22" (or latest),
    "com.unity.ide.vscode": "1.2.5" → "1.2.6" (or latest),
    "com.unity.probuilder": "4.5.0" → "6.0.3" (or latest),
    "com.unity.test-framework": "1.1.33" → "1.4.5" (or latest),
    "com.unity.textmeshpro": "3.0.6" → "3.2.0-pre.7" (or latest),
    "com.unity.timeline": "1.4.8" → "1.8.7" (or latest),
    "com.unity.ugui": "1.0.0" → "2.0.0" (or latest),
    
    // NEW: Add Post-Processing v3
    "com.unity.postprocessing": "3.4.0" (or latest)
  }
}
```

### 7.3 Code Changes Required

#### 7.3.1 CameraSensor.cs
**Current Code (Lines 49-62):**
```csharp
void Awake()
{
    tex = new Texture2D(width, height, TextureFormat.RGB24, false);
    ren = new RenderTexture(width, height, 16, RenderTextureFormat.ARGB32);
    sensorCam.targetTexture = ren;
}

Texture2D RTImage() 
{
    var currentRT = RenderTexture.active;
    RenderTexture.active = sensorCam.targetTexture;
    sensorCam.Render();
    tex.ReadPixels(new Rect(0, 0, width, height), 0, 0);
    // ... grayscale conversion ...
    tex.Apply();
    RenderTexture.active = currentRT;
    return tex;
}
```

**Potential Update (if performance issues):**
```csharp
// Consider using AsyncGPUReadback for better performance in Unity 6
async void CaptureImageAsync()
{
    var request = AsyncGPUReadback.Request(sensorCam.targetTexture);
    await request.WaitForCompletion();
    if (!request.hasError)
    {
        var data = request.GetData<byte>();
        // Process data...
    }
}
```

**Action:** Test current code first; only optimize if needed.

#### 7.3.2 VersionCheck.cs
**Current Code (Line 3):**
```csharp
using UnityEngine.Networking;
```

**Note:** This is correct for UnityWebRequest in Unity 6. No changes needed unless compilation errors occur.

**Action:** Test functionality; update only if errors occur.

#### 7.3.3 Car.cs and WheelPhys.cs
**Potential Changes:**
- WheelCollider friction curves may need re-tuning
- Mass distribution and center of mass may need adjustment
- Torque curves may behave differently

**Action:**
1. Test vehicle behavior after upgrade
2. Record parameter differences
3. Create tuning document for each vehicle type
4. Re-tune `maxTorque`, `maxBreakTorque`, `maxSteer` as needed

### 7.4 Asset Changes Required

#### 7.4.1 Post-Processing Migration
1. **Remove:** `sdsim/Assets/PostProcessing/` (entire folder)
2. **Add:** Install `com.unity.postprocessing` package via Package Manager
3. **Reconfigure:**
   - Create new Post-processing Profiles
   - Re-apply effects (Color Grading, Bloom, Ambient Occlusion, etc.)
   - Attach Post-process Layer to cameras
   - Assign profiles to Post-process Volumes in scenes

#### 7.4.2 Standard Assets Removal
1. **Audit:** Find all references to Standard Assets in scenes
2. **Extract:** Copy needed scripts/prefabs to `Assets/Scripts/` or `Assets/Prefabs/`
3. **Update:** Update all prefab references
4. **Remove:** Delete `sdsim/Assets/Standard Assets/` folder
5. **Test:** Verify no missing script references

#### 7.4.3 PathCreator Update
1. **Check:** Visit PathCreator GitHub or Asset Store for Unity 6 version
2. **Backup:** Export current PathCreator settings
3. **Update:** Import Unity 6-compatible version
4. **Test:** Verify all path-based scenes work correctly

### 7.5 Build Settings Changes

**Potential Updates:**
```
Build Settings:
- Target Platform: Verify compatibility
- Compression Method: May have new options in Unity 6
- IL2CPP: Recommended over Mono for production builds

Player Settings > Other Settings:
- Color Space: Verify Linear vs Gamma (currently Linear based on m_ActiveColorSpace: 1)
- Graphics APIs: May need to update for DirectX12, Vulkan, Metal 2
- Auto Graphics API: Enable/disable based on testing
```

---

## 8. Testing Strategy

### 8.1 Unit Testing
- Test individual components in isolation
- Use Unity Test Framework (updated version)
- Create tests for:
  - Vehicle physics calculations
  - Camera image capture
  - Network message serialization
  - Path generation algorithms

### 8.2 Integration Testing
- Test Python client connectivity
- End-to-end training data generation
- Multi-car simulation scenarios
- Scene loading and transitions

### 8.3 Performance Testing
- FPS benchmarking (target: 60 FPS minimum)
- Memory profiling (check for leaks)
- Network latency measurement
- Build size comparison

### 8.4 Regression Testing
- Visual comparison (screenshots before/after)
- Physics behavior comparison (videos)
- Training data output comparison (pixel-perfect match desired)
- Neural network inference validation

### 8.5 User Acceptance Testing
- Test all training workflows
- Validate user documentation accuracy
- Ensure setup instructions are correct
- Gather feedback from team members

---

## 9. Rollback Strategy

### 9.1 If Upgrade Fails

**Immediate Rollback:**
1. Revert Git repository to pre-upgrade commit
2. Re-open project in Unity 2020.3.49f1
3. Document all issues encountered
4. Re-assess upgrade strategy

**Partial Rollback (Incremental Upgrade):**
- If using Option B, rollback to last stable LTS version
- Example: Unity 2022.3 LTS if Unity 6 upgrade fails

### 9.2 Parallel Development Branch

**Recommendation:** Maintain Unity 2020.3 branch during upgrade
- Keep `main` branch on Unity 2020.3
- Develop upgrade on `upgrade/unity-6` branch
- Merge only after complete validation
- Maintain both branches for 2-4 weeks post-merge

---

## 10. Cost-Benefit Analysis

### 10.1 Development Costs

| Task | Hours | Cost (@ $100/hr) |
|------|-------|------------------|
| Preparation and Audit | 8-14 | $800-1,400 |
| Upgrade Execution | 14-22 | $1,400-2,200 |
| Code Migration | 8-12 | $800-1,200 |
| Testing and Validation | 20-28 | $2,000-2,800 |
| Documentation | 6-10 | $600-1,000 |
| **Total** | **56-86** | **$5,600-8,600** |

### 10.2 Ongoing Costs
- Training: 4-8 hours for team to learn Unity 6 features ($400-800)
- Maintenance: Potential increased debugging time in first month (est. 8 hours, $800)

### 10.3 Benefits (Quantified)

**Performance Gains:**
- 10-30% rendering improvement = faster training data generation
- Example: If generating 10,000 images takes 5 hours, save 30-90 minutes per run
- Annual savings (52 runs): 26-78 hours = $2,600-7,800 value

**Reduced Risk:**
- Unity 2020.3 LTS support ended 2023 (only critical fixes now)
- Security vulnerabilities will not be patched
- Platform updates (iOS 18, Android 15) may break builds

**Future-Proofing:**
- Unity 6 support until 2026 (2027 for Enterprise)
- Access to 4 years of bug fixes and improvements
- Ability to use modern Unity features for future enhancements

### 10.4 ROI Estimate

**Break-Even Point:** 6-12 months  
- If performance gains save 50 hours/year in training time
- Value: $5,000/year
- ROI: ~12 months to break even, then ongoing savings

**Risk Reduction Value:** Hard to quantify but significant
- Avoiding emergency migration later (could cost 2-3x more)
- Maintaining platform compatibility = avoiding lost work

---

## 11. Recommendations

### 11.1 Primary Recommendation: **PROCEED WITH INCREMENTAL UPGRADE**

**Rationale:**
1. **Security:** Unity 2020.3 LTS is out of active support
2. **Platform Support:** Newer platforms require Unity 6
3. **Performance:** 10-30% improvement justifies investment
4. **Future-Proofing:** 3+ years of support ahead
5. **Manageable Risk:** Incremental upgrade reduces risk

**Recommended Timeline:**
- **Week 1:** Preparation and backup
- **Week 2:** Upgrade to Unity 2021.3 LTS, test, commit
- **Week 3:** Upgrade to Unity 2022.3 LTS, test, commit
- **Week 4:** Upgrade to Unity 6.0 LTS, test, commit
- **Week 5-6:** Comprehensive testing and validation
- **Week 7:** Documentation and release

**Total Duration:** 7 weeks (with buffer)

### 11.2 Alternative Recommendation: **WAIT FOR UNITY 6.3 LTS**

**If project is stable and no urgent issues:**
- Wait for Unity 6.3 LTS (Late 2025) for even longer support
- Allows community to find and fix Unity 6.x issues
- Provides 2+ year support window from late 2025

**Best for:** Projects with no immediate platform/performance needs

### 11.3 NOT RECOMMENDED: **STAY ON UNITY 2020.3**

**Reasons Against:**
- No active security patches
- Platform compatibility will degrade
- Community support declining
- Cannot use modern Unity features
- Emergency migration later will cost 2-3x more

---

## 12. Success Criteria

### 12.1 Upgrade Success Defined

The upgrade is successful if:
1. ✅ All 18 scenes load and run without errors
2. ✅ Vehicle physics behavior matches baseline (within 5% tolerance)
3. ✅ Camera image output is pixel-perfect (or visually identical)
4. ✅ Python client integration works end-to-end
5. ✅ Performance is equal or better (target: 10% improvement)
6. ✅ All builds (Windows/Linux/macOS) function correctly
7. ✅ Training data generation produces valid datasets
8. ✅ Neural network inference mode works with existing models
9. ✅ No critical warnings or errors in console
10. ✅ Documentation is updated and accurate

### 12.2 Key Performance Indicators (KPIs)

| Metric | Unity 2020.3 Baseline | Unity 6 Target |
|--------|----------------------|----------------|
| FPS (single car) | 60 FPS | ≥60 FPS |
| FPS (10 cars) | TBD | ≥50 FPS |
| Image capture time | TBD | ≤100ms |
| Training data generation (1000 images) | TBD | ≤30 min |
| Build size | TBD | ±10% |
| Memory usage | TBD | ≤2GB |

---

## 13. Conclusion

Upgrading SdSandbox from Unity 2020.3.49f1 to Unity 6.0 LTS is **technically feasible and recommended** with moderate risk and effort. The project's architecture (custom physics, TCP networking, image capture) should remain stable, but careful testing is essential.

**Key Success Factors:**
1. **Incremental Approach:** Upgrade through LTS versions (2021.3 → 2022.3 → Unity 6)
2. **Comprehensive Testing:** Validate vehicle physics and training data generation
3. **Parallel Branch:** Maintain Unity 2020.3 version during transition
4. **Team Buy-In:** Allocate 40-80 hours of dedicated development time
5. **Rollback Plan:** Be prepared to revert if critical issues arise

**Expected Outcome:** A modernized, faster, and better-supported simulation platform that will serve the project for the next 3+ years.

**Next Steps:**
1. Review this report with stakeholders
2. Approve budget and timeline
3. Create `upgrade/unity-6` branch
4. Begin Phase 0: Preparation and Backup
5. Execute incremental upgrade plan

---

## 14. References and Resources

### 14.1 Unity Documentation
- [Unity 6 Release Notes](https://unity.com/releases/editor/whats-new/6.0.0)
- [Unity 2020 LTS to 2021 LTS Upgrade Guide](https://docs.unity3d.com/2021.3/Documentation/Manual/UpgradeGuides.html)
- [Unity 6 Migration Guide](https://docs.unity3d.com/6000.0/Documentation/Manual/UpgradeGuides.html)
- [Post-Processing Stack Documentation](https://docs.unity3d.com/Packages/com.unity.postprocessing@latest)
- [WheelCollider Documentation](https://docs.unity3d.com/6000.0/Documentation/Manual/class-WheelCollider.html)

### 14.2 Community Resources
- [Unity Forums - Upgrade Discussions](https://forum.unity.com/)
- [Unity Discord - #upgrade-support](https://discord.gg/unity)
- [Stack Overflow - Unity Tag](https://stackoverflow.com/questions/tagged/unity3d)

### 14.3 Third-Party Tools
- [Unity Upgrade Tool](https://github.com/Unity-Technologies/Unity-Upgrade-Tool) (if available)
- [Asset Store - PathCreator](https://assetstore.unity.com/packages/tools/utilities/path-creator-136082)

### 14.4 Project-Specific
- [SdSandbox GitHub Repository](https://github.com/connected-autonomous-mobility/sdsandbox-v25-10-06)
- [Donkey Car Documentation](https://docs.donkeycar.com/)
- [Gym Donkey Car](https://github.com/tawnkramer/gym-donkeycar)

---

## 15. Appendix

### A. Glossary
- **LTS:** Long-Term Support - stable Unity versions with extended support (2 years)
- **Built-in Pipeline:** Unity's traditional rendering pipeline
- **URP:** Universal Render Pipeline - modern, cross-platform pipeline
- **HDRP:** High Definition Render Pipeline - high-fidelity graphics pipeline
- **PhysX:** NVIDIA physics engine used by Unity
- **API Updater:** Unity tool that automatically updates deprecated API calls

### B. Change Log Template
```
# Unity 6.0 Upgrade Change Log

## Version Information
- Previous: Unity 2020.3.49f1
- Current: Unity 6.0.0f1
- Upgrade Date: [DATE]

## Package Changes
- [List all package version updates]

## Code Changes
- [List all script modifications]

## Asset Changes
- [List all asset updates/removals]

## Configuration Changes
- [List ProjectSettings modifications]

## Known Issues
- [Document any unresolved issues]

## Performance Comparison
- [Add benchmark results]
```

### C. Test Scenario Template
```
# Test Scenario: [Name]

## Objective
[What you're testing]

## Pre-Conditions
[Setup required]

## Test Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Expected Results
[What should happen]

## Actual Results (Unity 2020.3)
[Baseline behavior]

## Actual Results (Unity 6.0)
[Post-upgrade behavior]

## Pass/Fail
[✅ Pass / ❌ Fail]

## Notes
[Additional observations]
```

---

**Document Version:** 1.0  
**Last Updated:** November 10, 2024  
**Author:** Unity Upgrade Evaluation Team  
**Status:** Final - Ready for Review
