#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibInspect
{
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
}

stdlib.inspect := AhkStdlibInspect
