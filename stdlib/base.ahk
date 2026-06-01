#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibCoreBase
{
    static checkType(expectedClass, value?)
    {
        if !IsSet(value)
            throw UnsetError()
        if !(value is expectedClass)
            throw TypeError(expectedClass.Prototype.__Class)
    }

    static delattr(obj, name)
    {
        if !(name is String)
            throw TypeError("attribute name must be string, not '" AhkStdlibCoreBasePythonTypeName(name) "'", -1)

        if !IsObject(obj)
            throw PropertyError("'" AhkStdlibCoreBasePythonTypeName(obj) "' object has no attribute '" name "'", -1)

        hadOwn := obj.HasOwnProp(name)
        hasPythonDictEntry := false
        if !hadOwn {
            try dictValue := obj.__dict__
            catch
                dictValue := unset
            if IsSet(dictValue) && dictValue is Map && dictValue.Has(name)
                hasPythonDictEntry := true
        }

        try
            removed := obj.DeleteProp(name)
        catch PropertyError
            throw

        if hadOwn || hasPythonDictEntry
            return removed

        throw PropertyError("'" AhkStdlibCoreBasePythonTypeName(obj) "' object has no attribute '" name "'", -1)
    }
}

stdlib.base := AhkStdlibCoreBase

AhkStdlibCoreBasePythonTypeName(value)
{
    if value is String
        return "str"
    if value is Integer
        return "int"
    if value is Float
        return "float"
    if value is Array
        return "list"
    if value is Map
        return "dict"
    return Type(value)
}
