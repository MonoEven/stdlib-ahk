#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\itertools>
#Include <stdlib\operator>

class StdlibOperatorTest
{
    static TestComparisonsLogicAndIdentity()
    {
        objectValue := { Name: "kept" }

        AhkTest.AssertTrue(stdlib.operator.lt(1, 2))
        AhkTest.AssertTrue(stdlib.operator.le(2, 2))
        AhkTest.AssertTrue(stdlib.operator.eq("a", "a"))
        AhkTest.AssertTrue(stdlib.operator.ne("a", "b"))
        AhkTest.AssertTrue(stdlib.operator.ge(3, 2))
        AhkTest.AssertTrue(stdlib.operator.gt(3, 2))
        AhkTest.AssertTrue(stdlib.operator.truth([0]))
        AhkTest.AssertFalse(stdlib.operator.truth([]))
        AhkTest.AssertTrue(stdlib.operator.not_(0))
        AhkTest.AssertTrue(stdlib.operator.is_(objectValue, objectValue))
        AhkTest.AssertTrue(stdlib.operator.is_not(objectValue, {}))
    }

    static TestMathOperators()
    {
        AhkTest.AssertEqual(5, stdlib.operator.add(2, 3))
        AhkTest.AssertEqual(-1, stdlib.operator.sub(2, 3))
        AhkTest.AssertEqual(6, stdlib.operator.mul(2, 3))
        AhkTest.AssertEqual(2.5, stdlib.operator.truediv(5, 2))
        AhkTest.AssertEqual(2, stdlib.operator.floordiv(5, 2))
        AhkTest.AssertEqual(1, stdlib.operator.mod(5, 2))
        AhkTest.AssertEqual(-2, stdlib.operator.floordiv(-3, 2))
        AhkTest.AssertEqual(-2, stdlib.operator.floordiv(3, -2))
        AhkTest.AssertEqual(1, stdlib.operator.mod(-3, 2))
        AhkTest.AssertEqual(-1, stdlib.operator.mod(3, -2))
        AhkTest.AssertEqual(-3, stdlib.operator.neg(3))
        AhkTest.AssertEqual(3, stdlib.operator.pos(3))
        AhkTest.AssertEqual(3, stdlib.operator.abs(-3))
    }

    static TestAddAndMulFollowSequenceSemantics()
    {
        AhkTest.AssertEqual("ab", stdlib.operator.add("a", "b"))
        AhkTest.AssertEqual([1, 2, 3], stdlib.operator.add([1], [2, 3]))
        AhkTest.AssertEqual("ababab", stdlib.operator.mul("ab", 3))
        AhkTest.AssertEqual("ababab", stdlib.operator.mul(3, "ab"))
        AhkTest.AssertEqual([1, 2, 1, 2], stdlib.operator.mul([1, 2], 2))
        AhkTest.AssertEqual([1, 2, 1, 2], stdlib.operator.mul(2, [1, 2]))
        AhkTest.AssertEqual("", stdlib.operator.mul("ab", 0))
        AhkTest.AssertEqual([], stdlib.operator.mul([1], -1))
        AhkTest.AssertThrows(TypeError, (*) => stdlib.operator.add("a", 1))
        AhkTest.AssertThrows(TypeError, (*) => stdlib.operator.mul("a", 2.5))
    }

    static TestSequenceOperationsUseZeroBasedIndexesForArrays()
    {
        values := ["a", "b", "a", "c"]

        AhkTest.AssertTrue(stdlib.operator.contains(values, "b"))
        AhkTest.AssertEqual(2, stdlib.operator.countOf(values, "a"))
        AhkTest.AssertEqual(1, stdlib.operator.indexOf(values, "b"))
        AhkTest.AssertEqual("a", stdlib.operator.getitem(values, 0))
        AhkTest.AssertEqual("c", stdlib.operator.getitem(values, -1))

        stdlib.operator.setitem(values, 1, "B")
        AhkTest.AssertEqual(["a", "B", "a", "c"], values)

        stdlib.operator.delitem(values, 0)
        AhkTest.AssertEqual(["B", "a", "c"], values)
    }

    static TestStringContainsUsesSubstringButCountAndIndexUseCharacters()
    {
        AhkTest.AssertTrue(stdlib.operator.contains("abc", "bc"))
        AhkTest.AssertEqual(3, stdlib.operator.countOf("aaa", "a"))
        AhkTest.AssertEqual(0, stdlib.operator.countOf("aaa", "aa"))
        AhkTest.AssertEqual(1, stdlib.operator.indexOf("abc", "b"))
        AhkTest.RaisesMatch(ValueError, "sequence\.index\(x\): x not in sequence", (*) => stdlib.operator.indexOf("abc", "bc"))
    }

    static TestMapItemOperationsUseMapKeys()
    {
        value := Map("name", "Ada", "score", 7)

        AhkTest.AssertTrue(stdlib.operator.contains(value, "name"))
        AhkTest.AssertEqual("Ada", stdlib.operator.getitem(value, "name"))
        stdlib.operator.setitem(value, "score", 8)
        AhkTest.AssertEqual(8, value["score"])
        stdlib.operator.delitem(value, "name")
        AhkTest.AssertFalse(value.Has("name"))
    }

    static TestMapCountAndIndexIterateKeys()
    {
        value := Map("name", "Ada", "score", 7)

        AhkTest.AssertEqual(1, stdlib.operator.countOf(value, "name"))
        AhkTest.AssertEqual(0, stdlib.operator.countOf(value, "Ada"))
        AhkTest.AssertEqual(1, stdlib.operator.indexOf(value, "score"))
        AhkTest.RaisesMatch(ValueError, "sequence\.index\(x\): x not in sequence", (*) => stdlib.operator.indexOf(value, "missing"))
    }

