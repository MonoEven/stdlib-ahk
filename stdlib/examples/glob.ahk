#Requires AutoHotkey v2.0

#Include <stdlib\glob>

txtMatches := stdlib.glob.glob("*.txt")
escaped := stdlib.glob.escape("[*]?.txt")
hasMagic := stdlib.glob.has_magic("*.txt")

MsgBox "glob('*.txt') count=" txtMatches.Length
    . "`nescape([*]?.txt)=" escaped
    . "`nhas_magic(*.txt)=" (hasMagic ? "yes" : "no")
