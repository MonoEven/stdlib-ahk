#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibMath
{
    static pi := 3.141592653589793
    static e := 2.718281828459045
    static tau := 6.283185307179586

    static floor(x) => Floor(x)
    static ceil(x) => Ceil(x)
    static trunc(x) => Integer(x)
    static fabs(x) => Abs(x)
    static sqrt(x) => Sqrt(x)

    static factorial(n) => AhkStdlibMathFactorial(n)
    static gcd(values*) => AhkStdlibMathGcd(values*)
    static lcm(values*) => AhkStdlibMathLcm(values*)
    static comb(n, k) => AhkStdlibMathComb(n, k)
    static perm(n, k := unset) => AhkStdlibMathPerm(n, k?)
    static prod(iterable, start := 1) => AhkStdlibMathProd(iterable, start)
    static fsum(iterable) => AhkStdlibMathFsum(iterable)
    static degrees(x) => x * 180 / AhkStdlibMath.pi
    static radians(x) => x * AhkStdlibMath.pi / 180
    static dist(p, q) => AhkStdlibMathDist(p, q)
    static hypot(coordinates*) => AhkStdlibMathHypot(coordinates*)
    static isclose(a, b, rel_tol := 0.000000001, abs_tol := 0.0) => AhkStdlibMathIsClose(a, b, rel_tol, abs_tol)

    static inf := AhkStdlibMathInf()
    static nan := AhkStdlibMathNan()

    static sin(x) => AhkStdlibMathCrt1("sin", x)
    static cos(x) => AhkStdlibMathCrt1("cos", x)
    static tan(x) => AhkStdlibMathCrt1("tan", x)
    static asin(x) => AhkStdlibMathCrt1("asin", x)
    static acos(x) => AhkStdlibMathCrt1("acos", x)
    static atan(x) => AhkStdlibMathCrt1("atan", x)
    static atan2(y, x) => AhkStdlibMathCrt2("atan2", y, x)
    static sinh(x) => AhkStdlibMathCrt1("sinh", x)
    static cosh(x) => AhkStdlibMathCrt1("cosh", x)
    static tanh(x) => AhkStdlibMathCrt1("tanh", x)
    static asinh(x) => AhkStdlibMathCrt1("asinh", x)
    static acosh(x) => AhkStdlibMathCrt1("acosh", x)
    static atanh(x) => AhkStdlibMathCrt1("atanh", x)
    static exp(x) => AhkStdlibMathCrt1("exp", x)
    static exp2(x) => AhkStdlibMathExp2(x)
    static expm1(x) => AhkStdlibMathCrt1("expm1", x)
    static nextafter(x, y) => AhkStdlibMathCrt2("nextafter", x, y)
    static ulp(x) => AhkStdlibMathUlp(x)
    static log(x, base := unset) => AhkStdlibMathLog(x, base?)
    static log2(x) => AhkStdlibMathCrt1("log2", x)
    static log10(x) => AhkStdlibMathCrt1("log10", x)
    static log1p(x) => AhkStdlibMathCrt1("log1p", x)
    static pow(x, y) => AhkStdlibMathPow(x, y)
    static copysign(x, y) => AhkStdlibMathCrt2("copysign", x, y)
    static fmod(x, y) => AhkStdlibMathCrt2("fmod", x, y)
    static remainder(x, y) => AhkStdlibMathCrt2("remainder", x, y)
    static ldexp(x, i) => AhkStdlibMathLdexp(x, i)
    static frexp(x) => AhkStdlibMathFrexp(x)
    static modf(x) => AhkStdlibMathModf(x)
    static isqrt(n) => AhkStdlibMathIsqrt(n)
    static isnan(x) => AhkStdlibMathIsNan(x)
    static isinf(x) => AhkStdlibMathIsInf(x)
    static isfinite(x) => AhkStdlibMathIsFinite(x)
}

stdlib.math := AhkStdlibMath

AhkStdlibMathFactorial(n)
{
    AhkStdlibMathRequireInteger("factorial", n)
    if n < 0
        throw ValueError("factorial() not defined for negative values", -1)

    result := 1
    loop n
        result *= A_Index
    return result
}

AhkStdlibMathGcd(values*)
{
    if values.Length = 0
        return 0

    result := 0
    for value in values {
        AhkStdlibMathRequireInteger("gcd", value)
        result := AhkStdlibMathGcdPair(result, value)
    }
    return result
}

