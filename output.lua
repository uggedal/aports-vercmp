local M = {}

local function sorted_index(t)
	local index = {}
	for k in pairs(t) do
		table.insert(index, k)
	end
	table.sort(index)
	return index
end

function M.write(maintainers)
	print(os.date())

	for _, m in ipairs(sorted_index(maintainers)) do
		local pkgs = maintainers[m]
		if m == nil or m == "" then
			m = "(unmaintained)"
		end
		table.sort(pkgs, function(a,b) return a.name<b.name end)
		print("==== "..m.." ====")
		for i,p in pairs(pkgs) do
			print(string.format("%-40s(current: %s) %s",
						p.name.."-"..p.new, p.current, p.upstream))
		end
		print()
	end
end

return M
