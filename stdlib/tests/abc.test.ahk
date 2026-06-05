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

AhkTest.Collect(StdlibAbcTest)
