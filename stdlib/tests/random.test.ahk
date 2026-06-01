#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\random>

class StdlibRandomTest
{
    class DemoChoiceDictLike extends Map
    {
        __New()
        {
            super.__New()
            this["a"] := 1
        }
    }

    class DemoSequence
    {
        __Len
        {
            get => 3
        }

        __Item[index]
        {
            get
            {
                if index = 1
                    return "a"
                if index = 2
                    return "b"
                if index = 3
                    return "c"
                throw IndexError("out", -1)
            }
        }
    }

    static TestSeedMakesPython310RandomSequenceRepeatable()
    {
        stdlib.random.seed(12345)

        values := [
            stdlib.random.random(),
            stdlib.random.random(),
            stdlib.random.random(),
            stdlib.random.random(),
            stdlib.random.random()
        ]

        AhkTest.AssertApprox(0.41661987254534116, values[1])
        AhkTest.AssertApprox(0.010169169457068361, values[2])
        AhkTest.AssertApprox(0.82520650925374317, values[3])
        AhkTest.AssertApprox(0.2986398551995928, values[4])
        AhkTest.AssertApprox(0.36841168948847569, values[5])

        stdlib.random.seed(12345)
        AhkTest.AssertEqual(values, [
            stdlib.random.random(),
            stdlib.random.random(),
            stdlib.random.random(),
            stdlib.random.random(),
            stdlib.random.random()
        ])
    }

    static TestGetrandbitsMatchesPython310ForSeededGenerator()
    {
        stdlib.random.seed(12345)

        AhkTest.AssertEqual(0, stdlib.random.getrandbits(0))
        AhkTest.AssertEqual(0, stdlib.random.getrandbits(1))
        AhkTest.AssertEqual(2, stdlib.random.getrandbits(2))
        AhkTest.AssertEqual(0, stdlib.random.getrandbits(3))
        AhkTest.AssertEqual(13, stdlib.random.getrandbits(4))
        AhkTest.AssertEqual(26, stdlib.random.getrandbits(5))
        AhkTest.AssertEqual(1724103795, stdlib.random.getrandbits(31))
        AhkTest.AssertEqual(1282648386, stdlib.random.getrandbits(32))
    }

    static TestRandomReturnsFloatInHalfOpenUnitInterval()
    {
        loop 20 {
            value := stdlib.random.random()
            AhkTest.AssertEqual("Float", Type(value))
            AhkTest.AssertTrue(value >= 0.0)
            AhkTest.AssertTrue(value < 1.0)
        }
    }

    static TestUniformReturnsFloatBetweenInclusiveBounds()
    {
        AhkTest.AssertEqual(1.5, stdlib.random.uniform(1.5, 1.5))

        loop 20 {
            value := stdlib.random.uniform(-2.5, 3.5)
            AhkTest.AssertEqual("Float", Type(value))
            AhkTest.AssertTrue(value >= -2.5)
            AhkTest.AssertTrue(value <= 3.5)
        }
    }

    static TestRandrangeUsesPythonStopExclusiveIntegerRanges()
    {
        stdlib.random.seed(12345)

        AhkTest.AssertEqual([6, 0, 4, 5, 3, 4, 9, 6, 2, 5], [
            stdlib.random.randrange(10),
            stdlib.random.randrange(10),
            stdlib.random.randrange(10),
            stdlib.random.randrange(10),
            stdlib.random.randrange(10),
            stdlib.random.randrange(10),
            stdlib.random.randrange(10),
            stdlib.random.randrange(10),
            stdlib.random.randrange(10),
            stdlib.random.randrange(10)
        ])

        loop 30 {
            oneArg := stdlib.random.randrange(5)
            AhkTest.AssertTrue(oneArg >= 0 && oneArg < 5)

            twoArg := stdlib.random.randrange(2, 6)
            AhkTest.AssertTrue(twoArg >= 2 && twoArg < 6)

            stepped := stdlib.random.randrange(1, 6, 2)
            AhkTest.AssertTrue(stepped = 1 || stepped = 3 || stepped = 5)

            descending := stdlib.random.randrange(5, 1, -2)
            AhkTest.AssertTrue(descending = 5 || descending = 3)
        }
    }

