--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local apk = require("apk")

local M = {}

local upstream_providers = {
	(require("upstream.gnome")),
	(require("upstream.github")),
	(require("upstream.generic")),
	(require("upstream.archlinux")),
}

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

local function find_newer(pkgver, versions)
	filter_invalid(versions)
	table.sort(versions, vsort)
	local newver = nil

	for _, ver in ipairs(versions) do
		if apk.version_is_less(pkgver, ver) then
			newver = ver
			break
		end
	end
	return newver
end

local function search(p)
	local upstream = nil
	local newver = nil

	for _, provider in pairs(upstream_providers) do
		upstream = provider.init(p)
		if upstream ~= nil then
			newver = find_newer(p.pkgver, upstream:versions())
			if newver ~= nil then
				break
			end
		end
	end
	return upstream, newver
end

function M.start(db, limit)
	local maintainers = {}
	local i = 1

	for p in db:each_aport() do
		i = i + 1
		if limit ~= 0 and i >= limit then
			break
		end

		local upstream, newver = search(p)

		if newver ~= nil then
			local m = p:get_maintainer()
			local t = {
				["name"] = p.pkgname,
				["current"] = p.pkgver,
				["new"] = newver,
				["upstream"] = upstream.provider_name,
			}
			if maintainers[m] == nil then
				maintainers[m] = {}
			end
			table.insert(maintainers[m], t)
		end
	end
	return maintainers
end

return M
