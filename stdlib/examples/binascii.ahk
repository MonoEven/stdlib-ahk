#Requires AutoHotkey v2.0

#Include <stdlib\binascii>

payload := Buffer(3, 0)
StrPut("abc", payload, "UTF-8")
encoded := stdlib.binascii.hexlify(payload)
decoded := stdlib.binascii.unhexlify("616263")
checksum := stdlib.binascii.crc32(payload)
base64Line := stdlib.binascii.b2a_base64(payload)
base64Compact := stdlib.binascii.b2a_base64(payload, { newline: false })
base64Decoded := stdlib.binascii.a2b_base64(base64Line)

MsgBox "hexlify=" StrGet(encoded, "UTF-8")
    . "`nunhexlify=" StrGet(decoded, "UTF-8")
    . "`ncrc32=" checksum
    . "`nb2a_base64=" StrGet(base64Compact, "UTF-8")
    . "`na2b_base64=" StrGet(base64Decoded, "UTF-8")
