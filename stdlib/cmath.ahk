#Requires AutoHotkey v2.0

#Include <stdlib\init>

; cmath / complex: AHK has no native complex type, but operator overloading
; (proven by fractions/decimal) lets us model complex as a value class with
; __Add/__Sub/__Mul/__Div/__Pow/__Neg/__Compare. cmath then mirrors Python's
; complex-valued math built on real float primitives (ucrtbase for hypot/atan2/
; sinh/cosh, native Sqrt/Exp/Ln/Sin/Cos). sqrt uses Kahan's algorithm so the
; tested exact cases (sqrt(-1)=1j, sqrt(3+4j)=2+1j) round-trip cleanly.

class AhkStdlibComplex
{
    ; Facade absorbing the injected module-attribute `this` (see ahk-v2-pitfalls)
    ; and forwarding to the real value constructor.
    static Call(thisClass, real := 0, imag := unset)
    {
        return AhkStdlibComplexConstruct(real, imag?)
    }
}

stdlib.complex := AhkStdlibComplex

AhkStdlibComplexConstruct(real := 0, imag := unset)
{
    ; complex(string) — only a single string argument is allowed.
    if real is String {
        if IsSet(imag)
            throw TypeError("complex() can't take second arg if first is a string", -1)
        return AhkStdlibComplexParse(real)
    }
    if IsSet(imag) && imag is String
        throw TypeError("complex() second arg can't be a string", -1)

    ; complex(complex [, complex]) — Python allows complex parts; flatten them.
    rr := 0.0, ri := 0.0
    if AhkStdlibIsComplex(real)
        rr := real.real, ri := real.imag
    else if real is Number
        rr := real + 0.0
    else if AhkStdlibIsBool(real)
        rr := real.Value ? 1.0 : 0.0
    else
        throw TypeError("complex() first argument must be a string or a number, not '" AhkStdlibPythonTypeName(real) "'", -1)

    if IsSet(imag) {
        if AhkStdlibIsComplex(imag)
            rr -= imag.imag, ri += imag.real
        else if imag is Number
            ri += imag + 0.0
        else if AhkStdlibIsBool(imag)
            ri += imag.Value ? 1.0 : 0.0
        else
            throw TypeError("complex() second argument must be a number, not '" AhkStdlibPythonTypeName(imag) "'", -1)
    }

    return AhkStdlibComplexValue(rr, ri)
}

class AhkStdlibComplexValue
{
    __New(real := 0.0, imag := 0.0)
    {
        this.real := real + 0.0
        this.imag := imag + 0.0
    }

    conjugate()
    {
        return AhkStdlibComplexValue(this.real, -this.imag)
    }

    ToString()
    {
        return AhkStdlibComplexRepr(this)
    }

    __Repr()
    {
        return AhkStdlibComplexRepr(this)
    }

    __Add(other)
    {
        o := AhkStdlibComplexCoerce(other)
        if o = ""
            return ""
        return AhkStdlibComplexValue(this.real + o.real, this.imag + o.imag)
    }

    __Sub(other)
    {
        o := AhkStdlibComplexCoerce(other)
        if o = ""
            return ""
        return AhkStdlibComplexValue(this.real - o.real, this.imag - o.imag)
    }

    __Mul(other)
    {
        o := AhkStdlibComplexCoerce(other)
        if o = ""
            return ""
        return AhkStdlibComplexValue(
            this.real * o.real - this.imag * o.imag,
            this.real * o.imag + this.imag * o.real
        )
    }

    __Div(other)
    {
        o := AhkStdlibComplexCoerce(other)
        if o = ""
            return ""
        return AhkStdlibComplexDivide(this, o)
    }

    __Pow(exponent)
    {
        o := AhkStdlibComplexCoerce(exponent)
        if o = ""
            return ""
        return AhkStdlibComplexPow(this, o)
    }

    __Neg()
    {
        return AhkStdlibComplexValue(-this.real, -this.imag)
    }

