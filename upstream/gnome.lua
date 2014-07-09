

http = require("socket.http")
json = require("cjson")
apk = require("apk")

local M = {}

local function find_newer(self)
	local oldver = self.pkg.pkgver
	print("DEBUG: searching:", self.gnome_name)
	local baseurl = "http://ftp.gnome.org/pub/GNOME/sources/"
	local jsonurl = baseurl..self.gnome_name.."/cache.json"
	local jsondata = assert(http.request(jsonurl))
	local n,t = unpack(json.decode(jsondata))
	local latest = oldver or "0"
	for k,v in pairs(t[self.gnome_name]) do
		if apk.version_compare(k, latest) == ">" then
			latest = k
		end
	end
	if latest == oldver then
		latest = nil
	end
	return latest
end

function M.init(pkg)
	local provider = {
		provider_name = "gnome",
		pkg = pkg,
	}

	for source in pkg:remote_sources() do
		local gnomename = string.match(source, "GNOME/sources/([^/]+)/")
			or string.match(source,
					"download.gnome.org/sources/([^/]+)/")
		if gnomename then
			return {
				gnome_name = gnomename,
				provider_name = "gnome",
				find_newer = find_newer,
				pkg = pkg
			}
		end
	end
	return nil
end

return M