    static TestRandrangeRejectsPython310InvalidArguments()
    {
        AhkTest.RaisesMatch(ValueError, "empty range for randrange", (*) => stdlib.random.randrange(0))
        AhkTest.RaisesMatch(ValueError, "empty range for randrange", (*) => stdlib.random.randrange(5, 1))
        AhkTest.RaisesMatch(ValueError, "zero step for randrange", (*) => stdlib.random.randrange(1, 5, 0))
        AhkTest.RaisesMatch(ValueError, "non-integer arg 1 for randrange", (*) => stdlib.random.randrange(1.2))
        AhkTest.RaisesMatch(ValueError, "non-integer stop for randrange", (*) => stdlib.random.randrange(1, 5.2))
        AhkTest.RaisesMatch(ValueError, "non-integer step for randrange", (*) => stdlib.random.randrange(1, 5, 2.5))
    }

    static TestRandintIsInclusiveAndRaisesForEmptyRange()
    {
        AhkTest.AssertEqual(1, stdlib.random.randint(1, 1))

        stdlib.random.seed(12345)
        AhkTest.AssertEqual([4, 6, 1, 3, 3, 2], [
            stdlib.random.randint(1, 6),
            stdlib.random.randint(1, 6),
            stdlib.random.randint(1, 6),
            stdlib.random.randint(1, 6),
            stdlib.random.randint(1, 6),
            stdlib.random.randint(1, 6)
        ])

        loop 20 {
            value := stdlib.random.randint(1, 3)
            AhkTest.AssertTrue(value >= 1 && value <= 3)
        }

        AhkTest.RaisesMatch(ValueError, "empty range for randrange", (*) => stdlib.random.randint(5, 1))
    }

    static TestChoiceSupportsArraysAndStrings()
    {
        stdlib.random.seed(12345)
        AhkTest.AssertEqual(["blue", "green", "red", "blue"], [
            stdlib.random.choice(["red", "blue", "green"]),
            stdlib.random.choice(["red", "blue", "green"]),
            stdlib.random.choice(["red", "blue", "green"]),
            stdlib.random.choice(["red", "blue", "green"])
        ])

        arrayChoice := stdlib.random.choice(["red", "blue"])
        AhkTest.AssertTrue(arrayChoice = "red" || arrayChoice = "blue")

        stringChoice := stdlib.random.choice("ab")
        AhkTest.AssertTrue(stringChoice = "a" || stringChoice = "b")
    }

    static TestChoiceRejectsEmptySequencesLikePython()
    {
        AhkTest.RaisesMatch(IndexError, "list index out of range", (*) => stdlib.random.choice([]))
        AhkTest.RaisesMatch(IndexError, "string index out of range", (*) => stdlib.random.choice(""))
    }

    static TestChoiceTreatsMappingsAsSubscriptableAndSurfacesObservedKeyErrorLikePython310()
    {
        AhkTest.RaisesMatch(stdlib.KeyError, "^0$", (*) => stdlib.random.choice(Map("a", 1)))
        AhkTest.RaisesMatch(stdlib.KeyError, "^0$", (*) => stdlib.random.choice(StdlibRandomTest.DemoChoiceDictLike()))
    }

    static TestChoiceAndChoicesAcceptCustomSequenceProtocolLikePython310()
    {
        stdlib.random.seed(12345)
        AhkTest.AssertEqual("b", stdlib.random.choice(StdlibRandomTest.DemoSequence()))

        stdlib.random.seed(12345)
        AhkTest.AssertEqual(["b", "a", "c", "a"], stdlib.random.choices(StdlibRandomTest.DemoSequence(), unset, unset, 4))
    }

    static TestShuffleMutatesArrayInPlaceAndReturnsNoValue()
    {
        values := [1, 2, 3, 4]

        result := stdlib.random.shuffle(values)

        AhkTest.AssertEqual("", result)
        AhkTest.AssertEqual(4, values.Length)
        AhkTest.AssertEqual(Map(1, 1, 2, 1, 3, 1, 4, 1), stdlib_random_test_counts(values))

        stdlib.random.seed(12345)
        seeded := [1, 2, 3, 4, 5]
        stdlib.random.shuffle(seeded)
        AhkTest.AssertEqual([5, 3, 2, 1, 4], seeded)
    }

