#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibUuid
{
    static UUID(args*)
    {
        if args.Length = 0
            throw TypeError("one of the hex, bytes, bytes_le, fields, or int arguments must be given", -1)
        if args.Length > 2
            throw TypeError("UUID.__init__() takes from 1 to 2 positional arguments but " args.Length " were given", -1)

        if args.Length = 1 && Type(args[1]) = "Object" {
            seen := false
            keywordHex := unset
            for key, value in args[1].OwnProps() {
                switch key {
                    case "hex":
                        if seen
                            throw TypeError("UUID.__init__() got multiple values for argument 'hex'", -1)
                        seen := true
                        keywordHex := value
                    default:
                        throw TypeError("UUID.__init__() got an unexpected keyword argument '" key "'", -1)
                }
            }
            if seen
                return AhkStdlibUuidFromHex(keywordHex)
        }

        keywordHex := unset
        if args.Length = 2 {
            if Type(args[2]) != "Object"
                throw TypeError("UUID.__init__() got an unexpected keyword argument '" AhkStdlibUuidUnexpectedKeywordName(args[2]) "'", -1)
            for key, value in args[2].OwnProps() {
                switch key {
                    case "hex":
                        keywordHex := value
                    default:
                        throw TypeError("UUID.__init__() got an unexpected keyword argument '" key "'", -1)
                }
            }
        }

        if args.Length >= 1 && IsSet(keywordHex)
            throw TypeError("UUID.__init__() got multiple values for argument 'hex'", -1)

        hexValue := IsSet(keywordHex) ? keywordHex : args[1]
        return AhkStdlibUuidFromHex(hexValue)
    }

    static uuid4(args*)
    {
        if args.Length = 1
            throw TypeError("uuid4() takes 0 positional arguments but 1 was given", -1)
        if args.Length > 1
            throw TypeError("uuid4() takes 0 positional arguments but " args.Length " were given", -1)

        guid := Buffer(16, 0)
        text := Buffer(39 * 2, 0)
        hr := DllCall("ole32\CoCreateGuid", "Ptr", guid, "UInt")
        if hr != 0
            throw OSError(hr, -1)
        DllCall("ole32\StringFromGUID2", "Ptr", guid, "Ptr", text, "Int", 39, "Int")
        return AhkStdlibUuidFromHex(StrGet(text))
    }
}

class AhkStdlibUuidValue
{
    __New(normalizedHex)
    {
        this.hex := normalizedHex
        this.variant := AhkStdlibUuidVariant(normalizedHex)
        this.version := AhkStdlibUuidVersion(normalizedHex)
        this.urn := "urn:uuid:" AhkStdlibUuidCanonicalString(normalizedHex)
    }

    ToString()
    {
        return AhkStdlibUuidCanonicalString(this.hex)
    }

    __Repr()
    {
        return "UUID('" this.ToString() "')"
    }
}

stdlib.uuid := AhkStdlibUuid

AhkStdlibUuidFromHex(hexValue)
{
    if Type(hexValue) != "String"
        throw AttributeError("'" AhkStdlibPythonTypeName(hexValue) "' object has no attribute 'replace'", -1)

    text := StrLower(hexValue)
    if SubStr(text, 1, 9) = "urn:uuid:"
        text := SubStr(text, 10)
    if SubStr(text, 1, 1) = "{"
        text := SubStr(text, 2, -1)
    normalized := StrReplace(text, "-", "")
    if StrLen(normalized) != 32
        throw ValueError("badly formed hexadecimal UUID string", -1)
    if RegExMatch(normalized, "[^0-9a-f]") > 0
        throw ValueError("invalid literal for int() with base 16: '" normalized "'", -1)
    return AhkStdlibUuidValue(normalized)
}

AhkStdlibUuidCanonicalString(normalizedHex)
{
    return SubStr(normalizedHex, 1, 8)
        . "-" SubStr(normalizedHex, 9, 4)
        . "-" SubStr(normalizedHex, 13, 4)
        . "-" SubStr(normalizedHex, 17, 4)
        . "-" SubStr(normalizedHex, 21, 12)
}

AhkStdlibUuidVariant(normalizedHex)
{
    nibble := Integer("0x" SubStr(normalizedHex, 17, 1))
    if nibble < 8
        return "reserved for NCS compatibility"
    if nibble < 12
        return "specified in RFC 4122"
    if nibble < 14
        return "reserved for Microsoft compatibility"
    return "reserved for future definition"
}

AhkStdlibUuidVersion(normalizedHex)
{
    if AhkStdlibUuidVariant(normalizedHex) != "specified in RFC 4122"
        return stdlib.None
    return Integer("0x" SubStr(normalizedHex, 13, 1))
}

AhkStdlibUuidUnexpectedKeywordName(value)
{
    if Type(value) = "String"
        return value
    return AhkStdlibPythonTypeName(value)
}
