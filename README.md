# OnePlus 12 Android 14 OOS Stock Kernel Build

This repository contains the kernel modules and device tree for the OnePlus 12 (sm8650 platform) running Android 14 OxygenOS.

## Device Information

- **Device**: OnePlus 12
- **Primary Variant**: **waffle-22825** (512GB Global) ⭐
- **Other Variants**: waffle-22877 (CN), pangu-22111, enzo-23607
- **Platform**: Qualcomm SM8650 (pineapple)
- **SoC**: Snapdragon 8 Gen 3
- **OS Version**: Android 14 OOS (OxygenOS)
- **Build Type**: User build (`u` variant)
- **Kernel Architecture**: GKI 2.0 (Generic Kernel Image 2.0)

> **📱 Have the waffle 512GB Global variant?** See [DEVICE_WAFFLE_512GB.md](DEVICE_WAFFLE_512GB.md) for device-specific instructions.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Git** (version 2.0+)
2. **Repo tool** - Install using:
   ```bash
   mkdir -p ~/.bin
   PATH="${HOME}/.bin:${PATH}"
   curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
   chmod a+rx ~/.bin/repo
   ```

3. **Build dependencies** (Ubuntu/Debian):
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
       openjdk-11-jdk
   ```

## Setting Up the Build Environment

### Step 1: Initialize Repository

Create a working directory and initialize the repo:

```bash
# Create workspace directory
mkdir -p ~/oneplus12_kernel
cd ~/oneplus12_kernel

# Initialize repo with OnePlus 12 Android 14 manifest
repo init -u https://github.com/OnePlusOSS/kernel_manifest.git -b oneplus/sm8650 -m oneplus_12_u.xml

# Sync all repositories
repo sync -c -j$(nproc --all) --no-clone-bundle --no-tags
```

**Note**: The sync process will download approximately 2-3 GB of source code and may take 15-30 minutes depending on your internet connection.

### Step 2: Verify Repository Structure

After syncing, your directory structure should look like this:

```
oneplus12_kernel/
├── kernel_platform/
│   ├── common/              # Common kernel source
│   ├── msm-kernel/          # MSM-specific kernel
│   ├── build/               # Build system
│   ├── oplus/               # OnePlus-specific code
│   ├── qcom/                # Qualcomm proprietary code
│   ├── prebuilts/           # Prebuilt toolchains
│   ├── external/            # External dependencies
│   └── tools/               # Build tools
└── vendor/
    ├── oplus/               # OnePlus vendor modules
    └── qcom/                # Qualcomm vendor modules
```

## Building the Kernel

### Building with Bazel (Recommended)

The kernel uses **Kleaf** (Kernel + Bazel) as the primary build system with **GKI 2.0** architecture:

```bash
cd ~/oneplus12_kernel

# Build kernel for pineapple (sm8650) - GKI 2.0 variant
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki
```

**Build Variants:**
- `gki` - Generic Kernel Image 2.0 (user/production build, stock OOS)
- `consolidate` - Consolidated build (userdebug with additional modules for development)

### What is GKI 2.0?

**GKI 2.0** (Generic Kernel Image 2.0) is Google's kernel architecture for Android 14 that:
- Separates the core kernel from vendor modules
- Enables kernel updates independent of vendor code
- Provides a stable Kernel Module Interface (KMI)
- Ensures ABI compatibility across Android releases
- Uses modular kernel design with loadable modules

### Build Script Options

The OnePlus build scripts support various operations:

1. **Full kernel build**:
   ```bash
   ./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki
   ```

2. **Kernel modules only**:
   ```bash
   ./kernel_platform/oplus/build/oplus_build_ko.sh pineapple gki
   ```

3. **Boot image**:
   ```bash
   ./kernel_platform/oplus/build/oplus_build_boot.sh pineapple gki
   ```

4. **DTBO image**:
   ```bash
   ./kernel_platform/oplus/build/oplus_build_dtbo.sh pineapple gki
   ```

### Build Output Location

After a successful build, output files will be located at:

```
kernel_platform/out/msm-kernel-pineapple-gki/dist/
├── Image                    # Kernel image
├── *.ko                     # Kernel modules
├── dtb/                     # Device tree binaries
├── dtbo.img                 # Device tree overlay image
└── boot.img                 # Boot image (if built)
```

## Advanced Build Configuration

### Platform and Variant Options

The build system supports multiple platforms and variants:

**Platform**: `pineapple` (sm8650)

**Variants**:
- `gki` - Generic Kernel Image (stock user build)
- `consolidate` - Consolidated build (development)

### Environment Variables

Key environment variables used during build (automatically set by build scripts):

```bash
CHIPSET_COMPANY=QCOM
OPLUS_VND_BUILD_PLATFORM=SM8650
TARGET_BOARD_PLATFORM=pineapple
```

### Custom Build Parameters

For advanced users, you can customize the build:

```bash
# Enable verbose output
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki 2>&1 | tee build.log

