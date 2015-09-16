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

function M.write(maintainers, db, start)
	local duration = os.difftime(os.time(), start)
	print(os.date("%Y-%m-%d %H:%M").." ("..duration.."s)\n")

	for _, m in ipairs(sorted_index(maintainers)) do
		print("==== "..m.." ====")

		local pkgnames = {}
		for pkgname, _ in pairs(maintainers[m]) do
			table.insert(pkgnames, pkgname)
		end
		for pkg in db:each_in_build_order(pkgnames) do
			local p = maintainers[m][pkg.pkgname]
			print(string.format("%-40s(current: %s) %s",
						pkg.pkgname.."-"..p.new, p.current, p.upstream))
		end
		print()
	end
end

return M
