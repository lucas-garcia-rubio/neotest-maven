local lib = require("neotest.lib")
local filetype = require("plenary.filetype")
local position_queries = require("neotest-maven.position_queries")
local printTable = require("neotest-maven.utils.print-table").printTable

--- See Neotest adapter specification.
---
--- It uses the Neotest provided utilities to run Treesitter queries. These
--- queries find (nested) test classes as Neotest namespaces and test functions
--- as Neotest tests. Other positions like "file" and "dir" are not supported
--- and are handled differently during execution.
---
--- Referred context functions help to provide good readable test names for UI
--- and construct test identifiers based on Java paths used during execution.
---
--- @param path string - absolute file path
--- @return nil | table | table[] - see neotest.Tree
return function(path)
	local file_type = filetype.detect(path)
	local position_query = position_queries[file_type]

	local returnable = lib.treesitter.parse_positions(path, position_query, {
		--nested_tests = true,
		--require_namespaces = true,
		build_position = 'require("neotest-maven.hooks.discover_positions.build_position")',
		position_id = 'require("neotest-maven.hooks.discover_positions.build_position_identifier")',
	})

	-- TODO: implementar logging level

	return returnable
end
