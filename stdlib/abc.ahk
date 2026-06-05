#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibAbc
{
    static ABC := AhkStdlibAbcBase
    static AhkStdlibCacheToken := 0

    static abstractmethod(args*)
    {
        if args.Length < 1
            throw TypeError("abstractmethod() missing 1 required positional argument: 'funcobj'", -1)
        if args.Length > 1
            throw TypeError("abstractmethod() takes 1 positional argument but " args.Length " were given", -1)

        funcobj := args[1]
        if !IsObject(funcobj)
            throw TypeError("'" AhkStdlibPythonTypeName(funcobj) "' object is not callable", -1)

        funcobj.DefineProp("__isabstractmethod__", { Value: true })
        return funcobj
    }

    static isabstract(value)
    {
        if IsObject(value) && HasProp(value, "Prototype")
            return AhkStdlibAbcClassIsAbstract(value)
        return AhkStdlibAbcInstanceIsAbstract(value)
    }

    static isinstance(instance, cls)
    {
        return instance is cls
    }

    static get_cache_token(args*)
    {
        if args.Length != 0
            throw TypeError("_abc.get_cache_token() takes no arguments (" args.Length " given)", -1)
        return AhkStdlibAbc.AhkStdlibCacheToken
    }
}

class AhkStdlibAbcBase
{
    static register(args*)
    {
        if args.Length = 0
            throw TypeError("ABCMeta.register() missing 1 required positional argument: 'subclass'", -1)
        if args.Length > 1
            throw TypeError("ABCMeta.register() takes 2 positional arguments but " args.Length + 1 " were given", -1)

        subclass := args[1]
        if !IsObject(subclass) || !HasProp(subclass, "Prototype")
            throw TypeError("Can only register classes", -1)

        if subclass = this
            return subclass

        if subclass.Prototype.Base = this.Prototype
            return subclass

        subclass.Prototype.Base := this.Prototype
        AhkStdlibAbc.AhkStdlibCacheToken += 1
        return subclass
    }
}

stdlib.abc := AhkStdlibAbc

AhkStdlibAbcClassIsAbstract(cls)
{
    if !IsObject(cls) || !HasProp(cls, "Prototype")
        return false

    for name, member in cls.Prototype.OwnProps() {
        if IsObject(member) && member.HasOwnProp("__isabstractmethod__") && member.__isabstractmethod__
            return true
    }
    return false
}

AhkStdlibAbcInstanceIsAbstract(instance)
{
    if !IsObject(instance)
        return false

    currentProto := instance.Base
    while IsObject(currentProto) {
        for name, member in currentProto.OwnProps() {
            if IsObject(member) && member.HasOwnProp("__isabstractmethod__") && member.__isabstractmethod__
                return true
        }
        currentProto := currentProto.Base
    }
    return false
}