    __Pos()
    {
        return AhkStdlibComplexValue(this.real, this.imag)
    }

    ; complex supports only == / != ; ordering raises (matching CPython).
    __Compare(other, op)
    {
        if op != "eq" && op != "ne"
            return ""
        o := AhkStdlibComplexCoerce(other)
        if o = ""
            return ""
        equal := (this.real = o.real) && (this.imag = o.imag)
        return equal ? 0 : 1
    }
}

; Coerce an operand into a complex value, or "" when it is not a number.
AhkStdlibComplexCoerce(value)
{
    if AhkStdlibIsComplex(value)
        return value
    if value is Number
        return AhkStdlibComplexValue(value + 0.0, 0.0)
    if AhkStdlibIsBool(value)
        return AhkStdlibComplexValue(value.Value ? 1.0 : 0.0, 0.0)
    return ""
}

AhkStdlibIsComplex(value)
{
    return Type(value) = "AhkStdlibComplexValue"
}

AhkStdlibComplexDivide(a, b)
{
    ; Smith's algorithm: scale by the larger component to avoid overflow.
    br := b.real, bi := b.imag
    if Abs(br) >= Abs(bi) {
        if br = 0.0 && bi = 0.0
            throw ZeroDivisionError("complex division by zero", -1)
        ratio := bi / br
        denom := br + bi * ratio
        return AhkStdlibComplexValue(
            (a.real + a.imag * ratio) / denom,
            (a.imag - a.real * ratio) / denom
        )
    }
    ratio := br / bi
    denom := br * ratio + bi
    return AhkStdlibComplexValue(
        (a.real * ratio + a.imag) / denom,
        (a.imag * ratio - a.real) / denom
    )
}

AhkStdlibComplexPow(a, b)
{
    ; 0**0 == 1; 0**positive == 0 (matching CPython special-casing).
    if a.real = 0.0 && a.imag = 0.0 {
        if b.real = 0.0 && b.imag = 0.0
            return AhkStdlibComplexValue(1.0, 0.0)
        if b.imag = 0.0 && b.real > 0.0
            return AhkStdlibComplexValue(0.0, 0.0)
        throw ZeroDivisionError("0.0 to a negative or complex power", -1)
    }

    ; Integer real exponents use repeated multiplication for exactness.
    if b.imag = 0.0 && b.real = Round(b.real) && Abs(b.real) <= 100 {
        n := Integer(b.real)
        return AhkStdlibComplexIntPow(a, n)
    }

    ; General case: exp(b * log(a)).
    logA := AhkStdlibComplexLog(a)
    prod := AhkStdlibComplexValue(
        b.real * logA.real - b.imag * logA.imag,
        b.real * logA.imag + b.imag * logA.real
    )
    return AhkStdlibComplexExp(prod)
}

AhkStdlibComplexIntPow(a, n)
{
    if n = 0
        return AhkStdlibComplexValue(1.0, 0.0)
    negative := n < 0
    n := Abs(n)
    result := AhkStdlibComplexValue(1.0, 0.0)
    baseValue := AhkStdlibComplexValue(a.real, a.imag)
    while n > 0 {
        if Mod(n, 2) = 1
            result := AhkStdlibComplexValue(
                result.real * baseValue.real - result.imag * baseValue.imag,
                result.real * baseValue.imag + result.imag * baseValue.real
            )
        n := n // 2
        if n > 0
            baseValue := AhkStdlibComplexValue(
                baseValue.real * baseValue.real - baseValue.imag * baseValue.imag,
                2 * baseValue.real * baseValue.imag
            )
    }
    if negative
        return AhkStdlibComplexDivide(AhkStdlibComplexValue(1.0, 0.0), result)
    return result
}

