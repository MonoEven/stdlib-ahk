#Requires AutoHotkey v2.0

#Include <stdlib\string>

defaultTitle := stdlib.string.capwords("  hello   world  ")
commaTitle := stdlib.string.capwords("a,,b,", ",")

string_example_output := "ascii_lowercase=" stdlib.string.ascii_lowercase
    . "`ncapwords default=" defaultTitle
    . "`ncapwords comma=" commaTitle
FileAppend string_example_output "`n", "*", "UTF-8"
