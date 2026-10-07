# package/lean

Packages from Lean's trees, or the ones QWRT ships, that the feeds PonWrt
uses do not provide in a usable form.

LuCI packages from [coolsnowwolf/luci](https://github.com/coolsnowwolf/luci)
(branch `openwrt-25.12`, commit `2fa3f68a78e875fee86d9f9d55e38641834db225`):

| Package | Upstream path | Local changes |
|---|---|---|
| luci-app-airoha-npu | `applications/luci-app-airoha-npu` | `luci.mk` include path; dropped README screenshots |
| luci-app-turboacc | `applications/luci-app-turboacc` | `luci.mk` include path; firewall4/nftables flow offloading only (drop iptables, fast-classifier and shortcut-fe engines); depend on `luci-lua-runtime` and `luci-lib-jsonc` for the Lua rpcd backend; detect `nft_flow_offload.ko` and `nft_fullcone.ko`; fullcone mode 2 (Broadcom) sets firewall4's `brcm_fullcone`, see below; uci-defaults turns packet steering off unless it was set, since hardware flow offloading keeps forwarded traffic off the CPU |
| luci-theme-design | `themes/luci-theme-design` | `luci.mk` include path |

`luci-app-airoha-npu` reads and programs the CPU PLL through `devmem`, which
`configs/an7581.config` already provides (`CONFIG_KERNEL_DEVMEM` and the
busybox `devmem` applet). An overclock only lasts until the next reboot.

## luci-app-xupnpd

From [jarod360/luci-app-xupnpd](https://github.com/jarod360/luci-app-xupnpd)
(commit `4afbcc53ae6cdde1527548172f3e502107eef539`, Apache-2.0 per its
Makefile header), the same code QWRT ships. Local changes:

- No `/etc/init.d/xupnpd` or `/etc/config/xupnpd` of its own: they would
  collide with the xupnpd package's files, which apk refuses. The xupnpd
  copy below provides both and honours the `enabled` option.
- Depend on `luci-compat` for the Lua CBI page and add an rpcd ACL.
- Translations moved to `po/zh_Hans`, where `luci.mk` looks for them.
- No bundled ISP-specific `iptv.m3u` and no uci-defaults script; dropped the
  unused "Broadcast for LAN Only" option. Clearing the playlist text box
  now empties the playlist, and saving it sends xupnpd SIGUSR1 so the new
  list is picked up without a restart.

## xupnpd

Copied from the ImmortalWrt packages feed (`multimedia/xupnpd`, commit
`e731ba76764082d9db71de60f1ddac43f4114101`) so its init script can read
`/etc/config/xupnpd`, which the package now ships with `enabled` off. The
service only starts when `enabled` is set, and a reload trigger starts or
stops it whenever the `xupnpd` config changes. Packages in `package/` take
precedence over feeds, so `./scripts/feeds install -a` skips the feed copy.

## mihomo

Copied from [fw876/helloworld](https://github.com/fw876/helloworld)
(commit `c39f1e350105f5fc6445506f03363c5bfa44273b`) with upx taken from
`$(STAGING_DIR_HOSTPKG)`, where the packages feed installs it (Lean's tree
builds upx under `tools/`). Packages in `package/` take precedence over
feeds, so `./scripts/feeds install -a` skips the helloworld copy.

There is no prebuilt source tarball on the mirrors, so the build packs one
from a git checkout. Building as root keeps the group-write bits
`git archive` sets, which changes the tarball, and `PKG_MIRROR_HASH` then
fails to match. Build as a regular user, as CI does.

To update, copy `PKG_VERSION` and `PKG_MIRROR_HASH` from helloworld, or
refresh the hash as a regular user:

    make package/lean/mihomo/download PKG_MIRROR_HASH=skip
    make package/lean/mihomo/check FIXUP=1

## Broadcom fullcone NAT

turboacc's "Broadcom Fullcone NAT1" mode, ported from
[coolsnowwolf/lede](https://github.com/coolsnowwolf/lede) (commit
`0bf8f083b1c6b55770d1bb71e6a5402ee90e35cb`). It lives outside this
directory:

| Path | Source |
|---|---|
| `target/linux/generic/hack-6.18/982-add-bcm-fullconenat-support.patch`, `983-add-bcm-fullconenat-to-nft.patch`, `985-netfilter-bcm-fullcone-reserve-expectation-early.patch` | Lean, unchanged |
| `target/linux/generic/hack-6.18/986-netfilter-bcm-fullcone-do-not-unregister-helper.patch` | local: 982 unregisters a helper that was never registered, which crashes when `nft_masq` is unloaded |
| `package/libs/libnftnl/patches/002-libnftnl-add-masquerade-fullcone-flag.patch`, `package/network/utils/nftables/patches/103-nftables-add-masquerade-fullcone-flag.patch`, `104-fix-fullcone-json-parsing.patch` | Lean, unchanged; 104 also fixes a crash parsing JSON `redirect` statements |
| `package/network/config/firewall4/patches/002-firewall4-add-brcm-fullcone-mode.patch` | Lean's, but selected with `brcm_fullcone '1'` next to `fullcone '1'` (Lean's `fullcone '2'` also works), because LuCI's firewall page shows fullcone as a checkbox and would reset `2` to off |
| `package/kernel/linux/files/sysctl-nf-conntrack.conf` | `nf_conntrack_expect_max=16384`, as in Lean's tree |

The kernel puts a `BCM-NAT` helper on the first conntrack of each IPv4 UDP
mapping and keeps the mapping open through a conntrack expectation:

- Only IPv4 UDP is covered. TCP and IPv6 are masqueraded as usual.
- Conntracks with a helper are never flow offloaded, so the first
  connection of each mapping stays on the CPU path. Later connections that
  reuse the mapping, and inbound ones, can still be offloaded.
- With 985, a new UDP flow is dropped when the expectation table is full,
  hence the larger `nf_conntrack_expect_max`.
