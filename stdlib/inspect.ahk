#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibInspect
{
    static Parameter
    {
        get => AhkStdlibInspectParameter
    }

    static Signature
    {
        get => AhkStdlibInspectSignature
    }

    static isfunction(args*)
    {
        if args.Length = 0
            throw TypeError("isfunction() missing 1 required positional argument: 'object'", -1)
        if args.Length > 1
            throw TypeError("isfunction() takes 1 positional argument but " args.Length " were given", -1)

        value := args[1]
        if !IsObject(value)
            return false
        if !(value is Func)
            return false
        if value is BoundFunc
            return false
        if value.IsBuiltIn
            return false
        if value.Name = ""
            return true
        if InStr(value.Name, ".Prototype.")
            return false
        if InStr(value.Name, ".")
            return false
        return true
    }

    static isclass(args*)
    {
        if args.Length = 0
            throw TypeError("isclass() missing 1 required positional argument: 'object'", -1)
        if args.Length > 1
            throw TypeError("isclass() takes 1 positional argument but " args.Length " were given", -1)

        value := args[1]
        return IsObject(value) && Type(value) = "Class" && HasProp(value, "Prototype")
    }

    static ismethod(object)
    {
        return IsObject(object) && object is BoundFunc
    }

    static isbuiltin(object)
    {
        return IsObject(object) && object is Func && object.IsBuiltIn
    }

    static isroutine(object)
    {
        return IsObject(object) && (object is Func || object is BoundFunc || object is Closure)
    }

    static ismodule(object)
    {
        ; A SimpleNamespace/module-like object carries the module marker.
        return IsObject(object) && (HasProp(object, "__AhkStdlibModule") || Type(object) = "AhkStdlibTypesModuleType")
    }

    static ismethoddescriptor(object)
    {
        return IsObject(object) && object is Func && !object.IsBuiltIn && InStr(object.Name, ".Prototype.")
    }

    static callable(object)
    {
        return IsObject(object) && HasMethod(object, "Call")
    }

    static getmro(cls)
    {
        if !AhkStdlibInspect.isclass(cls)
            throw TypeError("getmro() argument must be a class", -1)
        chain := []
        current := cls
        while IsObject(current) && Type(current) = "Class" {
            chain.Push(current)
            current := current.Base
            ; Stop at the root Class/Object base.
            if !IsObject(current) || !HasProp(current, "Prototype")
                break
        }
        return stdlib.tuple(chain)
    }

    static getmembers(object, predicate := unset)
    {
        members := []
        seen := Map()
        for name in AhkStdlibInspectPropNames(object) {
            if seen.Has(name)
                continue
            seen[name] := true
            value := AhkStdlibInspectTryGet(object, name)
            if IsSet(predicate) && !AhkStdlibIsNone(predicate) {
                if !AhkStdlibTruthValue(predicate.Call(value))
                    continue
            }
            members.Push(stdlib.tuple([name, value]))
        }
        ; Python returns members sorted by name.
        AhkStdlibInspectSortPairs(members)
        return members
    }

    static getdoc(object)
    {
        if IsObject(object) && HasProp(object, "__doc__") {
            doc := object.__doc__
            if doc is String
                return doc
        }
        return stdlib.None
    }

    static signature(callable, kwargs*)
    {
        return AhkStdlibInspectSignature(callable)
    }

    static getfullargspec(func)
    {
        sig := AhkStdlibInspectSignature(func)
        args := []
        varargs := stdlib.None
        for param in sig.AhkStdlibParameters {
            if param.kind = AhkStdlibInspectParameter.VAR_POSITIONAL
                varargs := param.name
            else
                args.Push(param.name)
        }
        return AhkStdlibInspectFullArgSpec(args, varargs)
    }
}

class AhkStdlibInspectParameter
{
    ; Kind constants mirror Python's inspect.Parameter.
    static POSITIONAL_ONLY := 0
    static POSITIONAL_OR_KEYWORD := 1
    static VAR_POSITIONAL := 2
    static KEYWORD_ONLY := 3
    static VAR_KEYWORD := 4

    static empty := AhkStdlibInspectEmptyClass

    __New(name, kind, hasDefault := false, defaultValue := unset)
    {
        this.name := name
        this.kind := kind
        if hasDefault
            this.default := defaultValue
        else
            this.default := AhkStdlibInspectEmptyClass
        this.annotation := AhkStdlibInspectEmptyClass
    }

    __Repr()
    {
        return "<Parameter " this.AhkStdlibFormat() ">"
    }

