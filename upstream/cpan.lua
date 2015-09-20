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
		("http://search.cpan.org/dist/%s/"):format(self.cpan_name),
		self.pkg.pkgname,
		self.cpan_name
	)
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
