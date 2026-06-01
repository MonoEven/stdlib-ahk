#Requires AutoHotkey v2.0

#Include <stdlib\enum>

enum_example_color := stdlib.enum.Enum("Color", "RED GREEN BLUE")
enum_example_listed := stdlib.enum.Enum("Listed", ["RED", "GREEN", "BLUE"], { start: 5 })
enum_example_ordered := stdlib.enum.Enum("Ordered", [["LOW", 10], ["HIGH", 20]])
enum_example_auto := stdlib.enum.Enum("AutoColor", [["RED", stdlib.enum.auto()], ["GREEN", stdlib.enum.auto()]])

enum_example_color_name := enum_example_color.__name__
enum_example_red_name := enum_example_color.RED.name
enum_example_red_value := enum_example_color.RED.value
enum_example_red_string := String(enum_example_color.RED)
enum_example_red_repr := enum_example_color.RED.__Repr()
enum_example_green_by_name_same := enum_example_color["GREEN"] == enum_example_color.GREEN
enum_example_green_by_value_same := enum_example_color(2) == enum_example_color.GREEN

enum_example_member_names := []
for name, member in enum_example_color.__members__
    enum_example_member_names.Push(name)

enum_example_member_values := []
for member in enum_example_color
    enum_example_member_values.Push(member.value)

enum_example_listed_values := []
for member in enum_example_listed
    enum_example_listed_values.Push(member.value)

enum_example_auto_values := []
for member in enum_example_auto
    enum_example_auto_values.Push(member.value)

enum_example_auto_factory_repr := enum_example_auto.RED._value_factory.__Repr()

enum_example_missing_name_error := ""
try {
    enum_example_color["MISSING"]
} catch KeyError as err {
    enum_example_missing_name_error := err.Message
}

enum_example_bad_value_error := ""
try {
    enum_example_color(4)
} catch ValueError as err {
    enum_example_bad_value_error := err.Message
}

enum_example_bad_keyword_error := ""
try {
    stdlib.enum.Enum("Color", "RED GREEN BLUE", { bad: 1 })
} catch TypeError as err {
    enum_example_bad_keyword_error := err.Message
}
