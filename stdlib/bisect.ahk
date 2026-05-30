#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibCollectionsBisect
{
    static bisect_left(a, x, lo := 0, hi := "", key := unset)
    {
        AhkStdlibBisectCheckBounds(a, &lo, &hi)
        AhkStdlibBisectCheckKey(key?)

        while lo < hi {
            mid := (lo + hi) // 2
            if AhkStdlibBisectKeyValue(a[mid + 1], key?) < x
                lo := mid + 1
            else
                hi := mid
        }

        return lo
    }

    static bisect_right(a, x, lo := 0, hi := "", key := unset)
    {
        AhkStdlibBisectCheckBounds(a, &lo, &hi)
        AhkStdlibBisectCheckKey(key?)

        while lo < hi {
            mid := (lo + hi) // 2
            if x < AhkStdlibBisectKeyValue(a[mid + 1], key?)
                hi := mid
            else
                lo := mid + 1
        }

        return lo
    }

    static bisect(a, x, lo := 0, hi := "", key := unset)
    {
        return this.bisect_right(a, x, lo, hi, key?)
    }

    static insort_left(a, x, lo := 0, hi := "", key := unset)
    {
        searchValue := IsSet(key) ? AhkStdlibBisectCallKey(key, x) : x
        index := this.bisect_left(a, searchValue, lo, hi, key?)
        AhkStdlibBisectInsertAtPythonIndex(a, index, x)
    }

    static insort_right(a, x, lo := 0, hi := "", key := unset)
    {
        searchValue := IsSet(key) ? AhkStdlibBisectCallKey(key, x) : x
        index := this.bisect_right(a, searchValue, lo, hi, key?)
        AhkStdlibBisectInsertAtPythonIndex(a, index, x)
    }

    static insort(a, x, lo := 0, hi := "", key := unset)
    {
        return this.insort_right(a, x, lo, hi, key?)
    }
}

stdlib.bisect := AhkStdlibCollectionsBisect

AhkStdlibBisectCheckBounds(a, &lo, &hi)
{
    if !(a is Array)
        throw TypeError("a must be an Array", -1)

    if lo < 0
        throw ValueError("lo must be non-negative", -1)

    if hi == "" || hi == -1
        hi := a.Length

    if hi > a.Length
        throw IndexError("list index out of range", -1)
}

AhkStdlibBisectInsertAtPythonIndex(a, index, value)
{
    if index >= a.Length {
        a.Push(value)
        return
    }

    a.InsertAt(index + 1, value)
}

AhkStdlibBisectCheckKey(key := unset)
{
    if IsSet(key) && !HasMethod(key, "Call")
        throw TypeError("key must be callable", -1)
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
        throw TypeError("key must be callable", -1)
    return key.Call(value)
}
