#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\assert>

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
        AhkStdlibAbcMarkAbstract(funcobj)
        return funcobj
    }

    static abstractstaticmethod(args*)
    {
        if args.Length < 1
            throw TypeError("abstractstaticmethod.__init__() missing 1 required positional argument: 'callable'", -1)
        if args.Length > 1
            throw TypeError("abstractstaticmethod.__init__() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return AhkStdlibAbcAbstractStaticMethod(args[1])
    }

    static abstractclassmethod(args*)
    {
        if args.Length < 1
            throw TypeError("abstractclassmethod.__init__() missing 1 required positional argument: 'callable'", -1)
        if args.Length > 1
            throw TypeError("abstractclassmethod.__init__() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return AhkStdlibAbcAbstractClassMethod(args[1])
    }

    static abstractproperty(args*)
    {
        if args.Length > 4
            throw TypeError("property() takes at most 4 arguments (" args.Length " given)", -1)

        fget := args.Length >= 1 ? args[1] : stdlib.None
        fset := args.Length >= 2 ? args[2] : stdlib.None
        fdel := args.Length >= 3 ? args[3] : stdlib.None
        return AhkStdlibAbcAbstractProperty(fget, fset, fdel)
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
    __New(args*)
    {
        AhkStdlibAbcRequireConcrete(this)
    }

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

        if AhkStdlibAbcIsSubclass(this, subclass)
            throw RuntimeError("Refusing to create an inheritance cycle", -1)

        AhkStdlibAbcVirtualRegistryAdd(this, subclass)
        AhkStdlibAbc.AhkStdlibCacheToken += 1
        return subclass
    }
}

class AhkStdlibAbcAbstractStaticMethod
{
    __New(funcobj)
    {
        AhkStdlibAbcMarkAbstract(funcobj)
        this.__func := funcobj
        this.DefineProp("__isabstractmethod", { Value: true })
    }

    Call(args*)
    {
        return this.__func.Call(args*)
    }
}

class AhkStdlibAbcAbstractClassMethod
{
    __New(funcobj)
    {
        AhkStdlibAbcMarkAbstract(funcobj)
        this.__func := funcobj
        this.DefineProp("__isabstractmethod", { Value: true })
    }

    Call(args*)
    {
        return this.__func.Call(args*)
    }
}

class AhkStdlibAbcAbstractProperty
{
    __New(fget, fset, fdel)
    {
        this.fget := fget
        this.fset := fset
        this.fdel := fdel
        this.DefineProp("__isabstractmethod", { Value: true })
    }

    Get(instance)
    {
        return this.fget.Call(instance)
    }

    Set(instance, value)
    {
        this.fset.Call(instance, value)
        return stdlib.None
    }

    Delete(instance)
    {
        this.fdel.Call(instance)
        return stdlib.None
    }
}

stdlib.abc := AhkStdlibAbc

AhkStdlibAbcMarkAbstract(value)
{
    if !IsObject(value)
        throw AttributeError("'" AhkStdlibPythonTypeName(value) "' object has no attribute '__isabstractmethod__'", -1)
    value.DefineProp("__isabstractmethod", { Value: true })
}

AhkStdlibAbcRequireCallable(value)
{
    if !IsObject(value) || !HasMethod(value, "Call")
        throw TypeError("'" AhkStdlibPythonTypeName(value) "' object is not callable", -1)
}

AhkStdlibAbcIsInstance(instance, cls)
{
    if !IsObject(cls) || !HasProp(cls, "Prototype")
        return false
    if !IsObject(instance)
        return false

    instanceClass := AhkStdlibAbcInstanceClass(instance)
    if IsObject(instanceClass) && HasProp(instanceClass, "Prototype")
        return AhkStdlibAbcIsSubclass(instanceClass, cls)

    if instance is cls
        return true
    return AhkStdlibAbcPrototypeHasVirtualBase(instance.Base, cls)
}

AhkStdlibAbcInstanceClass(instance)
{
    if !IsObject(instance)
        return false

    try proto := instance.Base
    catch
        return false

    if !IsObject(proto) || !HasProp(proto, "__Class")
        return false

    className := proto.__Class
    try cls := %className%
    catch
        return false

    if IsObject(cls) && HasProp(cls, "Prototype") && ObjPtr(cls.Prototype) = ObjPtr(proto)
        return cls
    return false
}

AhkStdlibAbcIsSubclass(subclass, cls)
{
    if !IsObject(subclass) || !HasProp(subclass, "Prototype")
        return false
    if !IsObject(cls) || !HasProp(cls, "Prototype")
        return false
    hookResult := AhkStdlibAbcSubclassHookResult(cls, subclass)
    if !AhkStdlibIsNotImplemented(hookResult)
        return hookResult
    if AhkStdlibAbcClassExtends(subclass, cls)
        return true
    return AhkStdlibAbcVirtualRegistryHas(cls, subclass)
}

AhkStdlibAbcSubclassHookResult(cls, subclass)
{
    if !HasMethod(cls, "__subclasshook")
        return stdlib.NotImplemented

    result := cls.__subclasshook(subclass)
    if AhkStdlibIsNotImplemented(result)
        return stdlib.NotImplemented
    if result == true
        return true
    if result == false
        return false

    throw stdlib.assert.AssertionError("__subclasshook__ must return either False, True, or NotImplemented", -1)
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
            instanceCls := AhkStdlibAbcPrototypeClass(currentProto)
            if IsObject(instanceCls) && AhkStdlibAbcVirtualRegistryHas(registeredCls, instanceCls)
                return true
        }
        currentProto := currentProto.Base
    }
    return false
}

