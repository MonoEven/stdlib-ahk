#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\inspect>

class StdlibInspectProbeDemo
{
    Method(x, y := 3)
    {
        return x + y
    }
}

stdlib_inspect_probe_free(a, b := 2, args*)
{
    return a + b
}

class StdlibInspectTest
{
    static TestPredicatesMatchObservedLocal310Baseline()
    {
        lambda := (() => 1)

        AhkTest.AssertTrue(stdlib.inspect.isfunction(stdlib_inspect_probe_free))
        AhkTest.AssertTrue(stdlib.inspect.isfunction(lambda))
        AhkTest.AssertFalse(stdlib.inspect.isfunction(StrLen))
        AhkTest.AssertFalse(stdlib.inspect.isfunction(StdlibInspectProbeDemo.Prototype.Method))
        AhkTest.AssertFalse(stdlib.inspect.isfunction(StdlibInspectProbeDemo))

        AhkTest.AssertTrue(stdlib.inspect.isclass(StdlibInspectProbeDemo))
        AhkTest.AssertFalse(stdlib.inspect.isclass(StdlibInspectProbeDemo()))
        AhkTest.AssertFalse(stdlib.inspect.isclass(stdlib_inspect_probe_free))
    }

    static TestPredicateArityAndNonCallableCasesMatchObservedLocal310Baseline()
    {
        missingObject := ""
        extraObject := ""
        missingClass := ""
        try
            stdlib.inspect.isfunction()
        catch as err
            missingObject := err.Message
        try
            stdlib.inspect.isfunction(1, 2)
        catch as err
            extraObject := err.Message
        try
            stdlib.inspect.isclass()
        catch as err
            missingClass := err.Message

        AhkTest.AssertEqual("isfunction() missing 1 required positional argument: 'object'", missingObject)
        AhkTest.AssertEqual("isfunction() takes 1 positional argument but 2 were given", extraObject)
        AhkTest.AssertEqual("isclass() missing 1 required positional argument: 'object'", missingClass)
        AhkTest.AssertFalse(stdlib.inspect.isfunction(1))
        AhkTest.AssertFalse(stdlib.inspect.isclass(1))
    }
}

AhkTest.Collect(StdlibInspectTest)
