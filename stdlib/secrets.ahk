#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\base64>

class AhkStdlibSecrets
{
    static DEFAULT_ENTROPY := 32

    static choice(sequence)
    {
        if sequence is Array {
            if sequence.Length = 0
                throw IndexError("list index out of range", -1)
            return sequence[AhkStdlibSecretsRandBelow(sequence.Length) + 1]
        }

        if sequence is String {
            length := StrLen(sequence)
            if length = 0
                throw IndexError("string index out of range", -1)
            return SubStr(sequence, AhkStdlibSecretsRandBelow(length) + 1, 1)
        }

        if !(sequence is Integer || sequence is Float)
            throw TypeError("object of type '" AhkStdlibPythonTypeName(sequence) "' has no len()", -1)
        throw TypeError("object of type '" AhkStdlibPythonTypeName(sequence) "' has no len()", -1)
    }

    static randbelow(exclusiveUpperBound)
    {
        if AhkStdlibIsNone(exclusiveUpperBound)
            throw TypeError("'<=' not supported between instances of 'NoneType' and 'int'", -1)
        if exclusiveUpperBound is Float
            throw AttributeError("'float' object has no attribute 'bit_length'", -1)
        if !(exclusiveUpperBound is Integer)
            return AhkStdlibSecretsTypeErrorForRandbelow(exclusiveUpperBound)
        if exclusiveUpperBound <= 0
            throw ValueError("Upper bound must be positive.", -1)
        return AhkStdlibSecretsRandBelow(exclusiveUpperBound)
    }

    static token_bytes(nbytes := 32)
    {
        if !(nbytes is Integer)
            throw TypeError("'" AhkStdlibPythonTypeName(nbytes) "' object cannot be interpreted as an integer", -1)
        if nbytes < 0
            throw ValueError("negative argument not allowed", -1)

        bytes := Buffer(nbytes, 0)
        if nbytes = 0
            return bytes

        status := DllCall("bcrypt\BCryptGenRandom"
            , "Ptr", 0
            , "Ptr", bytes.Ptr
            , "UInt", bytes.Size
            , "UInt", 0x00000002
            , "UInt")
        if status != 0
            throw OSError(status, -1)
        return bytes
    }

    static token_hex(nbytes := 32)
    {
        return AhkStdlibSecretsBufferToHex(this.token_bytes(nbytes))
    }

    static token_urlsafe(nbytes := unset)
    {
        if !IsSet(nbytes) || AhkStdlibIsNone(nbytes)
            nbytes := this.DEFAULT_ENTROPY
        tok := this.token_bytes(nbytes)
        encoded := stdlib.base64.urlsafe_b64encode(tok)
        text := StrGet(encoded, encoded.Size, "UTF-8")
        return StrReplace(text, "=", "")
    }

    static randbits(k)
    {
        if AhkStdlibIsNone(k)
            throw TypeError("'NoneType' object cannot be interpreted as an integer", -1)
        if k is Float
            throw TypeError("'float' object cannot be interpreted as an integer", -1)
        if !(k is Integer) && !AhkStdlibIsBool(k)
            throw TypeError("'" AhkStdlibPythonTypeName(k) "' object cannot be interpreted as an integer", -1)
        if AhkStdlibIsBool(k)
            k := k.Value ? 1 : 0
        if k < 0
            throw ValueError("number of bits must be non-negative", -1)
        if k = 0
            return 0
        return AhkStdlibSecretsRandBits(k)
    }

    static compare_digest(args*)
    {
        if args.Length != 2
            throw TypeError("compare_digest expected 2 arguments, got " args.Length, -1)

        left := args[1]
        right := args[2]
        leftType := AhkStdlibSecretsDigestKind(left)
        rightType := AhkStdlibSecretsDigestKind(right)

        if leftType = "bytes" && rightType = "str"
            throw TypeError("a bytes-like object is required, not 'str'", -1)
        if leftType = "str" && rightType = "bytes"
            throw TypeError("a bytes-like object is required, not 'str'", -1)
        if leftType = "str" && rightType = "str"
            return AhkStdlibSecretsCompareString(left, right)
        if leftType = "bytes" && rightType = "bytes"
            return AhkStdlibSecretsCompareBytes(left, right)

        throw TypeError("unsupported operand types(s) or combination of types", -1)
    }
}

stdlib.secrets := AhkStdlibSecrets

class AhkStdlibSecretsSystemRandom
{
    static Call(thisClass, args*)
    {
        if args.Length > 0
            throw TypeError("SystemRandom() takes no arguments (" args.Length " given)", -1)
        instance := Object()
        ObjSetBase(instance, AhkStdlibSecretsSystemRandom.Prototype)
        return instance
    }

    randbelow(exclusiveUpperBound)
    {
        return AhkStdlibSecrets.randbelow(exclusiveUpperBound)
    }

    getrandbits(k)
    {
        return AhkStdlibSecrets.randbits(k)
    }

