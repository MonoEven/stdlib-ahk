#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\hashlib>

class AhkStdlibHmac
{
    static new(key, msg := unset, digestmod := unset)
    {
        return AhkStdlibHmacValue(key, msg?, digestmod?)
    }

    static digest(key, msg, digest)
    {
        instance := AhkStdlibHmacValue(key, msg, digest)
        return instance.digest()
    }

    static compare_digest(args*)
    {
        if args.Length != 2
            throw TypeError("compare_digest expected 2 arguments, got " args.Length, -1)
        return AhkStdlibHmacCompareDigest(args[1], args[2])
    }
}

stdlib.hmac := AhkStdlibHmac

class AhkStdlibHmacValue
{
    __New(key, msg := unset, digestmod := unset)
    {
        if !IsSet(digestmod) || AhkStdlibIsNone(digestmod)
            throw TypeError("Missing required parameter 'digestmod'.", -1)

        algorithm := AhkStdlibHmacResolveDigestmod(digestmod)
        keyBytes := AhkStdlibHmacRequireBytes(key, "key")

        blockSize := AhkStdlibHmacBlockSize(algorithm)
        digestSize := AhkStdlibHmacDigestSize(algorithm)

        normalizedKey := AhkStdlibHmacNormalizeKey(keyBytes, algorithm, blockSize)
        inner := Buffer(blockSize, 0)
        outer := Buffer(blockSize, 0)
        loop blockSize {
            offset := A_Index - 1
            keyByte := NumGet(normalizedKey, offset, "UChar")
            NumPut("UChar", keyByte ^ 0x36, inner, offset)
            NumPut("UChar", keyByte ^ 0x5C, outer, offset)
        }

        this.DefineProp("AhkStdlibAlgorithm", { Value: algorithm })
        this.DefineProp("AhkStdlibBlockSize", { Value: blockSize })
        this.DefineProp("AhkStdlibDigestSize", { Value: digestSize })
        this.DefineProp("AhkStdlibOuterPad", { Value: outer })
        this.AhkStdlibInnerChunks := [AhkStdlibHashlibCloneBuffer(inner)]

        this.DefineProp("name", { Get: AhkStdlibHmacPropGetName })
        this.DefineProp("digest_size", { Get: AhkStdlibHmacPropGetDigestSize })
        this.DefineProp("block_size", { Get: AhkStdlibHmacPropGetBlockSize })

        if IsSet(msg) && !AhkStdlibIsNone(msg)
            this.update(msg)
    }

    update(msg)
    {
        bytes := AhkStdlibHmacRequireBytesLike(msg)
        if bytes.Size > 0
            this.AhkStdlibInnerChunks.Push(AhkStdlibHashlibCloneBuffer(bytes))
        return ""
    }

    digest()
    {
        innerDigest := AhkStdlibHashlibComputeDigestBuffer(this.AhkStdlibAlgorithm, this.AhkStdlibInnerChunks)
        outerChunks := [AhkStdlibHashlibCloneBuffer(this.AhkStdlibOuterPad), innerDigest]
        return AhkStdlibHashlibComputeDigestBuffer(this.AhkStdlibAlgorithm, outerChunks)
    }

    hexdigest()
    {
        return AhkStdlibHashlibBufferToHex(this.digest())
    }

    copy()
    {
        copied := { }
        ObjSetBase(copied, AhkStdlibHmacValue.Prototype)
        copied.DefineProp("AhkStdlibAlgorithm", { Value: this.AhkStdlibAlgorithm })
        copied.DefineProp("AhkStdlibBlockSize", { Value: this.AhkStdlibBlockSize })
        copied.DefineProp("AhkStdlibDigestSize", { Value: this.AhkStdlibDigestSize })
        copied.DefineProp("AhkStdlibOuterPad", { Value: AhkStdlibHashlibCloneBuffer(this.AhkStdlibOuterPad) })
        copiedChunks := []
        for chunk in this.AhkStdlibInnerChunks
            copiedChunks.Push(AhkStdlibHashlibCloneBuffer(chunk))
        copied.AhkStdlibInnerChunks := copiedChunks
        copied.DefineProp("name", { Get: AhkStdlibHmacPropGetName })
        copied.DefineProp("digest_size", { Get: AhkStdlibHmacPropGetDigestSize })
        copied.DefineProp("block_size", { Get: AhkStdlibHmacPropGetBlockSize })
        return copied
    }
}

