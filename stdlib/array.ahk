#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibArray
{
    static typecodes := "bBuhHiIlLqQfd"
    static array := AhkStdlibArrayType
    static ArrayType := AhkStdlibArrayType
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
            return AhkStdlibArrayReadElement(this, offset)
        }
        set {
            offset := this.AhkStdlibResolveIndex(index)
            AhkStdlibArrayValidateValue(this.typecode, this.AhkStdlibElementKind, value)
            AhkStdlibArrayWriteElement(this, value, this.AhkStdlibBuffer, offset)
        }
    }

    __Len
    {
        get => this.AhkStdlibLength
    }

    __Compare(other, operation)
    {
        if !(other is AhkStdlibArrayValue)
            return ""

        sharedLength := this.AhkStdlibLength < other.AhkStdlibLength ? this.AhkStdlibLength : other.AhkStdlibLength
        loop sharedLength {
            index := A_Index - 1
            left := this[index]
            right := other[index]
            if !AhkStdlibArrayValuesEqual(left, right)
                return left < right ? -1 : 1
        }

        if this.AhkStdlibLength = other.AhkStdlibLength
            return 0
        return this.AhkStdlibLength < other.AhkStdlibLength ? -1 : 1
    }

    __Add(other)
    {
        if !(other is AhkStdlibArrayValue)
            return ""
        if this.typecode != other.typecode
            throw TypeError("bad argument type for built-in operation", -1)

        result := AhkStdlibArrayValue(this.typecode)
        for value in this
            result.append(value)
        for value in other
            result.append(value)
        return result
    }

    __Mul(count)
    {
        if AhkStdlibIsBool(count)
            count := count.Value ? 1 : 0
        if !(count is Integer)
            return ""

        result := AhkStdlibArrayValue(this.typecode)
        if count <= 0
            return result

        loop count {
            for value in this
                result.append(value)
        }
        return result
    }

    __Contains(value)
    {
        return this.count(value) > 0
    }

    __LengthHint()
    {
        return this.AhkStdlibLength
    }

    append(value)
    {
        AhkStdlibArrayValidateValue(this.typecode, this.AhkStdlibElementKind, value)
        oldLength := this.AhkStdlibLength
        this.AhkStdlibLength += 1
        this.AhkStdlibBuffer.Size := this.AhkStdlibLength * this.itemsize
        AhkStdlibArrayWriteElement(this, value, this.AhkStdlibBuffer, oldLength * this.itemsize)
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

    fromlist(iterable)
    {
        return AhkStdlibArrayReturnNone(this.extend(iterable))
    }

    insert(index, value)
    {
        if !(index is Integer)
            throw TypeError("'" AhkStdlibPythonTypeName(index) "' object cannot be interpreted as an integer", -1)
        AhkStdlibArrayValidateValue(this.typecode, this.AhkStdlibElementKind, value)
        if index < 0 {
            index += this.AhkStdlibLength
            if index < 0
                index := 0
        }
        if index > this.AhkStdlibLength
            index := this.AhkStdlibLength

        oldLength := this.AhkStdlibLength
        newBuffer := Buffer((oldLength + 1) * this.itemsize, 0)
        targetIndex := 0
        loop oldLength + 1 {
            if targetIndex = index {
                AhkStdlibArrayWriteElement(this, value, newBuffer, targetIndex * this.itemsize)
                targetIndex += 1
            }
            sourceIndex := A_Index - 1
            if sourceIndex < oldLength {
                sourceValue := AhkStdlibArrayReadStorage(this, sourceIndex * this.itemsize)
                NumPut(this.AhkStdlibStorageType, sourceValue, newBuffer, targetIndex * this.itemsize)
                targetIndex += 1
            }
        }
        this.AhkStdlibLength := oldLength + 1
        this.AhkStdlibBuffer := newBuffer
        return stdlib.None
    }

    tobytes()
    {
        bytes := Buffer(this.AhkStdlibBuffer.Size, 0)
        if bytes.Size > 0
            DllCall("RtlMoveMemory", "Ptr", bytes.Ptr, "Ptr", this.AhkStdlibBuffer.Ptr, "UPtr", bytes.Size)
        return bytes
    }

    frombytes(bytes)
    {
        if bytes is String
            throw TypeError("a bytes-like object is required, not 'str'", -1)
        if !IsObject(bytes) || !HasProp(bytes, "Ptr") || !HasProp(bytes, "Size")
            throw TypeError("a bytes-like object is required, not '" AhkStdlibPythonTypeName(bytes) "'", -1)
        if Mod(bytes.Size, this.itemsize) != 0
            throw ValueError("bytes length not a multiple of item size", -1)

        count := bytes.Size // this.itemsize
        loop count {
            offset := (A_Index - 1) * this.itemsize
            value := NumGet(bytes, offset, this.AhkStdlibStorageType)
            this.AhkStdlibAppendStorageValue(value)
        }
        return stdlib.None
    }

    byteswap()
    {
        if !(this.itemsize = 1 || this.itemsize = 2 || this.itemsize = 4 || this.itemsize = 8)
            throw RuntimeError("don't know how to byteswap this array type", -1)
        if this.itemsize = 1
            return stdlib.None

        loop this.AhkStdlibLength {
            elementOffset := (A_Index - 1) * this.itemsize
            left := 0
            right := this.itemsize - 1
            while left < right {
                leftValue := NumGet(this.AhkStdlibBuffer, elementOffset + left, "UChar")
                rightValue := NumGet(this.AhkStdlibBuffer, elementOffset + right, "UChar")
                NumPut("UChar", rightValue, this.AhkStdlibBuffer, elementOffset + left)
                NumPut("UChar", leftValue, this.AhkStdlibBuffer, elementOffset + right)
                left += 1
                right -= 1
            }
        }
        return stdlib.None
    }

    fromunicode(text)
    {
        if this.typecode != "u"
            throw ValueError("fromunicode() may only be called on unicode type arrays", -1)
        if !(text is String)
            throw TypeError("can only extend array with unicode string", -1)
        loop parse text
            this.append(A_LoopField)
        return stdlib.None
    }

    tounicode()
    {
        if this.typecode != "u"
            throw ValueError("tounicode() may only be called on unicode type arrays", -1)
        text := ""
        loop this.AhkStdlibLength
            text .= this[A_Index - 1]
        return text
    }

    tofile(file)
    {
        bytes := this.tobytes()
        handle := AhkStdlibArrayOpenBinaryFile(file, "w", &closeAfter)
        try {
            if bytes.Size > 0
                handle.RawWrite(bytes, bytes.Size)
        } finally {
            if closeAfter
                handle.Close()
        }
        return stdlib.None
    }

    fromfile(file, n)
    {
        if !(n is Integer)
            throw TypeError("'" AhkStdlibPythonTypeName(n) "' object cannot be interpreted as an integer", -1)
        if n < 0
            throw ValueError("negative count", -1)

        bytesToRead := n * this.itemsize
        bytes := Buffer(bytesToRead, 0)
        handle := AhkStdlibArrayOpenBinaryFile(file, "r", &closeAfter)
        try {
            bytesRead := bytesToRead = 0 ? 0 : handle.RawRead(bytes, bytesToRead)
        } finally {
            if closeAfter
                handle.Close()
        }
        if bytesRead != bytesToRead
            throw Error("read() didn't return enough bytes", -1)
        return this.frombytes(bytes)
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
            values.Push(this[A_Index - 1])
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
            value := AhkStdlibArrayReadStorage(this, sourceIndex * this.itemsize)
            NumPut(this.AhkStdlibStorageType, value, newBuffer, targetIndex * this.itemsize)
            targetIndex += 1
        }
        this.AhkStdlibLength -= 1
        this.AhkStdlibBuffer := newBuffer
    }

    AhkStdlibAppendStorageValue(value)
    {
        oldLength := this.AhkStdlibLength
        this.AhkStdlibLength += 1
        this.AhkStdlibBuffer.Size := this.AhkStdlibLength * this.itemsize
        NumPut(this.AhkStdlibStorageType, value, this.AhkStdlibBuffer, oldLength * this.itemsize)
    }
}

