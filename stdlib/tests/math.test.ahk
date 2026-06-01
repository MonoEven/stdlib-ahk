#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\math>

class StdlibMathTest
{
    static TestConstantsAndBasicNumericFunctionsFollowPythonMath()
    {
        AhkTest.AssertEqual(3.141592653589793, stdlib.math.pi)
        AhkTest.AssertEqual(2.718281828459045, stdlib.math.e)
        AhkTest.AssertEqual(6.283185307179586, stdlib.math.tau)
        AhkTest.AssertEqual(3, stdlib.math.floor(3.9))
        AhkTest.AssertEqual(-4, stdlib.math.floor(-3.1))
        AhkTest.AssertEqual(4, stdlib.math.ceil(3.1))
        AhkTest.AssertEqual(-3, stdlib.math.ceil(-3.9))
        AhkTest.AssertEqual(-3, stdlib.math.trunc(-3.9))
        AhkTest.AssertEqual(3.5, stdlib.math.fabs(-3.5))
        AhkTest.AssertEqual(5, stdlib.math.sqrt(25))
    }

    static TestCombinatoricsAndIntegerHelpersFollowPythonMath()
    {
        AhkTest.AssertEqual(1, stdlib.math.factorial(0))
        AhkTest.AssertEqual(120, stdlib.math.factorial(5))
        AhkTest.RaisesMatch(ValueError, "factorial\(\) not defined for negative values", (*) => stdlib.math.factorial(-1))
        AhkTest.RaisesMatch(TypeError, "object cannot be interpreted as an integer", (*) => stdlib.math.factorial(1.0))

        AhkTest.AssertEqual(10, stdlib.math.comb(5, 2))
        AhkTest.AssertEqual(0, stdlib.math.comb(3, 5))
        AhkTest.AssertEqual(20, stdlib.math.perm(5, 2))
        AhkTest.AssertEqual(0, stdlib.math.perm(3, 5))
        AhkTest.AssertEqual(120, stdlib.math.perm(5))

        AhkTest.AssertEqual(0, stdlib.math.gcd())
        AhkTest.AssertEqual(6, stdlib.math.gcd(48, -18))
        AhkTest.AssertEqual(1, stdlib.math.lcm())
        AhkTest.AssertEqual(24, stdlib.math.lcm(6, 8))
        AhkTest.AssertEqual(0, stdlib.math.lcm(0, 8))
    }

    static TestIterableAndGeometryHelpersFollowPythonMath()
    {
        AhkTest.AssertEqual(24, stdlib.math.prod([1, 2, 3, 4]))
        AhkTest.AssertEqual(10, stdlib.math.prod([], 10))
        AhkTest.AssertApprox(0.6, stdlib.math.fsum([0.1, 0.2, 0.3]))
        AhkTest.AssertEqual(180, stdlib.math.degrees(stdlib.math.pi))
        AhkTest.AssertEqual(stdlib.math.pi, stdlib.math.radians(180))
        AhkTest.AssertEqual(5, stdlib.math.dist([0, 0], [3, 4]))
        AhkTest.AssertEqual(5, stdlib.math.hypot(3, 4))
        AhkTest.AssertEqual(3, stdlib.math.hypot(1, 2, 2))
    }

    static TestFsumPreservesSmallTermsDuringCancellation()
    {
        AhkTest.AssertEqual(1.0, stdlib.math.fsum([1.0e100, 1.0, -1.0e100]))
    }

    static TestHypotScalesExtremeValuesLikePython()
    {
        AhkTest.AssertApprox(1.4142135623730951e308, stdlib.math.hypot(1.0e308, 1.0e308), { Rel: 1.0e-15, Abs: 0.0 })
        AhkTest.AssertApprox(1.414213562373095e-200, stdlib.math.hypot(1.0e-200, 1.0e-200), { Rel: 1.0e-15, Abs: 0.0 })
    }

    static TestDistScalesExtremeCoordinateDifferencesLikePython()
    {
        AhkTest.AssertApprox(1.4142135623730951e308, stdlib.math.dist([1.0e308, 0.0], [0.0, 1.0e308]), { Rel: 1.0e-15, Abs: 0.0 })
    }

    static TestDistAcceptsIterablePointsLikePython()
    {
        p := StdlibMathIterablePoint([0, 0])
        q := StdlibMathIterablePoint([3, 4])

        AhkTest.AssertEqual(5, stdlib.math.dist(p, q))
    }

    static TestIscloseFollowsPythonDefaultAndToleranceRules()
    {
        AhkTest.AssertTrue(stdlib.math.isclose(1.0, 1.0000000001))
        AhkTest.AssertFalse(stdlib.math.isclose(1.0, 1.1))
        AhkTest.AssertTrue(stdlib.math.isclose(0.0, 0.0001, 0.0, 0.001))
        AhkTest.RaisesMatch(ValueError, "tolerances must be non-negative", (*) => stdlib.math.isclose(1.0, 1.0, -0.1))
    }
}

class StdlibMathIterablePoint
{
    __New(values)
    {
        this.Values := values
    }

    __Enum(numberOfVars)
    {
        return this.Values.__Enum(numberOfVars)
    }
}

AhkTest.Collect(StdlibMathTest)
