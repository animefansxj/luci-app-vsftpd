--[[
LuCI - Lua Configuration Interface - vsftpd support

Script by animefans_xj @ nvacg.com (af_xj@hotmail.com , xujun@smm.cn)

Licensed under the Apache License, Version 2.0 (the "license");
you may not use this file except in compliance with the License.
you may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.vsftpd",package.seeall)

function index()
	require("luci.i18n")
	luci.i18n.loadc("vsftpd")
	if not nixio.fs.access("/etc/config/vsftpd") then
		return
	end
	
	local page = entry({"admin","services","vsftpd"},cbi("vsftpd"),_("FTP Service"))
	page.i18n="vsftpd"
	page.dependent=true
end