stdlib.array := AhkStdlibArray

AhkStdlibArrayCollectIterable(iterable, &values)
{
    for value in iterable
        values.Push(value)
}

AhkStdlibArrayReturnNone(value)
{
    return stdlib.None
}

AhkStdlibArrayReadStorage(arrayValue, offset)
{
    return NumGet(arrayValue.AhkStdlibBuffer, offset, arrayValue.AhkStdlibStorageType)
}

AhkStdlibArrayReadElement(arrayValue, offset)
{
    value := AhkStdlibArrayReadStorage(arrayValue, offset)
    if arrayValue.typecode = "u"
        return Chr(value)
    return value
}

AhkStdlibArrayWriteElement(arrayValue, value, buffer, offset)
{
    storageValue := arrayValue.typecode = "u" ? Ord(value) : value
    NumPut(arrayValue.AhkStdlibStorageType, storageValue, buffer, offset)
}

AhkStdlibArrayOpenBinaryFile(file, mode, &closeAfter)
{
    closeAfter := false
    if file is String {
        closeAfter := true
        return FileOpen(file, mode)
    }
    if IsObject(file) && HasMethod(file, "RawRead") && HasMethod(file, "RawWrite")
        return file
    if IsObject(file) && mode = "r" && HasMethod(file, "RawRead")
        return file
    if IsObject(file) && mode = "w" && HasMethod(file, "RawWrite")
        return file
    throw TypeError("file must have 'read' and 'write' attributes", -1)
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
