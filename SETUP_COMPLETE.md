# Build Environment Setup - Complete

## ✅ Setup Complete

Your OnePlus 12 (waffle-22825 512GB Global) build environment documentation is now complete and ready to use!

## 📚 Documentation Files Created

### 1. [README.md](README.md) - Main Documentation
**Start here!** Comprehensive guide covering:
- Prerequisites and dependencies
- Repo tool setup with OnePlus kernel manifest
- Build instructions for GKI 2.0 kernel
- Build output locations
- Advanced configuration
- Troubleshooting

**Target audience:** All users building OnePlus 12 kernel

### 2. [BUILD_GUIDE.md](BUILD_GUIDE.md) - Detailed Build Instructions
**For step-by-step guidance:** Detailed walkthrough including:
- System preparation with exact commands
- Workspace initialization
- Complete sync process
- Build monitoring and verification
- Output file descriptions
- Advanced Bazel/Kleaf options

**Target audience:** First-time builders and those wanting detailed explanations

### 3. [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Command Reference
**For quick lookups:** Fast reference with:
- All common build commands
- Parameter explanations
- File locations
- Troubleshooting quick fixes
- Build time estimates

**Target audience:** Experienced users needing quick command reference

### 4. [DEVICE_WAFFLE_512GB.md](DEVICE_WAFFLE_512GB.md) - Device-Specific Guide ⭐
**For your specific device!** Focused documentation for:
- OnePlus 12 waffle-22825 512GB Global variant
- Hardware specifications and features
- Device tree files specific to your device
- Flash instructions for your device
- Device-specific troubleshooting

**Target audience:** OnePlus 12 512GB Global owners (like you!)

### 5. [setup_build_env.sh](setup_build_env.sh) - Automated Setup Script
**For automated setup:** Bash script that:
- Checks all dependencies
- Validates disk space
- Initializes workspace
- Configures repo with correct manifest
- Syncs all repositories
- Verifies setup completion

**Usage:** `./setup_build_env.sh`

## 🎯 Quick Start Paths

### Path 1: Automated Setup (Recommended for Beginners)
```bash
# 1. Clone this repository
git clone https://github.com/2loch-ness6/android_kernel_modules_and_devicetree_oneplus_sm8650.git
cd android_kernel_modules_and_devicetree_oneplus_sm8650

# 2. Read device-specific guide
cat DEVICE_WAFFLE_512GB.md

# 3. Run automated setup (from a different directory, not inside this repo)
cd ~
./path/to/setup_build_env.sh
```

### Path 2: Manual Setup (For Experienced Users)
```bash
# 1. Read quick reference
cat QUICK_REFERENCE.md

# 2. Install repo and dependencies
mkdir -p ~/.bin && curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+x ~/.bin/repo

# 3. Initialize and build
mkdir ~/oneplus12_kernel && cd ~/oneplus12_kernel
repo init -u https://github.com/OnePlusOSS/kernel_manifest.git -b oneplus/sm8650 -m oneplus_12_u.xml
repo sync -c -j$(nproc)
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki
```

## 🔧 Build Configuration Summary

### What You're Building
- **Device:** OnePlus 12 (waffle-22825)
- **Storage:** 512GB UFS 4.0
- **Region:** Global/International
- **Platform:** SM8650 (pineapple) - Snapdragon 8 Gen 3
- **OS:** Android 14 OxygenOS
- **Kernel:** GKI 2.0 (Generic Kernel Image 2.0)
- **Build Type:** User (`u` variant from oneplus_12_u.xml)

### Key Repositories Used
1. **Common Kernel**: `android_kernel_common_oneplus_sm8650` (oneplus/sm8650_u_14.0.0_oneplus12)
2. **MSM Kernel**: `android_kernel_oneplus_sm8650` (oneplus/sm8650_u_14.0.0_oneplus12)
3. **This Repo**: `android_kernel_modules_and_devicetree_oneplus_sm8650` (oneplus/sm8650_u_14.0.0_oneplus12)
4. **Prebuilts**: Qualcomm CodeLinaro toolchains and build tools

