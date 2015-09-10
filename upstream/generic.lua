http = require("socket.http")
apk = require("apk")
rex = require("rex_pcre")

local M = {}

local function find_newer(self)
	local baseurl = (string.gsub(self.source, "[^/]+$", ""))

	dbg(("%s: generic: fetching %s"):format(self.pkg.pkgname, baseurl))

	-- TODO: factor fetching logic in helper with support for
	--       several formats
	local data, status = http.request(baseurl)
	if data == nil then
		io.stderr:write("ERROR: " .. status .. "\n")
		return
	end

	local r = rex.new(
		"(?i)"..
		"\\b"..
		self.pkg.pkgname..
		"[-_]"..
		"([^-/_\\s]*?\\d[^-/_\\s]*?)"..
		"(?:[-_.](?:src|source|orig))?"..
		"\\.(?:tar|t[bglx]z|tbz2|zip)"..
		"\\b"
	)

	-- TODO: factor mathcing logic in helper
	local latest = self.pkg.pkgver or "0"
	for v in rex.gmatch(data, r) do
		if v ~= nil and apk.version_compare(v, latest) == ">" then
			latest = v
		end
	end

	if latest == self.pkg.pkgver then
		latest = nil
	end

	return latest
end

function M.init(pkg)
	for source in pkg:remote_sources() do
		-- TODO: support foo.tar:: prefix
		if string.match(source, "^http://") then
			return {
				provider_name = "generic",
				find_newer = find_newer,
				pkg = pkg,
				source = source
			}
		end
	end
	return nil
end

return M
