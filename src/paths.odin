package main

import "core:fmt"
import "core:os"
import "core:strings"

Paths :: struct {
	home:     string,
	config:   string,
	template: string,
}

// Paths constructor
Paths_Create :: proc() -> ^Paths {
	p, err := new(Paths)
	if err != nil do fmt.panicf("Failed to allocate [Paths]: %v", err)
	return p
}

// Paths deconstructor
Paths_Delete :: proc(p: ^Paths) {
	delete_string(p.home)
	delete_string(p.config)
	delete_string(p.template)
	free(p)
}

// Calls constructor, then inits member fields
Paths_Init :: proc() -> ^Paths {
	p := Paths_Create()

	home, home_err := os.user_home_dir(context.allocator)
	defer delete_string(home)
	if home_err != nil do fmt.panicf("Failed to allocate user home path string: %v", home_err)

	config, config_err := os.join_path(
		[]string{home, ".config", "omake", "config.json"},
		context.allocator,
	)
	defer delete_string(config)
	if config_err != nil do fmt.panicf("Failed to allocate config path string: %v", config_err)

	template, template_err := os.join_path(
		[]string{home, ".config", "omake", "templates"},
		context.allocator,
	)
	defer delete_string(template)
	if template_err != nil do fmt.panicf("Failed to allocate template path string: %v", template_err)

	p.home = strings.clone(home, context.allocator)
	p.config = strings.clone(config, context.allocator)
	p.template = strings.clone(template, context.allocator)
	return p
}