AhkStdlibMathLcm(values*)
{
    if values.Length = 0
        return 1

    result := 1
    for value in values {
        AhkStdlibMathRequireInteger("lcm", value)
        if value = 0
            return 0
        result := Abs(result * value) // AhkStdlibMathGcdPair(result, value)
    }
    return Abs(result)
}

AhkStdlibMathComb(n, k)
{
    AhkStdlibMathCheckCombinatoricInputs(n, k)
    if k > n
        return 0

    k := Min(k, n - k)
    result := 1
    loop k
        result := result * (n - A_Index + 1) // A_Index
    return result
}

AhkStdlibMathPerm(n, k := unset)
{
    if !IsSet(k)
        k := n
    AhkStdlibMathCheckCombinatoricInputs(n, k)
    if k > n
        return 0

    result := 1
    loop k
        result *= n - A_Index + 1
    return result
}

AhkStdlibMathProd(iterable, start := 1)
{
    result := start
    for value in iterable
        result *= value
    return result
}

AhkStdlibMathFsum(iterable)
{
    partials := []
    for value in iterable {
        x := value + 0.0
        nextPartials := []

        for y in partials {
            if Abs(x) < Abs(y) {
                temp := x
                x := y
                y := temp
            }

            hi := x + y
            lo := y - (hi - x)
            if lo != 0.0
                nextPartials.Push(lo)
            x := hi
        }

        nextPartials.Push(x)
        partials := nextPartials
    }

    total := 0.0
    for value in partials
        total += value
    return total
}

AhkStdlibMathDist(p, q)
{
    pValues := AhkStdlibMathList(p)
    qValues := AhkStdlibMathList(q)
    if pValues.Length != qValues.Length
        throw ValueError("both points must have the same dimension", -1)

    differences := []
    loop pValues.Length
        differences.Push(pValues[A_Index] - qValues[A_Index])
    return AhkStdlibMathHypot(differences*)
}

AhkStdlibMathHypot(coordinates*)
{
    maxAbs := 0.0
    for value in coordinates
        maxAbs := Max(maxAbs, Abs(value))
    if maxAbs = 0.0
        return 0.0

    total := 0.0
    for value in coordinates {
        scaled := value / maxAbs
        total += scaled ** 2
    }
    return maxAbs * Sqrt(total)
}

AhkStdlibMathIsClose(a, b, rel_tol := 0.000000001, abs_tol := 0.0)
{
    if rel_tol < 0.0 || abs_tol < 0.0
        throw ValueError("tolerances must be non-negative", -1)
    if a == b
        return true

    difference := Abs(b - a)
    return difference <= Max(rel_tol * Max(Abs(a), Abs(b)), abs_tol)
}

AhkStdlibMathList(iterable)
{
    if iterable is Array
        return iterable.Clone()
    if IsObject(iterable) && HasMethod(iterable, "__Enum") {
        values := []
        for value in iterable
            values.Push(value)
        return values
    }
    throw TypeError("'" Type(iterable) "' object is not iterable", -1)
}

AhkStdlibMathGcdPair(a, b)
{
    a := Abs(a)
    b := Abs(b)
    while b != 0 {
        temp := Mod(a, b)
        a := b
        b := temp
    }
    return a
}

AhkStdlibMathCheckCombinatoricInputs(n, k)
{
    AhkStdlibMathRequireInteger("n", n)
    AhkStdlibMathRequireInteger("k", k)
    if n < 0
        throw ValueError("n must be a non-negative integer", -1)
    if k < 0
        throw ValueError("k must be a non-negative integer", -1)
}

AhkStdlibMathRequireInteger(name, value)
{
    if !(value is Integer)
        throw TypeError("'" Type(value) "' object cannot be interpreted as an integer", -1)
}

AhkStdlibMathInf()
{
    static value := AhkStdlibMathBitsToDouble(0x7FF0000000000000)
    return value
}

AhkStdlibMathNan()
{
    static value := AhkStdlibMathBitsToDouble(0x7FF8000000000000)
    return value
}

AhkStdlibMathBitsToDouble(bits)
{
    bytes := Buffer(8, 0)
    NumPut("Int64", bits, bytes, 0)
    return NumGet(bytes, 0, "Double")
}