AhkStdlibAbcPrototypeClass(proto)
{
    if !IsObject(proto) || !HasProp(proto, "__Class")
        return false

    try cls := %proto.__Class%
    catch
        return false

    if IsObject(cls) && HasProp(cls, "Prototype") && ObjPtr(cls.Prototype) = ObjPtr(proto)
        return cls
    return false
}

AhkStdlibAbcVirtualRegistryAdd(cls, subclass)
{
    registry := AhkStdlibAbcVirtualRegistryGet(cls, true)
    registry[AhkStdlibAbcClassKey(subclass)] := subclass
}

AhkStdlibAbcVirtualRegistryHas(cls, subclass)
{
    return AhkStdlibAbcVirtualRegistryHasVisited(cls, subclass, Map())
}

AhkStdlibAbcVirtualRegistryHasVisited(cls, subclass, seen)
{
    registry := AhkStdlibAbcVirtualRegistryGet(cls)
    if !IsObject(registry)
        return false
    clsKey := AhkStdlibAbcClassKey(cls)
    if seen.Has(clsKey)
        return false
    seen[clsKey] := true

    if registry.Has(AhkStdlibAbcClassKey(subclass))
        return true

    for key, registeredCls in registry {
        if AhkStdlibAbcClassExtends(subclass, registeredCls)
            return true
        if AhkStdlibAbcVirtualRegistryHasVisited(registeredCls, subclass, seen)
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

AhkStdlibAbcRequireConcrete(instance)
{
    cls := AhkStdlibAbcInstanceClass(instance)
    if !IsObject(cls) || !HasProp(cls, "Prototype")
        return
    if !AhkStdlibAbcClassIsAbstract(cls)
        return

    abstractNames := AhkStdlibAbcAbstractMethodNames(cls)
    if abstractNames.Length = 0
        return

    throw TypeError("Can't instantiate abstract class " cls.Prototype.__Class " with " AhkStdlibAbcFormatAbstractMethodList(abstractNames), -1)
}

AhkStdlibAbcAbstractMethodNames(cls)
{
    names := []
    if AhkStdlibAbcClassHasAbstractCache(cls) {
        for name, isAbstract in cls.AhkStdlibAbstractMethods {
            if isAbstract
                names.Push(name)
        }
        return names
    }

    currentProto := cls.Prototype
    seenMethods := Map()
    while IsObject(currentProto) {
        if HasMethod(currentProto, "OwnProps") {
            for name, member in currentProto.OwnProps() {
                if seenMethods.Has(name)
                    continue
                seenMethods[name] := true
                if AhkStdlibAbcMemberIsAbstract(member)
                    names.Push(name)
            }
        }
        currentProto := currentProto.Base
    }
    return names
}

AhkStdlibAbcFormatAbstractMethodList(names)
{
    joinedNames := ""
    for index, name in names {
        if index > 1
            joinedNames .= ", "
        joinedNames .= name
    }

    if names.Length = 1
        return "abstract method " joinedNames
    return "abstract methods " joinedNames
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
    return IsObject(member) && member.HasOwnProp("__isabstractmethod") && member.__isabstractmethod
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
