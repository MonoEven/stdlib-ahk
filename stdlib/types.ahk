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

    ; GenericAlias: the runtime object Python builds for `list[int]`. CPython
    ; exposes it via the direct constructor types.GenericAlias(origin, args) as
    ; well, which is fully reproducible here (no syntax needed) — a value class
    ; holding __origin__/__args__ with a `origin[arg, ...]` repr.
    static GenericAlias(origin, args)
    {
        return AhkStdlibTypesGenericAlias(origin, args)
    }

    ; UnionType: the runtime type of `int | str`. CPython forbids constructing it
    ; directly (`types.UnionType(...)` raises TypeError); unions are born from the
    ; `|` operator, which AHK cannot overload on class objects. We mirror both: the
    ; type marker (.isinstance duck-types a union value, like CoroutineType) raises
    ; on call, and a Union(a, b, ...) builder stands in for the unavailable `|`,
    ; producing a value with __args__, an `a | b` repr, and member isinstance().
    static UnionType := AhkStdlibTypesUnionType

    static Union(members*)
    {
        return AhkStdlibTypesMakeUnion(members)
    }
}

; types.GenericAlias(origin, args) — e.g. GenericAlias(Array, [Integer, String])
; reprs as `Array[Integer, String]`. args may be a single value or an Array; it is
; always normalized to a tuple, mirroring CPython's __args__.
class AhkStdlibTypesGenericAlias
{
    __New(origin, args)
    {
        this.__origin := origin
        normalized := (args is Array) ? args : [args]
        this.__args := stdlib.tuple(normalized)
        this.__parameters := stdlib.tuple([])
    }

    __origin__ => this.__origin
    __args__ => this.__args
    __parameters__ => this.__parameters

    isinstance(obj)
    {
        ; Python: isinstance(x, list[int]) checks against the origin only
        ; (parameters are not enforced at runtime).
        return AhkStdlibTypesValueIsType(obj, this.__origin)
    }

    __Repr()
    {
        parts := []
        for arg in this.__args
            parts.Push(AhkStdlibTypesTypeName(arg))
        joined := ""
        for index, part in parts {
            if index > 1
                joined .= ", "
            joined .= part
        }
        return AhkStdlibTypesTypeName(this.__origin) "[" joined "]"
    }

    ToString() => this.__Repr()
}

; types.UnionType marker. `int | str` produces an instance of this type; the type
; itself cannot be instantiated (matches CPython's TypeError on call). Used here as
; an isinstance protocol object that recognizes union values built via types.Union.
class AhkStdlibTypesUnionType
{
    static Call(args*)
    {
        throw TypeError("cannot create 'types.UnionType' instances", -1)
    }

    static isinstance(obj)
    {
        return obj is AhkStdlibTypesUnion
    }
}

; A union value (what `int | str` evaluates to). Members are flattened (a union of
; unions merges) and de-duplicated, preserving first-seen order, exactly like
; CPython's `|`.
class AhkStdlibTypesUnion
{
    __New(members)
    {
        this.__members := members
    }

    __args__ => stdlib.tuple(this.__members)

    isinstance(obj)
    {
        for member in this.__members {
            if AhkStdlibTypesValueIsType(obj, member)
                return true
        }
        return false
    }

    Or(other)
    {
        ; Stand-in for `union | x` — returns a new merged union.
        return AhkStdlibTypesMakeUnion([this, other])
    }

    __Repr()
    {
        joined := ""
        for index, member in this.__members {
            if index > 1
                joined .= " | "
            joined .= AhkStdlibTypesTypeName(member)
        }
        return joined
    }

    ToString() => this.__Repr()
}

; Build a union from raw members: flatten nested unions, drop duplicates.
AhkStdlibTypesMakeUnion(members)
{
    flat := []
    for member in members {
        if member is AhkStdlibTypesUnion {
            for inner in member.__members
                AhkStdlibTypesUnionPush(flat, inner)
        } else {
            AhkStdlibTypesUnionPush(flat, member)
        }
    }
    if flat.Length < 2
        throw TypeError("a union requires at least two members", -1)
    return AhkStdlibTypesUnion(flat)
}

AhkStdlibTypesUnionPush(flat, member)
{
    for existing in flat {
        if existing == member
            return
    }
    flat.Push(member)
}

; Python-style name for a type/value used in GenericAlias / Union reprs.
AhkStdlibTypesTypeName(value)
{
    if value is AhkStdlibTypesGenericAlias || value is AhkStdlibTypesUnion
        return value.__Repr()
    if AhkStdlibIsNone(value)
        return "None"
    if Type(value) = "Class" {
        try
            return value.Prototype.__Class
    }
    if value is String
        return value
    return String(value)
}

; Does `obj` satisfy `expectedType` for GenericAlias/Union isinstance checks?
; Accepts an AHK Class (native `is`), a nested GenericAlias/Union (delegates), or
; None (matches the None singleton, mirroring `int | None`).
AhkStdlibTypesValueIsType(obj, expectedType)
{
    if expectedType is AhkStdlibTypesGenericAlias || expectedType is AhkStdlibTypesUnion
        return expectedType.isinstance(obj)
    if AhkStdlibIsNone(expectedType)
        return AhkStdlibIsNone(obj)
    if Type(expectedType) = "Class"
        return obj is expectedType
    return false
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
