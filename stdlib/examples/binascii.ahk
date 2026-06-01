#Requires AutoHotkey v2.0

#Include <stdlib\binascii>

payload := Buffer(3, 0)
StrPut("abc", payload, "UTF-8")
encoded := stdlib.binascii.hexlify(payload)
decoded := stdlib.binascii.unhexlify("616263")

MsgBox "hexlify=" StrGet(encoded, "UTF-8")
    . "`nunhexlify=" StrGet(decoded, "UTF-8")
