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
		if m == nil or m == "" then
			m = "(unmaintained)"
		end
		print("==== "..m.." ====")

		local pkgs = {}
		for _, p in pairs(maintainers[m]) do
			table.insert(pkgs, p.pkgname)
		end
		for pkg in db:each_in_build_order(pkgs) do
			local p = maintainers[m][pkg.dir]
			print(string.format("%-40s(current: %s) %s",
						p.name.."-"..p.new, p.current, p.upstream))
		end
		print()
	end
end

return M
