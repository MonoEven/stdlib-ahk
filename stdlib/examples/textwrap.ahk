#Requires AutoHotkey v2.0

#Include <stdlib\textwrap>

dedented := stdlib.textwrap.dedent("    a`n      b`n")
indented := stdlib.textwrap.indent("a`n`nb", "> ")
allIndented := stdlib.textwrap.indent("a`n`n b", "> ", (*) => stdlib.True)

MsgBox "dedent=" dedented
    . "`nindent=" indented
    . "`nindent all=" allIndented