# Use specific number of parallel jobs
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki thin all true
```

## Device Tree Overlays

OnePlus 12 device variants and their corresponding overlays:

| Variant | Project Code | Storage | Region | Device Tree Overlay |
|---------|--------------|---------|--------|---------------------|
| **OnePlus 12 Global** ⭐ | **waffle-22825** | **512GB** | **Global/International** | **waffle-22825-pineapple-overlay.dtbo** |
| OnePlus 12 (CN) | waffle-22877 | 512GB | China | waffle-22877-pineapple-overlay.dtbo |
| OnePlus 12 (Pangu) | pangu-22111 | Varies | China | pangu-22111-pineapple-overlay.dtbo |
| OnePlus 12 (Enzo) | enzo-23607 | Varies | Regional | enzo-23607-pineapple-overlay.dtbo |

Each variant includes board revisions: EVB, EVT1, EVT2, DVT1, DVT2, PVT1

> **Note**: The waffle-22825 512GB Global variant is the most common international model and is fully supported by this build.

## Troubleshooting

### Common Issues

1. **"repo: command not found"**
   - Ensure repo is in your PATH: `export PATH="${HOME}/.bin:${PATH}"`
   - Add to `~/.bashrc` for persistence

2. **Sync failures**
   - Check internet connectivity
   - Try syncing with fewer jobs: `repo sync -j4`
   - Resume incomplete sync: `repo sync -c --force-sync`

3. **Build failures due to missing dependencies**
   - Install all prerequisites listed above
   - Ensure Java 11 is the default: `sudo update-alternatives --config java`

4. **Out of disk space**
   - Minimum 100GB free space recommended
   - Clean old builds: `rm -rf kernel_platform/out/`

5. **Permission errors**
   - Ensure build scripts are executable: `chmod +x kernel_platform/oplus/build/*.sh`

### Getting Help

- **OnePlus OSS**: https://github.com/OnePlusOSS
- **Kernel Manifest**: https://github.com/OnePlusOSS/kernel_manifest
- **Qualcomm Chipcode**: https://git.codelinaro.org

## Repository Structure

This repository (`android_kernel_modules_and_devicetree_oneplus_sm8650`) contains:

- **kernel_platform/oplus/**: OnePlus-specific kernel modules, device trees, and build scripts
- **kernel_platform/qcom/**: Qualcomm proprietary device tree and modules
- **vendor/oplus/**: OnePlus vendor kernel modules
- **vendor/qcom/**: Qualcomm opensource modules (camera, audio, display, wlan, etc.)

## Source Code References

This build configuration references the following upstream repositories:

1. **Kernel Common**: `android_kernel_common_oneplus_sm8650` (oneplus/sm8650_u_14.0.0_oneplus12)
2. **MSM Kernel**: `android_kernel_oneplus_sm8650` (oneplus/sm8650_u_14.0.0_oneplus12)
3. **Modules & Device Tree**: `android_kernel_modules_and_devicetree_oneplus_sm8650` (oneplus/sm8650_u_14.0.0_oneplus12)
4. **Build Tools**: Qualcomm CodeLinaro prebuilts
5. **Toolchains**: Clang, GCC, Bazel from Qualcomm releases

## Build System Details

### Bazel/Kleaf

This kernel uses **Kleaf** (Kernel + Bazel), Google's modern build system for Android kernels:

- **Documentation**: `kernel_platform/build/kernel/kleaf/README.md`
- **Configuration**: Starlark-based build definitions (`.bzl` files)
- **Benefits**: Hermetic builds, better caching, parallel execution

### Build Process Flow

1. **Environment Setup** → `oplus_setup.sh` configures environment variables
2. **Vendor Preparation** → `prepare_vendor.sh` sets up vendor modules
3. **Kernel Build** → Bazel/Kleaf compiles kernel and modules
4. **Image Creation** → Boot, DTBO images are generated
5. **Distribution** → Output artifacts collected in `dist/` directory

## License

The kernel source code is licensed under GPL v2. See individual source files for specific license information.

- **Kernel**: GPL v2
- **Modules**: Various (GPL v2, Apache 2.0, BSD)
- **Build System**: Apache 2.0

## Contributing

This is a stock kernel release repository. For modifications or custom kernels:

1. Fork this repository
2. Create your feature branch
3. Follow kernel coding standards
4. Test thoroughly on target device
5. Submit pull requests with detailed descriptions

## Disclaimer

This is an open source release from OnePlus. Building and flashing custom kernels may:
- Void your warranty
- Cause device instability
- Result in data loss

**Always backup your data before flashing custom builds.**

## Additional Resources

- [Kleaf Documentation](kernel_platform/build/kernel/kleaf/README.md)
- **[Device-Specific: OnePlus 12 Waffle 512GB Global](DEVICE_WAFFLE_512GB.md)** ⭐
- [OnePlus Open Source](https://github.com/OnePlusOSS)
- [Qualcomm Linux Kernel](https://git.codelinaro.org)
- [Android Kernel Documentation](https://source.android.com/devices/architecture/kernel)
