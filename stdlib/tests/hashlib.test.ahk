#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\hashlib>

class StdlibHashlibTest
{
    static TestAlgorithmsGuaranteedAndConstructorsMatchPython310()
    {
        AhkTest.AssertEqual([
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
        ], StdlibHashlibTest.SortStrings(stdlib.hashlib.algorithms_guaranteed))

        AhkTest.AssertEqual("d41d8cd98f00b204e9800998ecf8427e", stdlib.hashlib.md5().hexdigest())
        AhkTest.AssertEqual("900150983cd24fb0d6963f7d28e17f72", stdlib.hashlib.md5(StdlibHashlibTest.Bytes("abc")).hexdigest())
        AhkTest.AssertEqual("a9993e364706816aba3e25717850c26c9cd0d89d", stdlib.hashlib.sha1(StdlibHashlibTest.Bytes("abc")).hexdigest())
        AhkTest.AssertEqual("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", stdlib.hashlib.sha256(StdlibHashlibTest.Bytes("abc")).hexdigest())
        AhkTest.AssertEqual("a9993e364706816aba3e25717850c26c9cd0d89d", stdlib.hashlib.new("sha1", StdlibHashlibTest.Bytes("abc")).hexdigest())
        AhkTest.AssertEqual("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", stdlib.hashlib.new("SHA256", StdlibHashlibTest.Bytes("abc")).hexdigest())
    }

    static TestSha2FamilyMatchesPython310()
    {
        AhkTest.AssertEqual("23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7", stdlib.hashlib.sha224(StdlibHashlibTest.Bytes("abc")).hexdigest())
        AhkTest.AssertEqual("cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7", stdlib.hashlib.sha384(StdlibHashlibTest.Bytes("abc")).hexdigest())
        AhkTest.AssertEqual("ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f", stdlib.hashlib.sha512(StdlibHashlibTest.Bytes("abc")).hexdigest())

        sha224Hash := stdlib.hashlib.sha224()
        AhkTest.AssertEqual("sha224", sha224Hash.name)
        AhkTest.AssertEqual(28, sha224Hash.digest_size)
        AhkTest.AssertEqual(64, sha224Hash.block_size)

        sha384Hash := stdlib.hashlib.sha384()
        AhkTest.AssertEqual("sha384", sha384Hash.name)
        AhkTest.AssertEqual(48, sha384Hash.digest_size)
        AhkTest.AssertEqual(128, sha384Hash.block_size)

        sha512Hash := stdlib.hashlib.sha512()
        AhkTest.AssertEqual("sha512", sha512Hash.name)
        AhkTest.AssertEqual(64, sha512Hash.digest_size)
        AhkTest.AssertEqual(128, sha512Hash.block_size)

        AhkTest.AssertEqual("23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7", stdlib.hashlib.new("SHA224", StdlibHashlibTest.Bytes("abc")).hexdigest())
    }

    static TestHashObjectsExposePython310MetadataAndDigestBehavior()
    {
        hash := stdlib.hashlib.md5()

        AhkTest.AssertEqual("md5", hash.name)
        AhkTest.AssertEqual(16, hash.digest_size)
        AhkTest.AssertEqual(64, hash.block_size)
        AhkTest.AssertEqual("", hash.update(StdlibHashlibTest.Bytes("a")))
        AhkTest.AssertEqual("", hash.update(StdlibHashlibTest.Bytes("bc")))
        AhkTest.AssertEqual("900150983cd24fb0d6963f7d28e17f72", hash.hexdigest())
        AhkTest.AssertEqual([144, 1, 80, 152, 60, 210, 79, 176, 214, 150, 63, 125, 40, 225, 127, 114], StdlibHashlibTest.BufferBytes(hash.digest()))

        copied := hash.copy()
        copied.update(StdlibHashlibTest.Bytes("d"))

        AhkTest.AssertEqual("900150983cd24fb0d6963f7d28e17f72", hash.hexdigest())
        AhkTest.AssertEqual("e2fc714c4727ee9395f324cd2e7f331f", copied.hexdigest())
    }

    static TestHashlibRejectsUnsupportedAlgorithmsAndTextPayloadsLikePython310()
    {
        AhkTest.RaisesMatch(ValueError, "unsupported hash type crc32", (*) => stdlib.hashlib.new("crc32"))
        AhkTest.RaisesMatch(TypeError, "Strings must be encoded before hashing", (*) => stdlib.hashlib.md5("abc"))
        AhkTest.RaisesMatch(TypeError, "Strings must be encoded before hashing", (*) => stdlib.hashlib.new("md5", "abc"))
        AhkTest.RaisesMatch(TypeError, "Strings must be encoded before hashing", (*) => stdlib.hashlib.md5().update("abc"))
    }

