--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local curl = require("lcurl")

local M = {}

local function status_ok(url, status)
	if string.match(url, "^https?://") then
		return status == 200
	elseif string.match(url, "^ftp://") then
		return status == 226
	end
	return false
end

function M.supported(url)
	return string.match(url, "^https?://") or
		string.match(url, "^ftp://")
end

function M.fetch(url)
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

	local ok = status_ok(url, status)
	if not ok then
		io.stderr:write("ERROR: " .. status .. "\n")
	end
	return result, ok
end

return M
