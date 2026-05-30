#Requires AutoHotkey v2.0

class stdlib
{
    static None := AhkStdlibNone()
    static NotImplemented := AhkStdlibNotImplemented()
    static True := AhkStdlibBool(true)
    static False := AhkStdlibBool(false)

    static NotImplementedError
    {
        get => NotImplementedError
    }

    static NotImplementedError(args*)
    {
        return NotImplementedError(args*)
    }

    static RuntimeError
    {
        get => RuntimeError
    }

    static RuntimeError(args*)
    {
        return RuntimeError(args*)
    }

    static StopIteration
    {
        get => StopIteration
    }

    static StopIteration(args*)
    {
        return StopIteration(args*)
    }

    static KeyError
    {
        get => KeyError
    }

    static KeyError(args*)
    {
        return KeyError(args*)
    }

    static SystemError
    {
        get => SystemError
    }

    static SystemError(args*)
    {
        return SystemError(args*)
    }

    static tuple(iterable := unset)
    {
        if !IsSet(iterable)
            return AhkStdlibTuple()
        return AhkStdlibTupleFrom(iterable)
    }
}

class NotImplementedError extends Error
{
}

class RuntimeError extends Error
{
}

class StopIteration extends Error
{
}

class KeyError extends Error
{
}

class SystemError extends Error
{
}

AhkStdlibNone()
{
    static value := { __AhkStdlibNone: true }
    return value
}

AhkStdlibNotImplemented()
{
    static value := { __AhkStdlibNotImplemented: true }
    return value
}

class AhkStdlibBoolean
{
    __New(value)
    {
        this.Value := value ? true : false
    }
}

AhkStdlibBool(value)
{
    static trueValue := AhkStdlibBoolean(true)
    static falseValue := AhkStdlibBoolean(false)
    return value ? trueValue : falseValue
}

AhkStdlibIsNone(value)
{
    return IsObject(value) && !(value !== AhkStdlibNone())
}

AhkStdlibIsNotImplemented(value)
{
    return IsObject(value) && !(value !== AhkStdlibNotImplemented())
}

AhkStdlibIsBool(value)
{
    return value is AhkStdlibBoolean
}

AhkStdlibTruthValue(value)
{
    if AhkStdlibIsBool(value)
        return value.Value
    if AhkStdlibIsNone(value)
        return false
    if value is Array
        return value.Length != 0
    if value is Map
        return value.Count != 0
    return value ? true : false
}

class AhkStdlibTuple extends Array
{
    __New(values := unset)
    {
        this.AhkStdlibInitializing := true
        if IsSet(values) {
            for value in values
                super.Push(value)
        }
        this.AhkStdlibInitializing := false
    }

    __Item[index]
    {
        get => super[index]
        set => AhkStdlibTupleMutation()
    }

    Length {
        get => super.Length
        set => AhkStdlibTupleMutation()
    }

    Push(values*)
    {
        if this.AhkStdlibInitializing
            return super.Push(values*)
        AhkStdlibTupleMutation()
    }

    Pop()
    {
        AhkStdlibTupleMutation()
    }

    InsertAt(index, values*)
    {
        AhkStdlibTupleMutation()
    }

    RemoveAt(index, length?)
    {
        AhkStdlibTupleMutation()
    }

    Delete(index)
    {
        AhkStdlibTupleMutation()
    }
}

AhkStdlibTupleFrom(iterable)
{
    if iterable is AhkStdlibTuple
        return iterable

    values := []
    if iterable is String {
        loop parse iterable
            values.Push(A_LoopField)
        return AhkStdlibTuple(values)
    }

    if IsObject(iterable) && HasMethod(iterable, "__Enum") {
        for value in iterable
            values.Push(value)
        return AhkStdlibTuple(values)
    }

    throw TypeError("'" AhkStdlibPythonTypeName(iterable) "' object is not iterable", -1)
}

AhkStdlibTupleMutation()
{
    throw TypeError("'tuple' object does not support item assignment", -1)
}

AhkStdlibPythonTypeName(value)
{
    if AhkStdlibIsNone(value)
        return "NoneType"
    if AhkStdlibIsNotImplemented(value)
        return "NotImplementedType"
    if AhkStdlibIsBool(value)
        return "bool"
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
    typeName := Type(value)
    if typeName = "Func" || typeName = "BoundFunc"
        return "function"
    if IsObject(value) && typeName != "Object"
        return AhkStdlibLeafTypeName(typeName)
    if IsObject(value)
        return "object"
    return typeName
}

AhkStdlibLeafTypeName(typeName)
{
    dot := InStr(typeName, ".", false, -1)
    if dot
        return SubStr(typeName, dot + 1)
    return typeName
}
