#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibFractions
{
    static Fraction := AhkStdlibFractionsFraction
}

class AhkStdlibFractionsFraction
{
    static Call(thisClass, numerator := 0, denominator := unset)
    {
        if IsSet(denominator)
            return AhkStdlibFractionsFractionValue(numerator, denominator)
        return AhkStdlibFractionsFractionValue(numerator)
    }

    static from_float(value)
    {
        if !(value is Float)
            throw TypeError("Fraction.from_float() only takes floats, not " AhkStdlibFractionsFromFloatTypeString(value), -1)
        ratio := AhkStdlibFractionsFloatIntegerRatio(value)
        return AhkStdlibFractionsFractionValue(ratio[1], ratio[2])
    }
}

class AhkStdlibFractionsFractionValue
{
    __New(numerator := 0, denominator := unset)
    {
        values := AhkStdlibFractionsNormalize(numerator, denominator?)
        this.numerator := values.numerator
        this.denominator := values.denominator
    }

    ToString()
    {
        if this.denominator = 1
            return String(this.numerator)
        return this.numerator "/" this.denominator
    }

    __Repr()
    {
        return "Fraction(" this.numerator ", " this.denominator ")"
    }

    to_float()
    {
        return this.numerator / this.denominator
    }

    as_integer_ratio()
    {
        return [this.numerator, this.denominator]
    }

    limit_denominator(max_denominator := 1000000)
    {
        if !(max_denominator is Number)
            throw TypeError("'" AhkStdlibFractionsTypeName(max_denominator) "' object cannot be interpreted as an integer", -1)
        max_denominator := Floor(max_denominator)
        if max_denominator < 1
            throw ValueError("max_denominator should be at least 1", -1)

        if this.denominator <= max_denominator
            return AhkStdlibFractionsFractionValue(this.numerator, this.denominator)

        p0 := 0, q0 := 1
        p1 := 1, q1 := 0
        n := this.numerator
        d := this.denominator

        while true {
            a := n // d
            q2 := q0 + a * q1
            if q2 > max_denominator
                break
            p0Temp := p1, q0Temp := q1
            p1 := p0 + a * p1
            q1 := q2
            p0 := p0Temp
            q0 := q0Temp
            nTemp := Mod(n, d)
            n := d
            d := nTemp
            if d = 0
                break
        }

        k := (max_denominator - q0) // q1
        bound1 := AhkStdlibFractionsFractionValue(p0 + k * p1, q0 + k * q1)
        bound2 := AhkStdlibFractionsFractionValue(p1, q1)
        diff1 := Abs(bound1.to_float() - this.to_float())
        diff2 := Abs(bound2.to_float() - this.to_float())
        if diff2 < diff1
            return bound2
        if diff1 < diff2
            return bound1
        if bound2.denominator <= bound1.denominator
            return bound2
        return bound1
    }

    __Compare(other, op)
    {
        other := AhkStdlibFractionsCoerceRational(other)
        if other = ""
            return ""
        left := this.numerator * other.denominator
        right := other.numerator * this.denominator
        if left = right
            return 0
        return left < right ? -1 : 1
    }

    __Add(other)
    {
        other := AhkStdlibFractionsCoerceRational(other)
        if other = ""
            return ""
        return AhkStdlibFractionsFractionValue(
            this.numerator * other.denominator + other.numerator * this.denominator,
            this.denominator * other.denominator
        )
    }

    __Sub(other)
    {
        other := AhkStdlibFractionsCoerceRational(other)
        if other = ""
            return ""
        return AhkStdlibFractionsFractionValue(
            this.numerator * other.denominator - other.numerator * this.denominator,
            this.denominator * other.denominator
        )
    }

    __Mul(other)
    {
        other := AhkStdlibFractionsCoerceRational(other)
        if other = ""
            return ""
        return AhkStdlibFractionsFractionValue(
            this.numerator * other.numerator,
            this.denominator * other.denominator
        )
    }

    __Div(other)
    {
        other := AhkStdlibFractionsCoerceRational(other)
        if other = ""
            return ""
        return AhkStdlibFractionsFractionValue(
            this.numerator * other.denominator,
            this.denominator * other.numerator
        )
    }

    __Neg()
    {
        return AhkStdlibFractionsFractionValue(-this.numerator, this.denominator)
    }

    __Pos()
    {
        return AhkStdlibFractionsFractionValue(this.numerator, this.denominator)
    }
}

stdlib.fractions := AhkStdlibFractions

AhkStdlibFractionsNormalize(numerator, denominator := unset)
{
    if !IsSet(denominator)
        return AhkStdlibFractionsNormalizeSingle(numerator)

    if !(numerator is Integer) || !(denominator is Integer)
        throw TypeError("both arguments should be Rational instances", -1)
    if denominator = 0
        throw ZeroDivisionError("Fraction(1, 0)", -1)
    return AhkStdlibFractionsNormalizePair(numerator, denominator)
}

AhkStdlibFractionsCoerceRational(value)
{
    if Type(value) = "AhkStdlibFractionsFractionValue"
        return value
    if value is Integer
        return AhkStdlibFractionsFractionValue(value, 1)
    if value is Float
        return AhkStdlibFractionsFraction.from_float(value)
    return ""
}

