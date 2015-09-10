https = require("ssl.https")
apk = require("apk")

local M = {}

local function find_newer(self)
	local releasesurl = ("https://github.com/%s/releases"):format(self.project)
	dbg(("%s: github: fetching %s"):format(self.pkg.pkgname, self.project))
	local data, status = https.request(releasesurl)
	if data == nil then
		io.stderr:write("ERROR: " .. status .. "\n")
		return
	end

	local latest = self.pkg.pkgver
	for v in string.gmatch(data, ('a href="/%s/archive/v?([0-9a-z._-]+)%%.tar.gz"'):format(self.project)) do
		for _,s in pairs{
				{search="-rc", replace="_rc"},
				{search="-beta", replace="_beta"},
				{search="-alpha", replace="_alpha"},
			} do
			v = string.gsub(v, s.search, s.replace)
		end
		if apk.version_compare(v, latest) == ">" then
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
		local project  = string.match(source,
			".*::https://github.com/(.*)/archive/")
		if project  then
			return {
				provider_name = "github",
				find_newer = find_newer,
				pkg = pkg,
				project = project
			}
		end
	end
	return nil
end

return M
