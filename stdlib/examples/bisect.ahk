#Requires AutoHotkey v2.0

#Include <stdlib\array>
#Include <stdlib\bisect>

bisect_example_values := [1, 2, 2, 3]
bisect_example_left := stdlib.bisect.bisect_left(bisect_example_values, 2)
bisect_example_right := stdlib.bisect.bisect_right(bisect_example_values, 2)
stdlib.bisect.insort_right(bisect_example_values, 2)
bisect_example_none_hi := stdlib.bisect.bisect_left([1, 2, 3], 2, 0, stdlib.None)
bisect_example_records := [
    Map("name", "a", "size", 1),
    Map("name", "cc", "size", 2),
    Map("name", "bbb", "size", 3),
]
bisect_example_key_index := stdlib.bisect.bisect_right(bisect_example_records, 2, 0, stdlib.None, (record) => record["size"])
bisect_example_array := stdlib.array.array("i", [1, 3])
stdlib.bisect.insort_left(bisect_example_array, 2)
