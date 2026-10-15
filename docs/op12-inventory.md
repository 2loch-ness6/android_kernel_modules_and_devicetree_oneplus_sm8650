# OP12 kernel + tooling — consolidated inventory (by date)

Chronological ledger of every meaningful artifact across the two working dirs:

- **`/srv/op12-kernel/`** — kernel source tree + build outputs, patch exports, packaged modules/zips, docs, captures.
- **`~/OnePlus12_kernal/`** — on-device aarch64 tools (injector / LPC capture) + a mirror of the memory/doc notes.

Heavy source/build internals (`.repo`, `.git`, `kernel_platform/`, `out/`, `vendor/`, `vendor-ref/`) are omitted — only the artifacts that matter are listed. Sizes are bytes. Generated 2026-10-13.

---

## 2024-08-02 — stock baseline (OEM build date)
| size | path | what |
|---|---|---|
| tree | `/srv/op12-kernel/pkg/dlkm_work/staging/` | Extracted **stock** vendor_dlkm / system_dlkm module set (spi-msm-geni, oplus_*, qca_cld3, etc.). Reference baseline for repacking; mtimes are the OEM build, not our work. |

## 2026-09-15 — repo bring-up
| size | path | what |
|---|---|---|
| 62 | `repo-sync.log` | Initial `repo sync` of the OP12 kernel manifest. |

## 2026-09-16 — A14 Docker-kernel build iterations
| size | path | what |
|---|---|---|
| 585,853 | `build-C6.log` | Docker/CFI-LTO kernel build iteration C6. |
| 581,606 | `build-C7.log` | iteration C7. |
| 582,276 | `build-C8.log` | iteration C8. |

## 2026-09-26 — project docs / memory snapshot
| size | path | what |
|---|---|---|
| 1,670 | `docs/op12-device-facts.md` | device facts (CPH2581/waffle/pineapple). |
| 1,700 | `docs/op12-kernel-build-setup.md` | build-host + tree setup. |
| 6,457 | `docs/op12-docker-build-recipe.md` | the 7 source/config changes for a working Docker kernel. |
| 10,626 | `docs/op12-docker-cfi-lto-invariant.md` | CFI/LTO findings + failure modes. |
| 20,690 | `docs/op12-current-state.md` | running state log. |
| 948 | `docs/MEMORY.md` | memory index mirror. |

## 2026-10-07 — cfg80211 mgmt-injection patch + first on-device tools
| size | path | what |
|---|---|---|
| 583,647 | `build-cfg80211-patch2.log` | cfg80211 patch build (iter 2). |
| 571,662 | `build-cfg80211-patch3.log` | cfg80211 patch build (iter 3 — the CRC-safe one). |
| 597,051 | `build-research-cfg80211.log` | research/disassembly build. |
| 10,124 | `~/OnePlus12_kernal/nl80211_inject.c` | mgmt-TX injector source. |
| 11,080 | `~/OnePlus12_kernal/nl80211_inject` | injector, **aarch64 PIE (dynamic)**. App ships a *static* NDK build at `apk/assets/nl80211_inject.arm64`. |
| 5,287 | `~/OnePlus12_kernal/lpc_ctl.c` | LPC (local packet capture) control source. |
| 8,920 | `~/OnePlus12_kernal/lpc_ctl` | LPC control, aarch64 PIE. |

## 2026-10-12 — the big day: WiFi monitor + cfg80211 flash package + patch exports
### Patch exports (git-format)
| size | path | what |
|---|---|---|
| 19,753 | `patches-a14-c6/kernel_platform_common.patch` | A14 c6 branch — common tree. |
| 4,010 | `patches-a14-c6/kernel_platform_msm-kernel.patch` | A14 c6 — msm-kernel. |
| 2,380 | `patches-a14-c6/_.patch` | A14 c6 — top-level. |
| 18,796 | `patches-a15-bt-cfg80211/kernel_platform_common.patch` | A15 BT+cfg80211 branch — common tree. |
| 4,620 | `patches-a15-bt-cfg80211/kernel_platform_msm-kernel.patch` | A15 — msm-kernel. |
| 2,581 | `patches-a15-bt-cfg80211/_.patch` | A15 — top-level. |
| 375 | `repo-sync-a15-fetch.log` | A15 fetch log. |

