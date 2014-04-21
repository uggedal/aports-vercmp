

http = require("socket.http")
json = require("cjson")
ml = require("ml")
apk = require("apk")

local gnome = {}
function gnome.find_newer(upkgname, oldver)
	print("DEBUG: searching:", upkgname)
	local baseurl = "http://ftp.gnome.org/pub/GNOME/sources/"
	local jsonurl = baseurl..upkgname.."/cache.json"
	local jsondata = assert(http.request(jsonurl))
	local n,t = unpack(json.decode(jsondata))
	local latest = oldver or "0"
	for k,v in pairs(t[upkgname]) do
		if apk.version_compare(k, latest) == ">" then
			latest = k
		end
	end
	if latest == oldver then
		latest = nil
	end
	return latest
end


function gnome.is_gnome_source(pkg)
	for source in pkg:remote_sources() do
		local gnomename = string.match(source, "GNOME/sources/([^/]+)/") or
			string.match(source, "download.gnome.org/sources/([^/]+)/")
		if gnomename then
			return gnomename
		end
	end
	return nil
end

return gnome
