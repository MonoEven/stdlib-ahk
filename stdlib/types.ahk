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
        this.__name__ := name
        this.__doc__ := doc
    }
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