    static TestSha3FamilyMatchesPython310()
    {
        ; SHA3-224 has no Windows CNG provider on every build; skip gracefully
        ; when absent rather than failing. SHA3-256/384/512 ship on Win11.
        if !stdlib.hashlib.algorithms_available.Has("sha3_256")
            AhkTest.SkipNow("Windows CNG provider 'SHA3-256' is unavailable on this OS")

        AhkTest.AssertEqual("3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532", stdlib.hashlib.sha3_256(StdlibHashlibTest.Bytes("abc")).hexdigest())
        AhkTest.AssertEqual("ec01498288516fc926459f58e2c6ad8df9b473cb0fc08c2596da7cf0e49be4b298d88cea927ac7f539f1edf228376d25", stdlib.hashlib.sha3_384(StdlibHashlibTest.Bytes("abc")).hexdigest())
        AhkTest.AssertEqual("b751850b1a57168a5693cd924b6b096e08f621827444f70d884f5d0240d2712e10e116e9192af3c91a7ec57647e3934057340b4cf408d5a56592f8274eec53f0", stdlib.hashlib.sha3_512(StdlibHashlibTest.Bytes("abc")).hexdigest())
        AhkTest.AssertEqual("a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a", stdlib.hashlib.sha3_256().hexdigest())

        sha3 := stdlib.hashlib.sha3_256()
        AhkTest.AssertEqual("sha3_256", sha3.name)
        AhkTest.AssertEqual(32, sha3.digest_size)
        AhkTest.AssertEqual(136, sha3.block_size)

        sha3b := stdlib.hashlib.sha3_512()
        AhkTest.AssertEqual(64, sha3b.digest_size)
        AhkTest.AssertEqual(72, sha3b.block_size)

        AhkTest.AssertEqual("3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532", stdlib.hashlib.new("SHA3-256", StdlibHashlibTest.Bytes("abc")).hexdigest())
        AhkTest.AssertEqual("3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532", stdlib.hashlib.new("sha3_256", StdlibHashlibTest.Bytes("abc")).hexdigest())
    }

    static TestShakeVariableLengthMatchesPython310()
    {
        if !stdlib.hashlib.algorithms_available.Has("shake_128")
            AhkTest.SkipNow("Windows CNG provider 'SHAKE128' is unavailable on this OS")

        AhkTest.AssertEqual("5881092dd818bf5cf8a3ddb793fbcba7", stdlib.hashlib.shake_128(StdlibHashlibTest.Bytes("abc")).hexdigest(16))
        AhkTest.AssertEqual("483366601360a8771c6863080cc4114d8db44530f8f1e1ee4f94ea37e78b5739", stdlib.hashlib.shake_256(StdlibHashlibTest.Bytes("abc")).hexdigest(32))
        AhkTest.AssertEqual("7f9c2ba4e88f827d616045507605853e", stdlib.hashlib.shake_128().hexdigest(16))
        AhkTest.AssertEqual("46b9dd2b0ba88d13233b3feb743eeb243fcd52ea62b81b82b50c27646ed5762f", stdlib.hashlib.shake_256().hexdigest(32))

        shake := stdlib.hashlib.shake_128()
        AhkTest.AssertEqual("shake_128", shake.name)
        AhkTest.AssertEqual(0, shake.digest_size)
        AhkTest.AssertEqual(168, shake.block_size)
        AhkTest.AssertEqual(136, stdlib.hashlib.shake_256().block_size)

        ; SHAKE digest()/hexdigest() require an explicit length (Python TypeError).
        AhkTest.RaisesMatch(TypeError, "digest\(\) missing required argument 'length' \(pos 1\)", (*) => stdlib.hashlib.shake_128(StdlibHashlibTest.Bytes("abc")).digest())
        AhkTest.RaisesMatch(TypeError, "hexdigest\(\) missing required argument 'length' \(pos 1\)", (*) => stdlib.hashlib.shake_128(StdlibHashlibTest.Bytes("abc")).hexdigest())
    }

    static TestNonShakeDigestRejectsLengthArgumentLikePython310()
    {
        AhkTest.RaisesMatch(TypeError, "HASH.digest\(\) takes no arguments \(1 given\)", (*) => stdlib.hashlib.sha256(StdlibHashlibTest.Bytes("abc")).digest(5))
        AhkTest.RaisesMatch(TypeError, "HASH.hexdigest\(\) takes no arguments \(1 given\)", (*) => stdlib.hashlib.md5().hexdigest(5))
    }

