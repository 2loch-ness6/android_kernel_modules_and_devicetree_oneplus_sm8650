# Quick Reference - OnePlus 12 Kernel Build

## Device Info
- **Device**: OnePlus 12
- **Primary Model**: **waffle-22825** (512GB Global) ⭐
- **Platform**: SM8650 (pineapple) - Snapdragon 8 Gen 3
- **OS**: Android 14 OxygenOS
- **Architecture**: GKI 2.0 (Generic Kernel Image 2.0)
- **Build Type**: User (`u` variant)

> **📱 For waffle 512GB Global owners**: See [DEVICE_WAFFLE_512GB.md](DEVICE_WAFFLE_512GB.md)

## Quick Setup

```bash
# Install repo tool
mkdir -p ~/.bin && curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo && chmod a+x ~/.bin/repo
export PATH="${HOME}/.bin:${PATH}"

# Initialize workspace
mkdir ~/oneplus12_kernel && cd ~/oneplus12_kernel
repo init -u https://github.com/OnePlusOSS/kernel_manifest.git -b oneplus/sm8650 -m oneplus_12_u.xml
repo sync -c -j$(nproc)

# Build
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki
```

## Build Commands

### Main Build Targets

| Command | Description |
|---------|-------------|
| `oplus_build_kernel.sh pineapple gki` | Full GKI 2.0 kernel build (production) |
| `oplus_build_kernel.sh pineapple consolidate` | Development build (userdebug) |
| `oplus_build_ko.sh pineapple gki` | Build kernel modules only |
| `oplus_build_boot.sh pineapple gki` | Build boot image |
| `oplus_build_dtbo.sh pineapple gki` | Build device tree overlays |

### Build Script Parameters

```bash
./kernel_platform/oplus/build/oplus_build_kernel.sh <platform> <variant> [<lto>] [<target>] [<recompile>]

# Examples:
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple consolidate thin all true
```

**Parameters:**
- `platform`: `pineapple` (sm8650)
- `variant`: `gki` or `consolidate`
- `lto`: `thin` or `full` (Link-Time Optimization)
- `target`: `all` or specific target
- `recompile`: `true` or `false` (force recompile)

## Output Locations

```
kernel_platform/out/msm-kernel-pineapple-gki/dist/
├── Image                   # Kernel binary
├── Image.gz                # Compressed kernel
├── *.ko                    # Kernel modules (~200+ files)
├── dtb/*.dtb              # Device tree binaries
├── dtbo.img               # Device tree overlay image
├── boot.img               # Boot image
├── vendor_boot.img        # Vendor boot image
└── vendor_dlkm.img       # Vendor DLKM image
```

## Device Tree Overlays

### OnePlus 12 Variants

| Variant | Project Code | Storage | Region | DTBO File |
|---------|--------------|---------|--------|-----------|
| **OnePlus 12 Global** ⭐ | **waffle-22825** | **512GB** | **Global** | **waffle-22825-pineapple-overlay.dtbo** |
| OnePlus 12 (CN) | waffle-22877 | 512GB | China | waffle-22877-pineapple-overlay.dtbo |
| OnePlus 12 (Pangu) | pangu-22111 | Varies | China | pangu-22111-pineapple-overlay.dtbo |
| OnePlus 12 (Enzo) | enzo-23607 | Varies | Regional | enzo-23607-pineapple-overlay.dtbo |

## Common Commands

### Repo Commands

```bash
# Check sync status
repo status

# List all projects
repo list

# Sync specific project
repo sync <project-name>

# Update all to latest
repo sync -c --force-sync

# Start new branch
repo start <branch-name> --all
```

### Build System

```bash
# Clean build outputs
rm -rf kernel_platform/out/

# Bazel clean
cd kernel_platform && tools/bazel clean

# Full Bazel reset
cd kernel_platform && tools/bazel clean --expunge

# Check Bazel version
cd kernel_platform && tools/bazel version
```

### Verification

```bash
# Check kernel version
strings kernel_platform/out/msm-kernel-pineapple-gki/dist/Image | grep "Linux version"

# Count modules
ls kernel_platform/out/msm-kernel-pineapple-gki/dist/*.ko | wc -l

# Check boot image
file kernel_platform/out/msm-kernel-pineapple-gki/dist/boot.img

# List DTB files
ls kernel_platform/out/msm-kernel-pineapple-gki/dist/dtb/
```

