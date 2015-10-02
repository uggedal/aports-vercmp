--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local net = require("net")
local rex = require("rex_pcre")

local M = {}

local function versions(self)
	local vers = {}

	local releasesurl = ("https://github.com/%s/releases"):format(self.project)
	dbg(("%s: github: fetching %s"):format(self.pkg.pkgname, self.project))

	local data, ok = net.fetch(releasesurl)
	if not ok then
		return vers
	end

	local r = rex.new(("a href=./%s/archive/v?([0-9a-z._-]+)\\.tar\\.gz"):format(self.project))
	for v in rex.gmatch(data, r) do
		table.insert(vers, v)
	end
	return vers
end

function M.init(pkg)
	for _, source in pairs(pkg.valid_sources) do
		local project  = string.match(source,
			"https://github.com/(.*)/archive/")
		if project  then
			return {
				provider_name = "github",
				versions = versions,
				pkg = pkg,
				project = project
			}
		end
	end
	return nil
end

return M
