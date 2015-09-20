--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local net = require("net")
local rex = require("rex_pcre")
local pattern = require("pattern")

local M = {}

local function versions(self)
	local vers = {}

	local baseurl = (string.gsub(self.source, "[^/]+$", ""))

	dbg(("%s: directory: fetching %s (%s)"):format(
		self.pkg.pkgname, baseurl, self.directory_name))

	local data, ok = net.fetch(baseurl)
	if not ok then
		return vers
	end

	local r = pattern.version(self.directory_name)

	for v in rex.gmatch(data, r) do
		table.insert(vers, v)
	end

	return vers
end

function M.init(pkg)
	local r = pattern.name()

	for source in pkg:remote_sources() do
		if net.supported(source) then
			local directory_name = rex.match(source, r)
			if directory_name ~= nil then
				return {
					provider_name = "directory",
					versions = versions,
					pkg = pkg,
					directory_name = directory_name,
					source = source
				}
			end
		end
	end
	return nil
end

return M
