#Requires AutoHotkey v2.0

#Include <stdlib\base64>

payload := Buffer(3, 0)
StrPut("abc", payload, "UTF-8")
encoded := stdlib.base64.b64encode(payload)
decoded := stdlib.base64.b64decode("YWJj")

MsgBox "encoded=" StrGet(encoded, "UTF-8")
    . "`ndecoded=" StrGet(decoded, "UTF-8")
