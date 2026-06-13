#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibDecimalDecimalException extends Error
{
}

class AhkStdlibDecimalClamped extends AhkStdlibDecimalDecimalException
{
}

class AhkStdlibDecimalRounded extends AhkStdlibDecimalDecimalException
{
}

class AhkStdlibDecimalInexact extends AhkStdlibDecimalDecimalException
{
}

class AhkStdlibDecimalSubnormal extends AhkStdlibDecimalDecimalException
{
}

class AhkStdlibDecimalUnderflow extends AhkStdlibDecimalInexact
{
}

class AhkStdlibDecimalOverflow extends AhkStdlibDecimalInexact
{
}

class AhkStdlibDecimalDivisionByZero extends AhkStdlibDecimalDecimalException
{
}

class AhkStdlibDecimalInvalidOperation extends AhkStdlibDecimalDecimalException
{
}

class AhkStdlibDecimalConversionSyntax extends AhkStdlibDecimalInvalidOperation
{
}

class AhkStdlibDecimalDivisionImpossible extends AhkStdlibDecimalInvalidOperation
{
}

class AhkStdlibDecimalDivisionUndefined extends AhkStdlibDecimalInvalidOperation
{
}

class AhkStdlibDecimalInvalidContext extends AhkStdlibDecimalInvalidOperation
{
}

class AhkStdlibDecimalFloatOperation extends AhkStdlibDecimalDecimalException
{
}

class AhkStdlibDecimal
{
    static ROUND_CEILING := "ROUND_CEILING"
    static ROUND_FLOOR := "ROUND_FLOOR"
    static ROUND_UP := "ROUND_UP"
    static ROUND_DOWN := "ROUND_DOWN"
    static ROUND_HALF_UP := "ROUND_HALF_UP"
    static ROUND_HALF_DOWN := "ROUND_HALF_DOWN"
    static ROUND_HALF_EVEN := "ROUND_HALF_EVEN"
    static ROUND_05UP := "ROUND_05UP"
    static HAVE_CONTEXTVAR := true
    static HAVE_THREADS := true
    static MAX_PREC := 999999999999999999
    static MAX_EMAX := 999999999999999999
    static MIN_EMIN := -999999999999999999
    static MIN_ETINY := -1999999999999999997
    static Decimal := AhkStdlibDecimalValueClass
    static Context := AhkStdlibDecimalContextClass
    static DefaultContext := AhkStdlibDecimalContext()
    static BasicContext := AhkStdlibDecimalContext({ prec: 9, rounding: "ROUND_HALF_UP", traps: ["Clamped", "InvalidOperation", "DivisionByZero", "Overflow", "Underflow"] })
    static ExtendedContext := AhkStdlibDecimalContext({ prec: 9, rounding: "ROUND_HALF_EVEN", traps: [] })
    static DecimalException := AhkStdlibDecimalDecimalException
    static Clamped := AhkStdlibDecimalClamped
    static Rounded := AhkStdlibDecimalRounded
    static Inexact := AhkStdlibDecimalInexact
    static Subnormal := AhkStdlibDecimalSubnormal
    static Underflow := AhkStdlibDecimalUnderflow
    static Overflow := AhkStdlibDecimalOverflow
    static DivisionByZero := AhkStdlibDecimalDivisionByZero
    static InvalidOperation := AhkStdlibDecimalInvalidOperation
    static ConversionSyntax := AhkStdlibDecimalConversionSyntax
    static DivisionImpossible := AhkStdlibDecimalDivisionImpossible
    static DivisionUndefined := AhkStdlibDecimalDivisionUndefined
    static InvalidContext := AhkStdlibDecimalInvalidContext
    static FloatOperation := AhkStdlibDecimalFloatOperation

    static getcontext(args*)
    {
        if args.Length != 0
            throw TypeError("getcontext() takes no arguments (" args.Length " given)", -1)
        return AhkStdlibDecimalCurrentContext()
    }

    static setcontext(args*)
    {
        if args.Length != 1
            throw TypeError("setcontext() takes exactly one argument (" args.Length " given)", -1)
        if !(args[1] is AhkStdlibDecimalContext)
            throw TypeError("argument must be a context", -1)
        AhkStdlibDecimalCurrentContext(args[1].copy())
        return stdlib.None
    }

    static localcontext(args*)
    {
        if args.Length > 1
            throw TypeError("localcontext() takes at most 1 argument (" args.Length " given)", -1)
        if args.Length = 1 {
            if !(args[1] is AhkStdlibDecimalContext)
                throw TypeError("optional argument must be a context", -1)
            return AhkStdlibDecimalLocalContext(args[1])
        }
        return AhkStdlibDecimalLocalContext()
    }
}

class AhkStdlibDecimalValueClass
{
    static Call(thisClass, value := 0)
    {
        return AhkStdlibDecimalValue(value)
    }

    static from_float(value)
    {
        return AhkStdlibDecimalFromFloat(value)
    }
}

class AhkStdlibDecimalValue
{
    __New(value := 0)
    {
        normalized := AhkStdlibDecimalNormalize(value)
        this.sign := normalized.sign
        this.digits := normalized.digits
        this.exponent := normalized.exponent
    }

    ToString()
    {
        return AhkStdlibDecimalFormat(this.sign, this.digits, this.exponent)
    }

    __Repr()
    {
        return "Decimal('" this.ToString() "')"
    }

    normalize()
    {
        digits := this.digits
        exponent := this.exponent

        if digits = "0"
            return AhkStdlibDecimalValue("0")

        while StrLen(digits) > 1 && SubStr(digits, -1) = "0" {
            digits := SubStr(digits, 1, -1)
            exponent += 1
        }

        if exponent < 0 {
            while StrLen(digits) > 1 && SubStr(digits, -1) = "0" {
                digits := SubStr(digits, 1, -1)
                exponent += 1
                if exponent = 0
                    break
            }
        }

        if exponent > 0
            return AhkStdlibDecimalFromParts(this.sign, digits, exponent)

        if exponent = 0
            return AhkStdlibDecimalFromParts(this.sign, digits, exponent)

        return AhkStdlibDecimalFromParts(this.sign, digits, exponent)
    }

    __Compare(other, op)
    {
        other := AhkStdlibDecimalCoerceForCompare(other)
        if other = ""
            return ""
        leftScale := this.exponent < other.exponent ? this.exponent : other.exponent
        leftInt := AhkStdlibDecimalScaledInteger(this.sign, this.digits, this.exponent, leftScale)
        rightInt := AhkStdlibDecimalScaledInteger(other.sign, other.digits, other.exponent, leftScale)
        if leftInt = rightInt
            return 0
        return leftInt < rightInt ? -1 : 1
    }

    __Add(other)
    {
        other := AhkStdlibDecimalCoerce(other)
        if other = ""
            return ""
        scale := this.exponent < other.exponent ? this.exponent : other.exponent
        leftInt := AhkStdlibDecimalScaledInteger(this.sign, this.digits, this.exponent, scale)
        rightInt := AhkStdlibDecimalScaledInteger(other.sign, other.digits, other.exponent, scale)
        return AhkStdlibDecimalFixToPrecision(AhkStdlibDecimalFromScaledInteger(leftInt + rightInt, scale))
    }

    __Sub(other)
    {
        other := AhkStdlibDecimalCoerce(other)
        if other = ""
            return ""
        scale := this.exponent < other.exponent ? this.exponent : other.exponent
        leftInt := AhkStdlibDecimalScaledInteger(this.sign, this.digits, this.exponent, scale)
        rightInt := AhkStdlibDecimalScaledInteger(other.sign, other.digits, other.exponent, scale)
        return AhkStdlibDecimalFixToPrecision(AhkStdlibDecimalFromScaledInteger(leftInt - rightInt, scale))
    }

    __Mul(other)
    {
        other := AhkStdlibDecimalCoerce(other)
        if other = ""
            return ""
        product := AhkStdlibDecimalBigMul(this.digits, other.digits)
        resultSign := (this.sign != other.sign) ? 1 : 0
        built := AhkStdlibDecimalFromParts(resultSign, AhkStdlibDecimalNormalizeIntString(product), this.exponent + other.exponent)
        return AhkStdlibDecimalFixToPrecision(built)
    }

