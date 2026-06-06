#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\decimal>
#Include <stdlib\fractions>
#Include <stdlib\operator>

class StdlibDecimalTest
{
    static TestDecimalContextConstantsAndSignalsMatchObservedLocal310()
    {
        AhkTest.AssertEqual("ROUND_CEILING", stdlib.decimal.ROUND_CEILING)
        AhkTest.AssertEqual("ROUND_FLOOR", stdlib.decimal.ROUND_FLOOR)
        AhkTest.AssertEqual("ROUND_UP", stdlib.decimal.ROUND_UP)
        AhkTest.AssertEqual("ROUND_DOWN", stdlib.decimal.ROUND_DOWN)
        AhkTest.AssertEqual("ROUND_HALF_UP", stdlib.decimal.ROUND_HALF_UP)
        AhkTest.AssertEqual("ROUND_HALF_DOWN", stdlib.decimal.ROUND_HALF_DOWN)
        AhkTest.AssertEqual("ROUND_HALF_EVEN", stdlib.decimal.ROUND_HALF_EVEN)
        AhkTest.AssertEqual("ROUND_05UP", stdlib.decimal.ROUND_05UP)
        AhkTest.AssertTrue(stdlib.decimal.HAVE_CONTEXTVAR)
        AhkTest.AssertTrue(stdlib.decimal.HAVE_THREADS)
        AhkTest.AssertEqual(999999999999999999, stdlib.decimal.MAX_PREC)
        AhkTest.AssertEqual(999999999999999999, stdlib.decimal.MAX_EMAX)
        AhkTest.AssertEqual(-999999999999999999, stdlib.decimal.MIN_EMIN)
        AhkTest.AssertEqual(-1999999999999999997, stdlib.decimal.MIN_ETINY)

        AhkTest.AssertTrue(stdlib.decimal.DecimalException() is Error)
        AhkTest.AssertTrue(stdlib.decimal.DivisionByZero() is Error)
        AhkTest.AssertTrue(stdlib.decimal.InvalidOperation() is Error)
        AhkTest.AssertTrue(stdlib.decimal.FloatOperation() is Error)

        defaultContext := stdlib.decimal.DefaultContext
        basicContext := stdlib.decimal.BasicContext
        extendedContext := stdlib.decimal.ExtendedContext
        newContext := stdlib.decimal.Context()
        customContext := stdlib.decimal.Context({ prec: 7, rounding: stdlib.decimal.ROUND_DOWN, Emin: -99, Emax: 99, capitals: 0, clamp: 1 })

        AhkTest.AssertEqual(28, defaultContext.prec)
        AhkTest.AssertEqual(stdlib.decimal.ROUND_HALF_EVEN, defaultContext.rounding)
        AhkTest.AssertEqual(9, basicContext.prec)
        AhkTest.AssertEqual(stdlib.decimal.ROUND_HALF_UP, basicContext.rounding)
        AhkTest.AssertEqual(9, extendedContext.prec)
        AhkTest.AssertEqual(stdlib.decimal.ROUND_HALF_EVEN, extendedContext.rounding)
        AhkTest.AssertEqual(28, newContext.prec)
        AhkTest.AssertEqual(7, customContext.prec)
        AhkTest.AssertEqual(stdlib.decimal.ROUND_DOWN, customContext.rounding)
        AhkTest.AssertEqual(-99, customContext.Emin)
        AhkTest.AssertEqual(99, customContext.Emax)
        AhkTest.AssertEqual(0, customContext.capitals)
        AhkTest.AssertEqual(1, customContext.clamp)
        AhkTest.AssertEqual(9, customContext.flags.Count)
        AhkTest.AssertEqual(9, customContext.traps.Count)

        original := stdlib.decimal.getcontext()
        originalCopy := original.copy()
        try {
            AhkTest.AssertEqual(28, original.prec)
            AhkTest.AssertSame(stdlib.None, stdlib.decimal.setcontext(customContext))
            AhkTest.AssertEqual(7, stdlib.decimal.getcontext().prec)

            withLocal := stdlib.decimal.localcontext()
            entered := withLocal.__enter__()
            AhkTest.AssertEqual(7, entered.prec)
            entered.prec := 11
            AhkTest.AssertEqual(11, stdlib.decimal.getcontext().prec)
            AhkTest.AssertFalse(withLocal.__exit__(stdlib.None, stdlib.None, stdlib.None))
            AhkTest.AssertEqual(7, stdlib.decimal.getcontext().prec)

            withExplicit := stdlib.decimal.localcontext(stdlib.decimal.Context({ prec: 13 }))
            explicitEntered := withExplicit.__enter__()
            AhkTest.AssertEqual(13, explicitEntered.prec)
            explicitEntered.prec := 14
            AhkTest.AssertEqual(14, stdlib.decimal.getcontext().prec)
            AhkTest.AssertFalse(withExplicit.__exit__(stdlib.None, stdlib.None, stdlib.None))
            AhkTest.AssertEqual(7, stdlib.decimal.getcontext().prec)
        } finally {
            stdlib.decimal.setcontext(originalCopy)
        }

        AhkTest.RaisesMatch(TypeError, "argument must be a context", (*) => stdlib.decimal.setcontext(1))
        AhkTest.RaisesMatch(TypeError, "optional argument must be a context", (*) => stdlib.decimal.localcontext(1).__enter__())
        AhkTest.RaisesMatch(TypeError, "an integer is required", (*) => stdlib.decimal.Context({ prec: "7" }))
        AhkTest.RaisesMatch(TypeError, "valid values for rounding are", (*) => stdlib.decimal.Context({ rounding: "bad" }))
    }

