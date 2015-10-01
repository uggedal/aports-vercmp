
--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local upstream = require("upstream")

local M = {}

local function versions(self)
	return upstream.versions(
		self.provider_name,
		("http://sourceforge.net/projects/%s/rss?limit=200"):format(self.sf_name),
		self.pkg.pkgname,
		self.sf_name
	)
end

function M.init(pkg)
	for source in pkg:remote_sources() do
		local sf_name  = string.match(source,
			"https?://sourceforge.net/projects/([^/]+)") or
			string.match(source,
			"https?://downloads.sourceforge.net/sourceforge/([^/]+)") or
			string.match(source,
			"https?://downloads.sourceforge.net/project/([^/]+)") or
			string.match(source,
			"https?://downloads.sourceforge.net/([^/]+)")
		if sf_name then
			return {
				provider_name = "sf",
				versions = versions,
				pkg = pkg,
				sf_name = sf_name
			}
		end
	end
	return nil
end

return M
