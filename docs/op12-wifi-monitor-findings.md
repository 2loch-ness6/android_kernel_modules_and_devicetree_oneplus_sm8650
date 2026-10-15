# OnePlus 12 (WCN7850 "kiwi_v2") — Working WiFi Monitor-Mode Capture

**Status: PROVEN WORKING (2026-10-12).** A one-call qcacld driver patch makes
`con_mode=4` global monitor mode auto-start Local Packet Capture (LPC), so
`tcpdump -i wlan0` captures real promiscuous 802.11 traffic. On the **stock**
kernel the same `con_mode=4` + tcpdump captures **0 frames**.

Device: CPH2581, OxygenOS 15.0.0.863, kernel `6.1.118-android14-11-o`,
WCN7850 ("kiwi_v2"). Bootloader unlocked, Magisk root.

## Root cause (why stock captures 0 frames)
WCN7850 does not feed a classic monitor *destination* ring. Monitor RX arrives as
RX-header TLVs in the monitor *status* ring and is reconstructed into 802.11 frames
**only by the Local Packet Capture (LPC) handler**, which runs only when
`is_local_pkt_capture_running == true`
(`dp/wifi3.0/monitor/1.0/dp_rx_mon_status_1.0.c` — otherwise the status nbuf is freed).
That flag is set only by `cdp_start_local_pkt_capture()`, whose only stock trigger is
the `QCA_NL80211_VENDOR_SUBCMD_SET_MONITOR_MODE` (202) vendor command. The classic
`con_mode=4` open path (`__hdd_mon_open`) sets up the monitor *filter* but never starts
LPC → 0 frames. All LPC config is already compiled in on stock (`WLAN_DP_LOCAL_PKT_CAPTURE`).
Nothing is missing except *starting* capture.

## The fix (branch `a15-wifi-monitor`, commit 04493091 + build-config revert)
Four edits in `vendor/qcom/opensource/wlan/qcacld-3.0`:
1. **`core/hdd/src/wlan_hdd_main.c`** — new static helper
   `wlan_hdd_lpc_start_global_monitor()` (gated `#ifdef WLAN_FEATURE_LOCAL_PKT_CAPTURE`)
   that builds an all-frames `cdp_monitor_filter` (`mode=MON_FILTER_PASS`,
   `fp_mgmt=FILTER_MGMT_ALL`, `fp_data=FILTER_DATA_ALL`, `fp_ctrl=FILTER_CTRL_ALL`) and
   calls `cdp_start_local_pkt_capture(soc, OL_TXRX_PDEV_ID, &filter)`. Wired into
   `__hdd_mon_open`'s success path, called when `con_mode == QDF_GLOBAL_MONITOR_MODE`.
   Bypasses both the INI gate and the os_if concurrency gate.
2. **`core/hdd/src/wlan_hdd_sysfs_monitor_mode_channel.c`** — propagate the
   `wlan_hdd_set_mon_chan()` error instead of silently returning `count` (surfaces
   bad channel/BW writes).
3. **`core/sme/src/csr/csr_api_roam.c`** `csr_get_vdev_type_nss` — add
   `case QDF_MONITOR_MODE` (reuse STA nss).
4. **`core/sme/src/common/sme_api.c`** `sme_get_nss_chain_shift` — add
   `case QDF_MONITOR_MODE: return STA_NSS_CHAINS_SHIFT;`.

Build config: the three **pktlog/streamfs research configs** from the parent branch
(`CONFIG_FEATURE_PKTLOG=y`, `CONFIG_WLAN_STREAMFS=y`, `-REMOVE_PKT_LOG`) were reverted —
they break the module link (`pktlog_htc_attach`, `relay_file_operations` undefined) and
are unrelated to monitor capture. They remain in commit a8b258e4 for separate work.

## Build
From `/srv/op12-kernel/kernel_platform`:
```
tools/bazel run \
  --//build/kernel/kleaf/impl:force_disable_trim=true \
  --//build/kernel/kleaf:kmi_symbol_list_violations_check=false \
  --//build/kernel/kleaf:kmi_symbol_list_strict_mode=false \
  //vendor/qcom/opensource/wlan/qcacld-3.0:pineapple_gki_kiwi-v2_modules_dist
```
Requires symlink `kernel_platform/vendor -> ../vendor` (qcacld BUILD.bazel uses absolute
`//vendor/...` labels that must resolve inside the kernel_platform bazel workspace).
GKI kernel is cached; a module-only rebuild is ~5 min. Dist `.ko` is unstripped (~523 MB);
`llvm-strip --strip-debug` → ~19.2 MB (matches stock 19.21 MB).

