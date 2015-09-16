--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local apk = require("apk")

local M = {}

local function filter_invalid(versions)
	for i = #versions, 1, -1 do
		if not apk.version_validate(versions[i]) then
			table.remove(versions, i)
		end
	end
end

local function vsort(a, b)
	if apk.version_compare(a, b) == "=" then
		return a > b
	end

	if apk.version_is_less(a, b) then
		return false
	end
	return true
end

function M.newer(pkgver, versions)
	filter_invalid(versions)
	table.sort(versions, vsort)

	local newer = nil

	for _, ver in ipairs(versions) do
		if apk.version_is_less(pkgver, ver) then
			newer = ver
			break
		end
	end
	return newer
end

return M
