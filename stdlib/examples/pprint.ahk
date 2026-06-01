#Requires AutoHotkey v2.0

#Include <stdlib\pprint>
#Include <stdlib\io>

pprint_example_nested := stdlib.pprint.pformat([1, "two", [3]])
pprint_example_sorted_dict := stdlib.pprint.pformat(Map("b", 1, "a", 2))
pprint_example_indented := stdlib.pprint.pformat([Map("a", 1, "b", 2), Map("c", 3)], 2, 20)
pprint_example_depth := stdlib.pprint.pformat([1, [2, [3, [4]]]], 1, 80, 2)
pprint_example_compact := stdlib.pprint.pformat([[1, 2], [3, 4], [5, 6]], 1, 12, stdlib.None, true)
pprint_example_stream := stdlib.io.StringIO()
pprint_example_pprint_result := stdlib.pprint.pprint(Map("b", 1, "a", 2), pprint_example_stream)
pprint_example_stream_text := pprint_example_stream.getvalue()
pprint_example_pp_stream := stdlib.io.StringIO()
pprint_example_pp_result := stdlib.pprint.pp(Map("b", 1, "a", 2), pprint_example_pp_stream)
pprint_example_pp_stream_text := pprint_example_pp_stream.getvalue()
pprint_example_printer := stdlib.pprint.PrettyPrinter(2, 20)
pprint_example_printer_text := pprint_example_printer.pformat(Map("b", 1, "a", [1, 2, 3]))
pprint_example_bad_indent_error := ""
try {
    stdlib.pprint.PrettyPrinter("x")
} catch ValueError as err {
    pprint_example_bad_indent_error := err.Message
}
pprint_example_bad_stream_error := ""
try {
    stdlib.pprint.pprint(Map("a", 1), 1)
} catch AttributeError as err {
    pprint_example_bad_stream_error := err.Message
}
