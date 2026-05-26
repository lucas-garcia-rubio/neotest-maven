return {
	name = "neotest-maven",
	root = require("neotest-maven.hooks.find_project_directory"),
	is_test_file = require("neotest-maven.hooks.is_test_file"),
	discover_positions = require("neotest-maven.hooks.discover_positions"),
	build_spec = require("neotest-maven.hooks.build_run_specification"),
	results = require("neotest-maven.hooks.collect_results"),
}
