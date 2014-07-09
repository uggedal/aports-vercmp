apk = require("apk")

local M = {}
--"http://mirrors.kernel.org/archlinux/"
local url_base="http://ftp.lysator.liu.se/pub/archlinux/"
local upstream_repos = { 
	"core/os/i686/core.db.tar.gz",
	"extra/os/i686/extra.db.tar.gz",
	"community/os/i686/community.db.tar.gz",
}

local db = {}

local pkgmap = {
	["freetype"] = "freetype2",
	["gmp5"] = "gmp",
	["gstreamer" ] = "gstreamer0.10",
	["gstreamer1"] = "gstreamer",
	["gtk+2.0"] = "gtk2",
	["mpfr3"] = "mpfr",
	["python"] = "python2",
	["mpc1" ] = "libmpc",
	[ "libmpc" ] = "",
	["glib" ] = "glib2",
	["libnl3" ] = "libnl",
	["libnl" ] = "",
}

local version_regex = {
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

local function add_version(repodb, pkgname, pkgver, pkgrel)
	if pkgname == nil then
		return
	end
	local name = pkgmap[pkgname]
	if name == nil then
		name = pkgname
	end
	if db[name] == nil then
		db[name] = {}
	end
	table.insert(db[name], {
		repo = repodb,
		origver=pkgver,
		pkgver=fix_version(pkgver),
		pkgrel=pkgrel,
		pkgname=pkgname,
	})
end

local function read_upstream_repodb(repodb)
	local f
	local url = url_base..repodb
	local dbfile = string.gsub(repodb, ".*/", "")
	
	local line
--	os.execute("wget "..url)
--	local f = io.popen("tar -ztf "..dbfile.." 2>/dev/null")
	local f = io.popen("curl --silent "..url.." | tar -zt 2>/dev/null")
	local pkgdb = {}
	for line in f:lines() do
		local pkgname, pkgver, pkgrel = string.match(line, "^(.*)-([0-9]+.*)-([0-9]+)/$")
		add_version(repodb, pkgname, pkgver, pkgrel)
	end
	f:close()
end

local function is_newer(arch, pkgver)
	if not apk.version_is_less(pkgver, arch) then
		return nil
	end
	return arch
--	print(pkgname.."-"..arch.pkgver.." (current: "..pkgver..")")
end

local function find_newer(self)
	local pkgname = self.pkg.pkgname
	local pkgver = self.pkg.pkgver
	local i, p, newest
	if self.db[pkgname] == nil then
		return
	end
	newest = "0"
	for i, p in pairs(self.db[pkgname]) do
		if apk.version_is_less(newest, p.pkgver) then
			newest = p.pkgver
		end
	end
	if is_newer(newest, pkgver) then
		return newest
	end
	return nil
end

local function exists(self, pkgname)
	return self.db[pkgname] ~= nil
end

local repos_initialized = false
local function init_repos()
	if repos_initialized then
		return db
	end
	for i,repo in pairs(upstream_repos) do
		io.stderr:write("Reading upstream "..repo.."\n")
		read_upstream_repodb(repo)
	end
	repos_initialized = true
	return db
end

function M.init(pkg)
	init_repos()
	if db[pkg.pkgname] == nil then
		return nil
	end
	return {
		provider_name = "archlinux",
		db = db,
		find_newer = find_newer,
		pkg = pkg
	}
end


return M