    AhkStdlibFormat()
    {
        text := this.name
        if this.kind = AhkStdlibInspectParameter.VAR_POSITIONAL
            text := "*" text
        else if this.kind = AhkStdlibInspectParameter.VAR_KEYWORD
            text := "**" text
        if !AhkStdlibInspectIsEmpty(this.default)
            text .= "=" AhkStdlibInspectValueRepr(this.default)
        return text
    }
}

class AhkStdlibInspectSignature
{
    __New(callable)
    {
        if !(IsObject(callable) && HasMethod(callable, "Call"))
            throw TypeError("'" AhkStdlibPythonTypeName(callable) "' is not a callable object", -1)

        this.AhkStdlibCallable := callable
        this.AhkStdlibParameters := AhkStdlibInspectBuildParameters(callable)

        ordered := Map()
        ordered.Default := ""
        params := this.AhkStdlibParameters
        this.parameters := AhkStdlibInspectOrderedParams(params)
    }

    parameters_list()
    {
        return this.AhkStdlibParameters
    }

    __Repr()
    {
        return "<Signature " this.AhkStdlibFormat() ">"
    }

    AhkStdlibFormat()
    {
        parts := []
        for param in this.AhkStdlibParameters
            parts.Push(param.AhkStdlibFormat())
        joined := ""
        for p in parts
            joined := joined = "" ? p : joined ", " p
        return "(" joined ")"
    }

    ToString()
    {
        return this.AhkStdlibFormat()
    }
}

stdlib.inspect := AhkStdlibInspect

; ---------------------------------------------------------------------------
; Sentinel for "no value" (Python's inspect._empty).
; ---------------------------------------------------------------------------

class AhkStdlibInspectEmptyClass
{
}

AhkStdlibInspectIsEmpty(value)
{
    return IsObject(value) && value == AhkStdlibInspectEmptyClass
}

AhkStdlibInspectBuildParameters(callable)
{
    ; Note: AHK identifiers are case-insensitive, so a local named `func` would
    ; shadow the built-in `Func` class and break `is Func` checks. Use `routine`.
    routine := callable
    ; Bound methods drop the implicit `this`/first parameter.
    boundOffset := 0
    if callable is BoundFunc {
        boundOffset := 1
    }

    if !(routine is Func) && !(routine is BoundFunc) {
        ; Callable object with a Call method.
        if HasMethod(callable, "Call") {
            routine := callable.Call
            ; Calling through .Call adds an implicit `this`.
            boundOffset := 1
        }
    }

    minParams := AhkStdlibInspectFuncProp(routine, "MinParams", 0)
    maxParams := AhkStdlibInspectFuncProp(routine, "MaxParams", minParams)
    isVariadic := AhkStdlibInspectFuncProp(routine, "IsVariadic", false)

    params := []
    index := 1
    total := maxParams
    while index <= total {
        if index <= boundOffset {
            index += 1
            continue
        }
        paramName := "arg" (index - boundOffset)
        hasDefault := index > minParams
        param := AhkStdlibInspectParameter(paramName, AhkStdlibInspectParameter.POSITIONAL_OR_KEYWORD, hasDefault, hasDefault ? stdlib.None : unset)
        params.Push(param)
        index += 1
    }

    if isVariadic {
        params.Push(AhkStdlibInspectParameter("args", AhkStdlibInspectParameter.VAR_POSITIONAL))
    }

    return params
}

AhkStdlibInspectFuncProp(func, propName, defaultValue)
{
    if IsObject(func) && HasProp(func, propName) {
        try
            return func.%propName%
    }
    return defaultValue
}

AhkStdlibInspectOrderedParams(params)
{
    ordered := Map()
    for param in params
        ordered[param.name] := param
    return ordered
}

class AhkStdlibInspectFullArgSpec
{
    __New(args, varargs)
    {
        this.args := args
        this.varargs := varargs
        this.varkw := stdlib.None
        this.defaults := stdlib.None
        this.kwonlyargs := []
        this.kwonlydefaults := stdlib.None
        this.annotations := Map()
    }
}

AhkStdlibInspectPropNames(object)
{
    names := []
    if !IsObject(object)
        return names
    try {
        for name in object.OwnProps()
            names.Push(name)
    }
    ; Include prototype methods for class instances.
    return names
}

AhkStdlibInspectTryGet(object, name)
{
    try
        return object.%name%
    catch
        return stdlib.None
}

AhkStdlibInspectSortPairs(pairs)
{
    n := pairs.Length
    Loop n {
        i := A_Index
        Loop n - i {
            j := i + A_Index
            if StrCompare(pairs[j][1], pairs[i][1]) < 0 {
                tmp := pairs[i]
                pairs[i] := pairs[j]
                pairs[j] := tmp
            }
        }
    }
}

AhkStdlibInspectValueRepr(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if value is String
        return "'" value "'"
    if IsObject(value)
        return "<object>"
    return String(value)
}
