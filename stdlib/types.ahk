#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibTypes
{
    static FunctionType := Func
    static LambdaType := Func
    static BuiltinFunctionType := Func
    static BuiltinMethodType := Func
    static MethodType := BoundFunc

    static ModuleType(name, doc := "")
    {
        return AhkStdlibTypesModule(name, doc)
    }

    static SimpleNamespace(attributes := unset)
    {
        if IsSet(attributes)
            return AhkStdlibTypesSimpleNamespace(attributes)
        return AhkStdlibTypesSimpleNamespace()
    }

    static MappingProxyType(mapping)
    {
        return AhkStdlibTypesMappingProxy(mapping)
    }

    ; CoroutineType / GeneratorType: AHK has no native coroutine/generator
    ; objects, so these are protocol objects whose isinstance(obj) duck-types the
    ; relevant capability (same pattern as collections.abc / inspect). Coroutines
    ; come from stdlib.asyncio (carry the asyncio step hook); generators require
    ; yield, so GeneratorType matches nothing.
    static CoroutineType := AhkStdlibTypesCoroutineType
    static GeneratorType := AhkStdlibTypesGeneratorType
}

class AhkStdlibTypesCoroutineType
{
    static isinstance(obj)
    {
        return IsObject(obj) && HasMethod(obj, "AhkStdlibAsyncioStep")
    }
}

class AhkStdlibTypesGeneratorType
{
    static isinstance(obj)
    {
        return false
    }
}

class AhkStdlibTypesSimpleNamespace
{
    __New(attributes := unset)
    {
        if !IsSet(attributes)
            return

        if attributes is Map {
            for name, value in attributes
                this.%name% := value
            return
        }

        if attributes is Object {
            for name, value in attributes.OwnProps()
                this.%name% := value
            return
        }

        throw TypeError("SimpleNamespace attributes must be a Map or Object", -1)
    }

    Equals(other)
    {
        if !(other is AhkStdlibTypesSimpleNamespace)
            return false

        if AhkStdlibTypesOwnPropCount(this) != AhkStdlibTypesOwnPropCount(other)
            return false

        for name, value in this.OwnProps() {
            if !other.HasOwnProp(name)
                return false
            if !AhkStdlibTypesAreEqual(value, other.%name%)
                return false
        }

        return true
    }
}

class AhkStdlibTypesModule
{
    __New(name, doc := "")
    {
        this.__name := name
        this.__doc := doc
    }
}

; Read-only view over a Map (Python's types.MappingProxyType). Reads delegate to
; the wrapped mapping and reflect later mutations of it; writes raise like
; Python's "'mappingproxy' object does not support item assignment".
class AhkStdlibTypesMappingProxy
{
    __New(mapping)
    {
        if !(mapping is Map)
            throw TypeError("mappingproxy() argument must be a mapping, not " AhkStdlibPythonTypeName(mapping), -1)
        this.AhkStdlibMapping := mapping
    }

    __Item[key]
    {
        get {
            if !this.AhkStdlibMapping.Has(key)
                throw KeyError(AhkStdlibTypesMappingKeyRepr(key), -1)
            return this.AhkStdlibMapping[key]
        }
        set => AhkStdlibTypesMappingProxyReadonly()
    }

    Has(key) => this.AhkStdlibMapping.Has(key)

    Count => this.AhkStdlibMapping.Count

    get(key, default := unset)
    {
        if this.AhkStdlibMapping.Has(key)
            return this.AhkStdlibMapping[key]
        return IsSet(default) ? default : stdlib.None
    }

    keys()
    {
        result := []
        for key in this.AhkStdlibMapping
            result.Push(key)
        return result
    }

    values()
    {
        result := []
        for , value in this.AhkStdlibMapping
            result.Push(value)
        return result
    }

    items()
    {
        result := []
        for key, value in this.AhkStdlibMapping
            result.Push(stdlib.tuple([key, value]))
        return result
    }

    copy()
    {
        ; Python's mappingproxy.copy() returns a plain dict.
        cloned := Map()
        for key, value in this.AhkStdlibMapping
            cloned[key] := value
        return cloned
    }

    __Enum(numberOfVars)
    {
        return this.AhkStdlibMapping.__Enum(numberOfVars)
    }

    __Repr()
    {
        return "mappingproxy(" AhkStdlibTypesMapRepr(this.AhkStdlibMapping) ")"
    }
}

AhkStdlibTypesMappingProxyReadonly()
{
    throw TypeError("'mappingproxy' object does not support item assignment", -1)
}

AhkStdlibTypesMappingKeyRepr(key)
{
    if key is String
        return "'" key "'"
    return String(key)
}

AhkStdlibTypesMapRepr(mapping)
{
    parts := []
    for key, value in mapping
        parts.Push(AhkStdlibTypesMappingKeyRepr(key) ": " AhkStdlibTypesRepr(value))
    joined := ""
    for index, part in parts {
        if index > 1
            joined .= ", "
        joined .= part
    }
    return "{" joined "}"
}

AhkStdlibTypesRepr(value)
{
    if value is String
        return "'" value "'"
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    return String(value)
}

stdlib.types := AhkStdlibTypes

AhkStdlibTypesOwnPropCount(value)
{
    count := 0
    for name in value.OwnProps()
        count += 1
    return count
}

AhkStdlibTypesAreEqual(expected, actual)
{
    if IsObject(expected) || IsObject(actual) {
        if !IsObject(expected) || !IsObject(actual)
            return false

        if expected is Array && actual is Array {
            if expected.Length != actual.Length
                return false
            loop expected.Length {
                if !AhkStdlibTypesAreEqual(expected[A_Index], actual[A_Index])
                    return false
            }
            return true
        }

        if expected is Map && actual is Map {
            if expected.Count != actual.Count
                return false
            for key, expectedValue in expected {
                if !actual.Has(key)
                    return false
                if !AhkStdlibTypesAreEqual(expectedValue, actual[key])
                    return false
            }
            return true
        }

        return expected == actual
    }

    return expected == actual
}
