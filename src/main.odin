package main

import "core:fmt"
import "core:os"
import "core:slice"


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

	validNames: [dynamic]string
	defer delete(validNames)

	if len(templates.data) == 0 {
		fmt.eprintf("No templates. You can create some here: %s", paths.template)
		os.exit(1)
	} else {
		for entry in templates.data {
			append(&validNames, entry.name)
		}
	}

	selectedTemplates: [dynamic]string
	defer delete(selectedTemplates)

	// Run
	if len(os.args) == 1 {
		fmt.eprintln("Expected template name(s)")
		os.exit(1)
	}

	args := os.args[1:]
	al := 0
	for al < len(args) {

		switch (args[al]) {
		case "-l", "--list", "list":
			fmt.print("Valid Names\n")
			for n in validNames {
				fmt.printfln("%s", n)
			}
			os.exit(0)

		case:
			if slice.contains(validNames[:], args[al]) {
				append(&selectedTemplates, args[al])
			} else {
				fmt.eprintf(
					"Invalid argument: %s\nValid template names:\n%v\n",
					args[al],
					validNames[:],
				)
				os.exit(1)
			}
		}

		al += 1
	}


	switch (len(selectedTemplates)) {
	case 0:
		fmt.eprintln("Expected template name(s)")
		os.exit(1)
	case 1:
		Template_Copy(selectedTemplates[:], templates, paths, selectedTemplates[0], true)

	case:
		for name in selectedTemplates {
			Template_Copy(selectedTemplates[:], templates, paths, name, false)
		}
		os.exit(0)
	}

}
