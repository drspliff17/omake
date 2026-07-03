package main

//TODO:
// Link some config based system into a custom override, where you give the template name, the target (ie. '{thing}' ) and the new
// replacement, as a variable or something, that could be either hard coded into the config, or set directly with a argument i.e.
// omake -n some_project -s thing=hello odin -> to substitute the '{thing}' to 'hello'

import "core:fmt"
import "core:os"
import "core:slice"

PrintHelp :: proc() {
	str := `
                    [ omake ]
----------------------------------------------------
$TEMPLATES  - Defaults to ~/.config/omake/templates
$NAME       - Refers to the template name, when made

-l | list   - Displays valid names inside $TEMPLATES
-n | name   - Override template $NAME

`
	fmt.print(str)
}

main :: proc() {
	paths := Paths_Init()
	defer Paths_Delete(paths)

	config := Config_Data_Create()
	defer Config_Data_Delete(config)

	cfile := CFile_Create(Config_Data, paths.config, config, Config_Data{})
	defer CFile_Delete(cfile)

	// NOTE: Temp removed
	// Config_File_Create(cfile)
	// Config_Load_File(cfile)

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
		fmt.eprintln("Expected template name(s). Use 'omake help' for more information")
		os.exit(1)
	}

	args := os.args[1:]
	al := 0
	for al < len(args) {

		switch (args[al]) {
		case "-h", "--help", "help":
			PrintHelp()
			os.exit(0)

		case "-l", "--list", "list":
			fmt.print("Valid Names\n")
			for n in validNames {
				fmt.printfln("%s", n)
			}
			os.exit(0)

		case "-n", "--name", "name":
			if al + 1 >= len(args) {
				fmt.eprintln("Requires a name to be provided")
				os.exit(1)
			}
			templates.override_name = args[al + 1]
			al += 1

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
		fmt.eprintln("Expected template name(s) - Use 'omake help' for more information")
		os.exit(1)
	case 1:
		Template_Copy(selectedTemplates[:], templates, paths, selectedTemplates[0], true)

	case:
		if templates.override_name != "" {
			fmt.printfln("Name override can only be used on individual templates")
			os.exit(1)
		}

		for name in selectedTemplates {
			Template_Copy(selectedTemplates[:], templates, paths, name, false)
		}
		os.exit(0)
	}

}
