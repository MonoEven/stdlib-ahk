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

    static cache(user_function)
    {
        if !HasMethod(user_function, "Call")
            throw TypeError("the first argument must be callable", -1)
        return AhkStdlibFunctoolsLruCache(user_function, stdlib.None, false)
    }

    static lru_cache(maxsize := 128, typed := false)
    {
        if HasMethod(maxsize, "Call") && !AhkStdlibIsBool(maxsize)
            return AhkStdlibFunctoolsLruCache(maxsize, 128, false)
        if !AhkStdlibIsNone(maxsize) && !(maxsize is Integer)
            throw TypeError("Expected first argument to be an integer, a callable, or None", -1)
        return AhkStdlibFunctoolsLruDecorator(maxsize, AhkStdlibTruthValue(typed))
    }

    static cmp_to_key(mycmp)
    {
        if !HasMethod(mycmp, "Call")
            throw TypeError("the first argument must be callable", -1)
        return AhkStdlibFunctoolsKeyFactory(mycmp)
    }

    static update_wrapper(wrapper, wrapped, kwargs*)
    {
        return AhkStdlibFunctoolsUpdateWrapper(wrapper, wrapped)
    }

    static wraps(wrapped, kwargs*)
    {
        ; Decorator factory: returns a function that copies wrapped's metadata
        ; onto the wrapper it is applied to.
        return (wrapper) => AhkStdlibFunctoolsUpdateWrapper(wrapper, wrapped)
    }

    static total_ordering(cls)
    {
        return AhkStdlibFunctoolsTotalOrdering(cls)
    }

    static cached_property(func)
    {
        return AhkStdlibFunctoolsCachedProperty(func)
    }

    static partialmethod(args*)
    {
        if args.Length < 1
            throw TypeError("partialmethod expected at least 1 argument, got 0", -1)
        callback := args[1]
        boundArgs := []
        index := 2
        while index <= args.Length {
            boundArgs.Push(args[index])
            index += 1
        }
        return AhkStdlibFunctoolsPartialMethod(callback, boundArgs*)
    }

    static singledispatch(target)
    {
        if !HasMethod(target, "Call")
            throw TypeError("the first argument must be callable", -1)
        return AhkStdlibFunctoolsSingleDispatch(target)
    }

    static singledispatchmethod(target)
    {
        if !HasMethod(target, "Call")
            throw TypeError("the first argument must be callable", -1)
        return AhkStdlibFunctoolsSingleDispatchMethod(target)
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

    __module {
        get {
            dictState := this.__dict
            if !(dictState is Map)
                throw stdlib.SystemError("bad argument to internal function", -1)
            if dictState.Has("__module")
                return dictState["__module"]
            return this.AhkStdlibModule
        }
        set {
            dictState := this.__dict
            if !(dictState is Map)
                throw stdlib.SystemError("bad argument to internal function", -1)
            dictState["__module"] := value
        }
    }

    __doc {
        get {
            dictState := this.__dict
            if !(dictState is Map)
                throw stdlib.SystemError("bad argument to internal function", -1)
            if dictState.Has("__doc")
                return dictState["__doc"]
            return this.AhkStdlibDoc
        }
        set {
            dictState := this.__dict
            if !(dictState is Map)
                throw stdlib.SystemError("bad argument to internal function", -1)
            dictState["__doc"] := value
        }
    }

    __dict {
        get => this.AhkStdlibDict
        set {
            if !(value is Map)
                throw TypeError("__dict must be set to a dictionary, not a '" AhkStdlibFunctoolsPythonTypeName(value) "'", -1)
            this.DefineProp("AhkStdlibDict", { Value: value })
        }
    }

    __Set(name, params, value)
    {
        dictState := this.__dict
        if !(dictState is Map)
            throw stdlib.SystemError("bad argument to internal function", -1)
        dictState[name] := value
        return value
    }

    __Get(name, params)
    {
        dictState := this.__dict
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

    __reduce()
    {
        dictState := this.__dict
        if dictState is Map
            dictState := dictState.Count = 0 ? stdlib.None : dictState
        else
            throw stdlib.SystemError("bad argument to internal function", -1)
        state := AhkStdlibTuple([this.func, this.args, this.keywords.Clone(), dictState])
        return AhkStdlibTuple([AhkStdlibFunctoolsPartial, AhkStdlibTuple([this.func]), state])
    }

    __setstate(args*)
    {
        if args.Length = 0
            throw TypeError("partial.__setstate() takes exactly one argument (0 given)", -1)
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
        dictState := this.__dict
        if !(dictState is Map)
            throw stdlib.SystemError("bad argument to internal function", -1)
        if name = "__module" || name = "__doc" {
            if dictState.Has(name) {
                removed := dictState[name]
                dictState.Delete(name)
                return removed
            }
            throw stdlib.AttributeError(name, -1)
        }
        if name = "__dict"
            throw TypeError("cannot delete __dict", -1)
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

AhkStdlibFunctoolsLruDecorator(maxsize, typed)
{
    apply(user_function) => AhkStdlibFunctoolsLruCache(user_function, maxsize, typed)
    return apply
}

AhkStdlibFunctoolsLruCache(user_function, maxsize, typed)
{
    if !HasMethod(user_function, "Call")
        throw TypeError("the first argument must be callable", -1)
    if !AhkStdlibIsNone(maxsize) {
        if !(maxsize is Integer)
            throw TypeError("Expected first argument to be an integer, a callable, or None", -1)
        if maxsize < 0
            maxsize := 0
    }
    return AhkStdlibFunctoolsLruCacheValue(user_function, maxsize, typed)
}

AhkStdlibFunctoolsMakeKey(args, typed)
{
    if typed {
        parts := []
        for value in args
            parts.Push(AhkStdlibFunctoolsKeyToken(value))
        for value in args
            parts.Push("<type:" AhkStdlibPythonTypeName(value) ">")
        return "seq" Chr(31) AhkStdlibFunctoolsJoinKey(parts)
    }

    if args.Length = 1 {
        value := args[1]
        if (value is Integer && !AhkStdlibIsBool(value)) || (value is String)
            return AhkStdlibFunctoolsKeyToken(value)
    }

    parts := []
    for value in args
        parts.Push(AhkStdlibFunctoolsKeyToken(value))
    return "seq" Chr(31) AhkStdlibFunctoolsJoinKey(parts)
}

AhkStdlibFunctoolsJoinKey(parts)
{
    result := ""
    for index, value in parts {
        if index > 1
            result .= Chr(31)
        result .= value
    }
    return result
}

AhkStdlibFunctoolsKeyToken(value)
{
    if AhkStdlibIsNone(value)
        return "N"
    if AhkStdlibIsBool(value)
        return value.Value ? "B1" : "B0"
    if (value is Integer) || (value is Float) {
        if value = Round(value) && Abs(value) < 1.0e15
            return "n" Format("{:d}", Integer(value))
        return "n" value
    }
    if value is String
        return "s" value
    if IsObject(value)
        return "o" ObjPtr(value)
    return "?" String(value)
}

class AhkStdlibFunctoolsCacheInfo
{
    __New(hits, misses, maxsize, currsize)
    {
        this.hits := hits
        this.misses := misses
        this.maxsize := maxsize
        this.currsize := currsize
    }

    __Repr()
    {
        maxsizeText := AhkStdlibIsNone(this.maxsize) ? "None" : this.maxsize ""
        return "CacheInfo(hits=" this.hits ", misses=" this.misses ", maxsize=" maxsizeText ", currsize=" this.currsize ")"
    }
}

class AhkStdlibFunctoolsLruCacheValue
{
    __New(user_function, maxsize, typed)
    {
        this.DefineProp("AhkStdlibFunc", { Value: user_function })
        this.DefineProp("AhkStdlibMaxsize", { Value: maxsize })
        this.DefineProp("AhkStdlibTyped", { Value: typed })
        this.AhkStdlibCache := Map()
        this.AhkStdlibOrder := []
        this.AhkStdlibHits := 0
        this.AhkStdlibMisses := 0
    }

    __wrapped__ {
        get => this.AhkStdlibFunc
    }

    Call(args*)
    {
        maxsize := this.AhkStdlibMaxsize
        if !AhkStdlibIsNone(maxsize) && maxsize = 0 {
            this.AhkStdlibMisses += 1
            return this.AhkStdlibFunc.Call(args*)
        }

        key := AhkStdlibFunctoolsMakeKey(args, this.AhkStdlibTyped)
        cache := this.AhkStdlibCache
        if cache.Has(key) {
            this.AhkStdlibHits += 1
            if !AhkStdlibIsNone(maxsize)
                AhkStdlibFunctoolsTouchKey(this.AhkStdlibOrder, key)
            return cache[key]
        }

        result := this.AhkStdlibFunc.Call(args*)
        this.AhkStdlibMisses += 1
        cache[key] := result
        if !AhkStdlibIsNone(maxsize) {
            this.AhkStdlibOrder.Push(key)
            if cache.Count > maxsize {
                evicted := this.AhkStdlibOrder.RemoveAt(1)
                cache.Delete(evicted)
            }
        }
        return result
    }

    cache_info()
    {
        return AhkStdlibFunctoolsCacheInfo(this.AhkStdlibHits, this.AhkStdlibMisses, this.AhkStdlibMaxsize, this.AhkStdlibCache.Count)
    }

    cache_clear()
    {
        this.AhkStdlibCache := Map()
        this.AhkStdlibOrder := []
        this.AhkStdlibHits := 0
        this.AhkStdlibMisses := 0
        return stdlib.None
    }

    cache_parameters()
    {
        return Map("maxsize", this.AhkStdlibMaxsize, "typed", this.AhkStdlibTyped ? stdlib.True : stdlib.False)
    }
}

AhkStdlibFunctoolsTouchKey(order, key)
{
    loop order.Length {
        if order[A_Index] == key {
            order.RemoveAt(A_Index)
            break
        }
    }
    order.Push(key)
}

AhkStdlibFunctoolsKeyFactory(mycmp)
{
    make(obj) => AhkStdlibFunctoolsKeyValue(mycmp, obj)
    return make
}

class AhkStdlibFunctoolsKeyValue
{
    __New(mycmp, obj)
    {
        this.DefineProp("AhkStdlibCmp", { Value: mycmp })
        this.obj := obj
    }

    Compare(other)
    {
        return this.AhkStdlibCmp.Call(this.obj, other.obj)
    }

    __Compare(other, operation := "")
    {
        if !(other is AhkStdlibFunctoolsKeyValue)
            return ""
        return this.AhkStdlibCmp.Call(this.obj, other.obj)
    }

    lt(other) => this.AhkStdlibCmp.Call(this.obj, other.obj) < 0
    le(other) => this.AhkStdlibCmp.Call(this.obj, other.obj) <= 0
    gt(other) => this.AhkStdlibCmp.Call(this.obj, other.obj) > 0
    ge(other) => this.AhkStdlibCmp.Call(this.obj, other.obj) >= 0
    eq(other) => this.AhkStdlibCmp.Call(this.obj, other.obj) = 0
    ne(other) => this.AhkStdlibCmp.Call(this.obj, other.obj) != 0
}

; ---------------------------------------------------------------------------
; wraps / update_wrapper
; ---------------------------------------------------------------------------

; Python copies __module__/__name__/__qualname__/__doc__/__dict__ and updates
; __wrapped__. AHK functions expose only a writable-via-DefineProp surface, so
; we copy the practical metadata (Name, __doc__) and set __wrapped__.
AhkStdlibFunctoolsUpdateWrapper(wrapper, wrapped, args*)
{
    if !IsObject(wrapper) || !IsObject(wrapped)
        throw TypeError("update_wrapper() requires callable objects", -1)
    for attr in ["Name", "__name__", "__qualname__", "__doc__", "__module__"] {
        if HasProp(wrapped, attr) {
            try wrapper.DefineProp(attr, { Value: wrapped.%attr% })
        }
    }
    try wrapper.DefineProp("__wrapped__", { Value: wrapped })
    return wrapper
}

; wraps(wrapped) returns a decorator that calls update_wrapper on its argument.
AhkStdlibFunctoolsWraps(wrapped, args*)
{
    return AhkStdlibFunctoolsWrapsDecorator(wrapped)
}

class AhkStdlibFunctoolsWrapsDecorator
{
    __New(wrapped)
    {
        this.AhkStdlibWrapped := wrapped
    }

    Call(wrapper)
    {
        return AhkStdlibFunctoolsUpdateWrapper(wrapper, this.AhkStdlibWrapped)
    }
}

; ---------------------------------------------------------------------------
; total_ordering
; ---------------------------------------------------------------------------

; Given a class defining eq plus one of lt/le/gt/ge (as methods), fill in the
; remaining comparison methods. Python operates on dunder methods; AHK has no
; operator dunders, so we fill the plain-named comparison methods (lt/le/gt/ge)
; which the cmp_to_key key objects and user code use by convention here.
AhkStdlibFunctoolsTotalOrdering(cls, args*)
{
    if !(IsObject(cls) && HasProp(cls, "Prototype"))
        throw TypeError("total_ordering() argument must be a class", -1)
    proto := cls.Prototype

    has(name) => HasMethod(proto, name)

    if has("lt") {
        if !has("le")
            proto.DefineProp("le", { Call: (self, other) => self.lt(other) || self.eq(other) })
        if !has("gt")
            proto.DefineProp("gt", { Call: (self, other) => !self.lt(other) && !self.eq(other) })
        if !has("ge")
            proto.DefineProp("ge", { Call: (self, other) => !self.lt(other) })
    } else if has("le") {
        if !has("lt")
            proto.DefineProp("lt", { Call: (self, other) => self.le(other) && !self.eq(other) })
        if !has("gt")
            proto.DefineProp("gt", { Call: (self, other) => !self.le(other) })
        if !has("ge")
            proto.DefineProp("ge", { Call: (self, other) => self.le(other) ? self.eq(other) : true })
    } else if has("gt") {
        if !has("ge")
            proto.DefineProp("ge", { Call: (self, other) => self.gt(other) || self.eq(other) })
        if !has("lt")
            proto.DefineProp("lt", { Call: (self, other) => !self.gt(other) && !self.eq(other) })
        if !has("le")
            proto.DefineProp("le", { Call: (self, other) => !self.gt(other) })
    } else if has("ge") {
        if !has("gt")
            proto.DefineProp("gt", { Call: (self, other) => self.ge(other) && !self.eq(other) })
        if !has("lt")
            proto.DefineProp("lt", { Call: (self, other) => !self.ge(other) })
        if !has("le")
            proto.DefineProp("le", { Call: (self, other) => self.ge(other) ? self.eq(other) : true })
    } else {
        throw ValueError("must define at least one ordering operation: < > <= >=", -1)
    }
    return cls
}

; ---------------------------------------------------------------------------
; cached_property
; ---------------------------------------------------------------------------

; Python's cached_property is a descriptor that computes once per instance and
; caches in the instance __dict__. AHK has no descriptor protocol, so this is a
; helper that wraps a getter: cached_property(func) returns an object whose
; Get(instance) memoizes per instance via an attached storage key.
AhkStdlibFunctoolsCachedProperty(func, args*)
{
    return AhkStdlibFunctoolsCachedPropertyValue(func)
}

class AhkStdlibFunctoolsCachedPropertyValue
{
    __New(func)
    {
        this.AhkStdlibFunc := func
        this.AhkStdlibCacheKey := "__cached_" (A_TickCount) "_" Random(1, 0x7FFFFFFF)
    }

    Get(instance)
    {
        key := this.AhkStdlibCacheKey
        if HasProp(instance, key)
            return instance.%key%
        value := this.AhkStdlibFunc.Call(instance)
        instance.DefineProp(key, { Value: value })
        return value
    }

    ; Attach as a real property getter on a class prototype.
    Bind(cls, name)
    {
        self := this
        cls.Prototype.DefineProp(name, { Get: (instance) => self.Get(instance) })
        return this
    }
}

; ---------------------------------------------------------------------------
; partialmethod
; ---------------------------------------------------------------------------

; partialmethod is like partial but designed to be used as a method descriptor.
; Without descriptors, expose it as a callable that prepends the instance plus
; the bound args when invoked as obj.method(...) via a prototype binding helper.
AhkStdlibFunctoolsPartialMethod(callback, boundArgs*)
{
    return AhkStdlibFunctoolsPartialMethodValue(callback, boundArgs*)
}

class AhkStdlibFunctoolsPartialMethodValue
{
    __New(callback, boundArgs*)
    {
        if !(IsObject(callback) && HasMethod(callback, "Call"))
            throw TypeError("the first argument must be callable", -1)
        this.AhkStdlibFunc := callback
        this.AhkStdlibArgs := boundArgs
    }

    ; Called as obj.method(extra*) once bound; prepends instance + bound args.
    Call(instance, args*)
    {
        combined := [instance]
        for value in this.AhkStdlibArgs
            combined.Push(value)
        for value in args
            combined.Push(value)
        return this.AhkStdlibFunc.Call(combined*)
    }

    Bind(cls, name)
    {
        self := this
        cls.Prototype.DefineProp(name, { Call: (instance, args*) => self.Call(instance, args*) })
        return this
    }
}


; ---- singledispatch ----
; Generic-function dispatch on the type of the FIRST argument. .register(type,
; fn) adds an implementation; .register(type) returns a decorator that
; registers and returns fn. Resolution walks the value's prototype (.base)
; chain so subclasses fall back to a registered superclass; primitives map to
; the Integer/Float/String/Number built-in classes. Python's ABC-based virtual
; dispatch is approximated by concrete AHK types only.
class AhkStdlibFunctoolsSingleDispatch
{
    __New(target)
    {
        this.DefineProp("AhkStdlibDefault", { Value: target })
        ; Keyed by class Prototype object for identity-safe MRO matching.
        this.AhkStdlibRegistry := Map()
        this.registry := this.AhkStdlibRegistry
    }

    register(cls, fn := unset)
    {
        if !IsSet(fn) {
            captured := cls
            return (implementation) => this.AhkStdlibRegisterImpl(captured, implementation)
        }
        return this.AhkStdlibRegisterImpl(cls, fn)
    }

    AhkStdlibRegisterImpl(cls, fn)
    {
        if !HasMethod(fn, "Call")
            throw TypeError("Invalid registration: the implementation must be callable", -1)
        this.AhkStdlibRegistry[AhkStdlibFunctoolsProtoKey(cls)] := fn
        return fn
    }

    dispatch(cls)
    {
        found := AhkStdlibFunctoolsDispatchByClass(this.AhkStdlibRegistry, cls)
        return IsSet(found) ? found : this.AhkStdlibDefault
    }

    Call(args*)
    {
        if args.Length < 1
            throw TypeError("dispatcher requires at least 1 positional argument", -1)
        fn := AhkStdlibFunctoolsDispatchByValue(this.AhkStdlibRegistry, args[1], this.AhkStdlibDefault)
        return fn.Call(args*)
    }
}

; singledispatchmethod: dispatch on the SECOND argument (first after `this`).
class AhkStdlibFunctoolsSingleDispatchMethod
{
    __New(target)
    {
        this.DefineProp("AhkStdlibDefault", { Value: target })
        this.AhkStdlibRegistry := Map()
        this.registry := this.AhkStdlibRegistry
    }

    register(cls, fn := unset)
    {
        if !IsSet(fn) {
            captured := cls
            return (implementation) => this.AhkStdlibRegisterImpl(captured, implementation)
        }
        return this.AhkStdlibRegisterImpl(cls, fn)
    }

    AhkStdlibRegisterImpl(cls, fn)
    {
        if !HasMethod(fn, "Call")
            throw TypeError("Invalid registration: the implementation must be callable", -1)
        this.AhkStdlibRegistry[AhkStdlibFunctoolsProtoKey(cls)] := fn
        return fn
    }

    dispatch(cls)
    {
        found := AhkStdlibFunctoolsDispatchByClass(this.AhkStdlibRegistry, cls)
        return IsSet(found) ? found : this.AhkStdlibDefault
    }

    Call(instance, args*)
    {
        if args.Length < 1
            throw TypeError("singledispatchmethod requires at least 1 positional argument after self", -1)
        fn := AhkStdlibFunctoolsDispatchByValue(this.AhkStdlibRegistry, args[1], this.AhkStdlibDefault)
        return fn.Call(instance, args*)
    }

    Bind(cls, name)
    {
        self := this
        cls.Prototype.DefineProp(name, { Call: (instance, args*) => self.Call(instance, args*) })
        return this
    }
}

; A class registers under its Prototype; built-in primitive classes (Integer,
; Float, String, Number, Object) likewise expose .Prototype, so one rule works
; for both. A bare prototype passed in is used as-is.
AhkStdlibFunctoolsProtoKey(cls)
{
    if IsObject(cls) && HasProp(cls, "Prototype") && IsObject(cls.Prototype)
        return cls.Prototype
    return cls
}

; Resolve for a concrete runtime value.
AhkStdlibFunctoolsDispatchByValue(registry, value, default)
{
    if IsObject(value) {
        proto := value.base
        while IsObject(proto) {
            if registry.Has(proto)
                return registry[proto]
            proto := proto.base
        }
        return default
    }
    ; Primitive: exact type first, then Number for numerics.
    if value is Integer {
        if registry.Has(Integer.Prototype)
            return registry[Integer.Prototype]
        if registry.Has(Number.Prototype)
            return registry[Number.Prototype]
    } else if value is Float {
        if registry.Has(Float.Prototype)
            return registry[Float.Prototype]
        if registry.Has(Number.Prototype)
            return registry[Number.Prototype]
    } else if value is String {
        if registry.Has(String.Prototype)
            return registry[String.Prototype]
    }
    return default
}

; Resolve for an explicit class argument (.dispatch(Type)).
AhkStdlibFunctoolsDispatchByClass(registry, cls)
{
    proto := AhkStdlibFunctoolsProtoKey(cls)
    while IsObject(proto) {
        if registry.Has(proto)
            return registry[proto]
        proto := proto.base
    }
    return unset
}
