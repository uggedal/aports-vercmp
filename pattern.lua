--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local rex = require("rex_pcre")

local M = {}

local function gen(name, version)
	return rex.new(name..
		"(?:[-_]?(?:src|source))?"..
		"[-_]"..
		version..
		"(?i)"..
		"(?:[-_](?:src|source|asc|orig))?"..
		"\\.(?:tar|t[bglx]z|tbz2|zip)"
	)
end

function M.name()
	return gen("([^/]+)", "(?:[^-/_\\s]+?)")
end

function M.version(name)
	return gen(name, "([^-/_\\s]+?)")
end

return M
