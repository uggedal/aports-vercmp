--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local rex = require("rex_pcre")

local M = {}

function M.generic(name)
	return rex.new(
		name..
		"(?:[-_]?(?:src|source))?"..
		"[-_]"..
		"([^-/_\\s]+?)"..
		"(?i)"..
		"(?:[-_](?:src|source|asc|orig))?"..
		"\\.(?:tar|t[bglx]z|tbz2|zip)"
	)
end

return M