### WiFi monitor (qca_cld3 con_mode=4 / LPC)
| size | path | what |
|---|---|---|
| 3,103 | `build-wifi-monitor.log` | monitor-mode qca build log. |
| 476 | `build-diskguard.log` | diskguard build log. |
| 19,212,336 | `qca_cld3_kiwi_v2_test.ko` | patched monitor qca module (stripped). |
| 19,212,336 | `magisk-op12-wifi-monitor/qca_cld3_kiwi_v2.ko` | same ko, staged in the Magisk module. |
| 1,629 | `magisk-op12-wifi-monitor/post-fs-data.sh` | module: bind-mount + live-swap the qca ko. |
| 309 | `magisk-op12-wifi-monitor/module.prop` | module metadata. |
| 5,024,324 | `op12_wifi_monitor.zip` | **packaged Magisk monitor module** (flashable). |
| 6,211 | `~/OnePlus12_kernal/lpc_mon.c` | LPC monitor capture tool source (**newest tool**). |
| 9,112 | `~/OnePlus12_kernal/lpc_mon` | LPC monitor, aarch64 PIE. |

### cfg80211 patch — build / CRC-gate / flash images
| size | path | what |
|---|---|---|
| 2,067,752 | `cfg80211-work/cfg80211.built.ko` | **patched** cfg80211 (two injection gates removed; vermagic maybe-dirty). |
| 2,068,616 | `cfg80211-work/cfg80211.stock.ko` | stock cfg80211 (CRC reference). |
| 544 / 44 / 3,734 | `cfg80211-work/__kcrctab*.{built,stock}.bin`, `__ksymtab_strings.*` | CRC-section dumps — **byte-identical built vs stock = CRC gate passes**. |
| 7,114 / 0 | `cfg80211-work/crc.{built,stock}.txt` | CRC compare notes. |
| 5,255 / 5,351 | `cfg80211-work/fn.{built,stock}.txt` | function-list diff. |
| 45,137,920 | `cfg80211-work/vendor_dlkm.erofs` | carved stock erofs (data only). |
| 42,565,632 | `cfg80211-work/vendor_dlkm_patched.img` | **patched vendor_dlkm** (erofs lz4hc, patched cfg80211, SELinux contexts verified). |
| 46,084,096 | `cfg80211-work/GOLDEN_vendor_dlkm_b.img` | **GOLDEN** full stock partition (erofs+verity+FEC) — rollback floor. sha `630e1625…`. |

### cfg80211 flash package (TWRP + server)
| size | path | what |
|---|---|---|
| 88,784,713 | `op12_cfg80211_toggle.zip` | **TWRP toggle zip** (Vol-UP install / Vol-DOWN rollback). |
| 88,784,713 | `serve_cfg80211/op12_cfg80211_toggle.zip` | same zip staged for HTTP serve. |
| 91 | `serve_cfg80211/op12_cfg80211_toggle.zip.sha256` | checksum. |

### Monitor-mode captures + findings
| size | path | what |
|---|---|---|
| 7,353 | `docs/op12-wifi-monitor-findings.md` | monitor-mode findings writeup. |
| 7,564 | `docs/captures/moncap_01.pcap` | monitor capture. |
| 82,968 | `docs/captures/moncap_ch6.pcap` | ch6 capture. |
| 86,258 | `docs/captures/moncap_ch6_25s.pcap` | ch6 25s capture. |
| 63,000 | `docs/captures/moncap_persist_postboot.pcap` | post-boot persistence capture (Magisk module verified). |

---

## Current state (2026-10-13)
- **Device primed:** patched cfg80211 flashed (fresh from this tree); mgmt-TX injection firmware-confirmed. Ready for DeadNet v3 **M6 on-device** validation.
- **Rollback floor:** `GOLDEN_vendor_dlkm_b.img` (sha `630e1625…`) + stock vbmeta; TWRP toggle zip carries both.
- **On-device tool set (aarch64):** `nl80211_inject` (injector), `lpc_ctl` (capture toggle), `lpc_mon` (monitor capture, newest).
- **App integration:** DeadNet v3 (`~/deadnet`, branch `feature/v3-phy-ownership`) drives the injector via a static NDK copy in `apk/assets/`.
