--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>

This content is released under the MIT License.
--]]


module(..., package.seeall)

require("apk")
require("download")

local pkg_list_file = "upstream.list"

local url_alias = {
	["SF-DEFAULT"] = "http://sourceforge.net/api/file/index/project-name/%s/mtime/desc/limit/20/rss",
	["FM-DEFAULT"] = "http://freshmeat.net/projects/%s",
	["GNU-DEFAULT"] = "http://ftp.gnu.org/gnu/%s/",
	["CPAN-DEFAULT"] = "http://search.cpan.org/dist/%s/",
	["HACKAGE-DEFAULT"] = "http://hackage.haskell.org/packages/archive/%s/",
	["DEBIAN-DEFAULT"] = "http://ftp.debian.org/debian/pool/main/first-char-of-%s/%s/",
	["GOOGLE-DEFAULT"] = "http://code.google.com/p/%s/downloads/list",
	["PYPI-DEFAULT"] = "http://pypi.python.org/packages/source/first-char-of-%s/%s",
	["LP-DEFAULT"] = "https://launchpad.net/%s/+download",
	["GNOME-DEFAULT"] = "http://download.gnome.org/sources/%s/*/",
}

local version_regex = {
	["DEFAULT"] =	function(name)
				return "%A"..name.."[-_](%d+[^-/_%s]*?).tar."
			end,
}

local version_replace = {
	["%.[pP](%d+)$"] = "_p%1",
	["([^_])p(%d+)$"] = "%1_p%2",
	["%.([a-z])$"] = "_%1",
	["(%d)[Rr][Cc](%d+)"] = "%1_rc%2",
	["(%d)b(%d+)$"] = "%1_beta%2",
}


local function fix_version(ver)
	local search, replace
	local str = ver
	for search, replace in pairs(version_regex) do
		str = string.gsub(str, search, replace)
	end
	return str
end

local function read_list_file()
	local db = {}
	local line
	local f = io.open(pkg_list_file)
	if f == nil then
		return nil
	end
	for line in f:lines() do
		local name = nil
		local pkgname, regex, url = string.match(line, "(.*)%s+(.*)%s+(.*)")
		if regex then
			local re, name = string.match(regex, "(.*):(.*)")
			if re then
				regex = re
			end
		end
		if name == nil then
			name = pkgname
		end
		if pkgname ~= nil then
			db[pkgname] = {
				["regex"] = regex,
				["url"] = url,
				["name"] = name,
			}
		end
		print(pkgname, regex, url, name)
	end
	f:close()
	return db
end

local function find_newer(self, pkg)
	local p = self.db[pkg]
	if p == nil then
		--log_missing(pkg)
		return nil
	end
	local url = string.format(p.url, p.name)
	print("Searching upstream version of "..pkg.."...")
	local buf = download.get(url)
	io.stdout:write(buf)
end

function Init()
	local i, repo
	local handle = {}
	handle.db = read_list_file()
	if handle.db == nil then
		return nil
	end
	handle.find_newer = find_newer
	handle.exists = exists
	return handle
end

