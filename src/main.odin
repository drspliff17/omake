package main

import "core:fmt"

main :: proc() {
	// Init Paths
	paths := Paths_Init()
	defer Paths_Delete(paths)

	// Init / Load Config
	config := Config_Data_Create()
	defer Config_Data_Delete(config)

	cfile := CFile_Create(Config_Data, paths.config, config, Config_Data{})
	defer CFile_Delete(cfile)

	Config_File_Create(cfile)
	Config_Load_File(cfile)

	templates := Template_Directory_Data_Create()
	Template_Directory_Init(templates, paths)
	defer Template_Directory_Data_Delete(templates)

}