    static TestAlgorithmsAvailableReportsUsableNames()
    {
        available := stdlib.hashlib.algorithms_available

        ; Names always usable on Windows (CNG providers + pure-AHK SHA-224).
        for name in ["md5", "sha1", "sha224", "sha256", "sha384", "sha512"]
            AhkTest.AssertTrue(available.Has(name), "expected " name " in algorithms_available")

        ; BLAKE2 has no CNG provider but is implemented in pure AHK, so it is
        ; reported usable.
        AhkTest.AssertTrue(available.Has("blake2b"))
        AhkTest.AssertTrue(available.Has("blake2s"))

        ; Every reported name must actually produce a digest (SHAKE needs a length).
        for name in available {
            hash := stdlib.hashlib.new(name, StdlibHashlibTest.Bytes("abc"))
            out := InStr(name, "shake") ? hash.digest(16) : hash.digest()
            AhkTest.AssertTrue(out.Size > 0, "expected non-empty digest for " name)
        }
    }

    static TestPbkdf2HmacMatchesPython310()
    {
        AhkTest.AssertEqual("0a38253555ce37f5c72a6b703f996814ebf241f203af146e93dcdeb031c5567e"
            , StdlibHashlibTest.Hex(stdlib.hashlib.pbkdf2_hmac("sha256", StdlibHashlibTest.Bytes("pw"), StdlibHashlibTest.Bytes("salt"), 1000)))
        AhkTest.AssertEqual("0c60c80f961f0e71f3a9b524af6012062fe037a6"
            , StdlibHashlibTest.Hex(stdlib.hashlib.pbkdf2_hmac("sha1", StdlibHashlibTest.Bytes("password"), StdlibHashlibTest.Bytes("salt"), 1)))
        AhkTest.AssertEqual("c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134af7ad98c1b458ce3f"
            , StdlibHashlibTest.Hex(stdlib.hashlib.pbkdf2_hmac("sha256", StdlibHashlibTest.Bytes("password"), StdlibHashlibTest.Bytes("salt"), 4096, 40)))
        AhkTest.AssertEqual("9bbcdf4f0b03e358d9a6f311a95c29f8df1dfac308b5b4734bb2a52f712fd3f3380a648301abd4796bbc873c3c18c2d7ee5ce68818d1eeb631a59ba9208eb3a5"
            , StdlibHashlibTest.Hex(stdlib.hashlib.pbkdf2_hmac("sha512", StdlibHashlibTest.Bytes("pw"), StdlibHashlibTest.Bytes("salt"), 1)))
        AhkTest.AssertEqual("9887054ca80d1507d8b6e84a29476d04"
            , StdlibHashlibTest.Hex(stdlib.hashlib.pbkdf2_hmac("md5", StdlibHashlibTest.Bytes("pw"), StdlibHashlibTest.Bytes("salt"), 1)))

        ; dklen defaults to the underlying digest size (32 for sha256).
        AhkTest.AssertEqual(32, stdlib.hashlib.pbkdf2_hmac("sha256", StdlibHashlibTest.Bytes("pw"), StdlibHashlibTest.Bytes("salt"), 1000).Size)

        AhkTest.RaisesMatch(ValueError, "iteration value must be greater than 0.", (*) => stdlib.hashlib.pbkdf2_hmac("sha256", StdlibHashlibTest.Bytes("pw"), StdlibHashlibTest.Bytes("salt"), 0))
        AhkTest.RaisesMatch(ValueError, "key length must be greater than 0.", (*) => stdlib.hashlib.pbkdf2_hmac("sha256", StdlibHashlibTest.Bytes("pw"), StdlibHashlibTest.Bytes("salt"), 1000, -1))
        AhkTest.RaisesMatch(ValueError, "unsupported hash type badhash", (*) => stdlib.hashlib.pbkdf2_hmac("badhash", StdlibHashlibTest.Bytes("pw"), StdlibHashlibTest.Bytes("salt"), 1))
    }

