#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibFunctools
{
    static reduce(callback, iterable, initializer := unset)
    {
        if IsSet(initializer)
            return AhkStdlibFunctoolsReduce(callback, iterable, initializer)
        return AhkStdlibFunctoolsReduce(callback, iterable)
    }

    static partial(args*)
    {
        if args.Length < 1
            throw TypeError("type 'partial' takes at least one argument", -1)
        callback := args[1]
        boundArgs := []
        index := 2
        while index <= args.Length {
            boundArgs.Push(args[index])
            index += 1
        }
        return AhkStdlibFunctoolsPartial(callback, boundArgs*)
    }
}

stdlib.functools := AhkStdlibFunctools

class AhkStdlibFunctoolsPartial
{
    __New(callback, boundArgs*)
    {
        if callback is AhkStdlibFunctoolsPartial {
            func := callback.func
            if boundArgs.Length = 0 {
                args := callback.AhkStdlibArgs
                argsView := callback.AhkStdlibArgsView
            } else {
                args := []
                for value in callback.args
                    args.Push(value)
                for value in boundArgs
                    args.Push(value)
                argsView := AhkStdlibTuple(args)
            }
            keywords := callback.keywords.Clone()
        } else {
            if !HasMethod(callback, "Call")
                throw TypeError("the first argument must be callable", -1)
            func := callback
            args := []
            for value in boundArgs
                args.Push(value)
            argsView := AhkStdlibTuple(args)
            keywords := Map()
        }

        this.DefineProp("AhkStdlibFunc", { Value: func })
        this.DefineProp("AhkStdlibArgs", { Value: args })
        this.DefineProp("AhkStdlibArgsView", { Value: argsView })
        this.DefineProp("AhkStdlibKeywords", { Value: keywords })
        this.DefineProp("AhkStdlibModule", { Value: "functools" })
        this.DefineProp("AhkStdlibDoc", { Value: "partial(func, *args, **keywords) - new function with partial application`n    of the given arguments and keywords.`n" })
        this.DefineProp("AhkStdlibDict", { Value: Map() })
    }

    func {
        get => this.AhkStdlibFunc
        set => AhkStdlibFunctoolsReadonlyAttribute()
    }

    args {
        get => this.AhkStdlibArgsView
        set => AhkStdlibFunctoolsReadonlyAttribute()
    }

    keywords {
        get => this.AhkStdlibKeywords
        set => AhkStdlibFunctoolsReadonlyAttribute()
    }

    __module__ {
        get {
            dictState := this.__dict__
            if !(dictState is Map)
                throw stdlib.SystemError("bad argument to internal function", -1)
            if dictState.Has("__module__")
                return dictState["__module__"]
            return this.AhkStdlibModule
        }
        set {
            dictState := this.__dict__
            if !(dictState is Map)
                throw stdlib.SystemError("bad argument to internal function", -1)
            dictState["__module__"] := value
        }
    }

    __doc__ {
        get {
            dictState := this.__dict__
            if !(dictState is Map)
                throw stdlib.SystemError("bad argument to internal function", -1)
            if dictState.Has("__doc__")
                return dictState["__doc__"]
            return this.AhkStdlibDoc
        }
        set {
            dictState := this.__dict__
            if !(dictState is Map)
                throw stdlib.SystemError("bad argument to internal function", -1)
            dictState["__doc__"] := value
        }
    }

    __dict__ {
        get => this.AhkStdlibDict
        set {
            if !(value is Map)
                throw TypeError("__dict__ must be set to a dictionary, not a '" AhkStdlibFunctoolsPythonTypeName(value) "'", -1)
            this.DefineProp("AhkStdlibDict", { Value: value })
        }
    }

    __Set(name, params, value)
    {
        dictState := this.__dict__
        if !(dictState is Map)
            throw stdlib.SystemError("bad argument to internal function", -1)
        dictState[name] := value
        return value
    }

    __Get(name, params)
    {
        dictState := this.__dict__
        if !(dictState is Map)
            throw stdlib.SystemError("bad argument to internal function", -1)
        if dictState.Has(name)
            return dictState[name]
        throw stdlib.AttributeError("'functools.partial' object has no attribute '" name "'", -1)
    }

    Call(args*)
    {
        callArgs := []
        for value in this.args
            callArgs.Push(value)
        for value in args
            callArgs.Push(value)
        for , value in this.keywords
            callArgs.Push(value)

        return this.func.Call(callArgs*)
    }

