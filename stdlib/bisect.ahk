#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibCollectionsBisect
{
    static bisect_left(args*)
    {
        AhkStdlibBisectParseArgs("bisect_left", args, &a, &x, &lo, &hi, &key)
        AhkStdlibBisectCheckBounds(a, &lo, &hi)
        AhkStdlibBisectCheckKey(key?)

        while lo < hi {
            mid := (lo + hi) // 2
            if AhkStdlibBisectKeyValue(AhkStdlibBisectGetItem(a, mid), key?) < x
                lo := mid + 1
            else
                hi := mid
        }

        return lo
    }

    static bisect_right(args*)
    {
        AhkStdlibBisectParseArgs("bisect_right", args, &a, &x, &lo, &hi, &key)
        AhkStdlibBisectCheckBounds(a, &lo, &hi)
        AhkStdlibBisectCheckKey(key?)

        while lo < hi {
            mid := (lo + hi) // 2
            if x < AhkStdlibBisectKeyValue(AhkStdlibBisectGetItem(a, mid), key?)
                hi := mid
            else
                lo := mid + 1
        }

        return lo
    }

    static bisect(args*)
    {
        return this.bisect_right(args*)
    }

    static insort_left(args*)
    {
        AhkStdlibBisectParseArgs("insort_left", args, &a, &x, &lo, &hi, &key)
        searchValue := IsSet(key) ? AhkStdlibBisectCallKey(key, x) : x
        index := IsSet(key)
            ? this.bisect_left(a, searchValue, lo, hi, key)
            : this.bisect_left(a, searchValue, lo, hi)
        AhkStdlibBisectInsertAtPythonIndex(a, index, x)
        return stdlib.None
    }

    static insort_right(args*)
    {
        AhkStdlibBisectParseArgs("insort_right", args, &a, &x, &lo, &hi, &key)
        searchValue := IsSet(key) ? AhkStdlibBisectCallKey(key, x) : x
        index := IsSet(key)
            ? this.bisect_right(a, searchValue, lo, hi, key)
            : this.bisect_right(a, searchValue, lo, hi)
        AhkStdlibBisectInsertAtPythonIndex(a, index, x)
        return stdlib.None
    }

    static insort(args*)
    {
        return this.insort_right(args*)
    }
}

stdlib.bisect := AhkStdlibCollectionsBisect

AhkStdlibBisectParseArgs(functionName, args, &a, &x, &lo, &hi, &key)
{
    if args.Length = 0
        throw TypeError(functionName "() missing required argument 'a' (pos 1)", -1)
    if args.Length = 1
        throw TypeError(functionName "() missing required argument 'x' (pos 2)", -1)
    if args.Length > 5
        throw TypeError(functionName "() takes at most 5 arguments (" args.Length " given)", -1)

    a := args[1]
    x := args[2]
    lo := args.Length >= 3 ? AhkStdlibBisectInterpretIndex(args[3]) : 0
    hi := args.Length >= 4 ? args[4] : stdlib.None
    if !AhkStdlibIsNone(hi)
        hi := AhkStdlibBisectInterpretIndex(hi)
    key := unset
    if args.Length >= 5 && !AhkStdlibIsNone(args[5])
        key := args[5]
}

AhkStdlibBisectCheckBounds(a, &lo, &hi)
{
    length := AhkStdlibBisectLength(a)

    if lo < 0
        throw ValueError("lo must be non-negative", -1)

    if AhkStdlibIsNone(hi)
        hi := length

    if hi > length
        throw IndexError("list index out of range", -1)
    if hi = -1
        hi := length
}

AhkStdlibBisectInsertAtPythonIndex(a, index, value)
{
    if a is Array {
        if index >= a.Length {
            a.Push(value)
            return
        }

        a.InsertAt(index + 1, value)
        return
    }

    if HasMethod(a, "insert") {
        a.insert(index, value)
        return
    }

    throw stdlib.AttributeError("'" AhkStdlibPythonTypeName(a) "' object has no attribute 'insert'", -1)
}

AhkStdlibBisectLength(a)
{
    if a is Array
        return a.Length
    if IsObject(a) && HasProp(a, "__Len")
        return a.__Len
    throw TypeError("a must be an Array", -1)
}

AhkStdlibBisectGetItem(a, index)
{
    if a is Array
        return a[index + 1]
    if IsObject(a) && HasProp(a, "__Item")
        return a[index]
    throw TypeError("a must be an Array", -1)
}

AhkStdlibBisectCheckKey(key := unset)
{
    if IsSet(key) && !HasMethod(key, "Call")
        throw TypeError("'" AhkStdlibPythonTypeName(key) "' object is not callable", -1)
}

AhkStdlibBisectKeyValue(value, key := unset)
{
    if IsSet(key)
        return AhkStdlibBisectCallKey(key, value)
    return value
}

AhkStdlibBisectCallKey(key, value)
{
    if !HasMethod(key, "Call")
        throw TypeError("'" AhkStdlibPythonTypeName(key) "' object is not callable", -1)
    return key.Call(value)
}

AhkStdlibBisectInterpretIndex(value)
{
    if value is Integer
        return value
    if AhkStdlibIsBool(value)
        return value.Value ? 1 : 0
    throw TypeError("'" AhkStdlibPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
}
