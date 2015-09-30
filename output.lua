--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local M = {}

local function sorted_index(t)
	local index = {}
	for k in pairs(t) do
		table.insert(index, k)
	end
	table.sort(index)
	return index
end

function M.write(repo, maintainers, db, start)
	local duration = os.difftime(os.time(), start)
	print(repo..": "..os.date("%Y-%m-%d %H:%M").." ("..duration.."s)\n")

	for _, m in ipairs(sorted_index(maintainers)) do
		print("==== "..m.." ====")

		local pkgnames = {}
		for pkgname, _ in pairs(maintainers[m]) do
			table.insert(pkgnames, pkgname)
		end
		local notfound = {}
		for pkg in db:each_in_build_order(pkgnames) do
			local p = maintainers[m][pkg.pkgname]

			if p.notfound then
				table.insert(notfound, pkg)
			else
				print(string.format("%-40s(current: %s) %s",
					pkg.pkgname.."-"..p.new, p.current, p.upstream))
			end
		end

		for _, pkg in ipairs(notfound) do
			print(string.format("%-40sno upstream version", pkg.pkgname))
		end

		print()
	end
end

return M
