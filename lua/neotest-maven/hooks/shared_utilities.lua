local lib = require("neotest.lib")

-- TODO: How to improve using Treesitter or similar?
--- @param file_path string
local function get_package_name(file_path)
	print("executando shared_utilities")
	local first_line = lib.files.read_lines(file_path)[1]
	return (first_line:gsub("^package ", ""):gsub(";", ""))
end

return {
	get_package_name = get_package_name,
}
