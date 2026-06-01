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
