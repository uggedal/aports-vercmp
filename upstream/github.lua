

json = require("cjson")
ml = require("ml")
apk = require("apk")
curl = require("lcurl")

local M = {}

local function fetch_url(url)
	local result = ""
	local c = curl.easy()
		:setopt_url(url)
		:setopt_writefunction(
			function(data)
				result=result..data
				return true
			end)
		:setopt(curl.OPT_FOLLOWLOCATION, true)
		:perform()
	local status = c:getinfo(curl.INFO_RESPONSE_CODE)
	c:close()
	return result, status
end


--[[
github api only lets us only do 60 requests per hour, and potensially
5000 if we register an application key. Instead of messing with oauth
we simply parse the html for now
local function find_newer(self)
	local tagsurl = ("https://api.github.com/repos/%s/tags"):format(self.project)
	print(("DEBUG: %s: github: %s"):format(self.pkg.pkgname, self.project))
	local jsondata, status = assert(https.request(tagsurl))
	local t
	if jsondata then
		t = json.decode(jsondata)
	end
	if status ~= 200 then
		print(("github api error: %i\n  url: %s\n  message: %s\n  doc: %s\n"):format(status, tagsurl, t.message, t.documentation_url))
		return nil
	end
	local latest = oldver or "0"
	for k,v in pairs(t) do
		print("DEBUG: github:", k, v.name)
		if apk.version_compare(k, latest) == ">" then
			latest = k
		end
	end
	if latest == oldver then
		latest = nil
	end
	return latest
end
]]--

local function find_newer(self)
	local releasesurl = ("https://github.com/%s/releases"):format(self.project)
--[[
	print(("DEBUG: %s: github: %s: %s"):format(self.pkg.pkgname,
		self.project, releasesurl))
--]]
	local data, status = fetch_url(releasesurl)
	assert (status == 200)
	local latest = self.pkg.pkgver
	for v in string.gmatch(data, ('a href="/%s/archive/v?([0-9a-z._-]+)%%.tar.gz"'):format(self.project)) do
		for _,s in pairs{
				{search="-rc", replace="_rc"},
				{search="-beta", replace="_beta"},
				{search="-alpha", replace="_alpha"},
			} do
			v = string.gsub(v, s.search, s.replace)
		end
		if apk.version_validate(v) then
			if apk.version_compare(v, latest) == ">" then
				latest = v
			end
		else
			print("INVALID version:", v)
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
				project = project,
			}
		end
	end
	return nil
end

return M
