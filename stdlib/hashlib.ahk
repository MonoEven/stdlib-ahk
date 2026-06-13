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

    static sha224(data := unset, kwargs*)
    {
        return AhkStdlibHashlibCreateNamed("sha224", data?, kwargs*)
    }

    static sha384(data := unset, kwargs*)
    {
        return AhkStdlibHashlibCreateNamed("sha384", data?, kwargs*)
    }

    static sha512(data := unset, kwargs*)
    {
        return AhkStdlibHashlibCreateNamed("sha512", data?, kwargs*)
    }

    static sha3_224(data := unset, kwargs*)
    {
        return AhkStdlibHashlibCreateNamed("sha3_224", data?, kwargs*)
    }

    static sha3_256(data := unset, kwargs*)
    {
        return AhkStdlibHashlibCreateNamed("sha3_256", data?, kwargs*)
    }

    static sha3_384(data := unset, kwargs*)
    {
        return AhkStdlibHashlibCreateNamed("sha3_384", data?, kwargs*)
    }

    static sha3_512(data := unset, kwargs*)
    {
        return AhkStdlibHashlibCreateNamed("sha3_512", data?, kwargs*)
    }

    static shake_128(data := unset, kwargs*)
    {
        return AhkStdlibHashlibCreateNamed("shake_128", data?, kwargs*)
    }

    static shake_256(data := unset, kwargs*)
    {
        return AhkStdlibHashlibCreateNamed("shake_256", data?, kwargs*)
    }

    ; Python exposes algorithms_available as the set of names this build can
    ; actually use. On Windows we back hashes with CNG (BCrypt) providers plus a
    ; pure-AHK SHA-224, so the membership is probed against the live OS rather
    ; than hard-coded: SHA3 and SHAKE exist on recent Windows 11 builds but not
    ; on older systems, and BLAKE2 has no CNG provider at all. A set has no
    ; native AHK type, so this mirrors it as a case-sensitive Map whose keys are
    ; the usable names (membership via .Has, iteration via for-each key).
    static algorithms_available {
        get {
            available := Map()
            available.CaseSense := true
            for name in AhkStdlibHashlibCandidateAlgorithms()
                if AhkStdlibHashlibAlgorithmUsable(name)
                    available[name] := true
            return available
        }
    }

    static pbkdf2_hmac(hash_name, password, salt, iterations, dklen := unset)
    {
        return AhkStdlibHashlibPbkdf2Hmac(hash_name, password, salt, iterations, dklen?)
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

    digest(length := unset)
    {
        outLen := AhkStdlibHashlibResolveDigestLength(this.AhkStdlibAlgorithmName, "digest", length?)
        return AhkStdlibHashlibComputeDigestBuffer(this.AhkStdlibAlgorithmName, this.AhkStdlibChunks, outLen)
    }

    hexdigest(length := unset)
    {
        outLen := AhkStdlibHashlibResolveDigestLength(this.AhkStdlibAlgorithmName, "hexdigest", length?)
        return AhkStdlibHashlibBufferToHex(AhkStdlibHashlibComputeDigestBuffer(this.AhkStdlibAlgorithmName, this.AhkStdlibChunks, outLen))
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
    case "sha224", "sha3_224":
        return 28
    case "sha256", "sha3_256":
        return 32
    case "sha384", "sha3_384":
        return 48
    case "sha512", "sha3_512":
        return 64
    case "shake_128", "shake_256":
        ; SHAKE is an extendable-output function; Python reports digest_size 0.
        return 0
    default:
        throw ValueError("unsupported hash type " this.AhkStdlibAlgorithmName, -1)
    }
}

