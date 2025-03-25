local lib = require("neotest.lib")
local find_project_directory = require("neotest-maven.hooks.find_project_directory")
local printTable = require("neotest-maven.utils.print-table").printTable

--- Fiends either an executable file named `gradlew` in any parent directory of
--- the project or falls back to a binary called `gradle` that must be available
--- in the users PATH.
---
--- @return string - absolute path to wrapper of binary name
local function get_maven_executable()
	return "mvn"
end

--- Runs the given Gradle executable in the respective project directory to
--- query the `testResultsDir` property. Has to do so some plain text parsing of
--- the Gradle command output. The child folder named `test` is always added to
--- this path.
--- Is empty is directory could not be determined.
---
--- @param project_directory string | nil
--- @param position table
--- @return string - absolute path of test results directory
local function get_test_results_directory(project_directory, position)
	if position.type == "file" or position.type == "test" then
		local filename = position.path:match("([^/]+)$")
		if filename:find("IT") then
			return project_directory .. "/target/failsafe-reports"
		else
			return project_directory .. "/target/surefire-reports"
		end
	end
	return project_directory .. "/target/failsafe-reports" .. ":" .. project_directory .. "/target/surefire-reports"
end

--- Takes a NeoTest tree object and iterate over its positions. For each position
--- it traverses up the tree to find the respective namespace that can be
--- used to filter the tests on execution. The namespace is usually the parent
--- test class.
---
--- @param tree table - see neotest.Tree
--- @return  table[] - list of neotest.Position of `type = "namespace"`
local function get_namespaces_of_tree(tree)
	local namespaces = {}

	for _, position in tree:iter() do
		if position.type == "namespace" then
			table.insert(namespaces, position)
		end
	end

	return namespaces
end

--- Constructs the additional arguments for the test command to filter the
--- correct tests that should run.
--- Therefore it uses (and possibly repeats) the Gradle test command
--- option `--tests` with the full locator. The locators consist of the
--- package path, plus optional class names and test function name. This value is
--- already attached/pre-calculated to the nodes `id` property in the tree.
--- The position argument defines what the user intended to execute, which can
--- also be a whole file. In that case the paths are unknown and must be
--- collected by some additional logic.
---
--- @param tree table - see neotest.Tree
--- @param position table - see neotest.Position
--- @return string[] - list of strings for arguments
local function get_test_filter_arguments(tree, position)
	local arguments = {}

	if position.type == "test" or position.type == "namespace" then
		vim.list_extend(arguments, { "--tests", "'" .. position.id .. "'" })
	elseif position.type == "file" then
		local namespaces = get_namespaces_of_tree(tree)

		for _, namespace in pairs(namespaces) do
			vim.list_extend(arguments, { "--tests", "'" .. namespace.id .. "'" })
		end
	end

	return arguments
end

--- @param position table
--- @return table
local function build_maven_command(position)
	local command = { get_maven_executable(), "-f", find_project_directory(position.path) .. "/pom.xml", "" }
	if position.type == "file" then
		local filename = position.name
		local classname = filename:gsub("%.java", "")
		if classname:find("IT") then
			table.insert(command, "-Dit.test='" .. classname .. "*'")
			table.insert(command, "failsafe:integration-test")
		else
			table.insert(command, "-Dtest='" .. classname .. "*'")
			table.insert(command, "surefire:test")
		end
		return command
	elseif position.type == "test" then
		local filename = position.path:match("([^/]+)$")
		local classname = filename:gsub("%.java", "")
		local classname_with_test = position.id:match("(" .. classname .. ".*)")
		classname_with_test = classname_with_test:gsub("%.", "$")
		classname_with_test = classname_with_test:gsub("$([^$]*)$", "#%1")

		if classname:find("IT") then
			table.insert(command, "-Dit.test='" .. classname_with_test .. "'")
			table.insert(command, "failsafe:integration-test")
		else
			table.insert(command, "-Dtest='" .. classname_with_test .. "'")
			table.insert(command, "surefire:test")
		end
		return command
	elseif position.type == "dir" then
		table.insert(command, "verify")
		return command
	end

	return {}
end

--- See Neotest adapter specification.
---
--- In its core, it builds a command to start Gradle correctly in the project
--- directory with a test filter based on the positions.
--- It also determines the folder where the resulsts will be reported to, to
--- collect them later on. That folder path is saved to the context object.
---
--- @param arguments table - see neotest.RunArgs
--- @return nil | table | table[] - see neotest.RunSpec[]
return function(arguments)
	local position = arguments.tree:data()
	local command = build_maven_command(position)
	local project_directory = find_project_directory(position.path)

	local context = {}
	context.test_results_directory = get_test_results_directory(project_directory, position)
	local returnable = { command = table.concat(command, " "), context = context }
	print("returnable: ")
	printTable(returnable)
	print("+++++++++++++++++++++")
	return returnable
end
