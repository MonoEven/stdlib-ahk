#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\cmath>
#Include <stdlib\operator>

class StdlibCmathTest
{
    static Close(actual, expReal, expImag, tol := 1e-9)
    {
        AhkTest.AssertTrue(Abs(actual.real - expReal) < tol, "real " actual.real " != " expReal)
        AhkTest.AssertTrue(Abs(actual.imag - expImag) < tol, "imag " actual.imag " != " expImag)
    }

    static TestConstruction()
    {
        z := stdlib.complex(1, 2)
        AhkTest.AssertEqual(1.0, z.real)
        AhkTest.AssertEqual(2.0, z.imag)

        AhkTest.AssertEqual(3.0, stdlib.complex(3).real)
        AhkTest.AssertEqual(0.0, stdlib.complex(3).imag)

        ; complex from complex args
        StdlibCmathTest.Close(stdlib.complex(stdlib.complex(1, 2)), 1, 2)
        ; complex(1, complex(0,1)) == 0j in Python: real 1 - imag.imag(1) = 0
        StdlibCmathTest.Close(stdlib.complex(1, stdlib.complex(0, 1)), 0, 0)
    }

    static TestParse()
    {
        StdlibCmathTest.Close(stdlib.complex("1+2j"), 1, 2)
        StdlibCmathTest.Close(stdlib.complex("3"), 3, 0)
        StdlibCmathTest.Close(stdlib.complex("1-2j"), 1, -2)
        StdlibCmathTest.Close(stdlib.complex("j"), 0, 1)
        StdlibCmathTest.Close(stdlib.complex("-j"), 0, -1)
        StdlibCmathTest.Close(stdlib.complex("2j"), 0, 2)
        StdlibCmathTest.Close(stdlib.complex("(1+2j)"), 1, 2)
        StdlibCmathTest.Close(stdlib.complex("1.5e2+3j"), 150, 3)
        AhkTest.AssertThrows(ValueError, (*) => stdlib.complex("1 + 2j"))
        AhkTest.AssertThrows(ValueError, (*) => stdlib.complex("garbage"))
    }

    static TestRepr()
    {
        AhkTest.AssertEqual("(1+2j)", String(stdlib.complex(1, 2)))
        AhkTest.AssertEqual("(1.5+2j)", String(stdlib.complex(1.5, 2)))
        AhkTest.AssertEqual("(-1-2j)", String(stdlib.complex(-1, -2)))
        AhkTest.AssertEqual("1j", String(stdlib.complex(0, 1)))
        AhkTest.AssertEqual("-1j", String(stdlib.complex(0, -1)))
        AhkTest.AssertEqual("(3+0j)", String(stdlib.complex(3, 0)))
        AhkTest.AssertEqual("0j", String(stdlib.complex(0, 0)))
        AhkTest.AssertEqual("(2.5+0j)", String(stdlib.complex(2.5, 0)))
        AhkTest.AssertEqual("(3+4j)", String(stdlib.complex(3.0, 4.0)))
        AhkTest.AssertEqual("(100+200j)", String(stdlib.complex(100, 200)))
        AhkTest.AssertEqual("(0.1+0.2j)", String(stdlib.complex(0.1, 0.2)))
        AhkTest.AssertEqual("(1e+300+1j)", String(stdlib.complex(1e300, 1)))
    }

    static TestArithmetic()
    {
        op := stdlib.operator
        StdlibCmathTest.Close(op.add(stdlib.complex(1, 2), stdlib.complex(3, 4)), 4, 6)
        StdlibCmathTest.Close(op.sub(stdlib.complex(1, 2), stdlib.complex(3, 4)), -2, -2)
        StdlibCmathTest.Close(op.mul(stdlib.complex(1, 2), stdlib.complex(3, 4)), -5, 10)
        StdlibCmathTest.Close(op.truediv(stdlib.complex(1, 2), stdlib.complex(3, 4)), 0.44, 0.08)
        StdlibCmathTest.Close(op.pow(stdlib.complex(1, 2), 2), -3, 4)
        StdlibCmathTest.Close(op.neg(stdlib.complex(1, 2)), -1, -2)
        AhkTest.AssertTrue(Abs(op.abs(stdlib.complex(3, 4)) - 5.0) < 1e-9)
        ; mixed with real (either side)
        StdlibCmathTest.Close(op.add(stdlib.complex(1, 2), 3), 4, 2)
        StdlibCmathTest.Close(op.add(3, stdlib.complex(1, 2)), 4, 2)
        StdlibCmathTest.Close(op.sub(10, stdlib.complex(1, 2)), 9, -2)
        StdlibCmathTest.Close(op.mul(stdlib.complex(1, 2), 2.0), 2, 4)
        StdlibCmathTest.Close(op.truediv(stdlib.complex(4, 2), 2), 2, 1)
        StdlibCmathTest.Close(op.pow(stdlib.complex(1, 2), stdlib.complex(2, 1)), -1.6401010184280038, 0.202050398556709)
    }

    static TestEquality()
    {
        op := stdlib.operator
        AhkTest.AssertTrue(op.eq(stdlib.complex(1, 2), stdlib.complex(1, 2)))
        AhkTest.AssertFalse(op.eq(stdlib.complex(1, 2), stdlib.complex(1, 3)))
        ; complex == real when imag is zero
        AhkTest.AssertTrue(op.eq(stdlib.complex(3, 0), 3))
        AhkTest.AssertFalse(op.eq(stdlib.complex(3, 1), 3))
        AhkTest.AssertTrue(op.ne(stdlib.complex(1, 2), stdlib.complex(1, 3)))
        ; ordering is unsupported -> raises TypeError
        AhkTest.AssertThrows(TypeError, (*) => op.lt(stdlib.complex(1, 0), stdlib.complex(2, 0)))
    }

