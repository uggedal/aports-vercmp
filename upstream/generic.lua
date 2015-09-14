--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

http = require("socket.http")
rex = require("rex_pcre")

local M = {}

local function versions(self)
	local vers = {}

	local baseurl = (string.gsub(self.source, "[^/]+$", ""))

	dbg(("%s: generic: fetching %s"):format(self.pkg.pkgname, baseurl))

	-- TODO: factor fetching logic in helper with support for
	--       several formats
	local data, status = http.request(baseurl)
	if data == nil then
		io.stderr:write("ERROR: " .. status .. "\n")
		return vers
	end

	local r = rex.new(
		self.pkg.pkgname..
		"(?:[-_]?(?:src|source))?"..
		"[-_]"..
		"([^-/_\\s]+?)"..
		"(?i)"..
		"(?:[-_](?:src|source|asc|orig))?"..
		"\\.(?:tar|t[bglx]z|tbz2|zip)"
	)

	for v in rex.gmatch(data, r) do
		table.insert(vers, v)
	end

	return vers
end

function M.init(pkg)
	for source in pkg:remote_sources() do
		-- TODO: support foo.tar:: prefix
		if string.match(source, "^http://") then
			return {
				provider_name = "generic",
				versions = versions,
				pkg = pkg,
				source = source
			}
		end
	end
	return nil
end

return M