Vermagic: built `6.1.118-android14-11-o-maybe-dirty SMP preempt mod_unload modversions
aarch64`. Loads on the running `...-g818f2506c9e7` kernel because with `modversions` the
loader's `same_magic()` skips the release token and compares only the flags (identical to
stock); imported-symbol CRCs match (same GKI source).

## Test (insmod only, no flash, fully reversible by stock reload)
`montest_lpc.sh` (detached, self-restoring): `svc wifi disable` → `rmmod qca_cld3_kiwi_v2`
(boot-resident, refcnt 0) → `insmod qca_cld3_kiwi_v2_test.ko con_mode=4` →
`ip link set wlan0 up` → `echo "6 0" > .../net/wlan0/monitor_mode_channel` (val1=chan/freq,
val2 = **phy_ch_width enum**: 0=20 MHz, 1=40, 2=80, 3=160 — NOT MHz) →
`tcpdump -i wlan0 -w cap.pcap`. Restore: `rmmod` test → `insmod stock_wlan.ko` →
`svc wifi enable`. adbd-over-TCP drops when wlan0 cycles; script re-asserts it via
`setprop persist.adb.tcp.port 5555; stop/start adbd`.

## Evidence (ch6, 25 s capture, 2026-10-12)
`dmesg`: `wlan_hdd_lpc_start_global_monitor: LPC global monitor capture started (all frames)`.
233 frames captured (stock = 0). Real promiscuous traffic from devices we are NOT
associated with: encrypted WPA data frames (`Data IV:… KeyID`) across 4 BSSIDs
(`24:41:fe:e4:58:8e`, `4c:ab:f8:09:2f:66`, `2c:67:be:49:fd:7b`, `90:d3:cf:11:61:f0`) and
their clients, plus SSDP/mDNS/STP/IPv6-NDP multicast and broadcast, real RSSI (−87 dBm),
real rates. Pcaps: `docs/captures/moncap_ch6_25s.pcap` (+ `moncap_01.pcap`, `moncap_ch6.pcap`).

## Known refinement (not blocking)
~196/233 frames decoded as bogus "Assoc Request ()" with all-zero SA/BSSID and a constant
DA (`ac:c0:48:6f:4b:bb`, not the device MAC `82:80:b9:d1:22:c7`). These are a
mis-decoded/placeholder frame type the LPC path emits (112-byte radiotap with the ext-present
bit confuses old tcpdump's 802.11 offset). The real frames (above) decode correctly. Future:
tune the monitor filter / investigate the null frames to cut the noise.

## Persistence — DONE via Magisk module (2026-10-12, survives reboot)
Module `op12_wifi_monitor` (`/srv/op12-kernel/op12_wifi_monitor.zip`, source in
`/srv/op12-kernel/magisk-op12-wifi-monitor/`). The real module file is a single
`/vendor_dlkm/lib/modules/qca_cld3_kiwi_v2.ko` (erofs RO; `/vendor/lib/modules` is a
symlink to it), SELinux `u:object_r:vendor_file:s0`, listed at modules.load:306. Magisk v31
does NOT magic-mount vendor_dlkm, so a passive overlay won't work — the module's
`post-fs-data.sh` instead: (1) `chcon vendor_file` + `mount --bind` the patched .ko over the
target (catches the boot-time load), and (2) if already loaded at post-fs-data (refcnt 0,
pre-WiFi), live `rmmod` + `insmod` the patched one. `magisk --install-module` only extracted
module.prop, so the .ko + post-fs-data.sh were placed directly in
`/data/adb/modules/op12_wifi_monitor/` (0644 / 0755, root).

Verified after a reboot: boot log shows `bind-mount OK` → `already loaded ... refcnt=0` →
`rmmod OK` / `insmod patched OK`; loaded module = patched (`maybe-dirty` vermagic), STA WiFi
normal (`192.168.1.201`). Out-of-the-box test (NO insmod): `svc wifi disable` →
`echo 4 > /sys/module/qca_cld3_kiwi_v2/parameters/con_mode` → dmesg
`wlan_hdd_lpc_start_global_monitor: LPC global monitor capture started (all frames)` →
`echo "6 0" > monitor_mode_channel` → `tcpdump -i wlan0` = 164 frames
(`docs/captures/moncap_persist_postboot.pcap`). adb-over-TCP auto-reconnected on 5555 after
reboot (`persist.adb.tcp.port=5555`). Disable/remove = toggle the module off in Magisk +
reboot (restores stock .ko).

## Next steps
- Refine the ~artifact null frames (zero-SA "Assoc Request" decode) to cut capture noise;
  ratio of real:artifact frames varies with ambient traffic.
- Bundle with the cfg80211 mgmt-injection work (nested `kernel_platform/common` repo) for a
  full NetHunter kernel. Publish on XDA (module + findings).
