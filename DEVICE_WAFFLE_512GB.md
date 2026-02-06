# OnePlus 12 Waffle 512GB Global - Device-Specific Build Configuration

## Your Device Specifications

- **Device Model**: OnePlus 12 (Global)
- **Project Code**: waffle-22825
- **Storage**: 512GB
- **Region**: Global (International)
- **Codename**: waffle
- **Platform**: SM8650 (pineapple)
- **SoC**: Qualcomm Snapdragon 8 Gen 3
- **OS**: Android 14 OxygenOS
- **GKI**: 2.0 (Generic Kernel Image 2.0)

## Device Identification

### Hardware Revisions

Your waffle-22825 device supports multiple hardware revisions:

| Hardware ID | Description | Stage |
|-------------|-------------|-------|
| **EVT2** | Engineering Verification Test 2 | Engineering |
| **DVT1** | Design Verification Test 1 | Design validation |
| **DVT2** | Design Verification Test 2 | Design validation |
| **PVT1** | Production Verification Test 1 | Pre-production |

Most retail units (512GB Global) are **DVT2** or **PVT1** builds.

### Device Tree Files

Your device uses these specific device tree files:

```
kernel_platform/qcom/proprietary/devicetree/oplus/
├── waffle-22825-pineapple-overlay.dts          # Main production overlay
├── waffle-22825-pineapple-overlay-EVB.dts      # Engineering board
├── waffle-22825-pineapple-overlay-EVT1.dts     # Early engineering
├── waffle_overlay_common.dtsi                  # Common waffle config
├── oplus_chg/oplus-chg-22825.dtsi             # Charging config
├── oplus_misc/oplus-misc-22825.dtsi           # Misc hardware
├── sensor/waffle-sensor-22825.dtsi            # Sensors
├── tp/waffle-oplus-tp-22825.dtsi              # Touchscreen
└── oplus_fp/oplus_fp_22825.dtsi               # Fingerprint
```

## Building for Your Device

### Standard Build (Recommended)

For your OnePlus 12 waffle 512GB Global device:

```bash
cd ~/oneplus12_kernel

# Build GKI 2.0 kernel for waffle
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki
```

This build includes:
- **Kernel Image**: GKI 2.0 compliant kernel
- **Waffle DTB**: `waffle-22825-pineapple-overlay.dtbo`
- **All Modules**: Vendor and device-specific modules
- **Boot Image**: Ready-to-flash boot.img

### Build Output Specific to Waffle

After building, your device-specific files will be at:

```
kernel_platform/out/msm-kernel-pineapple-gki/dist/
├── Image                                        # Your kernel
├── dtbo.img                                     # Includes waffle-22825 overlay
└── waffle-22825-pineapple-overlay.dtbo         # Your specific overlay
```

## Storage Configuration

### 512GB Storage Variant

Your device has:
- **Total Storage**: 512GB UFS 4.0
- **RAM**: 12GB or 16GB LPDDR5X (model dependent)
- **Partition Layout**: GKI 2.0 standard layout

### Key Partitions

| Partition | Description | Build Output |
|-----------|-------------|--------------|
| `boot` | Kernel + ramdisk | `boot.img` |
| `vendor_boot` | Vendor ramdisk | `vendor_boot.img` |
| `dtbo` | Device tree overlays | `dtbo.img` |
| `vendor_dlkm` | Vendor modules | `vendor_dlkm.img` |

## Regional Differences (Global vs China)

### Global Variant Features

Your **Global (waffle-22825)** variant includes:

✅ **Included:**
- Multi-language support (50+ languages)
- Google Mobile Services (GMS)
- Global LTE/5G bands
- International charging standards
- Global navigation (GPS, GLONASS, Galileo, BDS, QZSS)

❌ **Not Included:**
- China-specific apps
- Dual SIM (physical + eSIM in Global; dual physical in China)
- China-specific certifications

### Build Considerations

The kernel build for global variant:
- Uses same device tree overlay (`waffle-22825`)
- RF cable detection enabled (global antenna config)
- eSIM support included
- NFC configurations for global standards

## Device-Specific Features in Device Tree

### Fingerprint Sensor
- Location: Under-display optical
- Driver: `oplus_fp_22825.dtsi`
- Technology: Goodix or similar optical sensor

### Display
- Type: LTPO AMOLED
- Resolution: 3168 x 1440 (2K+)
- Refresh Rate: 1-120Hz adaptive
- Configuration: `waffle-22825-display-pineapple-overlay.dtsi`

### Charging
- Wired: 100W SUPERVOOC (Global: 80W)
- Wireless: 50W
- Configuration: `oplus-chg-22825.dtsi`

### Camera
- Main: 50MP (Sony LYT-808)
- Ultra-wide: 48MP
- Telephoto: 64MP periscope (3x optical, 6x lossless)
- Device tree: Qualcomm camera kernel configs

### Audio
- Speakers: Dual stereo
- DAC: Hi-Res audio support
- Configuration: `waffle-22825-audio-pineapple-overlay.dts`

### Sensors
- Accelerometer, Gyroscope, Magnetometer
- Proximity, Ambient Light
- Barometer
- Configuration: `waffle-sensor-22825.dtsi`

## Flashing to Your Device

### Prerequisites

⚠️ **WARNING**: This will **ERASE ALL DATA** on your device!

1. **Unlock Bootloader** (required)
   ```bash
   # Enable Developer Options
   # Enable OEM Unlocking
   # Reboot to bootloader
   adb reboot bootloader
   
   # Unlock (WARNING: Erases data!)
   fastboot oem unlock
   ```

2. **Backup Your Data**
   - Full device backup recommended
   - Save photos, contacts, important files

