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

AhkStdlibBinasciiUtf8Bytes(text)
{
    size := StrPut(text, "UTF-8") - 1
    bytes := Buffer(size, 0)
    if size > 0
        StrPut(text, bytes, "UTF-8")
    return bytes
}