    static TestConjugateAndAbs()
    {
        StdlibCmathTest.Close(stdlib.complex(3, 4).conjugate(), 3, -4)
        ; abs() isn't overloadable in AHK; magnitude is exposed via cmath.polar
        polar := stdlib.cmath.polar(stdlib.complex(3, 4))
        AhkTest.AssertTrue(Abs(polar[1] - 5.0) < 1e-9)
    }

    static TestSqrtExpLog()
    {
        StdlibCmathTest.Close(stdlib.cmath.sqrt(-1), 0, 1)
        StdlibCmathTest.Close(stdlib.cmath.sqrt(stdlib.complex(3, 4)), 2, 1)
        StdlibCmathTest.Close(stdlib.cmath.exp(stdlib.complex(1, 2)), -1.1312043837568135, 2.4717266720048188)
        StdlibCmathTest.Close(stdlib.cmath.log(stdlib.complex(1, 1)), 0.34657359027997264, 0.7853981633974483)
        StdlibCmathTest.Close(stdlib.cmath.log(stdlib.complex(1, 1), 10), 0.15051499783199057, 0.3410940884604603)
        StdlibCmathTest.Close(stdlib.cmath.log10(stdlib.complex(1, 1)), 0.15051499783199057, 0.3410940884604603)
    }

    static TestTrig()
    {
        StdlibCmathTest.Close(stdlib.cmath.sin(stdlib.complex(1, 1)), 1.2984575814159773, 0.6349639147847361)
        StdlibCmathTest.Close(stdlib.cmath.cos(stdlib.complex(1, 1)), 0.8337300251311491, -0.9888977057628651)
        StdlibCmathTest.Close(stdlib.cmath.tan(stdlib.complex(1, 1)), 0.2717525853195118, 1.0839233273386946)
        StdlibCmathTest.Close(stdlib.cmath.sinh(stdlib.complex(1, 1)), 0.6349639147847361, 1.2984575814159773)
        StdlibCmathTest.Close(stdlib.cmath.cosh(stdlib.complex(1, 1)), 0.8337300251311491, 0.9888977057628651)
        StdlibCmathTest.Close(stdlib.cmath.tanh(stdlib.complex(1, 1)), 1.0839233273386946, 0.2717525853195118)
    }

    static TestInverseTrig()
    {
        StdlibCmathTest.Close(stdlib.cmath.asin(stdlib.complex(1, 1)), 0.6662394324925153, 1.0612750619050357)
        StdlibCmathTest.Close(stdlib.cmath.acos(stdlib.complex(1, 1)), 0.9045568943023814, -1.0612750619050357)
        StdlibCmathTest.Close(stdlib.cmath.atan(stdlib.complex(1, 1)), 1.0172219678978514, 0.40235947810852507)
        StdlibCmathTest.Close(stdlib.cmath.asinh(stdlib.complex(1, 1)), 1.0612750619050357, 0.6662394324925153)
        StdlibCmathTest.Close(stdlib.cmath.acosh(stdlib.complex(1, 1)), 1.0612750619050357, 0.9045568943023813)
        StdlibCmathTest.Close(stdlib.cmath.atanh(stdlib.complex(1, 1)), 0.40235947810852507, 1.0172219678978514)
    }

    static TestPolarRectPhase()
    {
        AhkTest.AssertTrue(Abs(stdlib.cmath.phase(stdlib.complex(1, 1)) - 0.7853981633974483) < 1e-9)
        polar := stdlib.cmath.polar(stdlib.complex(1, 1))
        AhkTest.AssertTrue(Abs(polar[1] - 1.4142135623730951) < 1e-9)
        AhkTest.AssertTrue(Abs(polar[2] - 0.7853981633974483) < 1e-9)
        StdlibCmathTest.Close(stdlib.cmath.rect(1.4142135623730951, 0.7853981633974483), 1, 1)
    }

    static TestConstantsAndPredicates()
    {
        AhkTest.AssertEqual(3.141592653589793, stdlib.cmath.pi)
        AhkTest.AssertEqual(2.718281828459045, stdlib.cmath.e)
        AhkTest.AssertEqual(6.283185307179586, stdlib.cmath.tau)
        AhkTest.AssertTrue(stdlib.cmath.isfinite(stdlib.complex(1, 2)).Value)
        AhkTest.AssertFalse(stdlib.cmath.isfinite(stdlib.cmath.infj).Value)
        AhkTest.AssertTrue(stdlib.cmath.isinf(stdlib.cmath.infj).Value)
        AhkTest.AssertTrue(stdlib.cmath.isnan(stdlib.cmath.nanj).Value)
        AhkTest.AssertTrue(stdlib.cmath.isclose(stdlib.complex(1, 1), stdlib.complex(1, 1.0000000001)).Value)
        AhkTest.AssertFalse(stdlib.cmath.isclose(stdlib.complex(1, 1), stdlib.complex(1, 2)).Value)
    }

    static TestDivByZeroRaises()
    {
        AhkTest.AssertThrows(ZeroDivisionError, (*) => stdlib.operator.truediv(stdlib.complex(1, 1), stdlib.complex(0, 0)))
    }
}

AhkTest.Collect(StdlibCmathTest)
