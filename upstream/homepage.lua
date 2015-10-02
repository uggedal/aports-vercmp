--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local net = require("net")
local rex = require("rex_pcre")
local pattern = require("pattern")
local upstream = require("upstream")

local M = {}

local function versions(self)
	return upstream.versions(
		self.provider_name,
		self.pkg.url,
		self.pkg.pkgname,
		self.file_name
	)
end

function M.init(pkg)
	local r = pattern.name()

	for _, source in pairs(pkg.valid_sources) do
		local file_name = rex.match(source, r)
		if file_name ~= nil then
			return {
				provider_name = "homepage",
				versions = versions,
				pkg = pkg,
				file_name = file_name
			}
		end
	end
	return nil
end

return M
