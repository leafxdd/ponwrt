# package/pon

Local copies of packages from the
[pbs05/openwrt-pon-userspace](https://github.com/pbs05/openwrt-pon-userspace)
feed that need changes. Packages in `package/` take precedence over feeds,
so `./scripts/feeds install -a` skips the feed copies.

## airoha-pon-daemons

`Makefile`, `README.md`, `files/` and `src/` are upstream's at commit
`a903fcc80f4b89f9b9e59a02d3ba1fc5550819a5`, unchanged except that
`Build/Prepare` applies `patches/` and `PKG_RELEASE` is one higher.

`patches/100-oam-report-the-ctc-onu-sn.patch` changes how EPON reports the
CTC ONU SN attribute (branch 0xC7, leaf 0x0001):

- Upstream changed it in November 2026 (10f4a9e, a903fcc) from the CTC
  layout to the 8-byte ONU serial number, tested against one Huawei OLT.
  The patch sends the CTC layout again: vendor ID (4), ONU model (4),
  ONU ID, which is the MAC address (6), hardware version (8) and software
  version (16), plus the extended ONU model (16) from CTC 3.0 on. They
  come from the `model`, `hardware_version`, `software_version` and
  `equipment_id` options of the `oam` section in `/etc/config/pon`.
  `option onu_sn_format 'serial'` there restores upstream's 8-byte value.
- An unset `vendor_id` follows the vendor bytes of the serial number the
  line registers with instead of `OWRT`. A configured one still wins.
- The serial number is read for every OAMPDU instead of once at start. The
  driver only latches it when `pon0` opens, after the agent has started,
  so upstream usually sent `OWRT` and part of the MAC address instead.
  `pondctl events --line line0` shows an `identity` event when it changes.

The CTC layout is what the agent sent before November, and what the
naoki66/OpenWrt_ONU_CONFIG fork and faadd2's ZN504XG-D builds still send.
On a China Telecom 10G-EPON line a FiberHome HG5585F CT registered with
such a build but was deregistered and denied with upstream's, and so was a
Nokia XG-040G-TF. With this patch the line registers and PPPoE comes up
(tested November 2026).

To update, copy the package from the feed again and refresh the patch:

    make package/pon/airoha-pon-daemons/{clean,prepare} V=s QUILT=1
    cd build_dir/target-*/airoha-pon-daemons-*/
    quilt push -a
    cd -
    make package/pon/airoha-pon-daemons/refresh
