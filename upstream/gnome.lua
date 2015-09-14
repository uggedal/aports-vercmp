--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

net = require("net")
json = require("cjson")

local M = {}

local function versions(self)
	local vers = {}

	local baseurl = "http://ftp.gnome.org/pub/GNOME/sources/"
	local jsonurl = baseurl..self.gnome_name.."/cache.json"

	dbg(("%s: gnome: fetching %s"):format(self.pkg.pkgname, jsonurl))

	local data, ok = net.fetch(jsonurl)
	if not ok then
		return vers
	end

	local n, t = unpack(json.decode(data))

	for k, v in pairs(t[self.gnome_name]) do
		table.insert(vers, k)
	end
	return vers
end

function M.init(pkg)
	for source in pkg:remote_sources() do
		local gnomename = string.match(source, "GNOME/sources/([^/]+)/")
			or string.match(source,
					"download.gnome.org/sources/([^/]+)/")
		if gnomename then
			return {
				provider_name = "gnome",
				versions = versions,
				pkg = pkg,
				gnome_name = gnomename
			}
		end
	end
	return nil
end

return M
