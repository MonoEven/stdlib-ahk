#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\datetime>
#Include <stdlib\decimal>
#Include <stdlib\fractions>
#Include <stdlib\itertools>

class StdlibItertoolsTest
{
    static DemoTimesFunction()
    {
    }

    class DemoTimes
    {
    }

    class DemoIterableSource
    {
    }

    class DemoFillvalueIterable
    {
        __New()
        {
            this.fillvalue := "not an option"
            this.Values := ["a", "b"]
        }

        __Enum(numberOfVars)
        {
            index := 0
            values := this.Values

            return NextValue

            NextValue(&value)
            {
                index += 1
                if index > values.Length
                    return false
                value := values[index]
                return true
            }
        }
    }

    class DemoChainIterable
    {
        __New()
        {
            this.iterables := "not a keyword"
            this.Values := ["a", "b"]
        }

        __Enum(numberOfVars)
        {
            index := 0
            values := this.Values

            return NextValue

            NextValue(&value)
            {
                index += 1
                if index > values.Length
                    return false
                value := values[index]
                return true
            }
        }
    }

    class DemoRepeatIterable
    {
        __New()
        {
            this.repeat := "not an option"
            this.Values := ["a", "b"]
        }

        __Enum(numberOfVars)
        {
            index := 0
            values := this.Values

            return NextValue

            NextValue(&value)
            {
                index += 1
                if index > values.Length
                    return false
                value := values[index]
                return true
            }
        }
    }

    class DemoTeeReenterSource
    {
        __New()
        {
            this.First := true
            this.Peer := unset
        }

        __Enum(numberOfVars)
        {
            self := this

            return NextValue

            NextValue(&value)
            {
                first := self.First
                self.First := false
                if !first
                    return false

                peerEnum := self.Peer.__Enum(1)
                return peerEnum(&value)
            }
        }
    }

    class DemoInitialValue
    {
        __New(value)
        {
            this.initial := "not an option"
            this.Value := value
        }
    }

    class DemoCountOptions
    {
        __New()
        {
            this.start := 3
            this.step := 2
        }
    }

    class DemoKeyCallable
    {
        __New()
        {
            this.key := "not an option"
        }

        Call(value)
        {
            return SubStr(value, 1, 1)
        }
    }

    static TestCountWorksWithIsliceUsingPythonIndexes()
    {
        values := stdlib.itertools.count(10, 2)

        result := stdlib_itertools_test_array(stdlib.itertools.islice(values, 0, 4))

        AhkTest.AssertEqual([10, 12, 14, 16], result)
    }

