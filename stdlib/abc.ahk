#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibAbc
{
    static ABC := AhkStdlibAbcBase
    static ABCMeta := AhkStdlibAbcBase
    static AhkStdlibCacheToken := 0
    static AhkStdlibVirtualRegistries := Map()

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

    static abstractstaticmethod(args*)
    {
        if args.Length < 1
            throw TypeError("abstractstaticmethod() missing 1 required positional argument: 'callable'", -1)
        if args.Length > 1
            throw TypeError("abstractstaticmethod() takes 1 positional argument but " args.Length " were given", -1)
        return AhkStdlibAbcAbstractStaticMethod(args[1])
    }

    static abstractclassmethod(args*)
    {
        if args.Length < 1
            throw TypeError("abstractclassmethod() missing 1 required positional argument: 'callable'", -1)
        if args.Length > 1
            throw TypeError("abstractclassmethod() takes 1 positional argument but " args.Length " were given", -1)
        return AhkStdlibAbcAbstractClassMethod(args[1])
    }

    static abstractproperty(args*)
    {
        if args.Length < 1
            throw TypeError("abstractproperty() missing 1 required positional argument: 'fget'", -1)
        if args.Length > 1
            throw TypeError("abstractproperty() takes 1 positional argument but " args.Length " were given", -1)
        return AhkStdlibAbcAbstractProperty(args[1])
    }

    static isabstract(value)
    {
        if IsObject(value) && HasProp(value, "Prototype")
            return AhkStdlibAbcClassIsAbstract(value)
        return AhkStdlibAbcInstanceIsAbstract(value)
    }

    static isinstance(instance, cls)
    {
        return AhkStdlibAbcIsInstance(instance, cls)
    }

    static issubclass(subclass, cls)
    {
        return AhkStdlibAbcIsSubclass(subclass, cls)
    }

    static get_cache_token(args*)
    {
        if args.Length != 0
            throw TypeError("_abc.get_cache_token() takes no arguments (" args.Length " given)", -1)
        return AhkStdlibAbc.AhkStdlibCacheToken
    }

    static update_abstractmethods(args*)
    {
        if args.Length < 1
            throw TypeError("update_abstractmethods() missing 1 required positional argument: 'cls'", -1)
        if args.Length > 1
            throw TypeError("update_abstractmethods() takes 1 positional argument but " args.Length " were given", -1)

        cls := args[1]
        if !IsObject(cls) || !HasProp(cls, "Prototype")
            return cls

        if !AhkStdlibAbcClassHasAbstractCache(cls)
            return cls

        cls.AhkStdlibAbstractMethods := AhkStdlibAbcCollectAbstractMethods(cls)
        return cls
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

        if AhkStdlibAbcClassExtends(subclass, this)
            return subclass

        if AhkStdlibAbcVirtualRegistryHas(this, subclass)
            return subclass

        AhkStdlibAbcVirtualRegistryAdd(this, subclass)
        AhkStdlibAbc.AhkStdlibCacheToken += 1
        return subclass
    }
}

class AhkStdlibAbcAbstractStaticMethod
{
    __New(funcobj)
    {
        AhkStdlibAbcRequireCallable(funcobj)
        funcobj.DefineProp("__isabstractmethod__", { Value: true })
        this.__func__ := funcobj
        this.DefineProp("__isabstractmethod__", { Value: true })
    }

    Call(args*)
    {
        return this.__func__.Call(args*)
    }
}

class AhkStdlibAbcAbstractClassMethod
{
    __New(funcobj)
    {
        AhkStdlibAbcRequireCallable(funcobj)
        funcobj.DefineProp("__isabstractmethod__", { Value: true })
        this.__func__ := funcobj
        this.DefineProp("__isabstractmethod__", { Value: true })
    }

    Call(args*)
    {
        return this.__func__.Call(args*)
    }
}

class AhkStdlibAbcAbstractProperty
{
    __New(fget)
    {
        AhkStdlibAbcRequireCallable(fget)
        this.fget := fget
        this.DefineProp("__isabstractmethod__", { Value: true })
    }

    Get(instance)
    {
        return this.fget.Call(instance)
    }
}

stdlib.abc := AhkStdlibAbc

AhkStdlibAbcRequireCallable(value)
{
    if !IsObject(value) || !HasMethod(value, "Call")
        throw TypeError("'" AhkStdlibPythonTypeName(value) "' object is not callable", -1)
}

AhkStdlibAbcIsInstance(instance, cls)
{
    if IsObject(cls) && HasProp(cls, "Prototype") {
        if instance is cls
            return true
        if IsObject(instance)
            return AhkStdlibAbcPrototypeHasVirtualBase(instance.Base, cls)
    }
    return false
}

