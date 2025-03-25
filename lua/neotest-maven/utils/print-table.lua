local function printTable(t, indent)
	indent = indent or 0
	local formatting = string.rep("  ", indent)
	for k, v in pairs(t) do
		if type(v) == "table" then
			print(formatting .. tostring(k) .. ":")
			printTable(v, indent + 1)
		else
			print(formatting .. tostring(k) .. ": " .. tostring(v))
		end
	end
end

return {
	printTable = printTable,
}
