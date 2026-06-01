#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibHashlib
{
    static algorithms_guaranteed := [
        "blake2b",
        "blake2s",
        "md5",
        "sha1",
        "sha224",
        "sha256",
        "sha384",
        "sha3_224",
        "sha3_256",
        "sha3_384",
        "sha3_512",
        "sha512",
        "shake_128",
        "shake_256"
    ]

    static new(name, data := unset, kwargs*)
    {
        usedforsecurity := AhkStdlibHashlibParseUsedForSecurity(kwargs*)
        hash := AhkStdlibHash(name, usedforsecurity)
        if IsSet(data)
            hash.update(data)
        return hash
    }

    static md5(data := unset, kwargs*)
    {
        return AhkStdlibHashlibCreateNamed("md5", data?, kwargs*)
    }

    static sha1(data := unset, kwargs*)
    {
        return AhkStdlibHashlibCreateNamed("sha1", data?, kwargs*)
    }

    static sha256(data := unset, kwargs*)
    {
        return AhkStdlibHashlibCreateNamed("sha256", data?, kwargs*)
    }
}

stdlib.hashlib := AhkStdlibHashlib

class AhkStdlibHash
{
    __New(name, usedforsecurity := true)
    {
        this.AhkStdlibAlgorithmName := AhkStdlibHashlibNormalizeAlgorithm(name)
        this.AhkStdlibUsedForSecurity := usedforsecurity ? true : false
        this.AhkStdlibChunks := []
        this.DefineProp("name", { Get: AhkStdlibHashlibPropGetName })
        this.DefineProp("digest_size", { Get: AhkStdlibHashlibPropGetDigestSize })
        this.DefineProp("block_size", { Get: AhkStdlibHashlibPropGetBlockSize })
    }

    update(data)
    {
        bytes := AhkStdlibHashlibRequireBytesLike(data)
        if bytes.Size > 0
            this.AhkStdlibChunks.Push(AhkStdlibHashlibCloneBuffer(bytes))
        return ""
    }

    digest()
    {
        return AhkStdlibHashlibComputeDigestBuffer(this.AhkStdlibAlgorithmName, this.AhkStdlibChunks)
    }

    hexdigest()
    {
        return AhkStdlibHashlibBufferToHex(this.digest())
    }

    copy()
    {
        copied := AhkStdlibHash(this.AhkStdlibAlgorithmName, this.AhkStdlibUsedForSecurity)
        for chunk in this.AhkStdlibChunks
            copied.AhkStdlibChunks.Push(AhkStdlibHashlibCloneBuffer(chunk))
        return copied
    }
}

AhkStdlibHashlibCreateNamed(name, data := unset, kwargs*)
{
    usedforsecurity := AhkStdlibHashlibParseUsedForSecurity(kwargs*)
    hash := AhkStdlibHash(name, usedforsecurity)
    if IsSet(data)
        hash.update(data)
    return hash
}

AhkStdlibHashlibPropGetName(this)
{
    return this.AhkStdlibAlgorithmName
}

AhkStdlibHashlibPropGetDigestSize(this)
{
    switch this.AhkStdlibAlgorithmName {
    case "md5":
        return 16
    case "sha1":
        return 20
    case "sha256":
        return 32
    default:
        throw ValueError("unsupported hash type " this.AhkStdlibAlgorithmName, -1)
    }
}

AhkStdlibHashlibPropGetBlockSize(this)
{
    switch this.AhkStdlibAlgorithmName {
    case "md5", "sha1", "sha256":
        return 64
    default:
        throw ValueError("unsupported hash type " this.AhkStdlibAlgorithmName, -1)
    }
}

AhkStdlibHashlibParseUsedForSecurity(kwargs*)
{
    if kwargs.Length = 0
        return true
    if kwargs.Length != 1
        throw TypeError("hashlib constructor accepts at most 1 keyword argument", -1)
    keyword := kwargs[1]
    if !(keyword is Map)
        throw TypeError("hashlib constructor accepts keyword arguments as Map wrappers", -1)
    if keyword.Count != 1 || !keyword.Has("usedforsecurity")
        throw TypeError("'" AhkStdlibHashlibFirstUnexpectedKeyword(keyword) "' is an invalid keyword argument for openssl_md5", -1)
    return AhkStdlibTruthValue(keyword["usedforsecurity"])
}

