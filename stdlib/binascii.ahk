#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibBinasciiError extends Error
{
}

class AhkStdlibBinasciiIncomplete extends Error
{
}

class AhkStdlibBinascii
{
    static Error := AhkStdlibBinasciiError
    static Incomplete := AhkStdlibBinasciiIncomplete

    static hexlify(args*)
    {
        if args.Length = 0
            throw TypeError("hexlify() missing required argument 'data' (pos 1)", -1)
        if args.Length > 3
            throw TypeError("hexlify() takes at most 3 arguments (" args.Length " given)", -1)

        data := AhkStdlibBinasciiRequireBytesLike(args[1], "a bytes-like object is required, not 'str'")
        sep := args.Length >= 2 ? args[2] : stdlib.None
        bytesPerSep := args.Length >= 3 ? args[3] : 1

        return AhkStdlibBinasciiHexlify(data, sep, bytesPerSep)
    }

    static b2a_hex(args*)
    {
        return this.hexlify(args*)
    }

    static unhexlify(args*)
    {
        if args.Length != 1
            throw TypeError("binascii.unhexlify() takes exactly one argument (" args.Length " given)", -1)

        source := AhkStdlibBinasciiRequireHexSource(args[1])
        return AhkStdlibBinasciiUnhexlify(source)
    }

    static a2b_hex(args*)
    {
        return this.unhexlify(args*)
    }

    static b2a_base64(args*)
    {
        if args.Length = 0
            throw TypeError("b2a_base64() missing required argument 'data' (pos 1)", -1)
        if args.Length > 2
            throw TypeError("b2a_base64() takes at most 1 positional argument (" args.Length " given)", -1)

        data := AhkStdlibBinasciiRequireBytesLike(args[1])
        newline := true
        if args.Length = 2 {
            options := args[2]
            if Type(options) != "Object" || !options.HasOwnProp("newline")
                throw TypeError("b2a_base64() takes exactly 1 positional argument (" args.Length " given)", -1)
            newline := AhkStdlibTruthValue(options.newline)
        }

        encoded := AhkStdlibBinasciiBase64Encode(data)
        if newline
            encoded .= "`n"
        return AhkStdlibBinasciiUtf8Bytes(encoded)
    }

    static a2b_base64(args*)
    {
        if args.Length = 0
            throw TypeError("a2b_base64() missing required argument 'data' (pos 1)", -1)
        if args.Length > 1
            throw TypeError("a2b_base64() takes exactly 1 positional argument (" args.Length " given)", -1)

        source := AhkStdlibBinasciiRequireAsciiSource(args[1])
        return AhkStdlibBinasciiBase64Decode(source)
    }

    static crc32(args*)
    {
        if args.Length = 0
            throw TypeError("crc32 expected at least 1 argument, got 0", -1)
        if args.Length > 2
            throw TypeError("crc32 expected at most 2 arguments, got " args.Length, -1)

        data := AhkStdlibBinasciiRequireBytesLike(args[1])
        seed := args.Length = 2 ? AhkStdlibBinasciiInterpretIndex(args[2]) : 0
        return AhkStdlibBinasciiCrc32(data, seed)
    }
}

stdlib.binascii := AhkStdlibBinascii

AhkStdlibBinasciiRequireBytesLike(value, stringMessage := "")
{
    if value is String {
        if stringMessage != ""
            throw TypeError(stringMessage, -1)
        throw TypeError("a bytes-like object is required, not 'str'", -1)
    }
    if !IsObject(value) || !HasProp(value, "Ptr") || !HasProp(value, "Size")
        throw TypeError("a bytes-like object is required, not '" AhkStdlibPythonTypeName(value) "'", -1)
    return value
}

AhkStdlibBinasciiRequireHexSource(value)
{
    if value is String
        return value
    if AhkStdlibIsBool(value)
        throw TypeError("argument should be bytes, buffer or ASCII string, not 'bool'", -1)
    if IsObject(value) && HasProp(value, "Ptr") && HasProp(value, "Size")
        return StrGet(value, value.Size, "UTF-8")
    throw TypeError("argument should be bytes, buffer or ASCII string, not '" AhkStdlibPythonTypeName(value) "'", -1)
}

AhkStdlibBinasciiRequireAsciiSource(value)
{
    if value is String
        return value
    if AhkStdlibIsBool(value)
        throw TypeError("argument should be bytes, buffer or ASCII string, not 'bool'", -1)
    if IsObject(value) && HasProp(value, "Ptr") && HasProp(value, "Size")
        return StrGet(value, value.Size, "UTF-8")
    throw TypeError("argument should be bytes, buffer or ASCII string, not '" AhkStdlibPythonTypeName(value) "'", -1)
}

