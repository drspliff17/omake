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
}

Template_Directory_Data :: struct {
	data: [dynamic]^Template_Entry,
}

Template_Entry_Create :: proc() -> ^Template_Entry {
	t, err := new(Template_Entry)
	if err != nil do fmt.panicf("Failed to allocate [Template_Entry]: %v", err)
	return t
}

Template_Entry_Delete :: proc(t: ^Template_Entry) {
	free(t)
}

Template_Directory_Data_Create :: proc() -> ^Template_Directory_Data {
	t, err := new(Template_Directory_Data)
	if err != nil do fmt.panicf("Failed to allocate [Template_Directory_Data]: %v", err)
	return t
}

Template_Directory_Data_Delete :: proc(t: ^Template_Directory_Data) {
	for entry in t.data do Template_Entry_Delete(entry)
	free(t)
}

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
		append(&t.data, e)
	}
}

// Test_Template_Directory_Data :: proc() {
// 	d := "/home/drspliff/.config/omake/templates"
// 	dir, err := os.read_all_directory_by_path(d, context.allocator)
// 	defer delete_slice(dir)
// 	if err != nil do fmt.panicf("Failed to read dir: %s :: %v", dir, err)
// 	for f in dir {
// 		fmt.printfln("Found: %s, type: %v", f.fullpath, f.type)
// 	}
// }
