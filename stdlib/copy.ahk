#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibCopyError extends Error
{
}

class AhkStdlibCopy
{
    static Error := AhkStdlibCopyError
    static dispatch_table := AhkStdlibCopyDispatchTable()

    static copy(args*)
    {
        if args.Length = 0
            throw TypeError("copy() missing 1 required positional argument: 'x'", -1)
        return AhkStdlibCopyShallow(args[1])
    }

    static deepcopy(args*)
    {
        if args.Length = 0
            throw TypeError("deepcopy() missing 1 required positional argument: 'x'", -1)
        memo := Map()
        return AhkStdlibCopyDeep(args[1], memo)
    }
}

stdlib.copy := AhkStdlibCopy

AhkStdlibCopyDispatchTable()
{
    return Map(
        "complex", { module: "copyreg", name: "pickle_complex" },
        "types.UnionType", { module: "copyreg", name: "pickle_union" },
        "re.Pattern", { module: "re", name: "_pickle" }
    )
}

AhkStdlibCopyShallow(value)
{
    if IsObject(value) && HasMethod(value, "__copy__")
        return value.__copy__()

    if value is AhkStdlibTuple
        return value

    if value is Array {
        result := []
        for item in value
            result.Push(item)
        return result
    }

    if value is Map {
        result := Map()
        for key, item in value
            result[key] := item
        return result
    }

    if IsObject(value)
        return value.Clone()

    return value
}

AhkStdlibCopyDeep(value, memo)
{
    if !IsObject(value)
        return value

    if HasMethod(value, "__deepcopy__")
        return value.__deepcopy__(memo)

    if AhkStdlibCopyIsImmutableObject(value)
        return value

    ptr := ObjPtr(value)
    if memo.Has(ptr)
        return memo[ptr]

    if value is AhkStdlibTuple {
        values := []
        placeholder := values
        memo[ptr] := placeholder
        for item in value
            values.Push(AhkStdlibCopyDeep(item, memo))
        result := AhkStdlibTuple(values)
        memo[ptr] := result
        return result
    }

    if value is Array {
        result := []
        memo[ptr] := result
        for item in value
            result.Push(AhkStdlibCopyDeep(item, memo))
        return result
    }

    if value is Map {
        result := Map()
        memo[ptr] := result
        for key, item in value
            result[key] := AhkStdlibCopyDeep(item, memo)
        return result
    }

    result := value.Clone()
    memo[ptr] := result
    for name, item in value.OwnProps()
        result.%name% := AhkStdlibCopyDeep(item, memo)
    return result
}

AhkStdlibCopyIsImmutableObject(value)
{
    return AhkStdlibIsNone(value) || AhkStdlibIsNotImplemented(value) || AhkStdlibIsBool(value)
}
