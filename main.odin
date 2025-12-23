package main

import "core:fmt"
import "collections"


main :: proc() {
    using collections
    my_list := new(i32)
    defer delete(&my_list)
    for i in 0..<10 {
        i_i32 := i32(i + 1)
        err := push_back(&my_list, i_i32)
        if (err != nil) {
            fmt.println("oops!, error: ", err)
        }
    }
    erase(&my_list, 5)
    erase_back(&my_list)
    erase_front(&my_list)
    push_back(&my_list, 20)
    for i in 0..<size(&my_list) {
        i_usize := usize(i)
        fmt.println("Element: ", i, ": ", at(&my_list, i_usize) or_else -1)
    }
}
