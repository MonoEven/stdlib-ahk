#Requires AutoHotkey v2.0

#Include <stdlib\glob>

txtMatches := stdlib.glob.glob("*.txt")
escaped := stdlib.glob.escape("[*]?.txt")
hasMagic := stdlib.glob.has_magic("*.txt")

glob_example_output := "glob('*.txt') count=" txtMatches.Length
    . "`nescape([*]?.txt)=" escaped
    . "`nhas_magic(*.txt)=" (hasMagic ? "yes" : "no")
FileAppend glob_example_output "`n", "*", "UTF-8"
