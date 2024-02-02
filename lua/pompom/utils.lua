local PomPomUtils = {}

--- @param str string
--- @param separator string
--- @return string[]
function PomPomUtils.split(str, separator)
	if separator == nil then
		separator = "%s"
	end

	local out = {}

	for group in string.gmatch(str,"([^"..separator.."]+)") do
		table.insert(out, group)
	end
	return out
end


--- @param str string
--- @return boolean
function PomPomUtils.is_whitespace(str)
	return string.gsub(str,"%s","") == ""
end

--- @param str string
--- @return string
function PomPomUtils.trim(str)
	return str:gsub("^%s+",""):gsub("%s+$","")
end

--- @param str string
--- @return string
function PomPomUtils.remove_duplicate_whitespace(str)
	return str:gsub("%s+"," ")
end

--- @param str string
--- @return string
function PomPomUtils.to_escaped_str(str)
	return str:gsub("(%W)","%%%1")
end

return PomPomUtils
