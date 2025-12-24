package collections

import "base:builtin"

@(private)
Node :: struct($T: typeid) {
	data: T,
	next: ^Node(T),
}

@(private)
new_Node :: proc(
	data: $T,
	previous: ^Node(T) = nil,
	next: ^Node(T) = nil,
	allocator := context.allocator,
) -> (
	node: ^Node(T),
	error: Error,
) {
	new_node, err := builtin.new(Node(T), allocator)
	if err != nil {
		return nil, Error.Allocation
	}
	if previous == nil {
		new_node.data = data
		new_node.next = next
		return new_node, nil
	}
	if previous.next != nil {
		previous.next = new_node
	}
	new_node.data = data
	new_node.next = next
	return new_node, nil
}

Linked_List :: struct($T: typeid) {
	_allocator: type_of(context.allocator),
	_size:      usize,
	_begin:     ^Node(T),
}

@(private)
new_Linked_List :: proc($T: typeid, allocator := context.temp_allocator) -> Linked_List(T) {
	return {_allocator = allocator, _size = 0, _begin = nil}
}

@(private)
delete_Linked_List :: proc(list: ^Linked_List($T)) {
	free(list._begin, list._allocator)
}

@(private)
at_Linked_List :: proc(list: ^Linked_List($T), position: usize) -> (value: T, error: Error) {
	default: T
	if position == 0 {
		if list._begin != nil {
			return list._begin.data, nil
		} else {
			return default, Error.Out_Of_Bounds
		}
	}
	node := list._begin
	if (position < list._size) {
		for i: usize = 0; i < position; i += 1 {
			if (node.next != nil) {
				node = node.next
			} else {
				// Found last element in the list
				return node.data, nil
			}
		}
		return node.data, nil
	}
	return default, Error.Out_Of_Bounds
}

@(private)
size_Linked_List :: proc(list: ^Linked_List($T)) -> usize {
	return list._size
}

@(private)
push_Linked_List :: proc(list: ^Linked_List($T), position: usize, data: T) -> (error: Error) {
	if position == 0 {
		if (list._begin == nil) {
			ptr, err := new_Node(data, nil, nil, list._allocator)
			if err != nil {
				return err
			}
			list._begin = ptr
			list._size += 1
			return nil
		}
		old_begin := list._begin
		list._begin = new_Node(data, nil, old_begin, list._allocator) or_return
		list._size += 1
		return nil
	}
	if position > list._size {
		return Error.Out_Of_Bounds
	}
	node := list._begin
	for i: usize = 0; i < position; i += 1 {
		if (node.next != nil) {
			node = node.next
		} else {
			node.next = new_Node(data, node, nil, list._allocator) or_return
			list._size += 1
			return nil
		}
	}
	new_next := node.next
	node.next = new_Node(data, node, new_next, list._allocator) or_return
	list._size += 1
	return nil
}

@(private)
push_back_Linked_List :: proc(list: ^Linked_List($T), data: T) -> (error: Error) {
	if list._size == 0 {
		push_Linked_List(list, 0, data) or_return
	} else {
		push_Linked_List(list, list._size, data) or_return
	}
	return nil
}

@(private)
push_front_Linked_List :: proc(list: ^Linked_List($T), data: T) -> (error: Error) {
	push_Linked_List(list, 0, data) or_return
}

@(private)
erase_Linked_List :: proc(list: ^Linked_List($T), position: usize) -> (error: Error) {
	if list._size == 0 || position >= list._size {
		return Error.Out_Of_Bounds
	}
	if position == 0 {
		node := list._begin
		list._begin = node.next
		node.next = nil
		free(node, list._allocator)
		list._size -= 1
		return nil
	}
	node := list._begin
	i: usize = 0
	for ; i < position - 1; i += 1 {
		node = node.next
	}
	erased := node.next
	next := erased.next
	erased.next = nil
	node.next = next
	free(erased, list._allocator)
	list._size -= 1
	return nil
}

@(private)
erase_back_Linked_List :: proc(list: ^Linked_List($T)) -> (error: Error) {
	erase_Linked_List(list, 0) or_return
	return nil
}

@(private)
erase_front_Linked_List :: proc(list: ^Linked_List($T)) -> (error: Error) {
	erase_Linked_List(list, list._size - 1) or_return
	return nil
}

@(private)
clear_Linked_List :: proc(list: ^Linked_List($T)) {
	free(list._begin, list._allocator)
	list._begin = nil
	list._size = 0
}

@(private)
zero_Linked_List :: proc(list: ^Linked_List($T)) {
	for_each_Linked_List(list, proc(it: ^T) {
		default: T
		it^ = default
	})
}

@(private)
for_each_Linked_List :: proc(list: ^Linked_List($T), action: proc(it: ^T)) {
	node := list._begin
	if (node == nil) {
		return
	}
	for node != nil {
		action(&node.data)
		node = node.next
	}
}

@(private)
filter_Linked_List :: proc(list: ^Linked_List($T), action: proc(it: ^T) -> bool) -> [dynamic]^T {
	node := list._begin
	if (node == nil) {
		return nil
	}
	buffer: [dynamic]^T
	for node != nil {
		if (action(&node.data)) {
			append(&buffer, &node.data)
		}
		node = node.next
	}
	return buffer
}

