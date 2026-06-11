#Requires AutoHotkey v2.0

#Include <stdlib\keyword>

isFor := stdlib.keyword.iskeyword("for")
isMatch := stdlib.keyword.iskeyword("match")
isSoftMatch := stdlib.keyword.issoftkeyword("match")

keyword_example_output := "kwlist size=" stdlib.keyword.kwlist.Length
    . "`niskeyword(for)=" (isFor ? "yes" : "no")
    . "`niskeyword(match)=" (isMatch ? "yes" : "no")
    . "`nissoftkeyword(match)=" (isSoftMatch ? "yes" : "no")
FileAppend keyword_example_output "`n", "*", "UTF-8"
