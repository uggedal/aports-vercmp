--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local M = {}

function M.add_upstream(p)
	local n = p.pkgname

	n = n:gsub("^lua-", "")
	n = n:gsub("^py-", "")
	n = n:gsub("^perl-", "")

	p.upstream_name = n
end

return M
