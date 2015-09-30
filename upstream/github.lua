--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local net = require("net")

local M = {}

local function versions(self)
	local vers = {}

	local releasesurl = ("https://github.com/%s/releases"):format(self.project)
	dbg(("%s: github: fetching %s"):format(self.pkg.pkgname, self.project))

	local data, ok = net.fetch(releasesurl)
	if not ok then
		return vers
	end

	-- TODO fails if project has special characters, switch to pcre
	for v in string.gmatch(data, ('a href="/%s/archive/v?([0-9a-z._-]+)%%.tar.gz"'):format(self.project)) do
		-- TODO: make such logic global?
		for _, s in pairs{
				{search="-rc", replace="_rc"},
				{search="-beta", replace="_beta"},
				{search="-alpha", replace="_alpha"},
			} do
			v = string.gsub(v, s.search, s.replace)
		end
		table.insert(vers, v)
	end
	return vers
end

function M.init(pkg)
	for source in pkg:remote_sources() do
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
