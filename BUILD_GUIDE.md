# OnePlus 12 Kernel Build Guide - Detailed Instructions

This document provides detailed step-by-step instructions for building the OnePlus 12 Android 14 OOS kernel with GKI 2.0 architecture.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Understanding the Build](#understanding-the-build)
3. [Detailed Build Steps](#detailed-build-steps)
4. [Build Outputs](#build-outputs)
5. [Advanced Configuration](#advanced-configuration)
6. [Troubleshooting](#troubleshooting)

## Quick Start

For experienced developers:

```bash
# 1. Install repo tool and dependencies
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+x ~/.bin/repo

# 2. Initialize and sync
mkdir ~/oneplus12_kernel && cd ~/oneplus12_kernel
repo init -u https://github.com/OnePlusOSS/kernel_manifest.git -b oneplus/sm8650 -m oneplus_12_u.xml
repo sync -c -j$(nproc)

# 3. Build
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki
```

## Understanding the Build

### OnePlus 12 Specifications

| Component | Details |
|-----------|---------|
| **Device Name** | OnePlus 12 |
| **Project Codes** | waffle-22825, waffle-22877, pangu-22111, enzo-23607 |
| **Platform** | SM8650 (pineapple) |
| **SoC** | Snapdragon 8 Gen 3 |
| **Android Version** | 14 |
| **OOS Version** | OxygenOS 14 |
| **Kernel Architecture** | GKI 2.0 (Generic Kernel Image 2.0) |
| **Build Type** | User (`u` variant) |

### GKI 2.0 Architecture

The OnePlus 12 uses **GKI 2.0** (Generic Kernel Image 2.0), which is Google's standardized kernel architecture for Android 14+:

**Key Features:**
- **Core Kernel**: Common Android kernel maintained by Google
- **Vendor Modules**: Device-specific modules loaded dynamically
- **KMI Stability**: Stable Kernel Module Interface across updates
- **Modular Design**: Separate kernel and vendor code
- **ABI Compatibility**: Binary compatibility for modules

**Build Components:**
1. **Core Kernel** (`kernel_platform/common/`) - ACK (Android Common Kernel)
2. **MSM Kernel** (`kernel_platform/msm-kernel/`) - Qualcomm specific code
3. **Vendor Modules** (`vendor/qcom/`, `vendor/oplus/`) - Hardware drivers
4. **Device Tree** - Hardware configuration overlays

### Repo Manifest Structure

The `oneplus_12_u.xml` manifest defines the complete source tree:

**Key Repositories:**
- `android_kernel_common_oneplus_sm8650` - ACK kernel base
- `android_kernel_oneplus_sm8650` - MSM-specific kernel
- `android_kernel_modules_and_devicetree_oneplus_sm8650` - This repo (modules & DT)
- Prebuilts - Toolchains, build tools, Bazel

## Detailed Build Steps

### Step 1: System Preparation

#### Install Dependencies (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    libncurses-dev \
    bison \
    flex \
    libssl-dev \
    libelf-dev \
    bc \
    cpio \
    python3 \
    python3-pip \
    git \
    curl \
    openjdk-11-jdk \
    rsync \
    libxml2-utils \
    zip \
    unzip
```

#### Install Repo Tool

```bash
# Create bin directory
mkdir -p ~/.bin
export PATH="${HOME}/.bin:${PATH}"

# Download repo
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo

# Make permanent (add to ~/.bashrc)
echo 'export PATH="${HOME}/.bin:${PATH}"' >> ~/.bashrc
```

#### Verify Java Version

GKI 2.0 build requires Java 11 or later:

```bash
java -version

# If needed, set Java 11 as default
sudo update-alternatives --config java
```

### Step 2: Initialize Workspace

#### Create Working Directory

```bash
# Create and enter workspace
mkdir -p ~/oneplus12_kernel
cd ~/oneplus12_kernel
```

#### Configure Git (First Time Only)

```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

#### Initialize Repo

```bash
# Initialize with OnePlus 12 Android 14 manifest
repo init \
    -u https://github.com/OnePlusOSS/kernel_manifest.git \
    -b oneplus/sm8650 \
    -m oneplus_12_u.xml

# Verify initialization
ls -la .repo/
```

**What This Does:**
- Downloads the manifest from OnePlusOSS
- Configures the repository structure
- Prepares for source code sync

### Step 3: Sync Source Code

#### Full Sync (Recommended)

```bash
# Sync all repositories with optimal settings
repo sync -c -j$(nproc --all) --no-clone-bundle --no-tags

# Options explained:
# -c              : Only sync current branch (saves space)
# -j$(nproc)      : Use all CPU cores for parallel download
# --no-clone-bundle : Direct git clone (more reliable)
# --no-tags       : Don't fetch git tags (saves bandwidth)
```

**Expected Duration:**
- Download size: ~2-3 GB
- Time: 15-30 minutes (depends on connection speed)

#### Resume Interrupted Sync

If sync is interrupted:

```bash
repo sync -c --force-sync
```

#### Verify Sync

```bash
# Check repository status
repo status

# List all projects
repo list
```

### Step 4: Build the Kernel

#### Standard GKI 2.0 Build (Production)

```bash
cd ~/oneplus12_kernel

# Build stock GKI kernel
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki
```

**Build Process:**
1. Environment setup and validation
2. Vendor module preparation
3. Kernel configuration generation
4. Bazel/Kleaf compilation
5. Module signing and packaging
6. Image creation (boot.img, dtbo.img)
7. Distribution artifact collection

**Expected Duration:**
- First build: 30-60 minutes
- Incremental builds: 5-15 minutes

#### Development Build (Userdebug)

For development with additional debugging:

```bash
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple consolidate
```

**Differences from GKI:**
- More kernel modules included
- Debug symbols enabled
- Additional logging
- Userdebug configurations

### Step 5: Monitor Build Progress

#### Enable Verbose Logging

```bash
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki 2>&1 | tee build.log
```

#### Watch Build in Real-Time

In another terminal:

```bash
cd ~/oneplus12_kernel
tail -f build.log
```

#### Check Build Status

```bash
# Check if build process is running
ps aux | grep bazel

# Check CPU usage
top
```

## Build Outputs

### Output Location

All build artifacts are placed in:

```
kernel_platform/out/msm-kernel-pineapple-gki/dist/
```

### Key Output Files

#### Kernel Image

```
Image                       # Raw kernel image (ARM64)
Image.gz                    # Compressed kernel image
vmlinux                     # Kernel with debug symbols
System.map                  # Kernel symbol table
```

#### Kernel Modules (*.ko)

GKI 2.0 uses loadable modules:

```
*.ko                        # Kernel modules
modules.load                # Module load order
modules.dep                 # Module dependencies
modules.alias               # Module aliases
```

**Module Categories:**
- **Core Modules**: Essential kernel modules (filesystem, network)
- **Vendor Modules**: Qualcomm and OnePlus specific (camera, audio, display)
- **DLKM**: Dynamically Loadable Kernel Modules

#### Device Tree

```
dtb/*.dtb                   # Device tree binaries
dtbo.img                    # Device tree overlay image
```

**DTB Files for OnePlus 12:**
- `pineapple.dtb` - Base platform DTB
- `pineapple-v2.dtb` - Hardware revision 2

**DTBO Files:**
- `waffle-22825-pineapple-overlay.dtbo` - OnePlus 12 main variant
- `waffle-22877-pineapple-overlay.dtbo` - OnePlus 12 variant
- `pangu-22111-pineapple-overlay.dtbo` - Pangu variant
- `enzo-23607-pineapple-overlay.dtbo` - Enzo variant

#### Boot Images

```
boot.img                    # Boot image (kernel + ramdisk)
vendor_boot.img             # Vendor boot image (vendor ramdisk)
vendor_dlkm.img            # Vendor DLKM partition image
```

### Build Artifacts Structure

```
dist/
├── Image                           # Kernel binary
├── Image.gz
├── vmlinux
├── System.map
├── *.ko                           # ~200+ kernel modules
├── modules.load
├── modules.dep
├── modules.alias
├── dtb/
│   ├── pineapple.dtb
│   ├── pineapple-v2.dtb
│   └── ...
├── dtbo.img
├── boot.img
├── vendor_boot.img
└── vendor_dlkm.img
```

## Advanced Configuration

### Build Specific Components

#### Kernel Only (No Modules)

```bash
cd ~/oneplus12_kernel/kernel_platform
tools/bazel build //msm-kernel:pineapple_gki_kernel
```

#### Modules Only

```bash
./kernel_platform/oplus/build/oplus_build_ko.sh pineapple gki
```

#### Boot Image Only

```bash
./kernel_platform/oplus/build/oplus_build_boot.sh pineapple gki
```

#### DTBO Image Only

```bash
./kernel_platform/oplus/build/oplus_build_dtbo.sh pineapple gki
```

### Customize Build Configuration

#### Modify Kernel Config

```bash
cd ~/oneplus12_kernel/kernel_platform/msm-kernel

# Edit defconfig
vi arch/arm64/configs/pineapple_GKI.config

# Rebuild
cd ~/oneplus12_kernel
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki
```

#### Bazel Build Options

```bash
cd ~/oneplus12_kernel/kernel_platform

# Clean build
tools/bazel clean

# Build with specific options
tools/bazel build --config=fast //msm-kernel:pineapple_gki_dist

# Available configs:
# --config=fast      : Faster local builds
# --config=release   : Release build
# --config=stamp     : Include version stamping
```

### Environment Variables

Key variables affecting the build:

```bash
export CHIPSET_COMPANY=QCOM
export OPLUS_VND_BUILD_PLATFORM=SM8650
export TARGET_BOARD_PLATFORM=pineapple
export ANDROID_BUILD_TOP=~/oneplus12_kernel

# Build with custom variables
CHIPSET_COMPANY=QCOM ./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki
```

### Parallel Build Control

```bash
# Use specific number of jobs
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki thin all true

# Control Bazel parallelism
cd kernel_platform
tools/bazel build --jobs=16 //msm-kernel:pineapple_gki_dist
```

## Troubleshooting

### Build Failures

#### "Command not found: repo"

```bash
export PATH="${HOME}/.bin:${PATH}"
echo 'export PATH="${HOME}/.bin:${PATH}"' >> ~/.bashrc
```

#### "Permission denied" on scripts

```bash
chmod +x kernel_platform/oplus/build/*.sh
```

#### "Java version incompatible"

```bash
# Install Java 11
sudo apt-get install openjdk-11-jdk

# Set as default
sudo update-alternatives --config java
```

#### Out of Memory During Build

```bash
# Reduce parallel jobs
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki thin 4 true

# Or limit Bazel memory
cd kernel_platform
tools/bazel build --local_ram_resources=8192 //msm-kernel:pineapple_gki_dist
```

#### Missing Prebuilt Tools

```bash
# Re-sync prebuilts
cd ~/oneplus12_kernel
repo sync -c kernel_platform/prebuilts
```

### Sync Issues

#### Slow Download

```bash
# Reduce parallel jobs
repo sync -c -j4

# Use specific mirror (if available)
repo init -u https://github.com/OnePlusOSS/kernel_manifest.git \
    -b oneplus/sm8650 -m oneplus_12_u.xml \
    --repo-url=https://mirrors.tuna.tsinghua.edu.cn/git/git-repo
```

#### Sync Corruption

```bash
cd ~/oneplus12_kernel
repo forall -c 'git reset --hard'
repo sync -c --force-sync
```

### Clean Builds

#### Clean All Build Outputs

```bash
rm -rf ~/oneplus12_kernel/kernel_platform/out/
```

#### Clean Bazel Cache

```bash
cd ~/oneplus12_kernel/kernel_platform
tools/bazel clean --expunge
```

#### Complete Reset (Keep Source)

```bash
cd ~/oneplus12_kernel
repo forall -c 'git clean -fdx'
repo sync -c
```

## Verification

### Verify Build Success

```bash
# Check for kernel image
ls -lh ~/oneplus12_kernel/kernel_platform/out/msm-kernel-pineapple-gki/dist/Image

# Check module count
ls ~/oneplus12_kernel/kernel_platform/out/msm-kernel-pineapple-gki/dist/*.ko | wc -l

# Check boot image
file ~/oneplus12_kernel/kernel_platform/out/msm-kernel-pineapple-gki/dist/boot.img
```

### Extract Kernel Version

```bash
cd ~/oneplus12_kernel/kernel_platform/out/msm-kernel-pineapple-gki/dist/
strings Image | grep "Linux version"
```

## Next Steps

After successful build:

1. **Flash to Device** (requires unlocked bootloader):
   ```bash
   fastboot flash boot boot.img
   fastboot flash vendor_boot vendor_boot.img
   fastboot flash dtbo dtbo.img
   ```

2. **Create Flashable ZIP** (for custom recovery)

3. **Test on Device** and verify functionality

4. **Contribute Back** to open source if making improvements

## References

- **OnePlus OSS**: https://github.com/OnePlusOSS
- **Kernel Manifest**: https://github.com/OnePlusOSS/kernel_manifest
- **Kleaf Docs**: `kernel_platform/build/kernel/kleaf/README.md`
- **GKI Documentation**: https://source.android.com/devices/architecture/kernel/generic-kernel-image
- **Qualcomm CodeLinaro**: https://git.codelinaro.org

## Support

For issues:
1. Check this guide's troubleshooting section
2. Review OnePlus OSS documentation
3. Search existing issues on GitHub
4. Open new issue with build logs

**Important**: Always include:
- OS version (Ubuntu 22.04, etc.)
- Build command used
- Complete error log
- Output of `repo list`