AhkStdlibHashlibPropGetBlockSize(this)
{
    switch this.AhkStdlibAlgorithmName {
    case "md5", "sha1", "sha224", "sha256":
        return 64
    case "sha384", "sha512":
        return 128
    case "sha3_224":
        return 144
    case "sha3_256", "shake_256":
        return 136
    case "sha3_384":
        return 104
    case "sha3_512":
        return 72
    case "shake_128":
        return 168
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
    ; Python accepts dash- and underscore-spelled SHA3/SHAKE names (e.g.
    ; "sha3-256" and "sha3_256"); fold both onto the underscore canonical form.
    normalized := StrLower(StrReplace(String(name), "-", "_"))
    switch normalized {
    case "md5", "sha1", "sha224", "sha256", "sha384", "sha512":
        return normalized
    case "sha3_224", "sha3_256", "sha3_384", "sha3_512", "shake_128", "shake_256":
        return normalized
    default:
        throw ValueError("unsupported hash type " String(name), -1)
    }
}

AhkStdlibHashlibIsShake(name)
{
    return name = "shake_128" || name = "shake_256"
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

AhkStdlibHashlibComputeDigestBuffer(name, chunks, outLen := unset)
{
    ; Windows CNG (BCrypt) ships providers for MD5/SHA1/SHA256/SHA384/SHA512 but
    ; not SHA-224, so back that single algorithm with a pure-AHK SHA-256 core.
    if name = "sha224"
        return AhkStdlibHashlibSha224Digest(chunks)

    isShake := AhkStdlibHashlibIsShake(name)
    algorithmHandle := 0
    hashHandle := 0

    try {
        status := DllCall("bcrypt\BCryptOpenAlgorithmProvider"
            , "Ptr*", &algorithmHandle
            , "WStr", AhkStdlibHashlibBCryptName(name)
            , "Ptr", 0
            , "UInt", 0
            , "UInt")
        AhkStdlibHashlibThrowNtStatus(status, "BCryptOpenAlgorithmProvider failed")

        objectLength := AhkStdlibHashlibGetUIntProperty(algorithmHandle, "ObjectLength")
        ; SHAKE is an extendable-output function: the caller picks the byte count,
        ; so honour the requested length instead of the provider's fixed digest.
        digestLength := isShake ? outLen : AhkStdlibHashlibGetUIntProperty(algorithmHandle, "HashDigestLength")
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

        digest := Buffer(digestLength > 0 ? digestLength : 1, 0)
        status := DllCall("bcrypt\BCryptFinishHash"
            , "Ptr", hashHandle
            , "Ptr", digest.Ptr
            , "UInt", digestLength
            , "UInt", 0
            , "UInt")
        AhkStdlibHashlibThrowNtStatus(status, "BCryptFinishHash failed")

        if digest.Size != digestLength {
            trimmed := Buffer(digestLength, 0)
            if digestLength > 0
                DllCall("RtlMoveMemory", "Ptr", trimmed.Ptr, "Ptr", digest.Ptr, "UPtr", digestLength)
            return trimmed
        }
        return digest
    } finally {
        if hashHandle
            DllCall("bcrypt\BCryptDestroyHash", "Ptr", hashHandle)
        if algorithmHandle
            DllCall("bcrypt\BCryptCloseAlgorithmProvider", "Ptr", algorithmHandle, "UInt", 0)
    }
}

; Map the stdlib/Python canonical name onto the CNG (BCrypt) provider name.
; MD5/SHA1/SHA256/SHA384/SHA512 use the plain uppercase form; SHA3 uses a dash
; ("SHA3-256") and SHAKE drops the underscore ("SHAKE128").
AhkStdlibHashlibBCryptName(name)
{
    switch name {
    case "sha3_224":
        return "SHA3-224"
    case "sha3_256":
        return "SHA3-256"
    case "sha3_384":
        return "SHA3-384"
    case "sha3_512":
        return "SHA3-512"
    case "shake_128":
        return "SHAKE128"
    case "shake_256":
        return "SHAKE256"
    default:
        return StrUpper(name)
    }
}

; Candidate algorithms whose membership in algorithms_available is probed live.
AhkStdlibHashlibCandidateAlgorithms()
{
    return ["md5", "sha1", "sha224", "sha256", "sha384", "sha512"
        , "sha3_224", "sha3_256", "sha3_384", "sha3_512", "shake_128", "shake_256"]
}

; True when this build can actually compute the algorithm: SHA-224 is the pure
; AHK fallback, every other name needs a working CNG provider on this OS.
AhkStdlibHashlibAlgorithmUsable(name)
{
    if name = "sha224"
        return true
    algorithmHandle := 0
    status := DllCall("bcrypt\BCryptOpenAlgorithmProvider"
        , "Ptr*", &algorithmHandle
        , "WStr", AhkStdlibHashlibBCryptName(name)
        , "Ptr", 0
        , "UInt", 0
        , "UInt")
    if algorithmHandle
        DllCall("bcrypt\BCryptCloseAlgorithmProvider", "Ptr", algorithmHandle, "UInt", 0)
    return status = 0
}

; Resolve the byte length for digest()/hexdigest(). SHAKE requires an explicit
; length (Python raises TypeError without one); all other algorithms reject a
; length argument outright.
AhkStdlibHashlibResolveDigestLength(name, methodName, length := unset)
{
    if AhkStdlibHashlibIsShake(name) {
        if !IsSet(length)
            throw TypeError(methodName "() missing required argument 'length' (pos 1)", -1)
        value := AhkStdlibHashlibIndex(length)
        if value < 0
            throw ValueError("negative digest length", -1)
        return value
    }
    if IsSet(length)
        throw TypeError("HASH." methodName "() takes no arguments (1 given)", -1)
    return 0
}

AhkStdlibHashlibIndex(value)
{
    if value is Integer
        return value
    if value is Float {
        if value != Floor(value)
            throw TypeError("'float' object cannot be interpreted as an integer", -1)
        return Integer(value)
    }
    if value is String && RegExMatch(value, "^-?\d+$")
        return Integer(value)
    throw TypeError("'" AhkStdlibPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
}

; pbkdf2_hmac via BCryptDeriveKeyPBKDF2. The HMAC hash is opened with the CNG
; reusable-HMAC flag (0x08); dklen defaults to the underlying digest size.
AhkStdlibHashlibPbkdf2Hmac(hash_name, password, salt, iterations, dklen := unset)
{
    canonical := AhkStdlibHashlibNormalizePbkdf2Hash(hash_name)
    pwd := AhkStdlibHashlibRequireBytesLike(password)
    saltBytes := AhkStdlibHashlibRequireBytesLike(salt)
    iters := AhkStdlibHashlibIndex(iterations)
    if iters < 1
        throw ValueError("iteration value must be greater than 0.", -1)

    if !IsSet(dklen) || AhkStdlibIsNone(dklen) {
        keyLen := AhkStdlibHashlibPbkdf2DigestSize(canonical)
    } else {
        keyLen := AhkStdlibHashlibIndex(dklen)
        if keyLen < 1
            throw ValueError("key length must be greater than 0.", -1)
    }

    algorithmHandle := 0
    try {
        status := DllCall("bcrypt\BCryptOpenAlgorithmProvider"
            , "Ptr*", &algorithmHandle
            , "WStr", AhkStdlibHashlibBCryptName(canonical)
            , "Ptr", 0
            , "UInt", 0x00000008
            , "UInt")
        AhkStdlibHashlibThrowNtStatus(status, "BCryptOpenAlgorithmProvider failed")

        derived := Buffer(keyLen, 0)
        status := DllCall("bcrypt\BCryptDeriveKeyPBKDF2"
            , "Ptr", algorithmHandle
            , "Ptr", pwd.Size > 0 ? pwd.Ptr : 0
            , "UInt", pwd.Size
            , "Ptr", saltBytes.Size > 0 ? saltBytes.Ptr : 0
            , "UInt", saltBytes.Size
            , "UInt64", iters
            , "Ptr", derived.Ptr
            , "UInt", derived.Size
            , "UInt")
        AhkStdlibHashlibThrowNtStatus(status, "BCryptDeriveKeyPBKDF2 failed")
        return derived
    } finally {
        if algorithmHandle
            DllCall("bcrypt\BCryptCloseAlgorithmProvider", "Ptr", algorithmHandle, "UInt", 0)
    }
}

AhkStdlibHashlibNormalizePbkdf2Hash(name)
{
    normalized := StrLower(StrReplace(String(name), "-", "_"))
    switch normalized {
    case "sha1", "sha256", "sha384", "sha512", "md5":
        return normalized
    default:
        throw ValueError("unsupported hash type " String(name), -1)
    }
}

AhkStdlibHashlibPbkdf2DigestSize(name)
{
    switch name {
    case "md5":
        return 16
    case "sha1":
        return 20
    case "sha256":
        return 32
    case "sha384":
        return 48
    case "sha512":
        return 64
    default:
        throw ValueError("unsupported hash type " name, -1)
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

; --- Pure-AHK SHA-224 (Windows CNG exposes no SHA-224 provider) ---
; SHA-224 is the SHA-256 compression function with distinct initial hash
; values and a digest truncated to the first 28 bytes (seven 32-bit words).

AhkStdlibHashlibSha224Digest(chunks)
{
    total := 0
    for chunk in chunks
        total += chunk.Size
    data := Buffer(total > 0 ? total : 1, 0)
    offset := 0
    for chunk in chunks {
        if chunk.Size > 0 {
            DllCall("RtlMoveMemory", "Ptr", data.Ptr + offset, "Ptr", chunk.Ptr, "UPtr", chunk.Size)
            offset += chunk.Size
        }
    }

    mask := 0xFFFFFFFF
    h := [0xc1059ed8, 0x367cd507, 0x3070dd17, 0xf70e5939
        , 0xffc00b31, 0x68581511, 0x64f98fa7, 0xbefa4fa4]
    k := AhkStdlibHashlibSha256Constants()

    msgLen := total
    bitLen := msgLen * 8
    padLen := msgLen + 1
    while Mod(padLen, 64) != 56
        padLen += 1
    paddedSize := padLen + 8

    padded := Buffer(paddedSize, 0)
    if msgLen > 0
        DllCall("RtlMoveMemory", "Ptr", padded.Ptr, "Ptr", data.Ptr, "UPtr", msgLen)
    NumPut("UChar", 0x80, padded, msgLen)
    loop 8 {
        shift := (8 - A_Index) * 8
        NumPut("UChar", (bitLen >> shift) & 0xFF, padded, paddedSize - 8 + (A_Index - 1))
    }

    w := []
    w.Length := 64
    numBlocks := paddedSize // 64
    loop numBlocks {
        blockBase := (A_Index - 1) * 64
        loop 16 {
            i := A_Index - 1
            b0 := NumGet(padded, blockBase + i * 4 + 0, "UChar")
            b1 := NumGet(padded, blockBase + i * 4 + 1, "UChar")
            b2 := NumGet(padded, blockBase + i * 4 + 2, "UChar")
            b3 := NumGet(padded, blockBase + i * 4 + 3, "UChar")
            w[A_Index] := ((b0 << 24) | (b1 << 16) | (b2 << 8) | b3) & mask
        }
        loop 48 {
            i := A_Index + 16
            w15 := w[i - 15]
            w2 := w[i - 2]
            s0 := (AhkStdlibHashlibRotr32(w15, 7) ^ AhkStdlibHashlibRotr32(w15, 18) ^ (w15 >> 3)) & mask
            s1 := (AhkStdlibHashlibRotr32(w2, 17) ^ AhkStdlibHashlibRotr32(w2, 19) ^ (w2 >> 10)) & mask
            w[i] := (w[i - 16] + s0 + w[i - 7] + s1) & mask
        }

        a := h[1], b := h[2], c := h[3], d := h[4]
        e := h[5], f := h[6], g := h[7], hh := h[8]

        loop 64 {
            i := A_Index
            S1 := (AhkStdlibHashlibRotr32(e, 6) ^ AhkStdlibHashlibRotr32(e, 11) ^ AhkStdlibHashlibRotr32(e, 25)) & mask
            ch := ((e & f) ^ ((~e & mask) & g)) & mask
            temp1 := (hh + S1 + ch + k[i] + w[i]) & mask
            S0 := (AhkStdlibHashlibRotr32(a, 2) ^ AhkStdlibHashlibRotr32(a, 13) ^ AhkStdlibHashlibRotr32(a, 22)) & mask
            maj := ((a & b) ^ (a & c) ^ (b & c)) & mask
            temp2 := (S0 + maj) & mask
            hh := g
            g := f
            f := e
            e := (d + temp1) & mask
            d := c
            c := b
            b := a
            a := (temp1 + temp2) & mask
        }

        h[1] := (h[1] + a) & mask
        h[2] := (h[2] + b) & mask
        h[3] := (h[3] + c) & mask
        h[4] := (h[4] + d) & mask
        h[5] := (h[5] + e) & mask
        h[6] := (h[6] + f) & mask
        h[7] := (h[7] + g) & mask
        h[8] := (h[8] + hh) & mask
    }

    digest := Buffer(28, 0)
    loop 7 {
        word := h[A_Index]
        base := (A_Index - 1) * 4
        NumPut("UChar", (word >> 24) & 0xFF, digest, base + 0)
        NumPut("UChar", (word >> 16) & 0xFF, digest, base + 1)
        NumPut("UChar", (word >> 8) & 0xFF, digest, base + 2)
        NumPut("UChar", word & 0xFF, digest, base + 3)
    }
    return digest
}

AhkStdlibHashlibRotr32(value, bits)
{
    return ((value >> bits) | (value << (32 - bits))) & 0xFFFFFFFF
}

AhkStdlibHashlibSha256Constants()
{
    static k := [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2]
    return k
}