    __Div(other)
    {
        other := AhkStdlibDecimalCoerce(other)
        if other = ""
            return ""

        rightInt := Integer(other.digits)
        if rightInt = 0
            throw Error("[<class 'decimal.DivisionByZero'>]", -1)

        leftInt := Integer(this.digits)
        numerator := leftInt
        denominator := rightInt
        scaleExponent := this.exponent - other.exponent

        common := AhkStdlibDecimalGcd(numerator, denominator)
        numerator := numerator // common
        denominator := denominator // common

        while Mod(denominator, 2) = 0 {
            denominator := denominator // 2
            numerator *= 5
            scaleExponent -= 1
        }
        while Mod(denominator, 5) = 0 {
            denominator := denominator // 5
            numerator *= 2
            scaleExponent -= 1
        }

        if this.sign != other.sign
            numerator := 0 - numerator

        prec := AhkStdlibDecimalCurrentContext().prec
        if denominator != 1
            return AhkStdlibDecimalDivideToContext(String(numerator), String(denominator), scaleExponent, prec)

        return AhkStdlibDecimalFixToPrecision(AhkStdlibDecimalFromScaledInteger(numerator, scaleExponent))
    }

    __FloorDiv(other)
    {
        other := AhkStdlibDecimalCoerce(other)
        if other = ""
            return ""

        if Integer(other.digits) = 0
            throw Error("[<class 'decimal.DivisionByZero'>]", -1)

        scaled := AhkStdlibDecimalSharedScale(this, other)
        quotient := AhkStdlibDecimalTruncDiv(scaled.left, scaled.right)
        return AhkStdlibDecimalValue(quotient)
    }

    __Mod(other)
    {
        other := AhkStdlibDecimalCoerce(other)
        if other = ""
            return ""

        if Integer(other.digits) = 0
            throw Error("[<class 'decimal.InvalidOperation'>]", -1)

        scaled := AhkStdlibDecimalSharedScale(this, other)
        quotient := AhkStdlibDecimalTruncDiv(scaled.left, scaled.right)
        remainder := scaled.left - (scaled.right * quotient)
        return AhkStdlibDecimalFromScaledInteger(remainder, scaled.exponent)
    }

    __Neg()
    {
        if this.digits = "0"
            return AhkStdlibDecimalValue("0")
        return AhkStdlibDecimalValue(this.sign ? SubStr(this.ToString(), 2) : "-" this.ToString())
    }

    __Pos()
    {
        return AhkStdlibDecimalValue(this.ToString())
    }

    quantize(other, rounding := unset)
    {
        target := AhkStdlibDecimalCoerce(other)
        if target = ""
            throw TypeError("quantize() argument must be a Decimal", -1)
        mode := IsSet(rounding) ? rounding : AhkStdlibDecimalCurrentContext().rounding
        AhkStdlibDecimalValidateRounding(mode)
        return AhkStdlibDecimalQuantizeTo(this.sign, this.digits, this.exponent, target.exponent, mode)
    }

    to_integral_value(rounding := unset)
    {
        mode := IsSet(rounding) ? rounding : AhkStdlibDecimalCurrentContext().rounding
        AhkStdlibDecimalValidateRounding(mode)
        if this.exponent >= 0
            return AhkStdlibDecimalFromParts(this.sign, this.digits, this.exponent)
        return AhkStdlibDecimalQuantizeTo(this.sign, this.digits, this.exponent, 0, mode)
    }

    to_integral(rounding := unset)
    {
        return IsSet(rounding) ? this.to_integral_value(rounding) : this.to_integral_value()
    }

    sqrt()
    {
        return AhkStdlibDecimalSqrt(this.sign, this.digits, this.exponent)
    }

    ln()
    {
        return AhkStdlibDecimalLn(this.sign, this.digits, this.exponent)
    }

    log10()
    {
        return AhkStdlibDecimalLog10(this.sign, this.digits, this.exponent)
    }

    exp()
    {
        return AhkStdlibDecimalExp(this.sign, this.digits, this.exponent)
    }

    compare(other)
    {
        result := this.__Compare(other, "")
        if result = ""
            throw TypeError("unsupported operand for compare", -1)
        return AhkStdlibDecimalValue(String(result))
    }

    copy_abs()
    {
        return AhkStdlibDecimalFromParts(0, this.digits, this.exponent)
    }

    copy_sign(other)
    {
        source := AhkStdlibDecimalCoerce(other)
        if source = ""
            throw TypeError("copy_sign() argument must be a Decimal", -1)
        return AhkStdlibDecimalFromParts(source.sign, this.digits, this.exponent)
    }

    copy_negate()
    {
        return AhkStdlibDecimalFromParts(this.sign ? 0 : 1, this.digits, this.exponent)
    }

    as_tuple()
    {
        digitArray := []
        loop StrLen(this.digits)
            digitArray.Push(Integer(SubStr(this.digits, A_Index, 1)))
        return [this.sign, digitArray, this.exponent]
    }

    as_integer_ratio()
    {
        if this.digits = "0"
            return [0, 1]
        if this.exponent >= 0 {
            numerator := AhkStdlibDecimalBigMul(this.digits, AhkStdlibDecimalBigPow10(this.exponent))
            denominator := "1"
        } else {
            numerator := this.digits
            denominator := AhkStdlibDecimalBigPow10(-this.exponent)
        }
        common := AhkStdlibDecimalBigGcd(numerator, denominator)
        numerator := AhkStdlibDecimalBigDivMod(numerator, common).q
        denominator := AhkStdlibDecimalBigDivMod(denominator, common).q
        if this.sign
            numerator := AhkStdlibDecimalBigNeg(numerator)
        return [AhkStdlibDecimalBigToScalar(numerator), AhkStdlibDecimalBigToScalar(denominator)]
    }

    is_nan()
    {
        return false
    }

    is_qnan()
    {
        return false
    }

    is_snan()
    {
        return false
    }

    is_infinite()
    {
        return false
    }

    is_finite()
    {
        return true
    }

    is_zero()
    {
        return this.digits = "0"
    }

    is_signed()
    {
        return this.sign != 0
    }
}

class AhkStdlibDecimalContextClass
{
    static Call(thisClass, args*)
    {
        if args.Length > 1
            throw TypeError("Context() takes at most 1 argument (" args.Length " given)", -1)
        return args.Length = 1 ? AhkStdlibDecimalContext(args[1]) : AhkStdlibDecimalContext()
    }
}

class AhkStdlibDecimalContext
{
    __New(options := unset)
    {
        this.prec := AhkStdlibDecimalContextOption(options?, "prec", 28)
        this.rounding := AhkStdlibDecimalContextOption(options?, "rounding", "ROUND_HALF_EVEN")
        this.Emin := AhkStdlibDecimalContextOption(options?, "Emin", -999999)
        this.Emax := AhkStdlibDecimalContextOption(options?, "Emax", 999999)
        this.capitals := AhkStdlibDecimalContextOption(options?, "capitals", 1)
        this.clamp := AhkStdlibDecimalContextOption(options?, "clamp", 0)
        AhkStdlibDecimalValidateInteger(this.prec)
        AhkStdlibDecimalValidateInteger(this.Emin)
        AhkStdlibDecimalValidateInteger(this.Emax)
        AhkStdlibDecimalValidateInteger(this.capitals)
        AhkStdlibDecimalValidateInteger(this.clamp)
        AhkStdlibDecimalValidateRounding(this.rounding)
        trapNames := AhkStdlibDecimalContextOption(options?, "traps", ["InvalidOperation", "DivisionByZero", "Overflow"])
        this.flags := AhkStdlibDecimalSignalMap([])
        this.traps := AhkStdlibDecimalSignalMap(trapNames)
    }

