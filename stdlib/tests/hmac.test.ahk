#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\hmac>

class StdlibHmacTest
{
    static TestHmacMatchesPython310AcrossAlgorithms()
    {
        key := StdlibHmacTest.Bytes("key")
        msg := StdlibHmacTest.Bytes("message")

        AhkTest.AssertEqual("6e9ef29b75fffc5b7abae527d58fdadb2fe42e7219011976917343065f58ed4a",
            stdlib.hmac.new(key, msg, "sha256").hexdigest())
        AhkTest.AssertEqual("2088df74d5f2146b48146caf4965377e9d0be3a4",
            stdlib.hmac.new(key, msg, "sha1").hexdigest())
        AhkTest.AssertEqual("e477384d7ca229dd1426e64b63ebf2d36ebd6d7e669a6735424e72ea6c01d3f8b56eb39c36d8232f5427999b8d1a3f9cd1128fc69f4d75b434216810fa367e98",
            stdlib.hmac.new(key, msg, "sha512").hexdigest())
    }

    static TestHmacUpdateAndOneShotDigestMatch()
    {
        key := StdlibHmacTest.Bytes("key")

        streamed := stdlib.hmac.new(key, , "sha256")
        AhkTest.AssertEqual("", streamed.update(StdlibHmacTest.Bytes("mes")))
        streamed.update(StdlibHmacTest.Bytes("sage"))
        AhkTest.AssertEqual("6e9ef29b75fffc5b7abae527d58fdadb2fe42e7219011976917343065f58ed4a", streamed.hexdigest())

        oneshot := stdlib.hmac.digest(key, StdlibHmacTest.Bytes("message"), "sha256")
        AhkTest.AssertEqual("6e9ef29b75fffc5b7abae527d58fdadb2fe42e7219011976917343065f58ed4a", StdlibHmacTest.Hex(oneshot))
    }

    static TestHmacMetadataMatchesPython310()
    {
        mac := stdlib.hmac.new(StdlibHmacTest.Bytes("key"), StdlibHmacTest.Bytes("message"), "sha256")

        AhkTest.AssertEqual("hmac-sha256", mac.name)
        AhkTest.AssertEqual(32, mac.digest_size)
        AhkTest.AssertEqual(64, mac.block_size)

        sha512 := stdlib.hmac.new(StdlibHmacTest.Bytes("key"), , "sha512")
        AhkTest.AssertEqual(128, sha512.block_size)
        AhkTest.AssertEqual(64, sha512.digest_size)
    }

    static TestHmacCopyIsIndependent()
    {
        mac := stdlib.hmac.new(StdlibHmacTest.Bytes("key"), , "sha256")
        mac.update(StdlibHmacTest.Bytes("mes"))

        copied := mac.copy()
        copied.update(StdlibHmacTest.Bytes("sage"))
        mac.update(StdlibHmacTest.Bytes("sage"))

        AhkTest.AssertEqual(copied.hexdigest(), mac.hexdigest())
        AhkTest.AssertEqual("6e9ef29b75fffc5b7abae527d58fdadb2fe42e7219011976917343065f58ed4a", copied.hexdigest())
    }

    static TestHmacRejectsBadArgumentsLikePython310()
    {
        AhkTest.RaisesMatch(TypeError, "^Missing required parameter 'digestmod'\.$", (*) => stdlib.hmac.new(StdlibHmacTest.Bytes("key"), StdlibHmacTest.Bytes("m")))
        AhkTest.RaisesMatch(TypeError, "key: expected bytes or bytearray, but got 'str'", (*) => stdlib.hmac.new("key", StdlibHmacTest.Bytes("m"), "sha256"))
        AhkTest.RaisesMatch(TypeError, "^Strings must be encoded before hashing$", (*) => stdlib.hmac.new(StdlibHmacTest.Bytes("key"), , "sha256").update("abc"))
        AhkTest.RaisesMatch(ValueError, "unsupported hash type crc32", (*) => stdlib.hmac.new(StdlibHmacTest.Bytes("key"), , "crc32"))
    }

    static TestHmacCompareDigestMatchesPython310()
    {
        AhkTest.AssertTrue(stdlib.hmac.compare_digest("abc", "abc"))
        AhkTest.AssertFalse(stdlib.hmac.compare_digest("abc", "abd"))
        AhkTest.AssertTrue(stdlib.hmac.compare_digest(StdlibHmacTest.Bytes("abc"), StdlibHmacTest.Bytes("abc")))
        AhkTest.AssertFalse(stdlib.hmac.compare_digest(StdlibHmacTest.Bytes("abc"), StdlibHmacTest.Bytes("abd")))
    }

    static Bytes(text)
    {
        size := StrPut(text, "UTF-8") - 1
        bytes := Buffer(size, 0)
        if size > 0
            StrPut(text, bytes, "UTF-8")
        return bytes
    }

    static RepeatByte(value, count)
    {
        bytes := Buffer(count, 0)
        loop count
            NumPut("UChar", value, bytes, A_Index - 1)
        return bytes
    }

    static Hex(bytes)
    {
        text := ""
        loop bytes.Size
            text .= Format("{:02x}", NumGet(bytes, A_Index - 1, "UChar"))
        return text
    }
}

AhkTest.Collect(StdlibHmacTest)
