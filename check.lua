--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local ver = require("ver")

local M = {}

local upstream_providers = {
	(require("upstream.gnome")),
	(require("upstream.github")),
	(require("upstream.sf")),
	(require("upstream.cpan")),
	(require("upstream.pypi")),
	(require("upstream.rubygems")),
	(require("upstream.homepage")),
	(require("upstream.directory")),
	(require("upstream.archlinux")),
}

local function search(p)
	local upstream = nil
	local newer = nil
	local notfound = true

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
	return upstream, newer, notfound
end

function M.start(db, limit)
	local maintainers = {}
	local i = 0

	for p in db:each_aport() do
		i = i + 1
		if limit ~= 0 and i > limit then
			break
		end

		local upstream, newer, notfound = search(p)

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

	return maintainers
end

return M
