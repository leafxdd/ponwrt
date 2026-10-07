# SPDX-Identifier-License: GPL-3.0-only
#
# Copyright (C) 2024 Lean <coolsnowwolf@gmail.com>
# Copyright (C) 2019-2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-turboacc

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_TURBOACC_INCLUDE_BBR_CCA

PKG_LICENSE:=GPL-3.0-only
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

# PonWrt only ships firewall4, so the fastpath engine is nftables flow
# offloading; the iptables, fast-classifier and shortcut-fe engines are gone.
LUCI_TITLE:=LuCI support for FastPath (FW4)
LUCI_DEPENDS:= \
	+firewall4 \
	+kmod-nft-offload \
	+luci-lib-jsonc \
	+luci-lua-runtime \
	+PACKAGE_TURBOACC_INCLUDE_BBR_CCA:kmod-tcp-bbr
LUCI_PKGARCH:=all

define Package/luci-app-turboacc/config
  config PACKAGE_TURBOACC_INCLUDE_BBR_CCA
    bool "Enable BBR CCA"
    depends on PACKAGE_luci-app-turboacc
    default y
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