    static TestDecimalConstructsAndFormatsLikePython310()
    {
        fromString := stdlib.decimal.Decimal("1.25")
        fromZeroPadded := stdlib.decimal.Decimal("001.2300")
        fromInt := stdlib.decimal.Decimal(5)

        AhkTest.AssertEqual("1.25", String(fromString))
        AhkTest.AssertEqual("Decimal('1.25')", fromString.__Repr())
        AhkTest.AssertEqual("1.2300", String(fromZeroPadded))
        AhkTest.AssertEqual("Decimal('1.2300')", fromZeroPadded.__Repr())
        AhkTest.AssertEqual("5", String(fromInt))
        AhkTest.AssertEqual("Decimal('5')", fromInt.__Repr())
    }

    static TestDecimalSupportsArithmeticComparisonAndUnaryLikePython310()
    {
        left := stdlib.decimal.Decimal("1.25")
        right := stdlib.decimal.Decimal("2.5")
        negative := stdlib.decimal.Decimal("-1.25")
        trailing := stdlib.decimal.Decimal("2.50")
        scientific := stdlib.decimal.Decimal("500.000")

        AhkTest.AssertEqual("3.75", String(stdlib.operator.add(left, right)))
        AhkTest.AssertEqual("1.25", String(stdlib.operator.sub(right, left)))
        AhkTest.AssertEqual("2.50", String(stdlib.operator.mul(left, stdlib.decimal.Decimal("2"))))
        AhkTest.AssertTrue(stdlib.operator.eq(stdlib.decimal.Decimal("1.0"), stdlib.decimal.Decimal("1.00")))
        AhkTest.AssertTrue(stdlib.operator.lt(left, stdlib.decimal.Decimal("2")))
        AhkTest.AssertFalse(stdlib.operator.truth(stdlib.decimal.Decimal("0")))
        AhkTest.AssertTrue(stdlib.operator.truth(left))
        AhkTest.AssertEqual("-1.25", String(stdlib.operator.pos(negative)))
        AhkTest.AssertEqual("-1.25", String(stdlib.operator.neg(left)))
        AhkTest.AssertEqual("1.25", String(stdlib.operator.abs(negative)))
        AhkTest.AssertEqual("2.5", String(trailing.normalize()))
        AhkTest.AssertEqual("5E+2", String(scientific.normalize()))
    }

