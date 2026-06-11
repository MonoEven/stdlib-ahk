#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\abc>

class StdlibAbcTest
{
    static TestAbstractMethodMarksFunctionsAndRejectsObservedArity()
    {
        probe := stdlib.abc.abstractmethod((value) => value)

        AhkTest.AssertTrue(probe.HasOwnProp("__isabstractmethod"))
        AhkTest.AssertEqual(true, probe.__isabstractmethod)
        AhkTest.AssertEqual(3, probe.Call(3))
        AhkTest.RaisesMatch(TypeError, "^abstractmethod\(\) missing 1 required positional argument: 'funcobj'$", (*) => stdlib.abc.abstractmethod())
        AhkTest.RaisesMatch(TypeError, "^abstractmethod\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.abc.abstractmethod(1, 2))
    }

    static TestLegacyDescriptorHelperConstructorErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '__isabstractmethod__'$", (*) => stdlib.abc.abstractmethod(1))

        AhkTest.RaisesMatch(TypeError, "^abstractstaticmethod\.__init__\(\) missing 1 required positional argument: 'callable'$", (*) => stdlib.abc.abstractstaticmethod())
        AhkTest.RaisesMatch(TypeError, "^abstractstaticmethod\.__init__\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.abc.abstractstaticmethod((*) => stdlib.None, (*) => stdlib.None))
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '__isabstractmethod__'$", (*) => stdlib.abc.abstractstaticmethod(1))

        AhkTest.RaisesMatch(TypeError, "^abstractclassmethod\.__init__\(\) missing 1 required positional argument: 'callable'$", (*) => stdlib.abc.abstractclassmethod())
        AhkTest.RaisesMatch(TypeError, "^abstractclassmethod\.__init__\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.abc.abstractclassmethod((*) => stdlib.None, (*) => stdlib.None))
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '__isabstractmethod__'$", (*) => stdlib.abc.abstractclassmethod(1))
    }

    static TestAbcAndRegisterSupportCoveredVirtualSubclassSlice()
    {
        registered := stdlib.abc.ABC.register(StdlibAbcForeign)

        AhkTest.AssertSame(StdlibAbcForeign, registered)
        AhkTest.AssertFalse(stdlib.abc.isabstract(StdlibAbcForeign))
        AhkTest.AssertTrue(stdlib.abc.isinstance(StdlibAbcForeign(), stdlib.abc.ABC))
    }

    static TestRegisterUsesVirtualRegistryWithoutReparenting()
    {
        baseBefore := StdlibAbcVirtualRegistryForeign.Prototype.Base
        tokenBefore := stdlib.abc.get_cache_token()

        registered := stdlib.abc.ABC.register(StdlibAbcVirtualRegistryForeign)

        AhkTest.AssertSame(StdlibAbcVirtualRegistryForeign, registered)
        AhkTest.AssertEqual(1, stdlib.abc.get_cache_token() - tokenBefore)
        AhkTest.AssertSame(baseBefore, StdlibAbcVirtualRegistryForeign.Prototype.Base)
        AhkTest.AssertTrue(stdlib.abc.issubclass(StdlibAbcVirtualRegistryForeign, stdlib.abc.ABC))
        AhkTest.AssertTrue(stdlib.abc.isinstance(StdlibAbcVirtualRegistryForeign(), stdlib.abc.ABC))
        AhkTest.AssertTrue(stdlib.abc.issubclass(StdlibAbcVirtualRegistryReal, stdlib.abc.ABC))
        AhkTest.AssertTrue(stdlib.abc.isinstance(StdlibAbcVirtualRegistryReal(), stdlib.abc.ABC))
        AhkTest.AssertFalse(stdlib.abc.issubclass(StdlibAbcVirtualRegistryUnrelated, stdlib.abc.ABC))
        AhkTest.AssertFalse(stdlib.abc.isinstance(StdlibAbcVirtualRegistryUnrelated(), stdlib.abc.ABC))

        tokenBeforeDuplicate := stdlib.abc.get_cache_token()
        AhkTest.AssertSame(StdlibAbcVirtualRegistryForeign, stdlib.abc.ABC.register(StdlibAbcVirtualRegistryForeign))
        AhkTest.AssertEqual(tokenBeforeDuplicate, stdlib.abc.get_cache_token())
        AhkTest.AssertSame(baseBefore, StdlibAbcVirtualRegistryForeign.Prototype.Base)
    }

    static TestGetCacheTokenAndRegisterInvalidationMatchLocal310()
    {
        tokenBefore := stdlib.abc.get_cache_token()
        AhkTest.AssertTrue(tokenBefore is Integer)
        AhkTest.RaisesMatch(TypeError, "^_abc\.get_cache_token\(\) takes no arguments \(1 given\)$", (*) => stdlib.abc.get_cache_token(1))

        registeredOne := stdlib.abc.ABC.register(StdlibAbcCacheForeignOne)
        tokenAfterOne := stdlib.abc.get_cache_token()
        AhkTest.AssertSame(StdlibAbcCacheForeignOne, registeredOne)
        AhkTest.AssertEqual(1, tokenAfterOne - tokenBefore)
        AhkTest.AssertTrue(stdlib.abc.isinstance(StdlibAbcCacheForeignOne(), stdlib.abc.ABC))

        registeredAgain := stdlib.abc.ABC.register(StdlibAbcCacheForeignOne)
        tokenAfterAgain := stdlib.abc.get_cache_token()
        AhkTest.AssertSame(StdlibAbcCacheForeignOne, registeredAgain)
        AhkTest.AssertEqual(tokenAfterOne, tokenAfterAgain)

        registeredTwo := stdlib.abc.ABC.register(StdlibAbcCacheForeignTwo)
        tokenAfterTwo := stdlib.abc.get_cache_token()
        AhkTest.AssertSame(StdlibAbcCacheForeignTwo, registeredTwo)
        AhkTest.AssertEqual(1, tokenAfterTwo - tokenAfterAgain)
        AhkTest.AssertTrue(stdlib.abc.isinstance(StdlibAbcCacheForeignTwo(), stdlib.abc.ABC))

        AhkTest.AssertSame(stdlib.abc.ABC, stdlib.abc.ABC.register(stdlib.abc.ABC))
        AhkTest.AssertEqual(tokenAfterTwo, stdlib.abc.get_cache_token())
        AhkTest.RaisesMatch(TypeError, "^ABCMeta\.register\(\) missing 1 required positional argument: 'subclass'$", (*) => stdlib.abc.ABC.register())
        AhkTest.RaisesMatch(TypeError, "^ABCMeta\.register\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.abc.ABC.register(StdlibAbcCacheForeignOne, StdlibAbcCacheForeignTwo))
        AhkTest.RaisesMatch(TypeError, "^Can only register classes$", (*) => stdlib.abc.ABC.register(1))
    }

    static TestPublicAbstractHelpersAndUpdateAbstractMethods()
    {
        AhkTest.AssertSame(stdlib.abc.ABC, stdlib.abc.ABCMeta)

        staticMethod := stdlib.abc.abstractstaticmethod((value) => value + 1)
        AhkTest.AssertTrue(staticMethod.HasOwnProp("__isabstractmethod"))
        AhkTest.AssertTrue(staticMethod.__isabstractmethod)
        AhkTest.AssertTrue(staticMethod.__func.HasOwnProp("__isabstractmethod"))
        AhkTest.AssertTrue(staticMethod.__func.__isabstractmethod)
        AhkTest.AssertEqual(4, staticMethod.Call(3))

        classMethod := stdlib.abc.abstractclassmethod((cls, value) => value + 2)
        AhkTest.AssertTrue(classMethod.HasOwnProp("__isabstractmethod"))
        AhkTest.AssertTrue(classMethod.__isabstractmethod)
        AhkTest.AssertTrue(classMethod.__func.HasOwnProp("__isabstractmethod"))
        AhkTest.AssertTrue(classMethod.__func.__isabstractmethod)
        AhkTest.AssertEqual(5, classMethod.Call(StdlibAbcPublicAbstractDynamic, 3))

        propertyMethod := stdlib.abc.abstractproperty((self) => "prop")
        AhkTest.AssertTrue(propertyMethod.HasOwnProp("__isabstractmethod"))
        AhkTest.AssertTrue(propertyMethod.__isabstractmethod)
        AhkTest.AssertFalse(propertyMethod.fget.HasOwnProp("__isabstractmethod"))
        AhkTest.AssertEqual("prop", propertyMethod.Get(StdlibAbcPublicAbstractDynamic()))

        emptyProperty := stdlib.abc.abstractproperty()
        AhkTest.AssertTrue(emptyProperty.__isabstractmethod)
        AhkTest.AssertSame(stdlib.None, emptyProperty.fget)
        AhkTest.AssertSame(stdlib.None, emptyProperty.fset)
        AhkTest.AssertSame(stdlib.None, emptyProperty.fdel)

        propertyEvents := []
        fullProperty := stdlib.abc.abstractproperty(
            (self) => self.value,
            (self, value) => (self.value := value, propertyEvents.Push(["set", value])),
            (self) => (self.deleted := true, propertyEvents.Push(["delete"])),
            "doc text"
        )
        target := StdlibAbcPropertyTarget()
        AhkTest.AssertTrue(fullProperty.__isabstractmethod)
        AhkTest.AssertEqual("start", fullProperty.Get(target))
        AhkTest.AssertSame(stdlib.None, fullProperty.Set(target, "next"))
        AhkTest.AssertEqual("next", target.value)
        AhkTest.AssertSame(stdlib.None, fullProperty.Delete(target))
        AhkTest.AssertTrue(target.deleted)
        AhkTest.AssertEqual([["set", "next"], ["delete"]], propertyEvents)

        nonCallableProperty := stdlib.abc.abstractproperty(1)
        AhkTest.AssertTrue(nonCallableProperty.__isabstractmethod)
        AhkTest.AssertEqual(1, nonCallableProperty.fget)
        AhkTest.RaisesMatch(TypeError, "^property\(\) takes at most 4 arguments \(5 given\)$", (*) => stdlib.abc.abstractproperty((*) => 1, (*) => 2, (*) => 3, "doc", 1))

        AhkTest.AssertSame(StdlibAbcPublicAbstractDynamic, stdlib.abc.update_abstractmethods(StdlibAbcPublicAbstractDynamic))
        AhkTest.AssertFalse(stdlib.abc.isabstract(StdlibAbcPublicAbstractDynamic))
        StdlibAbcPublicAbstractDynamic.Prototype.need := stdlib.abc.abstractmethod((self) => stdlib.None)
        AhkTest.AssertFalse(stdlib.abc.isabstract(StdlibAbcPublicAbstractDynamic))
        AhkTest.AssertSame(StdlibAbcPublicAbstractDynamic, stdlib.abc.update_abstractmethods(StdlibAbcPublicAbstractDynamic))
        AhkTest.AssertTrue(stdlib.abc.isabstract(StdlibAbcPublicAbstractDynamic))
    }

    static TestUpdateAbstractMethodsConcreteOverrideClearsInheritedAbstract()
    {
        StdlibAbcUpdateBase.Prototype.need := stdlib.abc.abstractmethod((self) => "base")
        StdlibAbcUpdateConcrete.Prototype.need := (self) => "concrete"
        StdlibAbcUpdateReabstract.Prototype.need := stdlib.abc.abstractmethod((self) => "again")

        AhkTest.AssertSame(StdlibAbcUpdateBase, stdlib.abc.update_abstractmethods(StdlibAbcUpdateBase))
        AhkTest.AssertSame(StdlibAbcUpdateConcrete, stdlib.abc.update_abstractmethods(StdlibAbcUpdateConcrete))
        AhkTest.AssertSame(StdlibAbcUpdateLeaf, stdlib.abc.update_abstractmethods(StdlibAbcUpdateLeaf))
        AhkTest.AssertSame(StdlibAbcUpdateReabstract, stdlib.abc.update_abstractmethods(StdlibAbcUpdateReabstract))

        AhkTest.AssertTrue(stdlib.abc.isabstract(StdlibAbcUpdateBase))
        AhkTest.AssertFalse(stdlib.abc.isabstract(StdlibAbcUpdateConcrete))
        AhkTest.AssertTrue(stdlib.abc.isabstract(StdlibAbcUpdateLeaf))
        AhkTest.AssertTrue(stdlib.abc.isabstract(StdlibAbcUpdateReabstract))
        AhkTest.AssertEqual("concrete", StdlibAbcUpdateConcrete.Prototype.need.Call(StdlibAbcUpdateConcrete()))
    }

    static TestSubclassHookControlsSubclassAndInstanceChecksLikeLocal310()
    {
        StdlibAbcSubclassHookBase.Calls := []

        AhkTest.AssertTrue(stdlib.abc.issubclass(StdlibAbcHookAccepted, StdlibAbcSubclassHookBase))
        AhkTest.AssertTrue(stdlib.abc.isinstance(StdlibAbcHookAccepted(), StdlibAbcSubclassHookBase))
        AhkTest.AssertFalse(stdlib.abc.issubclass(StdlibAbcHookRejected, StdlibAbcSubclassHookBase))
        AhkTest.AssertFalse(stdlib.abc.isinstance(StdlibAbcHookRejected(), StdlibAbcSubclassHookBase))
        AhkTest.AssertFalse(stdlib.abc.issubclass(StdlibAbcHookFallback, StdlibAbcSubclassHookBase))
        AhkTest.AssertTrue(stdlib.abc.issubclass(StdlibAbcHookConcrete, StdlibAbcSubclassHookBase))
        AhkTest.AssertFalse(stdlib.abc.issubclass(StdlibAbcHookRejectActualConcrete, StdlibAbcHookRejectActualBase))
        AhkTest.AssertFalse(stdlib.abc.isinstance(StdlibAbcHookRejectActualConcrete(), StdlibAbcHookRejectActualBase))
        AhkTest.RaisesMatch(stdlib.assert.AssertionError, "^__subclasshook__ must return either False, True, or NotImplemented$", (*) => stdlib.abc.issubclass(StdlibAbcHookAccepted, StdlibAbcBadSubclassHookBase))
    }

    static TestRegisterRefusesInheritanceCycleLikeLocal310()
    {
        tokenBefore := stdlib.abc.get_cache_token()

        AhkTest.RaisesMatch(RuntimeError, "^Refusing to create an inheritance cycle$", (*) => StdlibAbcRegisterCycleChild.register(StdlibAbcRegisterCycleBase))
        AhkTest.AssertEqual(tokenBefore, stdlib.abc.get_cache_token())
        AhkTest.AssertFalse(stdlib.abc.issubclass(StdlibAbcRegisterCycleBase, StdlibAbcRegisterCycleChild))
        AhkTest.AssertTrue(stdlib.abc.issubclass(StdlibAbcRegisterCycleChild, StdlibAbcRegisterCycleBase))

        AhkTest.AssertSame(StdlibAbcRegisterCycleBase, StdlibAbcRegisterCycleBase.register(StdlibAbcRegisterCycleBase))
        AhkTest.AssertEqual(tokenBefore, stdlib.abc.get_cache_token())
        AhkTest.AssertSame(StdlibAbcRegisterCycleForeign, StdlibAbcRegisterCycleBase.register(StdlibAbcRegisterCycleForeign))
        AhkTest.AssertEqual(1, stdlib.abc.get_cache_token() - tokenBefore)
        AhkTest.AssertTrue(stdlib.abc.issubclass(StdlibAbcRegisterCycleForeign, StdlibAbcRegisterCycleBase))
    }

    static TestVirtualRegistryIsTransitiveLikeLocal310()
    {
        tokenBefore := stdlib.abc.get_cache_token()
        rootRegisterMid := StdlibAbcTransitiveRoot.register(StdlibAbcTransitiveMid)
        tokenAfterRoot := stdlib.abc.get_cache_token()
        midRegisterLeaf := StdlibAbcTransitiveMid.register(StdlibAbcTransitiveLeaf)
        tokenAfterMid := stdlib.abc.get_cache_token()

        AhkTest.AssertSame(StdlibAbcTransitiveMid, rootRegisterMid)
        AhkTest.AssertSame(StdlibAbcTransitiveLeaf, midRegisterLeaf)
        AhkTest.AssertEqual(1, tokenAfterRoot - tokenBefore)
        AhkTest.AssertEqual(1, tokenAfterMid - tokenAfterRoot)
        AhkTest.AssertTrue(stdlib.abc.issubclass(StdlibAbcTransitiveMid, StdlibAbcTransitiveRoot))
        AhkTest.AssertTrue(stdlib.abc.issubclass(StdlibAbcTransitiveLeaf, StdlibAbcTransitiveMid))
        AhkTest.AssertTrue(stdlib.abc.issubclass(StdlibAbcTransitiveLeaf, StdlibAbcTransitiveRoot))
        AhkTest.AssertTrue(stdlib.abc.isinstance(StdlibAbcTransitiveLeaf(), StdlibAbcTransitiveRoot))
        AhkTest.AssertTrue(stdlib.abc.issubclass(StdlibAbcTransitiveRealLeaf, StdlibAbcTransitiveRoot))
        AhkTest.AssertTrue(stdlib.abc.isinstance(StdlibAbcTransitiveRealLeaf(), StdlibAbcTransitiveRoot))
    }

    static TestAbstractAbcInstantiationIsBlockedLikeLocal310()
    {
        AhkTest.AssertTrue(stdlib.abc.isabstract(StdlibAbcInstantiationBase))
        AhkTest.AssertFalse(stdlib.abc.isabstract(StdlibAbcInstantiationConcrete))
        AhkTest.AssertTrue(stdlib.abc.isabstract(StdlibAbcInstantiationStillAbstract))

        AhkTest.RaisesMatch(TypeError, "^Can't instantiate abstract class StdlibAbcInstantiationBase with abstract method need$", (*) => StdlibAbcInstantiationBase())
        AhkTest.RaisesMatch(TypeError, "^Can't instantiate abstract class StdlibAbcInstantiationStillAbstract with abstract method need$", (*) => StdlibAbcInstantiationStillAbstract())
        AhkTest.AssertEqual("concrete", StdlibAbcInstantiationConcrete().need())

        AhkTest.AssertFalse(stdlib.abc.isabstract(StdlibAbcInstantiationDynamic))
        StdlibAbcInstantiationDynamic.Prototype.need := stdlib.abc.abstractmethod((self) => "dynamic")
        AhkTest.AssertFalse(stdlib.abc.isabstract(StdlibAbcInstantiationDynamic))
        AhkTest.AssertSame(StdlibAbcInstantiationDynamic, stdlib.abc.update_abstractmethods(StdlibAbcInstantiationDynamic))
        AhkTest.AssertTrue(stdlib.abc.isabstract(StdlibAbcInstantiationDynamic))
        AhkTest.RaisesMatch(TypeError, "^Can't instantiate abstract class StdlibAbcInstantiationDynamic with abstract method need$", (*) => StdlibAbcInstantiationDynamic())
    }

    static TestRegisterWorksAsDecoratorWithStdlibDecorateLikeLocal310()
    {
        tokenBefore := stdlib.abc.get_cache_token()
        decorated := stdlib.decorate(StdlibAbcDecoratorTarget, (cls) => StdlibAbcDecoratorRoot.register(cls))
        tokenAfter := stdlib.abc.get_cache_token()

        AhkTest.AssertSame(StdlibAbcDecoratorTarget, decorated)
        AhkTest.AssertEqual(1, tokenAfter - tokenBefore)
        AhkTest.AssertTrue(stdlib.abc.issubclass(StdlibAbcDecoratorTarget, StdlibAbcDecoratorRoot))
        AhkTest.AssertTrue(stdlib.abc.isinstance(StdlibAbcDecoratorTarget(), StdlibAbcDecoratorRoot))
    }
}

class StdlibAbcForeign
{
}

class StdlibAbcCacheForeignOne
{
}

class StdlibAbcCacheForeignTwo
{
}

class StdlibAbcVirtualRegistryForeign
{
}

class StdlibAbcVirtualRegistryReal extends AhkStdlibAbcBase
{
}

class StdlibAbcVirtualRegistryUnrelated
{
}

class StdlibAbcPublicAbstractDynamic
{
    static AhkStdlibAbstractMethods := Map()
}

class StdlibAbcPropertyTarget
{
    __New()
    {
        this.value := "start"
        this.deleted := false
    }
}

class StdlibAbcUpdateBase
{
    static AhkStdlibAbstractMethods := Map()
}

class StdlibAbcUpdateConcrete extends StdlibAbcUpdateBase
{
    static AhkStdlibAbstractMethods := Map()
}

class StdlibAbcUpdateLeaf extends StdlibAbcUpdateBase
{
    static AhkStdlibAbstractMethods := Map()
}

class StdlibAbcUpdateReabstract extends StdlibAbcUpdateBase
{
    static AhkStdlibAbstractMethods := Map()
}

class StdlibAbcSubclassHookBase extends AhkStdlibAbcBase
{
    static Calls := []

    static __subclasshook(subclass)
    {
        this.Calls.Push(subclass.Prototype.__Class)
        if subclass = StdlibAbcHookAccepted
            return true
        if subclass = StdlibAbcHookRejected
            return false
        return stdlib.NotImplemented
    }
}

class StdlibAbcHookAccepted
{
}

class StdlibAbcHookRejected
{
}

class StdlibAbcHookFallback
{
}

class StdlibAbcHookConcrete extends StdlibAbcSubclassHookBase
{
}

class StdlibAbcHookRejectActualBase extends AhkStdlibAbcBase
{
    static __subclasshook(subclass)
    {
        if subclass = StdlibAbcHookRejectActualConcrete
            return false
        return stdlib.NotImplemented
    }
}

class StdlibAbcHookRejectActualConcrete extends StdlibAbcHookRejectActualBase
{
}

class StdlibAbcBadSubclassHookBase extends AhkStdlibAbcBase
{
    static __subclasshook(subclass)
    {
        return "yes"
    }
}

class StdlibAbcRegisterCycleBase extends AhkStdlibAbcBase
{
}

class StdlibAbcRegisterCycleChild extends StdlibAbcRegisterCycleBase
{
}

class StdlibAbcRegisterCycleForeign
{
}

class StdlibAbcTransitiveRoot extends AhkStdlibAbcBase
{
}

class StdlibAbcTransitiveMid extends AhkStdlibAbcBase
{
}

class StdlibAbcTransitiveLeaf
{
}

class StdlibAbcTransitiveRealLeaf extends StdlibAbcTransitiveLeaf
{
}

class StdlibAbcInstantiationBase extends AhkStdlibAbcBase
{
    static AhkStdlibAbstractMethods := Map("need", true)
}

StdlibAbcInstantiationBase.Prototype.need := stdlib.abc.abstractmethod((self) => "base")

class StdlibAbcInstantiationConcrete extends StdlibAbcInstantiationBase
{
    static AhkStdlibAbstractMethods := Map()

    need()
    {
        return "concrete"
    }
}

class StdlibAbcInstantiationStillAbstract extends StdlibAbcInstantiationBase
{
    static AhkStdlibAbstractMethods := Map("need", true)
}

class StdlibAbcInstantiationDynamic extends AhkStdlibAbcBase
{
    static AhkStdlibAbstractMethods := Map()
}

class StdlibAbcDecoratorRoot extends AhkStdlibAbcBase
{
}

class StdlibAbcDecoratorTarget
{
}

AhkTest.Collect(StdlibAbcTest)
