#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibQuopri
{
    static encodestring(args*)
    {
        if args.Length = 0
            throw TypeError("encodestring() missing 1 required positional argument: 's'", -1)
        if args.Length > 3
            throw TypeError("encodestring() takes from 1 to 3 positional arguments but " args.Length " were given", -1)

        source := AhkStdlibQuopriRequireBytesLike(args[1], "str")
        quotetabs := args.Length >= 2 ? AhkStdlibQuopriCoerceIntFlag(args[2]) : false
        header := args.Length >= 3 ? AhkStdlibQuopriCoerceIntFlag(args[3]) : false

        return AhkStdlibQuopriEncode(source, quotetabs, header)
    }

    static decodestring(args*)
    {
        if args.Length = 0
            throw TypeError("decodestring() missing 1 required positional argument: 's'", -1)
        if args.Length > 2
            throw TypeError("decodestring() takes from 1 to 2 positional arguments but " args.Length " were given", -1)

        source := AhkStdlibQuopriRequireDecodeSource(args[1])
        header := args.Length >= 2 ? AhkStdlibQuopriCoerceIntFlag(args[2]) : false

        return AhkStdlibQuopriDecode(source, header)
    }

    static encode(args*)
    {
        if args.Length < 3 {
            missing := AhkStdlibQuopriMissingArgs(["input", "output", "quotetabs"], args.Length)
            throw TypeError("encode() missing " missing, -1)
        }
        if args.Length > 4
            throw TypeError("encode() takes from 3 to 4 positional arguments but " args.Length " were given", -1)

        input := args[1]
        output := args[2]
        quotetabs := AhkStdlibQuopriCoerceIntFlag(args[3])
        header := args.Length >= 4 ? AhkStdlibQuopriCoerceIntFlag(args[4]) : false

        data := AhkStdlibQuopriRequireBytesLike(input.read(), "str")
        output.write(AhkStdlibQuopriEncode(data, quotetabs, header))
        return stdlib.None
    }

    static decode(args*)
    {
        if args.Length < 2 {
            missing := AhkStdlibQuopriMissingArgs(["input", "output"], args.Length)
            throw TypeError("decode() missing " missing, -1)
        }
        if args.Length > 3
            throw TypeError("decode() takes from 2 to 3 positional arguments but " args.Length " were given", -1)

        input := args[1]
        output := args[2]
        header := args.Length >= 3 ? AhkStdlibQuopriCoerceIntFlag(args[3]) : false

        data := AhkStdlibQuopriRequireDecodeSource(input.read())
        output.write(AhkStdlibQuopriDecode(data, header))
        return stdlib.None
    }
}

stdlib.quopri := AhkStdlibQuopri

AhkStdlibQuopriRequireBytesLike(value, strTypeName := "str")
{
    if value is String
        throw TypeError("a bytes-like object is required, not '" strTypeName "'", -1)
    if !IsObject(value) || !HasProp(value, "Ptr") || !HasProp(value, "Size")
        throw TypeError("a bytes-like object is required, not '" AhkStdlibPythonTypeName(value) "'", -1)
    return value
}

AhkStdlibQuopriRequireDecodeSource(value)
{
    if value is String {
        loop parse value
            if Ord(A_LoopField) > 127
                throw ValueError("string argument should contain only ASCII characters", -1)
        return AhkStdlibQuopriUtf8Bytes(value)
    }
    if IsObject(value) && HasProp(value, "Ptr") && HasProp(value, "Size")
        return value
    throw TypeError("argument should be bytes, buffer or ASCII string, not '" AhkStdlibPythonTypeName(value) "'", -1)
}

