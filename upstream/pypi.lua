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

	local jsonurl = ("https://pypi.python.org/pypi/%s/json"):format(self.pypi_name)
	dbg(("%s: pypi: fetching %s"):format(self.pkg.pkgname, self.pypi_name))

	local data, ok = net.fetch(jsonurl)
	if not ok then
		return vers
	end

	for key, val in pairs(json.decode(data)) do
		if key == "releases" then
			for ver, _ in pairs(val) do
				table.insert(vers, ver)
			end
		end
	end

	return vers
end

function M.init(pkg)
	for _, source in pairs(pkg.valid_sources) do
		local pypi_name  = string.match(source,
			"https?://pypi.python.org/packages/source/[^/]+/([^/]+)/")
		if pypi_name then
			return {
				provider_name = "pypi",
				versions = versions,
				pkg = pkg,
				pypi_name = pypi_name
			}
		end
	end
	return nil
end

return M
