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