AhkStdlibHmacPropGetName(this)
{
    return "hmac-" this.AhkStdlibAlgorithm
}

AhkStdlibHmacPropGetDigestSize(this)
{
    return this.AhkStdlibDigestSize
}

AhkStdlibHmacPropGetBlockSize(this)
{
    return this.AhkStdlibBlockSize
}

AhkStdlibHmacResolveDigestmod(digestmod)
{
    if digestmod is String
        return AhkStdlibHmacNormalizeAlgorithm(digestmod)
    if IsObject(digestmod) && HasProp(digestmod, "AhkStdlibAlgorithm")
        return digestmod.AhkStdlibAlgorithm
    throw TypeError("Missing required parameter 'digestmod'.", -1)
}

AhkStdlibHmacNormalizeAlgorithm(name)
{
    normalized := StrLower(StrReplace(String(name), "-", ""))
    switch normalized {
    case "md5", "sha1", "sha224", "sha256", "sha384", "sha512":
        return normalized
    default:
        throw ValueError("unsupported hash type " String(name), -1)
    }
}

AhkStdlibHmacBlockSize(algorithm)
{
    switch algorithm {
    case "md5", "sha1", "sha224", "sha256":
        return 64
    case "sha384", "sha512":
        return 128
    default:
        throw ValueError("unsupported hash type " algorithm, -1)
    }
}

AhkStdlibHmacDigestSize(algorithm)
{
    switch algorithm {
    case "md5":
        return 16
    case "sha1":
        return 20
    case "sha224":
        return 28
    case "sha256":
        return 32
    case "sha384":
        return 48
    case "sha512":
        return 64
    default:
        throw ValueError("unsupported hash type " algorithm, -1)
    }
}

AhkStdlibHmacRequireBytes(value, name)
{
    if value is String
        throw TypeError(name ": expected bytes or bytearray, but got 'str'", -1)
    if !IsObject(value) || !HasProp(value, "Ptr") || !HasProp(value, "Size")
        throw TypeError(name ": expected bytes or bytearray, but got '" AhkStdlibPythonTypeName(value) "'", -1)
    return value
}

AhkStdlibHmacRequireBytesLike(value)
{
    if value is String
        throw TypeError("Strings must be encoded before hashing", -1)
    if !IsObject(value) || !HasProp(value, "Ptr") || !HasProp(value, "Size")
        throw TypeError("object supporting the buffer API required", -1)
    return value
}

AhkStdlibHmacNormalizeKey(keyBytes, algorithm, blockSize)
{
    source := keyBytes
    if keyBytes.Size > blockSize
        source := AhkStdlibHashlibComputeDigestBuffer(algorithm, [AhkStdlibHashlibCloneBuffer(keyBytes)])

    padded := Buffer(blockSize, 0)
    copyCount := source.Size < blockSize ? source.Size : blockSize
    if copyCount > 0
        DllCall("RtlMoveMemory", "Ptr", padded.Ptr, "Ptr", source.Ptr, "UPtr", copyCount)
    return padded
}

AhkStdlibHmacCompareDigest(left, right)
{
    leftKind := AhkStdlibHmacDigestKind(left)
    rightKind := AhkStdlibHmacDigestKind(right)

    if leftKind = "str" && rightKind = "str" {
        if StrLen(left) != StrLen(right)
            return false
        mismatch := 0
        loop StrLen(left)
            mismatch := mismatch | (Ord(SubStr(left, A_Index, 1)) ^ Ord(SubStr(right, A_Index, 1)))
        return mismatch = 0
    }
    if leftKind = "bytes" && rightKind = "bytes" {
        if left.Size != right.Size
            return false
        mismatch := 0
        loop left.Size
            mismatch := mismatch | (NumGet(left, A_Index - 1, "UChar") ^ NumGet(right, A_Index - 1, "UChar"))
        return mismatch = 0
    }
    throw TypeError("unsupported operand types(s) or combination of types", -1)
}

AhkStdlibHmacDigestKind(value)
{
    if value is String
        return "str"
    if IsObject(value) && HasProp(value, "Ptr") && HasProp(value, "Size")
        return "bytes"
    return ""
}
