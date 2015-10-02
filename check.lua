--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local ver = require("ver")
local net = require("net")

local M = {}

local upstream_providers = {
	(require("upstream.gnome")),
	(require("upstream.github")),
	(require("upstream.sf")),
	(require("upstream.cpan")),
	(require("upstream.pypi")),
	(require("upstream.rubygems")),
	(require("upstream.directory")),
	(require("upstream.homepage")),
	(require("upstream.archlinux")),
}

local function strip_source(s)
	return s:gsub("^saveas-", ""):gsub(".*::http", "http")
end

local function filter_sources(p)
	local sources = {}

	for source in p:remote_sources() do
		local stripped = strip_source(source)
		if net.supported(stripped) then
			table.insert(sources, stripped)
		end
	end

	return sources
end

local function search(p)
	local upstream = nil
	local newer = nil
	local notfound = true
	local skip = true

	p.valid_sources = filter_sources(p)

	if #p.valid_sources > 0 then
		skip = false

		for i, provider in pairs(upstream_providers) do
			upstream = provider.init(p)

			if upstream ~= nil then
				local versions = upstream:versions()
				if #versions > 0 then
					notfound = false
					newer = ver.newer(p.pkgver, versions)
					break
				end
			end
		end
	end
	return upstream, newer, notfound, skip
end

function M.start(db, limit)
	local maintainers = {}
	local i = 0

	for p in db:each_aport() do
		i = i + 1
		if limit ~= 0 and i > limit then
			break
		end

		local upstream, newer, notfound, skip = search(p)

		if not skip then
			local t = nil
			local m = p:get_maintainer()
			if m == nil or m == "" then
				m = "(unmaintained)"
			end

			if newer ~= nil then
				t = {
					["current"] = p.pkgver,
					["new"] = newer,
					["upstream"] = upstream.provider_name,
					["notfound"] = notfound
				}
			end

			if notfound then
				t = {
					["notfound"] = notfound
				}
			end

			if t ~= nil then
				if maintainers[m] == nil then
					maintainers[m] = {}
				end
				maintainers[m][p.pkgname] = t
			end
		end
	end

	return maintainers
end

return M