AhkStdlibQuopriCoerceIntFlag(value)
{
    if AhkStdlibIsBool(value)
        return value.Value
    if AhkStdlibIsNone(value)
        throw TypeError("'NoneType' object cannot be interpreted as an integer", -1)
    if value is Integer
        return value != 0
    throw TypeError("'" AhkStdlibPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
}

AhkStdlibQuopriEncode(bytes, quotetabs, header)
{
    if bytes.Size = 0
        return Buffer(0)

    parts := []
    line := []
    lineLength := 0
    index := 0

    while index < bytes.Size {
        byte := NumGet(bytes, index, "UChar")

        if byte = 10 {
            AhkStdlibQuopriFlushEncodedLine(parts, line, &lineLength, 10)
            index += 1
            continue
        }

        if byte = 13 {
            if index + 1 < bytes.Size && NumGet(bytes, index + 1, "UChar") = 10 {
                AhkStdlibQuopriFlushEncodedLine(parts, line, &lineLength, 13, true)
                index += 2
                continue
            }
            AhkStdlibQuopriFlushEncodedLine(parts, line, &lineLength, 13)
            index += 1
            continue
        }

        token := AhkStdlibQuopriEncodeByte(bytes, index, quotetabs, header)
        tokenLength := StrLen(token)
        if lineLength + tokenLength > 75 && lineLength > 0 {
            parts.Push("=")
            parts.Push("`n")
            lineLength := 0
        }

        line.Push(token)
        lineLength += tokenLength
        index += 1
    }

    for _, token in line
        parts.Push(token)
    return AhkStdlibQuopriUtf8Bytes(AhkStdlibQuopriJoin(parts))
}

AhkStdlibQuopriEncodeByte(bytes, index, quotetabs, header)
{
    byte := NumGet(bytes, index, "UChar")
    nextByte := index + 1 < bytes.Size ? NumGet(bytes, index + 1, "UChar") : -1
    isLineEndNext := nextByte = -1 || nextByte = 10 || nextByte = 13

    if byte = 95 && header
        return AhkStdlibQuopriQuoteByte(byte)

    if byte = 32 || byte = 9 {
        if quotetabs || isLineEndNext
            return AhkStdlibQuopriQuoteByte(byte)
        if header && byte = 32
            return "_"
        return Chr(byte)
    }

    if byte = 61 || byte < 32 || byte > 126
        return AhkStdlibQuopriQuoteByte(byte)

    return Chr(byte)
}

AhkStdlibQuopriFlushEncodedLine(parts, line, &lineLength, newlineByte, hasTrailingLf := false)
{
    if line.Length > 0 {
        if line[line.Length] = " " || line[line.Length] = "`t"
            line[line.Length] := AhkStdlibQuopriQuoteByte(Ord(line[line.Length]))
        for _, token in line
            parts.Push(token)
        line.Length := 0
    }

    parts.Push(Chr(newlineByte))
    if hasTrailingLf
        parts.Push("`n")
    lineLength := 0
}

AhkStdlibQuopriDecode(bytes, header)
{
    if bytes.Size = 0
        return Buffer(0)

    parts := []
    index := 0
    while index < bytes.Size {
        byte := NumGet(bytes, index, "UChar")

        if header && byte = 95 {
            parts.Push(Chr(32))
            index += 1
            continue
        }

        if byte != 61 {
            parts.Push(Chr(byte))
            index += 1
            continue
        }

        if index + 1 >= bytes.Size
            break

        next := NumGet(bytes, index + 1, "UChar")
        if next = 61 {
            parts.Push("=")
            index += 2
            continue
        }

        if next = 10 {
            index += 2
            continue
        }

        if next = 13 {
            if index + 2 < bytes.Size && NumGet(bytes, index + 2, "UChar") = 10
                index += 3
            else
                index += 2
            continue
        }

        if index + 2 < bytes.Size {
            high := NumGet(bytes, index + 1, "UChar")
            low := NumGet(bytes, index + 2, "UChar")
            if AhkStdlibQuopriIsHexByte(high) && AhkStdlibQuopriIsHexByte(low) {
                parts.Push(Chr((AhkStdlibQuopriHexValue(high) * 16) + AhkStdlibQuopriHexValue(low)))
                index += 3
                continue
            }
        }

        parts.Push("=")
        index += 1
    }

    return AhkStdlibQuopriUtf8Bytes(AhkStdlibQuopriJoin(parts))
}

AhkStdlibQuopriQuoteByte(byte)
{
    static hex := "0123456789ABCDEF"
    return "=" SubStr(hex, (byte // 16) + 1, 1) SubStr(hex, Mod(byte, 16) + 1, 1)
}

AhkStdlibQuopriIsHexByte(byte)
{
    return (byte >= 48 && byte <= 57)
        || (byte >= 65 && byte <= 70)
        || (byte >= 97 && byte <= 102)
}

AhkStdlibQuopriHexValue(byte)
{
    if byte >= 48 && byte <= 57
        return byte - 48
    if byte >= 65 && byte <= 70
        return 10 + (byte - 65)
    return 10 + (byte - 97)
}

AhkStdlibQuopriJoin(parts)
{
    text := ""
    for _, part in parts
        text .= part
    return text
}

AhkStdlibQuopriUtf8Bytes(text)
{
    size := StrPut(text, "UTF-8") - 1
    bytes := Buffer(size, 0)
    if size > 0
        StrPut(text, bytes, "UTF-8")
    return bytes
}

AhkStdlibQuopriMissingArgs(names, given)
{
    needed := names.Length - given
    missing := []
    loop needed
        missing.Push("'" names[given + A_Index] "'")
    if missing.Length = 1
        return "1 required positional argument: " missing[1]
    if missing.Length = 2
        return "2 required positional arguments: " missing[1] " and " missing[2]
    head := ""
    loop missing.Length - 1 {
        if A_Index > 1
            head .= ", "
        head .= missing[A_Index]
    }
    return missing.Length " required positional arguments: " head ", and " missing[missing.Length]
}