AhkStdlibHashlibFirstUnexpectedKeyword(keyword)
{
    for name in keyword
        return String(name)
    return ""
}

AhkStdlibHashlibNormalizeAlgorithm(name)
{
    normalized := StrLower(StrReplace(String(name), "-", ""))
    switch normalized {
    case "md5", "sha1", "sha256":
        return normalized
    default:
        throw ValueError("unsupported hash type " String(name), -1)
    }
}

AhkStdlibHashlibRequireBytesLike(data)
{
    if data is String
        throw TypeError("Strings must be encoded before hashing", -1)
    if !IsObject(data) || !HasProp(data, "Ptr") || !HasProp(data, "Size")
        throw TypeError("object supporting the buffer API required", -1)
    return data
}

AhkStdlibHashlibCloneBuffer(bytes)
{
    cloned := Buffer(bytes.Size, 0)
    if bytes.Size > 0
        DllCall("RtlMoveMemory", "Ptr", cloned.Ptr, "Ptr", bytes.Ptr, "UPtr", bytes.Size)
    return cloned
}

AhkStdlibHashlibComputeDigestBuffer(name, chunks)
{
    algorithmHandle := 0
    hashHandle := 0

    try {
        status := DllCall("bcrypt\BCryptOpenAlgorithmProvider"
            , "Ptr*", &algorithmHandle
            , "WStr", StrUpper(name)
            , "Ptr", 0
            , "UInt", 0
            , "UInt")
        AhkStdlibHashlibThrowNtStatus(status, "BCryptOpenAlgorithmProvider failed")

        objectLength := AhkStdlibHashlibGetUIntProperty(algorithmHandle, "ObjectLength")
        digestLength := AhkStdlibHashlibGetUIntProperty(algorithmHandle, "HashDigestLength")
        hashObject := Buffer(objectLength, 0)

        status := DllCall("bcrypt\BCryptCreateHash"
            , "Ptr", algorithmHandle
            , "Ptr*", &hashHandle
            , "Ptr", hashObject.Ptr
            , "UInt", hashObject.Size
            , "Ptr", 0
            , "UInt", 0
            , "UInt", 0
            , "UInt")
        AhkStdlibHashlibThrowNtStatus(status, "BCryptCreateHash failed")

        for chunk in chunks {
            if chunk.Size <= 0
                continue
            status := DllCall("bcrypt\BCryptHashData"
                , "Ptr", hashHandle
                , "Ptr", chunk.Ptr
                , "UInt", chunk.Size
                , "UInt", 0
                , "UInt")
            AhkStdlibHashlibThrowNtStatus(status, "BCryptHashData failed")
        }

        digest := Buffer(digestLength, 0)
        status := DllCall("bcrypt\BCryptFinishHash"
            , "Ptr", hashHandle
            , "Ptr", digest.Ptr
            , "UInt", digest.Size
            , "UInt", 0
            , "UInt")
        AhkStdlibHashlibThrowNtStatus(status, "BCryptFinishHash failed")

        return digest
    } finally {
        if hashHandle
            DllCall("bcrypt\BCryptDestroyHash", "Ptr", hashHandle)
        if algorithmHandle
            DllCall("bcrypt\BCryptCloseAlgorithmProvider", "Ptr", algorithmHandle, "UInt", 0)
    }
}

AhkStdlibHashlibGetUIntProperty(handle, propertyName)
{
    output := Buffer(4, 0)
    bytesWritten := 0
    status := DllCall("bcrypt\BCryptGetProperty"
        , "Ptr", handle
        , "WStr", propertyName
        , "Ptr", output.Ptr
        , "UInt", output.Size
        , "UInt*", &bytesWritten
        , "UInt", 0
        , "UInt")
    AhkStdlibHashlibThrowNtStatus(status, "BCryptGetProperty failed: " propertyName)
    return NumGet(output, 0, "UInt")
}

AhkStdlibHashlibBufferToHex(bytes)
{
    text := ""
    loop bytes.Size
        text .= Format("{:02x}", NumGet(bytes, A_Index - 1, "UChar"))
    return text
}

AhkStdlibHashlibThrowNtStatus(status, message)
{
    if status != 0
        throw OSError(message, -1, Format("NTSTATUS 0x{:08X}", status & 0xFFFFFFFF))
}
