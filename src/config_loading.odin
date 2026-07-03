package main

import "core:encoding/json"
import "core:fmt"
import "core:os"

CFile :: struct(T: typeid) {
	filepath: string,
	default:  T,
	target:   ^T,
}

// Constructor for CFile
CFile_Create :: proc($T: typeid, filepath: string, target: ^T, default: T) -> ^CFile(T) {
	cfile, cfile_err := new(CFile(T))
	if cfile_err != nil do fmt.panicf("Failed to create CFile: %v", cfile_err)

	cfile.filepath = filepath
	cfile.target = target
	cfile.default = default

	return cfile
}

CFile_Delete :: proc(c: ^CFile) {
	free(c)
}

// Returns true if new (values = c.default) is created, bool is false
Config_File_Create :: proc(c: ^CFile($T)) -> bool {
	if os.exists(c.filepath) {
		return false
	}

	config_dir := os.dir(c.filepath)
	if !os.exists(config_dir) {
		err := os.make_directory(config_dir)
		if err != nil do fmt.panicf("Failed to create config directory: %v", err)
		fmt.printfln("Created config directory at: %s", config_dir)
	}

	templates_dir, templates_err := os.join_path(
		[]string{config_dir, "templates"},
		context.allocator,
	)
	defer delete_string(templates_dir)
	if templates_err != nil do fmt.panicf("Failed to allocate config template directory string: %v", templates_err)
	if !os.exists(templates_dir) {
		err := os.make_directory(templates_dir)
		if err != nil do fmt.panicf("Failed to create template directory: %v", err)
		fmt.printfln("Created config/templates directory")
	}

	json_text, err := json.marshal(c.default, allocator = context.allocator)
	if err != nil {
		fmt.panicf("Failed to marshal default config: %v", err)
	}

	werr := os.write_entire_file(c.filepath, json_text)
	if werr != nil {
		fmt.panicf("Failed to write default config: %v", werr)
	}

	fmt.printfln("Created default config file at: %s", c.filepath)
	return true
}

Config_Load_File :: proc(c: ^CFile($T)) -> bool {
	if c.target == nil {
		panic("Target to unmarshal unset")
	}

	data, err := os.read_entire_file(c.filepath, context.allocator)
	if err != nil {
		panic("Error when attempting to read config file")
	}

	ok := json.unmarshal(data, c.target) == nil
	if ok {
		fmt.println("Loaded Config")
	}
	return ok
}
