local find_project_directory = require("neotest-maven.hooks.find_project_directory")

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
	return returnable
end
