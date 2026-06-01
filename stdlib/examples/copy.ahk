#Requires AutoHotkey v2.0

#Include <stdlib\copy>

copy_example_list := [1, [2]]
copy_example_list_copy := stdlib.copy.copy(copy_example_list)
copy_example_list_deep := stdlib.copy.deepcopy(copy_example_list)
copy_example_list_copy_shares_nested := copy_example_list_copy[2] == copy_example_list[2]
copy_example_list_deep_shares_nested := copy_example_list_deep[2] == copy_example_list[2]

copy_example_map := Map("a", [1], "b", 2)
copy_example_map_copy := stdlib.copy.copy(copy_example_map)
copy_example_map_deep := stdlib.copy.deepcopy(copy_example_map)
copy_example_map_copy_shares_nested := copy_example_map_copy["a"] == copy_example_map["a"]
copy_example_map_deep_shares_nested := copy_example_map_deep["a"] == copy_example_map["a"]

copy_example_tuple := stdlib.tuple([1, [2]])
copy_example_tuple_copy := stdlib.copy.copy(copy_example_tuple)
copy_example_tuple_deep := stdlib.copy.deepcopy(copy_example_tuple)
copy_example_tuple_copy_same := copy_example_tuple_copy == copy_example_tuple
copy_example_tuple_deep_nested_same := copy_example_tuple_deep[2] == copy_example_tuple[2]

copy_example_text_same := stdlib.copy.copy("abc")
copy_example_int_same := stdlib.copy.deepcopy(42)

copy_example_custom_copy := stdlib.copy.copy(StdlibCopyExampleCustomCopy())
copy_example_custom_deep := stdlib.copy.deepcopy(StdlibCopyExampleCustomDeep())

copy_example_cycle := StdlibCopyExampleNode()
copy_example_cycle.me := copy_example_cycle
copy_example_cycle_clone := stdlib.copy.deepcopy(copy_example_cycle)
copy_example_cycle_self := copy_example_cycle_clone.me == copy_example_cycle_clone

copy_example_missing_error := ""
try {
    stdlib.copy.copy()
} catch TypeError as err {
    copy_example_missing_error := err.Message
}

copy_example_deep_missing_error := ""
try {
    stdlib.copy.deepcopy()
} catch TypeError as err {
    copy_example_deep_missing_error := err.Message
}

class StdlibCopyExampleNode
{
    __New()
    {
        this.me := ""
    }
}

class StdlibCopyExampleCustomCopy
{
    __copy__()
    {
        return ["custom-copy", Type(this)]
    }
}

class StdlibCopyExampleCustomDeep
{
    __deepcopy__(memo)
    {
        return ["custom-deepcopy", memo is Map, Type(this)]
    }
}
