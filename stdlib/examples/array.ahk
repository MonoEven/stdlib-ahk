#Requires AutoHotkey v2.0

#Include <stdlib\array>
#Include <stdlib\copy>
#Include <stdlib\operator>

array_example_ints := stdlib.array.array("i", [1, 2, 3])
array_example_empty_repr := stdlib.array.array("i").__Repr()
array_example_typecodes := stdlib.array.typecodes
array_example_arraytype_is_array := stdlib.array.ArrayType = stdlib.array.array
array_example_typecode := array_example_ints.typecode
array_example_itemsize := array_example_ints.itemsize
array_example_root_bool_ints := stdlib.array.array("i", [stdlib.True, stdlib.False]).tolist()
array_example_root_bool_floats := stdlib.array.array("f", [stdlib.True, stdlib.False]).tolist()
array_example_root_bool_index_source := stdlib.array.array("i", [10, 20, 30])
array_example_root_bool_get_true := array_example_root_bool_index_source[stdlib.True]
array_example_root_bool_get_false := array_example_root_bool_index_source[stdlib.False]
array_example_root_bool_delete_source := stdlib.array.array("i", [10, 20, 30])
array_example_root_bool_delete_result := array_example_root_bool_delete_source.Delete(stdlib.True)
array_example_root_bool_after_delete := array_example_root_bool_delete_source.tolist()
array_example_root_bool_pop_true := stdlib.array.array("i", [10, 20, 30]).pop(stdlib.True)
array_example_root_bool_insert_source := stdlib.array.array("i", [10, 20, 30])
array_example_root_bool_insert_result := array_example_root_bool_insert_source.insert(stdlib.False, 99)
array_example_root_bool_after_insert := array_example_root_bool_insert_source.tolist()
array_example_root_bool_multiply := stdlib.operator.mul(stdlib.array.array("i", [7, 8]), stdlib.True).tolist()
array_example_root_bool_count_true := stdlib.array.array("i", [0, 1, 1, 2]).count(stdlib.True)
array_example_root_bool_index_false := stdlib.array.array("i", [1, 2, 0, 0]).index(stdlib.False)
array_example_root_bool_remove_source := stdlib.array.array("i", [0, 1, 2, 1])
array_example_root_bool_remove_result := array_example_root_bool_remove_source.remove(stdlib.True)
array_example_root_bool_after_remove := array_example_root_bool_remove_source.tolist()
array_example_root_bool_contains_false := stdlib.operator.contains(stdlib.array.array("i", [1, 0, 2]), stdlib.False)
array_example_root_bool_unicode_error := ""
try {
    stdlib.array.array("u", [stdlib.True])
} catch TypeError as err {
    array_example_root_bool_unicode_error := err.Message
}
array_example_typecode_readonly_error := ""
try {
    array_example_ints.typecode := "h"
} catch Error as err {
    if !(err is stdlib.AttributeError)
        throw
    array_example_typecode_readonly_error := err.Message
}
array_example_itemsize_readonly_error := ""
try {
    array_example_ints.itemsize := 8
} catch Error as err {
    if !(err is stdlib.AttributeError)
        throw
    array_example_itemsize_readonly_error := err.Message
}
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
array_example_iadd_source := stdlib.array.array("i", [1, 2])
array_example_iadd_result := array_example_iadd_source.__iadd(stdlib.array.array("i", [3, 4]))
array_example_after_iadd := array_example_iadd_source.tolist()
array_example_imul_source := stdlib.array.array("i", [1, 2])
array_example_imul_result := array_example_imul_source.__imul(2)
array_example_after_imul := array_example_imul_source.tolist()
array_example_rmul_source := stdlib.array.array("i", [1, 2])
array_example_rmul_result := array_example_rmul_source.__rmul(2).tolist()
array_example_after_rmul_source := array_example_rmul_source.tolist()
array_example_count_5 := array_example_ints.count(5)
array_example_index_5 := array_example_ints.index(5)
array_example_index_5_from_5 := array_example_ints.index(5, 5)
array_example_index_5_negative_window := array_example_ints.index(5, -3, -1)
array_example_pop_last := array_example_ints.pop()
array_example_remove_5 := array_example_ints.remove(5)
array_example_reverse := array_example_ints.reverse()
array_example_after_mutations := array_example_ints.tolist()
array_example_bytes_repr := stdlib.array.array("b", [1, -2, 3]).__Repr()
array_example_raw_source := stdlib.array.array("i", [1, 2, 3])
array_example_shallow_copy := stdlib.copy.copy(array_example_raw_source)
array_example_deep_copy := stdlib.copy.deepcopy(array_example_raw_source)
array_example_shallow_copy[0] := 10
array_example_deep_copy.append(4)
array_example_source_after_copy_mutations := array_example_raw_source.tolist()
array_example_shallow_copy_values := array_example_shallow_copy.tolist()
array_example_deep_copy_values := array_example_deep_copy.tolist()
array_example_slice_source := stdlib.array.array("i", [1, 2, 3, 4, 5])
array_example_slice_middle := array_example_slice_source[stdlib.slice(1, 4)].tolist()
array_example_slice_step := array_example_slice_source[stdlib.slice(stdlib.None, stdlib.None, 2)].tolist()
array_example_slice_source[stdlib.slice(1, 3)] := stdlib.array.array("i", [20, 30, 40])
array_example_after_slice_set := array_example_slice_source.tolist()
array_example_slice_self_assignment := stdlib.array.array("i", [1, 2, 3, 4])
array_example_slice_self_assignment[stdlib.slice(stdlib.None, stdlib.None, -1)] := array_example_slice_self_assignment
array_example_after_slice_self_assignment := array_example_slice_self_assignment.tolist()
array_example_slice_delete_result := array_example_slice_source.Delete(stdlib.slice(stdlib.None, stdlib.None, 2))
array_example_after_slice_delete := array_example_slice_source.tolist()
array_example_operator_slice_source := stdlib.array.array("i", [1, 2, 3, 4, 5])
array_example_operator_slice_values := stdlib.operator.getitem(array_example_operator_slice_source, stdlib.slice(1, 4)).tolist()
array_example_operator_slice_set := stdlib.operator.setitem(array_example_operator_slice_source, stdlib.slice(1, 3), stdlib.array.array("i", [20, 30, 40]))
array_example_after_operator_slice_set := array_example_operator_slice_source.tolist()
array_example_operator_slice_delete := stdlib.operator.delitem(array_example_operator_slice_source, stdlib.slice(stdlib.None, stdlib.None, 2))
array_example_after_operator_slice_delete := array_example_operator_slice_source.tolist()
array_example_raw_bytes := array_example_raw_source.tobytes()
array_example_raw_copy := stdlib.array.array("i")
array_example_frombytes_result := array_example_raw_copy.frombytes(array_example_raw_bytes)
array_example_raw_copy_values := array_example_raw_copy.tolist()
array_example_bytes_initializer_values := stdlib.array.array("i", array_example_raw_bytes).tolist()
array_example_extend_bytes_values := stdlib.array.array("i", [9])
array_example_extend_bytes_buffer := Buffer(2, 0)
NumPut("UChar", 1, array_example_extend_bytes_buffer, 0)
NumPut("UChar", 2, array_example_extend_bytes_buffer, 1)
array_example_extend_bytes_result := array_example_extend_bytes_values.extend(array_example_extend_bytes_buffer)
array_example_after_extend_bytes := array_example_extend_bytes_values.tolist()
array_example_fromlist_result := array_example_raw_copy.fromlist([4])
array_example_after_fromlist := array_example_raw_copy.tolist()
array_example_swap := stdlib.array.array("H", [0x0102, 0x0304])
array_example_byteswap_result := array_example_swap.byteswap()
array_example_after_byteswap := array_example_swap.tolist()
array_example_unicode := stdlib.array.array("u", "Az")
array_example_unicode_repr := array_example_unicode.__Repr()
array_example_tounicode := array_example_unicode.tounicode()
array_example_unicode_extend_string_result := array_example_unicode.extend("!")
array_example_fromunicode_result := array_example_unicode.fromunicode("?")
array_example_after_fromunicode := array_example_unicode.tolist()
array_example_unicode_raw_bytes := array_example_unicode.tobytes()
array_example_unicode_bytes_initializer := stdlib.array.array("u", array_example_unicode_raw_bytes).tounicode()
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
array_example_short_file_path := A_Temp "\stdlib-array-short-example-" A_TickCount "-" Random(100000, 999999) ".bin"
array_example_fromfile_eof_error := ""
try {
    ArrayExampleWriteIntBytes(array_example_short_file_path, [1])
    array_example_partial_loaded := stdlib.array.array("i", [99])
    try {
        array_example_partial_loaded.fromfile(array_example_short_file_path, 2)
    } catch EOFError as err {
        array_example_fromfile_eof_error := err.Message
    }
    array_example_partial_loaded_values := array_example_partial_loaded.tolist()
} finally {
    if FileExist(array_example_short_file_path)
        FileDelete array_example_short_file_path
}
array_example_bad_typecode_error := ""
try {
    stdlib.array.array("z")
} catch ValueError as err {
    array_example_bad_typecode_error := err.Message
}
array_example_bad_string_initializer_error := ""
try {
    stdlib.array.array("i", "12")
} catch TypeError as err {
    array_example_bad_string_initializer_error := err.Message
}
array_example_bad_append_error := ""
try {
    stdlib.array.array("i").append("x")
} catch TypeError as err {
    array_example_bad_append_error := err.Message
}
array_example_bad_extend_error := ""
try {
    stdlib.array.array("i").extend(stdlib.array.array("h", [1]))
} catch TypeError as err {
    array_example_bad_extend_error := err.Message
}
array_example_bad_fromlist_error := ""
try {
    stdlib.array.array("i").fromlist(stdlib.tuple([1]))
} catch TypeError as err {
    array_example_bad_fromlist_error := err.Message
}
array_example_overflow_error := ""
try {
    stdlib.array.array("B", [256])
} catch Error as err {
    array_example_overflow_error := err.Message
}

ArrayExampleWriteIntBytes(path, integers)
{
    bytes := Buffer(integers.Length * 4, 0)
    offset := 0
    for value in integers {
        NumPut("Int", value, bytes, offset)
        offset += 4
    }
    file := FileOpen(path, "w")
    try {
        file.RawWrite(bytes, bytes.Size)
    } finally {
        file.Close()
    }
}
