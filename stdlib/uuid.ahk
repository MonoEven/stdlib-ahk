#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\hashlib>
#Include <stdlib\decimal>

class AhkStdlibUuid
{
    static NAMESPACE_DNS
    {
        get => AhkStdlibUuidNamespace("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
    }

    static NAMESPACE_URL
    {
        get => AhkStdlibUuidNamespace("6ba7b811-9dad-11d1-80b4-00c04fd430c8")
    }

    static NAMESPACE_OID
    {
        get => AhkStdlibUuidNamespace("6ba7b812-9dad-11d1-80b4-00c04fd430c8")
    }

    static NAMESPACE_X500
    {
        get => AhkStdlibUuidNamespace("6ba7b814-9dad-11d1-80b4-00c04fd430c8")
    }

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

    static uuid3(args*)
    {
        if args.Length < 2
            throw TypeError("uuid3() missing " (2 - args.Length) " required positional argument" (2 - args.Length = 1 ? "" : "s") ": " AhkStdlibUuidMissingArgNames(args.Length), -1)
        if args.Length > 2
            throw TypeError("uuid3() takes 2 positional arguments but " args.Length " were given", -1)
        return AhkStdlibUuidFromNamespace(args[1], args[2], "md5", 3)
    }

    static uuid5(args*)
    {
        if args.Length < 2
            throw TypeError("uuid5() missing " (2 - args.Length) " required positional argument" (2 - args.Length = 1 ? "" : "s") ": " AhkStdlibUuidMissingArgNames(args.Length), -1)
        if args.Length > 2
            throw TypeError("uuid5() takes 2 positional arguments but " args.Length " were given", -1)
        return AhkStdlibUuidFromNamespace(args[1], args[2], "sha1", 5)
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

    int
    {
        get => AhkStdlibUuidHexToDecimal(this.hex)
    }

    bytes
    {
        get => AhkStdlibUuidHexToBuffer(this.hex)
    }

    bytes_le
    {
        get => AhkStdlibUuidHexToBufferLe(this.hex)
    }

    fields
    {
        get => AhkStdlibUuidFields(this.hex)
    }

    time_low
    {
        get => Integer("0x" SubStr(this.hex, 1, 8))
    }

    time_mid
    {
        get => Integer("0x" SubStr(this.hex, 9, 4))
    }

    time_hi_version
    {
        get => Integer("0x" SubStr(this.hex, 13, 4))
    }

    clock_seq_hi_variant
    {
        get => Integer("0x" SubStr(this.hex, 17, 2))
    }

    clock_seq_low
    {
        get => Integer("0x" SubStr(this.hex, 19, 2))
    }

    node
    {
        get => Integer("0x" SubStr(this.hex, 21, 12))
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

AhkStdlibUuidNamespace(canonical)
{
    return AhkStdlibUuidFromHex(canonical)
}

AhkStdlibUuidMissingArgNames(givenCount)
{
    if givenCount = 0
        return "'namespace' and 'name'"
    return "'name'"
}

AhkStdlibUuidFromNamespace(namespace, name, algorithm, version)
{
    if !(namespace is AhkStdlibUuidValue)
        throw AttributeError("'" AhkStdlibPythonTypeName(namespace) "' object has no attribute 'bytes'", -1)

    nameBytes := AhkStdlibUuidNameToBuffer(name)
    namespaceBytes := AhkStdlibUuidHexToBuffer(namespace.hex)

    combined := Buffer(namespaceBytes.Size + nameBytes.Size, 0)
    loop namespaceBytes.Size
        NumPut("UChar", NumGet(namespaceBytes, A_Index - 1, "UChar"), combined, A_Index - 1)
    loop nameBytes.Size
        NumPut("UChar", NumGet(nameBytes, A_Index - 1, "UChar"), combined, namespaceBytes.Size + A_Index - 1)

    digest := stdlib.hashlib.new(algorithm, combined).digest()

    hexChars := ""
    loop 16
        hexChars .= Format("{:02x}", NumGet(digest, A_Index - 1, "UChar"))

    versionNibble := Format("{:x}", version)
    hexChars := SubStr(hexChars, 1, 12) versionNibble SubStr(hexChars, 14)
    variantByte := (Integer("0x" SubStr(hexChars, 17, 2)) & 0x3F) | 0x80
    hexChars := SubStr(hexChars, 1, 16) Format("{:02x}", variantByte) SubStr(hexChars, 19)
    return AhkStdlibUuidValue(hexChars)
}

AhkStdlibUuidNameToBuffer(name)
{
    if name is Buffer
        return name
    if !(name is String)
        throw TypeError("name must be a string or bytes-like object", -1)
    size := StrPut(name, "UTF-8") - 1
    bytes := Buffer(size < 0 ? 0 : size, 0)
    if size > 0
        StrPut(name, bytes, "UTF-8")
    return bytes
}

AhkStdlibUuidHexToBuffer(normalizedHex)
{
    bytes := Buffer(16, 0)
    loop 16
        NumPut("UChar", Integer("0x" SubStr(normalizedHex, (A_Index - 1) * 2 + 1, 2)), bytes, A_Index - 1)
    return bytes
}

AhkStdlibUuidHexToBufferLe(normalizedHex)
{
    ; bytes_le reverses the first three little-endian fields (4, 2, 2 bytes) then keeps the rest.
    bytes := AhkStdlibUuidHexToBuffer(normalizedHex)
    result := Buffer(16, 0)
    order := [4, 3, 2, 1, 6, 5, 8, 7, 9, 10, 11, 12, 13, 14, 15, 16]
    loop 16
        NumPut("UChar", NumGet(bytes, order[A_Index] - 1, "UChar"), result, A_Index - 1)
    return result
}

AhkStdlibUuidFields(normalizedHex)
{
    return stdlib.tuple([
        Integer("0x" SubStr(normalizedHex, 1, 8)),
        Integer("0x" SubStr(normalizedHex, 9, 4)),
        Integer("0x" SubStr(normalizedHex, 13, 4)),
        Integer("0x" SubStr(normalizedHex, 17, 2)),
        Integer("0x" SubStr(normalizedHex, 19, 2)),
        Integer("0x" SubStr(normalizedHex, 21, 12))
    ])
}

AhkStdlibUuidHexToDecimal(normalizedHex)
{
    ; Convert an arbitrary-length hex string to a decimal Decimal via string arithmetic,
    ; because the 128-bit value overflows AutoHotkey's native 64-bit integers.
    decimalDigits := [0]
    loop parse normalizedHex {
        nibble := Integer("0x" A_LoopField)
        carry := nibble
        index := 1
        while index <= decimalDigits.Length {
            product := decimalDigits[index] * 16 + carry
            decimalDigits[index] := Mod(product, 10)
            carry := product // 10
            index += 1
        }
        while carry > 0 {
            decimalDigits.Push(Mod(carry, 10))
            carry := carry // 10
        }
    }

    text := ""
    index := decimalDigits.Length
    while index >= 1 {
        text .= decimalDigits[index]
        index -= 1
    }
    if text = ""
        text := "0"
    return stdlib.decimal.Decimal(text)
}
