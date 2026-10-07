local playlist = "/usr/share/xupnpd/playlists/iptv.m3u"

m = Map("xupnpd")
m.title = translate("XUPNPD IPTV Config")
m.description = translate("XUPNPD for IPTV DLNA Service")

m:section(SimpleSection).template = "xupnpd/xupnpd_status"

s = m:section(TypedSection, "xupnpd")
s.addremove = false
s.anonymous = true

s:tab("basic", translate("Basic Setting"))
enable = s:taboption("basic", Flag, "enabled", translate("Enable"))
enable.rmempty = false

s:tab("config", translate("IPTV M3U List"))
config = s:taboption("config", Value, "config", translate("IPTV M3U List"),
	translate("Stream URLs must point at the router, e.g. through udpxy or msd_lite."))
config.template = "cbi/tvalue"
config.rows = 13
config.wrap = "off"

function config.cfgvalue(self, section)
	return nixio.fs.readfile(playlist)
end

function config.write(self, section, value)
	value = value:gsub("\r\n?", "\n")
	nixio.fs.writefile(playlist, value)
end

function config.remove(self, section)
	nixio.fs.writefile(playlist, "")
end

return m