; --- complex(string) parsing ---------------------------------------------
AhkStdlibComplexParse(text)
{
    raw := Trim(text)
    if raw = ""
        throw ValueError("complex() arg is a malformed string", -1)

    ; Strip a single surrounding pair of parentheses.
    if SubStr(raw, 1, 1) = "(" && SubStr(raw, -1) = ")"
        raw := Trim(SubStr(raw, 2, StrLen(raw) - 2))
    if raw = "" || InStr(raw, " ")
        throw ValueError("complex() arg is a malformed string", -1)

    ; 'j'/'J' suffix marks the imaginary unit.
    if SubStr(raw, -1) = "j" || SubStr(raw, -1) = "J"
        return AhkStdlibComplexParseImaginaryOnly(raw)

    ; Pure real: must be a valid float literal.
    if !AhkStdlibComplexIsFloatLiteral(raw)
        throw ValueError("complex() arg is a malformed string", -1)
    return AhkStdlibComplexValue(Float(raw), 0.0)
}

AhkStdlibComplexParseImaginaryOnly(raw)
{
    body := SubStr(raw, 1, StrLen(raw) - 1)   ; drop trailing j

    ; Find the split point between real and imaginary: a +/- that is not part
    ; of an exponent (e+/e-) and not the leading sign.
    splitPos := 0
    loop StrLen(body) {
        i := StrLen(body) - A_Index + 1
        if i <= 1
            break
        ch := SubStr(body, i, 1)
        if ch = "+" || ch = "-" {
            prev := SubStr(body, i - 1, 1)
            if prev = "e" || prev = "E"
                continue
            splitPos := i
            break
        }
    }

    if splitPos {
        realText := SubStr(body, 1, splitPos - 1)
        imagText := SubStr(body, splitPos)
        if !AhkStdlibComplexIsFloatLiteral(realText)
            throw ValueError("complex() arg is a malformed string", -1)
        imagValue := AhkStdlibComplexImagMagnitude(imagText)
        return AhkStdlibComplexValue(Float(realText), imagValue)
    }

    return AhkStdlibComplexValue(0.0, AhkStdlibComplexImagMagnitude(body))
}

AhkStdlibComplexImagMagnitude(imagText)
{
    if imagText = "" || imagText = "+"
        return 1.0
    if imagText = "-"
        return -1.0
    if !AhkStdlibComplexIsFloatLiteral(imagText)
        throw ValueError("complex() arg is a malformed string", -1)
    return Float(imagText)
}

AhkStdlibComplexIsFloatLiteral(text)
{
    if text = ""
        return false
    lower := StrLower(text)
    if lower = "inf" || lower = "+inf" || lower = "-inf"
        return true
    if lower = "nan" || lower = "+nan" || lower = "-nan"
        return true
    return RegExMatch(text, "^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$") > 0
}

; --- repr / str ----------------------------------------------------------
AhkStdlibComplexRepr(z)
{
    re := z.real, im := z.imag

    ; Pure-imaginary (real is +0.0) prints without parens, e.g. "1j", "-1j".
    if AhkStdlibComplexIsPositiveZero(re) {
        return AhkStdlibComplexFloatPart(im) "j"
    }

    realStr := AhkStdlibComplexFloatPart(re)
    imStr := AhkStdlibComplexFloatPart(im)
    sign := (SubStr(imStr, 1, 1) = "-") ? "" : "+"
    return "(" realStr sign imStr "j)"
}

AhkStdlibComplexIsPositiveZero(x)
{
    ; +0.0 has bit pattern 0; -0.0 has the sign bit set.
    if x != 0.0
        return false
    buf := Buffer(8)
    NumPut("Double", x, buf)
    return NumGet(buf, 0, "Int64") = 0
}

; Render one float component the way CPython renders complex parts: shortest
; round-tripping digits with no trailing ".0" (so 3.0 -> "3"), and inf/nan
; spelled out.
AhkStdlibComplexFloatPart(x)
{
    if AhkStdlibComplexIsNan(x)
        return "nan"
    if x = AhkStdlibComplexInfValue()
        return "inf"
    if x = -AhkStdlibComplexInfValue()
        return "-inf"
    return AhkStdlibComplexFormatFloat(x)
}