    __Repr()
    {
        parts := ["<function " AhkStdlibFunctoolsCallableDisplayName(this.func) " at 0x" Format("{:X}", ObjPtr(this.func)) ">"]
        for value in this.args
            parts.Push(AhkStdlibFunctoolsValueRepr(value))
        for key, value in this.keywords
            parts.Push(key "=" AhkStdlibFunctoolsValueRepr(value))
        return "functools.partial(" AhkStdlibFunctoolsJoin(parts, ", ") ")"
    }

    __reduce__()
    {
        dictState := this.__dict__
        if dictState is Map
            dictState := dictState.Count = 0 ? stdlib.None : dictState
        else
            throw stdlib.SystemError("bad argument to internal function", -1)
        state := AhkStdlibTuple([this.func, this.args, this.keywords.Clone(), dictState])
        return AhkStdlibTuple([AhkStdlibFunctoolsPartial, AhkStdlibTuple([this.func]), state])
    }

    __setstate__(args*)
    {
        if args.Length = 0
            throw TypeError("partial.__setstate__() takes exactly one argument (0 given)", -1)
        if args.Length != 1
            throw TypeError("invalid partial state", -1)
        state := args[1]
        values := AhkStdlibFunctoolsValidatePartialState(state)
        this.DefineProp("AhkStdlibFunc", { Value: values.func })
        this.DefineProp("AhkStdlibArgs", { Value: values.args })
        this.DefineProp("AhkStdlibArgsView", { Value: AhkStdlibTuple(values.args) })
        this.DefineProp("AhkStdlibKeywords", { Value: values.keywords })
        this.DefineProp("AhkStdlibDict", { Value: values.dict })
        return stdlib.None
    }

    DeleteProp(name)
    {
        if name = "func" || name = "args" || name = "keywords"
            AhkStdlibFunctoolsReadonlyAttribute()
        dictState := this.__dict__
        if !(dictState is Map)
            throw stdlib.SystemError("bad argument to internal function", -1)
        if name = "__module__" || name = "__doc__" {
            if dictState.Has(name) {
                removed := dictState[name]
                dictState.Delete(name)
                return removed
            }
            throw stdlib.AttributeError(name, -1)
        }
        if name = "__dict__"
            throw TypeError("cannot delete __dict__", -1)
        if dictState.Has(name) {
            removed := dictState[name]
            dictState.Delete(name)
            return removed
        }
        if this.HasOwnProp(name)
            return super.DeleteProp(name)
        throw stdlib.AttributeError(name, -1)
    }
}

AhkStdlibFunctoolsReadonlyAttribute()
{
    throw PropertyError("readonly attribute", -1)
}

AhkStdlibFunctoolsValidatePartialState(state)
{
    if Type(state) != "AhkStdlibTuple" || state.Length != 4
        throw TypeError("invalid partial state", -1)

    func := state[1]
    argsValue := state[2]
    keywords := state[3]
    dict := state[4]

    if !HasMethod(func, "Call")
        throw TypeError("invalid partial state", -1)
    if Type(argsValue) != "AhkStdlibTuple"
        throw TypeError("invalid partial state", -1)
    if !(keywords is Map) && !AhkStdlibIsNone(keywords)
        throw TypeError("invalid partial state", -1)
    if !AhkStdlibFunctoolsIsValidPartialDictState(dict)
        throw TypeError("invalid partial state", -1)

    args := []
    for value in argsValue
        args.Push(value)

    return {
        func: func,
        args: args,
        keywords: AhkStdlibIsNone(keywords) ? Map() : keywords.Clone(),
        dict: AhkStdlibIsNone(dict) ? Map() : dict
    }
}

AhkStdlibFunctoolsIsValidPartialDictState(dict)
{
    if AhkStdlibIsNone(dict)
        return true
    return true
}

AhkStdlibFunctoolsReduce(callback, iterable, initializer := unset)
{
    if !HasMethod(callback, "Call")
        throw TypeError("'" AhkStdlibFunctoolsPythonTypeName(callback) "' object is not callable", -1)

    iterator := AhkStdlibFunctoolsEnum(iterable, "reduce_arg2")
    hasValue := false
    accumulator := ""

    if IsSet(initializer) {
        accumulator := initializer
        hasValue := true
    }

    item := unset
    while iterator(&item) {
        if hasValue
            accumulator := callback.Call(accumulator, item)
        else {
            accumulator := item
            hasValue := true
        }
    }

    if !hasValue
        throw TypeError("reduce() of empty iterable with no initial value", -1)

    return accumulator
}

