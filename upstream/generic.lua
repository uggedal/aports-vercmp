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

	dbg(("%s: generic: fetching %s"):format(self.pkg.pkgname, baseurl))

	local data, ok = net.fetch(baseurl)
	if not ok then
		return vers
	end

	local r = pattern.generic(self.pkg.upstream_name)

	for v in rex.gmatch(data, r) do
		table.insert(vers, v)
	end

	return vers
end

function M.init(pkg)
	for source in pkg:remote_sources() do
		-- TODO: support foo.tar:: prefix
		if net.supported(source) then
			return {
				provider_name = "generic",
				versions = versions,
				pkg = pkg,
				source = source
			}
		end
	end
	return nil
end

return M
