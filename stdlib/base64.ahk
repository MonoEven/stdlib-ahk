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

    static urlsafe_b64encode(args*)
    {
        if args.Length = 0
            throw TypeError("urlsafe_b64encode() missing 1 required positional argument: 's'", -1)
        if args.Length > 1
            throw TypeError("urlsafe_b64encode() takes 1 positional argument but " args.Length " were given", -1)

        encoded := AhkStdlibBase64Encode(AhkStdlibBase64RequireBytesLike(args[1], "str"))
        encoded := StrReplace(StrReplace(encoded, "+", "-"), "/", "_")
        return AhkStdlibBase64Utf8Bytes(encoded)
    }

    static urlsafe_b64decode(args*)
    {
        if args.Length = 0
            throw TypeError("urlsafe_b64decode() missing 1 required positional argument: 's'", -1)
        if args.Length > 1
            throw TypeError("urlsafe_b64decode() takes 1 positional argument but " args.Length " were given", -1)

        source := AhkStdlibBase64RequireDecodeSource(args[1])
        source := StrReplace(StrReplace(source, "-", "+"), "_", "/")
        return AhkStdlibBase64Decode(source)
    }

    static standard_b64encode(args*)
    {
        if args.Length = 0
            throw TypeError("standard_b64encode() missing 1 required positional argument: 's'", -1)
        if args.Length > 1
            throw TypeError("standard_b64encode() takes 1 positional argument but " args.Length " were given", -1)
        return this.b64encode(args[1])
    }

    static standard_b64decode(args*)
    {
        if args.Length = 0
            throw TypeError("standard_b64decode() missing 1 required positional argument: 's'", -1)
        if args.Length > 1
            throw TypeError("standard_b64decode() takes 1 positional argument but " args.Length " were given", -1)
        return this.b64decode(args[1])
    }

    static encodebytes(args*)
    {
        if args.Length = 0
            throw TypeError("encodebytes() missing 1 required positional argument: 's'", -1)
        if args.Length > 1
            throw TypeError("encodebytes() takes 1 positional argument but " args.Length " were given", -1)

        encoded := AhkStdlibBase64Encode(AhkStdlibBase64RequireBytesLike(args[1], "str"))
        if encoded = ""
            return AhkStdlibBase64Utf8Bytes("")
        return AhkStdlibBase64Utf8Bytes(AhkStdlibBase64WrapLines(encoded, 76))
    }

    static decodebytes(args*)
    {
        if args.Length = 0
            throw TypeError("decodebytes() missing 1 required positional argument: 's'", -1)
        if args.Length > 1
            throw TypeError("decodebytes() takes 1 positional argument but " args.Length " were given", -1)
        if args[1] is String
            throw TypeError("expected bytes-like object, not str", -1)
        return AhkStdlibBase64Decode(StrGet(AhkStdlibBase64RequireBytesLike(args[1]), args[1].Size, "UTF-8"))
    }

    static b16encode(args*)
    {
        if args.Length = 0
            throw TypeError("b16encode() missing 1 required positional argument: 's'", -1)
        if args.Length > 1
            throw TypeError("b16encode() takes 1 positional argument but " args.Length " were given", -1)
        return AhkStdlibBase64Utf8Bytes(AhkStdlibBase64HexUpper(AhkStdlibBase64RequireBytesLike(args[1], "str")))
    }

    static b16decode(args*)
    {
        if args.Length = 0
            throw TypeError("b16decode() missing 1 required positional argument: 's'", -1)
        if args.Length > 2
            throw TypeError("b16decode() takes from 1 to 2 positional arguments but " args.Length " were given", -1)

        source := AhkStdlibBase64RequireDecodeSource(args[1])
        casefold := args.Length >= 2 ? AhkStdlibTruthValue(args[2]) : false
        return AhkStdlibBase64DecodeBase16(source, casefold)
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

AhkStdlibBase64WrapLines(text, lineLength)
{
    output := ""
    offset := 1
    while offset <= StrLen(text) {
        output .= SubStr(text, offset, lineLength) "`n"
        offset += lineLength
    }
    return output
}

AhkStdlibBase64HexUpper(bytes)
{
    output := ""
    loop bytes.Size
        output .= Format("{:02X}", NumGet(bytes, A_Index - 1, "UChar"))
    return output
}

AhkStdlibBase64DecodeBase16(source, casefold)
{
    if Mod(StrLen(source), 2) != 0
        throw Error("Odd-length string", -1)

    normalized := casefold ? StrUpper(source) : source
    if !RegExMatch(normalized, "^[0-9A-F]*$")
        throw Error("Non-base16 digit found", -1)

    bytes := Buffer(StrLen(normalized) // 2, 0)
    loop bytes.Size {
        pair := SubStr(normalized, (A_Index - 1) * 2 + 1, 2)
        NumPut("UChar", Integer("0x" pair), bytes, A_Index - 1)
    }
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