    static TestCountAcceptsStartAndStepOptionsLikePython310()
    {
        startOnly := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.count({ start: 3 }), 4))
        stepOnly := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.count({ step: 2 }), 4))
        startAndStep := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.count({ start: 3, step: 2 }), 4))
        splitStartAndStep := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.count({ start: 3 }, { step: 2 }), 4))
        splitStepAndStart := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.count({ step: 2 }, { start: 3 }), 4))
        positionalStartKeywordStep := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.count(3, { step: 2 }), 4))
        rootBoolOptions := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.count({ start: stdlib.True, step: stdlib.False }), 4))

        AhkTest.AssertEqual([3, 4, 5, 6], startOnly)
        AhkTest.AssertEqual([0, 2, 4, 6], stepOnly)
        AhkTest.AssertEqual([3, 5, 7, 9], startAndStep)
        AhkTest.AssertEqual([3, 5, 7, 9], splitStartAndStep)
        AhkTest.AssertEqual([3, 5, 7, 9], splitStepAndStart)
        AhkTest.AssertEqual([3, 5, 7, 9], positionalStartKeywordStep)
        AhkTest.AssertSame(stdlib.True, rootBoolOptions[1])
        AhkTest.AssertEqual([1, 1, 1], [rootBoolOptions[2], rootBoolOptions[3], rootBoolOptions[4]])
    }

    static TestCountRejectsDuplicateStartOptionLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "argument for count\(\) given by name \('start'\) and position \(1\)",
            (*) => stdlib.itertools.count(3, { start: 4 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "count\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib.itertools.count(1, 2, { start: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for count\(\)",
            (*) => stdlib.itertools.count({ step: 2, extra: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "count\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.count({ start: 1, step: 2, extra: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for count\(\)",
            (*) => stdlib.itertools.count({ extra: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for count\(\)",
            (*) => stdlib.itertools.count({ start: 1 }, { extra: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for count\(\)",
            (*) => stdlib.itertools.count({ step: 2 }, { extra: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "count\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.count({ start: 1 }, { step: 2, extra: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "count\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.count({ start: 1, extra: 3 }, { step: 2 })
        )
    }

    static TestCountTreatsStartStepPropertyObjectsAsValues()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "a number is required",
            (*) => stdlib.itertools.count(StdlibItertoolsTest.DemoCountOptions())
        )
    }

    static TestCountTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsValuesLikePython310()
    {
        callableStartProp := stdlib_itertools_test_plain_callable_object("start", (*) => 1)
        callableStepProp := stdlib_itertools_test_plain_callable_object("step", (*) => 1)
        callableExtraProp := stdlib_itertools_test_plain_callable_object("extra", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "a number is required",
            (*) => stdlib.itertools.count(callableStartProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "a number is required",
            (*) => stdlib.itertools.count(callableStepProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "a number is required",
            (*) => stdlib.itertools.count(callableExtraProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "a number is required",
            (*) => stdlib.itertools.count(0, callableStartProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "a number is required",
            (*) => stdlib.itertools.count(0, callableStepProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "a number is required",
            (*) => stdlib.itertools.count(0, callableExtraProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "a number is required",
            (*) => stdlib.itertools.count(callableStartProp, callableStepProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "a number is required",
            (*) => stdlib.itertools.count(callableStepProp, callableStartProp)
        )
    }

    static TestCountIteratorKeepsPositionAcrossConsumers()
    {
        values := stdlib.itertools.count(10)

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))
        second := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))

        AhkTest.AssertEqual([10, 11], first)
        AhkTest.AssertEqual([12, 13], second)
    }

    static TestCountReprTracksCurrentValueLikePython310()
    {
        values := stdlib.itertools.count(10, 2)
        boolStep := stdlib.itertools.count(stdlib.True, stdlib.False)

        AhkTest.AssertTrue(HasMethod(values, "__Repr"))
        AhkTest.AssertEqual("count(10, 2)", values.__Repr())
        AhkTest.AssertEqual([10, 12], stdlib_itertools_test_array(stdlib.itertools.islice(values, 2)))
        AhkTest.AssertEqual("count(14, 2)", values.__Repr())
        AhkTest.AssertEqual("count(True, False)", boolStep.__Repr())
        AhkTest.AssertEqual([stdlib.True], stdlib_itertools_test_array(stdlib.itertools.islice(boolStep, 1)))
        AhkTest.AssertEqual("count(1, False)", boolStep.__Repr())
    }

    static TestRepeatStopsAfterRequestedTimes()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.repeat("x", 3))

        AhkTest.AssertEqual(["x", "x", "x"], result)
    }

    static TestRepeatIteratorKeepsPositionAcrossConsumers()
    {
        values := stdlib.itertools.repeat("x", 3)

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))
        second := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))

        AhkTest.AssertEqual(["x", "x"], first)
        AhkTest.AssertEqual(["x"], second)
    }

    static TestRepeatReprTracksRemainingCountLikePython310()
    {
        limited := stdlib.itertools.repeat("x", 3)
        unlimited := stdlib.itertools.repeat("x")
        falseTimes := stdlib.itertools.repeat("x", stdlib.False)

        AhkTest.AssertTrue(HasMethod(limited, "__Repr"))
        AhkTest.AssertEqual("repeat('x', 3)", limited.__Repr())
        AhkTest.AssertEqual(["x", "x"], stdlib_itertools_test_array(stdlib.itertools.islice(limited, 2)))
        AhkTest.AssertEqual("repeat('x', 1)", limited.__Repr())
        AhkTest.AssertEqual("repeat('x')", unlimited.__Repr())
        AhkTest.AssertEqual(["x", "x"], stdlib_itertools_test_array(stdlib.itertools.islice(unlimited, 2)))
        AhkTest.AssertEqual("repeat('x')", unlimited.__Repr())
        AhkTest.AssertEqual("repeat('x', 0)", falseTimes.__Repr())
    }

    static TestRepeatWithoutTimesIsLazyAndUnlimited()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.repeat("x"), 4))

        AhkTest.AssertEqual(["x", "x", "x", "x"], result)
    }

    static TestRepeatAcceptsRootBoolTimesLikePython()
    {
        AhkTest.AssertEqual(["x"], stdlib_itertools_test_array(stdlib.itertools.repeat("x", stdlib.True)))
        AhkTest.AssertEqual([], stdlib_itertools_test_array(stdlib.itertools.repeat("x", stdlib.False)))
    }

    static TestRepeatAcceptsKeywordAnaloguesLikePython310()
    {
        timesKeywordValues := stdlib_itertools_test_array(stdlib.itertools.repeat("x", { times: 3 }))
        bothKeywordValues := stdlib_itertools_test_array(stdlib.itertools.repeat({ object: "x", times: 3 }))
        objectOnlyValues := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.repeat({ object: "x" }), 4))

        AhkTest.AssertEqual(["x", "x", "x"], timesKeywordValues)
        AhkTest.AssertEqual(["x", "x", "x"], bothKeywordValues)
        AhkTest.AssertEqual(["x", "x", "x", "x"], objectOnlyValues)
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) missing required argument 'object' \(pos 1\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.repeat({ times: 3 }))
        )
    }

    static TestRepeatAcceptsSplitKeywordAnaloguesLikePython310()
    {
        splitKeywordValues := stdlib_itertools_test_array(stdlib.itertools.repeat({ object: "x" }, { times: 3 }))
        reversedSplitKeywordValues := stdlib_itertools_test_array(stdlib.itertools.repeat({ times: 3 }, { object: "x" }))

        AhkTest.AssertEqual(["x", "x", "x"], splitKeywordValues)
        AhkTest.AssertEqual(["x", "x", "x"], reversedSplitKeywordValues)
    }

    static TestRepeatMatchesSplitKeywordPriorityLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for repeat\(\)",
            (*) => stdlib.itertools.repeat({ object: "x" }, { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for repeat\(\)",
            (*) => stdlib.itertools.repeat({ extra: 1 }, { object: "x" })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) missing required argument 'object' \(pos 1\)",
            (*) => stdlib.itertools.repeat({ times: 3 }, { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) missing required argument 'object' \(pos 1\)",
            (*) => stdlib.itertools.repeat({ extra: 1 }, { times: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.repeat({ object: "x" }, { times: 3, extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.repeat({ times: 3 }, { object: "x", extra: 1 })
        )
    }

    static TestRepeatRejectsDuplicateSplitKeywordsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'object'",
            (*) => stdlib.itertools.repeat({ object: "x" }, { object: "y" })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'times'",
            (*) => stdlib.itertools.repeat({ object: "x", times: 3 }, { times: 4 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'times'",
            (*) => stdlib.itertools.repeat({ times: 4 }, { object: "x", times: 3 })
        )
    }

    static TestRepeatRejectsDuplicateInvalidSplitKeywordsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.repeat({ extra: 1 }, { extra: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.repeat({ object: "x", extra: 1 }, { extra: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.repeat({ times: 3, extra: 1 }, { extra: 2 })
        )
    }

    static TestRepeatRejectsThreeWaySplitKeywordPriorityLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.repeat({ object: "x" }, { times: 3 }, { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.repeat({ extra: 1 }, { object: "x" }, { times: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.repeat({ extra: 1 }, { another: 2 }, { third: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'times'",
            (*) => stdlib.itertools.repeat({ object: "x" }, { times: 3 }, { times: 4 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'object'",
            (*) => stdlib.itertools.repeat({ object: "x" }, { object: "y" }, { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.repeat({ extra: 1 }, { extra: 2 }, { object: "x" })
        )
    }

    static TestRepeatRejectsPositionalThreeWaySplitKeywordPriorityLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'times'",
            (*) => stdlib.itertools.repeat("x", { times: 3 }, { times: 4 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.repeat("x", { extra: 1 }, { extra: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib.itertools.repeat("x", { times: 3 }, { another: 2 })
        )
    }

    static TestRepeatAcceptsPlainIterableObjectsWithKeywordLikeOwnPropsAsValuesLikePython310()
    {
        objectPropValue := stdlib_itertools_test_plain_iterable_object("object", ["A", "B"])
        timesPropValue := stdlib_itertools_test_plain_iterable_object("times", ["C", "D"])
        objectPropRepeated := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.repeat(objectPropValue), 2))
        timesPropRepeated := stdlib_itertools_test_array(stdlib.itertools.repeat(timesPropValue, 2))

        AhkTest.AssertEqual(2, objectPropRepeated.Length)
        AhkTest.AssertTrue(ObjPtr(objectPropRepeated[1]) = ObjPtr(objectPropValue))
        AhkTest.AssertTrue(ObjPtr(objectPropRepeated[2]) = ObjPtr(objectPropValue))
        AhkTest.AssertEqual(["A", "B"], stdlib_itertools_test_array(objectPropRepeated[1]))
        AhkTest.AssertEqual(2, timesPropRepeated.Length)
        AhkTest.AssertTrue(ObjPtr(timesPropRepeated[1]) = ObjPtr(timesPropValue))
        AhkTest.AssertTrue(ObjPtr(timesPropRepeated[2]) = ObjPtr(timesPropValue))
        AhkTest.AssertEqual(["C", "D"], stdlib_itertools_test_array(timesPropRepeated[1]))
    }

    static TestRepeatTreatsPlainObjectTimesArgumentsAsValuesLikePython310()
    {
        iterableTimesValue := stdlib_itertools_test_plain_iterable_object("times", ["A", "B"])
        iterableObjectValue := stdlib_itertools_test_plain_iterable_object("object", ["C", "D"])
        callableTimesValue := stdlib_itertools_test_plain_callable_object("times", (*) => 1)
        callableObjectValue := stdlib_itertools_test_plain_callable_object("object", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", iterableTimesValue)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", iterableObjectValue)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", callableTimesValue)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", callableObjectValue)
        )
    }

    static TestRepeatRejectsInvalidKeywordPriorityLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for repeat\(\)",
            (*) => stdlib.itertools.repeat({ object: "x", extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) missing required argument 'object' \(pos 1\)",
            (*) => stdlib.itertools.repeat({ times: 3, extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.repeat({ times: 3, extra: 1, another: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.repeat({ object: "x", times: 3, extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "argument for repeat\(\) given by name \('object'\) and position \(1\)",
            (*) => stdlib.itertools.repeat("x", { object: "y" })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib.itertools.repeat("x", { times: 3, extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib.itertools.repeat("x", { object: "y", times: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for repeat\(\)",
            (*) => stdlib.itertools.repeat("x", { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib.itertools.repeat("x", { extra: 1, another: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 arguments \(4 given\)",
            (*) => stdlib.itertools.repeat("x", { object: "y", times: 3, extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib.itertools.repeat("x", 3, { object: "y" })
        )
    }

    static TestRepeatRejectsOptionsOnlyPlainObjectsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) missing required argument 'object' \(pos 1\)",
            (*) => stdlib.itertools.repeat({ extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) missing required argument 'object' \(pos 1\)",
            (*) => stdlib.itertools.repeat({ extra: 1, another: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "repeat\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.repeat({ extra: 1, another: 2, third: 3 })
        )
    }

    static TestRepeatRejectsNonIntegerTimesLikePython()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'float' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", 2.0)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'str' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", "2")
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'NoneType' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", stdlib.None)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'NotImplementedType' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", stdlib.NotImplemented)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoTimes' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", StdlibItertoolsTest.DemoTimes())
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'list' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", [])
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'dict' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", Map())
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'function' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", StdlibItertoolsTest.DemoTimesFunction)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'Fraction' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", stdlib.fractions.Fraction(1, 1))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'decimal.Decimal' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.repeat("x", stdlib.decimal.Decimal("1"))
        )

        AhkTest.AssertEqual(["x"], stdlib_itertools_test_array(stdlib.itertools.repeat("x", true)))
        AhkTest.AssertEqual([], stdlib_itertools_test_array(stdlib.itertools.repeat("x", false)))
        AhkTest.AssertEqual([], stdlib_itertools_test_array(stdlib.itertools.repeat("x", -2)))
    }

    static TestCountRejectsNonNumericStartAndStepLikePython()
    {
        AhkTest.RaisesMatch(TypeError, "a number is required", (*) => stdlib.itertools.count("1"))
        AhkTest.RaisesMatch(TypeError, "a number is required", (*) => stdlib.itertools.count(1, "2"))
    }

    static TestCountAllowsFloatStartAndStep()
    {
        values := stdlib.itertools.count(1.5, 0.5)

        result := stdlib_itertools_test_array(stdlib.itertools.islice(values, 3))

        AhkTest.AssertEqual([1.5, 2.0, 2.5], result)
    }

    static TestCountAcceptsBoolAsPythonIntegerSubclass()
    {
        values := stdlib.itertools.count(true, true)

        result := stdlib_itertools_test_array(stdlib.itertools.islice(values, 4))

        AhkTest.AssertEqual([1, 2, 3, 4], result)
    }

    static TestCountAcceptsRootBoolStartAndStepLikePython310()
    {
        zeroStepTrue := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.count(stdlib.True, stdlib.False), 4))
        zeroStepFalse := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.count(stdlib.False, stdlib.False), 4))
        oneStepFalse := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.count(stdlib.False, stdlib.True), 4))

        AhkTest.AssertSame(stdlib.True, zeroStepTrue[1])
        AhkTest.AssertEqual([1, 1, 1], [zeroStepTrue[2], zeroStepTrue[3], zeroStepTrue[4]])
        AhkTest.AssertSame(stdlib.False, zeroStepFalse[1])
        AhkTest.AssertEqual([0, 0, 0], [zeroStepFalse[2], zeroStepFalse[3], zeroStepFalse[4]])
        AhkTest.AssertEqual([0, 1, 2, 3], oneStepFalse)
    }

    static TestCountAcceptsDecimalAndFractionLikeLocalPython310()
    {
        decimalStart := stdlib.itertools.count(stdlib.decimal.Decimal("1.5"))
        decimalStep := stdlib.itertools.count(1, stdlib.decimal.Decimal("1.5"))
        decimalBoth := stdlib.itertools.count(stdlib.decimal.Decimal("1.5"), stdlib.decimal.Decimal("0.5"))
        fractionStart := stdlib.itertools.count(stdlib.fractions.Fraction(1, 2))
        fractionStep := stdlib.itertools.count(1, stdlib.fractions.Fraction(1, 2))
        fractionBoth := stdlib.itertools.count(stdlib.fractions.Fraction(1, 2), stdlib.fractions.Fraction(1, 3))
        floatFractionStep := stdlib.itertools.count(1.5, stdlib.fractions.Fraction(1, 2))
        fractionFloatStep := stdlib.itertools.count(stdlib.fractions.Fraction(1, 2), 0.5)
        floatFractionBoth := stdlib.itertools.count(1.5, stdlib.fractions.Fraction(1, 3))
        decimalStartValues := stdlib_itertools_test_array(stdlib.itertools.islice(decimalStart, 2))
        decimalStepValues := stdlib_itertools_test_array(stdlib.itertools.islice(decimalStep, 2))
        decimalBothValues := stdlib_itertools_test_array(stdlib.itertools.islice(decimalBoth, 3))
        fractionStartValues := stdlib_itertools_test_array(stdlib.itertools.islice(fractionStart, 2))
        fractionStepValues := stdlib_itertools_test_array(stdlib.itertools.islice(fractionStep, 2))
        fractionBothValues := stdlib_itertools_test_array(stdlib.itertools.islice(fractionBoth, 3))
        floatFractionStepValues := stdlib_itertools_test_array(stdlib.itertools.islice(floatFractionStep, 3))
        fractionFloatStepValues := stdlib_itertools_test_array(stdlib.itertools.islice(fractionFloatStep, 3))
        floatFractionBothValues := stdlib_itertools_test_array(stdlib.itertools.islice(floatFractionBoth, 3))

        AhkTest.AssertEqual("1.5", String(decimalStartValues[1]))
        AhkTest.AssertEqual("2.5", String(decimalStartValues[2]))
        AhkTest.AssertEqual("1", String(decimalStepValues[1]))
        AhkTest.AssertEqual("2.5", String(decimalStepValues[2]))
        AhkTest.AssertEqual("1.5", String(decimalBothValues[1]))
        AhkTest.AssertEqual("2.0", String(decimalBothValues[2]))
        AhkTest.AssertEqual("2.5", String(decimalBothValues[3]))
        AhkTest.AssertEqual("1/2", String(fractionStartValues[1]))
        AhkTest.AssertEqual("3/2", String(fractionStartValues[2]))
        AhkTest.AssertEqual("1", String(fractionStepValues[1]))
        AhkTest.AssertEqual("3/2", String(fractionStepValues[2]))
        AhkTest.AssertEqual("1/2", String(fractionBothValues[1]))
        AhkTest.AssertEqual("5/6", String(fractionBothValues[2]))
        AhkTest.AssertEqual("7/6", String(fractionBothValues[3]))
        AhkTest.AssertEqual(1.5, floatFractionStepValues[1])
        AhkTest.AssertEqual(2.0, floatFractionStepValues[2])
        AhkTest.AssertEqual(2.5, floatFractionStepValues[3])
        AhkTest.AssertEqual("1/2", String(fractionFloatStepValues[1]))
        AhkTest.AssertEqual(1.0, fractionFloatStepValues[2])
        AhkTest.AssertEqual(1.5, fractionFloatStepValues[3])
        AhkTest.AssertEqual(1.5, floatFractionBothValues[1])
        AhkTest.AssertEqual(1.8333333333333333, floatFractionBothValues[2])
        AhkTest.AssertEqual(2.1666666666666665, floatFractionBothValues[3])
        AhkTest.RaisesMatch(
            TypeError,
            "unsupported operand type\(s\) for \+: 'decimal\.Decimal' and 'Fraction'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.count(stdlib.decimal.Decimal("1.5"), stdlib.fractions.Fraction(1, 2)), 2))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "unsupported operand type\(s\) for \+: 'Fraction' and 'decimal\.Decimal'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.count(stdlib.fractions.Fraction(1, 2), stdlib.decimal.Decimal("0.5")), 2))
        )
    }

    static TestCountRejectsDateAndDatetimeStartsLikeLocalPython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "a number is required",
            (*) => stdlib.itertools.count(
                stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3),
                stdlib.datetime.timedelta({ days: 1, seconds: 2 })
            )
        )
        AhkTest.RaisesMatch(
            TypeError,
            "a number is required",
            (*) => stdlib.itertools.count(
                stdlib.datetime.date(2024, 2, 29),
                stdlib.datetime.timedelta({ days: 1 })
            )
        )
    }

    static TestChainYieldsEachIterableInOrder()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.chain([1, 2], "ab", [], [3]))

        AhkTest.AssertEqual([1, 2, "a", "b", 3], result)
    }

    static TestChainWithNoIterablesIsEmpty()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.chain())

        AhkTest.AssertEqual([], result)
    }

    static TestChainIteratorKeepsPositionAcrossConsumers()
    {
        values := stdlib.itertools.chain([1, 2], "ab")

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 3))
        second := stdlib_itertools_test_array(stdlib.itertools.islice(values, 3))

        AhkTest.AssertEqual([1, 2, "a"], first)
        AhkTest.AssertEqual(["b"], second)
    }

    static TestChainFromIterableFlattensOuterIterableLikePython310()
    {
        values := stdlib.itertools.chain.from_iterable([[1, 2], "ab", []])

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 3))
        second := stdlib_itertools_test_array(stdlib.itertools.islice(values, 3))

        AhkTest.AssertEqual([1, 2, "a"], first)
        AhkTest.AssertEqual(["b"], second)
    }

    static TestChainFromIterableRejectsKeywordStyleOptionsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "chain\.from_iterable\(\) takes no keyword arguments",
            (*) => stdlib.itertools.chain.from_iterable({ iterable: [[1]] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "chain\.from_iterable\(\) takes no keyword arguments",
            (*) => stdlib.itertools.chain.from_iterable({ iterable: stdlib.True })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "chain\.from_iterable\(\) takes no keyword arguments",
            (*) => stdlib.itertools.chain.from_iterable("ab", { iterable: [[1]] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "chain\.from_iterable\(\) takes no keyword arguments",
            (*) => stdlib.itertools.chain.from_iterable({ extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "chain\.from_iterable\(\) takes no keyword arguments",
            (*) => stdlib.itertools.chain.from_iterable({ extra: 1, another: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "chain\.from_iterable\(\) takes no keyword arguments",
            (*) => stdlib.itertools.chain.from_iterable({ iterable: [[1]], extra: 1 })
        )
    }

    static TestChainRejectsKeywordAnaloguesLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "chain\(\) takes no keyword arguments",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain({ iterables: [[1]] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "chain\(\) takes no keyword arguments",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain({ iterable: stdlib.True }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "chain\(\) takes no keyword arguments",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain("ab", { iterables: [[1]] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "chain\(\) takes no keyword arguments",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain("ab", { iterable: [[1]] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "chain\(\) takes no keyword arguments",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain({ extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "chain\(\) takes no keyword arguments",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain({ extra: 1, another: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "chain\(\) takes no keyword arguments",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain({ iterable: [[1]], extra: 1 }))
        )
    }

    static TestChainRejectsDuplicateSplitKeywordAnaloguesLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain({ extra: 1 }, { extra: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain([1], { extra: 1 }, { extra: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain.from_iterable({ extra: 1 }, { extra: 2 }))
        )
    }

    static TestChainFromIterableLateKeywordPriorityMatchesPython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "chain\.from_iterable\(\) takes no keyword arguments",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain.from_iterable([["a"]], 2, { extra: 1 }))
        )
    }

    static TestChainReprMatchesPython310Shape()
    {
        direct := stdlib.itertools.chain([1], "ab")
        fromIterable := stdlib.itertools.chain.from_iterable([[1], "ab"])

        AhkTest.AssertRegex(direct.__Repr(), "^<itertools\.chain object at 0x[0-9A-F]+>$")
        AhkTest.AssertRegex(fromIterable.__Repr(), "^<itertools\.chain object at 0x[0-9A-F]+>$")
    }

    static TestCoveredIteratorReprsMatchPython310Shape()
    {
        groupbyIterator := stdlib.itertools.groupby("aabb")
        groupbyEnum := groupbyIterator.__Enum(1)
        firstGroupRow := unset
        AhkTest.AssertTrue(groupbyEnum(&firstGroupRow))
        firstGroupValues := stdlib_itertools_test_array(firstGroupRow)

        cases := [
            [stdlib.itertools.accumulate([1, 2]), "accumulate"],
            [stdlib.itertools.compress("ABC", [1, 0, 1]), "compress"],
            [stdlib.itertools.cycle([1, 2]), "cycle"],
            [stdlib.itertools.islice([1, 2, 3], 2), "islice"],
            [stdlib.itertools.pairwise([1, 2, 3]), "pairwise"],
            [stdlib.itertools.product([1], [2]), "product"],
            [stdlib.itertools.zip_longest([1], [2]), "zip_longest"],
            [groupbyIterator, "groupby"],
            [firstGroupValues[2], "_grouper"],
            [stdlib.itertools.combinations([1, 2], 1), "combinations"],
            [stdlib.itertools.combinations_with_replacement([1, 2], 1), "combinations_with_replacement"],
            [stdlib.itertools.permutations([1, 2]), "permutations"],
            [stdlib.itertools.starmap(stdlib_itertools_test_mul, [[2, 3]]), "starmap"],
            [stdlib.itertools.takewhile(stdlib_itertools_test_identity, [1, 0]), "takewhile"],
            [stdlib.itertools.dropwhile(stdlib_itertools_test_identity, [1, 0]), "dropwhile"],
            [stdlib.itertools.filterfalse(stdlib_itertools_test_identity, [0, 1]), "filterfalse"]
        ]

        for , item in cases
            AhkTest.AssertRegex(item[1].__Repr(), "^<itertools\." item[2] " object at 0x[0-9A-F]+>$")
    }

    static TestChainRejectsNonIterableInputsWithPythonTypeNames()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain(42))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'function' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain(StdlibItertoolsTest.DemoTimesFunction))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain(StdlibItertoolsTest.DemoIterableSource()))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'Fraction' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain(stdlib.fractions.Fraction(1, 1)))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'decimal.Decimal' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain(stdlib.decimal.Decimal("1")))
        )
    }

    static TestChainAcceptsIterableObjectsWithKeywordLikeOwnPropsLikePython310()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.chain(StdlibItertoolsTest.DemoChainIterable(), "x"))

        AhkTest.AssertEqual(["a", "b", "x"], result)
    }

    static TestChainAcceptsPlainIterableObjectsWithKeywordLikeOwnPropsLikePython310()
    {
        iterable := stdlib_itertools_test_plain_iterable_object("iterables", ["a", "b"])
        result := stdlib_itertools_test_array(stdlib.itertools.chain(iterable, "x"))

        AhkTest.AssertEqual(["a", "b", "x"], result)
    }

    static TestChainTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsNonIterableLikePython310()
    {
        callableIterableProp := stdlib_itertools_test_plain_callable_object("iterable", (*) => 1)
        callableExtraProp := stdlib_itertools_test_plain_callable_object("extra", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain(callableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain(callableExtraProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain("ab", callableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain.from_iterable(callableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.chain.from_iterable(callableExtraProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "chain\.from_iterable\(\) takes exactly one argument \(2 given\)",
            (*) => stdlib.itertools.chain.from_iterable("ab", callableIterableProp)
        )
    }

    static TestCompressSelectsTruthfulItemsLikePython()
    {
        letters := stdlib_itertools_test_array(stdlib.itertools.compress("ABCDEF", [1, 0, 1, 0, 1, 1]))
        bools := stdlib_itertools_test_array(stdlib.itertools.compress([10, 11, 12, 13], [true, false, 2, 0]))
        emptyData := stdlib_itertools_test_array(stdlib.itertools.compress([], [1, 0, 1]))
        emptySelectors := stdlib_itertools_test_array(stdlib.itertools.compress([1, 2, 3], []))

        AhkTest.AssertEqual(["A", "C", "E", "F"], letters)
        AhkTest.AssertEqual([10, 12], bools)
        AhkTest.AssertEqual([], emptyData)
        AhkTest.AssertEqual([], emptySelectors)
    }

    static TestCompressUsesSharedStdlibTruthinessForSelectorsLikePython310()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.compress("ABCDEFG", [stdlib.True, stdlib.False, [], [1], Map(), Map("x", 1), stdlib.None]))

        AhkTest.AssertEqual(["A", "D", "F"], result)
    }

    static TestCompressAcceptsKeywordAnaloguesLikePython310()
    {
        selectorsKeyword := stdlib_itertools_test_array(stdlib.itertools.compress("ABC", { selectors: [1, 0, 1] }))
        bothKeywords := stdlib_itertools_test_array(stdlib.itertools.compress({ data: "ABC", selectors: [1, 0, 1] }))

        AhkTest.AssertEqual(["A", "C"], selectorsKeyword)
        AhkTest.AssertEqual(["A", "C"], bothKeywords)
        AhkTest.RaisesMatch(
            TypeError,
            "compress\(\) missing required argument 'selectors' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress({ data: "ABC" }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "compress\(\) missing required argument 'selectors' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress({ data: "ABC", extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "compress\(\) missing required argument 'data' \(pos 1\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress({ selectors: [1, 0, 1] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "compress\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress("ABC", [1, 0, 1], { selectors: [1, 1, 1] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "compress\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress({ data: "ABC", selectors: [1, 0, 1], extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress({ data: 42, selectors: [1] }))
        )
    }

    static TestCompressRejectsOptionsOnlyPropertyObjectsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "compress\(\) missing required argument 'data' \(pos 1\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress({ extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "compress\(\) missing required argument 'selectors' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress("ABC", { extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "compress\(\) missing required argument 'selectors' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress("ABC", { data: "XYZ" }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "compress\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress("ABC", { selectors: [1, 0, 1], extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "compress\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress("ABC", { data: "XYZ", selectors: [1, 0, 1] }))
        )
    }

    static TestCompressAcceptsPlainIterableObjectsWithKeywordLikeOwnPropsLikePython310()
    {
        dataIterable := stdlib_itertools_test_plain_iterable_object("data", ["A", "B", "C"])
        selectorsIterable := stdlib_itertools_test_plain_iterable_object("selectors", [1, 0, 1])

        dataPropValues := stdlib_itertools_test_array(stdlib.itertools.compress(dataIterable, [1, 0, 1]))
        selectorsPropValues := stdlib_itertools_test_array(stdlib.itertools.compress("ABC", selectorsIterable))
        bothPropValues := stdlib_itertools_test_array(stdlib.itertools.compress(dataIterable, selectorsIterable))

        AhkTest.AssertEqual(["A", "C"], dataPropValues)
        AhkTest.AssertEqual(["A", "C"], selectorsPropValues)
        AhkTest.AssertEqual(["A", "C"], bothPropValues)
    }

    static TestCompressTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsPositionalLikePython310()
    {
        callableDataProp := stdlib_itertools_test_plain_callable_object("data", (*) => 1)
        callableSelectorsProp := stdlib_itertools_test_plain_callable_object("selectors", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress(callableDataProp, [1]))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress(callableSelectorsProp, [1]))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress("ab", callableSelectorsProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress("ab", callableDataProp))
        )
    }

    static TestCompressIteratorKeepsPositionAcrossConsumers()
    {
        values := stdlib.itertools.compress([1, 2, 3, 4], [1, 0, 1, 1])

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))
        second := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))

        AhkTest.AssertEqual([1, 3], first)
        AhkTest.AssertEqual([4], second)
    }

    static TestCompressRejectsNonIterableInputsAtConstructionLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.compress(42, [1])
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.compress([1], 42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib.itertools.compress(StdlibItertoolsTest.DemoIterableSource(), 42)
        )
    }

    static TestCompressRejectsNonIterableInputsWithPythonTypeNames()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress(42, [1, 0]))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress([1, 2], 42))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress(StdlibItertoolsTest.DemoIterableSource(), [1]))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'function' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress([1, 2], StdlibItertoolsTest.DemoTimesFunction))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'Fraction' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress(stdlib.fractions.Fraction(1, 1), [1]))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'decimal.Decimal' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.compress([1, 2], stdlib.decimal.Decimal("1")))
        )
    }

    static TestAccumulateUsesPythonDefaultAdditionAndInitial()
    {
        basic := stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2, 3, 4]))
        initial := stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], unset, 10))
        empty := stdlib_itertools_test_array(stdlib.itertools.accumulate([]))
        emptyInitial := stdlib_itertools_test_array(stdlib.itertools.accumulate([], unset, 10))
        strings := stdlib_itertools_test_array(stdlib.itertools.accumulate(["a", "b", "c"]))

        AhkTest.AssertEqual([1, 3, 6, 10], basic)
        AhkTest.AssertEqual([10, 11, 13], initial)
        AhkTest.AssertEqual([], empty)
        AhkTest.AssertEqual([10], emptyInitial)
        AhkTest.AssertEqual(["a", "ab", "abc"], strings)
    }

    static TestAccumulateAcceptsInitialOptionLikePython310()
    {
        defaultInitial := stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], { initial: 10 }))
        emptyInitial := stdlib_itertools_test_array(stdlib.itertools.accumulate([], { initial: 10 }))
        noneFuncInitial := stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], stdlib.None, { initial: 10 }))
        mulInitial := stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], stdlib_itertools_test_mul, { initial: 10 }))

        AhkTest.AssertEqual([10, 11, 13], defaultInitial)
        AhkTest.AssertEqual([10], emptyInitial)
        AhkTest.AssertEqual([10, 11, 13], noneFuncInitial)
        AhkTest.AssertEqual([10, 10, 20], mulInitial)
    }

    static TestAccumulateTreatsInitialPropertyObjectsAsValues()
    {
        initialValue := StdlibItertoolsTest.DemoInitialValue(10)

        rows := stdlib_itertools_test_array(stdlib.itertools.accumulate([], unset, initialValue))

        AhkTest.AssertEqual(1, rows.Length)
        AhkTest.AssertSame(initialValue, rows[1])
    }

    static TestAccumulateAcceptsCallableFunctionArgumentLikePython()
    {
        multiplied := stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2, 3, 4], stdlib_itertools_test_mul))

        AhkTest.AssertEqual([1, 2, 6, 24], multiplied)
    }

    static TestAccumulateAcceptsKeywordAnaloguesLikePython310()
    {
        iterableKeywordRows := stdlib_itertools_test_array(stdlib.itertools.accumulate({ iterable: [1, 2, 3] }))
        funcKeywordRows := stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2, 3], { func: stdlib_itertools_test_mul }))
        funcInitialKeywordRows := stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2, 3], { func: stdlib_itertools_test_mul, initial: 10 }))
        allKeywordRows := stdlib_itertools_test_array(stdlib.itertools.accumulate({ iterable: [1, 2, 3], func: stdlib_itertools_test_mul, initial: 10 }))

        AhkTest.AssertEqual([1, 3, 6], iterableKeywordRows)
        AhkTest.AssertEqual([1, 2, 6], funcKeywordRows)
        AhkTest.AssertEqual([10, 10, 20, 60], funcInitialKeywordRows)
        AhkTest.AssertEqual([10, 10, 20, 60], allKeywordRows)

        AhkTest.RaisesMatch(
            TypeError,
            "argument for accumulate\(\) given by name \('iterable'\) and position \(1\)",
            (*) => stdlib.itertools.accumulate([1, 2, 3], { iterable: [4, 5] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "argument for accumulate\(\) given by name \('func'\) and position \(2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2, 3], stdlib_itertools_test_mul, { func: stdlib_itertools_test_mul }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "accumulate\(\) missing required argument 'iterable' \(pos 1\)",
            (*) => stdlib.itertools.accumulate({ func: stdlib_itertools_test_mul })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for accumulate\(\)",
            (*) => stdlib.itertools.accumulate({ iterable: [1, 2], extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "accumulate\(\) takes at most 3 keyword arguments \(4 given\)",
            (*) => stdlib.itertools.accumulate({ iterable: [1, 2], func: stdlib_itertools_test_mul, initial: 0, extra: 1 })
        )
    }

    static TestAccumulateMatchesPythonKeywordPriorityForPropertyObjects()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "accumulate\(\) missing required argument 'iterable' \(pos 1\)",
            (*) => stdlib.itertools.accumulate({ extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "accumulate\(\) takes at most 3 keyword arguments \(4 given\)",
            (*) => stdlib.itertools.accumulate({ extra: 1, another: 2, third: 3, fourth: 4 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for accumulate\(\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], { func: stdlib_itertools_test_mul, extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for accumulate\(\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], { initial: 0, extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "accumulate\(\) takes at most 3 arguments \(4 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], { func: stdlib_itertools_test_mul, initial: 0, extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "accumulate\(\) takes at most 3 arguments \(4 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], { iterable: [3, 4], func: stdlib_itertools_test_mul, initial: 0 }))
        )
    }

    static TestAccumulateRejectsDuplicateSplitKeywordsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'func'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], { func: stdlib_itertools_test_mul }, { func: stdlib_itertools_test_mul }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'initial'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], { initial: 0 }, { initial: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], { extra: 1 }, { extra: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'func'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], { func: stdlib_itertools_test_mul, extra: 1 }, { func: stdlib_itertools_test_mul }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'initial'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], { initial: 0, extra: 1 }, { initial: 1 }))
        )
    }

    static TestAccumulateAcceptsStdlibOperatorCallableLikePython310()
    {
        multiplied := stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2, 3], stdlib.operator.mul))

        AhkTest.AssertEqual([1, 2, 6], multiplied)
    }

    static TestAccumulateValidatesIterableAtConstructionAndFuncWhenConsumedLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.accumulate(42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.accumulate(42, 99, { initial: 10 })
        )

        values := stdlib.itertools.accumulate([1, 2], 99)
        iterator := values.__Enum(1)
        first := unset

        AhkTest.AssertTrue(iterator(&first))
        AhkTest.AssertEqual(1, first)
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not callable",
            (*) => iterator(&first)
        )

        initialValues := stdlib.itertools.accumulate([1], 99, { initial: 10 })
        initialIterator := initialValues.__Enum(1)
        initialFirst := unset

        AhkTest.AssertTrue(initialIterator(&initialFirst))
        AhkTest.AssertEqual(10, initialFirst)
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not callable",
            (*) => initialIterator(&initialFirst)
        )

        truthValues := stdlib.itertools.accumulate([1, 2], stdlib.operator.truth, { initial: 10 })
        truthIterator := truthValues.__Enum(1)
        truthFirst := unset

        AhkTest.AssertTrue(truthIterator(&truthFirst))
        AhkTest.AssertEqual(10, truthFirst)
        AhkTest.RaisesMatch(
            TypeError,
            "_operator\.truth\(\) takes exactly one argument \(2 given\)",
            (*) => truthIterator(&truthFirst)
        )
    }

    static TestAccumulateRejectsNonIterableAndNonCallableInputsWithPythonTypeNames()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate(42))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate(StdlibItertoolsTest.DemoIterableSource()))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not callable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], 42))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not callable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2], 42, 10))
        )
    }

    static TestAccumulateTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsValuesLikePython310()
    {
        callableIterableProp := stdlib_itertools_test_plain_callable_object("iterable", stdlib_itertools_test_mul)
        callableFuncProp := stdlib_itertools_test_plain_callable_object("func", stdlib_itertools_test_mul)
        callableInitialProp := stdlib_itertools_test_plain_callable_object("initial", stdlib_itertools_test_mul)
        callableExtraProp := stdlib_itertools_test_plain_callable_object("extra", stdlib_itertools_test_mul)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate(callableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate(callableFuncProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate(callableInitialProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.accumulate(callableExtraProp))
        )

        multipliedByIterableProp := stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2, 3], callableIterableProp))
        multipliedByFuncProp := stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2, 3], callableFuncProp))
        multipliedByInitialProp := stdlib_itertools_test_array(stdlib.itertools.accumulate([1, 2, 3], callableInitialProp))

        AhkTest.AssertEqual([1, 2, 6], multipliedByIterableProp)
        AhkTest.AssertEqual([1, 2, 6], multipliedByFuncProp)
        AhkTest.AssertEqual([1, 2, 6], multipliedByInitialProp)

        emptyInitialRows := stdlib_itertools_test_array(stdlib.itertools.accumulate([], unset, callableInitialProp))
        emptyFuncRows := stdlib_itertools_test_array(stdlib.itertools.accumulate([], unset, callableFuncProp))
        emptyIterableRows := stdlib_itertools_test_array(stdlib.itertools.accumulate([], unset, callableIterableProp))
        oneInitialRows := stdlib_itertools_test_array(stdlib.itertools.accumulate([1], (left, right) => left, callableInitialProp))
        oneFuncRows := stdlib_itertools_test_array(stdlib.itertools.accumulate([1], (left, right) => left, callableFuncProp))
        oneIterableRows := stdlib_itertools_test_array(stdlib.itertools.accumulate([1], (left, right) => left, callableIterableProp))

        AhkTest.AssertEqual(1, emptyInitialRows.Length)
        AhkTest.AssertSame(callableInitialProp, emptyInitialRows[1])
        AhkTest.AssertEqual(1, emptyFuncRows.Length)
        AhkTest.AssertSame(callableFuncProp, emptyFuncRows[1])
        AhkTest.AssertEqual(1, emptyIterableRows.Length)
        AhkTest.AssertSame(callableIterableProp, emptyIterableRows[1])

        AhkTest.AssertEqual(2, oneInitialRows.Length)
        AhkTest.AssertSame(callableInitialProp, oneInitialRows[1])
        AhkTest.AssertSame(callableInitialProp, oneInitialRows[2])
        AhkTest.AssertEqual(2, oneFuncRows.Length)
        AhkTest.AssertSame(callableFuncProp, oneFuncRows[1])
        AhkTest.AssertSame(callableFuncProp, oneFuncRows[2])
        AhkTest.AssertEqual(2, oneIterableRows.Length)
        AhkTest.AssertSame(callableIterableProp, oneIterableRows[1])
        AhkTest.AssertSame(callableIterableProp, oneIterableRows[2])
    }

    static TestCycleRepeatsCoveredIterableLikePython()
    {
        values := stdlib.itertools.cycle([1, 2])

        result := stdlib_itertools_test_array(stdlib.itertools.islice(values, 5))

        AhkTest.AssertEqual([1, 2, 1, 2, 1], result)
    }

    static TestCycleAcceptsPlainIterableObjectsWithKeywordLikeOwnPropsLikePython310()
    {
        iterable := stdlib_itertools_test_plain_iterable_object("iterable", [3, 4])
        result := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.cycle(iterable), 5))

        AhkTest.AssertEqual([3, 4, 3, 4, 3], result)
    }

    static TestCycleTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsNonIterableLikePython310()
    {
        callableIterableProp := stdlib_itertools_test_plain_callable_object("iterable", (*) => 1)
        callableExtraProp := stdlib_itertools_test_plain_callable_object("extra", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.cycle(callableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.cycle(callableExtraProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "cycle expected 1 argument, got 2",
            (*) => stdlib.itertools.cycle([1, 2], callableIterableProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "cycle expected 1 argument, got 2",
            (*) => stdlib.itertools.cycle([1, 2], callableExtraProp)
        )
    }

    static TestCycleIteratorKeepsPositionAcrossConsumers()
    {
        values := stdlib.itertools.cycle([1, 2])

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))
        second := stdlib_itertools_test_array(stdlib.itertools.islice(values, 3))

        AhkTest.AssertEqual([1, 2], first)
        AhkTest.AssertEqual([1, 2, 1], second)
    }

    static TestCycleOfEmptyIterableIsEmpty()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.itertools.cycle([]), 3))

        AhkTest.AssertEqual([], result)
    }

    static TestCycleRejectsNonIterableInputsWithPythonTypeNames()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.cycle(42))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'function' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.cycle(StdlibItertoolsTest.DemoTimesFunction))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.cycle(StdlibItertoolsTest.DemoIterableSource()))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'Fraction' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.cycle(stdlib.fractions.Fraction(1, 1)))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'decimal.Decimal' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.cycle(stdlib.decimal.Decimal("1")))
        )
    }

    static TestCycleRejectsNonIterableInputsAtConstructionLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.cycle(42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'function' object is not iterable",
            (*) => stdlib.itertools.cycle(StdlibItertoolsTest.DemoTimesFunction)
        )
    }

    static TestCycleRejectsKeywordAnalogueLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "cycle\(\) takes no keyword arguments",
            (*) => stdlib.itertools.cycle({ iterable: [1, 2] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "cycle\(\) takes no keyword arguments",
            (*) => stdlib.itertools.cycle([1, 2], { iterable: [3, 4] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "cycle\(\) takes no keyword arguments",
            (*) => stdlib.itertools.cycle({ extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "cycle\(\) takes no keyword arguments",
            (*) => stdlib.itertools.cycle({ extra: 1, another: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "cycle\(\) takes no keyword arguments",
            (*) => stdlib.itertools.cycle({ iterable: [1, 2], extra: 1 })
        )
    }

    static TestCycleRejectsDuplicateSplitKeywordAnaloguesLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.cycle({ extra: 1 }, { extra: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.cycle([1, 2], { extra: 1 }, { extra: 2 })
        )
    }

    static TestCycleLateKeywordPriorityMatchesPython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "cycle\(\) takes no keyword arguments",
            (*) => stdlib.itertools.cycle([1, 2], 3, { extra: 1 })
        )
    }

    static TestCycleRejectsInvalidArityLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "cycle expected 1 argument, got 0",
            (*) => stdlib.itertools.cycle()
        )
        AhkTest.RaisesMatch(
            TypeError,
            "cycle expected 1 argument, got 2",
            (*) => stdlib.itertools.cycle([1, 2], 3)
        )
    }

    static TestPairwiseBuildsOverlappingTuplePairsLikePython310()
    {
        values := stdlib.itertools.pairwise([1, 2, 3])
        result := stdlib_itertools_test_array(values)

        AhkTest.AssertEqual(2, result.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(result[1]))
        AhkTest.AssertEqual([2, 3], stdlib_itertools_test_array(result[2]))
    }

    static TestPairwiseReturnsEmptyForShortInputsLikePython310()
    {
        emptyPairs := stdlib_itertools_test_array(stdlib.itertools.pairwise([]))
        singlePairs := stdlib_itertools_test_array(stdlib.itertools.pairwise([1]))

        AhkTest.AssertEqual([], emptyPairs)
        AhkTest.AssertEqual([], singlePairs)
    }

    static TestPairwiseAcceptsStringsAndKeepsIteratorPositionLikePython310()
    {
        values := stdlib.itertools.pairwise("abcd")

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 1))
        second := stdlib_itertools_test_array(values)

        AhkTest.AssertEqual(1, first.Length)
        AhkTest.AssertEqual(["a", "b"], stdlib_itertools_test_array(first[1]))
        AhkTest.AssertEqual(2, second.Length)
        AhkTest.AssertEqual(["b", "c"], stdlib_itertools_test_array(second[1]))
        AhkTest.AssertEqual(["c", "d"], stdlib_itertools_test_array(second[2]))
    }

    static TestPairwiseRejectsNonIterableInputAtConstructionLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.pairwise(42)
        )
    }

    static TestPairwiseTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsPositionalLikePython310()
    {
        callableIterableProp := stdlib_itertools_test_plain_callable_object("iterable", (*) => 1)
        callableExtraProp := stdlib_itertools_test_plain_callable_object("extra", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.pairwise(callableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.pairwise(callableExtraProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "pairwise expected 1 argument, got 2",
            (*) => stdlib.itertools.pairwise([1, 2], callableIterableProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "pairwise expected 1 argument, got 2",
            (*) => stdlib.itertools.pairwise([1, 2], callableExtraProp)
        )
    }

    static TestPairwiseRejectsKeywordStyleOptionsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "pairwise\(\) takes no keyword arguments",
            (*) => stdlib.itertools.pairwise({ iterable: [1, 2] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "pairwise\(\) takes no keyword arguments",
            (*) => stdlib.itertools.pairwise([1, 2], { iterable: [3, 4] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "pairwise\(\) takes no keyword arguments",
            (*) => stdlib.itertools.pairwise({ extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "pairwise\(\) takes no keyword arguments",
            (*) => stdlib.itertools.pairwise({ extra: 1, another: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "pairwise\(\) takes no keyword arguments",
            (*) => stdlib.itertools.pairwise([1, 2], { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "pairwise\(\) takes no keyword arguments",
            (*) => stdlib.itertools.pairwise([1, 2], { extra: 1, another: 2 })
        )
    }

    static TestPairwiseKeywordPriorityMatchesPython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.pairwise({ extra: 1 }, { extra: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "pairwise\(\) takes no keyword arguments",
            (*) => stdlib.itertools.pairwise([1, 2], 3, { extra: 1 })
        )
    }

    static TestPairwiseRejectsExtraPositionalSentinelsAsArityLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "pairwise expected 1 argument, got 2",
            (*) => stdlib.itertools.pairwise([1, 2], stdlib.None)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "pairwise expected 1 argument, got 2",
            (*) => stdlib.itertools.pairwise([1, 2], stdlib.NotImplemented)
        )
    }

    static TestPairwiseRejectsNonIterableInputsWithPythonTypeNames()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'NoneType' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.pairwise(stdlib.None))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'NotImplementedType' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.pairwise(stdlib.NotImplemented))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.pairwise(42))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.pairwise(StdlibItertoolsTest.DemoIterableSource()))
        )
    }

    static TestCombinationsBuildsPythonTupleRowsInLexicographicOrder()
    {
        rows := stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2, 3, 4], 2))

        AhkTest.AssertEqual(6, rows.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(rows[1]))
        AhkTest.AssertEqual([1, 3], stdlib_itertools_test_array(rows[2]))
        AhkTest.AssertEqual([1, 4], stdlib_itertools_test_array(rows[3]))
        AhkTest.AssertEqual([2, 3], stdlib_itertools_test_array(rows[4]))
        AhkTest.AssertEqual([2, 4], stdlib_itertools_test_array(rows[5]))
        AhkTest.AssertEqual([3, 4], stdlib_itertools_test_array(rows[6]))
    }

    static TestCombinationsAcceptsStringsZeroAndOversizedRLikePython310()
    {
        letters := stdlib_itertools_test_array(stdlib.itertools.combinations("abc", 2))
        emptyRow := stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2], 0))
        tooLarge := stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2], 3))
        trueRows := stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2], true))
        falseRows := stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2], false))

        AhkTest.AssertEqual(3, letters.Length)
        AhkTest.AssertEqual(["a", "b"], stdlib_itertools_test_array(letters[1]))
        AhkTest.AssertEqual(["a", "c"], stdlib_itertools_test_array(letters[2]))
        AhkTest.AssertEqual(["b", "c"], stdlib_itertools_test_array(letters[3]))
        AhkTest.AssertEqual(1, emptyRow.Length)
        AhkTest.AssertEqual([], stdlib_itertools_test_array(emptyRow[1]))
        AhkTest.AssertEqual([], tooLarge)
        AhkTest.AssertEqual(2, trueRows.Length)
        AhkTest.AssertEqual([1], stdlib_itertools_test_array(trueRows[1]))
        AhkTest.AssertEqual([2], stdlib_itertools_test_array(trueRows[2]))
        AhkTest.AssertEqual(1, falseRows.Length)
        AhkTest.AssertEqual([], stdlib_itertools_test_array(falseRows[1]))
    }

    static TestCombinationsAcceptsRootBoolRLikePython310()
    {
        trueRows := stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2], stdlib.True))
        falseRows := stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2], stdlib.False))

        AhkTest.AssertEqual(2, trueRows.Length)
        AhkTest.AssertEqual([1], stdlib_itertools_test_array(trueRows[1]))
        AhkTest.AssertEqual([2], stdlib_itertools_test_array(trueRows[2]))
        AhkTest.AssertEqual(1, falseRows.Length)
        AhkTest.AssertEqual([], stdlib_itertools_test_array(falseRows[1]))
    }

    static TestCombinationsAcceptsKeywordAnaloguesLikePython310()
    {
        rKeywordRows := stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2, 3], { r: 2 }))
        bothKeywordRows := stdlib_itertools_test_array(stdlib.itertools.combinations({ iterable: [1, 2, 3], r: 2 }))
        splitKeywordRows := stdlib_itertools_test_array(stdlib.itertools.combinations({ iterable: [1, 2, 3] }, { r: 2 }))
        reversedSplitKeywordRows := stdlib_itertools_test_array(stdlib.itertools.combinations({ r: 2 }, { iterable: [1, 2, 3] }))

        AhkTest.AssertEqual(3, rKeywordRows.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(rKeywordRows[1]))
        AhkTest.AssertEqual([2, 3], stdlib_itertools_test_array(rKeywordRows[3]))
        AhkTest.AssertEqual(3, bothKeywordRows.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(bothKeywordRows[1]))
        AhkTest.AssertEqual([2, 3], stdlib_itertools_test_array(bothKeywordRows[3]))
        AhkTest.AssertEqual(3, splitKeywordRows.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(splitKeywordRows[1]))
        AhkTest.AssertEqual([2, 3], stdlib_itertools_test_array(splitKeywordRows[3]))
        AhkTest.AssertEqual(3, reversedSplitKeywordRows.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(reversedSplitKeywordRows[1]))
        AhkTest.AssertEqual([2, 3], stdlib_itertools_test_array(reversedSplitKeywordRows[3]))
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) missing required argument 'iterable' \(pos 1\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ r: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) missing required argument 'r' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2, 3], { iterable: [4, 5] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) missing required argument 'r' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ iterable: [1, 2], extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) missing required argument 'r' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ extra: 1 }, { iterable: [1, 2] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ iterable: [1, 2], r: 2, extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ r: 2 }, { iterable: [1, 2], extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2, 3], 2, { iterable: [4, 5] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2], { r: 1, extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'str' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.combinations({ iterable: [1, 2], r: "2" })
        )
    }

    static TestCombinationsRejectsOptionsOnlyPropertyObjectsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) missing required argument 'iterable' \(pos 1\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ extra: 1, another: 2, third: 3 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) missing required argument 'r' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ iterable: [1, 2] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ iterable: [1], extra: 1, another: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) missing required argument 'iterable' \(pos 1\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ r: 2, extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) missing required argument 'r' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2], { extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) takes at most 2 arguments \(4 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations([1], { r: 2, extra: 1, another: 2 }))
        )
    }

    static TestCombinationsRejectsDuplicateSplitKeywordsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'iterable'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ iterable: [1, 2, 3] }, { iterable: [4, 5] }, { r: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'r'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ iterable: [1, 2, 3] }, { r: 2 }, { r: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ extra: 1 }, { extra: 2 }))
        )
    }

    static TestCombinationsRejectsThreeWaySplitKeywordPriorityLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ iterable: [1, 2, 3] }, { r: 2 }, { extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations({ extra: 1 }, { extra: 2 }, { iterable: [1, 2, 3] }, { r: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2, 3], { r: 2 }, { extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'r'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations([1, 2, 3], { r: 2 }, { r: 1 }))
        )
    }

    static TestCombinationsTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsPositionalLikePython310()
    {
        callableIterableProp := stdlib_itertools_test_plain_callable_object("iterable", (*) => 1)
        callableRProp := stdlib_itertools_test_plain_callable_object("r", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations(callableIterableProp, 1))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations(callableRProp, 1))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations("ab", callableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations("ab", callableRProp))
        )
    }

    static TestCombinationsAcceptPlainIterableObjectsWithKeywordLikeOwnPropsAsPositionalLikePython310()
    {
        iterableIterableProp := stdlib_itertools_test_plain_iterable_object("iterable", ["a", "b"])
        iterableRProp := stdlib_itertools_test_plain_iterable_object("r", ["a", "b"])
        iterableExtraProp := stdlib_itertools_test_plain_iterable_object("extra", ["a", "b"])

        iterableRows := stdlib_itertools_test_array(stdlib.itertools.combinations(iterableIterableProp, 1))
        rRows := stdlib_itertools_test_array(stdlib.itertools.combinations(iterableRProp, 1))

        AhkTest.AssertEqual(2, iterableRows.Length)
        AhkTest.AssertEqual(["a"], stdlib_itertools_test_array(iterableRows[1]))
        AhkTest.AssertEqual(["b"], stdlib_itertools_test_array(iterableRows[2]))
        AhkTest.AssertEqual(2, rRows.Length)
        AhkTest.AssertEqual(["a"], stdlib_itertools_test_array(rRows[1]))
        AhkTest.AssertEqual(["b"], stdlib_itertools_test_array(rRows[2]))

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations("ab", iterableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations("ab", iterableRProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations("ab", iterableExtraProp))
        )
    }

    static TestCombinationsKeepsIteratorPositionAcrossConsumersLikePython310()
    {
        values := stdlib.itertools.combinations([1, 2, 3, 4], 2)

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))
        second := stdlib_itertools_test_array(values)

        AhkTest.AssertEqual(2, first.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(first[1]))
        AhkTest.AssertEqual([1, 3], stdlib_itertools_test_array(first[2]))
        AhkTest.AssertEqual(4, second.Length)
        AhkTest.AssertEqual([1, 4], stdlib_itertools_test_array(second[1]))
        AhkTest.AssertEqual([2, 3], stdlib_itertools_test_array(second[2]))
        AhkTest.AssertEqual([2, 4], stdlib_itertools_test_array(second[3]))
        AhkTest.AssertEqual([3, 4], stdlib_itertools_test_array(second[4]))
    }

    static TestCombinationsMaterializesSourceWhenConstructedLikePython310()
    {
        source := stdlib.itertools.count(1)
        limited := stdlib.itertools.islice(source, 3)
        combinations := stdlib.itertools.combinations(limited, 2)
        remainingLimited := stdlib_itertools_test_array(limited)

        AhkTest.AssertEqual([], remainingLimited)
        AhkTest.AssertEqual(3, stdlib_itertools_test_array(combinations).Length)
    }

    static TestCombinationsRejectsInvalidArgumentsWithPython310Priority()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'float' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.combinations(42, 2.0)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'str' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.combinations([1, 2], "2")
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'NoneType' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.combinations([1, 2], stdlib.None)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'NotImplementedType' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.combinations([1, 2], stdlib.NotImplemented)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.combinations(42, -1)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib.itertools.combinations(StdlibItertoolsTest.DemoIterableSource(), 1)
        )
        AhkTest.RaisesMatch(
            ValueError,
            "r must be non-negative",
            (*) => stdlib.itertools.combinations([1, 2], -1)
        )
    }

    static TestProductBuildsPythonTupleRowsInLexicographicOrder()
    {
        rows := stdlib_itertools_test_array(stdlib.itertools.product([1, 2], "ab"))

        AhkTest.AssertEqual(4, rows.Length)
        AhkTest.AssertEqual([1, "a"], stdlib_itertools_test_array(rows[1]))
        AhkTest.AssertEqual([1, "b"], stdlib_itertools_test_array(rows[2]))
        AhkTest.AssertEqual([2, "a"], stdlib_itertools_test_array(rows[3]))
        AhkTest.AssertEqual([2, "b"], stdlib_itertools_test_array(rows[4]))
    }

    static TestProductAcceptsNoArgsSingleIterableAndEmptyPoolsLikePython310()
    {
        noArgs := stdlib_itertools_test_array(stdlib.itertools.product())
        singleRows := stdlib_itertools_test_array(stdlib.itertools.product([1, 2]))
        emptyFirst := stdlib_itertools_test_array(stdlib.itertools.product([], [1, 2]))
        emptySecond := stdlib_itertools_test_array(stdlib.itertools.product([1, 2], []))
        threePools := stdlib_itertools_test_array(stdlib.itertools.product([1], [2], [3]))

        AhkTest.AssertEqual(1, noArgs.Length)
        AhkTest.AssertEqual([], stdlib_itertools_test_array(noArgs[1]))
        AhkTest.AssertEqual(2, singleRows.Length)
        AhkTest.AssertEqual([1], stdlib_itertools_test_array(singleRows[1]))
        AhkTest.AssertEqual([2], stdlib_itertools_test_array(singleRows[2]))
        AhkTest.AssertEqual([], emptyFirst)
        AhkTest.AssertEqual([], emptySecond)
        AhkTest.AssertEqual(1, threePools.Length)
        AhkTest.AssertEqual([1, 2, 3], stdlib_itertools_test_array(threePools[1]))
    }

    static TestProductAcceptsRepeatOptionLikePython310()
    {
        rows := stdlib_itertools_test_array(stdlib.itertools.product([1, 2], { repeat: 2 }))
        zeroRows := stdlib_itertools_test_array(stdlib.itertools.product([1, 2], { repeat: 0 }))
        rootTrueRows := stdlib_itertools_test_array(stdlib.itertools.product([1, 2], { repeat: stdlib.True }))
        rootFalseRows := stdlib_itertools_test_array(stdlib.itertools.product([1, 2], { repeat: stdlib.False }))

        AhkTest.AssertEqual(4, rows.Length)
        AhkTest.AssertEqual([1, 1], stdlib_itertools_test_array(rows[1]))
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(rows[2]))
        AhkTest.AssertEqual([2, 1], stdlib_itertools_test_array(rows[3]))
        AhkTest.AssertEqual([2, 2], stdlib_itertools_test_array(rows[4]))
        AhkTest.AssertEqual(1, zeroRows.Length)
        AhkTest.AssertEqual([], stdlib_itertools_test_array(zeroRows[1]))
        AhkTest.AssertEqual(2, rootTrueRows.Length)
        AhkTest.AssertEqual([1], stdlib_itertools_test_array(rootTrueRows[1]))
        AhkTest.AssertEqual(1, rootFalseRows.Length)
        AhkTest.AssertEqual([], stdlib_itertools_test_array(rootFalseRows[1]))
        AhkTest.RaisesMatch(
            TypeError,
            "product\(\) takes at most 1 keyword argument \(2 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.product([1, 2], { repeat: 2, iterables: "x" }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'iterables' is an invalid keyword argument for product\(\)",
            (*) => stdlib.itertools.product({ iterables: "x" })
        )
    }

    static TestProductRejectsInvalidRepeatOptionLikePython310()
    {
        AhkTest.RaisesMatch(
            ValueError,
            "repeat argument cannot be negative",
            (*) => stdlib.itertools.product([1], { repeat: -1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'float' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.product([1], { repeat: 2.0 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'str' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.product([1], { repeat: "2" })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'NoneType' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.product([1], { repeat: stdlib.None })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'NotImplementedType' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.product([1], { repeat: stdlib.NotImplemented })
        )
    }

    static TestProductRejectsGenericKeywordStyleOptionsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for product\(\)",
            (*) => stdlib.itertools.product({ extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for product\(\)",
            (*) => stdlib.itertools.product([1], { extra: 1 })
        )
    }

    static TestProductRejectsSplitTrailingKeywordAnaloguesLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "product\(\) takes at most 1 keyword argument \(2 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.product([1], { repeat: 2 }, { extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "product\(\) takes at most 1 keyword argument \(2 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.product({ repeat: 2 }, { extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "product\(\) takes at most 1 keyword argument \(2 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.product([1], { extra: 1 }, { repeat: 2 }))
        )
    }

    static TestProductRejectsDuplicateSplitTrailingKeywordsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'repeat'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.product([1], { repeat: 2 }, { repeat: 3 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'repeat'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.product({ repeat: 2 }, { repeat: 3 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.product([1], { extra: 1 }, { extra: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.product({ extra: 1 }, { extra: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'repeat'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.product([1], { repeat: 2 }, { repeat: 3 }, { extra: 1 }))
        )
    }

    static TestProductTreatsRepeatPropertyIterablesAsInputs()
    {
        rows := stdlib_itertools_test_array(stdlib.itertools.product([1], StdlibItertoolsTest.DemoRepeatIterable()))

        AhkTest.AssertEqual(2, rows.Length)
        AhkTest.AssertEqual([1, "a"], stdlib_itertools_test_array(rows[1]))
        AhkTest.AssertEqual([1, "b"], stdlib_itertools_test_array(rows[2]))
    }

    static TestProductAcceptsPlainIterableObjectsWithRepeatLikeOwnPropsLikePython310()
    {
        iterable := stdlib_itertools_test_plain_iterable_object("repeat", [7, 8])
        rows := stdlib_itertools_test_array(stdlib.itertools.product([1], iterable))

        AhkTest.AssertEqual(2, rows.Length)
        AhkTest.AssertEqual([1, 7], stdlib_itertools_test_array(rows[1]))
        AhkTest.AssertEqual([1, 8], stdlib_itertools_test_array(rows[2]))
    }

    static TestProductTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsPositionalLikePython310()
    {
        callableRepeatProp := stdlib_itertools_test_plain_callable_object("repeat", (*) => 1)
        callableIterablesProp := stdlib_itertools_test_plain_callable_object("iterables", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.product(callableRepeatProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.product(callableIterablesProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.product([1], callableRepeatProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.product([1], callableIterablesProp))
        )
    }

    static TestProductKeepsIteratorPositionAcrossConsumersLikePython310()
    {
        values := stdlib.itertools.product([1, 2], "ab")

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))
        second := stdlib_itertools_test_array(values)

        AhkTest.AssertEqual(2, first.Length)
        AhkTest.AssertEqual([1, "a"], stdlib_itertools_test_array(first[1]))
        AhkTest.AssertEqual([1, "b"], stdlib_itertools_test_array(first[2]))
        AhkTest.AssertEqual(2, second.Length)
        AhkTest.AssertEqual([2, "a"], stdlib_itertools_test_array(second[1]))
        AhkTest.AssertEqual([2, "b"], stdlib_itertools_test_array(second[2]))
    }

    static TestProductMaterializesSourcesWhenConstructedLikePython310()
    {
        firstSource := stdlib.itertools.count(1)
        firstLimited := stdlib.itertools.islice(firstSource, 2)
        secondSource := stdlib.itertools.count(10)
        secondLimited := stdlib.itertools.islice(secondSource, 2)
        rows := stdlib.itertools.product(firstLimited, secondLimited)
        remainingFirst := stdlib_itertools_test_array(firstLimited)
        remainingSecond := stdlib_itertools_test_array(secondLimited)

        AhkTest.AssertEqual([], remainingFirst)
        AhkTest.AssertEqual([], remainingSecond)
        AhkTest.AssertEqual(4, stdlib_itertools_test_array(rows).Length)
    }

    static TestProductRejectsNonIterableInputsWithPythonTypeNames()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.product(42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.product([1], 42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'function' object is not iterable",
            (*) => stdlib.itertools.product(StdlibItertoolsTest.DemoTimesFunction)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib.itertools.product(StdlibItertoolsTest.DemoIterableSource())
        )
    }

    static TestZipLongestBuildsTupleRowsWithDefaultNoneFillLikePython310()
    {
        rows := stdlib_itertools_test_array(stdlib.itertools.zip_longest([1, 2, 3], "ab"))

        AhkTest.AssertEqual(3, rows.Length)
        AhkTest.AssertEqual([1, "a"], stdlib_itertools_test_array(rows[1]))
        AhkTest.AssertEqual([2, "b"], stdlib_itertools_test_array(rows[2]))
        AhkTest.AssertEqual([3, stdlib.None], stdlib_itertools_test_array(rows[3]))
    }

    static TestZipLongestAcceptsFillvalueOptionLikePython310()
    {
        rows := stdlib_itertools_test_array(stdlib.itertools.zip_longest([1, 2, 3], "ab", { fillvalue: "X" }))
        AhkTest.RaisesMatch(
            TypeError,
            "zip_longest\(\) got an unexpected keyword argument",
            (*) => stdlib_itertools_test_array(stdlib.itertools.zip_longest([1, 2], [3], { fillvalue: "X", iterables: "Y" }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "zip_longest\(\) got an unexpected keyword argument",
            (*) => stdlib.itertools.zip_longest({ iterables: "x" })
        )

        AhkTest.AssertEqual(3, rows.Length)
        AhkTest.AssertEqual([1, "a"], stdlib_itertools_test_array(rows[1]))
        AhkTest.AssertEqual([2, "b"], stdlib_itertools_test_array(rows[2]))
        AhkTest.AssertEqual([3, "X"], stdlib_itertools_test_array(rows[3]))
    }

    static TestZipLongestRejectsGenericKeywordStyleOptionsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "zip_longest\(\) got an unexpected keyword argument",
            (*) => stdlib.itertools.zip_longest({ extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "zip_longest\(\) got an unexpected keyword argument",
            (*) => stdlib.itertools.zip_longest([1], { extra: 1 })
        )
    }

    static TestZipLongestRejectsSplitTrailingKeywordAnaloguesLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "zip_longest\(\) got an unexpected keyword argument",
            (*) => stdlib_itertools_test_array(stdlib.itertools.zip_longest([1], { fillvalue: "X" }, { extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "zip_longest\(\) got an unexpected keyword argument",
            (*) => stdlib_itertools_test_array(stdlib.itertools.zip_longest({ fillvalue: "X" }, { extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "zip_longest\(\) got an unexpected keyword argument",
            (*) => stdlib_itertools_test_array(stdlib.itertools.zip_longest([1], { extra: 1 }, { fillvalue: "X" }))
        )
    }

    static TestZipLongestRejectsDuplicateSplitTrailingKeywordsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'fillvalue'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.zip_longest([1], { fillvalue: "X" }, { fillvalue: "Y" }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'fillvalue'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.zip_longest({ fillvalue: "X" }, { fillvalue: "Y" }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.zip_longest([1], { extra: 1 }, { extra: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.zip_longest({ extra: 1 }, { extra: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'fillvalue'",
            (*) => stdlib_itertools_test_array(stdlib.itertools.zip_longest([1], { fillvalue: "X" }, { fillvalue: "Y" }, { extra: 1 }))
        )
    }

    static TestZipLongestTreatsFillvaluePropertyIterablesAsInputs()
    {
        rows := stdlib_itertools_test_array(stdlib.itertools.zip_longest([1], StdlibItertoolsTest.DemoFillvalueIterable()))

        AhkTest.AssertEqual(2, rows.Length)
        AhkTest.AssertEqual([1, "a"], stdlib_itertools_test_array(rows[1]))
        AhkTest.AssertEqual([stdlib.None, "b"], stdlib_itertools_test_array(rows[2]))
    }

    static TestZipLongestAcceptsPlainIterableObjectsWithFillvalueLikeOwnPropsLikePython310()
    {
        iterable := stdlib_itertools_test_plain_iterable_object("fillvalue", ["a", "b"])
        rows := stdlib_itertools_test_array(stdlib.itertools.zip_longest([1], iterable))

        AhkTest.AssertEqual(2, rows.Length)
        AhkTest.AssertEqual([1, "a"], stdlib_itertools_test_array(rows[1]))
        AhkTest.AssertEqual([stdlib.None, "b"], stdlib_itertools_test_array(rows[2]))
    }

    static TestZipLongestTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsPositionalLikePython310()
    {
        callableFillvalueProp := stdlib_itertools_test_plain_callable_object("fillvalue", (*) => 1)
        callableIterablesProp := stdlib_itertools_test_plain_callable_object("iterables", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.zip_longest(callableFillvalueProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.zip_longest(callableIterablesProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.zip_longest([1], callableFillvalueProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.zip_longest([1], callableIterablesProp))
        )
    }

    static TestZipLongestAcceptsNoArgsSingleIterableAndEmptyInputsLikePython310()
    {
        noArgs := stdlib_itertools_test_array(stdlib.itertools.zip_longest())
        singleRows := stdlib_itertools_test_array(stdlib.itertools.zip_longest([1, 2]))
        emptyFirst := stdlib_itertools_test_array(stdlib.itertools.zip_longest([], [1, 2]))
        emptyBoth := stdlib_itertools_test_array(stdlib.itertools.zip_longest([], []))
        threeInputs := stdlib_itertools_test_array(stdlib.itertools.zip_longest([1], [2], [3, 4]))

        AhkTest.AssertEqual([], noArgs)
        AhkTest.AssertEqual(2, singleRows.Length)
        AhkTest.AssertEqual([1], stdlib_itertools_test_array(singleRows[1]))
        AhkTest.AssertEqual([2], stdlib_itertools_test_array(singleRows[2]))
        AhkTest.AssertEqual(2, emptyFirst.Length)
        AhkTest.AssertEqual([stdlib.None, 1], stdlib_itertools_test_array(emptyFirst[1]))
        AhkTest.AssertEqual([stdlib.None, 2], stdlib_itertools_test_array(emptyFirst[2]))
        AhkTest.AssertEqual([], emptyBoth)
        AhkTest.AssertEqual(2, threeInputs.Length)
        AhkTest.AssertEqual([1, 2, 3], stdlib_itertools_test_array(threeInputs[1]))
        AhkTest.AssertEqual([stdlib.None, stdlib.None, 4], stdlib_itertools_test_array(threeInputs[2]))
    }

    static TestZipLongestKeepsIteratorPositionAcrossConsumersLikePython310()
    {
        values := stdlib.itertools.zip_longest([1, 2], "abc")

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))
        second := stdlib_itertools_test_array(values)

        AhkTest.AssertEqual(2, first.Length)
        AhkTest.AssertEqual([1, "a"], stdlib_itertools_test_array(first[1]))
        AhkTest.AssertEqual([2, "b"], stdlib_itertools_test_array(first[2]))
        AhkTest.AssertEqual(1, second.Length)
        AhkTest.AssertEqual([stdlib.None, "c"], stdlib_itertools_test_array(second[1]))
    }

    static TestZipLongestDoesNotMaterializeSourcesWhenConstructedLikePython310()
    {
        firstSource := stdlib.itertools.count(1)
        firstLimited := stdlib.itertools.islice(firstSource, 2)
        secondSource := stdlib.itertools.count(10)
        secondLimited := stdlib.itertools.islice(secondSource, 3)
        rows := stdlib.itertools.zip_longest(firstLimited, secondLimited)
        remainingFirstBeforeConsumption := stdlib_itertools_test_array(firstLimited)
        remainingSecondBeforeConsumption := stdlib_itertools_test_array(secondLimited)

        AhkTest.AssertEqual([1, 2], remainingFirstBeforeConsumption)
        AhkTest.AssertEqual([10, 11, 12], remainingSecondBeforeConsumption)
        AhkTest.AssertEqual(0, stdlib_itertools_test_array(rows).Length)
    }

    static TestZipLongestRejectsNonIterableInputsWithPythonTypeNames()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.zip_longest(42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.zip_longest([1], 42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'function' object is not iterable",
            (*) => stdlib.itertools.zip_longest(StdlibItertoolsTest.DemoTimesFunction)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib.itertools.zip_longest(StdlibItertoolsTest.DemoIterableSource())
        )
    }

    static TestGroupbyBuildsConsecutiveGroupsWithIdentityKeyLikePython310()
    {
        groups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby("aaabbcaa"))

        AhkTest.AssertEqual(4, groups.Length)
        AhkTest.AssertEqual(["a", ["a", "a", "a"]], groups[1])
        AhkTest.AssertEqual(["b", ["b", "b"]], groups[2])
        AhkTest.AssertEqual(["c", ["c"]], groups[3])
        AhkTest.AssertEqual(["a", ["a", "a"]], groups[4])
    }

    static TestGroupbyAcceptsCallableAndExplicitNoneKeysLikePython310()
    {
        callableGroups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby(["ab", "ac", "ba", "bb", "ac"], stdlib_itertools_test_first_char))
        noneGroups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby([1, 1, 2], stdlib.None))
        emptyGroups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby([]))

        AhkTest.AssertEqual(3, callableGroups.Length)
        AhkTest.AssertEqual(["a", ["ab", "ac"]], callableGroups[1])
        AhkTest.AssertEqual(["b", ["ba", "bb"]], callableGroups[2])
        AhkTest.AssertEqual(["a", ["ac"]], callableGroups[3])
        AhkTest.AssertEqual(2, noneGroups.Length)
        AhkTest.AssertEqual([1, [1, 1]], noneGroups[1])
        AhkTest.AssertEqual([2, [2]], noneGroups[2])
        AhkTest.AssertEqual([], emptyGroups)
    }

    static TestGroupbyAcceptsKeyOptionLikePython310()
    {
        callableGroups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby(["ab", "ac", "ba", "bb", "ac"], { key: stdlib_itertools_test_first_char }))
        noneGroups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby([1, 1, 2], { key: stdlib.None }))
        operatorGroups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby(["ab", "ac", "ba"], { key: stdlib.operator.itemgetter(0) }))

        AhkTest.AssertEqual(3, callableGroups.Length)
        AhkTest.AssertEqual(["a", ["ab", "ac"]], callableGroups[1])
        AhkTest.AssertEqual(["b", ["ba", "bb"]], callableGroups[2])
        AhkTest.AssertEqual(["a", ["ac"]], callableGroups[3])
        AhkTest.AssertEqual([["a", ["ab", "ac"]], ["b", ["ba"]]], operatorGroups)
        AhkTest.AssertEqual(2, noneGroups.Length)
        AhkTest.AssertEqual([1, [1, 1]], noneGroups[1])
        AhkTest.AssertEqual([2, [2]], noneGroups[2])
        AhkTest.RaisesMatch(
            TypeError,
            "groupby\(\) missing required argument 'iterable' \(pos 1\)",
            (*) => stdlib.itertools.groupby({ key: stdlib_itertools_test_first_char })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for groupby\(\)",
            (*) => stdlib.itertools.groupby({ iterable: "aab", extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "groupby\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.groupby({ iterable: "aab", key: stdlib.None, extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "groupby\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib.itertools.groupby(["ab", "ac"], stdlib_itertools_test_first_char, { key: stdlib_itertools_test_first_char })
        )
    }

    static TestGroupbyAcceptsIterableKeywordAnalogueLikePython310()
    {
        identityGroups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby({ iterable: "aab" }))
        callableGroups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby({ iterable: ["ab", "ac", "ba"], key: stdlib_itertools_test_first_char }))
        splitCallableGroups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby({ key: stdlib_itertools_test_first_char }, { iterable: ["ab", "ac", "ba"] }))

        AhkTest.AssertEqual([["a", ["a", "a"]], ["b", ["b"]]], identityGroups)
        AhkTest.AssertEqual([["a", ["ab", "ac"]], ["b", ["ba"]]], callableGroups)
        AhkTest.AssertEqual([["a", ["ab", "ac"]], ["b", ["ba"]]], splitCallableGroups)
    }

    static TestGroupbyRejectsOptionsOnlyPropertyObjectsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "groupby\(\) missing required argument 'iterable' \(pos 1\)",
            (*) => stdlib.itertools.groupby({ extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for groupby\(\)",
            (*) => stdlib.itertools.groupby(["ab"], { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "argument for groupby\(\) given by name \('iterable'\) and position \(1\)",
            (*) => stdlib.itertools.groupby(["ab"], { iterable: "x" })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "groupby\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib.itertools.groupby(["ab"], { key: stdlib_itertools_test_first_char, extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for groupby\(\)",
            (*) => stdlib.itertools.groupby({ extra: 1 }, { iterable: "aab" })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "groupby\(\) missing required argument 'iterable' \(pos 1\)",
            (*) => stdlib.itertools.groupby({ key: stdlib_itertools_test_first_char }, { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "groupby\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.groupby({ key: stdlib_itertools_test_first_char }, { iterable: "aab", extra: 1 })
        )
    }

    static TestGroupbyRejectsDuplicateSplitKeywordsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'iterable'",
            (*) => stdlib.itertools.groupby({ iterable: "aab" }, { iterable: "bbc" })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'key'",
            (*) => stdlib.itertools.groupby({ iterable: ["ab", "ac"] }, { key: stdlib_itertools_test_first_char }, { key: stdlib.None })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.groupby({ extra: 1 }, { extra: 2 })
        )
    }

    static TestGroupbyRejectsThreeWaySplitKeywordPriorityLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "groupby\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib.itertools.groupby({ iterable: "aab" }, { key: stdlib_itertools_test_first_char }, { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.groupby({ extra: 1 }, { extra: 2 }, { iterable: "aab" })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "groupby\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib.itertools.groupby("aab", { key: stdlib_itertools_test_first_char }, { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'key'",
            (*) => stdlib.itertools.groupby("aab", { key: stdlib_itertools_test_first_char }, { key: stdlib.None })
        )
    }

    static TestGroupbyAcceptsStdlibOperatorCallableLikePython310()
    {
        groups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby([0, 1, 0], stdlib.operator.truth))

        AhkTest.AssertEqual([[false, [0]], [true, [1]], [false, [0]]], groups)
    }

    static TestGroupbyTreatsKeyPropertyCallablesAsKeyFunctions()
    {
        callableGroups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby(["ab", "ac", "ba"], StdlibItertoolsTest.DemoKeyCallable()))

        AhkTest.AssertEqual(2, callableGroups.Length)
        AhkTest.AssertEqual(["a", ["ab", "ac"]], callableGroups[1])
        AhkTest.AssertEqual(["b", ["ba"]], callableGroups[2])
    }

    static TestGroupbyTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsPositionalLikePython310()
    {
        callableIterableProp := stdlib_itertools_test_plain_callable_object("iterable", (*) => 1)
        callableKeyProp := stdlib_itertools_test_plain_callable_object("key", (*) => 1)
        callableExtraProp := stdlib_itertools_test_plain_callable_object("extra", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby(callableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby(callableKeyProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby(callableExtraProp))
        )

        iterablePropGroups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby("ab", callableIterableProp))
        keyPropGroups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby("ab", callableKeyProp))
        extraPropGroups := stdlib_itertools_test_groupby_pairs(stdlib.itertools.groupby("ab", callableExtraProp))

        AhkTest.AssertEqual([[1, ["a", "b"]]], iterablePropGroups)
        AhkTest.AssertEqual([[1, ["a", "b"]]], keyPropGroups)
        AhkTest.AssertEqual([[1, ["a", "b"]]], extraPropGroups)
    }

    static TestGroupbyTreatsPlainIterableObjectsWithKeywordLikeOwnPropsAsPositionalKeyValuesLikePython310()
    {
        iterableKeyProp := stdlib_itertools_test_plain_iterable_object("key", ["a", "b"])
        iterableIterableProp := stdlib_itertools_test_plain_iterable_object("iterable", ["a", "b"])
        iterableExtraProp := stdlib_itertools_test_plain_iterable_object("extra", ["a", "b"])

        groupsWithKeyProp := stdlib.itertools.groupby(["ab", "ac"], iterableKeyProp)
        groupsWithIterableProp := stdlib.itertools.groupby(["ab", "ac"], iterableIterableProp)
        groupsWithExtraProp := stdlib.itertools.groupby(["ab", "ac"], iterableExtraProp)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not callable",
            (*) => stdlib_itertools_test_groupby_pairs(groupsWithKeyProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not callable",
            (*) => stdlib_itertools_test_groupby_pairs(groupsWithIterableProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not callable",
            (*) => stdlib_itertools_test_groupby_pairs(groupsWithExtraProp)
        )
    }

    static TestGroupbyDoesNotMaterializeSourceWhenConstructedLikePython310()
    {
        source := stdlib.itertools.count(1)
        limited := stdlib.itertools.islice(source, 3)
        groups := stdlib.itertools.groupby(limited)
        remainingBeforeConsumption := stdlib_itertools_test_array(limited)

        AhkTest.AssertEqual([1, 2, 3], remainingBeforeConsumption)
        AhkTest.AssertEqual([], stdlib_itertools_test_groupby_pairs(groups))
    }

    static TestGroupbyGroupIteratorSharesSourceWithOuterIteratorLikePython310()
    {
        groups := stdlib.itertools.groupby([1, 1, 2, 2, 3])
        outer := groups.__Enum(1)

        firstPair := unset
        AhkTest.AssertTrue(outer(&firstPair))
        firstRow := stdlib_itertools_test_array(firstPair)
        firstGroup := firstRow[2]
        firstGroupIterator := firstGroup.__Enum(1)
        firstItem := unset
        AhkTest.AssertTrue(firstGroupIterator(&firstItem))

        secondPair := unset
        AhkTest.AssertTrue(outer(&secondPair))
        secondRow := stdlib_itertools_test_array(secondPair)

        AhkTest.AssertEqual(1, firstRow[1])
        AhkTest.AssertEqual(1, firstItem)
        AhkTest.AssertEqual(2, secondRow[1])
        AhkTest.AssertEqual([], stdlib_itertools_test_array(firstGroup))
        AhkTest.AssertEqual([2, 2], stdlib_itertools_test_array(secondRow[2]))
    }

    static TestGroupbyRejectsInvalidInputsWithPython310Timing()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.groupby(42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib.itertools.groupby(StdlibItertoolsTest.DemoIterableSource())
        )
        badKeyGroups := stdlib.itertools.groupby([1, 1], 42)
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not callable",
            (*) => stdlib_itertools_test_groupby_pairs(badKeyGroups)
        )
        badOptionKeyGroups := stdlib.itertools.groupby([1, 1], { key: 42 })
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not callable",
            (*) => stdlib_itertools_test_groupby_pairs(badOptionKeyGroups)
        )
    }

    static TestPermutationsBuildsPythonTupleRowsInLexicographicOrder()
    {
        rows := stdlib_itertools_test_array(stdlib.itertools.permutations([1, 2, 3], 2))

        AhkTest.AssertEqual(6, rows.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(rows[1]))
        AhkTest.AssertEqual([1, 3], stdlib_itertools_test_array(rows[2]))
        AhkTest.AssertEqual([2, 1], stdlib_itertools_test_array(rows[3]))
        AhkTest.AssertEqual([2, 3], stdlib_itertools_test_array(rows[4]))
        AhkTest.AssertEqual([3, 1], stdlib_itertools_test_array(rows[5]))
        AhkTest.AssertEqual([3, 2], stdlib_itertools_test_array(rows[6]))
    }

    static TestPermutationsRejectsInvalidKeywordPriorityLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for permutations\(\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations({ iterable: [1, 2], extra: 1 }))
        )
    }

    static TestPermutationsAcceptsDefaultNoneZeroOversizedAndBoolRLikePython310()
    {
        defaultRows := stdlib_itertools_test_array(stdlib.itertools.permutations([1, 2, 3]))
        noneRows := stdlib_itertools_test_array(stdlib.itertools.permutations([1, 2], stdlib.None))
        letters := stdlib_itertools_test_array(stdlib.itertools.permutations("abc", 2))
        emptyRow := stdlib_itertools_test_array(stdlib.itertools.permutations([1, 2], 0))
        tooLarge := stdlib_itertools_test_array(stdlib.itertools.permutations([1, 2], 3))
        trueRows := stdlib_itertools_test_array(stdlib.itertools.permutations([1, 2], true))
        falseRows := stdlib_itertools_test_array(stdlib.itertools.permutations([1, 2], false))

        AhkTest.AssertEqual(6, defaultRows.Length)
        AhkTest.AssertEqual([1, 2, 3], stdlib_itertools_test_array(defaultRows[1]))
        AhkTest.AssertEqual([3, 2, 1], stdlib_itertools_test_array(defaultRows[6]))
        AhkTest.AssertEqual(2, noneRows.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(noneRows[1]))
        AhkTest.AssertEqual([2, 1], stdlib_itertools_test_array(noneRows[2]))
        AhkTest.AssertEqual(6, letters.Length)
        AhkTest.AssertEqual(["a", "b"], stdlib_itertools_test_array(letters[1]))
        AhkTest.AssertEqual(["c", "b"], stdlib_itertools_test_array(letters[6]))
        AhkTest.AssertEqual(1, emptyRow.Length)
        AhkTest.AssertEqual([], stdlib_itertools_test_array(emptyRow[1]))
        AhkTest.AssertEqual([], tooLarge)
        AhkTest.AssertEqual(2, trueRows.Length)
        AhkTest.AssertEqual([1], stdlib_itertools_test_array(trueRows[1]))
        AhkTest.AssertEqual([2], stdlib_itertools_test_array(trueRows[2]))
        AhkTest.AssertEqual(1, falseRows.Length)
        AhkTest.AssertEqual([], stdlib_itertools_test_array(falseRows[1]))
    }

    static TestPermutationsAcceptsRootBoolRLikePython310()
    {
        trueRows := stdlib_itertools_test_array(stdlib.itertools.permutations([1, 2], stdlib.True))
        falseRows := stdlib_itertools_test_array(stdlib.itertools.permutations([1, 2], stdlib.False))

        AhkTest.AssertEqual(2, trueRows.Length)
        AhkTest.AssertEqual([1], stdlib_itertools_test_array(trueRows[1]))
        AhkTest.AssertEqual([2], stdlib_itertools_test_array(trueRows[2]))
        AhkTest.AssertEqual(1, falseRows.Length)
        AhkTest.AssertEqual([], stdlib_itertools_test_array(falseRows[1]))
    }

    static TestPermutationsAcceptsKeywordAnaloguesLikePython310()
    {
        rKeywordRows := stdlib_itertools_test_array(stdlib.itertools.permutations([1, 2, 3], { r: 2 }))
        bothKeywordRows := stdlib_itertools_test_array(stdlib.itertools.permutations({ iterable: [1, 2, 3], r: 2 }))
        splitKeywordRows := stdlib_itertools_test_array(stdlib.itertools.permutations({ iterable: [1, 2, 3] }, { r: 2 }))
        reversedSplitKeywordRows := stdlib_itertools_test_array(stdlib.itertools.permutations({ r: 2 }, { iterable: [1, 2, 3] }))

        AhkTest.AssertEqual(6, rKeywordRows.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(rKeywordRows[1]))
        AhkTest.AssertEqual([3, 2], stdlib_itertools_test_array(rKeywordRows[6]))
        AhkTest.AssertEqual(6, bothKeywordRows.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(bothKeywordRows[1]))
        AhkTest.AssertEqual([3, 2], stdlib_itertools_test_array(bothKeywordRows[6]))
        AhkTest.AssertEqual(6, splitKeywordRows.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(splitKeywordRows[1]))
        AhkTest.AssertEqual([3, 2], stdlib_itertools_test_array(splitKeywordRows[6]))
        AhkTest.AssertEqual(6, reversedSplitKeywordRows.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(reversedSplitKeywordRows[1]))
        AhkTest.AssertEqual([3, 2], stdlib_itertools_test_array(reversedSplitKeywordRows[6]))
        AhkTest.RaisesMatch(
            TypeError,
            "permutations\(\) missing required argument 'iterable' \(pos 1\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations({ r: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for permutations\(\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations({ extra: 1 }, { iterable: [1, 2, 3] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for permutations\(\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations({ iterable: [1, 2, 3] }, { extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "permutations\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations({ r: 2 }, { iterable: [1, 2, 3], extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "argument for permutations\(\) given by name \('iterable'\) and position \(1\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations([1, 2, 3], { iterable: [4, 5] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "permutations\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations([1, 2, 3], 2, { iterable: [4, 5] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "permutations\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations([1, 2], { r: 1, extra: 1 }))
        )

        AhkTest.RaisesMatch(
            TypeError,
            "Expected int as r",
            (*) => stdlib.itertools.permutations({ iterable: [1, 2], r: "2" })
        )
    }

    static TestPermutationsRejectsOptionsOnlyPropertyObjectsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "permutations\(\) missing required argument 'iterable' \(pos 1\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations({ extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "permutations\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations({ extra: 1, another: 2, third: 3 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "permutations\(\) missing required argument 'iterable' \(pos 1\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations({ r: 2, extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'extra' is an invalid keyword argument for permutations\(\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations([1], { extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "argument for permutations\(\) given by name \('iterable'\) and position \(1\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations([1], { iterable: [3, 4] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "permutations\(\) takes at most 2 arguments \(4 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations([1], { r: 2, extra: 1, another: 2 }))
        )
    }

    static TestPermutationsTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsPositionalLikePython310()
    {
        callableIterableProp := stdlib_itertools_test_plain_callable_object("iterable", (*) => 1)
        callableRProp := stdlib_itertools_test_plain_callable_object("r", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations(callableIterableProp, 1))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations(callableRProp, 1))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "Expected int as r",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations("ab", callableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "Expected int as r",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations("ab", callableRProp))
        )
    }

    static TestPermutationsAcceptPlainIterableObjectsWithKeywordLikeOwnPropsAsPositionalLikePython310()
    {
        iterableIterableProp := stdlib_itertools_test_plain_iterable_object("iterable", ["a", "b"])
        iterableRProp := stdlib_itertools_test_plain_iterable_object("r", ["a", "b"])
        iterableExtraProp := stdlib_itertools_test_plain_iterable_object("extra", ["a", "b"])

        iterableRows := stdlib_itertools_test_array(stdlib.itertools.permutations(iterableIterableProp, 1))
        rRows := stdlib_itertools_test_array(stdlib.itertools.permutations(iterableRProp, 1))

        AhkTest.AssertEqual(2, iterableRows.Length)
        AhkTest.AssertEqual(["a"], stdlib_itertools_test_array(iterableRows[1]))
        AhkTest.AssertEqual(["b"], stdlib_itertools_test_array(iterableRows[2]))
        AhkTest.AssertEqual(2, rRows.Length)
        AhkTest.AssertEqual(["a"], stdlib_itertools_test_array(rRows[1]))
        AhkTest.AssertEqual(["b"], stdlib_itertools_test_array(rRows[2]))

        AhkTest.RaisesMatch(
            TypeError,
            "Expected int as r",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations("ab", iterableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "Expected int as r",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations("ab", iterableRProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "Expected int as r",
            (*) => stdlib_itertools_test_array(stdlib.itertools.permutations("ab", iterableExtraProp))
        )
    }

    static TestPermutationsKeepsIteratorPositionAcrossConsumersLikePython310()
    {
        values := stdlib.itertools.permutations([1, 2, 3], 2)

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))
        second := stdlib_itertools_test_array(values)

        AhkTest.AssertEqual(2, first.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(first[1]))
        AhkTest.AssertEqual([1, 3], stdlib_itertools_test_array(first[2]))
        AhkTest.AssertEqual(4, second.Length)
        AhkTest.AssertEqual([2, 1], stdlib_itertools_test_array(second[1]))
        AhkTest.AssertEqual([2, 3], stdlib_itertools_test_array(second[2]))
        AhkTest.AssertEqual([3, 1], stdlib_itertools_test_array(second[3]))
        AhkTest.AssertEqual([3, 2], stdlib_itertools_test_array(second[4]))
    }

    static TestPermutationsMaterializesSourceWhenConstructedLikePython310()
    {
        source := stdlib.itertools.count(1)
        limited := stdlib.itertools.islice(source, 3)
        permutations := stdlib.itertools.permutations(limited, 2)
        remainingLimited := stdlib_itertools_test_array(limited)

        AhkTest.AssertEqual([], remainingLimited)
        AhkTest.AssertEqual(6, stdlib_itertools_test_array(permutations).Length)
    }

    static TestPermutationsRejectsInvalidArgumentsWithPython310Priority()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.permutations(42, 2.0)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.permutations(42, "2")
        )
        AhkTest.RaisesMatch(
            TypeError,
            "Expected int as r",
            (*) => stdlib.itertools.permutations([1, 2], "2")
        )
        AhkTest.RaisesMatch(
            TypeError,
            "Expected int as r",
            (*) => stdlib.itertools.permutations([1, 2], 2.0)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "Expected int as r",
            (*) => stdlib.itertools.permutations([1, 2], stdlib.fractions.Fraction(1, 1))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib.itertools.permutations(StdlibItertoolsTest.DemoIterableSource(), 1)
        )
        AhkTest.RaisesMatch(
            ValueError,
            "r must be non-negative",
            (*) => stdlib.itertools.permutations([1, 2], -1)
        )
    }

    static TestCombinationsWithReplacementBuildsPythonTupleRowsInLexicographicOrder()
    {
        rows := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([1, 2, 3], 2))

        AhkTest.AssertEqual(6, rows.Length)
        AhkTest.AssertEqual([1, 1], stdlib_itertools_test_array(rows[1]))
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(rows[2]))
        AhkTest.AssertEqual([1, 3], stdlib_itertools_test_array(rows[3]))
        AhkTest.AssertEqual([2, 2], stdlib_itertools_test_array(rows[4]))
        AhkTest.AssertEqual([2, 3], stdlib_itertools_test_array(rows[5]))
        AhkTest.AssertEqual([3, 3], stdlib_itertools_test_array(rows[6]))
    }

    static TestCombinationsWithReplacementAcceptsStringsZeroOversizedAndBoolRLikePython310()
    {
        letters := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement("abc", 2))
        emptyRow := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([1, 2], 0))
        oversized := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([1, 2], 3))
        emptyZero := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([], 0))
        emptyOne := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([], 1))
        trueRows := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([1, 2], true))
        falseRows := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([1, 2], false))

        AhkTest.AssertEqual(6, letters.Length)
        AhkTest.AssertEqual(["a", "a"], stdlib_itertools_test_array(letters[1]))
        AhkTest.AssertEqual(["c", "c"], stdlib_itertools_test_array(letters[6]))
        AhkTest.AssertEqual(1, emptyRow.Length)
        AhkTest.AssertEqual([], stdlib_itertools_test_array(emptyRow[1]))
        AhkTest.AssertEqual(4, oversized.Length)
        AhkTest.AssertEqual([1, 1, 1], stdlib_itertools_test_array(oversized[1]))
        AhkTest.AssertEqual([2, 2, 2], stdlib_itertools_test_array(oversized[4]))
        AhkTest.AssertEqual(1, emptyZero.Length)
        AhkTest.AssertEqual([], stdlib_itertools_test_array(emptyZero[1]))
        AhkTest.AssertEqual([], emptyOne)
        AhkTest.AssertEqual(2, trueRows.Length)
        AhkTest.AssertEqual([1], stdlib_itertools_test_array(trueRows[1]))
        AhkTest.AssertEqual([2], stdlib_itertools_test_array(trueRows[2]))
        AhkTest.AssertEqual(1, falseRows.Length)
        AhkTest.AssertEqual([], stdlib_itertools_test_array(falseRows[1]))
    }

    static TestCombinationsWithReplacementAcceptsRootBoolRLikePython310()
    {
        trueRows := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([1, 2], stdlib.True))
        falseRows := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([1, 2], stdlib.False))

        AhkTest.AssertEqual(2, trueRows.Length)
        AhkTest.AssertEqual([1], stdlib_itertools_test_array(trueRows[1]))
        AhkTest.AssertEqual([2], stdlib_itertools_test_array(trueRows[2]))
        AhkTest.AssertEqual(1, falseRows.Length)
        AhkTest.AssertEqual([], stdlib_itertools_test_array(falseRows[1]))
    }

    static TestCombinationsWithReplacementAcceptsKeywordAnaloguesLikePython310()
    {
        rKeywordRows := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([1, 2, 3], { r: 2 }))
        bothKeywordRows := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement({ iterable: [1, 2, 3], r: 2 }))
        splitKeywordRows := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement({ iterable: [1, 2, 3] }, { r: 2 }))
        reversedSplitKeywordRows := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement({ r: 2 }, { iterable: [1, 2, 3] }))

        AhkTest.AssertEqual(6, rKeywordRows.Length)
        AhkTest.AssertEqual([1, 1], stdlib_itertools_test_array(rKeywordRows[1]))
        AhkTest.AssertEqual([3, 3], stdlib_itertools_test_array(rKeywordRows[6]))
        AhkTest.AssertEqual(6, bothKeywordRows.Length)
        AhkTest.AssertEqual([1, 1], stdlib_itertools_test_array(bothKeywordRows[1]))
        AhkTest.AssertEqual([3, 3], stdlib_itertools_test_array(bothKeywordRows[6]))
        AhkTest.AssertEqual(6, splitKeywordRows.Length)
        AhkTest.AssertEqual([1, 1], stdlib_itertools_test_array(splitKeywordRows[1]))
        AhkTest.AssertEqual([3, 3], stdlib_itertools_test_array(splitKeywordRows[6]))
        AhkTest.AssertEqual(6, reversedSplitKeywordRows.Length)
        AhkTest.AssertEqual([1, 1], stdlib_itertools_test_array(reversedSplitKeywordRows[1]))
        AhkTest.AssertEqual([3, 3], stdlib_itertools_test_array(reversedSplitKeywordRows[6]))
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) missing required argument 'iterable' \(pos 1\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement({ r: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) missing required argument 'r' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([1, 2, 3], { iterable: [4, 5] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) missing required argument 'r' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement({ iterable: [1, 2], extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) missing required argument 'r' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement({ extra: 1 }, { iterable: [1, 2] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement({ iterable: [1, 2], r: 2, extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement({ r: 2 }, { iterable: [1, 2], extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([1, 2, 3], 2, { iterable: [4, 5] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) takes at most 2 arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([1, 2], { r: 1, extra: 1 }))
        )

        AhkTest.RaisesMatch(
            TypeError,
            "'str' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.combinations_with_replacement({ iterable: [1, 2], r: "2" })
        )
    }

    static TestCombinationsWithReplacementRejectsOptionsOnlyPropertyObjectsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) missing required argument 'iterable' \(pos 1\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement({ extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement({ extra: 1, another: 2, third: 3 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) missing required argument 'r' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement({ iterable: [1, 2] }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) takes at most 2 keyword arguments \(3 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement({ iterable: [1], extra: 1, another: 2 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) missing required argument 'r' \(pos 2\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([1, 2], { extra: 1 }))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) takes at most 2 arguments \(4 given\)",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement([1], { r: 2, extra: 1, another: 2 }))
        )
    }

    static TestCombinationsWithReplacementTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsPositionalLikePython310()
    {
        callableIterableProp := stdlib_itertools_test_plain_callable_object("iterable", (*) => 1)
        callableRProp := stdlib_itertools_test_plain_callable_object("r", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement(callableIterableProp, 1))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement(callableRProp, 1))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement("ab", callableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement("ab", callableRProp))
        )
    }

    static TestCombinationsWithReplacementAcceptPlainIterableObjectsWithKeywordLikeOwnPropsAsPositionalLikePython310()
    {
        iterableIterableProp := stdlib_itertools_test_plain_iterable_object("iterable", ["a", "b"])
        iterableRProp := stdlib_itertools_test_plain_iterable_object("r", ["a", "b"])
        iterableExtraProp := stdlib_itertools_test_plain_iterable_object("extra", ["a", "b"])

        iterableRows := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement(iterableIterableProp, 1))
        rRows := stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement(iterableRProp, 1))

        AhkTest.AssertEqual(2, iterableRows.Length)
        AhkTest.AssertEqual(["a"], stdlib_itertools_test_array(iterableRows[1]))
        AhkTest.AssertEqual(["b"], stdlib_itertools_test_array(iterableRows[2]))
        AhkTest.AssertEqual(2, rRows.Length)
        AhkTest.AssertEqual(["a"], stdlib_itertools_test_array(rRows[1]))
        AhkTest.AssertEqual(["b"], stdlib_itertools_test_array(rRows[2]))

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement("ab", iterableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement("ab", iterableRProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib_itertools_test_array(stdlib.itertools.combinations_with_replacement("ab", iterableExtraProp))
        )
    }

    static TestCombinationsWithReplacementKeepsIteratorPositionAcrossConsumersLikePython310()
    {
        values := stdlib.itertools.combinations_with_replacement([1, 2, 3], 2)

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))
        second := stdlib_itertools_test_array(values)

        AhkTest.AssertEqual(2, first.Length)
        AhkTest.AssertEqual([1, 1], stdlib_itertools_test_array(first[1]))
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(first[2]))
        AhkTest.AssertEqual(4, second.Length)
        AhkTest.AssertEqual([1, 3], stdlib_itertools_test_array(second[1]))
        AhkTest.AssertEqual([2, 2], stdlib_itertools_test_array(second[2]))
        AhkTest.AssertEqual([2, 3], stdlib_itertools_test_array(second[3]))
        AhkTest.AssertEqual([3, 3], stdlib_itertools_test_array(second[4]))
    }

    static TestCombinationsWithReplacementMaterializesSourceWhenConstructedLikePython310()
    {
        source := stdlib.itertools.count(1)
        limited := stdlib.itertools.islice(source, 3)
        rows := stdlib.itertools.combinations_with_replacement(limited, 2)
        remainingLimited := stdlib_itertools_test_array(limited)

        AhkTest.AssertEqual([], remainingLimited)
        AhkTest.AssertEqual(6, stdlib_itertools_test_array(rows).Length)
    }

    static TestCombinationsWithReplacementRejectsInvalidArgumentsWithPython310Priority()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "combinations_with_replacement\(\) missing required argument 'r' \(pos 2\)",
            (*) => stdlib.itertools.combinations_with_replacement([1, 2])
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'float' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.combinations_with_replacement(42, 2.0)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'NoneType' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.combinations_with_replacement([1, 2], stdlib.None)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'str' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.combinations_with_replacement([1, 2], "2")
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'Fraction' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.combinations_with_replacement([1, 2], stdlib.fractions.Fraction(1, 1))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.combinations_with_replacement(42, -1)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib.itertools.combinations_with_replacement(StdlibItertoolsTest.DemoIterableSource(), 1)
        )
        AhkTest.RaisesMatch(
            ValueError,
            "r must be non-negative",
            (*) => stdlib.itertools.combinations_with_replacement([1, 2], -1)
        )
    }

    static TestStarmapAppliesCallableOverIterableArgumentRowsLikePython310()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.starmap(stdlib_itertools_test_add, [[1, 2], [3, 4]]))

        AhkTest.AssertEqual([3, 7], result)
    }

    static TestStarmapAcceptsStdlibOperatorCallableLikePython310()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.starmap(stdlib.operator.add, [[1, 2], [3, 4]]))

        AhkTest.AssertEqual([3, 7], result)
    }

    static TestStarmapAcceptsPlainCallableObjectsWithKeywordLikeOwnPropsLikePython310()
    {
        func := stdlib_itertools_test_plain_callable_object("function", stdlib_itertools_test_add)
        result := stdlib_itertools_test_array(stdlib.itertools.starmap(func, [[1, 2], [3, 4]]))

        AhkTest.AssertEqual([3, 7], result)
    }

    static TestStarmapAcceptsPlainIterableObjectsWithKeywordLikeOwnPropsLikePython310()
    {
        iterable := stdlib_itertools_test_plain_iterable_object("iterable", [[1, 2], [3, 4]])
        result := stdlib_itertools_test_array(stdlib.itertools.starmap(stdlib_itertools_test_add, iterable))

        AhkTest.AssertEqual([3, 7], result)
    }

    static TestStarmapTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsPositionalLikePython310()
    {
        callableIterableProp := stdlib_itertools_test_plain_callable_object("iterable", (*) => 1)
        callableExtraProp := stdlib_itertools_test_plain_callable_object("extra", (*) => 1)
        callableFunctionProp := stdlib_itertools_test_plain_callable_object("function", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.starmap(stdlib_itertools_test_add, callableIterableProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.starmap(stdlib_itertools_test_add, callableExtraProp))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "starmap expected 2 arguments, got 3",
            (*) => stdlib.itertools.starmap(stdlib_itertools_test_add, [[1, 2]], callableIterableProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "starmap expected 2 arguments, got 3",
            (*) => stdlib.itertools.starmap(stdlib_itertools_test_add, [[1, 2]], callableFunctionProp)
        )
    }

    static TestStarmapAcceptsStringRowsAndKeepsIteratorPositionLikePython310()
    {
        values := stdlib.itertools.starmap(stdlib_itertools_test_add, ["ab", "cd", "ef"])

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 1))
        second := stdlib_itertools_test_array(values)

        AhkTest.AssertEqual(["ab"], first)
        AhkTest.AssertEqual(["cd", "ef"], second)
    }

    static TestStarmapAcceptsMixedStringAndArrayRowsLikePython310()
    {
        values := stdlib.itertools.starmap(stdlib_itertools_test_add, ["ab", [3, 4]])

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 1))
        second := stdlib_itertools_test_array(values)

        AhkTest.AssertEqual(["ab"], first)
        AhkTest.AssertEqual([7], second)
    }

    static TestStarmapRejectsKeywordStyleOptionsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "starmap\(\) takes no keyword arguments",
            (*) => stdlib.itertools.starmap({ function: stdlib_itertools_test_add, iterable: [[1, 2]] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "starmap\(\) takes no keyword arguments",
            (*) => stdlib.itertools.starmap({ func: stdlib_itertools_test_add, iterable: stdlib.True })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "starmap\(\) takes no keyword arguments",
            (*) => stdlib.itertools.starmap(stdlib_itertools_test_add, [[1, 2]], { iterable: [[3, 4]] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "starmap\(\) takes no keyword arguments",
            (*) => stdlib.itertools.starmap(stdlib_itertools_test_add, [[1, 2]], { function: stdlib_itertools_test_mul })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "starmap\(\) takes no keyword arguments",
            (*) => stdlib.itertools.starmap({ extra: 1, another: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "starmap\(\) takes no keyword arguments",
            (*) => stdlib.itertools.starmap(stdlib_itertools_test_add, { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "starmap\(\) takes no keyword arguments",
            (*) => stdlib.itertools.starmap(stdlib_itertools_test_add, [[1, 2]], { extra: 1 })
        )
    }

    static TestStarmapKeywordPriorityMatchesPython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.starmap({ extra: 1 }, { extra: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "starmap\(\) takes no keyword arguments",
            (*) => stdlib.itertools.starmap(stdlib_itertools_test_add, [[1, 2]], 3, { extra: 1 })
        )
    }

    static TestStarmapRejectsNonCallableAndNonIterableInputsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not callable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.starmap(42, [[1, 2]]))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.starmap(stdlib_itertools_test_add, 42))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.starmap(stdlib_itertools_test_add, StdlibItertoolsTest.DemoIterableSource()))
        )
    }

    static TestStarmapRejectsNonCallableFunctionWhenConsumedLikePython310()
    {
        intFunction := stdlib.itertools.starmap(42, [[1, 2]])
        noneFunction := stdlib.itertools.starmap(stdlib.None, [[1, 2]])

        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not callable",
            (*) => stdlib_itertools_test_array(intFunction)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'NoneType' object is not callable",
            (*) => stdlib_itertools_test_array(noneFunction)
        )
    }

    static TestStarmapRejectsNonIterableInputAtConstructionLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.starmap(stdlib_itertools_test_add, 42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.starmap(42, 99)
        )
    }

    static TestTakewhileYieldsPrefixWhilePredicateIsTrueLikePython310()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.takewhile(stdlib_itertools_test_less_than_three, [1, 2, 3, 1]))

        AhkTest.AssertEqual([1, 2], result)
    }

    static TestTakewhileUsesSharedStdlibTruthinessForPredicateResultsLikePython310()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.takewhile(stdlib_itertools_test_truthiness_result, [0, 1, 2, 3, 4, 5, 6]))

        AhkTest.AssertEqual([0], result)
    }

    static TestTakewhileAcceptsStdlibOperatorCallableLikePython310()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.takewhile(stdlib.operator.truth, [0, 1, 2]))

        AhkTest.AssertEqual([], result)
    }

    static TestTakewhileAcceptsPlainCallableObjectsWithKeywordLikeOwnPropsLikePython310()
    {
        predicate := stdlib_itertools_test_plain_callable_object("predicate", stdlib_itertools_test_less_than_three)
        result := stdlib_itertools_test_array(stdlib.itertools.takewhile(predicate, [1, 2, 3, 1]))

        AhkTest.AssertEqual([1, 2], result)
    }

    static TestTakewhileAcceptsPlainIterableObjectsWithKeywordLikeOwnPropsLikePython310()
    {
        iterable := stdlib_itertools_test_plain_iterable_object("iterable", [1, 2, 3, 1])
        result := stdlib_itertools_test_array(stdlib.itertools.takewhile(stdlib_itertools_test_less_than_three, iterable))

        AhkTest.AssertEqual([1, 2], result)
    }

    static TestTakewhileAcceptsStringsAndKeepsIteratorPositionLikePython310()
    {
        values := stdlib.itertools.takewhile(stdlib_itertools_test_is_alpha, "ab1c")

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 1))
        second := stdlib_itertools_test_array(values)

        AhkTest.AssertEqual(["a"], first)
        AhkTest.AssertEqual(["b"], second)
    }

    static TestTakewhileRejectsKeywordStyleOptionsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "takewhile\(\) takes no keyword arguments",
            (*) => stdlib.itertools.takewhile({ predicate: stdlib_itertools_test_identity, iterable: [1] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "takewhile\(\) takes no keyword arguments",
            (*) => stdlib.itertools.takewhile(stdlib_itertools_test_identity, { iterable: [1] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "takewhile\(\) takes no keyword arguments",
            (*) => stdlib.itertools.takewhile({ extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "takewhile\(\) takes no keyword arguments",
            (*) => stdlib.itertools.takewhile(stdlib_itertools_test_identity, { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "takewhile\(\) takes no keyword arguments",
            (*) => stdlib.itertools.takewhile(stdlib_itertools_test_identity, [1], { extra: 1 })
        )
    }

    static TestTakewhileKeywordPriorityMatchesPython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.takewhile({ extra: 1 }, { extra: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "takewhile\(\) takes no keyword arguments",
            (*) => stdlib.itertools.takewhile(stdlib_itertools_test_identity, [1], 3, { extra: 1 })
        )
    }

    static TestTakewhileRejectsNonCallableAndNonIterableInputsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not callable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.takewhile(42, [1]))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.takewhile(stdlib_itertools_test_identity, 42))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.takewhile(stdlib_itertools_test_identity, StdlibItertoolsTest.DemoIterableSource()))
        )
    }

    static TestTakewhileRejectsNonCallablePredicateWhenConsumedLikePython310()
    {
        intPredicate := stdlib.itertools.takewhile(42, [1])
        nonePredicate := stdlib.itertools.takewhile(stdlib.None, [1])

        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not callable",
            (*) => stdlib_itertools_test_array(intPredicate)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'NoneType' object is not callable",
            (*) => stdlib_itertools_test_array(nonePredicate)
        )
    }

    static TestTakewhileRejectsNonIterableInputAtConstructionLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.takewhile(stdlib_itertools_test_identity, 42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.takewhile(42, 99)
        )
    }

    static TestDropwhileYieldsSuffixAfterPredicateFirstFalseLikePython310()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.dropwhile(stdlib_itertools_test_less_than_three, [1, 2, 3, 1, 0, 4]))

        AhkTest.AssertEqual([3, 1, 0, 4], result)
    }

    static TestDropwhileAcceptsStdlibOperatorCallableLikePython310()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.dropwhile(stdlib.operator.truth, [0, 1, 2]))

        AhkTest.AssertEqual([0, 1, 2], result)
    }

    static TestDropwhileAcceptsPlainCallableObjectsWithKeywordLikeOwnPropsLikePython310()
    {
        predicate := stdlib_itertools_test_plain_callable_object("predicate", stdlib_itertools_test_less_than_three)
        result := stdlib_itertools_test_array(stdlib.itertools.dropwhile(predicate, [1, 2, 3, 1]))

        AhkTest.AssertEqual([3, 1], result)
    }

    static TestDropwhileAcceptsPlainIterableObjectsWithKeywordLikeOwnPropsLikePython310()
    {
        iterable := stdlib_itertools_test_plain_iterable_object("iterable", [1, 2, 3, 1])
        result := stdlib_itertools_test_array(stdlib.itertools.dropwhile(stdlib_itertools_test_less_than_three, iterable))

        AhkTest.AssertEqual([3, 1], result)
    }

    static TestDropwhileAcceptsStringsAndKeepsIteratorPositionLikePython310()
    {
        values := stdlib.itertools.dropwhile(stdlib_itertools_test_is_alpha, "ab1c")

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 1))
        second := stdlib_itertools_test_array(values)

        AhkTest.AssertEqual(["1"], first)
        AhkTest.AssertEqual(["c"], second)
    }

    static TestDropwhileStopsCallingPredicateAfterFirstFalseLikePython310()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.dropwhile(stdlib_itertools_test_less_than_three, [1, 3, "boom"]))

        AhkTest.AssertEqual([3, "boom"], result)
    }

    static TestDropwhileRejectsKeywordStyleOptionsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "dropwhile\(\) takes no keyword arguments",
            (*) => stdlib.itertools.dropwhile({ predicate: stdlib_itertools_test_identity, iterable: [1] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "dropwhile\(\) takes no keyword arguments",
            (*) => stdlib.itertools.dropwhile(stdlib_itertools_test_identity, { iterable: [1] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "dropwhile\(\) takes no keyword arguments",
            (*) => stdlib.itertools.dropwhile({ extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "dropwhile\(\) takes no keyword arguments",
            (*) => stdlib.itertools.dropwhile(stdlib_itertools_test_identity, { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "dropwhile\(\) takes no keyword arguments",
            (*) => stdlib.itertools.dropwhile(stdlib_itertools_test_identity, [1], { extra: 1 })
        )
    }

    static TestDropwhileKeywordPriorityMatchesPython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.dropwhile({ extra: 1 }, { extra: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "dropwhile\(\) takes no keyword arguments",
            (*) => stdlib.itertools.dropwhile(stdlib_itertools_test_identity, [1], 3, { extra: 1 })
        )
    }

    static TestDropwhileRejectsNonCallablePredicateWhenConsumedLikePython310()
    {
        intPredicate := stdlib.itertools.dropwhile(42, [1])
        nonePredicate := stdlib.itertools.dropwhile(stdlib.None, [1])

        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not callable",
            (*) => stdlib_itertools_test_array(intPredicate)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'NoneType' object is not callable",
            (*) => stdlib_itertools_test_array(nonePredicate)
        )
    }

    static TestDropwhileRejectsNonIterableInputsWithPythonTypeNames()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.dropwhile(stdlib_itertools_test_identity, 42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib.itertools.dropwhile(stdlib_itertools_test_identity, StdlibItertoolsTest.DemoIterableSource())
        )
    }

    static TestFilterfalseYieldsItemsWherePredicateIsFalseLikePython310()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.filterfalse(stdlib_itertools_test_less_than_three, [1, 2, 3, 1, 4]))

        AhkTest.AssertEqual([3, 4], result)
    }

    static TestFilterfalseWithNonePredicateUsesPythonTruthiness()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.filterfalse(stdlib.None, [0, 1, "", "x", stdlib.None, false, [], [1], Map(), Map("x", 1), stdlib.False, stdlib.True, stdlib.tuple(), stdlib.tuple([1])]))

        AhkTest.AssertEqual([0, "", stdlib.None, false, [], Map(), stdlib.False, stdlib.tuple()], result)
    }

    static TestFilterfalseAcceptsStdlibOperatorCallableLikePython310()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.filterfalse(stdlib.operator.truth, [0, 1, 2]))

        AhkTest.AssertEqual([0], result)
    }

    static TestFilterfalseAcceptsPlainCallableObjectsWithKeywordLikeOwnPropsLikePython310()
    {
        predicate := stdlib_itertools_test_plain_callable_object("predicate", stdlib_itertools_test_less_than_three)
        result := stdlib_itertools_test_array(stdlib.itertools.filterfalse(predicate, [1, 2, 3, 1, 4]))

        AhkTest.AssertEqual([3, 4], result)
    }

    static TestFilterfalseAcceptsPlainIterableObjectsWithKeywordLikeOwnPropsLikePython310()
    {
        iterable := stdlib_itertools_test_plain_iterable_object("iterable", [1, 2, 3, 1, 4])
        result := stdlib_itertools_test_array(stdlib.itertools.filterfalse(stdlib_itertools_test_less_than_three, iterable))

        AhkTest.AssertEqual([3, 4], result)
    }

    static TestFilterfalseKeepsIteratorPositionAcrossConsumersLikePython310()
    {
        values := stdlib.itertools.filterfalse(stdlib_itertools_test_less_than_three, [1, 2, 3, 4, 0, 5])

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 1))
        second := stdlib_itertools_test_array(values)

        AhkTest.AssertEqual([3], first)
        AhkTest.AssertEqual([4, 5], second)
    }

    static TestFilterfalseRejectsKeywordStyleOptionsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "filterfalse\(\) takes no keyword arguments",
            (*) => stdlib.itertools.filterfalse({ predicate: stdlib_itertools_test_identity, iterable: [1] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "filterfalse\(\) takes no keyword arguments",
            (*) => stdlib.itertools.filterfalse(stdlib_itertools_test_identity, { iterable: [1] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "filterfalse\(\) takes no keyword arguments",
            (*) => stdlib.itertools.filterfalse({ extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "filterfalse\(\) takes no keyword arguments",
            (*) => stdlib.itertools.filterfalse(stdlib_itertools_test_identity, { extra: 1 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "filterfalse\(\) takes no keyword arguments",
            (*) => stdlib.itertools.filterfalse(stdlib_itertools_test_identity, [1], { extra: 1 })
        )
    }

    static TestFilterfalseKeywordPriorityMatchesPython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.filterfalse({ extra: 1 }, { extra: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "filterfalse\(\) takes no keyword arguments",
            (*) => stdlib.itertools.filterfalse(stdlib_itertools_test_identity, [1], 3, { extra: 1 })
        )
    }

    static TestFilterfalseRejectsNonCallablePredicateWhenConsumedLikePython310()
    {
        values := stdlib.itertools.filterfalse(42, [1])

        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not callable",
            (*) => stdlib_itertools_test_array(values)
        )
    }

    static TestFilterfalseRejectsNonIterableInputsWithPythonTypeNames()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.filterfalse(stdlib_itertools_test_identity, 42)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib.itertools.filterfalse(stdlib_itertools_test_identity, StdlibItertoolsTest.DemoIterableSource())
        )
    }

    static TestTeeDuplicatesCoveredIterableLikePython()
    {
        copies := stdlib.itertools.tee([1, 2, 3])

        AhkTest.AssertTrue(copies is AhkStdlibTuple)
        AhkTest.AssertEqual(2, copies.Length)
        AhkTest.AssertEqual([1, 2, 3], stdlib_itertools_test_array(copies[1]))
        AhkTest.AssertEqual([1, 2, 3], stdlib_itertools_test_array(copies[2]))
        AhkTest.RaisesMatch(TypeError, "does not support item assignment|readonly", (*) => copies[1] := "x")
    }

    static TestTeeClonesKeepIndependentPositionsLikePython()
    {
        copies := stdlib.itertools.tee([1, 2, 3], 3)
        first := copies[1]
        second := copies[2]
        third := copies[3]
        firstHead := stdlib_itertools_test_array(stdlib.itertools.islice(first, 1))
        secondAll := stdlib_itertools_test_array(second)
        thirdAll := stdlib_itertools_test_array(third)
        firstRest := stdlib_itertools_test_array(first)

        AhkTest.AssertEqual([1], firstHead)
        AhkTest.AssertEqual([1, 2, 3], secondAll)
        AhkTest.AssertEqual([1, 2, 3], thirdAll)
        AhkTest.AssertEqual([2, 3], firstRest)
    }

    static TestTeeOfTeeCloneReusesSharedStateLikePython()
    {
        outer := stdlib.itertools.tee([1, 2, 3], 2)
        first := outer[1]
        second := outer[2]
        firstHead := stdlib_itertools_test_array(stdlib.itertools.islice(first, 1))
        nested := stdlib.itertools.tee(first, 2)
        AhkTest.AssertSame(first, nested[1])
        nestedFirst := stdlib_itertools_test_array(nested[1])
        nestedSecond := stdlib_itertools_test_array(nested[2])
        secondAll := stdlib_itertools_test_array(second)
        firstRest := stdlib_itertools_test_array(first)

        AhkTest.AssertEqual([1], firstHead)
        AhkTest.AssertEqual([2, 3], nestedFirst)
        AhkTest.AssertEqual([2, 3], nestedSecond)
        AhkTest.AssertEqual([1, 2, 3], secondAll)
        AhkTest.AssertEqual([], firstRest)
    }

    static TestTeeRejectsReenteringSharedIteratorLikePython310()
    {
        source := StdlibItertoolsTest.DemoTeeReenterSource()
        clones := stdlib.itertools.tee(source, 2)
        first := clones[1]
        source.Peer := clones[2]

        AhkTest.RaisesMatch(RuntimeError, "tee", (*) => stdlib_itertools_test_next(first))
    }

    static TestTeeReprMatchesPython310Shape()
    {
        clone := stdlib.itertools.tee([1], 1)[1]

        AhkTest.AssertTrue(HasMethod(clone, "__Repr"))
        AhkTest.AssertRegex(clone.__Repr(), "^<itertools\._tee object at 0x[0-9A-F]+>$")
    }

    static TestTeeCloneTypeIsInstantiableLikePython310()
    {
        copies := stdlib.itertools.tee("abc")
        clone := copies[1]
        teeType := clone.__class__
        fromIterable := teeType("def")
        originals := stdlib.itertools.tee("abc")
        fromClone := teeType(originals[1])

        AhkTest.AssertEqual(["d", "e", "f"], stdlib_itertools_test_array(fromIterable))
        AhkTest.AssertEqual(["a", "b", "c"], stdlib_itertools_test_array(originals[1]))
        AhkTest.AssertEqual(["a", "b", "c"], stdlib_itertools_test_array(originals[2]))
        AhkTest.AssertEqual(["a", "b", "c"], stdlib_itertools_test_array(fromClone))
    }

    static TestTeeCloneTypeRejectsWrongArityLikePython310()
    {
        clone := stdlib.itertools.tee("abc")[1]
        teeType := clone.__class__

        AhkTest.RaisesMatch(TypeError, "_tee expected 1 argument, got 0", (*) => teeType())
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => teeType(10))
    }

    static TestTeeCloneTypeRejectsKeywordStyleOptionsLikePython310()
    {
        clone := stdlib.itertools.tee("abc")[1]
        teeType := clone.__class__

        AhkTest.RaisesMatch(
            TypeError,
            "_tee\(\) takes no keyword arguments",
            (*) => teeType({ iterable: "def" })
        )
    }

    static TestTeeCloneTypeRejectsPositionalAndKeywordStyleOptionsLikePython310()
    {
        clone := stdlib.itertools.tee("abc")[1]
        teeType := clone.__class__

        AhkTest.RaisesMatch(
            TypeError,
            "_tee\(\) takes no keyword arguments",
            (*) => teeType("def", { iterable: "ghi" })
        )
    }

    static TestTeeRejectsWrongArityLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "tee expected at least 1 argument, got 0",
            (*) => stdlib.itertools.tee()
        )
        AhkTest.RaisesMatch(
            TypeError,
            "tee expected at most 2 arguments, got 3",
            (*) => stdlib.itertools.tee([1], 1, 2)
        )
    }

    static TestTeeRejectsKeywordStyleOptionsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "itertools\.tee\(\) takes no keyword arguments",
            (*) => stdlib.itertools.tee([1], { n: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "itertools\.tee\(\) takes no keyword arguments",
            (*) => stdlib.itertools.tee(stdlib.True, { n: 0 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "itertools\.tee\(\) takes no keyword arguments",
            (*) => stdlib.itertools.tee({ n: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "itertools\.tee\(\) takes no keyword arguments",
            (*) => stdlib.itertools.tee([1, 2], { iterable: [3, 4] })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "itertools\.tee\(\) takes no keyword arguments",
            (*) => stdlib.itertools.tee([1, 2], 2, { n: 3 })
        )
    }

    static TestTeeKeywordPriorityMatchesPython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.tee({ extra: 1 }, { extra: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'n'",
            (*) => stdlib.itertools.tee([1], { n: 2 }, { n: 3 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "itertools\.tee\(\) takes no keyword arguments",
            (*) => stdlib.itertools.tee([1], 2, 3, { extra: 1 })
        )
    }

    static TestTeeAcceptsZeroOneAndBoolCountsLikePython()
    {
        zeroCopies := stdlib.itertools.tee(42, 0)
        oneCopies := stdlib.itertools.tee([1, 2], 1)
        trueCopies := stdlib.itertools.tee([5, 6], true)
        falseCopies := stdlib.itertools.tee(StdlibItertoolsTest.DemoIterableSource(), false)
        cloneZeroCopies := stdlib.itertools.tee(stdlib.itertools.tee("abc", 1)[1], 0)

        AhkTest.AssertEqual([], zeroCopies)
        AhkTest.AssertEqual(1, oneCopies.Length)
        AhkTest.AssertEqual([1, 2], stdlib_itertools_test_array(oneCopies[1]))
        AhkTest.AssertEqual(1, trueCopies.Length)
        AhkTest.AssertEqual([5, 6], stdlib_itertools_test_array(trueCopies[1]))
        AhkTest.AssertEqual([], falseCopies)
        AhkTest.AssertEqual([], cloneZeroCopies)
    }

    static TestTeeAcceptsRootBoolCountsLikePython()
    {
        trueCopies := stdlib.itertools.tee([7, 8], stdlib.True)
        falseCopies := stdlib.itertools.tee(StdlibItertoolsTest.DemoIterableSource(), stdlib.False)

        AhkTest.AssertEqual(1, trueCopies.Length)
        AhkTest.AssertEqual([7, 8], stdlib_itertools_test_array(trueCopies[1]))
        AhkTest.AssertEqual([], falseCopies)
    }

    static TestTeeAcceptsPlainIterableObjectsWithNLikeOwnPropsLikePython310()
    {
        copies := stdlib.itertools.tee(stdlib_itertools_test_plain_iterable_object("n", ["a", "b"]))

        AhkTest.AssertEqual(2, copies.Length)
        AhkTest.AssertEqual(["a", "b"], stdlib_itertools_test_array(copies[1]))
        AhkTest.AssertEqual(["a", "b"], stdlib_itertools_test_array(copies[2]))
    }

    static TestTeeAcceptsPlainIterableObjectsWithIterableLikeOwnPropsLikePython310()
    {
        copies := stdlib.itertools.tee(stdlib_itertools_test_plain_iterable_object("iterable", ["a", "b"]))

        AhkTest.AssertEqual(2, copies.Length)
        AhkTest.AssertEqual(["a", "b"], stdlib_itertools_test_array(copies[1]))
        AhkTest.AssertEqual(["a", "b"], stdlib_itertools_test_array(copies[2]))
    }

    static TestTeeTreatsPlainCallableObjectsWithKeywordLikeOwnPropsAsPositionalLikePython310()
    {
        callableNProp := stdlib_itertools_test_plain_callable_object("n", (*) => 1)
        callableIterableProp := stdlib_itertools_test_plain_callable_object("iterable", (*) => 1)

        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib.itertools.tee(callableNProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object is not iterable",
            (*) => stdlib.itertools.tee(callableIterableProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.tee([1, 2], callableNProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'object' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.tee([1, 2], callableIterableProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "tee expected at most 2 arguments, got 3",
            (*) => stdlib.itertools.tee([1, 2], 2, callableNProp)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "tee expected at most 2 arguments, got 3",
            (*) => stdlib.itertools.tee([1, 2], 2, callableIterableProp)
        )
    }

    static TestTeeRejectsNegativeAndNonIntegerCountsLikePython()
    {
        AhkTest.RaisesMatch(
            ValueError,
            "n must be >= 0",
            (*) => stdlib.itertools.tee([1], -1)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'float' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.tee([1], 2.0)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'str' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.tee([1], "2")
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'NoneType' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.tee([1], stdlib.None)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'function' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.tee([1], StdlibItertoolsTest.DemoTimesFunction)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'Fraction' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.tee([1], stdlib.fractions.Fraction(1, 1))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'decimal.Decimal' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.tee([1], stdlib.decimal.Decimal("1"))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'tuple' object cannot be interpreted as an integer",
            (*) => stdlib.itertools.tee([1], stdlib.tuple())
        )
    }

    static TestTeeRejectsNonIterableInputsWithPythonTypeNames()
    {
        AhkTest.AssertEqual([], stdlib.itertools.tee(stdlib.True, 0))
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.tee(42, 1)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'bool' object is not iterable",
            (*) => stdlib.itertools.tee(stdlib.True, 1)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'bool' object is not iterable",
            (*) => stdlib.itertools.tee(stdlib.False, 1)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'function' object is not iterable",
            (*) => stdlib.itertools.tee(StdlibItertoolsTest.DemoTimesFunction, 1)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib.itertools.tee(StdlibItertoolsTest.DemoIterableSource(), 1)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'Fraction' object is not iterable",
            (*) => stdlib.itertools.tee(stdlib.fractions.Fraction(1, 1), 1)
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'decimal.Decimal' object is not iterable",
            (*) => stdlib.itertools.tee(stdlib.decimal.Decimal("1"), 1)
        )
    }

    static TestIsliceUsesPythonStartStopStep()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.islice([10, 11, 12, 13, 14, 15], 1, 5, 2))

        AhkTest.AssertEqual([11, 13], result)
    }

    static TestIsliceRejectsKeywordStyleOptionsLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "islice\(\) takes no keyword arguments",
            (*) => stdlib.itertools.islice([1, 2, 3], { stop: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "islice\(\) takes no keyword arguments",
            (*) => stdlib.itertools.islice(stdlib.True, { stop: 0 })
        )
    }

    static TestIsliceKeywordPriorityMatchesPython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'extra'",
            (*) => stdlib.itertools.islice({ extra: 1 }, { extra: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "got multiple values for keyword argument 'stop'",
            (*) => stdlib.itertools.islice({ stop: 1 }, { stop: 2 })
        )
        AhkTest.RaisesMatch(
            TypeError,
            "islice\(\) takes no keyword arguments",
            (*) => stdlib.itertools.islice([1, 2, 3], 1, 2, 3, { extra: 1 })
        )
    }

    static TestIsliceRejectsWrongArityLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "islice expected at least 2 arguments, got 0",
            (*) => stdlib.itertools.islice()
        )
        AhkTest.RaisesMatch(
            TypeError,
            "islice expected at least 2 arguments, got 1",
            (*) => stdlib.itertools.islice([1, 2, 3])
        )
        AhkTest.RaisesMatch(
            TypeError,
            "islice expected at most 4 arguments, got 5",
            (*) => stdlib.itertools.islice([1, 2, 3], 1, 2, 3, 4)
        )
    }

    static TestIsliceAcceptsStdlibNoneStopAsUnbounded()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.islice([10, 11, 12, 13], 1, stdlib.None, 2))

        AhkTest.AssertEqual([11, 13], result)
    }

    static TestIsliceAcceptsStdlibNoneStepAsDefaultOne()
    {
        result := stdlib_itertools_test_array(stdlib.itertools.islice([10, 11, 12], 0, 3, stdlib.None))

        AhkTest.AssertEqual([10, 11, 12], result)
        AhkTest.AssertEqual([10, 11, 12], stdlib_itertools_test_array(stdlib.itertools.islice([10, 11, 12], 0, 3, true)))
        AhkTest.RaisesMatch(
            ValueError,
            "Step for islice\(\) must be a positive integer or None\.",
            (*) => stdlib.itertools.islice([10, 11, 12], 0, 3, false)
        )
    }

    static TestIsliceAcceptsRootBoolIndicesLikePython()
    {
        AhkTest.AssertEqual([10], stdlib_itertools_test_array(stdlib.itertools.islice([10, 11, 12], stdlib.True)))
        AhkTest.AssertEqual([], stdlib_itertools_test_array(stdlib.itertools.islice([10, 11, 12], stdlib.False)))
        AhkTest.AssertEqual([11, 12, 13], stdlib_itertools_test_array(stdlib.itertools.islice([10, 11, 12, 13], stdlib.True, stdlib.None)))
        AhkTest.AssertEqual([10], stdlib_itertools_test_array(stdlib.itertools.islice([10, 11, 12], stdlib.False, stdlib.True)))
        AhkTest.AssertEqual([10, 11, 12], stdlib_itertools_test_array(stdlib.itertools.islice([10, 11, 12], 0, 3, stdlib.True)))
        AhkTest.RaisesMatch(
            ValueError,
            "Step for islice\(\) must be a positive integer or None\.",
            (*) => stdlib.itertools.islice([10, 11, 12], 0, 3, stdlib.False)
        )
    }

    static TestIsliceAcceptsStdlibNoneStartLikePython()
    {
        bounded := stdlib_itertools_test_array(stdlib.itertools.islice([10, 11, 12, 13], stdlib.None, 3))
        stepped := stdlib_itertools_test_array(stdlib.itertools.islice([10, 11, 12, 13], stdlib.None, stdlib.None, 2))

        AhkTest.AssertEqual([10, 11, 12], bounded)
        AhkTest.AssertEqual([10, 12], stepped)
    }

    static TestIsliceIteratorKeepsPositionAcrossConsumers()
    {
        values := stdlib.itertools.islice([10, 11, 12, 13], 0, 4)

        first := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))
        second := stdlib_itertools_test_array(stdlib.itertools.islice(values, 2))

        AhkTest.AssertEqual([10, 11], first)
        AhkTest.AssertEqual([12, 13], second)
    }

    static TestIsliceRejectsNonIterableInputAtConstructionAfterIndexValidationLikePython310()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib.itertools.islice(42, 2)
        )
        AhkTest.RaisesMatch(
            ValueError,
            "Stop argument for islice\(\) must be None or an integer: 0 <= x <= sys\.maxsize\.",
            (*) => stdlib.itertools.islice(42, -1)
        )
        AhkTest.RaisesMatch(
            ValueError,
            "Step for islice\(\) must be a positive integer or None\.",
            (*) => stdlib.itertools.islice(42, 0, 3, 0)
        )
    }

    static TestIsliceRejectsNonIterableInputsWithPythonTypeNames()
    {
        AhkTest.RaisesMatch(
            TypeError,
            "'int' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.islice(42, 2))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'function' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.islice(StdlibItertoolsTest.DemoTimesFunction, 2))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'DemoIterableSource' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.islice(StdlibItertoolsTest.DemoIterableSource(), 2))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'Fraction' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.fractions.Fraction(1, 1), 2))
        )
        AhkTest.RaisesMatch(
            TypeError,
            "'decimal.Decimal' object is not iterable",
            (*) => stdlib_itertools_test_array(stdlib.itertools.islice(stdlib.decimal.Decimal("1"), 2))
        )
    }

    static TestIsliceConsumesToStartWhenStopBeforeStart()
    {
        values := stdlib.itertools.count(0)

        empty := stdlib_itertools_test_array(stdlib.itertools.islice(values, 5, 2))
        nextValues := stdlib_itertools_test_array(stdlib.itertools.islice(values, 3))

        AhkTest.AssertEqual([], empty)
        AhkTest.AssertEqual([5, 6, 7], nextValues)
    }

    static TestIsliceRejectsExplicitNegativeStopLikePython()
    {
        AhkTest.RaisesMatch(
            ValueError,
            "Indices for islice\(\) must be None or an integer: 0 <= x <= sys\.maxsize\.",
            (*) => stdlib.itertools.islice([1, 2, 3], 1, -1)
        )
    }

    static TestIsliceTwoArgumentNegativeStopUsesPythonStopMessage()
    {
        AhkTest.RaisesMatch(
            ValueError,
            "Stop argument for islice\(\) must be None or an integer: 0 <= x <= sys\.maxsize\.",
            (*) => stdlib.itertools.islice([1, 2, 3], -1)
        )
    }

    static TestIsliceRejectsExplicitNonIntegerStopWithPythonStopMessage()
    {
        AhkTest.RaisesMatch(
            ValueError,
            "Stop argument for islice\(\) must be None or an integer: 0 <= x <= sys\.maxsize\.",
            (*) => stdlib.itertools.islice([1, 2, 3], 1, 2.0)
        )
        AhkTest.RaisesMatch(
            ValueError,
            "Indices for islice\(\) must be None or an integer: 0 <= x <= sys\.maxsize\.",
            (*) => stdlib.itertools.islice([1, 2, 3], stdlib.fractions.Fraction(1, 1), 3)
        )
        AhkTest.RaisesMatch(
            ValueError,
            "Indices for islice\(\) must be None or an integer: 0 <= x <= sys\.maxsize\.",
            (*) => stdlib.itertools.islice([1, 2, 3], stdlib.decimal.Decimal("1"), 3)
        )
        AhkTest.RaisesMatch(
            ValueError,
            "Stop argument for islice\(\) must be None or an integer: 0 <= x <= sys\.maxsize\.",
            (*) => stdlib.itertools.islice([1, 2, 3], 0, stdlib.fractions.Fraction(1, 1))
        )
        AhkTest.RaisesMatch(
            ValueError,
            "Stop argument for islice\(\) must be None or an integer: 0 <= x <= sys\.maxsize\.",
            (*) => stdlib.itertools.islice([1, 2, 3], 0, stdlib.decimal.Decimal("1"))
        )
        AhkTest.RaisesMatch(
            ValueError,
            "Step for islice\(\) must be a positive integer or None\.",
            (*) => stdlib.itertools.islice([1, 2, 3], 0, 3, stdlib.fractions.Fraction(1, 1))
        )
        AhkTest.RaisesMatch(
            ValueError,
            "Step for islice\(\) must be a positive integer or None\.",
            (*) => stdlib.itertools.islice([1, 2, 3], 0, 3, stdlib.decimal.Decimal("1"))
        )
        AhkTest.RaisesMatch(
            ValueError,
            "Stop argument for islice\(\) must be None or an integer: 0 <= x <= sys\.maxsize\.",
            (*) => stdlib.itertools.islice([1, 2, 3], stdlib.fractions.Fraction(1, 1))
        )
        AhkTest.RaisesMatch(
            ValueError,
            "Stop argument for islice\(\) must be None or an integer: 0 <= x <= sys\.maxsize\.",
            (*) => stdlib.itertools.islice([1, 2, 3], stdlib.decimal.Decimal("1"))
        )
    }
}