; Shortest round-trip float formatting matching Python's repr, but WITHOUT the
; trailing ".0" that float repr appends (complex parts omit it).
AhkStdlibComplexFormatFloat(x)
{
    if x = 0.0
        return AhkStdlibComplexIsPositiveZero(x) ? "0" : "-0"

    ; Find the shortest precision (scientific) that round-trips.
    sci := ""
    loop 17 {
        p := A_Index - 1
        candidate := Format("{:." p "e}", x)
        if Float(candidate) = x {
            sci := candidate
            break
        }
    }
    if sci = ""
        sci := Format("{:.16e}", x)

    return AhkStdlibComplexSciToPython(sci)
}

; Convert an AHK "{:.Ne}" string (d.dddde±XX) to Python's repr layout: fixed
; notation when -4 < decimal-point-exponent <= 16, else exponential.
AhkStdlibComplexSciToPython(sci)
{
    negative := false
    if SubStr(sci, 1, 1) = "-" {
        negative := true
        sci := SubStr(sci, 2)
    } else if SubStr(sci, 1, 1) = "+" {
        sci := SubStr(sci, 2)
    }

    ePos := InStr(sci, "e")
    mantissa := SubStr(sci, 1, ePos - 1)
    exp := Integer(SubStr(sci, ePos + 1))

    dot := InStr(mantissa, ".")
    if dot
        digits := SubStr(mantissa, 1, dot - 1) SubStr(mantissa, dot + 1)
    else
        digits := mantissa
    ; Strip trailing zeros in the significant digits.
    digits := RegExReplace(digits, "0+$")
    if digits = ""
        digits := "0"

    decpt := exp + 1   ; position of decimal point relative to first digit
    sign := negative ? "-" : ""

    ; Python: use exponential if decpt < -3 or decpt > 16.
    if decpt < -3 || decpt > 16
        return sign AhkStdlibComplexBuildExponential(digits, decpt)

    return sign AhkStdlibComplexBuildFixed(digits, decpt)
}

AhkStdlibComplexBuildFixed(digits, decpt)
{
    n := StrLen(digits)
    if decpt <= 0
        return "0." AhkStdlibComplexZeros(-decpt) digits
    if decpt >= n
        return digits AhkStdlibComplexZeros(decpt - n)
    return SubStr(digits, 1, decpt) "." SubStr(digits, decpt + 1)
}

AhkStdlibComplexBuildExponential(digits, decpt)
{
    n := StrLen(digits)
    mant := SubStr(digits, 1, 1)
    if n > 1
        mant .= "." SubStr(digits, 2)
    e := decpt - 1
    esign := e < 0 ? "-" : "+"
    eabs := Abs(e)
    epad := eabs < 10 ? "0" eabs : String(eabs)
    return mant "e" esign epad
}

AhkStdlibComplexZeros(count)
{
    s := ""
    loop count
        s .= "0"
    return s
}

; --- float primitives (shared by cmath internals) ------------------------
AhkStdlibComplexInfValue()
{
    static value := AhkStdlibComplexMakeInf()
    return value
}

AhkStdlibComplexMakeInf()
{
    buf := Buffer(8)
    NumPut("Int64", 0x7FF0000000000000, buf)
    return NumGet(buf, 0, "Double")
}

AhkStdlibComplexNanValue()
{
    static value := AhkStdlibComplexMakeNan()
    return value
}

AhkStdlibComplexMakeNan()
{
    buf := Buffer(8)
    NumPut("Int64", 0x7FF8000000000000, buf)
    return NumGet(buf, 0, "Double")
}

AhkStdlibComplexIsNan(x)
{
    return x != x
}

AhkStdlibComplexHypot(a, b)
{
    return DllCall("ucrtbase\hypot", "Double", a, "Double", b, "Cdecl Double")
}

AhkStdlibComplexAtan2(y, x)
{
    return DllCall("ucrtbase\atan2", "Double", y, "Double", x, "Cdecl Double")
}