    randbits(k)
    {
        return AhkStdlibSecrets.randbits(k)
    }

    choice(sequence)
    {
        return AhkStdlibSecrets.choice(sequence)
    }

    randrange(args*)
    {
        if args.Length = 0
            throw TypeError("randrange() missing 1 required positional argument: 'start'", -1)
        if args.Length > 3
            throw TypeError("randrange() takes from 1 to 3 positional arguments but " args.Length " were given", -1)

        if args.Length = 1 {
            stop := AhkStdlibSecretsRequireIndex(args[1], "stop")
            if stop <= 0
                throw ValueError("empty range for randrange()", -1)
            return AhkStdlibSecrets.randbelow(stop)
        }

        start := AhkStdlibSecretsRequireIndex(args[1], "start")
        stop := AhkStdlibSecretsRequireIndex(args[2], "stop")
        step := args.Length = 3 ? AhkStdlibSecretsRequireIndex(args[3], "step") : 1
        if step = 0
            throw ValueError("zero step for randrange()", -1)

        if step > 0
            width := stop - start
        else
            width := start - stop
        if width <= 0
            throw ValueError("empty range for randrange()", -1)

        absStep := step > 0 ? step : -step
        n := (width + absStep - 1) // absStep
        if n <= 0
            throw ValueError("empty range for randrange()", -1)
        return start + step * AhkStdlibSecrets.randbelow(n)
    }

    randint(a, b)
    {
        a := AhkStdlibSecretsRequireIndex(a, "a")
        b := AhkStdlibSecretsRequireIndex(b, "b")
        if a > b
            throw ValueError("empty range for randrange() (" a ", " (b + 1) ", " (b + 1 - a) ")", -1)
        return a + AhkStdlibSecrets.randbelow(b - a + 1)
    }
}

AhkStdlibSecrets.DefineProp("SystemRandom", { Value: AhkStdlibSecretsSystemRandom })

AhkStdlibSecretsRequireIndex(value, name)
{
    if AhkStdlibIsBool(value)
        return value.Value ? 1 : 0
    if value is Integer
        return value
    if value is Float
        throw TypeError("'float' object cannot be interpreted as an integer", -1)
    throw TypeError("'" AhkStdlibPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
}

AhkStdlibSecretsRandBits(k)
{
    nbytes := Ceil(k / 8)
    value := AhkStdlibRandomBytesToInteger(AhkStdlibSecrets.token_bytes(nbytes))
    excessBits := (nbytes * 8) - k
    if excessBits > 0
        value := value >>> excessBits
    return value
}

AhkStdlibSecretsTypeErrorForRandbelow(value)
{
    if AhkStdlibIsNone(value)
        throw TypeError("'<=' not supported between instances of 'NoneType' and 'int'", -1)
    throw TypeError("'" AhkStdlibPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
}

AhkStdlibSecretsRandBelow(exclusiveUpperBound)
{
    if exclusiveUpperBound = 1
        return 0

    bits := AhkStdlibSecretsBitLength(exclusiveUpperBound)
    value := AhkStdlibRandomBytesToInteger(AhkStdlibSecrets.token_bytes(Ceil(bits / 8)))
    excessBits := (Ceil(bits / 8) * 8) - bits
    if excessBits > 0
        value := value >>> excessBits
    while value >= exclusiveUpperBound {
        value := AhkStdlibRandomBytesToInteger(AhkStdlibSecrets.token_bytes(Ceil(bits / 8)))
        if excessBits > 0
            value := value >>> excessBits
    }
    return value
}

AhkStdlibSecretsBitLength(value)
{
    bits := 0
    current := value
    while current > 0 {
        current := current >> 1
        bits += 1
    }
    return bits
}

AhkStdlibRandomBytesToInteger(bytes)
{
    result := 0
    loop bytes.Size
        result := (result << 8) | NumGet(bytes, A_Index - 1, "UChar")
    return result
}

AhkStdlibSecretsBufferToHex(bytes)
{
    return AhkStdlibBufferToHex(bytes)
}

AhkStdlibSecretsDigestKind(value)
{
    if value is String
        return "str"
    if IsObject(value) && HasProp(value, "Ptr") && HasProp(value, "Size")
        return "bytes"
    return ""
}

AhkStdlibSecretsCompareString(left, right)
{
    if StrLen(left) != StrLen(right)
        return false
    mismatch := 0
    loop StrLen(left)
        mismatch := mismatch | (Ord(SubStr(left, A_Index, 1)) ^ Ord(SubStr(right, A_Index, 1)))
    return mismatch = 0
}

AhkStdlibSecretsCompareBytes(left, right)
{
    if left.Size != right.Size
        return false
    mismatch := 0
    loop left.Size
        mismatch := mismatch | (NumGet(left, A_Index - 1, "UChar") ^ NumGet(right, A_Index - 1, "UChar"))
    return mismatch = 0
}
