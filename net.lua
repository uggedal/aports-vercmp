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
	local i = 0
	local result = ""
	local status = 0
	local p_ok, p_err = pcall(function()
		local c = curl.easy()
			:setopt_url(url)
			:setopt_writefunction(
				function(data)
					i = i + 1
					if i >= 100 then
						return false
					end
					result=result..data
					return true
				end)
			:setopt(curl.OPT_FOLLOWLOCATION, true)
			:perform()
		status = c:getinfo(curl.INFO_RESPONSE_CODE)
		c:close()
	end)

	local ok = p_ok and status_ok(url, status) and result ~= nil
	if not ok then
		io.stderr:write("ERROR: " .. status .. "\n")
	end
	return result, ok
end

return M
