#Requires AutoHotkey v2.0

#Include <stdlib\array>
#Include <stdlib\operator>

array_example_ints := stdlib.array.array("i", [1, 2, 3])
array_example_empty_repr := stdlib.array.array("i").__Repr()
array_example_typecodes := stdlib.array.typecodes
array_example_arraytype_is_array := stdlib.array.ArrayType = stdlib.array.array
array_example_typecode := array_example_ints.typecode
array_example_itemsize := array_example_ints.itemsize
array_example_append_result := array_example_ints.append(4)
array_example_extend_result := array_example_ints.extend([5, 6])
array_example_second_value := array_example_ints[1]
array_example_ints[1] := 20
array_example_insert_result := array_example_ints.insert(1, 99)
array_example_values := array_example_ints.tolist()
array_example_iterated := []
for value in array_example_ints
    array_example_iterated.Push(value)
array_example_buffer_info := array_example_ints.buffer_info()
array_example_len := array_example_ints.__Len
array_example_truth := stdlib.operator.truth(array_example_ints)
array_example_contains_3 := stdlib.operator.contains(array_example_ints, 3)
array_example_equals_short_array := stdlib.operator.eq(stdlib.array.array("i", [1, 20, 99, 2, 3, 4, 5, 6]), stdlib.array.array("h", [1, 20, 99, 2, 3, 4, 5, 6]))
array_example_added := stdlib.operator.add(stdlib.array.array("i", [1, 2, 3]), stdlib.array.array("i", [4, 5])).tolist()
array_example_multiplied := stdlib.operator.mul(stdlib.array.array("i", [1, 2, 3]), 2).tolist()
array_example_reverse_multiplied := stdlib.operator.mul(2, stdlib.array.array("i", [1, 2, 3])).tolist()
array_example_count_5 := array_example_ints.count(5)
array_example_index_5 := array_example_ints.index(5)
array_example_pop_last := array_example_ints.pop()
array_example_remove_5 := array_example_ints.remove(5)
array_example_reverse := array_example_ints.reverse()
array_example_after_mutations := array_example_ints.tolist()
array_example_bytes_repr := stdlib.array.array("b", [1, -2, 3]).__Repr()
array_example_raw_source := stdlib.array.array("i", [1, 2, 3])
array_example_raw_bytes := array_example_raw_source.tobytes()
array_example_raw_copy := stdlib.array.array("i")
array_example_frombytes_result := array_example_raw_copy.frombytes(array_example_raw_bytes)
array_example_raw_copy_values := array_example_raw_copy.tolist()
array_example_fromlist_result := array_example_raw_copy.fromlist([4])
array_example_after_fromlist := array_example_raw_copy.tolist()
array_example_swap := stdlib.array.array("H", [0x0102, 0x0304])
array_example_byteswap_result := array_example_swap.byteswap()
array_example_after_byteswap := array_example_swap.tolist()
array_example_unicode := stdlib.array.array("u", "Az")
array_example_tounicode := array_example_unicode.tounicode()
array_example_fromunicode_result := array_example_unicode.fromunicode("!")
array_example_after_fromunicode := array_example_unicode.tolist()
array_example_file_path := A_Temp "\stdlib-array-example-" A_TickCount "-" Random(100000, 999999) ".bin"
try {
    array_example_tofile_result := stdlib.array.array("H", [1, 258]).tofile(array_example_file_path)
    array_example_file_loaded := stdlib.array.array("H")
    array_example_fromfile_result := array_example_file_loaded.fromfile(array_example_file_path, 2)
    array_example_file_loaded_values := array_example_file_loaded.tolist()
} finally {
    if FileExist(array_example_file_path)
        FileDelete array_example_file_path
}
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