## Environment Variables

```bash
export CHIPSET_COMPANY=QCOM
export OPLUS_VND_BUILD_PLATFORM=SM8650
export TARGET_BOARD_PLATFORM=pineapple
export ANDROID_BUILD_TOP=~/oneplus12_kernel
```

## Troubleshooting Quick Fixes

### Issue: repo not found
```bash
export PATH="${HOME}/.bin:${PATH}"
echo 'export PATH="${HOME}/.bin:${PATH}"' >> ~/.bashrc
```

### Issue: Permission denied
```bash
chmod +x kernel_platform/oplus/build/*.sh
```

### Issue: Build fails - out of memory
```bash
# Reduce parallel jobs
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki thin 4 true
```

### Issue: Sync fails
```bash
repo sync -c --force-sync -j4
```

### Issue: Build artifacts missing
```bash
repo sync -c kernel_platform/prebuilts
```

## Flash Commands

**WARNING**: Requires unlocked bootloader. Will erase data.

```bash
cd kernel_platform/out/msm-kernel-pineapple-gki/dist/

# Reboot to bootloader
adb reboot bootloader

# Flash images
fastboot flash boot boot.img
fastboot flash vendor_boot vendor_boot.img
fastboot flash dtbo dtbo.img

# Reboot
fastboot reboot
```

## File Locations

### Source Code
- **Common Kernel**: `kernel_platform/common/`
- **MSM Kernel**: `kernel_platform/msm-kernel/`
- **OnePlus Code**: `kernel_platform/oplus/`, `vendor/oplus/`
- **Qualcomm Code**: `kernel_platform/qcom/`, `vendor/qcom/`
- **Device Trees**: `kernel_platform/qcom/proprietary/devicetree/`

### Build System
- **Kleaf/Bazel**: `kernel_platform/build/kernel/kleaf/`
- **Build Scripts**: `kernel_platform/oplus/build/`
- **Bazel Binary**: `kernel_platform/prebuilts/bazel/linux-x86_64/`
- **Toolchain**: `kernel_platform/prebuilts/clang/host/linux-x86/`

### Configuration
- **Kernel Config**: `kernel_platform/msm-kernel/arch/arm64/configs/`
- **Device Tree Sources**: `kernel_platform/qcom/proprietary/devicetree/`
- **OnePlus DTS**: `kernel_platform/qcom/proprietary/devicetree/oplus/`

## Repository URLs

- **Manifest**: https://github.com/OnePlusOSS/kernel_manifest.git
- **Common Kernel**: https://github.com/OnePlusOSS/android_kernel_common_oneplus_sm8650
- **MSM Kernel**: https://github.com/OnePlusOSS/android_kernel_oneplus_sm8650
- **Modules & DT**: https://github.com/OnePlusOSS/android_kernel_modules_and_devicetree_oneplus_sm8650
- **Qualcomm**: https://git.codelinaro.org

## Build Time Estimates

| Build Type | First Build | Incremental |
|------------|-------------|-------------|
| Full GKI | 30-60 min | 5-15 min |
| Modules only | 15-30 min | 3-8 min |
| Boot image | 5-10 min | 2-5 min |
| DTBO only | 2-5 min | 1-2 min |

*Times vary based on CPU, RAM, and storage speed*

## System Requirements

- **OS**: Linux (Ubuntu 20.04+ recommended)
- **CPU**: 4+ cores (8+ recommended)
- **RAM**: 16GB minimum (32GB recommended)
- **Storage**: 100GB free space minimum
- **Internet**: Required for initial sync

## Resources

- **Main README**: [README.md](README.md)
- **Detailed Guide**: [BUILD_GUIDE.md](BUILD_GUIDE.md)
- **Device-Specific Guide**: [DEVICE_WAFFLE_512GB.md](DEVICE_WAFFLE_512GB.md) ⭐
- **Setup Script**: [setup_build_env.sh](setup_build_env.sh)
- **Kleaf Docs**: `kernel_platform/build/kernel/kleaf/README.md`

## Support

For issues, see:
1. [BUILD_GUIDE.md](BUILD_GUIDE.md) - Detailed troubleshooting
2. OnePlus OSS: https://github.com/OnePlusOSS
3. GKI Documentation: https://source.android.com/docs/core/architecture/kernel/generic-kernel-image
