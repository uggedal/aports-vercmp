--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local net = require("net")
local json = require("cjson")

local M = {}

local function versions(self)
	local vers = {}

	local jsonurl = (
		"http://rubygems.org/api/v1/versions/%s/latest.json"
	):format(self.gem_name)
	dbg(("%s: rubygems: fetching %s"):format(self.pkg.pkgname, self.gem_name))

	local data, ok = net.fetch(jsonurl)
	if not ok then
		return vers
	end

	table.insert(vers, json.decode(data)["version"])

	return vers
end

function M.init(pkg)
	for _, source in pairs(pkg.valid_sources) do
		local gem_name  = string.match(source,
			"/([^/]+)-[^-]+%.gem$")
		if gem_name then
			return {
				provider_name = "rubygems",
				versions = versions,
				pkg = pkg,
				gem_name = gem_name
			}
		end
	end
	return nil
end

return M