AhkStdlibComplexSinh(x)
{
    return DllCall("ucrtbase\sinh", "Double", x, "Cdecl Double")
}

AhkStdlibComplexCosh(x)
{
    return DllCall("ucrtbase\cosh", "Double", x, "Cdecl Double")
}

; --- cmath module --------------------------------------------------------
class AhkStdlibCmath
{
    static pi := 3.141592653589793
    static e := 2.718281828459045
    static tau := 6.283185307179586
    static inf := AhkStdlibComplexInfValue()
    static nan := AhkStdlibComplexNanValue()
    static infj := AhkStdlibComplexValue(0.0, AhkStdlibComplexInfValue())
    static nanj := AhkStdlibComplexValue(0.0, AhkStdlibComplexNanValue())

    static phase(z) => AhkStdlibCmathPhase(z)
    static polar(z) => AhkStdlibCmathPolar(z)
    static rect(r, phi) => AhkStdlibCmathRect(r, phi)

    static sqrt(z) => AhkStdlibComplexSqrt(AhkStdlibCmathArg(z))
    static exp(z) => AhkStdlibComplexExp(AhkStdlibCmathArg(z))
    static log(z, base := unset) => AhkStdlibCmathLog(z, base?)
    static log10(z) => AhkStdlibCmathLog10(z)

    static sin(z) => AhkStdlibComplexSin(AhkStdlibCmathArg(z))
    static cos(z) => AhkStdlibComplexCos(AhkStdlibCmathArg(z))
    static tan(z) => AhkStdlibComplexTan(AhkStdlibCmathArg(z))
    static sinh(z) => AhkStdlibComplexSinhC(AhkStdlibCmathArg(z))
    static cosh(z) => AhkStdlibComplexCoshC(AhkStdlibCmathArg(z))
    static tanh(z) => AhkStdlibComplexTanhC(AhkStdlibCmathArg(z))

    static asin(z) => AhkStdlibComplexAsin(AhkStdlibCmathArg(z))
    static acos(z) => AhkStdlibComplexAcos(AhkStdlibCmathArg(z))
    static atan(z) => AhkStdlibComplexAtan(AhkStdlibCmathArg(z))
    static asinh(z) => AhkStdlibComplexAsinh(AhkStdlibCmathArg(z))
    static acosh(z) => AhkStdlibComplexAcosh(AhkStdlibCmathArg(z))
    static atanh(z) => AhkStdlibComplexAtanh(AhkStdlibCmathArg(z))

    static isfinite(z) => AhkStdlibCmathIsFinite(z)
    static isinf(z) => AhkStdlibCmathIsInf(z)
    static isnan(z) => AhkStdlibCmathIsNan(z)
    static isclose(a, b, kwargs := unset) => AhkStdlibCmathIsClose(a, b, kwargs?)
}

stdlib.cmath := AhkStdlibCmath

; Coerce any numeric argument into a complex value for cmath functions.
AhkStdlibCmathArg(z)
{
    result := AhkStdlibComplexCoerce(z)
    if result = ""
        throw TypeError("must be real number, not " AhkStdlibPythonTypeName(z), -1)
    return result
}

AhkStdlibCmathPhase(z)
{
    c := AhkStdlibCmathArg(z)
    return AhkStdlibComplexAtan2(c.imag, c.real)
}

AhkStdlibCmathPolar(z)
{
    c := AhkStdlibCmathArg(z)
    r := AhkStdlibComplexHypot(c.real, c.imag)
    phi := AhkStdlibComplexAtan2(c.imag, c.real)
    return stdlib.tuple([r, phi])
}

AhkStdlibCmathRect(r, phi)
{
    if !(r is Number) || !(phi is Number)
        throw TypeError("must be real number", -1)
    return AhkStdlibComplexValue(r * Cos(phi), r * Sin(phi))
}