AhkStdlibFunctoolsEnum(iterable, context := "")
{
    if iterable is String
        return AhkStdlibFunctoolsStringEnum(iterable)
    if IsObject(iterable) && HasMethod(iterable, "__Enum")
        return iterable.__Enum(1)
    if context = "reduce_arg2"
        throw TypeError("reduce() arg 2 must support iteration", -1)
    throw TypeError("'" AhkStdlibFunctoolsPythonTypeName(iterable) "' object is not iterable", -1)
}

AhkStdlibFunctoolsPythonTypeName(value)
{
    if AhkStdlibIsNone(value)
        return "NoneType"
    if AhkStdlibIsBool(value)
        return "bool"
    if Type(value) = "AhkStdlibTuple"
        return "tuple"
    if value is Map
        return "dict"
    if value is Array
        return "list"
    if value is String
        return "str"
    if value is Float
        return "float"
    if value is Integer
        return "int"
    if IsObject(value) && Type(value) != "Object"
        return AhkStdlibFunctoolsLeafTypeName(Type(value))
    if IsObject(value)
        return "object"
    return Type(value)
}

AhkStdlibFunctoolsLeafTypeName(typeName)
{
    dot := InStr(typeName, ".", false, -1)
    if dot
        return SubStr(typeName, dot + 1)
    return typeName
}

AhkStdlibFunctoolsStringEnum(text)
{
    index := 1
    length := StrLen(text)

    return NextChar

    NextChar(&value)
    {
        if index > length
            return false
        value := SubStr(text, index, 1)
        index += 1
        return true
    }
}

AhkStdlibFunctoolsCallableDisplayName(callback)
{
    if HasProp(callback, "Name")
        return callback.Name
    return Type(callback)
}

AhkStdlibFunctoolsValueRepr(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if HasMethod(value, "Call")
        return "<function " AhkStdlibFunctoolsCallableDisplayName(value) " at 0x" Format("{:X}", ObjPtr(value)) ">"
    if value is String
        return AhkStdlibFunctoolsStringRepr(value)
    if value is AhkStdlibTuple
        return AhkStdlibFunctoolsTupleRepr(value)
    if value is Array
        return AhkStdlibFunctoolsArrayRepr(value)
    if value is Map
        return AhkStdlibFunctoolsMapRepr(value)
    if IsObject(value)
        return AhkStdlibFunctoolsObjectRepr(value)
    return String(value)
}

AhkStdlibFunctoolsJoin(values, separator)
{
    text := ""
    for index, value in values {
        if index > 1
            text .= separator
        text .= value
    }
    return text
}

AhkStdlibFunctoolsStringRepr(value)
{
    escaped := StrReplace(value, "\", "\\")
    escaped := StrReplace(escaped, "`n", "\n")
    escaped := StrReplace(escaped, "`r", "\r")
    escaped := StrReplace(escaped, "`t", "\t")
    escaped := StrReplace(escaped, "'", "\'")
    if InStr(escaped, "\'") && !InStr(escaped, '"')
        return '"' StrReplace(escaped, "\'", "'") '"'
    return "'" escaped "'"
}

AhkStdlibFunctoolsArrayRepr(values)
{
    parts := []
    for value in values
        parts.Push(AhkStdlibFunctoolsValueRepr(value))
    return "[" AhkStdlibFunctoolsJoin(parts, ", ") "]"
}

AhkStdlibFunctoolsTupleRepr(values)
{
    parts := []
    for value in values
        parts.Push(AhkStdlibFunctoolsValueRepr(value))
    if parts.Length = 1
        return "(" parts[1] ",)"
    return "(" AhkStdlibFunctoolsJoin(parts, ", ") ")"
}

AhkStdlibFunctoolsMapRepr(mapping)
{
    parts := []
    for key, value in mapping
        parts.Push(AhkStdlibFunctoolsValueRepr(key) ": " AhkStdlibFunctoolsValueRepr(value))
    return "{" AhkStdlibFunctoolsJoin(parts, ", ") "}"
}

AhkStdlibFunctoolsObjectRepr(value)
{
    return "<" Type(value) " object at 0x" Format("{:X}", ObjPtr(value)) ">"
}
