package main

import "core:fmt"
import "core:os"

Template_Type :: enum {
	FILE,
	DIRECTORY,
}

Template_Entry :: struct {
	type: Template_Type,
	path: string,
	name: string,
}

Template_Directory_Data :: struct {
	data:          [dynamic]^Template_Entry,
	override_name: string,
}

Get_Template_From_Valid_Name :: proc(n: string, t: ^Template_Directory_Data) -> ^Template_Entry {
	for e in t.data {
		if e.name == n do return e
	}
	fmt.panicf("Invalid name, you spoon: %s", n)
}

// Constructor
Template_Entry_Create :: proc() -> ^Template_Entry {
	t, err := new(Template_Entry)
	if err != nil do fmt.panicf("Failed to allocate [Template_Entry]: %v", err)
	return t
}

// Destructor
Template_Entry_Delete :: proc(t: ^Template_Entry) {
	free(t)
}

// Constructor
Template_Directory_Data_Create :: proc() -> ^Template_Directory_Data {
	t, err := new(Template_Directory_Data)
	if err != nil do fmt.panicf("Failed to allocate [Template_Directory_Data]: %v", err)
	return t
}

// Destructor
Template_Directory_Data_Delete :: proc(t: ^Template_Directory_Data) {
	for entry in t.data do Template_Entry_Delete(entry)
	free(t)
}

// Fill Template_Directory_Data.data with contents of paths.templates
Template_Directory_Init :: proc(t: ^Template_Directory_Data, p: ^Paths) {
	dir_contents, read_dir_err := os.read_all_directory_by_path(p.template, context.allocator)
	defer delete_slice(dir_contents)
	if read_dir_err != nil do fmt.panicf("Failed to read directory: %v", read_dir_err)

	for c in dir_contents {
		e := Template_Entry_Create()
		#partial switch (c.type) {
		case .Regular:
			e^.type = .FILE

		case .Directory:
			e^.type = .DIRECTORY
		}

		e^.path = c.fullpath
		e^.name = c.name
		append(&t.data, e)
	}
}

Template_Copy :: proc(
	selectedTemplates: []string,
	templates: ^Template_Directory_Data,
	paths: ^Paths,
	name: string,
	exitOnCopy: bool,
) {
	entry := Get_Template_From_Valid_Name(name, templates)
	if entry.type == .FILE {

		epath: string = templates.override_name != "" ? templates.override_name : entry.name
		p, perr := os.join_path([]string{paths.cwd, epath}, context.allocator)
		if perr != nil do fmt.panicf("Could not allocate template destination string: %s", p)

		err := os.copy_file(p, entry.path)
		if err != nil do fmt.panicf("Failed to copy template: %s to %s :: %v", entry.path, p, err)
		fmt.printfln("Created: [%s] %s -> %s", entry.type, epath, entry.path)
		if exitOnCopy do os.exit(0)

	} else {

		epath: string = templates.override_name != "" ? templates.override_name : entry.name
		p, perr := os.join_path([]string{paths.cwd, epath}, context.allocator)
		if perr != nil do fmt.panicf("Could not allocate template destination string: %s", p)

		err := os.copy_directory_all(p, entry.path)
		if err != nil do fmt.panicf("Failed to copy template: %s to %s :: %v", entry.path, p, err)
		fmt.printfln("Created: [%s] %s -> %s", entry.type, epath, entry.path)
		if exitOnCopy do os.exit(0)

	}

}
