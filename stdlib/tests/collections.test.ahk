#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\collections>
#Include <stdlib\operator>
#Include <stdlib\decimal>
#Include <stdlib\fractions>

class StdlibCollectionsTest
{
    static DemoFunctionCount()
    {
    }

    class DemoCounterSource
    {
    }

    class DemoCount
    {
    }

    class DemoMostCommonLimit
    {
    }

    class DemoDictLike extends Map
    {
    }

    class DemoCounterSubclass extends AhkStdlibCollectionsCounter
    {
    }

    static TestCounterCountsArrayValuesAndMissingItemsReturnZero()
    {
        counter := stdlib.collections.Counter(["red", "blue", "red"])

        AhkTest.AssertEqual(2, counter["red"])
        AhkTest.AssertEqual(1, counter["blue"])
        AhkTest.AssertEqual(0, counter["missing"])
        AhkTest.AssertEqual(3, counter.total())
    }

    static TestCounterCountsStringCharactersAndMappingCounts()
    {
        textCounter := stdlib.collections.Counter("abracadabra")
        mappingCounter := stdlib.collections.Counter(Map("alpha", 2, "beta", -1))

        AhkTest.AssertEqual(5, textCounter["a"])
        AhkTest.AssertEqual(2, textCounter["b"])
        AhkTest.AssertEqual(1, textCounter["c"])
        AhkTest.AssertEqual(2, mappingCounter["alpha"])
        AhkTest.AssertEqual(-1, mappingCounter["beta"])
        AhkTest.AssertEqual(1, mappingCounter.total())
    }

    static TestCounterAcceptsKwargsOptionLikePython310Constructor()
    {
        kwargsOnly := stdlib.collections.Counter({ kwargs: Map("a", 2, "b", 3) })
        iterableAndKwargs := stdlib.collections.Counter("ab", { kwargs: Map("a", 2, "c", 3) })
        mappingAndKwargs := stdlib.collections.Counter(Map("a", 2), { kwargs: Map("a", 3, "b", 4) })

        AhkTest.AssertEqual([["a", 2], ["b", 3]], stdlib_collections_test_pairs(kwargsOnly))
        AhkTest.AssertEqual([["a", 3], ["b", 1], ["c", 3]], stdlib_collections_test_pairs(iterableAndKwargs))
        AhkTest.AssertEqual([["a", 5], ["b", 4]], stdlib_collections_test_pairs(mappingAndKwargs))
    }

    static TestCounterUpdateAndSubtractAcceptKwargsOptionLikePython310()
    {
        updateCounter := stdlib.collections.Counter("a")
        subtractCounter := stdlib.collections.Counter("a")
        updateMappingCounter := stdlib.collections.Counter()
        subtractMappingCounter := stdlib.collections.Counter()

        updateResult := updateCounter.update({ kwargs: Map("a", 2, "b", 3) })
        subtractResult := subtractCounter.subtract({ kwargs: Map("a", 2, "b", 3) })
        updateMappingCounter.update(Map("a", 2), { kwargs: Map("a", 3, "b", 4) })
        subtractMappingCounter.subtract(Map("a", 2), { kwargs: Map("a", 3, "b", 4) })

        AhkTest.AssertEqual("", updateResult)
        AhkTest.AssertEqual("", subtractResult)
        AhkTest.AssertEqual([["a", 3], ["b", 3]], stdlib_collections_test_pairs(updateCounter))
        AhkTest.AssertEqual([["a", -1], ["b", -3]], stdlib_collections_test_pairs(subtractCounter))
        AhkTest.AssertEqual([["a", 5], ["b", 4]], stdlib_collections_test_pairs(updateMappingCounter))
        AhkTest.AssertEqual([["a", -5], ["b", -4]], stdlib_collections_test_pairs(subtractMappingCounter))
    }

