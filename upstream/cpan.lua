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

	local url = ("http://search.cpan.org/dist/%s/"):format(self.cpan_name)
	dbg(("%s: cpan: fetching %s"):format(self.pkg.pkgname, self.cpan_name))

	local data, ok = net.fetch(url)
	if not ok then
		return vers
	end

	local r = pattern.version(self.cpan_name)

	for v in rex.gmatch(data, r) do
		table.insert(vers, v)
	end

	return vers
end

function M.init(pkg)
	for source in pkg:remote_sources() do
		local cpan_name  = string.match(source,
			"https?://search.cpan.org/.+/([^/]+)-")
		if cpan_name then
			return {
				provider_name = "cpan",
				versions = versions,
				pkg = pkg,
				cpan_name = cpan_name
			}
		end
	end
	return nil
end

return M
