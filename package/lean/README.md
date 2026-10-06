# package/lean

Packages imported from Lean's trees that the feeds PonWrt uses do not provide
in a usable form.

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

## mihomo

Copied from [fw876/helloworld](https://github.com/fw876/helloworld)
(commit `c39f1e350105f5fc6445506f03363c5bfa44273b`) with `PKG_MIRROR_HASH`
recomputed. helloworld hashes the tarball Lean's tree generates from the git
checkout, while PonWrt generates it with `git archive`, so helloworld's hash
never matches here. Packages in `package/` take precedence over feeds, so
`./scripts/feeds install -a` skips the helloworld copy.

To update, change `PKG_VERSION` and refresh the hash:

    make package/lean/mihomo/download PKG_MIRROR_HASH=skip
    make package/lean/mihomo/check FIXUP=1
