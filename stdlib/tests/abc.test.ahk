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
}

class StdlibAbcForeign
{
}

AhkTest.Collect(StdlibAbcTest)