AhkStdlibAbcIsSubclass(subclass, cls)
{
    if !IsObject(subclass) || !HasProp(subclass, "Prototype")
        return false
    if !IsObject(cls) || !HasProp(cls, "Prototype")
        return false
    if AhkStdlibAbcClassExtends(subclass, cls)
        return true
    return AhkStdlibAbcVirtualRegistryHas(cls, subclass)
}

AhkStdlibAbcClassExtends(subclass, cls)
{
    if !IsObject(subclass) || !HasProp(subclass, "Prototype")
        return false
    if !IsObject(cls) || !HasProp(cls, "Prototype")
        return false

    targetProto := cls.Prototype
    currentProto := subclass.Prototype
    while IsObject(currentProto) {
        if ObjPtr(currentProto) = ObjPtr(targetProto)
            return true
        currentProto := currentProto.Base
    }
    return false
}

AhkStdlibAbcPrototypeHasVirtualBase(proto, cls)
{
    registry := AhkStdlibAbcVirtualRegistryGet(cls)
    if !IsObject(registry)
        return false

    currentProto := proto
    while IsObject(currentProto) {
        for key, registeredCls in registry {
            if ObjPtr(currentProto) = ObjPtr(registeredCls.Prototype)
                return true
        }
        currentProto := currentProto.Base
    }
    return false
}

AhkStdlibAbcVirtualRegistryAdd(cls, subclass)
{
    registry := AhkStdlibAbcVirtualRegistryGet(cls, true)
    registry[AhkStdlibAbcClassKey(subclass)] := subclass
}

AhkStdlibAbcVirtualRegistryHas(cls, subclass)
{
    registry := AhkStdlibAbcVirtualRegistryGet(cls)
    if !IsObject(registry)
        return false
    if registry.Has(AhkStdlibAbcClassKey(subclass))
        return true

    for key, registeredCls in registry {
        if AhkStdlibAbcClassExtends(subclass, registeredCls)
            return true
    }
    return false
}

AhkStdlibAbcVirtualRegistryGet(cls, create := false)
{
    if !IsObject(cls) || !HasProp(cls, "Prototype")
        return false
    key := AhkStdlibAbcClassKey(cls)
    registries := AhkStdlibAbc.AhkStdlibVirtualRegistries
    if !registries.Has(key) {
        if !create
            return false
        registries[key] := Map()
    }
    return registries[key]
}

AhkStdlibAbcClassKey(cls)
{
    return Format("{:016X}", ObjPtr(cls))
}

AhkStdlibAbcClassIsAbstract(cls)
{
    if !IsObject(cls) || !HasProp(cls, "Prototype")
        return false

    if AhkStdlibAbcClassHasAbstractCache(cls)
        return cls.AhkStdlibAbstractMethods.Count > 0

    if AhkStdlibAbcPrototypeHasAbstractMembers(cls.Prototype)
        return true
    return false
}

AhkStdlibAbcInstanceIsAbstract(instance)
{
    if !IsObject(instance)
        return false

    currentProto := instance.Base
    while IsObject(currentProto) {
        if AhkStdlibAbcPrototypeHasAbstractMembers(currentProto)
            return true
        currentProto := currentProto.Base
    }
    return false
}

AhkStdlibAbcMemberIsAbstract(member)
{
    return IsObject(member) && member.HasOwnProp("__isabstractmethod__") && member.__isabstractmethod__
}

AhkStdlibAbcClassHasAbstractCache(cls)
{
    return IsObject(cls) && cls.HasOwnProp("AhkStdlibAbstractMethods")
}

AhkStdlibAbcCollectAbstractMethods(cls)
{
    abstractMethods := Map()
    seenMethods := Map()
    if !IsObject(cls) || !HasProp(cls, "Prototype")
        return abstractMethods

    currentProto := cls.Prototype
    while IsObject(currentProto) {
        if HasMethod(currentProto, "OwnProps") {
            for name, member in currentProto.OwnProps() {
                if seenMethods.Has(name)
                    continue
                seenMethods[name] := true
                if AhkStdlibAbcMemberIsAbstract(member)
                    abstractMethods[name] := true
            }
        } else if HasMethod(currentProto, "__Enum") {
            for name, member in currentProto {
                if seenMethods.Has(name)
                    continue
                seenMethods[name] := true
                if AhkStdlibAbcMemberIsAbstract(member)
                    abstractMethods[name] := true
            }
        }
        currentProto := currentProto.Base
    }
    return abstractMethods
}

AhkStdlibAbcPrototypeHasAbstractMembers(proto)
{
    if !IsObject(proto)
        return false

    if HasMethod(proto, "OwnProps") {
        for name, member in proto.OwnProps() {
            if AhkStdlibAbcMemberIsAbstract(member)
                return true
        }
    } else if HasMethod(proto, "__Enum") {
        for name, member in proto {
            if AhkStdlibAbcMemberIsAbstract(member)
                return true
        }
    }
    return false
}
