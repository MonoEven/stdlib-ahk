#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\assert>

class AhkStdlibBase64
{
    static b64encode(args*)
    {
        if args.Length = 0
            throw TypeError("b64encode() missing 1 required positional argument: 's'", -1)
        if args.Length > 2
            throw TypeError("b64encode() takes from 1 to 2 positional arguments but " args.Length " were given", -1)

        bytes := AhkStdlibBase64RequireBytesLike(args[1], "str")
        altchars := args.Length >= 2 ? args[2] : stdlib.None

        if !AhkStdlibIsNone(altchars)
            AhkStdlibBase64AssertAltChars(altchars)

        encoded := AhkStdlibBase64Encode(bytes)
        if !AhkStdlibIsNone(altchars)
            encoded := StrReplace(StrReplace(encoded, "+", Chr(NumGet(altchars, 0, "UChar"))), "/", Chr(NumGet(altchars, 1, "UChar")))
        return AhkStdlibBase64Utf8Bytes(encoded)
    }

    static b64decode(args*)
    {
        if args.Length = 0
            throw TypeError("b64decode() missing 1 required positional argument: 's'", -1)
        if args.Length > 3
            throw TypeError("b64decode() takes from 1 to 3 positional arguments but " args.Length " were given", -1)

        source := AhkStdlibBase64RequireDecodeSource(args[1])
        altchars := args.Length >= 2 ? args[2] : stdlib.None
        validate := args.Length >= 3 ? args[3] : stdlib.None

        if !AhkStdlibIsNone(altchars) {
            AhkStdlibBase64AssertAltChars(altchars)
            source := StrReplace(StrReplace(source, Chr(NumGet(altchars, 0, "UChar")), "+"), Chr(NumGet(altchars, 1, "UChar")), "/")
        }

        if !AhkStdlibIsNone(validate) {
            ; Covered local 3.10 behavior accepts bool-like truthiness here.
            validate := AhkStdlibTruthValue(validate)
        }

        return AhkStdlibBase64Decode(source)
    }
}

stdlib.base64 := AhkStdlibBase64

AhkStdlibBase64RequireBytesLike(value, strTypeName := "str")
{
    if value is String
        throw TypeError("a bytes-like object is required, not '" strTypeName "'", -1)
    if !IsObject(value) || !HasProp(value, "Ptr") || !HasProp(value, "Size")
        throw TypeError("a bytes-like object is required, not '" AhkStdlibPythonTypeName(value) "'", -1)
    return value
}

AhkStdlibBase64RequireDecodeSource(value)
{
    if value is String
        return value
    if IsObject(value) && HasProp(value, "Ptr") && HasProp(value, "Size")
        return StrGet(value, value.Size, "UTF-8")
    throw TypeError("argument should be a bytes-like object or ASCII string, not '" AhkStdlibPythonTypeName(value) "'", -1)
}

AhkStdlibBase64AssertAltChars(value)
{
    bytes := AhkStdlibBase64RequireBytesLike(value)
    if bytes.Size != 2
        throw stdlib.assert.AssertionError("b'" StrGet(bytes, bytes.Size, "UTF-8") "'", -1)
    return bytes
}

AhkStdlibBase64Utf8Bytes(text)
{
    size := StrPut(text, "UTF-8") - 1
    bytes := Buffer(size, 0)
    if size > 0
        StrPut(text, bytes, "UTF-8")
    return bytes
}

AhkStdlibBase64Encode(bytes)
{
    if bytes.Size = 0
        return ""

    flags := 0x00000001 | 0x40000000
    chars := 0
    if !DllCall("crypt32\CryptBinaryToStringW"
        , "Ptr", bytes.Ptr
        , "UInt", bytes.Size
        , "UInt", flags
        , "Ptr", 0
        , "UInt*", &chars
        , "Int")
        throw Error("CryptBinaryToStringW failed", -1)

    outputBuffer := Buffer(chars * 2, 0)
    if !DllCall("crypt32\CryptBinaryToStringW"
        , "Ptr", bytes.Ptr
        , "UInt", bytes.Size
        , "UInt", flags
        , "Ptr", outputBuffer.Ptr
        , "UInt*", &chars
        , "Int")
        throw Error("CryptBinaryToStringW failed", -1)
    return StrGet(outputBuffer, "UTF-16")
}

AhkStdlibBase64Decode(text)
{
    if text = ""
        return Buffer(0)

    size := 0
    if !DllCall("crypt32\CryptStringToBinaryA"
        , "AStr", text
        , "UInt", 0
        , "UInt", 0x00000001
        , "Ptr", 0
        , "UInt*", &size
        , "Ptr", 0
        , "Ptr", 0
        , "Int")
        throw Error("CryptStringToBinaryA failed", -1)

    bytes := Buffer(size, 0)
    if !DllCall("crypt32\CryptStringToBinaryA"
        , "AStr", text
        , "UInt", 0
        , "UInt", 0x00000001
        , "Ptr", bytes.Ptr
        , "UInt*", &size
        , "Ptr", 0
        , "Ptr", 0
        , "Int")
        throw Error("CryptStringToBinaryA failed", -1)
    return bytes
}
