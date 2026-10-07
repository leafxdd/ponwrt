# package/lean

Packages from Lean's trees, or the ones QWRT ships, that the feeds PonWrt
uses do not provide in a usable form.

LuCI packages from [coolsnowwolf/luci](https://github.com/coolsnowwolf/luci)
(branch `openwrt-25.12`, commit `2fa3f68a78e875fee86d9f9d55e38641834db225`):

| Package | Upstream path | Local changes |
|---|---|---|
| luci-app-airoha-npu | `applications/luci-app-airoha-npu` | `luci.mk` include path; dropped README screenshots |
| luci-app-turboacc | `applications/luci-app-turboacc` | `luci.mk` include path; firewall4/nftables flow offloading only (drop iptables, fast-classifier and shortcut-fe engines); depend on `luci-lua-runtime` and `luci-lib-jsonc` for the Lua rpcd backend; detect `nft_flow_offload.ko` and `nft_fullcone.ko`; offer fullcone as on/off because firewall4 parses it as a boolean |
| luci-theme-design | `themes/luci-theme-design` | `luci.mk` include path |

`luci-app-airoha-npu` reads and programs the CPU PLL through `devmem`. PonWrt
builds without `CONFIG_DEVMEM` and the busybox `devmem` applet, so the page
reports the PLL frequency as unavailable and refuses overclocking.

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
(commit `c39f1e350105f5fc6445506f03363c5bfa44273b`) with `PKG_MIRROR_HASH`
recomputed, and upx taken from `$(STAGING_DIR_HOSTPKG)`, where the packages
feed installs it (Lean's tree builds upx under `tools/`).
helloworld hashes the tarball Lean's tree generates from the git
checkout, while PonWrt generates it with `git archive`, so helloworld's hash
never matches here. Packages in `package/` take precedence over feeds, so
`./scripts/feeds install -a` skips the helloworld copy.

To update, change `PKG_VERSION` and refresh the hash:

    make package/lean/mihomo/download PKG_MIRROR_HASH=skip
    make package/lean/mihomo/check FIXUP=1