AhkStdlibMathRequireNumber(value)
{
    if value is Number
        return value + 0.0
    if AhkStdlibIsBool(value)
        return value.Value ? 1.0 : 0.0
    throw TypeError("must be real number, not " AhkStdlibPythonTypeName(value), -1)
}

AhkStdlibMathCrt1(name, x)
{
    x := AhkStdlibMathRequireNumber(x)
    return DllCall("ucrtbase\" name, "Double", x, "Cdecl Double")
}

AhkStdlibMathCrt2(name, a, b)
{
    a := AhkStdlibMathRequireNumber(a)
    b := AhkStdlibMathRequireNumber(b)
    return DllCall("ucrtbase\" name, "Double", a, "Double", b, "Cdecl Double")
}

AhkStdlibMathLog(x, base := unset)
{
    x := AhkStdlibMathRequireNumber(x)
    if x <= 0.0
        throw ValueError("math domain error", -1)
    natural := DllCall("ucrtbase\log", "Double", x, "Cdecl Double")
    if !IsSet(base)
        return natural
    base := AhkStdlibMathRequireNumber(base)
    if base <= 0.0
        throw ValueError("math domain error", -1)
    return natural / DllCall("ucrtbase\log", "Double", base, "Cdecl Double")
}

AhkStdlibMathPow(x, y)
{
    x := AhkStdlibMathRequireNumber(x)
    y := AhkStdlibMathRequireNumber(y)
    return DllCall("ucrtbase\pow", "Double", x, "Double", y, "Cdecl Double")
}

AhkStdlibMathLdexp(x, i)
{
    x := AhkStdlibMathRequireNumber(x)
    if !(i is Integer)
        throw TypeError("Expected an int as second argument to ldexp.", -1)
    return DllCall("ucrtbase\ldexp", "Double", x, "Int", i, "Cdecl Double")
}

AhkStdlibMathFrexp(x)
{
    x := AhkStdlibMathRequireNumber(x)
    exponent := 0
    mantissa := DllCall("ucrtbase\frexp", "Double", x, "Int*", &exponent, "Cdecl Double")
    return AhkStdlibTuple([mantissa, exponent])
}

AhkStdlibMathModf(x)
{
    x := AhkStdlibMathRequireNumber(x)
    integerPart := 0.0
    intBytes := Buffer(8, 0)
    fractional := DllCall("ucrtbase\modf", "Double", x, "Ptr", intBytes.Ptr, "Cdecl Double")
    integerPart := NumGet(intBytes, 0, "Double")
    return AhkStdlibTuple([fractional, integerPart])
}

AhkStdlibMathIsqrt(n)
{
    AhkStdlibMathRequireInteger("isqrt", n)
    if n < 0
        throw ValueError("isqrt() argument must be nonnegative", -1)
    if n = 0
        return 0
    x := Integer(Sqrt(n))
    while x * x > n
        x -= 1
    while (x + 1) * (x + 1) <= n
        x += 1
    return x
}

AhkStdlibMathIsNan(x)
{
    x := AhkStdlibMathRequireNumber(x)
    return x != x
}

AhkStdlibMathIsInf(x)
{
    x := AhkStdlibMathRequireNumber(x)
    return x = AhkStdlibMathInf() || x = -AhkStdlibMathInf()
}

AhkStdlibMathIsFinite(x)
{
    x := AhkStdlibMathRequireNumber(x)
    return x = x && x != AhkStdlibMathInf() && x != -AhkStdlibMathInf()
}

AhkStdlibMathExp2(x)
{
    x := AhkStdlibMathRequireNumber(x)
    ; Python's math.exp2(x) = 2**x. CRT exp2 exists in ucrtbase.
    return DllCall("ucrtbase\exp2", "Double", x, "Cdecl Double")
}

AhkStdlibMathUlp(x)
{
    x := AhkStdlibMathRequireNumber(x)
    if x != x
        return x  ; ulp(nan) is nan
    inf := AhkStdlibMathInf()
    if x = inf || x = -inf
        return inf
    if x = 0.0
        return AhkStdlibMathBitsToDouble(1)  ; smallest subnormal positive
    ax := Abs(x)
    return DllCall("ucrtbase\nextafter", "Double", ax, "Double", inf, "Cdecl Double") - ax
}
