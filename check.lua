local M = {}

local upstream_providers = {
	(require("upstream.gnome")),
	(require("upstream.github")),
	(require("upstream.generic")),
	(require("upstream.archlinux")),
}

function M.start(db, limit)
	local maintainers = {}
	local i = 1
	for p in db:each_aport() do
		i = i + 1
		if limit ~= 0 and i >= limit then
			break
		end

		local upstream_pkg = nil
		local newver = nil
		for _,provider in pairs(upstream_providers) do
			upstream_pkg = provider.init(p)
			if upstream_pkg then
				newver = upstream_pkg:find_newer()
				break
			end
		end
		if newver ~= nil then
			local m = p:get_maintainer()
			local t = {
				["name"] = p.pkgname,
				["current"] = p.pkgver,
				["new"] = newver,
				["upstream"] = upstream_pkg.provider_name,
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
