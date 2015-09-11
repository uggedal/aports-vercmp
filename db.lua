local M = {}

function M.open(section)
	aportsdir = os.getenv("APORTSDIR")
	if aportsdir == nil then
		io.stderr:write("$APORTSDIR not set\n")
		os.exit(1)
	end

	dbg("init: aports: reading "..section)
	return require("aports.db").new(aportsdir, section)
end

return M