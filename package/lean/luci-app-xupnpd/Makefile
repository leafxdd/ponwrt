# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI page for XUPNPD
LUCI_DEPENDS:=+xupnpd +luci-compat
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-xupnpd
PKG_VERSION:=1.8
PKG_RELEASE:=2
PKG_LICENSE:=Apache-2.0

define Package/luci-app-xupnpd/conffiles
/etc/config/xupnpd
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