stdlib_itertools_test_array(iterable)
{
    result := []
    for value in iterable
        result.Push(value)
    return result
}

stdlib_itertools_test_groupby_pairs(iterable)
{
    result := []
    for row in iterable {
        values := stdlib_itertools_test_array(row)
        result.Push([values[1], stdlib_itertools_test_array(values[2])])
    }
    return result
}

stdlib_itertools_test_plain_iterable_object(propName, values)
{
    obj := { Values: values }
    obj.%propName% := "not a keyword"
    obj.DefineProp("__Enum", { Call: stdlib_itertools_test_plain_iterable_object_enum })
    return obj
}

stdlib_itertools_test_plain_callable_object(propName, callback)
{
    obj := { Callback: callback }
    obj.%propName% := "not a keyword"
    obj.DefineProp("Call", { Call: stdlib_itertools_test_plain_callable_object_call })
    return obj
}

stdlib_itertools_test_plain_iterable_object_enum(this, numberOfVars)
{
    index := 0
    values := this.Values
    return next_value

    next_value(&value)
    {
        index += 1
        if index > values.Length
            return false
        value := values[index]
        return true
    }
}

stdlib_itertools_test_plain_callable_object_call(this, args*)
{
    callback := this.Callback
    return callback(args*)
}

stdlib_itertools_test_mul(a, b)
{
    return stdlib.operator.mul(a, b)
}

stdlib_itertools_test_add(a, b)
{
    return stdlib.operator.add(a, b)
}

stdlib_itertools_test_less_than_three(value)
{
    return value < 3
}

stdlib_itertools_test_is_alpha(value)
{
    return value ~= "^[A-Za-z]$"
}

stdlib_itertools_test_identity(value)
{
    return value
}

stdlib_itertools_test_next(iterable)
{
    iterator := iterable.__Enum(1)
    value := unset
    if !iterator(&value)
        throw StopIteration()
    return value
}

stdlib_itertools_test_truthiness_result(value)
{
    values := [stdlib.True, stdlib.False, [], [1], Map(), Map("x", 1), stdlib.None]
    return values[value + 1]
}

stdlib_itertools_test_first_char(value)
{
    return SubStr(value, 1, 1)
}

AhkTest.Collect(StdlibItertoolsTest)
