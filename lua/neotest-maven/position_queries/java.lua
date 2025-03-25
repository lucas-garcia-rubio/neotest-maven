local class_with_name_ending_on_test = [[
    (
      (class_declaration name: (identifier) @namespace.name)
      (#match? @namespace.name "Test$")
    ) @namespace.definition
  ]]

local method_with_parameterized_test_annotation = [[
    (
      (method_declaration
        (modifiers (marker_annotation name: (identifier) @parameterized_test_marker.identifier))
        name: (identifier) @test.name
      )
      (#eq? @parameterized_test_marker.identifier "ParameterizedTest")
    ) @test.definition
  ]]

local class_with_name_ending_on_test_it = [[
    (
      (class_declaration name: (identifier) @namespace.name)
      (#match? @namespace.name "IT$")
    ) @namespace.definition
  ]]

local class_with_nested_annotation = [[
  (
    (class_declaration
      (modifiers (marker_annotation name: (identifier) @nested_marker.identifier))
      name: (identifier) @namespace.name
    )
    (#eq? @nested_marker.identifier "Nested")
  ) @namespace.definition
]]

local class_with_name_ending_on_tests = [[
    (
      (class_declaration name: (identifier) @namespace.name)
      (#match? @namespace.name "Tests$")
    ) @namespace.definition
  ]]

local method_with_test_marker = [[
    (
      (method_declaration
        (modifiers (marker_annotation name: (identifier) @test_marker.identifier))
        name: (identifier) @test.name
      )
      (#eq? @test_marker.identifier "Test")
    ) @test.definition
  ]]

local method_with_test_marker_and_display_name_annotation = [[
    (
      (method_declaration
        (modifiers
          (marker_annotation name: (identifier) @test_marker.identifier)
          (annotation
            name: (identifier) @display_name.identifier
            arguments: (annotation_argument_list (string_literal (string_fragment) @display_name.value))
          )
        )
        name: (identifier) @test.name
      )
      (#eq? @test_marker.identifier "Test")
      (#eq? @display_name.identifier "DisplayName")
    ) @test.definition
  ]]

-- Remind the order of the queries as first listed has higher priority.
return class_with_name_ending_on_test
	.. class_with_name_ending_on_test_it
	--.. class_with_name_ending_on_tests
	--.. method_with_test_marker_and_display_name_annotation
	.. method_with_test_marker
	.. method_with_parameterized_test_annotation
	.. class_with_nested_annotation
