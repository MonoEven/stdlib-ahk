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

    static TestSignatureReflectsFuncArity()
    {
        sig := stdlib.inspect.signature(stdlib_inspect_probe_free)
        ; a (required), b (defaulted), *args
        AhkTest.AssertEqual("(arg1, arg2=None, *args)", sig.ToString())

        params := sig.parameters_list()
        AhkTest.AssertEqual(3, params.Length)
        AhkTest.AssertEqual("arg1", params[1].name)
        AhkTest.AssertEqual(stdlib.inspect.Parameter.POSITIONAL_OR_KEYWORD, params[1].kind)
        AhkTest.AssertTrue(params[1].default == stdlib.inspect.Parameter.empty)
        AhkTest.AssertEqual("arg2", params[2].name)
        AhkTest.AssertFalse(params[2].default == stdlib.inspect.Parameter.empty)
        AhkTest.AssertEqual("args", params[3].name)
        AhkTest.AssertEqual(stdlib.inspect.Parameter.VAR_POSITIONAL, params[3].kind)
    }

    static TestGetmroWalksBaseChain()
    {
        mro := stdlib.inspect.getmro(StdlibInspectProbeDemo)
        AhkTest.AssertTrue(mro.Length >= 1)
        AhkTest.AssertEqual(StdlibInspectProbeDemo, mro[1])
    }

    static TestPredicatesForMethodsAndRoutines()
    {
        instance := StdlibInspectProbeDemo()
        bound := instance.Method
        AhkTest.AssertTrue(stdlib.inspect.ismethod(bound))
        AhkTest.AssertFalse(stdlib.inspect.ismethod(stdlib_inspect_probe_free))
        AhkTest.AssertTrue(stdlib.inspect.isroutine(stdlib_inspect_probe_free))
        AhkTest.AssertTrue(stdlib.inspect.isbuiltin(StrLen))
        AhkTest.AssertFalse(stdlib.inspect.isbuiltin(stdlib_inspect_probe_free))
        AhkTest.AssertTrue(stdlib.inspect.callable(stdlib_inspect_probe_free))
    }

    static TestGetmembersReturnsSortedPairs()
    {
        ns := { beta: 2, alpha: 1, gamma: 3 }
        members := stdlib.inspect.getmembers(ns)
        names := []
        for pair in members
            names.Push(pair[1])
        ; Sorted ascending by name.
        AhkTest.AssertEqual("alpha", names[1])
        AhkTest.AssertEqual("beta", names[2])
        AhkTest.AssertEqual("gamma", names[3])
    }
}

AhkTest.Collect(StdlibInspectTest)