AhkStdlibFractionsTypeName(value)
{
    if AhkStdlibIsNone(value)
        return "NoneType"
    if value is Map
        return "dict"
    if value is Array
        return "list"
    if value is String
        return "str"
    if value is Float
        return "float"
    if value is Integer
        return "int"
    if IsObject(value) && Type(value) != "Object" {
        dot := InStr(Type(value), ".", false, -1)
        return dot ? SubStr(Type(value), dot + 1) : Type(value)
    }
    if IsObject(value)
        return "object"
    return Type(value)
}

AhkStdlibFractionsFromFloatTypeString(value)
{
    if AhkStdlibIsNone(value)
        return "None (NoneType)"
    if value is Map
        return "{} (dict)"
    if value is Array
        return "[] (list)"
    if value is String
        return "'" value "' (str)"
    return AhkStdlibFractionsTypeName(value)
}

AhkStdlibFractionsNormalizeSingle(value)
{
    if value is Integer
        return { numerator: value, denominator: 1 }
    if value is Float
        return AhkStdlibFractionsNormalizePair(AhkStdlibFractionsFloatIntegerRatio(value)*)
    if value is String
        return AhkStdlibFractionsNormalizeFromString(value)
    throw TypeError("argument should be a string or a Rational instance", -1)
}

AhkStdlibFractionsFloatIntegerRatio(value)
{
    if value = 0
        return [0, 1]

    if value < 0 {
        ratio := AhkStdlibFractionsFloatIntegerRatio(-value)
        return [-ratio[1], ratio[2]]
    }

    significand := value
    exponent := 0
    while significand != Floor(significand) {
        significand *= 2
        exponent -= 1
    }

    numerator := Integer(significand)
    denominator := exponent < 0 ? 2 ** (-exponent) : 1
    if exponent > 0
        numerator *= 2 ** exponent

    normalized := AhkStdlibFractionsNormalizePair(numerator, denominator)
    return [normalized.numerator, normalized.denominator]
}

AhkStdlibFractionsNormalizeFromString(text)
{
    slash := InStr(text, "/")
    if slash {
        left := Trim(SubStr(text, 1, slash - 1))
        right := Trim(SubStr(text, slash + 1))
        if !AhkStdlibFractionsIsSignedInteger(left) || !AhkStdlibFractionsIsSignedInteger(right)
            throw ValueError("Invalid literal for Fraction: '" text "'", -1)
        denominator := Integer(right)
        if denominator = 0
            throw ZeroDivisionError("Fraction(1, 0)", -1)
        return AhkStdlibFractionsNormalizePair(Integer(left), denominator)
    }

    if AhkStdlibFractionsIsSignedInteger(text)
        return { numerator: Integer(text), denominator: 1 }
    if AhkStdlibFractionsIsDecimalLiteral(text)
        return AhkStdlibFractionsNormalizeDecimalString(text)
    throw ValueError("Invalid literal for Fraction: '" text "'", -1)
}

AhkStdlibFractionsNormalizeDecimalString(text)
{
    negative := false
    if SubStr(text, 1, 1) = "-" {
        negative := true
        text := SubStr(text, 2)
    } else if SubStr(text, 1, 1) = "+" {
        text := SubStr(text, 2)
    }

    pieces := StrSplit(text, ".")
    if pieces.Length != 2
        throw ValueError("Invalid literal for Fraction: '" (negative ? "-" : "") text "'", -1)
    if !AhkStdlibFractionsAllDigits(pieces[1]) || !AhkStdlibFractionsAllDigits(pieces[2])
        throw ValueError("Invalid literal for Fraction: '" (negative ? "-" : "") text "'", -1)

    scale := 10 ** StrLen(pieces[2])
    numerator := Integer(pieces[1]) * scale + Integer(pieces[2])
    if negative
        numerator := -numerator
    return AhkStdlibFractionsNormalizePair(numerator, scale)
}

AhkStdlibFractionsNormalizePair(numerator, denominator)
{
    if denominator < 0 {
        numerator := -numerator
        denominator := -denominator
    }
    gcd := AhkStdlibFractionsGcd(Abs(numerator), denominator)
    return { numerator: numerator // gcd, denominator: denominator // gcd }
}

AhkStdlibFractionsGcd(a, b)
{
    while b != 0 {
        temp := Mod(a, b)
        a := b
        b := temp
    }
    return a = 0 ? 1 : a
}

AhkStdlibFractionsIsSignedInteger(text)
{
    if text = ""
        return false
    start := 1
    first := SubStr(text, 1, 1)
    if first = "-" || first = "+"
        start := 2
    if start > StrLen(text)
        return false
    loop parse SubStr(text, start)
    {
        if !InStr("0123456789", A_LoopField)
            return false
    }
    return true
}

AhkStdlibFractionsIsDecimalLiteral(text)
{
    parts := StrSplit(text, ".")
    if parts.Length != 2
        return false
    if parts[1] = "" || parts[2] = ""
        return false
    if !AhkStdlibFractionsIsSignedInteger(parts[1])
        return false
    return AhkStdlibFractionsAllDigits(parts[2])
}

AhkStdlibFractionsAllDigits(text)
{
    if text = ""
        return false
    loop parse text
    {
        if !InStr("0123456789", A_LoopField)
            return false
    }
    return true
}
