package main

import "core:fmt"

// Created from arguments passed to omake, maps valid Config_Data{custom_keywords} entry to given value
Config_Keyword :: struct {
	key:   string,
	value: string,
}

Config_Data :: struct {
	custom_keywords: [dynamic]string,
}

// Constructor
Config_Data_Create :: proc() -> ^Config_Data {
	c, err := new(Config_Data)
	if err != nil do fmt.panicf("Failed to allocate [Config_Data]: %v", err)
	c.custom_keywords = make([dynamic]string)
	return c
}

// Deconstructor
Config_Data_Delete :: proc(c: ^Config_Data) {
	delete(c.custom_keywords)
	free(c)
}