    static TestCounterFromkeysMatchesPython310UndefinedClassmethod()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "Counter\.fromkeys\(\) missing 1 required positional argument: 'iterable'",
            (*) => stdlib.collections.Counter.fromkeys()
        )
        AhkTest.RaisesMatch(
            NotImplementedError,
            "Counter\.fromkeys\(\) is undefined\.  Use Counter\(iterable\) instead\.",
            (*) => stdlib.collections.Counter.fromkeys("ab")
        )
        AhkTest.RaisesMatch(
            NotImplementedError,
            "Counter\.fromkeys\(\) is undefined\.  Use Counter\(iterable\) instead\.",
            (*) => stdlib.collections.Counter.fromkeys("ab", 3)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "Counter\.fromkeys\(\) takes from 2 to 3 positional arguments but 4 were given",
            (*) => stdlib.collections.Counter.fromkeys("ab", 3, 4)
        )
    }

    static TestCounterReprUsesPythonMostCommonOrderForNumericCounts()
    {
        counter := stdlib.collections.Counter("abb")

        AhkTest.AssertEqual("Counter({'b': 2, 'a': 1})", counter.__Repr())
    }

    static TestCounterReprFallsBackToInsertionOrderForUnorderableCounts()
    {
        counter := stdlib.collections.Counter(Map("a", Map("x", 1), "b", Map("x", 2)))

        AhkTest.AssertEqual("Counter({'a': {'x': 1}, 'b': {'x': 2}})", counter.__Repr())
    }

    static TestCounterTotalUsesPythonBinaryTypeErrorsForNonNumericCounts()
    {
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'int' and 'str'", (*) => stdlib.collections.Counter(Map("a", "x")).total())
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'int' and 'list'", (*) => stdlib.collections.Counter(Map("a", [1])).total())
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'int' and 'function'", (*) => stdlib.collections.Counter(Map("a", StdlibCollectionsTest.DemoFunctionCount)).total())
        AhkTest.AssertEqual("1/2", String(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))).total()))
        AhkTest.AssertEqual("1.5", String(stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"))).total()))
        AhkTest.AssertEqual("3/2", String(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2), "b", 1)).total()))
        AhkTest.AssertEqual("3/2", String(stdlib.collections.Counter(Map("a", 1, "b", stdlib.fractions.Fraction(1, 2))).total()))
        AhkTest.AssertEqual("2.5", String(stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", 1)).total()))
        AhkTest.AssertEqual("2.5", String(stdlib.collections.Counter(Map("a", 1, "b", stdlib.decimal.Decimal("1.5"))).total()))
        AhkTest.AssertEqual("2", String(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2), "b", stdlib.fractions.Fraction(3, 2))).total()))
        AhkTest.AssertEqual("4.0", String(stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", stdlib.decimal.Decimal("2.5"))).total()))
        AhkTest.AssertEqual("9/2", String(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2), "b", stdlib.fractions.Fraction(3, 2), "c", stdlib.fractions.Fraction(5, 2))).total()))
        AhkTest.AssertEqual("7.5", String(stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", stdlib.decimal.Decimal("2.5"), "c", stdlib.decimal.Decimal("3.5"))).total()))
        AhkTest.AssertEqual(1.0, stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2), "b", 0.5)).total())
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'decimal.Decimal' and 'float'", (*) => stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", 0.5)).total())
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'Fraction' and 'decimal.Decimal'", (*) => stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2), "b", stdlib.decimal.Decimal("2.5"))).total())
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'decimal.Decimal' and 'Fraction'", (*) => stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("2.5"), "b", stdlib.fractions.Fraction(3, 2))).total())
    }

    static TestCounterUpdateSubtractElementsAndMostCommon()
    {
        counter := stdlib.collections.Counter(["a", "b", "a"])

        counter.update(["b", "c", "c"])
        counter.subtract(Map("a", 1, "d", 2))

        AhkTest.AssertEqual(1, counter["a"])
        AhkTest.AssertEqual(2, counter["b"])
        AhkTest.AssertEqual(2, counter["c"])
        AhkTest.AssertEqual(-2, counter["d"])
        AhkTest.AssertEqual(3, counter.total())
        AhkTest.AssertEqual(["a", "b", "b", "c", "c"], stdlib_collections_test_array(counter.elements()))
        AhkTest.AssertEqual([["b", 2], ["c", 2], ["a", 1]], counter.most_common(3))
    }

    static TestCounterMostCommonUsesPythonOrderingAndTypeErrors()
    {
        stringCounter := stdlib.collections.Counter(Map("a", "x", "b", "y"))
        listCounter := stdlib.collections.Counter(Map("a", [1], "b", [2]))
        functionCounter := stdlib.collections.Counter(Map("a", StdlibCollectionsTest.DemoFunctionCount, "b", StdlibCollectionsTest.DemoFunctionCount))
        fractionCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2), "b", stdlib.fractions.Fraction(3, 2)))
        decimalCounter := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", stdlib.decimal.Decimal("2.5")))
        mixedNumericCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2), "b", stdlib.decimal.Decimal("2.5")))
        intDecimalCounter := stdlib.collections.Counter(Map("a", 1, "b", stdlib.decimal.Decimal("2.5")))
        floatFractionCounter := stdlib.collections.Counter(Map("a", 2.5, "b", stdlib.fractions.Fraction(3, 2)))
        intFractionCounter := stdlib.collections.Counter(Map("a", 1, "b", stdlib.fractions.Fraction(3, 2)))
        floatDecimalCounter := stdlib.collections.Counter(Map("a", 2.5, "b", stdlib.decimal.Decimal("1.5")))

        AhkTest.AssertEqual([["b", "y"], ["a", "x"]], stringCounter.most_common())
        AhkTest.AssertEqual([["b", [2]], ["a", [1]]], listCounter.most_common())
        AhkTest.AssertEqual([["b", "3/2"], ["a", "1/2"]], stdlib_collections_test_render_pairs(fractionCounter.most_common()))
        AhkTest.AssertEqual([["b", "2.5"], ["a", "1.5"]], stdlib_collections_test_render_pairs(decimalCounter.most_common()))
        AhkTest.AssertEqual([["b", "2.5"], ["a", "3/2"]], stdlib_collections_test_render_pairs(mixedNumericCounter.most_common()))
        AhkTest.AssertEqual([["b", "2.5"], ["a", "1"]], stdlib_collections_test_render_pairs(intDecimalCounter.most_common()))
        AhkTest.AssertEqual([["a", "2.5"], ["b", "3/2"]], stdlib_collections_test_render_pairs(floatFractionCounter.most_common()))
        AhkTest.AssertEqual([["b", "3/2"], ["a", "1"]], stdlib_collections_test_render_pairs(intFractionCounter.most_common()))
        AhkTest.AssertEqual([["a", "2.5"], ["b", "1.5"]], stdlib_collections_test_render_pairs(floatDecimalCounter.most_common()))
        AhkTest.RaisesMatch(TypeError, "'<' not supported between instances of 'function' and 'function'", (*) => functionCounter.most_common())
    }

    static TestCounterMostCommonLimitFollowsPythonArgumentRules()
    {
        counter := stdlib.collections.Counter("abb")
        largerCounter := stdlib.collections.Counter("abbc")

        AhkTest.AssertEqual([["b", 2], ["a", 1]], counter.most_common(stdlib.None))
        AhkTest.AssertEqual([["b", 2]], counter.most_common(true))
        AhkTest.AssertEqual([], counter.most_common(false))
        AhkTest.AssertEqual([["b", 2]], counter.most_common(stdlib.fractions.Fraction(1, 1)))
        AhkTest.AssertEqual([["b", 2]], counter.most_common(stdlib.decimal.Decimal("1")))
        AhkTest.RaisesMatch(TypeError, "'Fraction' object cannot be interpreted as an integer", (*) => counter.most_common(stdlib.fractions.Fraction(0, 1)))
        AhkTest.RaisesMatch(TypeError, "'decimal.Decimal' object cannot be interpreted as an integer", (*) => counter.most_common(stdlib.decimal.Decimal("0")))
        AhkTest.RaisesMatch(TypeError, "'Fraction' object cannot be interpreted as an integer", (*) => largerCounter.most_common(stdlib.fractions.Fraction(2, 1)))
        AhkTest.RaisesMatch(TypeError, "'decimal.Decimal' object cannot be interpreted as an integer", (*) => largerCounter.most_common(stdlib.decimal.Decimal("2")))
        AhkTest.RaisesMatch(TypeError, "slice indices must be integers or None or have an __index__ method", (*) => counter.most_common(stdlib.fractions.Fraction(2, 1)))
        AhkTest.RaisesMatch(TypeError, "slice indices must be integers or None or have an __index__ method", (*) => counter.most_common(stdlib.decimal.Decimal("2")))
        AhkTest.RaisesMatch(TypeError, "'Fraction' object cannot be interpreted as an integer", (*) => counter.most_common(stdlib.fractions.Fraction(1, 2)))
        AhkTest.RaisesMatch(TypeError, "'decimal.Decimal' object cannot be interpreted as an integer", (*) => counter.most_common(stdlib.decimal.Decimal("0.5")))
        AhkTest.RaisesMatch(TypeError, "'float' object cannot be interpreted as an integer", (*) => counter.most_common(1.5))
        AhkTest.RaisesMatch(TypeError, "'float' object cannot be interpreted as an integer", (*) => largerCounter.most_common(2.0))
        AhkTest.RaisesMatch(TypeError, "slice indices must be integers or None or have an __index__ method", (*) => counter.most_common(2.0))
        AhkTest.RaisesMatch(TypeError, "'>=' not supported between instances of 'str' and 'int'", (*) => counter.most_common("1"))
        AhkTest.RaisesMatch(TypeError, "'>=' not supported between instances of 'object' and 'int'", (*) => counter.most_common({}))
        AhkTest.RaisesMatch(TypeError, "'>=' not supported between instances of 'DemoMostCommonLimit' and 'int'", (*) => counter.most_common(StdlibCollectionsTest.DemoMostCommonLimit()))
    }

    static TestCounterMostCommonAcceptsRootBoolLimitLikePython310()
    {
        counter := stdlib.collections.Counter("abb")

        AhkTest.AssertEqual([["b", 2]], counter.most_common(stdlib.True))
        AhkTest.AssertEqual([], counter.most_common(stdlib.False))
    }

    static TestCounterElementsIsLazyLikePython()
    {
        counter := stdlib.collections.Counter(Map("a", 2))
        elements := counter.elements()

        counter["a"] := 4

        AhkTest.AssertEqual(["a", "a", "a", "a"], stdlib_collections_test_array(elements))
    }

    static TestCounterElementsKeepsConsumedPositionAcrossConsumersLikePython()
    {
        elements := stdlib.collections.Counter("abb").elements()
        first := unset
        iterator := elements.__Enum(1)

        AhkTest.AssertTrue(iterator(&first))
        AhkTest.AssertEqual("a", first)
        AhkTest.AssertEqual(["b", "b"], stdlib_collections_test_array(elements))
        AhkTest.AssertEqual([], stdlib_collections_test_array(elements))
    }

    static TestCounterElementsRejectsSizeMutationDuringIterationLikePython()
    {
        counter := stdlib.collections.Counter(Map("a", 2))
        elements := counter.elements()
        first := unset

        iterator := elements.__Enum(1)
        AhkTest.AssertTrue(iterator(&first))
        AhkTest.AssertEqual("a", first)

        counter["b"] := 1

        AhkTest.RaisesMatch(Error, "dictionary changed size during iteration", (*) => stdlib_collections_test_array(elements))
    }

    static TestCounterElementsRejectsKeyMutationAtStableSizeLikePython()
    {
        counter := stdlib.collections.Counter(Map("a", 2))
        elements := counter.elements()
        first := unset

        iterator := elements.__Enum(1)
        AhkTest.AssertTrue(iterator(&first))
        AhkTest.AssertEqual("a", first)

        counter.Delete("a")
        counter["b"] := 2

        AhkTest.RaisesMatch(Error, "dictionary keys changed during iteration", (*) => stdlib_collections_test_array(elements))
    }

    static TestCounterElementsRejectsDeleteAndReaddSameKeyLikePython()
    {
        counter := stdlib.collections.Counter(Map("a", 2))
        elements := counter.elements()
        first := unset

        iterator := elements.__Enum(1)
        AhkTest.AssertTrue(iterator(&first))
        AhkTest.AssertEqual("a", first)

        counter.Delete("a")
        counter["a"] := 2

        AhkTest.RaisesMatch(Error, "dictionary keys changed during iteration", (*) => stdlib_collections_test_array(elements))
    }

    static TestCounterElementsKeepsActiveRepeatCountAndReadsFutureCountsLikePython()
    {
        counter := stdlib.collections.Counter(Map("a", 2, "b", 1))
        elements := counter.elements()
        first := unset

        iterator := elements.__Enum(1)
        AhkTest.AssertTrue(iterator(&first))
        AhkTest.AssertEqual("a", first)

        counter["a"] := 4
        counter["b"] := 3

        AhkTest.AssertEqual(["a", "b", "b", "b"], stdlib_collections_test_rest(iterator))
    }

    static TestCounterRejectsNonIterableObjectsLikePython()
    {
        AhkTest.RaisesMatch(TypeError, "'object' object is not iterable", (*) => stdlib.collections.Counter({ a: 2 }))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.collections.Counter(42))
        AhkTest.RaisesMatch(TypeError, "'DemoCounterSource' object is not iterable", (*) => stdlib.collections.Counter(StdlibCollectionsTest.DemoCounterSource()))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.collections.Counter(42, { kwargs: Map("a", 1) }))
    }

    static TestCounterUpdateAndSubtractReturnNoValueLikePython()
    {
        counter := stdlib.collections.Counter(["a"])

        updateResult := counter.update(Map("b", 2))
        subtractResult := counter.subtract(Map("a", 1))
        noArgUpdateResult := counter.update()
        noArgSubtractResult := counter.subtract()

        AhkTest.AssertEqual("", updateResult)
        AhkTest.AssertEqual("", subtractResult)
        AhkTest.AssertEqual("", noArgUpdateResult)
        AhkTest.AssertEqual("", noArgSubtractResult)
        AhkTest.AssertEqual(0, counter["a"])
        AhkTest.AssertEqual(2, counter["b"])
    }

    static TestCounterUpdateAndSubtractRejectInvalidArityAndNonIterableLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.collections.Counter().update(42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "Counter\.update\(\) takes from 1 to 2 positional arguments but 3 were given",
            (*) => stdlib.collections.Counter().update(Map(), Map())
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.collections.Counter().subtract(42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "Counter\.subtract\(\) takes from 1 to 2 positional arguments but 3 were given",
            (*) => stdlib.collections.Counter().subtract(Map(), Map())
        )
    }

    static TestCounterSetDefaultMatchesPython310()
    {
        existing := stdlib.collections.Counter("ab")
        missing := stdlib.collections.Counter("ab")
        noneDefault := stdlib.collections.Counter()

        AhkTest.AssertEqual(1, existing.setdefault("a", 5))
        AhkTest.AssertEqual([["a", 1], ["b", 1]], stdlib_collections_test_pairs(existing))
        AhkTest.AssertEqual(5, missing.setdefault("c", 5))
        AhkTest.AssertEqual([["a", 1], ["b", 1], ["c", 5]], stdlib_collections_test_pairs(missing))
        AhkTest.AssertSame(stdlib.None, noneDefault.setdefault("x"))
        AhkTest.AssertEqual([["x", stdlib.None]], stdlib_collections_test_pairs(noneDefault))
        AhkTest.RaisesMatch(TypeError, "setdefault expected at least 1 argument, got 0", (*) => stdlib.collections.Counter().setdefault())
        AhkTest.RaisesMatch(TypeError, "setdefault expected at most 2 arguments, got 3", (*) => stdlib.collections.Counter().setdefault("a", 1, 2))
    }

    static TestCounterGetMatchesPython310()
    {
        counter := stdlib.collections.Counter("ab")

        AhkTest.AssertEqual(1, counter.get("a"))
        AhkTest.AssertSame(stdlib.None, counter.get("z"))
        AhkTest.AssertEqual(7, counter.get("z", 7))
        AhkTest.RaisesMatch(TypeError, "get expected at least 1 argument, got 0", (*) => counter.get())
        AhkTest.RaisesMatch(TypeError, "get expected at most 2 arguments, got 3", (*) => counter.get("a", 1, 2))
    }

    static TestCounterPopMatchesPython310()
    {
        existing := stdlib.collections.Counter("ab")
        missingWithDefault := stdlib.collections.Counter("ab")

        AhkTest.AssertEqual(1, existing.pop("a"))
        AhkTest.AssertEqual([["b", 1]], stdlib_collections_test_pairs(existing))
        AhkTest.AssertSame(stdlib.None, missingWithDefault.pop("z", stdlib.None))
        AhkTest.AssertEqual([["a", 1], ["b", 1]], stdlib_collections_test_pairs(missingWithDefault))
        AhkTest.RaisesMatch(stdlib.KeyError, "^'z'$", (*) => stdlib.collections.Counter().pop("z"))
        AhkTest.RaisesMatch(TypeError, "pop expected at least 1 argument, got 0", (*) => stdlib.collections.Counter().pop())
        AhkTest.RaisesMatch(TypeError, "pop expected at most 2 arguments, got 3", (*) => stdlib.collections.Counter().pop("a", 1, 2))
    }

    static TestCounterPopItemMatchesPython310()
    {
        counter := stdlib.collections.Counter("ab")
        first := counter.popitem()

        AhkTest.AssertTrue(first is AhkStdlibTuple)
        AhkTest.AssertEqual(["b", 1], first)
        AhkTest.AssertEqual([["a", 1]], stdlib_collections_test_pairs(counter))
        AhkTest.RaisesMatch(TypeError, "does not support item assignment|readonly", (*) => first[1] := "x")
        second := counter.popitem()
        AhkTest.AssertTrue(second is AhkStdlibTuple)
        AhkTest.AssertEqual(["a", 1], second)
        AhkTest.AssertEqual([], stdlib_collections_test_pairs(counter))
        AhkTest.RaisesMatch(stdlib.KeyError, "^'popitem\(\): dictionary is empty'$", (*) => counter.popitem())
        AhkTest.RaisesMatch(TypeError, "dict\.popitem\(\) takes no arguments \(1 given\)", (*) => stdlib.collections.Counter().popitem(1))
    }

    static TestCounterCopyPreservesSubclassTypeLikePython310()
    {
        counter := StdlibCollectionsTest.DemoCounterSubclass("ab")
        copied := counter.copy()

        AhkTest.AssertTrue(copied is StdlibCollectionsTest.DemoCounterSubclass)
        AhkTest.AssertEqual([["a", 1], ["b", 1]], stdlib_collections_test_pairs(copied))
        AhkTest.AssertTrue(stdlib.operator.eq(copied, counter))
        AhkTest.AssertFalse(ObjPtr(copied) = ObjPtr(counter))

        copied["c"] := 5
        AhkTest.AssertEqual(0, counter["c"])
    }

    static TestCounterClearMatchesPython310()
    {
        counter := stdlib.collections.Counter("abca")
        returned := counter.Clear()

        AhkTest.AssertSame(stdlib.None, returned)
        AhkTest.AssertEqual([], stdlib_collections_test_pairs(counter))
        AhkTest.AssertSame(stdlib.None, counter.get("a"))
        AhkTest.AssertEqual(0, counter["a"])

        counter.update("ba")
        AhkTest.AssertEqual([["b", 1], ["a", 1]], stdlib_collections_test_pairs(counter))
    }

    static TestCounterDelItemMatchesPython310()
    {
        counter := stdlib.collections.Counter("ab")

        stdlib.operator.delitem(counter, "a")
        AhkTest.AssertEqual([["b", 1]], stdlib_collections_test_pairs(counter))
        AhkTest.RaisesMatch(stdlib.KeyError, "^'z'$", (*) => stdlib.operator.delitem(counter, "z"))
    }

    static TestCounterUpdateMappingUsesPythonRightPlusLeftOrder()
    {
        stringCounter := stdlib.collections.Counter(Map("a", "x"))
        listCounter := stdlib.collections.Counter(Map("a", [1]))
        fractionCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))
        fractionFloatCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))
        floatFractionCounter := stdlib.collections.Counter(Map("a", 0.5))
        decimalCounter := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5")))
        fractionPlusDecimalCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))
        decimalPlusFractionCounter := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5")))
        intPlusStringCounter := stdlib.collections.Counter(Map("a", "x"))
        intPlusListCounter := stdlib.collections.Counter(Map("a", [1]))
        functionCounter := stdlib.collections.Counter(Map("a", StdlibCollectionsTest.DemoFunctionCount))

        stringCounter.update(Map("a", "y"))
        listCounter.update(Map("a", [2]))
        fractionCounter.update(Map("a", stdlib.fractions.Fraction(1, 2)))
        fractionFloatCounter.update(Map("a", 0.5))
        floatFractionCounter.update(Map("a", stdlib.fractions.Fraction(1, 2)))
        decimalCounter.update(Map("a", stdlib.decimal.Decimal("0.5")))

        AhkTest.AssertEqual("yx", stringCounter["a"])
        AhkTest.AssertEqual([2, 1], listCounter["a"])
        AhkTest.AssertEqual("1", String(fractionCounter["a"]))
        AhkTest.AssertEqual(1.0, fractionFloatCounter["a"])
        AhkTest.AssertEqual(1.0, floatFractionCounter["a"])
        AhkTest.AssertEqual("2.0", String(decimalCounter["a"]))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'decimal.Decimal' and 'Fraction'", (*) => fractionPlusDecimalCounter.update(Map("a", stdlib.decimal.Decimal("0.5"))))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'Fraction' and 'decimal.Decimal'", (*) => decimalPlusFractionCounter.update(Map("a", stdlib.fractions.Fraction(1, 2))))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'int' and 'str'", (*) => intPlusStringCounter.update(Map("a", 1)))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'int' and 'list'", (*) => intPlusListCounter.update(Map("a", 1)))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'function' and 'function'", (*) => functionCounter.update(Map("a", StdlibCollectionsTest.DemoFunctionCount)))
    }

    static TestCounterSubtractMappingUsesPythonBinaryTypeErrors()
    {
        stringCounter := stdlib.collections.Counter(Map("a", "x"))
        listCounter := stdlib.collections.Counter(Map("a", [1]))
        fractionCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2)))
        fractionFloatCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2)))
        floatFractionCounter := stdlib.collections.Counter(Map("a", 2.0))
        decimalCounter := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5")))
        fractionMinusDecimalCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2)))
        decimalMinusFractionCounter := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5")))
        functionCounter := stdlib.collections.Counter(Map("a", StdlibCollectionsTest.DemoFunctionCount))
        intCounter := stdlib.collections.Counter(Map("a", 1))

        fractionCounter.subtract(Map("a", stdlib.fractions.Fraction(1, 2)))
        fractionFloatCounter.subtract(Map("a", 0.5))
        floatFractionCounter.subtract(Map("a", stdlib.fractions.Fraction(1, 2)))
        decimalCounter.subtract(Map("a", stdlib.decimal.Decimal("0.5")))

        AhkTest.AssertEqual("1", String(fractionCounter["a"]))
        AhkTest.AssertEqual(1.0, fractionFloatCounter["a"])
        AhkTest.AssertEqual(1.5, floatFractionCounter["a"])
        AhkTest.AssertEqual("1.0", String(decimalCounter["a"]))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \-: 'Fraction' and 'decimal.Decimal'", (*) => fractionMinusDecimalCounter.subtract(Map("a", stdlib.decimal.Decimal("0.5"))))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \-: 'decimal.Decimal' and 'Fraction'", (*) => decimalMinusFractionCounter.subtract(Map("a", stdlib.fractions.Fraction(1, 2))))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \-: 'str' and 'str'", (*) => stringCounter.subtract(Map("a", "y")))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \-: 'list' and 'list'", (*) => listCounter.subtract(Map("a", [2])))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \-: 'function' and 'function'", (*) => functionCounter.subtract(Map("a", StdlibCollectionsTest.DemoFunctionCount)))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \-: 'str' and 'int'", (*) => stringCounter.subtract(Map("a", 1)))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \-: 'int' and 'str'", (*) => intCounter.subtract(Map("a", "y")))
    }

    static TestCounterSubtractMappingRightOnlyNonNumericCountsUsePythonBinaryTypeErrors()
    {
        empty := stdlib.collections.Counter()
        fractionCounter := stdlib.collections.Counter()
        decimalCounter := stdlib.collections.Counter()

        fractionCounter.subtract(Map("a", stdlib.fractions.Fraction(1, 2)))
        decimalCounter.subtract(Map("a", stdlib.decimal.Decimal("1.5")))

        AhkTest.AssertEqual("-1/2", String(fractionCounter["a"]))
        AhkTest.AssertEqual("-1.5", String(decimalCounter["a"]))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \-: 'int' and 'str'", (*) => empty.subtract(Map("a", "y")))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \-: 'int' and 'list'", (*) => empty.subtract(Map("a", [2])))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \-: 'int' and 'function'", (*) => empty.subtract(Map("a", StdlibCollectionsTest.DemoFunctionCount)))
    }

    static TestCounterElementsRejectsNonIntegerCountsLikePython()
    {
        AhkTest.RaisesMatch(TypeError, "'float' object cannot be interpreted as an integer", (*) => stdlib_collections_test_array(stdlib.collections.Counter(Map("a", 2.0)).elements()))
        AhkTest.RaisesMatch(TypeError, "'float' object cannot be interpreted as an integer", (*) => stdlib_collections_test_array(stdlib.collections.Counter(Map("a", 2.5)).elements()))
        AhkTest.RaisesMatch(TypeError, "'str' object cannot be interpreted as an integer", (*) => stdlib_collections_test_array(stdlib.collections.Counter(Map("a", "2")).elements()))
        AhkTest.RaisesMatch(TypeError, "'NoneType' object cannot be interpreted as an integer", (*) => stdlib_collections_test_array(stdlib.collections.Counter(Map("a", stdlib.None)).elements()))
        AhkTest.RaisesMatch(TypeError, "'DemoCount' object cannot be interpreted as an integer", (*) => stdlib_collections_test_array(stdlib.collections.Counter(Map("a", StdlibCollectionsTest.DemoCount())).elements()))
    }

    static TestCounterElementsAcceptsBoolCountsLikePython()
    {
        counter := stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False, "c", 2))

        AhkTest.AssertEqual(["a", "c", "c"], stdlib_collections_test_array(counter.elements()))
    }

    static TestCounterElementsReprMatchesPython310ChainShape()
    {
        elements := stdlib.collections.Counter("abb").elements()

        AhkTest.AssertRegex(elements.__Repr(), "^<itertools\.chain object at 0x[0-9A-F]+>$")
    }

    static TestCounterFunctionCountPayloadUsesPythonFunctionTypeName()
    {
        functionCounter := stdlib.collections.Counter(Map("a", StdlibCollectionsTest.DemoFunctionCount))
        intCounter := stdlib.collections.Counter(Map("a", 1))

        AhkTest.RaisesMatch(TypeError, "'function' object cannot be interpreted as an integer", (*) => stdlib_collections_test_array(functionCounter.elements()))
        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'function' and 'int'", (*) => stdlib.operator.pos(functionCounter))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'function' and 'int'", (*) => stdlib.operator.add(functionCounter, intCounter))
    }

    static TestCounterArithmeticDropsNonPositiveCountsLikePython()
    {
        left := stdlib.collections.Counter(Map("a", 3, "b", 1, "c", 0, "d", -2))
        right := stdlib.collections.Counter(Map("a", 1, "b", 2, "c", 4, "e", -1))

        AhkTest.AssertEqual([["a", 4], ["b", 3], ["c", 4]], stdlib_collections_test_pairs(stdlib.operator.add(left, right)))
        AhkTest.AssertEqual([["a", 2], ["e", 1]], stdlib_collections_test_pairs(stdlib.operator.sub(left, right)))
        AhkTest.AssertEqual([["a", 1], ["b", 1]], stdlib_collections_test_pairs(stdlib.operator.and_(left, right)))
        AhkTest.AssertEqual([["a", 3], ["b", 2], ["c", 4]], stdlib_collections_test_pairs(stdlib.operator.or_(left, right)))
    }

    static TestCounterUnaryOperationsDropNonPositiveCountsLikePython()
    {
        counter := stdlib.collections.Counter(Map("a", 3, "b", 1, "c", 0, "d", -2))

        AhkTest.AssertEqual([["a", 3], ["b", 1]], stdlib_collections_test_pairs(stdlib.operator.pos(counter)))
        AhkTest.AssertEqual([["d", 2]], stdlib_collections_test_pairs(stdlib.operator.neg(counter)))
    }

    static TestCounterUnaryAndSetLikeOperationsRejectMixedOrderTypesLikePython()
    {
        stringCounter := stdlib.collections.Counter(Map("a", "x"))
        intCounter := stdlib.collections.Counter(Map("a", 1))

        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.pos(stringCounter))
        AhkTest.RaisesMatch(TypeError, "'<' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.neg(stringCounter))
        AhkTest.RaisesMatch(TypeError, "'<' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.and_(stringCounter, intCounter))
        AhkTest.RaisesMatch(TypeError, "'<' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.or_(stringCounter, intCounter))
    }

    static TestCounterSubRejectsMixedCountTypesLikePython()
    {
        stringCounter := stdlib.collections.Counter(Map("a", "x"))
        intCounter := stdlib.collections.Counter(Map("a", 1))

        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \-: 'int' and 'str'", (*) => stdlib.operator.sub(intCounter, stringCounter))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \-: 'str' and 'int'", (*) => stdlib.operator.sub(stringCounter, intCounter))
    }

    static TestCounterAddRejectsStringAndIntegerCountsLikePython()
    {
        stringCounter := stdlib.collections.Counter(Map("a", "x"))
        intCounter := stdlib.collections.Counter(Map("a", 1))

        AhkTest.RaisesMatch(TypeError, 'can only concatenate str \(not "int"\) to str', (*) => stdlib.operator.add(stringCounter, intCounter))
    }

    static TestCounterAddRejectsStringAndStringCountsAtPositiveFilterLikePython()
    {
        left := stdlib.collections.Counter(Map("a", "x"))
        right := stdlib.collections.Counter(Map("a", "y"))

        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.add(left, right))
    }

    static TestCounterAddRejectsArrayAndArrayCountsAtPositiveFilterLikePython()
    {
        left := stdlib.collections.Counter(Map("a", [1]))
        right := stdlib.collections.Counter(Map("a", [2]))

        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'list' and 'int'", (*) => stdlib.operator.add(left, right))
    }

    static TestCounterAddUsesRightOnlyListCountBeforePositiveFilterLikePython()
    {
        empty := stdlib.collections.Counter()
        right := stdlib.collections.Counter(Map("a", [1]))

        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'list' and 'int'", (*) => stdlib.operator.add(empty, right))
    }

    static TestCounterAddRejectsListAndIntegerCountsLikePython()
    {
        left := stdlib.collections.Counter(Map("a", [1]))
        right := stdlib.collections.Counter(Map("a", 1))

        AhkTest.RaisesMatch(TypeError, 'can only concatenate list \(not "int"\) to list', (*) => stdlib.operator.add(left, right))
    }

    static TestCounterOrUsesRightOnlyListCountBeforePositiveFilterLikePython()
    {
        empty := stdlib.collections.Counter()
        right := stdlib.collections.Counter(Map("a", [1]))

        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'list' and 'int'", (*) => stdlib.operator.or_(empty, right))
    }

    static TestCounterAndSkipsRightOnlyListCountLikePython()
    {
        empty := stdlib.collections.Counter()
        right := stdlib.collections.Counter(Map("a", [1]))

        AhkTest.AssertEqual([], stdlib_collections_test_pairs(stdlib.operator.and_(empty, right)))
    }

    static TestCounterAndOrUseListCountsBeforePositiveFilterLikePython()
    {
        sameLeft := stdlib.collections.Counter(Map("a", [1]))
        sameRight := stdlib.collections.Counter(Map("a", [1]))
        differentRight := stdlib.collections.Counter(Map("a", [2]))
        sameStringLeft := stdlib.collections.Counter(Map("a", "x"))
        sameStringRight := stdlib.collections.Counter(Map("a", "x"))
        differentStringRight := stdlib.collections.Counter(Map("a", "y"))

        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'list' and 'int'", (*) => stdlib.operator.and_(sameLeft, sameRight))
        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'list' and 'int'", (*) => stdlib.operator.and_(sameLeft, differentRight))
        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'list' and 'int'", (*) => stdlib.operator.or_(sameLeft, sameRight))
        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'list' and 'int'", (*) => stdlib.operator.or_(sameLeft, differentRight))
        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.and_(sameStringLeft, sameStringRight))
        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.and_(sameStringLeft, differentStringRight))
        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.or_(sameStringLeft, sameStringRight))
        AhkTest.RaisesMatch(TypeError, "'>' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.or_(sameStringLeft, differentStringRight))
    }

    static TestCounterSubUsesRightOnlyListCountAtPositiveFilterLikePython()
    {
        empty := stdlib.collections.Counter()
        right := stdlib.collections.Counter(Map("a", [1]))

        AhkTest.RaisesMatch(TypeError, "'<' not supported between instances of 'list' and 'int'", (*) => stdlib.operator.sub(empty, right))
    }

    static TestCounterSubIncludesRightOnlyNegativeCountsLikePython()
    {
        empty := stdlib.collections.Counter()
        right := stdlib.collections.Counter(Map("a", -2))

        AhkTest.AssertEqual([["a", 2]], stdlib_collections_test_pairs(stdlib.operator.sub(empty, right)))
    }

    static TestCounterRichComparisonsTreatMissingCountsAsZero()
    {
        left := stdlib.collections.Counter(Map("a", 1, "b", 0))
        sameWithoutZero := stdlib.collections.Counter(Map("a", 1))
        larger := stdlib.collections.Counter(Map("a", 1, "b", 1))
        negativeExtra := stdlib.collections.Counter(Map("a", 1, "b", -1))

        AhkTest.AssertTrue(stdlib.operator.eq(left, sameWithoutZero))
        AhkTest.AssertFalse(stdlib.operator.ne(left, sameWithoutZero))
        AhkTest.AssertTrue(stdlib.operator.le(left, sameWithoutZero))
        AhkTest.AssertTrue(stdlib.operator.ge(left, sameWithoutZero))
        AhkTest.AssertFalse(stdlib.operator.lt(left, sameWithoutZero))
        AhkTest.AssertFalse(stdlib.operator.gt(left, sameWithoutZero))
        AhkTest.AssertTrue(stdlib.operator.lt(sameWithoutZero, larger))
        AhkTest.AssertTrue(stdlib.operator.le(negativeExtra, sameWithoutZero))
        AhkTest.AssertFalse(stdlib.operator.le(stdlib.collections.Counter(Map("a", 2)), sameWithoutZero))
    }

    static TestCounterRichComparisonsRejectMixedOrderTypesLikePython()
    {
        left := stdlib.collections.Counter(Map("a", "x"))
        right := stdlib.collections.Counter(Map("a", 1))
        fractionFloatLeft := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))
        fractionFloatRight := stdlib.collections.Counter(Map("a", 0.75))
        decimalFloatLeft := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5")))
        decimalFloatRight := stdlib.collections.Counter(Map("a", 2.5))
        intDecimalLeft := stdlib.collections.Counter(Map("a", 1))
        intDecimalRight := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("2.5")))

        AhkTest.AssertFalse(stdlib.operator.eq(left, right))
        AhkTest.AssertTrue(stdlib.operator.ne(left, right))
        AhkTest.AssertTrue(stdlib.operator.lt(fractionFloatLeft, fractionFloatRight))
        AhkTest.AssertTrue(stdlib.operator.le(fractionFloatLeft, stdlib.collections.Counter(Map("a", 0.5))))
        AhkTest.AssertTrue(stdlib.operator.lt(decimalFloatLeft, decimalFloatRight))
        AhkTest.AssertTrue(stdlib.operator.ge(decimalFloatLeft, stdlib.collections.Counter(Map("a", 1.5))))
        AhkTest.AssertTrue(stdlib.operator.lt(intDecimalLeft, intDecimalRight))
        AhkTest.RaisesMatch(TypeError, "'<=' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.lt(left, right))
        AhkTest.RaisesMatch(TypeError, "'<=' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.le(left, right))
        AhkTest.RaisesMatch(TypeError, "'>=' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.gt(left, right))
        AhkTest.RaisesMatch(TypeError, "'>=' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.ge(left, right))
    }

    static TestCounterBoolCountsCompareLikePythonIntegers()
    {
        trueCount := stdlib.collections.Counter(Map("a", stdlib.True))
        falseCount := stdlib.collections.Counter(Map("a", stdlib.False))
        intOne := stdlib.collections.Counter(Map("a", 1))
        intZero := stdlib.collections.Counter(Map("a", 0))

        AhkTest.AssertTrue(stdlib.operator.eq(trueCount, intOne))
        AhkTest.AssertFalse(stdlib.operator.ne(trueCount, intOne))
        AhkTest.AssertTrue(stdlib.operator.le(trueCount, intOne))
        AhkTest.AssertTrue(stdlib.operator.ge(trueCount, intOne))
        AhkTest.AssertTrue(stdlib.operator.lt(falseCount, intOne))
        AhkTest.AssertTrue(stdlib.operator.gt(trueCount, intZero))
        AhkTest.AssertTrue(stdlib.operator.eq(trueCount, Map("a", 1)))
        AhkTest.AssertFalse(stdlib.operator.ne(trueCount, Map("a", 1)))
    }

    static TestCounterBoolCountsBehaveLikePythonIntegersAcrossArithmetic()
    {
        boolCounts := stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False, "c", -1))
        trueCount := stdlib.collections.Counter(Map("a", stdlib.True))
        falseCount := stdlib.collections.Counter(Map("a", stdlib.False))
        intOne := stdlib.collections.Counter(Map("a", 1))
        empty := stdlib.collections.Counter()
        updatedFromBool := stdlib.collections.Counter(Map("a", stdlib.True))
        updatedFromInt := stdlib.collections.Counter(Map("a", 1))
        subtractedFromBool := stdlib.collections.Counter(Map("a", stdlib.True))
        subtractedFromInt := stdlib.collections.Counter(Map("a", 1))

        AhkTest.AssertEqual([["a", stdlib.True]], stdlib_collections_test_pairs(stdlib.operator.pos(boolCounts)))
        AhkTest.AssertEqual([["c", 1]], stdlib_collections_test_pairs(stdlib.operator.neg(boolCounts)))
        AhkTest.AssertEqual([["a", 2]], stdlib_collections_test_pairs(stdlib.operator.add(trueCount, trueCount)))
        AhkTest.AssertEqual([["a", stdlib.True]], stdlib_collections_test_pairs(stdlib.operator.add(empty, stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False)))))
        AhkTest.AssertEqual([["a", stdlib.True]], stdlib_collections_test_pairs(stdlib.operator.or_(trueCount, falseCount)))
        AhkTest.AssertEqual([["a", 1]], stdlib_collections_test_pairs(stdlib.operator.and_(trueCount, intOne)))
        AhkTest.AssertEqual([["a", stdlib.True]], stdlib_collections_test_pairs(stdlib.operator.and_(intOne, trueCount)))
        AhkTest.AssertEqual([["a", 1]], stdlib_collections_test_pairs(stdlib.operator.sub(trueCount, falseCount)))
        AhkTest.AssertEqual([], stdlib_collections_test_pairs(stdlib.operator.sub(empty, stdlib.collections.Counter(Map("a", stdlib.False, "b", stdlib.True)))))
        AhkTest.AssertEqual(1, stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False)).total())

        updatedFromBool.update(Map("a", 1))
        updatedFromInt.update(Map("a", stdlib.True))
        subtractedFromBool.subtract(Map("a", 1))
        subtractedFromInt.subtract(Map("a", stdlib.True))

        AhkTest.AssertEqual([["a", 2]], stdlib_collections_test_pairs(updatedFromBool))
        AhkTest.AssertEqual([["a", 2]], stdlib_collections_test_pairs(updatedFromInt))
        AhkTest.AssertEqual([["a", 0]], stdlib_collections_test_pairs(subtractedFromBool))
        AhkTest.AssertEqual([["a", 0]], stdlib_collections_test_pairs(subtractedFromInt))
        AhkTest.AssertEqual([["a", stdlib.True], ["b", stdlib.False]], stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False)).most_common())
    }

    static TestCounterBoolFractionAndDecimalCountsFollowPythonNumericTower()
    {
        fractionCounts := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2), "b", stdlib.fractions.Fraction(-1, 2)))
        decimalCounts := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", stdlib.decimal.Decimal("-0.5")))
        boolFractionUpdate := stdlib.collections.Counter(Map("a", stdlib.True))
        fractionBoolUpdate := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))
        boolDecimalUpdate := stdlib.collections.Counter(Map("a", stdlib.True))
        decimalBoolSubtract := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5")))

        AhkTest.AssertEqual([["a", "3/2"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(stdlib.operator.pos(fractionCounts))))
        AhkTest.AssertEqual([["b", "1/2"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(stdlib.operator.neg(fractionCounts))))
        AhkTest.AssertEqual([["a", "1.5"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(stdlib.operator.pos(decimalCounts))))
        AhkTest.AssertEqual([["b", "0.5"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(stdlib.operator.neg(decimalCounts))))
        AhkTest.AssertEqual([["a", "3/2"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(stdlib.operator.add(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))))))
        AhkTest.AssertEqual([["a", "1/2"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(stdlib.operator.sub(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))))))
        AhkTest.AssertEqual([["a", "1/2"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(stdlib.operator.and_(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))))))
        AhkTest.AssertEqual([["a", "3/2"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(stdlib.operator.or_(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2)))))))
        AhkTest.AssertEqual([["a", "1.5"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(stdlib.operator.add(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5")))))))
        AhkTest.AssertEqual([["a", "0.5"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(stdlib.operator.sub(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5")))))))

        boolFractionUpdate.update(Map("a", stdlib.fractions.Fraction(1, 2)))
        fractionBoolUpdate.update(Map("a", stdlib.True))
        boolDecimalUpdate.update(Map("a", stdlib.decimal.Decimal("0.5")))
        decimalBoolSubtract.subtract(Map("a", stdlib.True))

        AhkTest.AssertEqual([["a", "3/2"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(boolFractionUpdate)))
        AhkTest.AssertEqual([["a", "3/2"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(fractionBoolUpdate)))
        AhkTest.AssertEqual([["a", "1.5"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(boolDecimalUpdate)))
        AhkTest.AssertEqual([["a", "0.5"]], stdlib_collections_test_render_pairs(stdlib_collections_test_pairs(decimalBoolSubtract)))
    }

    static TestCounterEqNeAgainstNonCounterObjectsReturnPythonBooleans()
    {
        counter := stdlib.collections.Counter(Map("a", 1))

        AhkTest.AssertFalse(stdlib.operator.eq(counter, 42))
        AhkTest.AssertTrue(stdlib.operator.ne(counter, 42))
        AhkTest.AssertFalse(stdlib.operator.eq(counter, "x"))
        AhkTest.AssertTrue(stdlib.operator.ne(counter, "x"))
        AhkTest.AssertFalse(stdlib.operator.eq(counter, ["a", 1]))
        AhkTest.AssertTrue(stdlib.operator.ne(counter, ["a", 1]))
    }

    static TestCounterEqNeUsePythonValueEqualityForListAndDictCounts()
    {
        listLeft := stdlib.collections.Counter(Map("a", [1]))
        listSame := stdlib.collections.Counter(Map("a", [1]))
        listDifferent := stdlib.collections.Counter(Map("a", [2]))
        dictLeft := stdlib.collections.Counter(Map("a", Map("x", 1)))
        dictSame := stdlib.collections.Counter(Map("a", Map("x", 1)))
        dictDifferent := stdlib.collections.Counter(Map("a", Map("x", 2)))
        fractionCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))
        decimalCounter := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5")))

        AhkTest.AssertTrue(stdlib.operator.eq(listLeft, listSame))
        AhkTest.AssertFalse(stdlib.operator.ne(listLeft, listSame))
        AhkTest.AssertFalse(stdlib.operator.eq(listLeft, listDifferent))
        AhkTest.AssertTrue(stdlib.operator.ne(listLeft, listDifferent))
        AhkTest.AssertTrue(stdlib.operator.eq(dictLeft, dictSame))
        AhkTest.AssertFalse(stdlib.operator.ne(dictLeft, dictSame))
        AhkTest.AssertFalse(stdlib.operator.eq(dictLeft, dictDifferent))
        AhkTest.AssertTrue(stdlib.operator.ne(dictLeft, dictDifferent))

        AhkTest.AssertTrue(stdlib.operator.eq(listLeft, Map("a", [1])))
        AhkTest.AssertFalse(stdlib.operator.ne(listLeft, Map("a", [1])))
        AhkTest.AssertFalse(stdlib.operator.eq(listLeft, Map("a", [2])))
        AhkTest.AssertTrue(stdlib.operator.ne(listLeft, Map("a", [2])))
        AhkTest.AssertTrue(stdlib.operator.eq(dictLeft, Map("a", Map("x", 1))))
        AhkTest.AssertFalse(stdlib.operator.ne(dictLeft, Map("a", Map("x", 1))))
        AhkTest.AssertFalse(stdlib.operator.eq(dictLeft, Map("a", Map("x", 2))))
        AhkTest.AssertTrue(stdlib.operator.ne(dictLeft, Map("a", Map("x", 2))))
        AhkTest.AssertTrue(stdlib.operator.eq(fractionCounter, stdlib.collections.Counter(Map("a", 0.5))))
        AhkTest.AssertFalse(stdlib.operator.ne(fractionCounter, stdlib.collections.Counter(Map("a", 0.5))))
        AhkTest.AssertTrue(stdlib.operator.eq(decimalCounter, stdlib.collections.Counter(Map("a", 1.5))))
        AhkTest.AssertFalse(stdlib.operator.ne(decimalCounter, stdlib.collections.Counter(Map("a", 1.5))))
        AhkTest.AssertTrue(stdlib.operator.eq(fractionCounter, Map("a", 0.5)))
        AhkTest.AssertFalse(stdlib.operator.ne(fractionCounter, Map("a", 0.5)))
        AhkTest.AssertTrue(stdlib.operator.eq(decimalCounter, Map("a", 1.5)))
        AhkTest.AssertFalse(stdlib.operator.ne(decimalCounter, Map("a", 1.5)))
    }

    static TestCounterEqNeTreatFractionAndDecimalCountsWithPythonNumericTowerEquality()
    {
        fractionCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))
        decimalCounter := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5")))

        AhkTest.AssertTrue(stdlib.operator.eq(fractionCounter, decimalCounter))
        AhkTest.AssertFalse(stdlib.operator.ne(fractionCounter, decimalCounter))
    }

    static TestCounterRichComparisonsTreatFractionAndDecimalCountsWithPythonNumericTower()
    {
        lowerFractionCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))
        equalFractionCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))
        greaterFractionCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2)))
        equalDecimalCounter := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5")))
        greaterDecimalCounter := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.75")))

        AhkTest.AssertTrue(stdlib.operator.lt(lowerFractionCounter, greaterDecimalCounter))
        AhkTest.AssertTrue(stdlib.operator.le(equalFractionCounter, equalDecimalCounter))
        AhkTest.AssertTrue(stdlib.operator.gt(greaterFractionCounter, equalDecimalCounter))
        AhkTest.AssertTrue(stdlib.operator.ge(equalFractionCounter, equalDecimalCounter))
    }

    static TestCounterArithmeticRejectsNonCounterOperandsLikePython()
    {
        counter := stdlib.collections.Counter(Map("a", 1))

        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+", (*) => stdlib.operator.add(counter, Map("a", 1)))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for &", (*) => stdlib.operator.and_(counter, Map("a", 1)))
        AhkTest.RaisesMatch(TypeError, "not supported between instances", (*) => stdlib.operator.lt(counter, Map("a", 1)))
    }

    static TestCounterArithmeticAgainstMappingSubclassUsesConcreteTypeNameLikeLocal310()
    {
        counter := stdlib.collections.Counter(Map("a", 1))
        mapping := StdlibCollectionsTest.DemoDictLike()
        mapping["a"] := 1

        AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for \+: 'Counter' and 'DemoDictLike'$", (*) => stdlib.operator.add(counter, mapping))
        AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for \-: 'Counter' and 'DemoDictLike'$", (*) => stdlib.operator.sub(counter, mapping))
        AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for &: 'Counter' and 'DemoDictLike'$", (*) => stdlib.operator.and_(counter, mapping))
    }

    static TestCounterRightOperandKeepsConcreteLeftTypeNameLikeLocal310()
    {
        counter := stdlib.collections.Counter(Map("a", 1))
        mapping := StdlibCollectionsTest.DemoDictLike()
        mapping["a"] := 1

        AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for \+: 'dict' and 'Counter'$", (*) => stdlib.operator.add(Map("a", 1), counter))
        AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for \-: 'dict' and 'Counter'$", (*) => stdlib.operator.sub(Map("a", 1), counter))
        AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for &: 'dict' and 'Counter'$", (*) => stdlib.operator.and_(Map("a", 1), counter))
        AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for \+: 'DemoDictLike' and 'Counter'$", (*) => stdlib.operator.add(mapping, counter))
        AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for \-: 'DemoDictLike' and 'Counter'$", (*) => stdlib.operator.sub(mapping, counter))
        AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for &: 'DemoDictLike' and 'Counter'$", (*) => stdlib.operator.and_(mapping, counter))
    }

    static TestCounterOrWithMappingUsesObservedLocal310DictUnion()
    {
        counter := stdlib.collections.Counter(Map("a", 1, "b", 2))
        plain := Map("a", 9, "c", 3)
        mapping := StdlibCollectionsTest.DemoDictLike()
        mapping["a"] := 9
        mapping["c"] := 3

        leftPlain := stdlib.operator.or_(counter, plain)
        leftSubclass := stdlib.operator.or_(counter, mapping)
        rightPlain := stdlib.operator.or_(plain, counter)
        rightSubclass := stdlib.operator.or_(mapping, counter)

        AhkTest.AssertEqual("Map", Type(leftPlain))
        AhkTest.AssertEqual("Map", Type(leftSubclass))
        AhkTest.AssertEqual("Map", Type(rightPlain))
        AhkTest.AssertEqual("Map", Type(rightSubclass))
        AhkTest.AssertEqual([["a", 9], ["b", 2], ["c", 3]], stdlib_collections_test_pairs(leftPlain))
        AhkTest.AssertEqual([["a", 9], ["b", 2], ["c", 3]], stdlib_collections_test_pairs(leftSubclass))
        AhkTest.AssertEqual(1, rightPlain["a"])
        AhkTest.AssertEqual(3, rightPlain["c"])
        AhkTest.AssertEqual(2, rightPlain["b"])
        AhkTest.AssertEqual(1, rightSubclass["a"])
        AhkTest.AssertEqual(3, rightSubclass["c"])
        AhkTest.AssertEqual(2, rightSubclass["b"])
    }

    static TestCounterMappingSubclassEqNeButOrderingUsesConcreteTypeNameLikeLocal310()
    {
        counter := stdlib.collections.Counter(Map("a", 1))
        dictLikeHigher := StdlibCollectionsTest.DemoDictLike()
        dictLikeEqual := StdlibCollectionsTest.DemoDictLike()
        dictLikeHigher["a"] := 2
        dictLikeEqual["a"] := 1

        AhkTest.AssertTrue(stdlib.operator.eq(counter, dictLikeEqual))
        AhkTest.AssertFalse(stdlib.operator.ne(counter, dictLikeEqual))
        AhkTest.RaisesMatch(TypeError, "^'<' not supported between instances of 'Counter' and 'DemoDictLike'$", (*) => stdlib.operator.lt(counter, dictLikeHigher))
        AhkTest.RaisesMatch(TypeError, "^'<=' not supported between instances of 'Counter' and 'DemoDictLike'$", (*) => stdlib.operator.le(counter, dictLikeHigher))
        AhkTest.RaisesMatch(TypeError, "^'>' not supported between instances of 'Counter' and 'DemoDictLike'$", (*) => stdlib.operator.gt(counter, dictLikeHigher))
        AhkTest.RaisesMatch(TypeError, "^'>=' not supported between instances of 'Counter' and 'DemoDictLike'$", (*) => stdlib.operator.ge(counter, dictLikeHigher))
    }

    static TestPublicCollectionsSurfaceCoversCoreContainerFunctions()
    {
        deque := stdlib.collections.deque([1, 2], 3)
        deque.append(3)
        deque.appendleft(0)
        deque.append(4)
        deque.rotate(1)
        poppedRight := deque.pop()
        poppedLeft := deque.popleft()
        deque.extend([5, 6])
        deque.extendleft([-1, -2])

        defaultDict := stdlib.collections.defaultdict((*) => [])
        defaultDict["a"].Push(1)
        missingDefault := defaultDict["b"]

        ordered := stdlib.collections.OrderedDict([["a", 1], ["b", 2]])
        ordered.move_to_end("a")
        lastItem := ordered.popitem()
        ordered["c"] := 3
        ordered.move_to_end("c", false)

        chain := stdlib.collections.ChainMap(Map("a", 1), Map("a", 2, "b", 3))
        chain["c"] := 4
        child := chain.new_child(Map("z", 9))

        pointType := stdlib.collections.namedtuple("Point", "x y")
        point := pointType.Call(2, 3)
        replaced := point._replace({ kwargs: Map("y", 5) })
        made := pointType._make([7, 8])

        userDict := stdlib.collections.UserDict(Map("a", 1))
        userDict["b"] := 2
        userList := stdlib.collections.UserList([1, 2])
        userList.append(3)
        userString := stdlib.collections.UserString("ahk")

        AhkTest.AssertSame(AhkStdlibCollectionsDeque, stdlib.collections.deque)
        AhkTest.AssertSame(AhkStdlibCollectionsDefaultDict, stdlib.collections.defaultdict)
        AhkTest.AssertSame(AhkStdlibCollectionsOrderedDict, stdlib.collections.OrderedDict)
        AhkTest.AssertSame(AhkStdlibCollectionsChainMap, stdlib.collections.ChainMap)
        AhkTest.AssertSame(AhkStdlibCollectionsUserDict, stdlib.collections.UserDict)
        AhkTest.AssertSame(AhkStdlibCollectionsUserList, stdlib.collections.UserList)
        AhkTest.AssertSame(AhkStdlibCollectionsUserString, stdlib.collections.UserString)

        AhkTest.AssertEqual(3, deque.maxlen)
        AhkTest.AssertEqual(2, poppedRight)
        AhkTest.AssertEqual(4, poppedLeft)
        AhkTest.AssertEqual([-2, -1, 1], stdlib_collections_test_array(deque))
        AhkTest.RaisesMatch(IndexError, "^pop from an empty deque$", (*) => stdlib.collections.deque().pop())

        AhkTest.AssertTrue(HasMethod(defaultDict.default_factory, "Call"))
        AhkTest.AssertEqual([["a", [1]], ["b", []]], stdlib_collections_test_pairs(defaultDict))
        AhkTest.AssertSame(missingDefault, defaultDict["b"])

        AhkTest.AssertEqual(["a", 1], stdlib_collections_test_array(lastItem))
        AhkTest.AssertEqual([["c", 3], ["b", 2]], stdlib_collections_test_pairs(ordered))

        AhkTest.AssertEqual(1, chain["a"])
        AhkTest.AssertEqual(3, chain["b"])
        AhkTest.AssertEqual(4, chain["c"])
        AhkTest.AssertEqual(2, chain.maps.Length)
        AhkTest.AssertEqual(3, child.maps.Length)
        AhkTest.AssertEqual([["z", 9]], stdlib_collections_test_pairs(child.maps[1]))

        AhkTest.AssertEqual("Point", pointType.__name)
        AhkTest.AssertEqual(["x", "y"], pointType._fields)
        AhkTest.AssertEqual([2, 3], stdlib_collections_test_array(point))
        AhkTest.AssertEqual(2, point.x)
        AhkTest.AssertEqual(3, point.y)
        AhkTest.AssertEqual([["x", 2], ["y", 3]], stdlib_collections_test_pairs(point._asdict()))
        AhkTest.AssertEqual([2, 5], stdlib_collections_test_array(replaced))
        AhkTest.AssertEqual([7, 8], stdlib_collections_test_array(made))

        AhkTest.AssertEqual([["a", 1], ["b", 2]], stdlib_collections_test_pairs(userDict))
        AhkTest.AssertEqual([1, 2, 3], stdlib_collections_test_array(userList))
        AhkTest.AssertEqual([1, 2, 3], userList.data)
        AhkTest.AssertEqual("ahk", userString.data)
        AhkTest.AssertEqual("AHK", userString.upper().data)
    }

    static TestDequeRingBufferLeftEndCorrectnessUnderGrowth()
    {
        ; Exercise the ring buffer past its initial capacity from both ends.
        dq := stdlib.collections.deque()
        loop 100
            dq.appendleft(A_Index)          ; 100,99,...,1 (left grows)
        loop 100
            dq.append(100 + A_Index)        ; ...,101..200 (right grows)
        AhkTest.AssertEqual(200, dq.Length)
        ; 0-based indexing (like Python): first element is the last appendleft
        ; value (100); index 99 is 1; index 199 is 200.
        AhkTest.AssertEqual(100, dq[0])
        AhkTest.AssertEqual(1, dq[99])
        AhkTest.AssertEqual(200, dq[199])
        ; Drain from the left and confirm FIFO order of the left half.
        expected := 100
        loop 100 {
            AhkTest.AssertEqual(expected, dq.popleft())
            expected -= 1
        }
        ; Remaining 100 elements are 101..200 from the left.
        AhkTest.AssertEqual(101, dq.popleft())
        AhkTest.AssertEqual(200, dq.pop())
        AhkTest.AssertEqual(98, dq.Length)
    }

    static TestDequeMaxlenDropsFromOppositeEnd()
    {
        dq := stdlib.collections.deque([1, 2, 3], 3)
        dq.append(4)                        ; drops 1 from the left
        AhkTest.AssertEqual([2, 3, 4], stdlib_collections_test_array(dq))
        dq.appendleft(0)                    ; drops 4 from the right
        AhkTest.AssertEqual([0, 2, 3], stdlib_collections_test_array(dq))
    }

    static TestCollectionsAbcProtocolChecks()
    {
        abc := stdlib.collections.abc
        ; Hashable: scalars yes, mutable containers no.
        AhkTest.AssertTrue(abc.Hashable.isinstance("x"))
        AhkTest.AssertTrue(abc.Hashable.isinstance(5))
        AhkTest.AssertFalse(abc.Hashable.isinstance([1, 2]))
        ; Sized / Container: arrays and maps qualify.
        AhkTest.AssertTrue(abc.Sized.isinstance([1, 2]))
        AhkTest.AssertTrue(abc.Sized.isinstance(Map("a", 1)))
        AhkTest.AssertFalse(abc.Sized.isinstance(5))
        AhkTest.AssertTrue(abc.Container.isinstance(Map("a", 1)))
        ; Callable: functions yes, data no.
        AhkTest.AssertTrue(abc.Callable.isinstance((*) => 1))
        AhkTest.AssertFalse(abc.Callable.isinstance(5))
        ; Iterable: arrays/maps/strings.
        AhkTest.AssertTrue(abc.Iterable.isinstance([1]))
        AhkTest.AssertTrue(abc.Iterable.isinstance("abc"))
    }

    static TestCollectionsAbcStructuralHierarchies()
    {
        abc := stdlib.collections.abc
        list := [1, 2, 3]
        dict := Map("a", 1)
        text := "abc"
        tup := stdlib.tuple([1, 2])

        ; Collection = Sized + Iterable + Container. list/dict/str all qualify.
        AhkTest.AssertTrue(abc.Collection.isinstance(list))
        AhkTest.AssertTrue(abc.Collection.isinstance(dict))
        AhkTest.AssertTrue(abc.Collection.isinstance(text))
        AhkTest.AssertFalse(abc.Collection.isinstance(5))

        ; Reversible: ordered sequences and (3.8+) dicts.
        AhkTest.AssertTrue(abc.Reversible.isinstance(list))
        AhkTest.AssertTrue(abc.Reversible.isinstance(text))
        AhkTest.AssertTrue(abc.Reversible.isinstance(dict))

        ; Mapping/MutableMapping: AHK Map mirrors dict (both true).
        AhkTest.AssertTrue(abc.Mapping.isinstance(dict))
        AhkTest.AssertTrue(abc.MutableMapping.isinstance(dict))
        AhkTest.AssertFalse(abc.Mapping.isinstance(list))
        AhkTest.AssertFalse(abc.Mapping.isinstance(text))

        ; Sequence: Array/String/tuple yes; Map no (matching dict).
        AhkTest.AssertTrue(abc.Sequence.isinstance(list))
        AhkTest.AssertTrue(abc.Sequence.isinstance(text))
        AhkTest.AssertTrue(abc.Sequence.isinstance(tup))
        AhkTest.AssertFalse(abc.Sequence.isinstance(dict))

        ; MutableSequence: Array yes; tuple (mutation-blocked) no; str no.
        AhkTest.AssertTrue(abc.MutableSequence.isinstance(list))
        AhkTest.AssertFalse(abc.MutableSequence.isinstance(tup))
        AhkTest.AssertFalse(abc.MutableSequence.isinstance(text))

        ; Iterator: a live enumerator is an Iterator; a list is not.
        AhkTest.AssertFalse(abc.Iterator.isinstance(list))
        AhkTest.AssertTrue(abc.Iterator.isinstance(StdlibCollectionsAbcIteratorLike()))

        ; Set/MutableSet: AHK has no native set; native containers are excluded;
        ; only objects duck-typing the protocol qualify.
        AhkTest.AssertFalse(abc.Set.isinstance(list))
        AhkTest.AssertFalse(abc.Set.isinstance(dict))
        setLike := StdlibCollectionsAbcSetLike()
        AhkTest.AssertTrue(abc.Set.isinstance(setLike))
        AhkTest.AssertTrue(abc.MutableSet.isinstance(setLike))

        ; Generator: a structural protocol (Iterator + send + throw + close),
        ; matching CPython's purely structural Generator.__subclasshook__. AHK has
        ; no `yield`, so nothing CREATES a generator, but an object that
        ; hand-implements the protocol is recognized, exactly as CPython
        ; recognizes such a class. A plain iterator (no send/throw/close) is NOT a
        ; Generator, and native containers never qualify.
        AhkTest.AssertFalse(abc.Generator.isinstance(list))
        AhkTest.AssertFalse(abc.Generator.isinstance(StdlibCollectionsAbcIteratorLike()))
        genLike := StdlibCollectionsAbcGeneratorLike()
        AhkTest.AssertTrue(abc.Generator.isinstance(genLike))
        ; A Generator is also an Iterator (the protocol subsumes it).
        AhkTest.AssertTrue(abc.Iterator.isinstance(genLike))
    }
}

