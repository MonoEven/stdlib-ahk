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
        return AhkStdlibDecimalFromScaledInteger(leftInt + rightInt, scale)
    }

    __Sub(other)
    {
        other := AhkStdlibDecimalCoerce(other)
        if other = ""
            return ""
        scale := this.exponent < other.exponent ? this.exponent : other.exponent
        leftInt := AhkStdlibDecimalScaledInteger(this.sign, this.digits, this.exponent, scale)
        rightInt := AhkStdlibDecimalScaledInteger(other.sign, other.digits, other.exponent, scale)
        return AhkStdlibDecimalFromScaledInteger(leftInt - rightInt, scale)
    }

    __Mul(other)
    {
        other := AhkStdlibDecimalCoerce(other)
        if other = ""
            return ""
        leftInt := (this.sign ? -1 : 1) * Integer(this.digits)
        rightInt := (other.sign ? -1 : 1) * Integer(other.digits)
        return AhkStdlibDecimalFromScaledInteger(leftInt * rightInt, this.exponent + other.exponent)
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

        if denominator != 1
            return AhkStdlibDecimalDivideToContext(String(numerator), String(denominator), scaleExponent, 28)

        return AhkStdlibDecimalFromScaledInteger(numerator, scaleExponent)
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

    __enter__()
    {
        this.previous := AhkStdlibDecimalCurrentContext()
        nextContext := HasProp(this, "context") ? this.context.copy() : this.previous.copy()
        AhkStdlibDecimalCurrentContext(nextContext)
        return nextContext
    }

    __exit__(excType, exc, tb)
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
    if left = right
        return 0
    return left < right ? -1 : 1
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