AhkStdlibBinasciiHexlify(data, sep, bytesPerSep)
{
    encoded := ""
    loop data.Size
        encoded .= Format("{:02x}", NumGet(data, A_Index - 1, "UChar"))

    if AhkStdlibIsNone(sep)
        return AhkStdlibBinasciiUtf8Bytes(encoded)

    if sep is String
        sepBytes := AhkStdlibBinasciiUtf8Bytes(sep)
    else if !IsObject(sep) || !HasProp(sep, "Ptr") || !HasProp(sep, "Size")
        throw TypeError("object of type '" AhkStdlibPythonTypeName(sep) "' has no len()", -1)
    else
        sepBytes := sep

    if sepBytes.Size != 1
        throw ValueError("sep must be length 1.", -1)
    sepText := StrGet(sepBytes, sepBytes.Size, "UTF-8")

    bytesPerSepInt := AhkStdlibBinasciiInterpretIndex(bytesPerSep)
    if bytesPerSepInt = 0
        return AhkStdlibBinasciiUtf8Bytes(encoded)
    return AhkStdlibBinasciiUtf8Bytes(AhkStdlibBinasciiGroupHex(encoded, sepText, bytesPerSepInt))
}

AhkStdlibBinasciiInterpretIndex(value)
{
    if value is Integer
        return value
    if AhkStdlibIsBool(value)
        return value.Value ? 1 : 0
    throw TypeError("'" AhkStdlibPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
}

AhkStdlibBinasciiGroupHex(encoded, separator, bytesPerSep)
{
    if bytesPerSep < 0
        bytesPerSep := -bytesPerSep
    if bytesPerSep = 0
        return encoded

    groupChars := bytesPerSep * 2
    if groupChars <= 0 || groupChars >= StrLen(encoded)
        return encoded

    segments := []
    segmentCount := 0
    start := 1
    while start <= StrLen(encoded) {
        segmentCount += 1
        segments.Push(SubStr(encoded, start, groupChars))
        start += groupChars
    }

    result := ""
    for index, segment in segments {
        if index > 1
            result .= separator
        result .= segment
    }
    return result
}

AhkStdlibBinasciiUnhexlify(source)
{
    if source = ""
        return Buffer(0)
    if Mod(StrLen(source), 2) != 0
        throw AhkStdlibBinasciiError("Odd-length string", -1)
    if RegExMatch(source, "[^0-9A-Fa-f]")
        throw AhkStdlibBinasciiError("Non-hexadecimal digit found", -1)

    size := StrLen(source) // 2
    bytes := Buffer(size, 0)
    loop size {
        offset := (A_Index - 1) * 2
        pair := SubStr(source, offset + 1, 2)
        NumPut("UChar", Integer("0x" pair), bytes, A_Index - 1)
    }
    return bytes
}

AhkStdlibBinasciiCrc32(data, seed)
{
    crc := DllCall("ntdll\RtlComputeCrc32"
        , "UInt", seed & 0xffffffff
        , "Ptr", data.Ptr
        , "UInt", data.Size
        , "UInt")
    return crc & 0xffffffff
}

AhkStdlibBinasciiBase64Encode(bytes)
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

AhkStdlibBinasciiBase64Decode(text)
{
    source := AhkStdlibBinasciiNormalizeBase64Input(text)
    if source = ""
        return Buffer(0)

    size := 0
    if !DllCall("crypt32\CryptStringToBinaryA"
        , "AStr", source
        , "UInt", 0
        , "UInt", 0x00000001
        , "Ptr", 0
        , "UInt*", &size
        , "Ptr", 0
        , "Ptr", 0
        , "Int")
        throw AhkStdlibBinasciiError("Incorrect padding", -1)

    bytes := Buffer(size, 0)
    if !DllCall("crypt32\CryptStringToBinaryA"
        , "AStr", source
        , "UInt", 0
        , "UInt", 0x00000001
        , "Ptr", bytes.Ptr
        , "UInt*", &size
        , "Ptr", 0
        , "Ptr", 0
        , "Int")
        throw AhkStdlibBinasciiError("Incorrect padding", -1)
    return bytes
}

AhkStdlibBinasciiNormalizeBase64Input(text)
{
    normalized := ""
    loop parse text {
        char := A_LoopField
        if RegExMatch(char, "^[A-Za-z0-9+/=]$")
            normalized .= char
    }
    return normalized
}

AhkStdlibBinasciiUtf8Bytes(text)
{
    size := StrPut(text, "UTF-8") - 1
    bytes := Buffer(size, 0)
    if size > 0
        StrPut(text, bytes, "UTF-8")
    return bytes
}
