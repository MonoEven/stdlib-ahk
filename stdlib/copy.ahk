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
        dispatch := AhkStdlibCopyExtractDispatch(args.Length >= 2 ? args[2] : "")
        return AhkStdlibCopyShallow(args[1], dispatch)
    }

    static deepcopy(args*)
    {
        if args.Length = 0
            throw TypeError("deepcopy() missing 1 required positional argument: 'x'", -1)
        dispatch := AhkStdlibCopyExtractDispatch(args.Length >= 2 ? args[2] : "")
        memo := Map()
        return AhkStdlibCopyDeep(args[1], memo, dispatch)
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

AhkStdlibCopyShallow(value, dispatch := "")
{
    ; Honor an explicit __copy__ hook first (matches CPython ordering:
    ; the object hook takes precedence over the dispatch_table reductor).
    if IsObject(value) && HasMethod(value, "__copy")
        return value.__copy()

    ; A registered copier in the supplied dispatch_table overrides default copying.
    if (copier := AhkStdlibCopyLookupDispatch(value, dispatch)) !== ""
        return AhkStdlibCopyInvokeCopier(copier, value)

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

AhkStdlibCopyDeep(value, memo, dispatch := "")
{
    if !IsObject(value)
        return value

    ; Honor an explicit __deepcopy__ hook first (matches CPython ordering:
    ; the object hook takes precedence over the dispatch_table reductor).
    if HasMethod(value, "__deepcopy")
        return value.__deepcopy(memo)

    if (copier := AhkStdlibCopyLookupDispatch(value, dispatch)) !== ""
        return AhkStdlibCopyInvokeCopier(copier, value, memo)

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
            values.Push(AhkStdlibCopyDeep(item, memo, dispatch))
        result := AhkStdlibTuple(values)
        memo[ptr] := result
        return result
    }

    if value is Array {
        result := []
        memo[ptr] := result
        for item in value
            result.Push(AhkStdlibCopyDeep(item, memo, dispatch))
        return result
    }

    if value is Map {
        result := Map()
        memo[ptr] := result
        for key, item in value
            result[key] := AhkStdlibCopyDeep(item, memo, dispatch)
        return result
    }

    result := value.Clone()
    memo[ptr] := result
    for name, item in value.OwnProps()
        result.%name% := AhkStdlibCopyDeep(item, memo, dispatch)
    return result
}

AhkStdlibCopyIsImmutableObject(value)
{
    return AhkStdlibIsNone(value) || AhkStdlibIsNotImplemented(value) || AhkStdlibIsBool(value)
}

; Normalize the optional second argument into a dispatch_table Map (or "").
; Accepts either a Map used directly, or an options object carrying a
; .dispatch_table property.
AhkStdlibCopyExtractDispatch(options)
{
    if !IsObject(options)
        return ""

    if options is Map
        return options

    if HasProp(options, "dispatch_table") {
        table := options.dispatch_table
        if table is Map
            return table
    }

    return ""
}

; Look up a registered copier for value in the dispatch_table. Keys may be the
; object itself, its class, the AHK type name, or the Python type name. Returns
; the copier or "" when none is registered.
AhkStdlibCopyLookupDispatch(value, dispatch)
{
    if !(dispatch is Map) || dispatch.Count = 0
        return ""

    if dispatch.Has(value)
        return dispatch[value]

    if IsObject(value) {
        cls := value.base
        if (cls !== "") && dispatch.Has(cls)
            return dispatch[cls]
    }

    typeName := Type(value)
    if dispatch.Has(typeName)
        return dispatch[typeName]

    pyName := AhkStdlibPythonTypeName(value)
    if dispatch.Has(pyName)
        return dispatch[pyName]

    return ""
}

; Invoke a dispatch copier. deepcopy passes the memo so the copier can recurse;
; copy passes only the value. A copier may be a plain function/closure or an
; object exposing a .copy()/.__call__() style entry point.
AhkStdlibCopyInvokeCopier(copier, value, memo := unset)
{
    if IsSet(memo)
        return copier(value, memo)
    return copier(value)
}