    static TestDecimalSupportsFractionComparisonLikePython310()
    {
        AhkTest.AssertTrue(stdlib.operator.eq(stdlib.decimal.Decimal("1.5"), stdlib.fractions.Fraction(3, 2)))
        AhkTest.AssertTrue(stdlib.operator.lt(stdlib.decimal.Decimal("1.5"), stdlib.fractions.Fraction(2, 1)))
        AhkTest.AssertTrue(stdlib.operator.gt(stdlib.fractions.Fraction(2, 1), stdlib.decimal.Decimal("1.5")))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'decimal\.Decimal' and 'Fraction'", (*) => stdlib.operator.add(stdlib.decimal.Decimal("1.5"), stdlib.fractions.Fraction(1, 2)))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'Fraction' and 'decimal\.Decimal'", (*) => stdlib.operator.add(stdlib.fractions.Fraction(1, 2), stdlib.decimal.Decimal("1.5")))
    }

    static TestDecimalSupportsTrueDivisionLikePython310()
    {
        AhkTest.AssertEqual("0.625", String(stdlib.operator.truediv(stdlib.decimal.Decimal("1.25"), stdlib.decimal.Decimal("2"))))
        AhkTest.AssertEqual("0.125", String(stdlib.operator.truediv(stdlib.decimal.Decimal("1"), stdlib.decimal.Decimal("8"))))
        AhkTest.AssertEqual("0.5", String(stdlib.operator.truediv(stdlib.decimal.Decimal("1"), 2)))
        AhkTest.AssertEqual("4", String(stdlib.operator.truediv(2, stdlib.decimal.Decimal("0.5"))))
        AhkTest.AssertEqual("0.3333333333333333333333333333", String(stdlib.operator.truediv(stdlib.decimal.Decimal("1"), stdlib.decimal.Decimal("3"))))
        AhkTest.AssertEqual("0.6666666666666666666666666667", String(stdlib.operator.truediv(stdlib.decimal.Decimal("2"), stdlib.decimal.Decimal("3"))))
        AhkTest.AssertEqual("0.1666666666666666666666666667", String(stdlib.operator.truediv(stdlib.decimal.Decimal("1"), stdlib.decimal.Decimal("6"))))
        AhkTest.AssertEqual("0.50", String(stdlib.operator.truediv(stdlib.decimal.Decimal("1.00"), stdlib.decimal.Decimal("2"))))
    }

    static TestDecimalSupportsFloorDivisionAndModuloLikePython310()
    {
        AhkTest.AssertEqual("3", String(stdlib.operator.floordiv(stdlib.decimal.Decimal("7.5"), stdlib.decimal.Decimal("2"))))
        AhkTest.AssertEqual("-3", String(stdlib.operator.floordiv(stdlib.decimal.Decimal("-7.5"), stdlib.decimal.Decimal("2"))))
        AhkTest.AssertEqual("3", String(stdlib.operator.floordiv(stdlib.decimal.Decimal("7.5"), 2)))
        AhkTest.AssertEqual("2", String(stdlib.operator.floordiv(7, stdlib.decimal.Decimal("2.5"))))
        AhkTest.AssertEqual("1.5", String(stdlib.operator.mod(stdlib.decimal.Decimal("7.5"), stdlib.decimal.Decimal("2"))))
        AhkTest.AssertEqual("-1.5", String(stdlib.operator.mod(stdlib.decimal.Decimal("-7.5"), stdlib.decimal.Decimal("2"))))
        AhkTest.AssertEqual("1.5", String(stdlib.operator.mod(stdlib.decimal.Decimal("7.5"), 2)))
        AhkTest.AssertEqual("2.0", String(stdlib.operator.mod(7, stdlib.decimal.Decimal("2.5"))))
    }

    static TestDecimalRejectsPython310InvalidArguments()
    {
        AhkTest.RaisesMatch(Error, "ConversionSyntax|InvalidOperation", (*) => stdlib.decimal.Decimal("abc"))
        AhkTest.RaisesMatch(TypeError, "conversion from dict to Decimal is not supported", (*) => stdlib.decimal.Decimal(Map()))
        AhkTest.AssertEqual("2.25", String(stdlib.operator.add(stdlib.decimal.Decimal("1.25"), 1)))
        AhkTest.RaisesMatch(Error, "DivisionByZero", (*) => stdlib.operator.truediv(stdlib.decimal.Decimal("1"), 0))
        AhkTest.RaisesMatch(Error, "DivisionByZero", (*) => stdlib.operator.truediv(stdlib.decimal.Decimal("1"), stdlib.decimal.Decimal("0")))
        AhkTest.RaisesMatch(Error, "DivisionByZero", (*) => stdlib.operator.floordiv(stdlib.decimal.Decimal("1"), stdlib.decimal.Decimal("0")))
        AhkTest.RaisesMatch(Error, "InvalidOperation", (*) => stdlib.operator.mod(stdlib.decimal.Decimal("1"), stdlib.decimal.Decimal("0")))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for //: 'decimal\.Decimal' and 'str'", (*) => stdlib.operator.floordiv(stdlib.decimal.Decimal("1"), "2"))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for %: 'decimal\.Decimal' and 'str'", (*) => stdlib.operator.mod(stdlib.decimal.Decimal("1"), "2"))
    }
}

AhkTest.Collect(StdlibDecimalTest)