AhkStdlibCmathLog(z, base := unset)
{
    result := AhkStdlibComplexLog(AhkStdlibCmathArg(z))
    if !IsSet(base)
        return result
    denom := AhkStdlibComplexLog(AhkStdlibCmathArg(base))
    return AhkStdlibComplexDivide(result, denom)
}

AhkStdlibCmathLog10(z)
{
    c := AhkStdlibComplexLog(AhkStdlibCmathArg(z))
    ln10 := 2.302585092994046
    return AhkStdlibComplexValue(c.real / ln10, c.imag / ln10)
}

; --- complex elementary functions ----------------------------------------
AhkStdlibComplexLog(z)
{
    r := AhkStdlibComplexHypot(z.real, z.imag)
    if r = 0.0
        throw ValueError("math domain error", -1)
    return AhkStdlibComplexValue(Ln(r), AhkStdlibComplexAtan2(z.imag, z.real))
}

AhkStdlibComplexExp(z)
{
    expReal := Exp(z.real)
    return AhkStdlibComplexValue(expReal * Cos(z.imag), expReal * Sin(z.imag))
}

AhkStdlibComplexSqrt(z)
{
    if z.real = 0.0 && z.imag = 0.0
        return AhkStdlibComplexValue(0.0, 0.0)

    ; Kahan's robust algorithm.
    ax := Abs(z.real)
    ay := Abs(z.imag)
    if ax >= ay {
        t := ay / ax
        w := Sqrt(ax) * Sqrt((1.0 + Sqrt(1.0 + t * t)) / 2.0)
    } else {
        t := ax / ay
        w := Sqrt(ay) * Sqrt((t + Sqrt(1.0 + t * t)) / 2.0)
    }

    if z.real >= 0.0
        return AhkStdlibComplexValue(w, z.imag / (2.0 * w))
    resultImag := z.imag >= 0.0 ? w : -w
    return AhkStdlibComplexValue(z.imag / (2.0 * resultImag), resultImag)
}

AhkStdlibComplexSin(z)
{
    return AhkStdlibComplexValue(
        Sin(z.real) * AhkStdlibComplexCosh(z.imag),
        Cos(z.real) * AhkStdlibComplexSinh(z.imag)
    )
}

AhkStdlibComplexCos(z)
{
    return AhkStdlibComplexValue(
        Cos(z.real) * AhkStdlibComplexCosh(z.imag),
        -Sin(z.real) * AhkStdlibComplexSinh(z.imag)
    )
}

AhkStdlibComplexTan(z)
{
    return AhkStdlibComplexDivide(AhkStdlibComplexSin(z), AhkStdlibComplexCos(z))
}

AhkStdlibComplexSinhC(z)
{
    return AhkStdlibComplexValue(
        AhkStdlibComplexSinh(z.real) * Cos(z.imag),
        AhkStdlibComplexCosh(z.real) * Sin(z.imag)
    )
}

AhkStdlibComplexCoshC(z)
{
    return AhkStdlibComplexValue(
        AhkStdlibComplexCosh(z.real) * Cos(z.imag),
        AhkStdlibComplexSinh(z.real) * Sin(z.imag)
    )
}

AhkStdlibComplexTanhC(z)
{
    return AhkStdlibComplexDivide(AhkStdlibComplexSinhC(z), AhkStdlibComplexCoshC(z))
}

; Inverse trig/hyperbolic via the standard complex identities.
; asinh(z) = log(z + sqrt(z^2 + 1))
AhkStdlibComplexAsinh(z)
{
    z2 := AhkStdlibComplexValue(z.real * z.real - z.imag * z.imag + 1.0, 2.0 * z.real * z.imag)
    root := AhkStdlibComplexSqrt(z2)
    sum := AhkStdlibComplexValue(z.real + root.real, z.imag + root.imag)
    return AhkStdlibComplexLog(sum)
}

; asin(z) = -i * asinh(i*z)
AhkStdlibComplexAsin(z)
{
    iz := AhkStdlibComplexValue(-z.imag, z.real)
    r := AhkStdlibComplexAsinh(iz)
    return AhkStdlibComplexValue(r.imag, -r.real)
}

