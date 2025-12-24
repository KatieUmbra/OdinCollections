package main

import cl "collections"
import "core:fmt"
import "core:mem"

main :: proc() {
	// Checking for memory leaks
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)
	defer {
		if len(track.allocation_map) > 0 {
			fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
			for _, entry in track.allocation_map {
				fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
			}
		}
		mem.tracking_allocator_destroy(&track)
	}
	// Initializing the list
	my_list := cl.new(i32)
	defer cl.delete(&my_list)
	// Adding elements to the list
	for i in 0 ..< 10 {
		i_i32 := i32(i + 1)
		err := cl.push_back(&my_list, i_i32)
		if (err != nil) {
			fmt.println("oops!, error: ", err)
		}
	}
	// Trying list methods
	cl.erase(&my_list, 5)
	cl.erase_back(&my_list)
	cl.erase_front(&my_list)
	cl.push_back(&my_list, 20)
	cl.for_each(&my_list, proc(it: ^i32) {it^ += i32(10)})
	filtered := cl.filter(&my_list, proc(it: ^i32) -> bool {return it^ % 2 == 0})
	fmt.println("=============")
	fmt.println("Filtering:\n=============")
	defer delete(filtered)
	for it in filtered {
		fmt.println("Filtered: ", it^)
	}
	fmt.println("=============")
	fmt.println("Elements:\n=============")
	cl.for_each(&my_list, proc(it: ^i32) {fmt.println("Element: ", it^)})
	fmt.println("=============")
	cl.zero(&my_list)
	fmt.println("Zeroed:\n=============")
	cl.for_each(&my_list, proc(it: ^i32) {fmt.println("Element: ", it^)})
	fmt.println("=============")
	cl.clear(&my_list)
	fmt.println("Cleared:\n=============")
	cl.for_each(&my_list, proc(it: ^i32) {fmt.println("Element: ", it^)})
	fmt.println("=============")
}

