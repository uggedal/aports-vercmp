--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local net = require("net")
local rex = require("rex_pcre")
local pattern = require("pattern")

local M = {}

function M.versions(provider, url, pkgname, searchname)
	local vers = {}

	dbg(("%s: %s: fetching %s (%s)"):format(
		provider, pkgname, url, searchname))

	local data, ok = net.fetch(url)
	if not ok then
		return vers
	end

	local r = pattern.version(searchname)

	for v in rex.gmatch(data, r) do
		table.insert(vers, v)
	end

	return vers
end

return M
