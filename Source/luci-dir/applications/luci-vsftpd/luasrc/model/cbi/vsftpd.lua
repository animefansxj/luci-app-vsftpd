--[[
LuCI - Lua Configuration Interface - vsftpd support

Script by Admin @ NVACG.com (af_xj@hotmail.com , xujun@smm.cn)
The template Read & Write Function is based on luci-app-samba, TKS.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

require("luci.sys")
require("luci.util")

local running=(luci.sys.call("pidof vsftpd > /dev/null") == 0)

m=Map("vsftpd",translate("FTP Service"),translate("Use this page, you can share your file under web via ftp."))

s=m:section(TypedSection,"vsftpd","")
s.addremove=false
s.anonymous=true

s:tab("general",translate("Global"))
s:tab("localuser",translate("Local User"))
s:tab("anonymous",translate("Anonymous"))
s:tab("userlist",translate("User List"))
s:tab("template",translate("Template"))



enable=s:taboption("general",Flag,"enabled",translate("Enabled"))
enable.rmempty=false
function enable.cfgvalue(self,section)
	return luci.sys.init.enabled("vsftpd") and self.enabled or self.disabled
end
function enable.write(self,section,value)
	if value == "1" then
	  if running then
		luci.sys.call("/etc/init.d/vsftpd stop >/dev/null")
	  end
		luci.sys.call("/etc/init.d/vsftpd enable >/dev/null")
		luci.sys.call("/etc/init.d/vsftpd start >/dev/null")
	else
		luci.sys.call("/etc/init.d/vsftpd stop >/dev/null")
		luci.sys.call("/etc/init.d/vsftpd disable >/dev/null")
	end
end
banner=s:taboption("general",Value,"ftpd_banner",translate("FTP banner"))
banner.rmempty=true
banner.placeholder="OpenWRT Router Embd FTP service."
max_clients=s:taboption("general",Value,"max_clients",translate("Max number of clients"))
max_clients.placeholder="10"
max_clients.datatype="range(1,100)"
max_clients.rmempty=false
ascii=s:taboption("general",ListValue,"ascii",translate("ASCII availabled"))
ascii:value("both","Both Download and Upload")
ascii:value("download","Download only")
ascii:value("upload","Upload only")
ascii:value("none","None")
port_20=s:taboption("general",Flag,"connect_from_port_20",translate("Data Port using 20"))
port_20.rmempty=false
async_abor=s:taboption("general",Flag,"async_abor_enable",translate("Accept Special Cmd"))
async_abor.rmempty=false
ls_recurse=s:taboption("general",Flag,"ls_recurse_enable",translate("Allow exhaustive listing"))
ls_recurse.rmempty=false
dirmessage=s:taboption("general",Flag,"dirmessage_enable",translate("Enable DIR Message"))
dirmessage.rmempty=false
idle_timeout=s:taboption("general",Value,"idle_session_timeout",translate("Idle timeout"))
idle_timeout.rmempty=false
idle_timeout.placeholder="600"
transfer_timeout=s:taboption("general",Value,"data_connection_timeout",translate("Transfer timeout"))
transfer_timeout.rmempty=false
transfer_timeout.placeholder="200"

local_enabled=s:taboption("localuser",Flag,"local_enable",translate("Allow local member"))
local_enabled.rmempty=false
local_write=s:taboption("localuser",Flag,"write_enable",translate("Member can write"))
local_write.rmempty=false
local_write:depends("local_enable",1)
local_chown=s:taboption("localuser",Flag,"chown_uploads",translate("Allow change permissions"))
local_chown.rmempty=false
local_chown:depends("local_enable",1)
local_chroot=s:taboption("localuser",Flag,"chroot_local_user",translate("Enable chroot"))
local_chroot.rmempty=false
local_chroot:depends("local_enable",1)
local_umask=s:taboption("localuser",Value,"local_umask",translate("uMask for new uploads"),translate("The format for number likes ###, first bit for the file's Master. second bit for the Groups which Master have joined, last bit for other people. Every bit's value from 0 to 7: 4 means read, 2 means write, 1 means execute. The value of a bit is the sigma of above listed value. When a file created, the default value is 777\(that means everyone can read write and execute the file,\) and the vsftpd will deduct the value which you set from default value."))
local_umask:value("000","000")
local_umask:value("022","022")
local_umask:value("027","027")
local_umask.placeholder="000"
local_umask.datatype="range(0,777)"
local_umask.rmempty=true
local_umask:depends("local_enable",1)

anon_enabled=s:taboption("anonymous",Flag,"anonymous_enable",translate("Allow anonymous"))
anon_enabled.rmempty=false
anon_upload=s:taboption("anonymous",Flag,"anon_upload_enable",translate("Anonymous can upload"))
anon_upload.rmempty=false
anon_upload:depends("anonymous_enable",1)
anon_mkdir=s:taboption("anonymous",Flag,"anon_mkdir_write_enable",translate("Anonymous can create folder"))
anon_mkdir.rmempty=false
anon_mkdir:depends("anonymous_enable",1)
anon_root=s:taboption("anonymous",Value,"anon_root",translate("Anonymous root"))
anon_root.rmempty=false

local_userlist=s:taboption("userlist",Flag,"userlist_enable",translate("Enable userlist"))
local_userlist.rmempty=false
local_userlist:depends("local_enable",1)
local_userlist_type=s:taboption("userlist",ListValue,"userlist_type",translate("Userlist control type"))
local_userlist_type:value("allow","allow")
local_userlist_type:value("deny","deny")
list=s:taboption("userlist",DynamicList,"userlist",translate("user"))
for _, list_user in luci.util.vspairs(luci.util.split(luci.sys.exec("cat /etc/passwd | cut -f 1 -d:"))) do
    list:value(list_user)
end

tmpl=s:taboption("template",Value,"_tmpl","",translate("Here,you can edit the template of config file"))
tmpl.template = "cbi/tvalue"
tmpl.rows=20

function tmpl.cfgvalue(self, section)
	return nixio.fs.readfile("/etc/vsftpd.conf.template")
end

function tmpl.write(self, section, value)
	value = value:gsub("\r\n?", "\n")
	nixio.fs.writefile("/etc/vsftpd.conf.template", value)
end


return m
