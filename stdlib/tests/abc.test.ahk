#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\abc>

class StdlibAbcTest
{
    static TestAbstractMethodMarksFunctionsAndRejectsObservedArity()
    {
        probe := stdlib.abc.abstractmethod((value) => value)

        AhkTest.AssertTrue(probe.HasOwnProp("__isabstractmethod__"))
        AhkTest.AssertEqual(true, probe.__isabstractmethod__)
        AhkTest.AssertEqual(3, probe.Call(3))
        AhkTest.RaisesMatch(TypeError, "^abstractmethod\(\) missing 1 required positional argument: 'funcobj'$", (*) => stdlib.abc.abstractmethod())
        AhkTest.RaisesMatch(TypeError, "^abstractmethod\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.abc.abstractmethod(1, 2))
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
        AhkTest.AssertTrue(staticMethod.HasOwnProp("__isabstractmethod__"))
        AhkTest.AssertTrue(staticMethod.__isabstractmethod__)
        AhkTest.AssertTrue(staticMethod.__func__.HasOwnProp("__isabstractmethod__"))
        AhkTest.AssertTrue(staticMethod.__func__.__isabstractmethod__)
        AhkTest.AssertEqual(4, staticMethod.Call(3))

        classMethod := stdlib.abc.abstractclassmethod((cls, value) => value + 2)
        AhkTest.AssertTrue(classMethod.HasOwnProp("__isabstractmethod__"))
        AhkTest.AssertTrue(classMethod.__isabstractmethod__)
        AhkTest.AssertTrue(classMethod.__func__.HasOwnProp("__isabstractmethod__"))
        AhkTest.AssertTrue(classMethod.__func__.__isabstractmethod__)
        AhkTest.AssertEqual(5, classMethod.Call(StdlibAbcPublicAbstractDynamic, 3))

        propertyMethod := stdlib.abc.abstractproperty((self) => "prop")
        AhkTest.AssertTrue(propertyMethod.HasOwnProp("__isabstractmethod__"))
        AhkTest.AssertTrue(propertyMethod.__isabstractmethod__)
        AhkTest.AssertFalse(propertyMethod.fget.HasOwnProp("__isabstractmethod__"))
        AhkTest.AssertEqual("prop", propertyMethod.Get(StdlibAbcPublicAbstractDynamic()))

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

AhkTest.Collect(StdlibAbcTest)
