#Requires AutoHotkey v2.0

#Include <stdlib\assert>

assert_example_value := stdlib.assert.assert("ready", "example should keep truthy values")

try {
    stdlib.assert.assert(false, "example failure")
} catch Error as err {
    if err is stdlib.assert.AssertionError
        assert_example_message := err.Message
}