    copy()
    {
        trapNames := []
        for name, enabled in this.traps {
            if enabled
                trapNames.Push(name)
        }
        return AhkStdlibDecimalContext({
            prec: this.prec,
            rounding: this.rounding,
            Emin: this.Emin,
            Emax: this.Emax,
            capitals: this.capitals,
            clamp: this.clamp,
            traps: trapNames
        })
    }
}

class AhkStdlibDecimalLocalContext
{
    __New(context := unset)
    {
        if IsSet(context)
            this.context := context.copy()
    }

    __enter()
    {
        this.previous := AhkStdlibDecimalCurrentContext()
        nextContext := HasProp(this, "context") ? this.context.copy() : this.previous.copy()
        AhkStdlibDecimalCurrentContext(nextContext)
        return nextContext
    }

    __exit(excType, exc, tb)
    {
        AhkStdlibDecimalCurrentContext(this.previous)
        return false
    }
}

stdlib.decimal := AhkStdlibDecimal

AhkStdlibDecimalCurrentContext(value := unset)
{
    static current := unset
    if IsSet(value) {
        current := value
        return current
    }
    if !IsSet(current)
        current := AhkStdlibDecimal.DefaultContext.copy()
    return current
}

AhkStdlibDecimalContextOption(options := unset, name := "", defaultValue := unset)
{
    if IsSet(options) {
        if options is Map {
            if options.Has(name)
                return options[name]
        } else if IsObject(options) && HasProp(options, name) {
            return options.%name%
        }
    }
    return defaultValue
}

AhkStdlibDecimalValidateInteger(value)
{
    if !(value is Integer)
        throw TypeError("an integer is required", -1)
}

AhkStdlibDecimalValidateRounding(value)
{
    if AhkStdlibDecimalArrayContains(AhkStdlibDecimalRoundingNames(), value)
        return
    throw TypeError("valid values for rounding are:`n  [ROUND_CEILING, ROUND_FLOOR, ROUND_UP, ROUND_DOWN,`n   ROUND_HALF_UP, ROUND_HALF_DOWN, ROUND_HALF_EVEN,`n   ROUND_05UP]", -1)
}

AhkStdlibDecimalRoundingNames()
{
    return ["ROUND_CEILING", "ROUND_FLOOR", "ROUND_UP", "ROUND_DOWN", "ROUND_HALF_UP", "ROUND_HALF_DOWN", "ROUND_HALF_EVEN", "ROUND_05UP"]
}

AhkStdlibDecimalSignalNames()
{
    return ["Clamped", "InvalidOperation", "DivisionByZero", "Overflow", "Underflow", "Subnormal", "Inexact", "Rounded", "FloatOperation"]
}

AhkStdlibDecimalSignalMap(enabledNames)
{
    result := Map()
    for name in AhkStdlibDecimalSignalNames()
        result[name] := AhkStdlibDecimalArrayContains(enabledNames, name)
    return result
}

AhkStdlibDecimalArrayContains(values, needle)
{
    for value in values {
        if value = needle
            return true
    }
    return false
}

AhkStdlibDecimalNormalize(value)
{
    if Type(value) = "AhkStdlibDecimalValue"
        return { sign: value.sign, digits: value.digits, exponent: value.exponent }
    if value is Integer
        return AhkStdlibDecimalNormalizeString(String(value))
    if value is String
        return AhkStdlibDecimalNormalizeString(value)
    if value is Map
        throw TypeError("conversion from dict to Decimal is not supported", -1)
    throw TypeError("conversion from " AhkStdlibDecimalTypeName(value) " to Decimal is not supported", -1)
}

AhkStdlibDecimalNormalizeString(value)
{
    value := Trim(value)
    if value = ""
        throw Error("[<class 'decimal.ConversionSyntax'>]", -1)

    sign := 0
    if SubStr(value, 1, 1) = "+" {
        value := SubStr(value, 2)
    } else if SubStr(value, 1, 1) = "-" {
        sign := 1
        value := SubStr(value, 2)
    }

    if RegExMatch(value, "i)^(\d+)(?:\.(\d*))?(?:e([+-]?\d+))?$", &match) {
        intPart := match[1]
        fracPart := match[2]
        expPart := match[3]
        digits := intPart fracPart
        digits := RegExReplace(digits, "^0+(?=\d)")
        if digits = ""
            digits := "0"
        exponent := -(StrLen(fracPart))
        if expPart != ""
            exponent += Integer(expPart)
        if digits = "0"
            return { sign: 0, digits: "0", exponent: 0 }
        return { sign: sign, digits: digits, exponent: exponent }
    }

    throw Error("[<class 'decimal.ConversionSyntax'>]", -1)
}

AhkStdlibDecimalCoerce(value)
{
    if Type(value) = "AhkStdlibDecimalValue"
        return value
    if value is Integer
        return AhkStdlibDecimalValue(value)
    return ""
}

AhkStdlibDecimalCoerceForCompare(value)
{
    if Type(value) = "AhkStdlibFractionsFractionValue"
        return AhkStdlibDecimalFromFraction(value)
    return AhkStdlibDecimalCoerce(value)
}

