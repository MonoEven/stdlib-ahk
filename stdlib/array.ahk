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
            if initializer is String {
                if typecode != "u"
                    throw TypeError("cannot use a str to initialize an array with typecode '" typecode "'", -1)
                AhkStdlibArrayIterateInitializerChars(initializer, &values)
            } else if AhkStdlibArrayIsBytesLike(initializer) {
                result := AhkStdlibArrayValue(typecode)
                result.frombytes(initializer)
                return result
            } else if IsObject(initializer) && HasMethod(initializer, "__Enum")
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
        this.AhkStdlibTypecode := typecode
        this.AhkStdlibItemsize := info.Size
        this.AhkStdlibStorageType := info.StorageType
        this.AhkStdlibElementKind := info.Kind
        this.AhkStdlibLength := 0
        this.AhkStdlibBuffer := Buffer(0)

        if IsSet(values) {
            for value in values
                this.append(value)
        }
    }

    typecode
    {
        get => this.AhkStdlibTypecode
        set
        {
            throw stdlib.AttributeError("attribute 'typecode' of 'array.array' objects is not writable", -1)
        }
    }

    itemsize
    {
        get => this.AhkStdlibItemsize
        set
        {
            throw stdlib.AttributeError("attribute 'itemsize' of 'array.array' objects is not writable", -1)
        }
    }

    __Item[index]
    {
        get {
            if index is AhkStdlibSlice
                return AhkStdlibArrayGetSlice(this, index)
            offset := this.AhkStdlibResolveIndex(index)
            return AhkStdlibArrayReadElement(this, offset)
        }
        set {
            if index is AhkStdlibSlice
                return AhkStdlibArraySetSlice(this, index, value)
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

    __iadd(other)
    {
        if !(other is AhkStdlibArrayValue)
            throw TypeError("can only extend array with array (not `"" AhkStdlibPythonTypeName(other) "`")", -1)
        if this.typecode != other.typecode
            throw TypeError("can only extend with array of same kind", -1)
        this.extend(other)
        return this
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

    __imul(count)
    {
        count := AhkStdlibArrayNormalizeScalar(count)
        if !(count is Integer)
            throw TypeError("'" AhkStdlibPythonTypeName(count) "' object cannot be interpreted as an integer", -1)

        result := this.__Mul(count)
        AhkStdlibArrayAdopt(this, result)
        return this
    }

    __rmul(count)
    {
        return this.__Mul(count)
    }

    __Contains(value)
    {
        return this.count(value) > 0
    }

    __LengthHint()
    {
        return this.AhkStdlibLength
    }

    __copy()
    {
        return AhkStdlibArrayCloneValue(this)
    }

    __deepcopy(memo)
    {
        ptr := ObjPtr(this)
        if memo.Has(ptr)
            return memo[ptr]
        result := AhkStdlibArrayCloneValue(this)
        memo[ptr] := result
        return result
    }

    append(value)
    {
        AhkStdlibArrayValidateValue(this.typecode, this.AhkStdlibElementKind, value)
        oldLength := this.AhkStdlibLength
        this.AhkStdlibLength += 1
        this.AhkStdlibBuffer.Size := this.AhkStdlibLength * this.itemsize
        AhkStdlibArrayWriteElement(this, value, this.AhkStdlibBuffer, oldLength * this.itemsize)
        return stdlib.None
    }

    extend(iterable)
    {
        values := []
        if iterable is AhkStdlibArrayValue {
            if iterable.typecode != this.typecode
                throw TypeError("can only extend with array of same kind", -1)
            AhkStdlibArrayCollectIterable(iterable, &values)
        } else if AhkStdlibArrayIsBytesLike(iterable) {
            AhkStdlibArrayCollectBytes(iterable, &values)
        } else if iterable is String
            AhkStdlibArrayIterateInitializerChars(iterable, &values)
        else if IsObject(iterable) && HasMethod(iterable, "__Enum")
            AhkStdlibArrayCollectIterable(iterable, &values)
        else
            throw TypeError("'" AhkStdlibPythonTypeName(iterable) "' object is not iterable", -1)

        for value in values
            this.append(value)
        return stdlib.None
    }

    fromlist(iterable)
    {
        if Type(iterable) != "Array"
            throw TypeError("arg must be list", -1)
        return AhkStdlibArrayReturnNone(this.extend(iterable))
    }

    insert(index, value)
    {
        index := AhkStdlibArrayNormalizeScalar(index)
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
        if !AhkStdlibArrayIsBytesLike(bytes)
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
        if bytesRead != bytesToRead {
            bytes.Size := bytesRead
            this.frombytes(bytes)
            throw EOFError("read() didn't return enough bytes", -1)
        }
        return this.frombytes(bytes)
    }

    count(args*)
    {
        if args.Length != 1
            throw TypeError("array.count() takes exactly one argument (" args.Length " given)", -1)
        needle := args[1]
        total := 0
        loop this.AhkStdlibLength {
            if AhkStdlibArrayElementEquals(this, this[A_Index - 1], needle)
                total += 1
        }
        return total
    }

    index(args*)
    {
        if args.Length = 0
            throw TypeError("index expected at least 1 argument, got 0", -1)
        if args.Length > 3
            throw TypeError("index expected at most 3 arguments, got " args.Length, -1)
        needle := args[1]
        start := args.Length >= 2 ? AhkStdlibArrayIndexBound(args[2], this.AhkStdlibLength) : 0
        stop := args.Length >= 3 ? AhkStdlibArrayIndexBound(args[3], this.AhkStdlibLength) : this.AhkStdlibLength
        index := start
        while index < stop {
            if AhkStdlibArrayElementEquals(this, this[index], needle)
                return index
            index += 1
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
            if AhkStdlibArrayElementEquals(this, this[index], needle) {
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
        index := AhkStdlibArrayNormalizeScalar(index)
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

    Delete(index)
    {
        if index is AhkStdlibSlice
            return AhkStdlibArrayDeleteSlice(this, index)
        offset := this.AhkStdlibResolveIndex(index)
        this.AhkStdlibDeleteIndex(offset // this.itemsize)
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
        if this.typecode = "u"
            return "array('u', " AhkStdlibArrayStringRepr(this.tounicode()) ")"
        return "array('" this.typecode "', " AhkStdlibArrayValueRepr(this.tolist()) ")"
    }

    AhkStdlibResolveIndex(index)
    {
        index := AhkStdlibArrayNormalizeScalar(index)
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

AhkStdlibArrayCollectBytes(bytes, &values)
{
    loop bytes.Size
        values.Push(NumGet(bytes, A_Index - 1, "UChar"))
}

AhkStdlibArrayIsBytesLike(value)
{
    return IsObject(value) && HasProp(value, "Ptr") && HasProp(value, "Size")
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
    storageValue := arrayValue.typecode = "u" ? Ord(value) : AhkStdlibArrayNormalizeScalar(value)
    NumPut(arrayValue.AhkStdlibStorageType, storageValue, buffer, offset)
}

AhkStdlibArrayCloneValue(arrayValue)
{
    result := AhkStdlibArrayValue(arrayValue.typecode)
    result.AhkStdlibLength := arrayValue.AhkStdlibLength
    result.AhkStdlibBuffer := arrayValue.tobytes()
    return result
}

AhkStdlibArrayGetSlice(arrayValue, sliceObject)
{
    result := AhkStdlibArrayValue(arrayValue.typecode)
    for index in AhkStdlibArraySlicePositions(arrayValue, sliceObject)
        result.append(arrayValue[index])
    return result
}

AhkStdlibArraySetSlice(arrayValue, sliceObject, replacement)
{
    AhkStdlibArrayValidateSliceReplacement(arrayValue, replacement)
    replacement := AhkStdlibArrayCloneValue(replacement)
    indices := sliceObject.indices(arrayValue.AhkStdlibLength)
    start := indices[1]
    stop := indices[2]
    step := indices[3]

    if step = 1 {
        AhkStdlibArrayReplaceContiguousSlice(arrayValue, start, stop, replacement)
        return stdlib.None
    }

    positions := AhkStdlibArraySlicePositionsFromIndices(start, stop, step)
    if positions.Length != replacement.AhkStdlibLength
        throw ValueError("attempt to assign array of size " replacement.AhkStdlibLength " to extended slice of size " positions.Length, -1)
    for positionIndex, position in positions
        arrayValue[position] := replacement[positionIndex - 1]
    return stdlib.None
}

AhkStdlibArrayDeleteSlice(arrayValue, sliceObject)
{
    indices := sliceObject.indices(arrayValue.AhkStdlibLength)
    start := indices[1]
    stop := indices[2]
    step := indices[3]

    if step = 1 {
        replacement := AhkStdlibArrayValue(arrayValue.typecode)
        AhkStdlibArrayReplaceContiguousSlice(arrayValue, start, stop, replacement)
        return stdlib.None
    }

    positions := Map()
    for position in AhkStdlibArraySlicePositionsFromIndices(start, stop, step)
        positions[position] := true

    result := AhkStdlibArrayValue(arrayValue.typecode)
    loop arrayValue.AhkStdlibLength {
        index := A_Index - 1
        if !positions.Has(index)
            result.append(arrayValue[index])
    }
    AhkStdlibArrayAdopt(arrayValue, result)
    return stdlib.None
}

AhkStdlibArraySlicePositions(arrayValue, sliceObject)
{
    indices := sliceObject.indices(arrayValue.AhkStdlibLength)
    return AhkStdlibArraySlicePositionsFromIndices(indices[1], indices[2], indices[3])
}

AhkStdlibArraySlicePositionsFromIndices(start, stop, step)
{
    positions := []
    index := start
    if step > 0 {
        while index < stop {
            positions.Push(index)
            index += step
        }
        return positions
    }

    while index > stop {
        positions.Push(index)
        index += step
    }
    return positions
}

AhkStdlibArrayValidateSliceReplacement(arrayValue, replacement)
{
    if !(replacement is AhkStdlibArrayValue)
        throw TypeError("can only assign array (not `"" AhkStdlibPythonTypeName(replacement) "`") to array slice", -1)
    if replacement.typecode != arrayValue.typecode
        throw TypeError("bad argument type for built-in operation", -1)
}

AhkStdlibArrayIndexBound(value, length)
{
    if AhkStdlibIsBool(value)
        value := value.Value ? 1 : 0
    else if !(value is Integer)
        throw TypeError("slice indices must be integers or have an __index__ method", -1)

    if value < 0
        value += length
    if value < 0
        return 0
    if value > length
        return length
    return value
}

AhkStdlibArrayReplaceContiguousSlice(arrayValue, start, stop, replacement)
{
    if stop < start
        stop := start

    result := AhkStdlibArrayValue(arrayValue.typecode)
    index := 0
    while index < start {
        result.append(arrayValue[index])
        index += 1
    }
    for value in replacement
        result.append(value)
    index := stop
    while index < arrayValue.AhkStdlibLength {
        result.append(arrayValue[index])
        index += 1
    }
    AhkStdlibArrayAdopt(arrayValue, result)
}

AhkStdlibArrayAdopt(target, source)
{
    target.AhkStdlibLength := source.AhkStdlibLength
    target.AhkStdlibBuffer := source.AhkStdlibBuffer
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

    value := AhkStdlibArrayNormalizeScalar(value)

    if kind = "float" {
        if (value is Integer) || (value is Float)
            return
        throw TypeError("must be real number, not " AhkStdlibPythonTypeName(value), -1)
    }

    if value is Integer {
        AhkStdlibArrayValidateIntegerRange(typecode, value)
        return
    }
    throw TypeError("'" AhkStdlibPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
}

AhkStdlibArrayNormalizeScalar(value)
{
    if AhkStdlibIsBool(value)
        return value.Value ? 1 : 0
    return value
}

AhkStdlibArrayValidateIntegerRange(typecode, value)
{
    switch typecode {
        case "b":
            if value < -128
                throw OverflowError("signed char is less than minimum", -1)
            if value > 127
                throw OverflowError("signed char is greater than maximum", -1)
        case "B":
            if value < 0
                throw OverflowError("unsigned byte integer is less than minimum", -1)
            if value > 255
                throw OverflowError("unsigned byte integer is greater than maximum", -1)
        case "h":
            if value < -32768
                throw OverflowError("signed short integer is less than minimum", -1)
            if value > 32767
                throw OverflowError("signed short integer is greater than maximum", -1)
        case "H":
            if value < 0
                throw OverflowError("unsigned short is less than minimum", -1)
            if value > 65535
                throw OverflowError("unsigned short is greater than maximum", -1)
        case "i", "l":
            if value < -2147483648 || value > 2147483647
                throw OverflowError("Python int too large to convert to C long", -1)
        case "I", "L":
            if value < 0
                throw OverflowError("can't convert negative value to unsigned int", -1)
            if value > 4294967295
                throw OverflowError("Python int too large to convert to C unsigned long", -1)
        case "q":
            ; AHK integers are already bounded to signed 64-bit values.
            return
        case "Q":
            if value < 0
                throw OverflowError("can't convert negative int to unsigned", -1)
    }
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

AhkStdlibArrayElementEquals(arrayValue, left, right)
{
    if arrayValue.AhkStdlibElementKind != "str"
        right := AhkStdlibArrayNormalizeScalar(right)
    return AhkStdlibArrayValuesEqual(left, right)
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

AhkStdlibArrayStringRepr(value)
{
    quote := InStr(value, "'") && !InStr(value, '"') ? '"' : "'"
    text := quote
    loop parse value {
        char := A_LoopField
        code := Ord(char)
        if char = "\"
            text .= "\\"
        else if char = quote
            text .= "\" char
        else if char = "`n"
            text .= "\n"
        else if char = "`r"
            text .= "\r"
        else if char = "`t"
            text .= "\t"
        else if code = 8
            text .= "\b"
        else if code = 12
            text .= "\f"
        else if code < 32 || code = 127
            text .= Format("\x{:02x}", code)
        else
            text .= char
    }
    return text quote
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
