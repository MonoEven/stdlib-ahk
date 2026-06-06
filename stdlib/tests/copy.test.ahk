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
    __copy__()
    {
        return ["custom-copy", Type(this)]
    }
}

class StdlibCopyCustomDeepCopy
{
    __deepcopy__(memo)
    {
        return ["custom-deepcopy", memo is Map, Type(this)]
    }
}

AhkTest.Collect(StdlibCopyTest)