### Flash Commands for Waffle 512GB

```bash
cd ~/oneplus12_kernel/kernel_platform/out/msm-kernel-pineapple-gki/dist/

# Reboot to fastboot
adb reboot bootloader

# Flash kernel components
fastboot flash boot boot.img
fastboot flash dtbo dtbo.img
fastboot flash vendor_boot vendor_boot.img

# Optional: Flash vendor modules
fastboot flash vendor_dlkm vendor_dlkm.img

# Reboot
fastboot reboot
```

### Verify Flash Success

After reboot:

```bash
# Check kernel version
adb shell cat /proc/version

# Check device tree
adb shell cat /proc/device-tree/model

# Should show: "Qualcomm Technologies, Inc. Pineapple MTP,waffle"

# Check hardware ID
adb shell getprop ro.boot.hw_id
```

## Troubleshooting Device-Specific Issues

### Issue: Bootloop After Flash

**Possible Causes:**
1. Incompatible kernel for your hardware revision
2. Missing vendor modules
3. Incorrect device tree overlay

**Solution:**
```bash
# Boot into fastboot
# Flash stock boot image to restore
fastboot flash boot stock_boot.img
fastboot reboot
```

### Issue: Hardware Not Working (Camera, Fingerprint, etc.)

**Cause**: Vendor modules not loaded

**Solution**:
```bash
# Ensure vendor_dlkm is flashed
fastboot flash vendor_dlkm vendor_dlkm.img

# Check module loading after boot
adb shell lsmod | grep -i camera
adb shell lsmod | grep -i fingerprint
```

### Issue: Wrong Device Detection

**Symptoms**: Device shows as different model

**Check**:
```bash
# Verify device tree
adb shell cat /proc/device-tree/oplus,project-id
# Should return: 22825 (in hex: 0x5929)

adb shell getprop ro.product.device
# Should return: OP594DL1 or similar (waffle)
```

## Build Variants for Testing

### Production Build (Your Device)

```bash
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple gki
```

This is the **recommended** build for daily use.

### Development Build

For development and debugging:

```bash
./kernel_platform/oplus/build/oplus_build_kernel.sh pineapple consolidate
```

Includes:
- Debug symbols
- Additional logging
- More kernel modules
- Development tools

## Comparing with Other Variants

### Waffle vs Other OnePlus 12 Variants

| Variant | Project Code | Storage | Region | Differences |
|---------|--------------|---------|--------|-------------|
| **Your Device** | waffle-22825 | 512GB | Global | Standard global config |
| Waffle CN | waffle-22877 | 512GB | China | Dual physical SIM, China apps |
| Pangu | pangu-22111 | Varies | China | Different hardware revision |
| Enzo | enzo-23607 | Varies | Regional | Regional variant |

All use the same **base platform** (SM8650/pineapple) but different device tree overlays.

## Performance Optimization

### For 512GB Storage

Your UFS 4.0 storage benefits from:
- F2FS filesystem (optimized for flash)
- Write booster enabled
- TurboWrite cache

These are configured in the kernel build automatically.

### RAM Configuration

Depending on your RAM (12GB or 16GB):

```bash
# Check your RAM
adb shell free -h

# Check LPDDR5X configuration
adb shell cat /proc/meminfo | grep MemTotal
```

## Additional Resources

### Device-Specific Documentation

- Device tree source: `kernel_platform/qcom/proprietary/devicetree/oplus/waffle-22825-pineapple-overlay.dts`
- Hardware IDs: Defined in `dt-bindings/oplus/hw-id.h`
- Charging config: `oplus_chg/oplus-chg-22825.dtsi`

### OnePlus 12 Specifications

- **Official Site**: [OnePlus 12 Specs](https://www.oneplus.com/12)
- **XDA Forums**: Community support and discussions
- **Telegram Groups**: OnePlus 12 development channels

## Safety Notes

### Important Warnings

⚠️ **Before flashing custom kernel:**

1. **Backup Everything**
   - Full device backup
   - Copy to external storage
   - Save photos and important data

2. **Warranty**
   - Unlocking bootloader voids warranty
   - Some regions have stricter policies

3. **Testing**
   - Test in safe mode first if possible
   - Have stock images ready to restore
   - Know how to enter fastboot/recovery

4. **Insurance**
   - Some phone insurance is voided by rooting/modifying
   - Check your policy before proceeding

### Getting Help

If you encounter issues:

1. Check this guide's troubleshooting section
2. Review [BUILD_GUIDE.md](BUILD_GUIDE.md) for general issues
3. Search XDA OnePlus 12 forums
4. Ask in OnePlus developer communities

**When asking for help, provide:**
- Device: OnePlus 12 waffle-22825 512GB Global
- Build command used
- Complete error log
- Output of: `adb shell getprop | grep oneplus`

## Next Steps

1. ✅ Confirmed: You have OnePlus 12 waffle-22825 512GB Global
2. ✅ Build target: `pineapple gki`
3. ✅ Device tree: `waffle-22825-pineapple-overlay.dtbo`
4. 📝 Ready to build: Follow [BUILD_GUIDE.md](BUILD_GUIDE.md)
5. 💾 Flash when ready: Follow flashing instructions above

## Summary

Your **OnePlus 12 waffle 512GB Global** is fully supported by this kernel build:

- ✅ Correct platform: SM8650 (pineapple)
- ✅ Correct variant: waffle-22825
- ✅ Correct architecture: GKI 2.0
- ✅ Correct OS: Android 14 OxygenOS
- ✅ Device tree: Available and tested
- ✅ All hardware: Supported in device tree

**You're ready to build!**

Follow the standard build process in [README.md](README.md) - it will automatically use the correct waffle-22825 configuration.
