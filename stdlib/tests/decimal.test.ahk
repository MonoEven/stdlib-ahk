#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\decimal>
#Include <stdlib\fractions>
#Include <stdlib\operator>

class StdlibDecimalTest
{
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