    static TestShuffleRejectsObservedReadonlySequenceShapesLikePython310()
    {
        AhkTest.RaisesMatch(TypeError, "^'str' object does not support item assignment$", (*) => stdlib.random.shuffle("ab"))
        AhkTest.RaisesMatch(TypeError, "^'tuple' object does not support item assignment$", (*) => stdlib.random.shuffle(stdlib.tuple([1, 2])))
    }

    static TestSampleReturnsUniqueValuesLikePython310()
    {
        stdlib.random.seed(12345)

        AhkTest.AssertEqual(["d", "c", "a"], stdlib.random.sample(["a", "b", "c", "d"], 3))
        AhkTest.AssertEqual([], stdlib.random.sample(["a", "b"], 0))
        stdlib.random.seed(12345)
        AhkTest.AssertEqual(["b"], stdlib.random.sample(["a", "b"], stdlib.True))
        AhkTest.AssertEqual([], stdlib.random.sample(["a", "b"], stdlib.False))
        AhkTest.RaisesMatch(ValueError, "Sample larger than population or is negative", (*) => stdlib.random.sample(["a", "b"], -1))
        AhkTest.RaisesMatch(ValueError, "Sample larger than population or is negative", (*) => stdlib.random.sample(["a", "b"], 3))
        AhkTest.RaisesMatch(TypeError, "Population must be a sequence", (*) => stdlib.random.sample(Map("a", 1), 1))
    }

    static TestChoicesReturnsWeightedValuesWithReplacementLikePython310()
    {
        stdlib.random.seed(12345)
        AhkTest.AssertEqual(["blue", "red", "green", "red", "blue"], stdlib.random.choices(["red", "blue", "green"], unset, unset, 5))

        stdlib.random.seed(12345)
        AhkTest.AssertEqual(["blue", "red", "green", "blue", "blue", "blue"], stdlib.random.choices(["red", "blue", "green"], [1, 2, 3], unset, 6))

        stdlib.random.seed(12345)
        AhkTest.AssertEqual(["blue", "red", "blue", "red", "blue", "red"], stdlib.random.choices(["red", "blue"], unset, [1, 3], 6))

        stdlib.random.seed(12345)
        AhkTest.AssertEqual(["b", "a", "c", "a"], stdlib.random.choices("abc", unset, unset, 4))

        stdlib.random.seed(12345)
        AhkTest.AssertEqual(["a"], stdlib.random.choices(["a", "b"], unset, unset, stdlib.True))
        AhkTest.AssertEqual([], stdlib.random.choices(["a", "b"], unset, unset, stdlib.False))
    }

    static TestChoicesRejectsPython310InvalidArguments()
    {
        AhkTest.RaisesMatch(IndexError, "list index out of range", (*) => stdlib.random.choices([], unset, unset, 1))
        AhkTest.RaisesMatch(TypeError, "Cannot specify both weights and cumulative weights", (*) => stdlib.random.choices(["a"], [1], [1], 1))
        AhkTest.RaisesMatch(ValueError, "The number of weights does not match the population", (*) => stdlib.random.choices(["a", "b"], [1], unset, 1))
        AhkTest.RaisesMatch(ValueError, "The number of weights does not match the population", (*) => stdlib.random.choices(["a", "b"], unset, [1], 1))
        AhkTest.RaisesMatch(ValueError, "Total of weights must be greater than zero", (*) => stdlib.random.choices(["a", "b"], [0, 0], unset, 1))
        AhkTest.AssertEqual([], stdlib.random.choices(["a", "b"], unset, unset, -1))
    }
}

stdlib_random_test_counts(values)
{
    counts := Map()
    for value in values
        counts[value] := counts.Has(value) ? counts[value] + 1 : 1
    return counts
}

AhkTest.Collect(StdlibRandomTest)
