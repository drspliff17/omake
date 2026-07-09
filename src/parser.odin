package main

import "core:fmt"
import "core:os"
import "core:strings"

// Parses given template entry, with given array of config keywords, returns the subbed file data in bytes
ParseTemplate_File :: proc(
	t: ^Template_Entry,
	ck: ^[dynamic]Config_Keyword,
) -> (
	new_data: [dynamic]byte,
	was_sub: bool,
) {
	data, err := os.read_entire_file_from_path(t.path, context.allocator)
	if err != nil do fmt.panicf("Failed to read data from file: %s :: %v", t.path, err)
	defer delete(data, context.allocator)

	it := string(data)

	for line in strings.split_lines_iterator(&it) {
		new_line := line

		for pair in ck {
			keyF := strings.concatenate([]string{"{{", pair.key, "}}"}, context.allocator)
			if strings.contains(new_line, keyF) {
				new_line, _ = strings.replace_all(new_line, keyF, pair.value)
				was_sub = true
			}
			delete_string(keyF)
		}

		append(&new_data, new_line)
		append(&new_data, "\n")
	}

	return new_data, was_sub
}


// Read contents of in_path, parses each file found, and calls self recursively for any dirs found
ProcessDirectory :: proc(
	in_path: string,
	out_path: string,
	templates: ^Template_Directory_Data,
	config_keywords: ^[dynamic]Config_Keyword,
	exitOnCopy: bool,
) {

	entries, err := os.read_all_directory_by_path(in_path, context.allocator)
	if err != nil do fmt.panicf("Failed to read dir: %s :: %v", in_path, err)
	defer delete(entries, context.allocator)

	mkdir_err := os.make_directory_all(out_path)
	if mkdir_err != nil do fmt.panicf("Failed to create output directory: %v", mkdir_err)

	for entry in entries {
		src, _ := os.join_path([]string{in_path, entry.name}, context.allocator)
		dst, _ := os.join_path([]string{out_path, entry.name}, context.allocator)
		defer delete_string(src)
		defer delete_string(dst)

		#partial switch entry.type {

		case .Directory:
			ProcessDirectory(src, dst, templates, config_keywords, exitOnCopy)

		case .Regular:
			t: Template_Entry = {
				path = src,
				name = entry.name,
			}

			file_data, changed := ParseTemplate_File(&t, config_keywords)
			defer delete(file_data)

			write_err := os.write_entire_file_from_bytes(dst, file_data[:])
			if write_err != nil do fmt.panicf("Failed to write file: %s :: %v", dst, write_err)

			chmod := os.chmod(dst, {.Execute_User, .Write_User, .Read_User})
			if chmod != nil do fmt.panicf("Failed to chmod")

			fmt.printfln("Processed: %s -> %s (changed=%v)", src, dst, changed)
		}

		if exitOnCopy do os.exit(0)
	}
}
