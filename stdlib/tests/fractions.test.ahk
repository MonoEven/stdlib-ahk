#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\fractions>
#Include <stdlib\operator>

class StdlibFractionsTest
{
    static TestFractionConstructsAndNormalizesLikePython310()
    {
        half := stdlib.fractions.Fraction(2, 4)
        negativeHalf := stdlib.fractions.Fraction(1, -2)
        fromInt := stdlib.fractions.Fraction(5)
        fromString := stdlib.fractions.Fraction("3/6")
        fromDecimalString := stdlib.fractions.Fraction("1.25")

        AhkTest.AssertEqual(1, half.numerator)
        AhkTest.AssertEqual(2, half.denominator)
        AhkTest.AssertEqual("1/2", String(half))
        AhkTest.AssertEqual("Fraction(1, 2)", half.__Repr())
        AhkTest.AssertEqual(-1, negativeHalf.numerator)
        AhkTest.AssertEqual(2, negativeHalf.denominator)
        AhkTest.AssertEqual("-1/2", String(negativeHalf))
        AhkTest.AssertEqual("5", String(fromInt))
        AhkTest.AssertEqual("1/2", String(fromString))
        AhkTest.AssertEqual("5/4", String(fromDecimalString))
    }

    static TestFractionSupportsArithmeticComparisonAndFloatLikePython310()
    {
        half := stdlib.fractions.Fraction(1, 2)
        third := stdlib.fractions.Fraction(1, 3)
        twoThirds := stdlib.fractions.Fraction(2, 3)
        threeQuarters := stdlib.fractions.Fraction(3, 4)

        AhkTest.AssertEqual("5/6", String(stdlib.operator.add(half, third)))
        AhkTest.AssertEqual("1/6", String(stdlib.operator.sub(half, third)))
        AhkTest.AssertEqual("1/2", String(stdlib.operator.mul(twoThirds, threeQuarters)))
        AhkTest.AssertEqual("8/9", String(stdlib.operator.truediv(twoThirds, threeQuarters)))
        AhkTest.AssertEqual(1.0, stdlib.operator.add(half, 0.5))
        AhkTest.AssertEqual(1.0, stdlib.operator.add(0.5, half))
        AhkTest.AssertEqual(1.0, stdlib.operator.sub(stdlib.fractions.Fraction(3, 2), 0.5))
        AhkTest.AssertEqual(1.5, stdlib.operator.sub(2.0, half))
        AhkTest.AssertEqual(0.25, stdlib.operator.mul(half, 0.5))
        AhkTest.AssertEqual(0.25, stdlib.operator.mul(0.5, half))
        AhkTest.AssertEqual(1.0, stdlib.operator.truediv(half, 0.5))
        AhkTest.AssertEqual(4.0, stdlib.operator.truediv(2.0, half))
        AhkTest.AssertTrue(stdlib.operator.lt(third, half))
        AhkTest.AssertTrue(stdlib.operator.lt(half, 0.75))
        AhkTest.AssertTrue(stdlib.operator.eq(stdlib.fractions.Fraction(2, 4), half))
        AhkTest.AssertTrue(stdlib.operator.eq(half, 0.5))
        AhkTest.AssertEqual(0.25, stdlib.fractions.Fraction(1, 4).to_float())
    }

    static TestFractionSupportsIntegerInteropAndUnaryTruthLikePython310()
    {
        half := stdlib.fractions.Fraction(1, 2)
        threeHalves := stdlib.fractions.Fraction(3, 2)
        twoThirds := stdlib.fractions.Fraction(2, 3)
        negativeHalf := stdlib.fractions.Fraction(-1, 2)

        AhkTest.AssertEqual("3/2", String(stdlib.operator.add(half, 1)))
        AhkTest.AssertEqual("3/2", String(stdlib.operator.add(1, half)))
        AhkTest.AssertEqual("1/2", String(stdlib.operator.sub(threeHalves, 1)))
        AhkTest.AssertEqual("1/2", String(stdlib.operator.sub(1, half)))
        AhkTest.AssertEqual("2", String(stdlib.operator.mul(twoThirds, 3)))
        AhkTest.AssertEqual("2", String(stdlib.operator.mul(3, twoThirds)))
        AhkTest.AssertEqual("1/4", String(stdlib.operator.truediv(half, 2)))
        AhkTest.AssertEqual("4", String(stdlib.operator.truediv(2, half)))
        AhkTest.AssertTrue(stdlib.operator.eq(stdlib.fractions.Fraction(2, 1), 2))
        AhkTest.AssertTrue(stdlib.operator.lt(half, 1))
        AhkTest.AssertFalse(stdlib.operator.truth(stdlib.fractions.Fraction(0, 1)))
        AhkTest.AssertTrue(stdlib.operator.truth(half))
        AhkTest.AssertEqual("1/2", String(stdlib.operator.abs(negativeHalf)))
        AhkTest.AssertEqual("-1/2", String(stdlib.operator.pos(negativeHalf)))
        AhkTest.AssertEqual("-1/2", String(stdlib.operator.neg(half)))
    }

    static TestFractionRejectsPython310InvalidArguments()
    {
        AhkTest.RaisesMatch(ZeroDivisionError, "1, 0", (*) => stdlib.fractions.Fraction(1, 0))
        AhkTest.RaisesMatch(ValueError, "Invalid literal for Fraction: 'abc'", (*) => stdlib.fractions.Fraction("abc"))
        AhkTest.RaisesMatch(TypeError, "argument should be a string or a Rational instance", (*) => stdlib.fractions.Fraction({}))
        AhkTest.RaisesMatch(TypeError, "both arguments should be Rational instances", (*) => stdlib.fractions.Fraction("1", "2"))
    }

    static TestFractionFromFloatRatioAndLimitDenominatorLikePython310()
    {
        fromHalf := stdlib.fractions.Fraction.from_float(0.5)
        fromOnePointOne := stdlib.fractions.Fraction.from_float(1.1)
        piApprox := stdlib.fractions.Fraction("3.1415926535")

        AhkTest.AssertEqual("1/2", String(fromHalf))
        AhkTest.AssertEqual("2476979795053773/2251799813685248", String(fromOnePointOne))
        AhkTest.AssertEqual([1, 2], stdlib.fractions.Fraction(1, 2).as_integer_ratio())
        AhkTest.AssertEqual([-3, 4], stdlib.fractions.Fraction(-3, 4).as_integer_ratio())
        AhkTest.AssertEqual([0, 1], stdlib.fractions.Fraction(0, 1).as_integer_ratio())
        AhkTest.AssertEqual("22/7", String(piApprox.limit_denominator(10)))
        AhkTest.AssertEqual("311/99", String(piApprox.limit_denominator(100)))
        AhkTest.AssertEqual("1/2", String(stdlib.fractions.Fraction(1, 2).limit_denominator()))
        AhkTest.AssertEqual("1/2", String(stdlib.fractions.Fraction(1, 2).limit_denominator(2.0)))
    }

    static TestFractionFromFloatRatioAndLimitDenominatorRejectPython310InvalidArguments()
    {
        AhkTest.RaisesMatch(TypeError, "only takes floats, not '0.5'|str", (*) => stdlib.fractions.Fraction.from_float("0.5"))
        AhkTest.RaisesMatch(TypeError, "only takes floats, not \\{\\}|dict", (*) => stdlib.fractions.Fraction.from_float(Map()))
        AhkTest.RaisesMatch(ValueError, "max_denominator should be at least 1", (*) => stdlib.fractions.Fraction(1, 2).limit_denominator(0))
    }
}

AhkTest.Collect(StdlibFractionsTest)