AhkStdlibDecimalFromFraction(value)
{
    numerator := value.numerator
    denominator := value.denominator
    if denominator = 0
        throw ZeroDivisionError("Fraction(1, 0)", -1)

    signText := numerator < 0 ? "-" : ""
    numeratorText := String(Abs(numerator))
    denominatorText := String(denominator)
    common := AhkStdlibDecimalGcd(Abs(numerator), denominator)
    numeratorText := String(Abs(numerator) // common)
    denominatorText := String(denominator // common)
    exponent := 0

    while Mod(Integer(denominatorText), 2) = 0 {
        denominatorText := String(Integer(denominatorText) // 2)
        numeratorText := AhkStdlibDecimalMultiplyIntStringDigit(numeratorText, 5)
        exponent -= 1
    }
    while Mod(Integer(denominatorText), 5) = 0 {
        denominatorText := String(Integer(denominatorText) // 5)
        numeratorText := AhkStdlibDecimalMultiplyIntStringDigit(numeratorText, 2)
        exponent -= 1
    }

    if denominatorText = "1"
        return AhkStdlibDecimalFromScaledInteger((signText = "-" ? -1 : 1) * Integer(numeratorText), exponent)

    text := AhkStdlibDecimalDivideToContext(numeratorText, denominatorText, exponent, 28)
    if signText = "-"
        return text.__Neg()
    return text
}

AhkStdlibDecimalSharedScale(left, right)
{
    scale := left.exponent < right.exponent ? left.exponent : right.exponent
    return {
        exponent: scale,
        left: AhkStdlibDecimalScaledInteger(left.sign, left.digits, left.exponent, scale),
        right: AhkStdlibDecimalScaledInteger(right.sign, right.digits, right.exponent, scale)
    }
}

AhkStdlibDecimalScaledInteger(sign, digits, exponent, targetExponent)
{
    scaled := digits
    zeros := exponent - targetExponent
    while zeros > 0 {
        scaled .= "0"
        zeros -= 1
    }
    integerValue := Integer(scaled)
    return sign ? -integerValue : integerValue
}

AhkStdlibDecimalTruncDiv(left, right)
{
    quotient := Abs(left) // Abs(right)
    return ((left < 0) != (right < 0)) ? (0 - quotient) : quotient
}

AhkStdlibDecimalFromScaledInteger(value, exponent)
{
    sign := value < 0 ? "-" : ""
    absValue := Abs(value)
    return AhkStdlibDecimalValue(sign AhkStdlibDecimalPlainFromParts(String(absValue), exponent))
}

AhkStdlibDecimalFromParts(sign, digits, exponent)
{
    instance := {}
    instance.base := AhkStdlibDecimalValue.Prototype
    instance.sign := digits = "0" ? 0 : sign
    instance.digits := digits = "" ? "0" : digits
    instance.exponent := digits = "0" ? 0 : exponent
    return instance
}

AhkStdlibDecimalGcd(left, right)
{
    left := Abs(left)
    right := Abs(right)
    while right != 0 {
        remainder := Mod(left, right)
        left := right
        right := remainder
    }
    return left = 0 ? 1 : left
}

AhkStdlibDecimalDivideToContext(numeratorText, denominatorText, scaleExponent, precision)
{
    sign := 0
    if SubStr(numeratorText, 1, 1) = "-" {
        sign := 1
        numeratorText := SubStr(numeratorText, 2)
    }
    if SubStr(denominatorText, 1, 1) = "-" {
        sign := sign ? 0 : 1
        denominatorText := SubStr(denominatorText, 2)
    }

    numeratorText := AhkStdlibDecimalNormalizeIntString(numeratorText)
    denominatorText := AhkStdlibDecimalNormalizeIntString(denominatorText)

    rationalAdjusted := AhkStdlibDecimalAdjustedExponent(numeratorText, denominatorText)
    power := precision - 1 - rationalAdjusted
    scaledNumerator := numeratorText
    while power > 0 {
        scaledNumerator .= "0"
        power -= 1
    }

    division := AhkStdlibDecimalDivideIntegerStrings(scaledNumerator, denominatorText)
    quotient := division.quotient
    remainder := division.remainder

    doubledRemainder := AhkStdlibDecimalMultiplyIntStringDigit(remainder, 2)
    remainderComparison := AhkStdlibDecimalCompareIntStrings(doubledRemainder, denominatorText)
    if remainderComparison > 0 || (remainderComparison = 0 && Mod(Integer(SubStr(quotient, -1)), 2) = 1)
        quotient := AhkStdlibDecimalIncrementIntString(quotient)

    targetExponent := scaleExponent - (precision - 1 - rationalAdjusted)
    if StrLen(quotient) > precision {
        quotient := SubStr(quotient, 1, precision)
        targetExponent += 1
    }

    return AhkStdlibDecimalFromParts(sign, quotient, targetExponent)
}

AhkStdlibDecimalAdjustedExponent(numeratorText, denominatorText)
{
    lenDiff := StrLen(numeratorText) - StrLen(denominatorText)
    if lenDiff >= 0 {
        scaledDenominator := denominatorText
        while lenDiff > 0 {
            scaledDenominator .= "0"
            lenDiff -= 1
        }
        adjusted := StrLen(numeratorText) - StrLen(denominatorText)
        if AhkStdlibDecimalCompareIntStrings(numeratorText, scaledDenominator) < 0
            adjusted -= 1
        return adjusted
    }

    scaledNumerator := numeratorText
    neededZeros := 0 - lenDiff
    while neededZeros > 0 {
        scaledNumerator .= "0"
        neededZeros -= 1
    }
    adjusted := StrLen(numeratorText) - StrLen(denominatorText)
    if AhkStdlibDecimalCompareIntStrings(scaledNumerator, denominatorText) < 0
        adjusted -= 1
    return adjusted
}

AhkStdlibDecimalDivideIntegerStrings(dividend, divisor)
{
    dividend := AhkStdlibDecimalNormalizeIntString(dividend)
    divisor := AhkStdlibDecimalNormalizeIntString(divisor)
    remainder := "0"
    quotient := ""

    loop StrLen(dividend) {
        remainder := AhkStdlibDecimalNormalizeIntString(remainder SubStr(dividend, A_Index, 1))
        quotientDigit := 0
        if AhkStdlibDecimalCompareIntStrings(remainder, divisor) >= 0 {
            loop 9 {
                candidateDigit := 10 - A_Index
                product := AhkStdlibDecimalMultiplyIntStringDigit(divisor, candidateDigit)
                if AhkStdlibDecimalCompareIntStrings(product, remainder) <= 0 {
                    quotientDigit := candidateDigit
                    remainder := AhkStdlibDecimalSubtractIntStrings(remainder, product)
                    break
                }
            }
        }
        quotient .= String(quotientDigit)
    }

    return { quotient: AhkStdlibDecimalNormalizeIntString(quotient), remainder: AhkStdlibDecimalNormalizeIntString(remainder) }
}

AhkStdlibDecimalCompareIntStrings(left, right)
{
    left := AhkStdlibDecimalNormalizeIntString(left)
    right := AhkStdlibDecimalNormalizeIntString(right)
    if StrLen(left) != StrLen(right)
        return StrLen(left) < StrLen(right) ? -1 : 1
    cmp := StrCompare(left, right)
    return cmp = 0 ? 0 : (cmp < 0 ? -1 : 1)
}

AhkStdlibDecimalMultiplyIntStringDigit(value, digit)
{
    value := AhkStdlibDecimalNormalizeIntString(value)
    if value = "0" || digit = 0
        return "0"

    carry := 0
    result := ""
    loop StrLen(value) {
        index := StrLen(value) - A_Index + 1
        current := Integer(SubStr(value, index, 1))
        product := current * digit + carry
        result := Mod(product, 10) result
        carry := product // 10
    }
    while carry > 0 {
        result := Mod(carry, 10) result
        carry := carry // 10
    }
    return AhkStdlibDecimalNormalizeIntString(result)
}

AhkStdlibDecimalSubtractIntStrings(left, right)
{
    left := AhkStdlibDecimalNormalizeIntString(left)
    right := AhkStdlibDecimalNormalizeIntString(right)
    borrow := 0
    result := ""

    loop StrLen(left) {
        leftIndex := StrLen(left) - A_Index + 1
        leftDigit := Integer(SubStr(left, leftIndex, 1)) - borrow
        rightIndex := StrLen(right) - A_Index + 1
        rightDigit := rightIndex >= 1 ? Integer(SubStr(right, rightIndex, 1)) : 0
        if leftDigit < rightDigit {
            leftDigit += 10
            borrow := 1
        } else {
            borrow := 0
        }
        result := String(leftDigit - rightDigit) result
    }

    return AhkStdlibDecimalNormalizeIntString(result)
}

AhkStdlibDecimalIncrementIntString(value)
{
    value := AhkStdlibDecimalNormalizeIntString(value)
    carry := 1
    result := ""

    loop StrLen(value) {
        index := StrLen(value) - A_Index + 1
        digit := Integer(SubStr(value, index, 1)) + carry
        if digit >= 10 {
            result := String(digit - 10) result
            carry := 1
        } else {
            result := String(digit) result
            carry := 0
        }
    }

    if carry
        result := "1" result
    return AhkStdlibDecimalNormalizeIntString(result)
}

AhkStdlibDecimalNormalizeIntString(value)
{
    value := RegExReplace(value, "^0+(?=\d)")
    return value = "" ? "0" : value
}

AhkStdlibDecimalPlainFromParts(digits, exponent)
{
    if digits = "0"
        return "0"
    if exponent >= 0 {
        while exponent > 0 {
            digits .= "0"
            exponent -= 1
        }
        return digits
    }

    decimalPlaces := -exponent
    if decimalPlaces >= StrLen(digits) {
        zeros := ""
        needed := decimalPlaces - StrLen(digits)
        while needed > 0 {
            zeros .= "0"
            needed -= 1
        }
        return "0." zeros digits
    }

    split := StrLen(digits) - decimalPlaces
    return SubStr(digits, 1, split) "." SubStr(digits, split + 1)
}

AhkStdlibDecimalFormat(sign, digits, exponent)
{
    if digits = "0"
        return "0"
    if exponent > 0
        text := AhkStdlibDecimalScientificString(0, digits, exponent)
    else
        text := AhkStdlibDecimalPlainFromParts(digits, exponent)
    return (sign && text != "0" ? "-" : "") text
}

AhkStdlibDecimalScientificString(sign, digits, exponent)
{
    if digits = "0"
        return "0"
    if StrLen(digits) = 1
        mantissa := digits
    else
        mantissa := SubStr(digits, 1, 1) "." SubStr(digits, 2)
    scientificExponent := exponent + StrLen(digits) - 1
    return (sign ? "-" : "") mantissa "E" Format("{:+d}", scientificExponent)
}

AhkStdlibDecimalTypeName(value)
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

; ---- rounding / quantize / precision fix ----

AhkStdlibDecimalRoundUp(mode, sign, firstDropped, restNonZero, lastKept)
{
    if mode = "ROUND_DOWN"
        return false
    if mode = "ROUND_UP"
        return firstDropped > 0 || restNonZero
    if mode = "ROUND_CEILING"
        return (firstDropped > 0 || restNonZero) && !sign
    if mode = "ROUND_FLOOR"
        return (firstDropped > 0 || restNonZero) && sign
    if mode = "ROUND_HALF_UP"
        return firstDropped >= 5
    if mode = "ROUND_HALF_DOWN"
        return firstDropped > 5 || (firstDropped = 5 && restNonZero)
    if mode = "ROUND_HALF_EVEN" {
        if firstDropped > 5
            return true
        if firstDropped < 5
            return false
        if restNonZero
            return true
        return Mod(lastKept, 2) = 1
    }
    if mode = "ROUND_05UP"
        return (firstDropped > 0 || restNonZero) && (lastKept = 0 || lastKept = 5)
    return false
}

; Drop `dropCount` low digits from `digits`, rounding per `mode`.
; Returns { digits, grew } where grew=1 if a carry lengthened the result.
AhkStdlibDecimalRoundCoeff(sign, digits, dropCount, mode)
{
    total := StrLen(digits)
    padded := digits
    while StrLen(padded) < dropCount + 1
        padded := "0" padded
    keepLen := StrLen(padded) - dropCount
    kept := SubStr(padded, 1, keepLen)
    dropped := SubStr(padded, keepLen + 1)
    firstDropped := dropped = "" ? 0 : Integer(SubStr(dropped, 1, 1))
    rest := SubStr(dropped, 2)
    restNonZero := RegExMatch(rest, "[1-9]") ? true : false
    lastKept := Integer(SubStr(kept, -1))
    grew := 0
    if AhkStdlibDecimalRoundUp(mode, sign, firstDropped, restNonZero, lastKept) {
        before := StrLen(kept)
        kept := AhkStdlibDecimalIncrementIntString(kept)
        if StrLen(kept) > before
            grew := 1
    }
    return { digits: AhkStdlibDecimalNormalizeIntString(kept), grew: grew }
}

; Round value (sign,digits,exponent) so it fits the current context precision.
AhkStdlibDecimalFixToPrecision(value)
{
    sign := value.sign
    digits := value.digits
    exponent := value.exponent
    if digits = "0"
        return AhkStdlibDecimalFromParts(0, "0", exponent)
    prec := AhkStdlibDecimalCurrentContext().prec
    if StrLen(digits) <= prec
        return AhkStdlibDecimalFromParts(sign, digits, exponent)
    mode := AhkStdlibDecimalCurrentContext().rounding
    dropCount := StrLen(digits) - prec
    rounded := AhkStdlibDecimalRoundCoeff(sign, digits, dropCount, mode)
    newExp := exponent + dropCount
    newDigits := rounded.digits
    if rounded.grew && StrLen(newDigits) > prec {
        newDigits := SubStr(newDigits, 1, prec)
        newExp += 1
    }
    return AhkStdlibDecimalFromParts(sign, newDigits, newExp)
}

; Rescale (sign,digits,exponent) to targetExponent, rounding per mode.
AhkStdlibDecimalQuantizeTo(sign, digits, exponent, targetExponent, mode)
{
    if digits = "0"
        return AhkStdlibDecimalFromParts(sign, "0", targetExponent)
    if exponent >= targetExponent {
        ; need more (or equal) fractional places: pad with zeros
        pad := exponent - targetExponent
        newDigits := digits
        while pad > 0 {
            newDigits .= "0"
            pad -= 1
        }
        return AhkStdlibDecimalFromParts(sign, newDigits, targetExponent)
    }
    dropCount := targetExponent - exponent
    rounded := AhkStdlibDecimalRoundCoeff(sign, digits, dropCount, mode)
    return AhkStdlibDecimalFromParts(sign, rounded.digits, targetExponent)
}

; ---- end rounding helpers ----

; ---- signed big-integer (decimal string) layer ----

AhkStdlibDecimalBigNorm(value)
{
    sign := ""
    if SubStr(value, 1, 1) = "-" {
        sign := "-"
        value := SubStr(value, 2)
    }
    value := RegExReplace(value, "^0+(?=\d)")
    if value = "" || value = "0"
        return "0"
    return sign value
}

AhkStdlibDecimalBigIsNeg(value)
{
    return SubStr(value, 1, 1) = "-"
}

AhkStdlibDecimalBigAbs(value)
{
    return AhkStdlibDecimalBigIsNeg(value) ? SubStr(value, 2) : value
}

AhkStdlibDecimalBigNeg(value)
{
    value := AhkStdlibDecimalBigNorm(value)
    if value = "0"
        return "0"
    return AhkStdlibDecimalBigIsNeg(value) ? SubStr(value, 2) : "-" value
}

AhkStdlibDecimalBigCmpAbs(left, right)
{
    return AhkStdlibDecimalCompareIntStrings(AhkStdlibDecimalBigAbs(left), AhkStdlibDecimalBigAbs(right))
}

AhkStdlibDecimalBigCmp(left, right)
{
    leftNeg := AhkStdlibDecimalBigIsNeg(left)
    rightNeg := AhkStdlibDecimalBigIsNeg(right)
    if leftNeg && !rightNeg
        return -1
    if !leftNeg && rightNeg
        return 1
    magnitude := AhkStdlibDecimalBigCmpAbs(left, right)
    return leftNeg ? -magnitude : magnitude
}

AhkStdlibDecimalBigAdd(left, right)
{
    left := AhkStdlibDecimalBigNorm(left)
    right := AhkStdlibDecimalBigNorm(right)
    leftNeg := AhkStdlibDecimalBigIsNeg(left)
    rightNeg := AhkStdlibDecimalBigIsNeg(right)
    leftAbs := AhkStdlibDecimalBigAbs(left)
    rightAbs := AhkStdlibDecimalBigAbs(right)
    if leftNeg = rightNeg {
        sum := AhkStdlibDecimalAddIntStrings(leftAbs, rightAbs)
        return AhkStdlibDecimalBigNorm((leftNeg ? "-" : "") sum)
    }
    cmp := AhkStdlibDecimalCompareIntStrings(leftAbs, rightAbs)
    if cmp = 0
        return "0"
    if cmp > 0 {
        diff := AhkStdlibDecimalSubtractIntStrings(leftAbs, rightAbs)
        return AhkStdlibDecimalBigNorm((leftNeg ? "-" : "") diff)
    }
    diff := AhkStdlibDecimalSubtractIntStrings(rightAbs, leftAbs)
    return AhkStdlibDecimalBigNorm((rightNeg ? "-" : "") diff)
}

AhkStdlibDecimalBigSub(left, right)
{
    return AhkStdlibDecimalBigAdd(left, AhkStdlibDecimalBigNeg(right))
}

AhkStdlibDecimalBigMul(left, right)
{
    leftNeg := AhkStdlibDecimalBigIsNeg(left)
    rightNeg := AhkStdlibDecimalBigIsNeg(right)
    product := AhkStdlibDecimalMulIntStrings(AhkStdlibDecimalBigAbs(left), AhkStdlibDecimalBigAbs(right))
    if product = "0"
        return "0"
    return (leftNeg != rightNeg ? "-" : "") product
}

AhkStdlibDecimalAddIntStrings(left, right)
{
    left := AhkStdlibDecimalNormalizeIntString(left)
    right := AhkStdlibDecimalNormalizeIntString(right)
    carry := 0
    result := ""
    maxLen := StrLen(left) > StrLen(right) ? StrLen(left) : StrLen(right)
    loop maxLen {
        li := StrLen(left) - A_Index + 1
        ri := StrLen(right) - A_Index + 1
        ld := li >= 1 ? Integer(SubStr(left, li, 1)) : 0
        rd := ri >= 1 ? Integer(SubStr(right, ri, 1)) : 0
        total := ld + rd + carry
        result := Mod(total, 10) result
        carry := total // 10
    }
    if carry
        result := String(carry) result
    return AhkStdlibDecimalNormalizeIntString(result)
}

AhkStdlibDecimalMulIntStrings(left, right)
{
    left := AhkStdlibDecimalNormalizeIntString(left)
    right := AhkStdlibDecimalNormalizeIntString(right)
    if left = "0" || right = "0"
        return "0"
    result := "0"
    loop StrLen(right) {
        rIndex := StrLen(right) - A_Index + 1
        shift := A_Index - 1
        digit := Integer(SubStr(right, rIndex, 1))
        partial := AhkStdlibDecimalMultiplyIntStringDigit(left, digit)
        if partial != "0" {
            zeros := shift
            while zeros > 0 {
                partial .= "0"
                zeros -= 1
            }
            result := AhkStdlibDecimalAddIntStrings(result, partial)
        }
    }
    return AhkStdlibDecimalNormalizeIntString(result)
}

; floor division: returns { q, r } with r having the sign of divisor (Python semantics)
AhkStdlibDecimalBigDivModFloor(numerator, divisor)
{
    numNeg := AhkStdlibDecimalBigIsNeg(numerator)
    divNeg := AhkStdlibDecimalBigIsNeg(divisor)
    numAbs := AhkStdlibDecimalBigAbs(numerator)
    divAbs := AhkStdlibDecimalBigAbs(divisor)
    division := AhkStdlibDecimalDivideIntegerStrings(numAbs, divAbs)
    qAbs := division.quotient
    rAbs := division.remainder
    if numNeg = divNeg {
        q := (numNeg && qAbs != "0") ? "-" qAbs : qAbs
        r := (numNeg && rAbs != "0") ? "-" rAbs : rAbs
        return { q: AhkStdlibDecimalBigNorm(q), r: AhkStdlibDecimalBigNorm(r) }
    }
    ; signs differ: floor rounds toward -inf
    if rAbs = "0" {
        q := qAbs = "0" ? "0" : "-" qAbs
        return { q: AhkStdlibDecimalBigNorm(q), r: "0" }
    }
    q := "-" AhkStdlibDecimalAddIntStrings(qAbs, "1")
    rMag := AhkStdlibDecimalSubtractIntStrings(divAbs, rAbs)
    r := divNeg ? "-" rMag : rMag
    return { q: AhkStdlibDecimalBigNorm(q), r: AhkStdlibDecimalBigNorm(r) }
}

; truncating division for positive operands: returns { q, r }
AhkStdlibDecimalBigDivMod(numerator, divisor)
{
    division := AhkStdlibDecimalDivideIntegerStrings(AhkStdlibDecimalBigAbs(numerator), AhkStdlibDecimalBigAbs(divisor))
    return { q: division.quotient, r: division.remainder }
}

AhkStdlibDecimalBigGcd(left, right)
{
    left := AhkStdlibDecimalBigAbs(left)
    right := AhkStdlibDecimalBigAbs(right)
    while right != "0" {
        remainder := AhkStdlibDecimalDivideIntegerStrings(left, right).remainder
        left := right
        right := remainder
    }
    return left = "0" ? "1" : left
}

AhkStdlibDecimalBigPow10(exp)
{
    result := "1"
    while exp > 0 {
        result .= "0"
        exp -= 1
    }
    return result
}

AhkStdlibDecimalBigPow5(exp)
{
    result := "1"
    while exp > 0 {
        result := AhkStdlibDecimalMultiplyIntStringDigit(result, 5)
        exp -= 1
    }
    return result
}

AhkStdlibDecimalBigPow2(exp)
{
    result := "1"
    while exp > 0 {
        result := AhkStdlibDecimalMultiplyIntStringDigit(result, 2)
        exp -= 1
    }
    return result
}

AhkStdlibDecimalBigToScalar(value)
{
    return Integer(value)
}

AhkStdlibDecimalBigLen(value)
{
    return StrLen(AhkStdlibDecimalBigAbs(value))
}

AhkStdlibDecimalBigOdd(value)
{
    return Mod(Integer(SubStr(AhkStdlibDecimalBigAbs(value), -1)), 2) = 1
}

; ---- end big-integer layer ----

; ---- from_float ----

AhkStdlibDecimalFromFloat(value)
{
    if value is Integer
        return AhkStdlibDecimalValue(value)
    if !(value is Float)
        throw TypeError("argument must be int or float", -1)

    buf := Buffer(8)
    NumPut("Double", value, buf)
    bits := NumGet(buf, 0, "Int64")

    signBit := (bits >> 63) & 1
    exponentField := (bits >> 52) & 0x7FF
    mantissaField := bits & 0xFFFFFFFFFFFFF

    if exponentField = 0x7FF
        throw Error("[<class 'decimal.InvalidOperation'>] cannot convert NaN/Infinity", -1)

    if exponentField = 0 {
        ; subnormal
        mantissa := mantissaField
        binExp := -1074
    } else {
        mantissa := mantissaField + 0x10000000000000
        binExp := exponentField - 1075
    }

    if mantissa = 0
        return AhkStdlibDecimalFromParts(signBit, "0", 0)

    mantissaStr := String(mantissa)
    ; remove common factors of two: mantissa * 2**binExp
    if binExp >= 0 {
        coeff := AhkStdlibDecimalMulIntStrings(mantissaStr, AhkStdlibDecimalBigPow2(binExp))
        exponent := 0
    } else {
        k := -binExp
        ; strip trailing factors of 2 from mantissa to reduce 5**k size
        while k > 0 && AhkStdlibDecimalEndsWithEven(mantissaStr) {
            mantissaStr := AhkStdlibDecimalHalveIntString(mantissaStr)
            k -= 1
        }
        coeff := AhkStdlibDecimalMulIntStrings(mantissaStr, AhkStdlibDecimalBigPow5(k))
        exponent := -k
    }
    return AhkStdlibDecimalFromParts(signBit, AhkStdlibDecimalNormalizeIntString(coeff), exponent)
}

AhkStdlibDecimalEndsWithEven(value)
{
    return Mod(Integer(SubStr(value, -1)), 2) = 0
}

AhkStdlibDecimalHalveIntString(value)
{
    value := AhkStdlibDecimalNormalizeIntString(value)
    carry := 0
    result := ""
    loop StrLen(value) {
        digit := carry * 10 + Integer(SubStr(value, A_Index, 1))
        result .= String(digit // 2)
        carry := Mod(digit, 2)
    }
    return AhkStdlibDecimalNormalizeIntString(result)
}

; ---- end from_float ----

; ---- transcendental math (big-integer fixed-point, ported from CPython _pydecimal) ----

AhkStdlibDecimalDivNearest(a, b)
{
    ; a, b big strings, b > 0; closest integer to a/b, round half to even
    divmod := AhkStdlibDecimalBigDivModFloor(a, b)
    q := divmod.q
    r := divmod.r
    twoR := AhkStdlibDecimalMulIntStrings(AhkStdlibDecimalBigAbs(r), "2")
    parity := AhkStdlibDecimalBigOdd(q) ? "1" : "0"
    lhs := AhkStdlibDecimalAddIntStrings(twoR, parity)
    if AhkStdlibDecimalCompareIntStrings(lhs, AhkStdlibDecimalBigAbs(b)) > 0
        return AhkStdlibDecimalBigAdd(q, "1")
    return q
}

AhkStdlibDecimalRshiftNearest(x, shift)
{
    b := AhkStdlibDecimalBigPow2(shift)
    return AhkStdlibDecimalDivNearest(x, b)
}

AhkStdlibDecimalLshift(x, shift)
{
    return AhkStdlibDecimalBigMul(x, AhkStdlibDecimalBigPow2(shift))
}

AhkStdlibDecimalSqrtNearest(n, a)
{
    ; closest integer to sqrt(n); a is initial approximation (positive)
    b := "0"
    while AhkStdlibDecimalBigCmp(a, b) != 0 {
        b := a
        ; a = (a - -n//a) >> 1  == (a + n//a) >> 1
        quotient := AhkStdlibDecimalBigDivModFloor(n, a).q
        sum := AhkStdlibDecimalBigAdd(a, quotient)
        a := AhkStdlibDecimalBigDivModFloor(sum, "2").q
    }
    return a
}

AhkStdlibDecimalNbits(value)
{
    n := 0
    value := AhkStdlibDecimalBigAbs(value)
    while value != "0" {
        value := AhkStdlibDecimalHalveIntString(value)
        n += 1
    }
    return n
}

AhkStdlibDecimalCeilDivNeg(a, b)
{
    ; compute -int(-a//b) for positive a, b == ceil(a/b)
    divmod := AhkStdlibDecimalBigDivMod(a, b)
    if divmod.r = "0"
        return divmod.q
    return AhkStdlibDecimalAddIntStrings(divmod.q, "1")
}

; integer approximation to M*log(x/M)
AhkStdlibDecimalIlog(x, M)
{
    L := 8
    y := AhkStdlibDecimalBigSub(x, M)
    R := 0
    loop {
        absY := AhkStdlibDecimalBigAbs(y)
        if R <= L {
            lhs := AhkStdlibDecimalLshift(absY, L - R)
            cont := AhkStdlibDecimalCompareIntStrings(lhs, AhkStdlibDecimalBigAbs(M)) >= 0
        } else {
            lhs := AhkStdlibDecimalRshiftFloor(absY, R - L)
            cont := AhkStdlibDecimalCompareIntStrings(lhs, AhkStdlibDecimalBigAbs(M)) >= 0
        }
        if !cont
            break
        ; y = div_nearest((M*y)<<1, M + sqrt_nearest(M*(M+rshift_nearest(y,R)), M))
        num := AhkStdlibDecimalLshift(AhkStdlibDecimalBigMul(M, y), 1)
        inner := AhkStdlibDecimalBigAdd(M, AhkStdlibDecimalRshiftNearest(y, R))
        radicand := AhkStdlibDecimalBigMul(M, inner)
        denom := AhkStdlibDecimalBigAdd(M, AhkStdlibDecimalSqrtNearest(radicand, M))
        y := AhkStdlibDecimalDivNearest(num, denom)
        R += 1
    }
    ; T = ceil(10*len(str(M)) / (3*L))
    T := AhkStdlibDecimalCeilDivScalar(10 * StrLen(AhkStdlibDecimalBigAbs(M)), 3 * L)
    yshift := AhkStdlibDecimalRshiftNearest(y, R)
    w := AhkStdlibDecimalDivNearest(M, String(T))
    k := T - 1
    while k > 0 {
        term := AhkStdlibDecimalDivNearest(AhkStdlibDecimalBigMul(yshift, w), M)
        w := AhkStdlibDecimalBigSub(AhkStdlibDecimalDivNearest(M, String(k)), term)
        k -= 1
    }
    return AhkStdlibDecimalDivNearest(AhkStdlibDecimalBigMul(w, y), M)
}

AhkStdlibDecimalCeilDivScalar(a, b)
{
    return (a + b - 1) // b
}

AhkStdlibDecimalRshiftFloor(x, shift)
{
    return AhkStdlibDecimalBigDivModFloor(x, AhkStdlibDecimalBigPow2(shift)).q
}

; ---- end transcendental math part 1 ----

; cached: floor(10**p * log(10)) as a big string, truncated
AhkStdlibDecimalLog10Digits(p)
{
    static digits := ""
    if p < 0
        throw ValueError("p should be nonnegative", -1)
    if p >= StrLen(digits) {
        extra := 3
        loop {
            M := AhkStdlibDecimalBigPow10(p + extra + 2)
            tenM := AhkStdlibDecimalMultiplyIntStringDigit(M, 10)
            computed := AhkStdlibDecimalDivNearest(AhkStdlibDecimalIlog(tenM, M), "100")
            computed := AhkStdlibDecimalBigAbs(computed)
            tail := SubStr(computed, -extra)
            if RegExMatch(tail, "[1-9]")
                break
            extra += 3
        }
        ; rstrip zeros, drop last digit
        trimmed := RegExReplace(computed, "0+$")
        digits := SubStr(trimmed, 1, StrLen(trimmed) - 1)
    }
    return SubStr(digits, 1, p + 1)
}

; integer approximation to 10**p * log(c*10**e)
AhkStdlibDecimalDlog(c, e, p)
{
    p += 2
    l := StrLen(AhkStdlibDecimalBigAbs(c))
    f := e + l - ((e + l >= 1) ? 1 : 0)
    if p > 0 {
        k := e + p - f
        if k >= 0
            c := AhkStdlibDecimalBigMul(c, AhkStdlibDecimalBigPow10(k))
        else
            c := AhkStdlibDecimalDivNearest(c, AhkStdlibDecimalBigPow10(-k))
        logD := AhkStdlibDecimalIlog(c, AhkStdlibDecimalBigPow10(p))
    } else {
        logD := "0"
    }
    if f != 0 {
        extra := StrLen(String(Abs(f))) - 1
        if p + extra >= 0 {
            fLog := AhkStdlibDecimalDivNearest(AhkStdlibDecimalBigMul(String(f), AhkStdlibDecimalLog10Digits(p + extra)), AhkStdlibDecimalBigPow10(extra))
        } else {
            fLog := "0"
        }
    } else {
        fLog := "0"
    }
    return AhkStdlibDecimalDivNearest(AhkStdlibDecimalBigAdd(fLog, logD), "100")
}

; integer approximation to 10**p * log10(c*10**e)
AhkStdlibDecimalDlog10(c, e, p)
{
    p += 2
    l := StrLen(AhkStdlibDecimalBigAbs(c))
    f := e + l - ((e + l >= 1) ? 1 : 0)
    if p > 0 {
        M := AhkStdlibDecimalBigPow10(p)
        k := e + p - f
        if k >= 0
            c := AhkStdlibDecimalBigMul(c, AhkStdlibDecimalBigPow10(k))
        else
            c := AhkStdlibDecimalDivNearest(c, AhkStdlibDecimalBigPow10(-k))
        logD := AhkStdlibDecimalIlog(c, M)
        log10 := AhkStdlibDecimalLog10Digits(p)
        logD := AhkStdlibDecimalDivNearest(AhkStdlibDecimalBigMul(logD, M), log10)
        logTenpower := AhkStdlibDecimalBigMul(String(f), M)
    } else {
        logD := "0"
        logTenpower := AhkStdlibDecimalDivNearest(String(f), AhkStdlibDecimalBigPow10(-p))
    }
    return AhkStdlibDecimalDivNearest(AhkStdlibDecimalBigAdd(logTenpower, logD), "100")
}

; integer approximation to M*exp(x/M) for x/M small
AhkStdlibDecimalIexp(x, M)
{
    L := 8
    R := AhkStdlibDecimalNbits(AhkStdlibDecimalBigDivModFloor(AhkStdlibDecimalLshift(x, L), M).q)
    T := AhkStdlibDecimalCeilDivScalar(10 * StrLen(AhkStdlibDecimalBigAbs(M)), 3 * L)
    y := AhkStdlibDecimalDivNearest(x, String(T))
    Mshift := AhkStdlibDecimalLshift(M, R)
    i := T - 1
    while i > 0 {
        ; y = div_nearest(x*(Mshift + y), Mshift * i)
        num := AhkStdlibDecimalBigMul(x, AhkStdlibDecimalBigAdd(Mshift, y))
        denom := AhkStdlibDecimalBigMul(Mshift, String(i))
        y := AhkStdlibDecimalDivNearest(num, denom)
        i -= 1
    }
    k := R - 1
    while k >= 0 {
        Mshift := AhkStdlibDecimalLshift(M, k + 2)
        ; y = div_nearest(y*(y+Mshift), Mshift)
        y := AhkStdlibDecimalDivNearest(AhkStdlibDecimalBigMul(y, AhkStdlibDecimalBigAdd(y, Mshift)), Mshift)
        k -= 1
    }
    return AhkStdlibDecimalBigAdd(M, y)
}

; compute approximation to exp(c*10**e); returns { coeff, exp }
AhkStdlibDecimalDexp(c, e, p)
{
    p += 2
    cLen := StrLen(AhkStdlibDecimalBigAbs(c))
    extra := (e + cLen - 1) > 0 ? (e + cLen - 1) : 0
    q := p + extra
    shift := e + q
    if shift >= 0
        cshift := AhkStdlibDecimalBigMul(c, AhkStdlibDecimalBigPow10(shift))
    else
        cshift := AhkStdlibDecimalBigDivModFloor(c, AhkStdlibDecimalBigPow10(-shift)).q
    log10q := AhkStdlibDecimalLog10Digits(q)
    divmod := AhkStdlibDecimalBigDivModFloor(cshift, log10q)
    quot := divmod.q
    rem := divmod.r
    rem := AhkStdlibDecimalDivNearest(rem, AhkStdlibDecimalBigPow10(extra))
    coeff := AhkStdlibDecimalDivNearest(AhkStdlibDecimalIexp(rem, AhkStdlibDecimalBigPow10(p)), "1000")
    expOut := AhkStdlibDecimalBigSub(quot, String(p - 3))
    return { coeff: coeff, exp: AhkStdlibDecimalBigToScalar(expOut) }
}

; ---- end transcendental math part 2 ----

; round (sign, digitsString, exponent) to precision p with ROUND_HALF_EVEN
AhkStdlibDecimalFixHalfEven(sign, digits, exponent, prec)
{
    if digits = "0"
        return AhkStdlibDecimalFromParts(0, "0", exponent)
    if StrLen(digits) <= prec
        return AhkStdlibDecimalFromParts(sign, digits, exponent)
    dropCount := StrLen(digits) - prec
    rounded := AhkStdlibDecimalRoundCoeff(sign, digits, dropCount, "ROUND_HALF_EVEN")
    newExp := exponent + dropCount
    newDigits := rounded.digits
    if rounded.grew && StrLen(newDigits) > prec {
        newDigits := SubStr(newDigits, 1, prec)
        newExp += 1
    }
    return AhkStdlibDecimalFromParts(sign, newDigits, newExp)
}

AhkStdlibDecimalSqrt(sign, digits, exponent)
{
    prec := AhkStdlibDecimalCurrentContext().prec
    if digits = "0" {
        ideal := exponent // 2
        return AhkStdlibDecimalFromParts(sign, "0", ideal)
    }
    if sign
        throw Error("[<class 'decimal.InvalidOperation'>] sqrt(-x), x > 0", -1)

    workPrec := prec + 1
    intStr := digits
    e := exponent >> 1
    if exponent & 1 {
        c := AhkStdlibDecimalMultiplyIntStringDigit(intStr, 10)
        l := (StrLen(intStr) >> 1) + 1
    } else {
        c := intStr
        l := (StrLen(intStr) + 1) >> 1
    }
    shift := workPrec - l
    exact := true
    if shift >= 0 {
        c := AhkStdlibDecimalMulIntStrings(c, AhkStdlibDecimalBigPow100(shift))
    } else {
        divmod := AhkStdlibDecimalBigDivMod(c, AhkStdlibDecimalBigPow100(-shift))
        c := divmod.q
        exact := (divmod.r = "0")
    }
    e -= shift

    ; Newton: n = floor(sqrt(c))
    n := AhkStdlibDecimalBigPow10(workPrec)
    loop {
        q := AhkStdlibDecimalBigDivModFloor(c, n).q
        if AhkStdlibDecimalBigCmp(n, q) <= 0
            break
        n := AhkStdlibDecimalBigDivModFloor(AhkStdlibDecimalBigAdd(n, q), "2").q
    }
    exact := exact && (AhkStdlibDecimalBigMul(n, n) = c)

    if exact {
        if shift >= 0
            n := AhkStdlibDecimalBigDivMod(n, AhkStdlibDecimalBigPow10(shift)).q
        else
            n := AhkStdlibDecimalMulIntStrings(n, AhkStdlibDecimalBigPow10(-shift))
        e += shift
    } else {
        if AhkStdlibDecimalBigDivMod(n, "5").r = "0"
            n := AhkStdlibDecimalBigAdd(n, "1")
    }
    return AhkStdlibDecimalFixHalfEven(0, AhkStdlibDecimalNormalizeIntString(n), e, prec)
}

AhkStdlibDecimalBigPow100(exp)
{
    result := "1"
    while exp > 0 {
        result .= "00"
        exp -= 1
    }
    return result
}

AhkStdlibDecimalLn(sign, digits, exponent)
{
    if digits = "0"
        throw Error("[<class 'decimal.InvalidOperation'>] ln(0)", -1)
    if sign
        throw Error("[<class 'decimal.InvalidOperation'>] ln of a negative value", -1)
    if digits = "1" && exponent = 0
        return AhkStdlibDecimalFromParts(0, "0", 0)

    prec := AhkStdlibDecimalCurrentContext().prec
    c := digits
    e := exponent
    places := prec + 3
    coeff := ""
    loop {
        coeff := AhkStdlibDecimalDlog(c, e, places)
        coeffLen := StrLen(AhkStdlibDecimalBigAbs(coeff))
        modBase := AhkStdlibDecimalMultiplyIntStringDigit(AhkStdlibDecimalBigPow10(coeffLen - prec - 1), 5)
        if AhkStdlibDecimalBigDivMod(coeff, modBase).r != "0"
            break
        places += 3
    }
    resultSign := AhkStdlibDecimalBigIsNeg(coeff) ? 1 : 0
    return AhkStdlibDecimalFixHalfEven(resultSign, AhkStdlibDecimalBigAbs(coeff), -places, prec)
}

AhkStdlibDecimalLog10(sign, digits, exponent)
{
    if digits = "0"
        throw Error("[<class 'decimal.InvalidOperation'>] log10(0)", -1)
    if sign
        throw Error("[<class 'decimal.InvalidOperation'>] log10 of a negative value", -1)

    prec := AhkStdlibDecimalCurrentContext().prec
    ; log10(10**n) = n exactly
    if SubStr(digits, 1, 1) = "1" && RegExReplace(SubStr(digits, 2), "0", "") = "" {
        n := exponent + StrLen(digits) - 1
        return AhkStdlibDecimalFixHalfEven(n < 0 ? 1 : 0, String(Abs(n)) = "0" ? "0" : String(Abs(n)), 0, prec)
    }

    c := digits
    e := exponent
    places := prec + 3
    coeff := ""
    loop {
        coeff := AhkStdlibDecimalDlog10(c, e, places)
        coeffLen := StrLen(AhkStdlibDecimalBigAbs(coeff))
        modBase := AhkStdlibDecimalMultiplyIntStringDigit(AhkStdlibDecimalBigPow10(coeffLen - prec - 1), 5)
        if AhkStdlibDecimalBigDivMod(coeff, modBase).r != "0"
            break
        places += 3
    }
    resultSign := AhkStdlibDecimalBigIsNeg(coeff) ? 1 : 0
    return AhkStdlibDecimalFixHalfEven(resultSign, AhkStdlibDecimalBigAbs(coeff), -places, prec)
}

AhkStdlibDecimalExp(sign, digits, exponent)
{
    if digits = "0"
        return AhkStdlibDecimalFromParts(0, "1", 0)

    prec := AhkStdlibDecimalCurrentContext().prec
    c := digits
    e := exponent
    if sign
        c := "-" c

    extra := 3
    coeff := ""
    expOut := 0
    loop {
        result := AhkStdlibDecimalDexp(c, e, prec + extra)
        coeff := result.coeff
        expOut := result.exp
        coeffLen := StrLen(AhkStdlibDecimalBigAbs(coeff))
        modBase := AhkStdlibDecimalMultiplyIntStringDigit(AhkStdlibDecimalBigPow10(coeffLen - prec - 1), 5)
        if AhkStdlibDecimalBigDivMod(coeff, modBase).r != "0"
            break
        extra += 3
    }
    return AhkStdlibDecimalFixHalfEven(0, AhkStdlibDecimalBigAbs(coeff), expOut, prec)
}
