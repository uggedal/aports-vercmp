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
		string.gsub(self.source, "[^/]+$", ""),
		self.pkg.pkgname,
		self.directory_name
	)
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
