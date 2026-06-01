#Requires AutoHotkey v2.0

#Include <stdlib\quopri>

payload := Buffer(3, 0)
StrPut("a b", payload, "UTF-8")
encoded := stdlib.quopri.encodestring(payload, stdlib.False, stdlib.True)
decoded := stdlib.quopri.decodestring("a_b=3D", stdlib.True)

MsgBox "encodestring=" StrGet(encoded, "UTF-8")
    . "`ndecodestring=" StrGet(decoded, "UTF-8")