; acos(z) = pi/2 - asin(z)
AhkStdlibComplexAcos(z)
{
    a := AhkStdlibComplexAsin(z)
    return AhkStdlibComplexValue(1.5707963267948966 - a.real, -a.imag)
}

; acosh(z) = log(z + sqrt(z^2 - 1)); choose the branch with real part >= 0.
AhkStdlibComplexAcosh(z)
{
    z2 := AhkStdlibComplexValue(z.real * z.real - z.imag * z.imag - 1.0, 2.0 * z.real * z.imag)
    root := AhkStdlibComplexSqrt(z2)
    sum := AhkStdlibComplexValue(z.real + root.real, z.imag + root.imag)
    res := AhkStdlibComplexLog(sum)
    if res.real < 0.0
        return AhkStdlibComplexValue(-res.real, -res.imag)
    return res
}

; atanh(z) = 0.5 * log((1+z)/(1-z))
AhkStdlibComplexAtanh(z)
{
    num := AhkStdlibComplexValue(1.0 + z.real, z.imag)
    den := AhkStdlibComplexValue(1.0 - z.real, -z.imag)
    q := AhkStdlibComplexDivide(num, den)
    l := AhkStdlibComplexLog(q)
    return AhkStdlibComplexValue(0.5 * l.real, 0.5 * l.imag)
}

; atan(z) = -i * atanh(i*z)
AhkStdlibComplexAtan(z)
{
    iz := AhkStdlibComplexValue(-z.imag, z.real)
    r := AhkStdlibComplexAtanh(iz)
    return AhkStdlibComplexValue(r.imag, -r.real)
}

; --- predicates ----------------------------------------------------------
AhkStdlibCmathIsFinite(z)
{
    c := AhkStdlibCmathArg(z)
    return AhkStdlibBool(AhkStdlibComplexComponentFinite(c.real) && AhkStdlibComplexComponentFinite(c.imag))
}

AhkStdlibCmathIsInf(z)
{
    c := AhkStdlibCmathArg(z)
    return AhkStdlibBool(AhkStdlibComplexComponentInf(c.real) || AhkStdlibComplexComponentInf(c.imag))
}

AhkStdlibCmathIsNan(z)
{
    c := AhkStdlibCmathArg(z)
    return AhkStdlibBool(AhkStdlibComplexIsNan(c.real) || AhkStdlibComplexIsNan(c.imag))
}

AhkStdlibComplexComponentInf(x)
{
    return x = AhkStdlibComplexInfValue() || x = -AhkStdlibComplexInfValue()
}

AhkStdlibComplexComponentFinite(x)
{
    return !AhkStdlibComplexIsNan(x) && !AhkStdlibComplexComponentInf(x)
}

AhkStdlibCmathIsClose(a, b, kwargs := unset)
{
    ca := AhkStdlibCmathArg(a)
    cb := AhkStdlibCmathArg(b)

    relTol := 1e-09
    absTol := 0.0
    if IsSet(kwargs) && IsObject(kwargs) {
        if HasProp(kwargs, "rel_tol")
            relTol := kwargs.rel_tol
        if HasProp(kwargs, "abs_tol")
            absTol := kwargs.abs_tol
    }
    if relTol < 0.0 || absTol < 0.0
        throw ValueError("tolerances must be non-negative", -1)

    if ca.real = cb.real && ca.imag = cb.imag
        return AhkStdlibBool(true)

    diff := AhkStdlibComplexHypot(ca.real - cb.real, ca.imag - cb.imag)
    magA := AhkStdlibComplexHypot(ca.real, ca.imag)
    magB := AhkStdlibComplexHypot(cb.real, cb.imag)
    threshold := relTol * (magA > magB ? magA : magB)
    if absTol > threshold
        threshold := absTol
    return AhkStdlibBool(diff <= threshold)
}
