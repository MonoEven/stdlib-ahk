#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\assert>

class AhkStdlibBase64
{
    static MAXBINSIZE := 57
    static MAXLINESIZE := 76

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

    static b32encode(args*)
    {
        if args.Length = 0
            throw TypeError("b32encode() missing 1 required positional argument: 's'", -1)
        if args.Length > 1
            throw TypeError("b32encode() takes 1 positional argument but " args.Length " were given", -1)
        return AhkStdlibBase64Utf8Bytes(AhkStdlibBase64EncodeBase32(AhkStdlibBase64RequireBytesLike(args[1], "str"), "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"))
    }

    static b32decode(args*)
    {
        if args.Length = 0
            throw TypeError("b32decode() missing 1 required positional argument: 's'", -1)
        if args.Length > 3
            throw TypeError("b32decode() takes from 1 to 3 positional arguments but " args.Length " were given", -1)

        source := AhkStdlibBase64RequireDecodeSource(args[1])
        casefold := args.Length >= 2 ? AhkStdlibTruthValue(args[2]) : false
        map01 := args.Length >= 3 ? args[3] : stdlib.None
        return AhkStdlibBase64DecodeBase32(source, "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567", casefold, map01)
    }

    static b32hexencode(args*)
    {
        if args.Length = 0
            throw TypeError("b32hexencode() missing 1 required positional argument: 's'", -1)
        if args.Length > 1
            throw TypeError("b32hexencode() takes 1 positional argument but " args.Length " were given", -1)
        return AhkStdlibBase64Utf8Bytes(AhkStdlibBase64EncodeBase32(AhkStdlibBase64RequireBytesLike(args[1], "str"), "0123456789ABCDEFGHIJKLMNOPQRSTUV"))
    }

    static b32hexdecode(args*)
    {
        if args.Length = 0
            throw TypeError("b32hexdecode() missing 1 required positional argument: 's'", -1)
        if args.Length > 2
            throw TypeError("b32hexdecode() takes from 1 to 2 positional arguments but " args.Length " were given", -1)

        source := AhkStdlibBase64RequireDecodeSource(args[1])
        casefold := args.Length >= 2 ? AhkStdlibTruthValue(args[2]) : false
        return AhkStdlibBase64DecodeBase32(source, "0123456789ABCDEFGHIJKLMNOPQRSTUV", casefold, stdlib.None)
    }

    static b85encode(args*)
    {
        if args.Length = 0
            throw TypeError("b85encode() missing 1 required positional argument: 'b'", -1)
        if args.Length > 2
            throw TypeError("b85encode() takes from 1 to 2 positional arguments but " args.Length " were given", -1)

        pad := args.Length >= 2 ? AhkStdlibTruthValue(args[2]) : false
        encoded := AhkStdlibBase64EncodeBase85(AhkStdlibBase64RequireBytesLike(args[1], "str"), AhkStdlibBase64B85Alphabet(), { pad: pad })
        return AhkStdlibBase64Utf8Bytes(encoded)
    }

    static b85decode(args*)
    {
        if args.Length = 0
            throw TypeError("b85decode() missing 1 required positional argument: 'b'", -1)
        if args.Length > 1
            throw TypeError("b85decode() takes 1 positional argument but " args.Length " were given", -1)

        source := AhkStdlibBase64RequireDecodeSource(args[1])
        return AhkStdlibBase64DecodeBase85(source, AhkStdlibBase64B85Alphabet(), {})
    }

    static a85encode(args*)
    {
        if args.Length = 0
            throw TypeError("a85encode() missing 1 required positional argument: 'b'", -1)
        if args.Length > 2
            throw TypeError("a85encode() takes from 1 to 2 positional arguments but " args.Length " were given", -1)

        options := args.Length >= 2 && IsObject(args[2]) ? args[2] : {}
        foldspaces := HasProp(options, "foldspaces") ? AhkStdlibTruthValue(options.foldspaces) : false
        pad := HasProp(options, "pad") ? AhkStdlibTruthValue(options.pad) : false
        adobe := HasProp(options, "adobe") ? AhkStdlibTruthValue(options.adobe) : false
        encoded := AhkStdlibBase64EncodeBase85(AhkStdlibBase64RequireBytesLike(args[1], "str"), AhkStdlibBase64A85Alphabet(), { pad: pad, foldspaces: foldspaces, ascii85: true })
        if adobe
            encoded := "<~" encoded "~>"
        return AhkStdlibBase64Utf8Bytes(encoded)
    }

