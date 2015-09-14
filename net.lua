--[[
Copyright (c) 2015 Natanael Copa <ncopa@alpinelinux.org>
Copyright (c) 2015 Eivind Uggedal <eivind@uggedal.com>

This content is released under the MIT License.
--]]

local curl = require("lcurl")

local M = {}

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
	return result, status
end

return M
