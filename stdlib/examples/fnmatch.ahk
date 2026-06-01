#Requires AutoHotkey v2.0

#Include <stdlib\fnmatch>

matchText := stdlib.fnmatch.fnmatch("A.TXT", "*.txt")
caseText := stdlib.fnmatch.fnmatchcase("A.TXT", "*.txt")
filtered := stdlib.fnmatch.filter(["A.TXT", "b.txt", "c.bin"], "*.txt")

MsgBox "fnmatch(A.TXT, *.txt)=" (matchText ? "yes" : "no")
    . "`nfnmatchcase(A.TXT, *.txt)=" (caseText ? "yes" : "no")
    . "`nfilter count=" filtered.Length
