#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\copy>

class StdlibCopyTest
{
    static TestPublicSurfaceMatchesObservedLocal310Names()
    {
        AhkTest.AssertSame(stdlib.copy.Error, stdlib.copy.error)
        AhkTest.AssertTrue(stdlib.copy.Error("x", -1) is Error)
        AhkTest.AssertTrue(stdlib.copy.dispatch_table is Map)
        AhkTest.AssertEqual(3, stdlib.copy.dispatch_table.Count)
        AhkTest.AssertTrue(stdlib.copy.dispatch_table.Has("complex"))
        AhkTest.AssertTrue(stdlib.copy.dispatch_table.Has("types.UnionType"))
        AhkTest.AssertTrue(stdlib.copy.dispatch_table.Has("re.Pattern"))
    }

    static TestCopyAndDeepcopyMatchObservedLocal310Surface()
    {
        values := [1, [2]]
        mapping := Map("a", [1], "b", 2)
        tuple := stdlib.tuple([1, [2]])
        cycle := StdlibCopyCycleNode()
        cycle.me := cycle

        listCopy := stdlib.copy.copy(values)
        listDeep := stdlib.copy.deepcopy(values)
        mapCopy := stdlib.copy.copy(mapping)
        mapDeep := stdlib.copy.deepcopy(mapping)
        tupleCopy := stdlib.copy.copy(tuple)
        tupleDeep := stdlib.copy.deepcopy(tuple)
        scalarText := stdlib.copy.copy("abc")
        scalarInt := stdlib.copy.deepcopy(42)
        customCopy := stdlib.copy.copy(StdlibCopyCustomCopy())
        customDeep := stdlib.copy.deepcopy(StdlibCopyCustomDeepCopy())
        cycled := stdlib.copy.deepcopy(cycle)

        AhkTest.AssertFalse(listCopy == values)
        AhkTest.AssertSame(values[2], listCopy[2])
        AhkTest.AssertFalse(listDeep == values)
        AhkTest.AssertFalse(listDeep[2] == values[2])
        AhkTest.AssertFalse(mapCopy == mapping)
        AhkTest.AssertSame(mapping["a"], mapCopy["a"])
        AhkTest.AssertFalse(mapDeep == mapping)
        AhkTest.AssertFalse(mapDeep["a"] == mapping["a"])
        AhkTest.AssertSame(tuple, tupleCopy)
        AhkTest.AssertFalse(tupleDeep == tuple)
        AhkTest.AssertFalse(tupleDeep[2] == tuple[2])
        AhkTest.AssertSame("abc", scalarText)
        AhkTest.AssertEqual(42, scalarInt)
        AhkTest.AssertEqual(["custom-copy", "StdlibCopyCustomCopy"], customCopy)
        AhkTest.AssertEqual(["custom-deepcopy", true, "StdlibCopyCustomDeepCopy"], customDeep)
        AhkTest.AssertTrue(cycled !== cycle)
        AhkTest.AssertSame(cycled, cycled.me)
    }

    static TestObservedCopyErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^copy\(\) missing 1 required positional argument: 'x'$", (*) => stdlib.copy.copy())
        AhkTest.RaisesMatch(TypeError, "^deepcopy\(\) missing 1 required positional argument: 'x'$", (*) => stdlib.copy.deepcopy())
    }

    static TestDeepcopyHonorsDeepcopyHook()
    {
        ; An object defining __deepcopy__ is invoked and receives the memo.
        obj := StdlibCopyCustomDeepCopy()
        result := stdlib.copy.deepcopy(obj)
        AhkTest.AssertEqual(["custom-deepcopy", true, "StdlibCopyCustomDeepCopy"], result)
    }

    static TestCopyHonorsCopyHook()
    {
        ; An object defining __copy__ is invoked by copy().
        obj := StdlibCopyCustomCopy()
        result := stdlib.copy.copy(obj)
        AhkTest.AssertEqual(["custom-copy", "StdlibCopyCustomCopy"], result)
    }

    static TestDispatchTableOverridesDeepcopyByTypeName()
    {
        ; A dispatch_table entry keyed by AHK type name overrides default copying.
        marker := []
        dispatch := Map("StdlibCopyPlain", (value, memo) => ["dispatched-deep", value.tag])
        obj := StdlibCopyPlain()
        obj.tag := "T"
        result := stdlib.copy.deepcopy(obj, { dispatch_table: dispatch })
        AhkTest.AssertEqual(["dispatched-deep", "T"], result)
    }

    static TestDispatchTableOverridesCopyByTypeName()
    {
        dispatch := Map("StdlibCopyPlain", (value) => ["dispatched-shallow", value.tag])
        obj := StdlibCopyPlain()
        obj.tag := "S"
        result := stdlib.copy.copy(obj, { dispatch_table: dispatch })
        AhkTest.AssertEqual(["dispatched-shallow", "S"], result)
    }

    static TestDispatchTableAcceptedAsBareMap()
    {
        ; The options argument may be the dispatch_table Map itself.
        dispatch := Map("StdlibCopyPlain", (value, memo) => "bare-map")
        obj := StdlibCopyPlain()
        AhkTest.AssertSame("bare-map", stdlib.copy.deepcopy(obj, dispatch))
    }

    static TestDispatchTableKeyedByObjectIdentity()
    {
        ; Registering the object itself selects the copier.
        obj := StdlibCopyPlain()
        dispatch := Map(obj, (value, memo) => "by-identity")
        AhkTest.AssertSame("by-identity", stdlib.copy.deepcopy(obj, dispatch))
    }

    static TestDeepcopyHookWinsOverDispatchTable()
    {
        ; CPython checks __deepcopy__ before the dispatch_table reductor.
        obj := StdlibCopyCustomDeepCopy()
        dispatch := Map("StdlibCopyCustomDeepCopy", (value, memo) => "from-dispatch")
        result := stdlib.copy.deepcopy(obj, dispatch)
        AhkTest.AssertEqual(["custom-deepcopy", true, "StdlibCopyCustomDeepCopy"], result)
    }

    static TestDispatchTableDoesNotAffectUnregisteredTypes()
    {
        ; Default deepcopy still applies when no entry matches.
        dispatch := Map("SomeOtherType", (value, memo) => "nope")
        values := [1, [2]]
        deep := stdlib.copy.deepcopy(values, dispatch)
        AhkTest.AssertFalse(deep == values)
        AhkTest.AssertFalse(deep[2] == values[2])
        AhkTest.AssertEqual(2, deep[2][1])
    }
}

class StdlibCopyPlain
{
}

class StdlibCopyCycleNode
{
    __New()
    {
        this.me := ""
    }
}

class StdlibCopyCustomCopy
{
    __copy()
    {
        return ["custom-copy", Type(this)]
    }
}

class StdlibCopyCustomDeepCopy
{
    __deepcopy(memo)
    {
        return ["custom-deepcopy", memo is Map, Type(this)]
    }
}

AhkTest.Collect(StdlibCopyTest)
