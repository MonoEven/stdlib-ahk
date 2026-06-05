#Requires AutoHotkey v2.0

#Include <stdlib\array>

array_example_ints := stdlib.array.array("i", [1, 2, 3])
array_example_empty_repr := stdlib.array.array("i").__Repr()
array_example_typecodes := stdlib.array.typecodes
array_example_typecode := array_example_ints.typecode
array_example_itemsize := array_example_ints.itemsize
array_example_append_result := array_example_ints.append(4)
array_example_extend_result := array_example_ints.extend([5, 6])
array_example_second_value := array_example_ints[1]
array_example_ints[1] := 20
array_example_values := array_example_ints.tolist()
array_example_iterated := []
for value in array_example_ints
    array_example_iterated.Push(value)
array_example_buffer_info := array_example_ints.buffer_info()
array_example_count_5 := array_example_ints.count(5)
array_example_index_5 := array_example_ints.index(5)
array_example_pop_last := array_example_ints.pop()
array_example_remove_5 := array_example_ints.remove(5)
array_example_reverse := array_example_ints.reverse()
array_example_after_mutations := array_example_ints.tolist()
array_example_bytes_repr := stdlib.array.array("b", [1, -2, 3]).__Repr()
array_example_bad_typecode_error := ""
try {
    stdlib.array.array("z")
} catch ValueError as err {
    array_example_bad_typecode_error := err.Message
}
array_example_bad_append_error := ""
try {
    stdlib.array.array("i").append("x")
} catch TypeError as err {
    array_example_bad_append_error := err.Message
}