    static a85decode(args*)
    {
        if args.Length = 0
            throw TypeError("a85decode() missing 1 required positional argument: 'b'", -1)
        if args.Length > 2
            throw TypeError("a85decode() takes from 1 to 2 positional arguments but " args.Length " were given", -1)

        options := args.Length >= 2 && IsObject(args[2]) ? args[2] : {}
        foldspaces := HasProp(options, "foldspaces") ? AhkStdlibTruthValue(options.foldspaces) : false
        adobe := HasProp(options, "adobe") ? AhkStdlibTruthValue(options.adobe) : false
        source := AhkStdlibBase64RequireDecodeSource(args[1])
        return AhkStdlibBase64DecodeBase85(source, AhkStdlibBase64A85Alphabet(), { foldspaces: foldspaces, adobe: adobe, ascii85: true })
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

AhkStdlibBase64EncodeBase32(bytes, alphabet)
{
    if bytes.Size = 0
        return ""

    output := ""
    bitBuffer := 0
    bitCount := 0
    loop bytes.Size {
        bitBuffer := (bitBuffer << 8) | NumGet(bytes, A_Index - 1, "UChar")
        bitCount += 8
        while bitCount >= 5 {
            bitCount -= 5
            output .= SubStr(alphabet, ((bitBuffer >> bitCount) & 31) + 1, 1)
        }
    }

    if bitCount > 0
        output .= SubStr(alphabet, ((bitBuffer << (5 - bitCount)) & 31) + 1, 1)

    while Mod(StrLen(output), 8) != 0
        output .= "="
    return output
}

AhkStdlibBase64DecodeBase32(source, alphabet, casefold, map01)
{
    if casefold
        source := StrUpper(source)

    if !AhkStdlibIsNone(map01) {
        mapChar := AhkStdlibBase64Map01Char(map01)
        source := StrReplace(source, "0", "O")
        source := StrReplace(source, "1", mapChar)
    }

    if Mod(StrLen(source), 8) != 0
        throw Error("Incorrect padding", -1)

    firstPad := InStr(source, "=")
    if firstPad > 0 {
        data := SubStr(source, 1, firstPad - 1)
        padding := SubStr(source, firstPad)
        if !RegExMatch(padding, "^=*$")
            throw Error("Non-base32 digit found", -1)
        paddingLength := StrLen(padding)
    } else {
        data := source
        paddingLength := 0
    }

    if !(paddingLength = 0 || paddingLength = 1 || paddingLength = 3 || paddingLength = 4 || paddingLength = 6)
        throw Error("Incorrect padding", -1)

    values := []
    bitBuffer := 0
    bitCount := 0
    loop StrLen(data) {
        char := SubStr(data, A_Index, 1)
        index := InStr(alphabet, char, true)
        if index = 0
            throw Error("Non-base32 digit found", -1)
        bitBuffer := (bitBuffer << 5) | (index - 1)
        bitCount += 5
        while bitCount >= 8 {
            bitCount -= 8
            values.Push((bitBuffer >> bitCount) & 0xff)
        }
    }

    return AhkStdlibBase64BytesFromValues(values)
}

AhkStdlibBase64Map01Char(value)
{
    if value is String {
        if StrLen(value) != 1
            throw stdlib.assert.AssertionError("'" value "'", -1)
        return StrUpper(value)
    }

    bytes := AhkStdlibBase64RequireBytesLike(value)
    if bytes.Size != 1
        throw stdlib.assert.AssertionError("b'" StrGet(bytes, bytes.Size, "UTF-8") "'", -1)
    return StrUpper(Chr(NumGet(bytes, 0, "UChar")))
}

AhkStdlibBase64BytesFromValues(values)
{
    bytes := Buffer(values.Length, 0)
    for index, value in values
        NumPut("UChar", value, bytes, index - 1)
    return bytes
}

AhkStdlibBase64B85Alphabet()
{
    return "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+-;<=>?@^_``{|}~"
}

AhkStdlibBase64A85Alphabet()
{
    output := ""
    loop 85
        output .= Chr(32 + A_Index)
    return output
}

AhkStdlibBase64EncodeBase85(bytes, alphabet, options)
{
    if bytes.Size = 0
        return ""

    pad := HasProp(options, "pad") ? options.pad : false
    ascii85 := HasProp(options, "ascii85") ? options.ascii85 : false
    foldspaces := HasProp(options, "foldspaces") ? options.foldspaces : false
    output := ""
    offset := 0
    while offset < bytes.Size {
        chunkLength := Min(4, bytes.Size - offset)
        value := 0
        loop 4 {
            byte := A_Index <= chunkLength ? NumGet(bytes, offset + A_Index - 1, "UChar") : 0
            value := (value << 8) | byte
        }

        if ascii85 && chunkLength = 4 && value = 0 {
            output .= "z"
        } else if ascii85 && foldspaces && chunkLength = 4 && value = 0x20202020 {
            output .= "y"
        } else {
            encoded := AhkStdlibBase64EncodeBase85Chunk(value, alphabet)
            if chunkLength < 4 && !pad
                encoded := SubStr(encoded, 1, chunkLength + 1)
            output .= encoded
        }
        offset += chunkLength
    }
    return output
}

AhkStdlibBase64EncodeBase85Chunk(value, alphabet)
{
    chars := []
    loop 5 {
        digit := Mod(value, 85)
        chars.InsertAt(1, SubStr(alphabet, digit + 1, 1))
        value := value // 85
    }
    output := ""
    for char in chars
        output .= char
    return output
}

AhkStdlibBase64DecodeBase85(source, alphabet, options)
{
    ascii85 := HasProp(options, "ascii85") ? options.ascii85 : false
    foldspaces := HasProp(options, "foldspaces") ? options.foldspaces : false
    if ascii85 {
        source := AhkStdlibBase64A85NormalizeSource(source)
        if HasProp(options, "adobe") && options.adobe {
            if StrLen(source) >= 4 && SubStr(source, 1, 2) = "<~" && SubStr(source, StrLen(source) - 1, 2) = "~>"
                source := SubStr(source, 3, StrLen(source) - 4)
        }
    }

    outputValues := []
    group := ""
    loop StrLen(source) {
        char := SubStr(source, A_Index, 1)
        if ascii85 && char = "z" {
            if group != ""
                throw Error("z inside Ascii85 5-tuple", -1)
            AhkStdlibBase64AppendUInt32Bytes(outputValues, 0)
            continue
        }
        if ascii85 && foldspaces && char = "y" {
            if group != ""
                throw Error("y inside Ascii85 5-tuple", -1)
            AhkStdlibBase64AppendUInt32Bytes(outputValues, 0x20202020)
            continue
        }

        if InStr(alphabet, char, true) = 0
            throw Error("Non-Ascii85 digit found", -1)
        group .= char
        if StrLen(group) = 5 {
            AhkStdlibBase64AppendUInt32Bytes(outputValues, AhkStdlibBase64DecodeBase85Group(group, alphabet))
            group := ""
        }
    }

    if group != "" {
        groupLength := StrLen(group)
        if groupLength = 1
            throw Error("Base85 overflow in hunk starting at byte 0", -1)
        padChar := SubStr(alphabet, 85, 1)
        loop 5 - groupLength
            group .= padChar
        value := AhkStdlibBase64DecodeBase85Group(group, alphabet)
        bytes := AhkStdlibBase64UInt32ByteValues(value)
        loop groupLength - 1
            outputValues.Push(bytes[A_Index])
    }

    return AhkStdlibBase64BytesFromValues(outputValues)
}

AhkStdlibBase64A85NormalizeSource(source)
{
    normalized := ""
    loop StrLen(source) {
        char := SubStr(source, A_Index, 1)
        if char = " " || char = "`t" || char = "`n" || char = "`r" || char = Chr(11)
            continue
        normalized .= char
    }
    return normalized
}

AhkStdlibBase64DecodeBase85Group(group, alphabet)
{
    value := 0
    loop StrLen(group) {
        char := SubStr(group, A_Index, 1)
        index := InStr(alphabet, char, true)
        if index = 0
            throw Error("Non-Ascii85 digit found", -1)
        value := value * 85 + index - 1
    }
    if value > 0xffffffff
        throw Error("Base85 overflow in hunk starting at byte 0", -1)
    return value
}

AhkStdlibBase64AppendUInt32Bytes(values, value)
{
    bytes := AhkStdlibBase64UInt32ByteValues(value)
    for byte in bytes
        values.Push(byte)
}

AhkStdlibBase64UInt32ByteValues(value)
{
    return [
        (value >> 24) & 0xff,
        (value >> 16) & 0xff,
        (value >> 8) & 0xff,
        value & 0xff,
    ]
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
