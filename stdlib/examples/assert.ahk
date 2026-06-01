#Requires AutoHotkey v2.0

#Include <stdlib\assert>

assert_example_value := assert("ready", "example should keep truthy values")

try {
    assert(false, "example failure")
} catch AssertionError as err {
    assert_example_message := err.Message
}
