local M = {}

function M.write(maintainers)
	print(os.date())
	for m, pkgs in pairs(maintainers) do
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
