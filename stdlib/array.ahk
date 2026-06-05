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

    count(args*)
    {
        if args.Length != 1
            throw TypeError("array.count() takes exactly one argument (" args.Length " given)", -1)
        needle := args[1]
        total := 0
        loop this.AhkStdlibLength {
            if AhkStdlibArrayValuesEqual(this[A_Index - 1], needle)
                total += 1
        }
        return total
    }

    index(args*)
    {
        if args.Length = 0
            throw TypeError("array.index() takes exactly one argument (0 given)", -1)
        if args.Length > 1
            throw TypeError("array.index() takes exactly one argument (" args.Length " given)", -1)
        needle := args[1]
        loop this.AhkStdlibLength {
            index := A_Index - 1
            if AhkStdlibArrayValuesEqual(this[index], needle)
                return index
        }
        throw ValueError("array.index(x): x not in array", -1)
    }

    remove(args*)
    {
        if args.Length = 0
            throw TypeError("array.remove() takes exactly one argument (0 given)", -1)
        if args.Length > 1
            throw TypeError("array.remove() takes exactly one argument (" args.Length " given)", -1)
        needle := args[1]
        loop this.AhkStdlibLength {
            index := A_Index - 1
            if AhkStdlibArrayValuesEqual(this[index], needle) {
                this.AhkStdlibDeleteIndex(index)
                return stdlib.None
            }
        }
        throw ValueError("array.remove(x): x not in array", -1)
    }

    pop(args*)
    {
        if args.Length > 1
            throw TypeError("pop expected at most 1 argument, got " args.Length, -1)
        if this.AhkStdlibLength = 0
            throw IndexError("pop from empty array", -1)
        index := args.Length = 0 ? this.AhkStdlibLength - 1 : args[1]
        if !(index is Integer)
            throw TypeError("'" AhkStdlibPythonTypeName(index) "' object cannot be interpreted as an integer", -1)
        if index < 0
            index += this.AhkStdlibLength
        if index < 0 || index >= this.AhkStdlibLength
            throw IndexError("pop index out of range", -1)
        value := this[index]
        this.AhkStdlibDeleteIndex(index)
        return value
    }

    reverse(args*)
    {
        if args.Length != 0
            throw TypeError("array.reverse() takes no arguments (" args.Length " given)", -1)
        left := 0
        right := this.AhkStdlibLength - 1
        while left < right {
            leftValue := this[left]
            this[left] := this[right]
            this[right] := leftValue
            left += 1
            right -= 1
        }
        return stdlib.None
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

    AhkStdlibDeleteIndex(index)
    {
        newBuffer := Buffer((this.AhkStdlibLength - 1) * this.itemsize)
        targetIndex := 0
        loop this.AhkStdlibLength {
            sourceIndex := A_Index - 1
            if sourceIndex = index
                continue
            value := NumGet(this.AhkStdlibBuffer, sourceIndex * this.itemsize, this.AhkStdlibStorageType)
            NumPut(this.AhkStdlibStorageType, value, newBuffer, targetIndex * this.itemsize)
            targetIndex += 1
        }
        this.AhkStdlibLength -= 1
        this.AhkStdlibBuffer := newBuffer
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

AhkStdlibArrayValuesEqual(left, right)
{
    if IsObject(left) || IsObject(right)
        return left = right
    return left == right
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