    static TestGetterAndCallerHelpersAreCallable()
    {
        box := StdlibOperatorBox("Ada", 7)
        values := ["a", "b", "c"]

        AhkTest.AssertEqual("c", stdlib.operator.itemgetter(-1).Call(values))
        AhkTest.AssertEqual(["c", "a"], stdlib.operator.itemgetter(-1, 0).Call(values))
        AhkTest.AssertEqual(7, stdlib.operator.attrgetter("child.value").Call(box))
        AhkTest.AssertEqual([7, "Ada"], stdlib.operator.attrgetter("child.value", "name").Call(box))
        AhkTest.AssertEqual("hi Bob?", stdlib.operator.methodcaller("greet", "Bob", "?").Call(box))
    }

    static TestLengthHintUsesSizedAhkValues()
    {
        AhkTest.AssertEqual(3, stdlib.operator.length_hint(["a", "b", "c"]))
        AhkTest.AssertEqual(2, stdlib.operator.length_hint(Map("a", 1, "b", 2)))
        AhkTest.AssertEqual(5, stdlib.operator.length_hint("hello"))
        AhkTest.AssertEqual(9, stdlib.operator.length_hint({ value: 1 }, 9))
        AhkTest.AssertThrows(TypeError, (*) => stdlib.operator.length_hint([], "bad"))
    }

    static TestLengthHintDefaultArgumentMatchesPython310TypeRules()
    {
        unsized := { value: 1 }

        AhkTest.AssertEqual(-1, stdlib.operator.length_hint(unsized, -1))
        AhkTest.AssertEqual(1, stdlib.operator.length_hint(unsized, stdlib.True))
        AhkTest.AssertEqual(0, stdlib.operator.length_hint(unsized, stdlib.False))
        AhkTest.RaisesMatch(
            TypeError,
            "'NoneType' object cannot be interpreted as an integer",
            (*) => stdlib.operator.length_hint(["a"], stdlib.None)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'str' object cannot be interpreted as an integer",
            (*) => stdlib.operator.length_hint(["a"], "bad")
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'tuple' object cannot be interpreted as an integer",
            (*) => stdlib.operator.length_hint(["a"], stdlib.tuple())
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'NotImplementedType' object cannot be interpreted as an integer",
            (*) => stdlib.operator.length_hint(["a"], stdlib.NotImplemented)
        )
    }

    static TestLengthHintProviderProtocolMatchesPython310()
    {
        AhkTest.AssertEqual(3, stdlib.operator.length_hint(StdlibOperatorLengthHintValue(3), 9))
        AhkTest.AssertEqual(1, stdlib.operator.length_hint(StdlibOperatorLengthHintValue(stdlib.True), 9))
        AhkTest.AssertEqual(0, stdlib.operator.length_hint(StdlibOperatorLengthHintValue(stdlib.False), 9))
        AhkTest.AssertEqual(9, stdlib.operator.length_hint(StdlibOperatorLengthHintValue(stdlib.NotImplemented), 9))
        AhkTest.AssertEqual(0, stdlib.operator.length_hint(StdlibOperatorLengthHintValue(stdlib.NotImplemented)))
        AhkTest.AssertEqual(9, stdlib.operator.length_hint(StdlibOperatorLengthHintTypeError(), 9))
        AhkTest.RaisesMatch(
            ValueError,
            "__length_hint__\(\) should return >= 0",
            (*) => stdlib.operator.length_hint(StdlibOperatorLengthHintValue(-1), 9)
        )
        AhkTest.RaisesMatch(
            ValueError,
            "bad hint",
            (*) => stdlib.operator.length_hint(StdlibOperatorLengthHintValueError(), 9)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "__length_hint__ must be an integer, not str",
            (*) => stdlib.operator.length_hint(StdlibOperatorLengthHintValue("bad"), 9)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "__length_hint__ must be an integer, not NoneType",
            (*) => stdlib.operator.length_hint(StdlibOperatorLengthHintValue(stdlib.None), 9)
        )
    }

    static TestLengthHintUsesRepeatRemainingCountLikePython310()
    {
        limited := stdlib.itertools.repeat("x", 3)
        unlimited := stdlib.itertools.repeat("x")
        exhausted := stdlib.itertools.repeat("x", -2)

        AhkTest.AssertEqual(3, stdlib.operator.length_hint(limited))
        AhkTest.AssertEqual(["x", "x"], stdlib_operator_test_array(stdlib.itertools.islice(limited, 2)))
        AhkTest.AssertEqual(1, stdlib.operator.length_hint(limited))
        AhkTest.AssertEqual(0, stdlib.operator.length_hint(unlimited))
        AhkTest.AssertEqual(9, stdlib.operator.length_hint(unlimited, 9))
        AhkTest.AssertEqual(0, stdlib.operator.length_hint(exhausted))
    }
}

class StdlibOperatorLengthHintValue
{
    __New(value)
    {
        this.Value := value
    }

    __LengthHint()
    {
        return this.Value
    }
}

class StdlibOperatorLengthHintTypeError
{
    __LengthHint()
    {
        throw TypeError("bad hint", -1)
    }
}

class StdlibOperatorLengthHintValueError
{
    __LengthHint()
    {
        throw ValueError("bad hint", -1)
    }
}

class StdlibOperatorChild
{
    __New(value)
    {
        this.value := value
    }
}

class StdlibOperatorBox
{
    __New(name, value)
    {
        this.name := name
        this.child := StdlibOperatorChild(value)
    }

    greet(who, punctuation := "!")
    {
        return "hi " who punctuation
    }
}

stdlib_operator_test_array(iterable)
{
    result := []
    for value in iterable
        result.Push(value)
    return result
}

AhkTest.Collect(StdlibOperatorTest)