class StdlibCollectionsAbcGeneratorLike
{
    ; Hand-implements the CPython Generator protocol: Iterator (Call/__Enum or
    ; __next__) plus send/throw/close. Not produced by `yield` (AHK has none),
    ; but structurally a generator.
    Call(&v) => false
    __Enum(n) => this
    __next__() => ""
    send(value) => ""
    throw(exc) => ""
    close() => ""
}

class StdlibCollectionsAbcSetLike
{
    Count => 0
    Has(x) => false
    add(x) => ""
    discard(x) => ""
    __Enum(n) => (&v) => false
}

class StdlibCollectionsAbcIteratorLike
{
    ; A live iterator: callable as an enumerator and self-iterable, but not an
    ; Array/Map. Mirrors how itertools iterators present in this stdlib.
    Call(&v) => false
    __Enum(n) => this
}

stdlib_collections_test_array(iterable)
{
    result := []
    for value in iterable
        result.Push(value)
    return result
}

stdlib_collections_test_rest(iterator)
{
    result := []
    value := unset
    while iterator(&value)
        result.Push(value)
    return result
}

stdlib_collections_test_pairs(counter)
{
    result := []
    for key, value in counter
        result.Push([key, value])
    return result
}

stdlib_collections_test_render_pairs(pairs)
{
    result := []
    for pair in pairs
        result.Push([pair[1], String(pair[2])])
    return result
}

AhkTest.Collect(StdlibCollectionsTest)
