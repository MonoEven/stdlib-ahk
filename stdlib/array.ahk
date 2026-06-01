#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibArray
{
    static typecodes := "bBuhHiIlLqQfd"
    static array := AhkStdlibArrayType
}

class AhkStdlibArrayType
{
    static Call(thisClass, typecode, initializer := unset)
    {
        if !(typecode is String) || StrLen(typecode) != 1 || !InStr(AhkStdlibArray.typecodes, typecode)
            throw ValueError("bad typecode (must be b, B, u, h, H, i, I, l, L, q, Q, f or d)", -1)

        values := []
        if IsSet(initializer) {
            if initializer is String
                AhkStdlibArrayIterateInitializerChars(initializer, &values)
            else if IsObject(initializer) && HasMethod(initializer, "__Enum")
                AhkStdlibArrayCollectIterable(initializer, &values)
            else
                throw TypeError("'" AhkStdlibPythonTypeName(initializer) "' object is not iterable", -1)
        }

        return AhkStdlibArrayValue(typecode, values)
    }
}

class AhkStdlibArrayValue
{
    __New(typecode, values := unset)
    {
        info := AhkStdlibArrayTypeInfo(typecode)
        this.typecode := typecode
        this.itemsize := info.Size
        this.AhkStdlibStorageType := info.StorageType
        this.AhkStdlibElementKind := info.Kind
        this.AhkStdlibLength := 0
        this.AhkStdlibBuffer := Buffer(0)

        if IsSet(values) {
            for value in values
                this.append(value)
        }
    }

    __Item[index]
    {
        get {
            offset := this.AhkStdlibResolveIndex(index)
            return NumGet(this.AhkStdlibBuffer, offset, this.AhkStdlibStorageType)
        }
        set {
            offset := this.AhkStdlibResolveIndex(index)
            AhkStdlibArrayValidateValue(this.typecode, this.AhkStdlibElementKind, value)
            NumPut(this.AhkStdlibStorageType, value, this.AhkStdlibBuffer, offset)
        }
    }

    append(value)
    {
        AhkStdlibArrayValidateValue(this.typecode, this.AhkStdlibElementKind, value)
        oldLength := this.AhkStdlibLength
        this.AhkStdlibLength += 1
        this.AhkStdlibBuffer.Size := this.AhkStdlibLength * this.itemsize
        NumPut(this.AhkStdlibStorageType, value, this.AhkStdlibBuffer, oldLength * this.itemsize)
        return ""
    }

    extend(iterable)
    {
        values := []
        if iterable is String
            AhkStdlibArrayIterateInitializerChars(iterable, &values)
        else if IsObject(iterable) && HasMethod(iterable, "__Enum")
            AhkStdlibArrayCollectIterable(iterable, &values)
        else
            throw TypeError("'" AhkStdlibPythonTypeName(iterable) "' object is not iterable", -1)

        for value in values
            this.append(value)
        return ""
    }

    tolist()
    {
        values := []
        loop this.AhkStdlibLength
            values.Push(NumGet(this.AhkStdlibBuffer, (A_Index - 1) * this.itemsize, this.AhkStdlibStorageType))
        return values
    }

    buffer_info()
    {
        return stdlib.tuple([this.AhkStdlibBuffer.Ptr, this.AhkStdlibLength])
    }

    __Enum(numberOfVars)
    {
        index := 0
        source := this

        if numberOfVars = 2
            return NextPair
        return NextValue

        NextValue(&value)
        {
            if index >= source.AhkStdlibLength
                return false
            value := source[index]
            index += 1
            return true
        }

        NextPair(&key, &value)
        {
            if index >= source.AhkStdlibLength
                return false
            key := index
            value := source[index]
            index += 1
            return true
        }
    }

    __Repr()
    {
        if this.AhkStdlibLength = 0
            return "array('" this.typecode "')"
        return "array('" this.typecode "', " AhkStdlibArrayValueRepr(this.tolist()) ")"
    }

    AhkStdlibResolveIndex(index)
    {
        if !(index is Integer)
            throw TypeError("array indices must be integers", -1)
        if index < 0 || index >= this.AhkStdlibLength
            throw IndexError("array index out of range", -1)
        return index * this.itemsize
    }
}

stdlib.array := AhkStdlibArray

AhkStdlibArrayCollectIterable(iterable, &values)
{
    for value in iterable
        values.Push(value)
}

AhkStdlibArrayIterateInitializerChars(text, &values)
{
    loop parse text
        values.Push(A_LoopField)
}

AhkStdlibArrayTypeInfo(typecode)
{
    switch typecode {
        case "b":
            return { StorageType: "Char", Size: 1, Kind: "int" }
        case "B":
            return { StorageType: "UChar", Size: 1, Kind: "int" }
        case "u":
            return { StorageType: "UShort", Size: 2, Kind: "str" }
        case "h":
            return { StorageType: "Short", Size: 2, Kind: "int" }
        case "H":
            return { StorageType: "UShort", Size: 2, Kind: "int" }
        case "i":
            return { StorageType: "Int", Size: 4, Kind: "int" }
        case "I":
            return { StorageType: "UInt", Size: 4, Kind: "int" }
        case "l":
            return { StorageType: "Int", Size: 4, Kind: "int" }
        case "L":
            return { StorageType: "UInt", Size: 4, Kind: "int" }
        case "q":
            return { StorageType: "Int64", Size: 8, Kind: "int" }
        case "Q":
            return { StorageType: "Int64", Size: 8, Kind: "int" }
        case "f":
            return { StorageType: "Float", Size: 4, Kind: "float" }
        case "d":
            return { StorageType: "Double", Size: 8, Kind: "float" }
    }
    throw ValueError("bad typecode (must be b, B, u, h, H, i, I, l, L, q, Q, f or d)", -1)
}

AhkStdlibArrayValidateValue(typecode, kind, value)
{
    if kind = "str" {
        if !(value is String) || StrLen(value) != 1
            throw TypeError("array item must be unicode character", -1)
        return
    }

    if kind = "float" {
        if (value is Integer) || (value is Float)
            return
        throw TypeError("'" AhkStdlibPythonTypeName(value) "' object cannot be interpreted as a float", -1)
    }

    if (value is Integer) || AhkStdlibIsBool(value)
        return
    throw TypeError("'" AhkStdlibPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
}

AhkStdlibArrayValueRepr(values)
{
    parts := []
    for value in values
        parts.Push(AhkStdlibArrayScalarRepr(value))
    return "[" AhkStdlibArrayJoin(parts, ", ") "]"
}

AhkStdlibArrayScalarRepr(value)
{
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if value is String
        return "'" StrReplace(value, "'", "\'") "'"
    if value is Float {
        text := String(value)
        if !InStr(text, ".") && !InStr(text, "e") && !InStr(text, "E")
            text .= ".0"
        return text
    }
    return String(value)
}

AhkStdlibArrayJoin(values, delimiter)
{
    text := ""
    for index, value in values {
        if index > 1
            text .= delimiter
        text .= value
    }
    return text
}
