package main

import "core:fmt"
import "core:os"
import "core:slice"

PrintHelp :: proc() {
	str := `
                          [ omake ]
--------------------------------------------------------------
$CONFIG              - $HOME/.config/omake
$TEMPLATES           - Defaults to ~/.config/omake/templates
$NAME                - Refers to the template name, when made
$K / $V              - Refers to keyword and replacement value

-l | list [-k/key]   - List template names / key names
-n | name            - Override template $NAME
-k | key  <$K & $V>  - Set keyword value, requires $K and $V
`
	fmt.print(str)
}

main :: proc() {

	// Ptr - Holds path strings needed throughout entire execution
	paths := Paths_Init()
	defer Paths_Delete(paths)

	// Ptr - Holds config data once its been loaded and unmarshalled
	config := Config_Data_Create()
	defer Config_Data_Delete(config)

	// Ptr - Abstraction for managing the creation/loading of the config file
	cfile := CFile_Create(Config_Data, paths.config, config, Config_Data{})
	defer CFile_Delete(cfile)

	Config_File_Create(cfile)
	Config_Load_File(cfile)

	// Ptr - Inits with the contents of the Paths[template] directory
	templates := Template_Directory_Data_Create()
	Template_Directory_Init(templates, paths)
	defer Template_Directory_Data_Delete(templates)


	validTemplateNames := make([dynamic]string)
	defer delete(validTemplateNames)

	// Collect validTemplateNames
	if len(templates.data) == 0 {
		fmt.eprintf("Found 0 templates. You can create some here: %s", paths.template)
		os.exit(1)
	} else {
		for entry in templates.data {
			append(&validTemplateNames, entry^.name)
		}
	}

	// Stores valid template names, collected when parsing args
	inputTemplateNames := make([dynamic]string)
	defer delete(inputTemplateNames)

	// Stores valid keyword entries, collected when parsing args
	inputKeywords := make([dynamic]Config_Keyword)
	defer delete(inputKeywords)


	// Parse Args
	if len(os.args) == 1 {
		fmt.eprintln(
			"Missing the required template name(s). Use 'omake help' for more information",
		)
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
			if al + 1 < len(args) {
				switch (args[al + 1]) {
				case "-k", "--key", "key":
					if len(config.custom_keywords[:]) == 0 {
						fmt.eprintfln("No Keywords, you can create some here: %s", paths.config)
						os.exit(1)
					}

					fmt.print("Valid Keys\n__________\n")
					for n in config.custom_keywords[:] {
						fmt.println(n)
					}
					os.exit(0)
				case:
					fmt.eprintln("Invalid option for list. Use 'omake help' for more information.")
					os.exit(1)
				}
			}

			fmt.print("Valid Names\n___________\n")
			for n in validTemplateNames {
				fmt.println(n)
			}
			os.exit(0)

		case "-k", "--key", "key":
			if al + 2 >= len(args) {
				fmt.eprintln("Requires a key and value to be provided")
				os.exit(1)
			}
			if !slice.contains(config.custom_keywords[:], args[al + 1]) {
				fmt.eprintfln(
					"Invalid keyword provided, you can add keywords via the custom_keywords array: %s",
					paths.config,
				)
				os.exit(1)
			}
			append(&inputKeywords, Config_Keyword{key = args[al + 1], value = args[al + 2]})
			al += 2

		case "-n", "--name", "name":
			if al + 1 >= len(args) {
				fmt.eprintln("Requires a name to be provided")
				os.exit(1)
			}
			templates.override_name = args[al + 1]
			al += 1

		case:
			if slice.contains(validTemplateNames[:], args[al]) {
				append(&inputTemplateNames, args[al])
			} else {
				fmt.eprintf(
					"Invalid argument: %s\nUse 'omake list' to see valid template names\n",
					args[al],
				)
				os.exit(1)
			}
		}

		al += 1
	}


	switch (len(inputTemplateNames)) {
	case 0:
		fmt.eprintln("Expected template name(s) - Use 'omake help' for more information")
		os.exit(1)
	case 1:
		Template_Copy(
			inputTemplateNames[:],
			templates,
			paths,
			&inputKeywords,
			config,
			inputTemplateNames[0],
			true,
		)

	case:
		if templates.override_name != "" {
			fmt.printfln("Name override can only be used when creating individual templates")
			os.exit(1)
		}

		for name in inputTemplateNames {
			Template_Copy(
				inputTemplateNames[:],
				templates,
				paths,
				&inputKeywords,
				config,
				name,
				false,
			)
		}
		os.exit(0)
	}

}