    static TestBlake2bMatchesPython310()
    {
        AhkTest.AssertEqual("786a02f742015903c6c6fd852552d272912f4740e15847618a86e217f71f5419d25e1031afee585313896444934eb04b903a685b1448b755d56f701afe9be2ce"
            , stdlib.hashlib.blake2b(StdlibHashlibTest.Bytes("")).hexdigest())
        AhkTest.AssertEqual("ba80a53f981c4d0d6a2797b69f12f6e94c212f14685ac4b74b12bb6fdbffa2d17d87c5392aab792dc252d5de4533cc9518d38aa8dbf1925ab92386edd4009923"
            , stdlib.hashlib.blake2b(StdlibHashlibTest.Bytes("abc")).hexdigest())
        ; digest_size truncates the output.
        AhkTest.AssertEqual("bddd813c634239723171ef3fee98579b94964e3bb1cb3e427262c8c068d52319"
            , stdlib.hashlib.blake2b(StdlibHashlibTest.Bytes("abc"), { digest_size: 32 }).hexdigest())
        ; Keyed hashing (MAC).
        AhkTest.AssertEqual("204c828c56fbe6dfe80f110efd16649b9baaad573a6fe4a9a3f492857ec46f8f01eb46d3d6b777f014802967b258fdf631947e68e70cbf9054edf69fa3bbb4a8"
            , stdlib.hashlib.blake2b(StdlibHashlibTest.Bytes("abc"), { key: StdlibHashlibTest.Bytes("secret") }).hexdigest())
        ; Incremental update matches one-shot.
        h := stdlib.hashlib.blake2b()
        h.update(StdlibHashlibTest.Bytes("a"))
        h.update(StdlibHashlibTest.Bytes("bc"))
        AhkTest.AssertEqual(stdlib.hashlib.blake2b(StdlibHashlibTest.Bytes("abc")).hexdigest(), h.hexdigest())
    }

    static TestBlake2sMatchesPython310()
    {
        AhkTest.AssertEqual("69217a3079908094e11121d042354a7c1f55b6482ca1a51e1b250dfd1ed0eef9"
            , stdlib.hashlib.blake2s(StdlibHashlibTest.Bytes("")).hexdigest())
        AhkTest.AssertEqual("508c5e8c327c14e2e1a72ba34eeb452f37458b209ed63a294d999b4c86675982"
            , stdlib.hashlib.blake2s(StdlibHashlibTest.Bytes("abc")).hexdigest())
        AhkTest.AssertEqual("d7d0d1441d31d042d6c1ef68ce5162e56f3b2a208de82b727b7c30c709b7bff2"
            , stdlib.hashlib.blake2s(StdlibHashlibTest.Bytes("abc"), { key: StdlibHashlibTest.Bytes("secret") }).hexdigest())
    }

    static TestScryptMatchesRfc7914()
    {
        ; RFC 7914 / Python 3.10 hashlib.scrypt vectors.
        AhkTest.AssertEqual("a2f63b8c062d326091944189baeb665b"
            , StdlibHashlibTest.Hex(stdlib.hashlib.scrypt(StdlibHashlibTest.Bytes("password"), { salt: StdlibHashlibTest.Bytes("NaCl"), n: 2, r: 1, p: 1, dklen: 16 })))
        AhkTest.AssertEqual("77d6576238657b203b19ca42c18a0497f16b4844e3074ae8dfdffa3fede21442fcd0069ded0948f8326a753a0fc81f17e8d3e0fb2e0d3628cf35e20c38d18906"
            , StdlibHashlibTest.Hex(stdlib.hashlib.scrypt(StdlibHashlibTest.Bytes(""), { salt: StdlibHashlibTest.Bytes(""), n: 16, r: 1, p: 1, dklen: 64 })))
        AhkTest.RaisesMatch(ValueError, "n must be a power of 2", (*) => stdlib.hashlib.scrypt(StdlibHashlibTest.Bytes("x"), { salt: StdlibHashlibTest.Bytes("y"), n: 3, r: 1, p: 1 }))
    }

    static Hex(bytes)
    {
        text := ""
        loop bytes.Size
            text .= Format("{:02x}", NumGet(bytes, A_Index - 1, "UChar"))
        return text
    }

    static Bytes(text)
    {
        size := StrPut(text, "UTF-8") - 1
        bytes := Buffer(size, 0)
        if size > 0
            StrPut(text, bytes, "UTF-8")
        return bytes
    }

    static BufferBytes(bytes)
    {
        values := []
        loop bytes.Size
            values.Push(NumGet(bytes, A_Index - 1, "UChar"))
        return values
    }

    static SortStrings(values)
    {
        copied := []
        for value in values
            copied.Push(value)
        loop copied.Length {
            outer := A_Index
            inner := outer + 1
            while inner <= copied.Length {
                if StrCompare(copied[inner], copied[outer]) < 0 {
                    temp := copied[outer]
                    copied[outer] := copied[inner]
                    copied[inner] := temp
                }
                inner += 1
            }
        }
        return copied
    }
}

AhkTest.Collect(StdlibHashlibTest)