### Build System
- **Primary:** Bazel/Kleaf (Google's kernel build system)
- **Wrapper:** OnePlus build scripts in `kernel_platform/oplus/build/`
- **Platform Target:** `pineapple`
- **Variant Target:** `gki`

## 📱 Device Tree Overlay

Your specific device uses:
```
waffle-22825-pineapple-overlay.dtbo
```

This overlay configures:
- ✅ 512GB UFS 4.0 storage
- ✅ Display (LTPO AMOLED 2K+ 120Hz)
- ✅ Cameras (50MP main, 48MP ultrawide, 64MP periscope)
- ✅ Charging (100W/80W wired, 50W wireless)
- ✅ Sensors (accelerometer, gyroscope, etc.)
- ✅ Fingerprint (under-display optical)
- ✅ Audio (dual stereo speakers)
- ✅ RF/Antenna (global bands)
- ✅ NFC (global standards)
- ✅ eSIM support

## 🚀 Next Steps

### 1. Choose Your Path
- **New to kernel building?** → Start with [README.md](README.md) and use [setup_build_env.sh](setup_build_env.sh)
- **Want detailed explanations?** → Read [BUILD_GUIDE.md](BUILD_GUIDE.md)
- **Experienced builder?** → Use [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- **Waffle 512GB owner?** → Check [DEVICE_WAFFLE_512GB.md](DEVICE_WAFFLE_512GB.md)

### 2. Prepare Your System
- Ubuntu 20.04+ or compatible Linux distribution
- 100GB+ free disk space
- 16GB+ RAM (32GB recommended)
- Stable internet connection

### 3. Install Dependencies
```bash
sudo apt-get update
sudo apt-get install -y build-essential libncurses-dev bison flex \
    libssl-dev libelf-dev bc cpio python3 python3-pip git openjdk-11-jdk
```

### 4. Run Setup
Choose one:
- Automated: `./setup_build_env.sh`
- Manual: Follow README.md instructions

### 5. Build
```bash
cd ~/oneplus12_kernel
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki
```

### 6. Find Your Outputs
```bash
ls -lh ~/oneplus12_kernel/kernel_platform/out/msm-kernel-pineapple-gki/dist/
```

Look for:
- `Image` - Your kernel
- `dtbo.img` - Device tree overlay (includes waffle-22825)
- `boot.img` - Flashable boot image
- `*.ko` - Kernel modules

## ⚠️ Important Notes

### Before Building
1. ✅ Read the documentation relevant to your experience level
2. ✅ Ensure you have enough disk space (100GB minimum)
3. ✅ Verify all dependencies are installed
4. ✅ Have stable internet for initial sync (~2-3GB download)

### Before Flashing
1. ⚠️ **BACKUP ALL DATA** - Flashing will erase your device
2. ⚠️ **Unlock bootloader** - Required for flashing (voids warranty)
3. ⚠️ **Test in safe environment** - Don't flash on your daily driver until tested
4. ⚠️ **Have stock images ready** - For recovery if something goes wrong

## 🆘 Getting Help

### Troubleshooting Order
1. Check the **Troubleshooting** section in [README.md](README.md)
2. Review **Common Issues** in [BUILD_GUIDE.md](BUILD_GUIDE.md)
3. Check **Quick Fixes** in [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
4. Search GitHub issues
5. Ask in XDA OnePlus 12 forums

### When Asking for Help
Include:
- Device: OnePlus 12 waffle-22825 512GB Global
- Build command used
- Complete error log
- OS version (Ubuntu 22.04, etc.)
- Output of: `repo list` and `repo status`

## 📊 Build Time Expectations

### First Build
- **Download/Sync**: 15-30 minutes (depends on internet)
- **Compilation**: 30-60 minutes (depends on CPU)
- **Total**: ~45-90 minutes

### Incremental Builds
- **Compilation**: 5-15 minutes (only changed files)

### System Impact During Build
- **CPU**: 100% usage (all cores)
- **RAM**: 8-16GB usage
- **Disk**: Heavy I/O activity

## ✨ What Makes This Build Special

### GKI 2.0 Benefits
- ✅ Kernel updates independent of vendor code
- ✅ Stable KMI (Kernel Module Interface)
- ✅ Better security update path
- ✅ Modular architecture
- ✅ ABI compatibility

### OnePlus 12 Optimizations
- ✅ Snapdragon 8 Gen 3 optimizations
- ✅ LTPO display support
- ✅ 100W charging control
- ✅ Periscope camera ISP tuning
- ✅ UFS 4.0 optimization

### Quality Assurance
- ✅ Based on official OnePlus OSS release
- ✅ Qualcomm CodeLinaro prebuilts
- ✅ Stock OxygenOS compatibility
- ✅ Tested hardware configurations

## 🎓 Learning Resources

### Understanding GKI 2.0
- [Android GKI Documentation](https://source.android.com/docs/core/architecture/kernel/generic-kernel-image)
- Google's kernel strategy for Android 14+
- Separation of core kernel and vendor modules

### Understanding Bazel/Kleaf
- `kernel_platform/build/kernel/kleaf/README.md`
- Modern build system for Android kernels
- Hermetic, cacheable, parallel builds

### Understanding Device Trees
- `kernel_platform/qcom/proprietary/devicetree/`
- Hardware description files (.dts/.dtsi)
- Device-specific configurations

## 📜 License Information

- **Kernel**: GPL v2
- **OnePlus Modules**: GPL v2 / Apache 2.0
- **Qualcomm Code**: Various open source licenses
- **Build System**: Apache 2.0

See individual source files for specific license details.

## 🙏 Acknowledgments

- **OnePlus** for open source kernel releases
- **Qualcomm** for CodeLinaro prebuilts
- **Google** for GKI 2.0 and Kleaf/Bazel
- **Community** for testing and feedback

## 🔗 Important Links

- **This Repository**: https://github.com/2loch-ness6/android_kernel_modules_and_devicetree_oneplus_sm8650
- **OnePlus OSS**: https://github.com/OnePlusOSS
- **Kernel Manifest**: https://github.com/OnePlusOSS/kernel_manifest
- **Qualcomm Code**: https://git.codelinaro.org
- **Android Source**: https://source.android.com

---

## Ready to Build? 🚀

**Choose your starting point:**

- 👉 **Complete beginner**: Start with [README.md](README.md)
- 👉 **Want step-by-step**: Read [BUILD_GUIDE.md](BUILD_GUIDE.md)
- 👉 **Need quick commands**: Check [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- 👉 **Waffle 512GB owner**: See [DEVICE_WAFFLE_512GB.md](DEVICE_WAFFLE_512GB.md)
- 👉 **Want automation**: Run [setup_build_env.sh](setup_build_env.sh)

**Happy building!** 🎉

---

*Last updated: 2026-02-06*
*Repository: android_kernel_modules_and_devicetree_oneplus_sm8650*
*Branch: oneplus/sm8650_u_14.0.0_oneplus12*
