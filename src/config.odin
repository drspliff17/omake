package main

import "core:fmt"


Config_Data :: struct {}

// Constructor
Config_Data_Create :: proc() -> ^Config_Data {
	c, err := new(Config_Data)
	if err != nil do fmt.panicf("Failed to allocate [Config_Data]: %v", err)
	return c
}

// Deconstructor
Config_Data_Delete :: proc(c: ^Config_Data) {
	free(c)
}
