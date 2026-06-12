#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\secrets>

class StdlibSecretsTest
{
    static TestCoveredChoiceRandbelowAndTokensMatchObservedLocal310Surface()
    {
        value := stdlib.secrets.choice([1, 2, 3])
        AhkTest.AssertTrue(value = 1 || value = 2 || value = 3)

        char := stdlib.secrets.choice("abc")
        AhkTest.AssertTrue(char = "a" || char = "b" || char = "c")

        belowOne := stdlib.secrets.randbelow(1)
        AhkTest.AssertEqual(0, belowOne)

        belowBool := stdlib.secrets.randbelow(true)
        AhkTest.AssertEqual(0, belowBool)

        tokenDefault := stdlib.secrets.token_bytes()
        tokenFour := stdlib.secrets.token_bytes(4)
        tokenHexDefault := stdlib.secrets.token_hex()
        tokenHexFour := stdlib.secrets.token_hex(4)

        AhkTest.AssertEqual("Buffer", Type(tokenDefault))
        AhkTest.AssertEqual(32, tokenDefault.Size)
        AhkTest.AssertEqual(4, tokenFour.Size)
        AhkTest.AssertEqual("", stdlib.secrets.token_hex(0))
        AhkTest.AssertEqual(64, StrLen(tokenHexDefault))
        AhkTest.AssertEqual(8, StrLen(tokenHexFour))
        AhkTest.AssertRegex(tokenHexDefault, "^[0-9a-f]+$")
        AhkTest.AssertRegex(tokenHexFour, "^[0-9a-f]+$")

        AhkTest.AssertTrue(stdlib.secrets.compare_digest("abc", "abc"))
        AhkTest.AssertFalse(stdlib.secrets.compare_digest("abc", "abd"))
        AhkTest.AssertTrue(stdlib.secrets.compare_digest(StdlibSecretsTest.Bytes("abc"), StdlibSecretsTest.Bytes("abc")))
    }

    static TestObservedSecretsErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(IndexError, "^list index out of range$", (*) => stdlib.secrets.choice([]))
        AhkTest.RaisesMatch(IndexError, "^string index out of range$", (*) => stdlib.secrets.choice(""))
        AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => stdlib.secrets.choice(1))
        AhkTest.RaisesMatch(ValueError, "^Upper bound must be positive\.$", (*) => stdlib.secrets.randbelow(0))
        AhkTest.RaisesMatch(AttributeError, "^'float' object has no attribute 'bit_length'$", (*) => stdlib.secrets.randbelow(1.5))
        AhkTest.RaisesMatch(TypeError, "^'<=' not supported between instances of 'NoneType' and 'int'$", (*) => stdlib.secrets.randbelow(stdlib.None))
        AhkTest.RaisesMatch(ValueError, "^negative argument not allowed$", (*) => stdlib.secrets.token_bytes(-1))
        AhkTest.RaisesMatch(ValueError, "^negative argument not allowed$", (*) => stdlib.secrets.token_hex(-1))
        AhkTest.RaisesMatch(TypeError, "^a bytes-like object is required, not 'str'$", (*) => stdlib.secrets.compare_digest("abc", StdlibSecretsTest.Bytes("abc")))
        AhkTest.RaisesMatch(TypeError, "^compare_digest expected 2 arguments, got 0$", (*) => stdlib.secrets.compare_digest())
        AhkTest.RaisesMatch(TypeError, "^compare_digest expected 2 arguments, got 1$", (*) => stdlib.secrets.compare_digest("a"))
        AhkTest.RaisesMatch(TypeError, "^compare_digest expected 2 arguments, got 3$", (*) => stdlib.secrets.compare_digest("a", "a", "a"))
    }

    static TestTokenUrlsafeProducesUnpaddedUrlSafeText()
    {
        tokenDefault := stdlib.secrets.token_urlsafe()
        tokenThree := stdlib.secrets.token_urlsafe(3)
        tokenNone := stdlib.secrets.token_urlsafe(stdlib.None)

        AhkTest.AssertEqual(43, StrLen(tokenDefault))
        AhkTest.AssertEqual(43, StrLen(tokenNone))
        AhkTest.AssertEqual(4, StrLen(tokenThree))
        AhkTest.AssertRegex(tokenDefault, "^[A-Za-z0-9_-]+$")
        AhkTest.AssertRegex(tokenThree, "^[A-Za-z0-9_-]+$")
        AhkTest.AssertFalse(InStr(tokenDefault, "="))
        AhkTest.AssertEqual("", stdlib.secrets.token_urlsafe(0))
        AhkTest.RaisesMatch(ValueError, "^negative argument not allowed$", (*) => stdlib.secrets.token_urlsafe(-1))
    }

    static TestRandbitsStaysInRangeAndValidatesArguments()
    {
        AhkTest.AssertEqual(0, stdlib.secrets.randbits(0))
        loop 50 {
            value := stdlib.secrets.randbits(8)
            AhkTest.AssertTrue(value >= 0 && value < 256)
        }
        value16 := stdlib.secrets.randbits(16)
        AhkTest.AssertTrue(value16 >= 0 && value16 < 65536)

        AhkTest.AssertEqual(32, stdlib.secrets.DEFAULT_ENTROPY)
        AhkTest.RaisesMatch(ValueError, "^number of bits must be non-negative$", (*) => stdlib.secrets.randbits(-1))
        AhkTest.RaisesMatch(TypeError, "^'NoneType' object cannot be interpreted as an integer$", (*) => stdlib.secrets.randbits(stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^'float' object cannot be interpreted as an integer$", (*) => stdlib.secrets.randbits(1.5))
        AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => stdlib.secrets.randbits("8"))
    }

    static TestSystemRandomExposesCryptoRandomMethods()
    {
        rng := stdlib.secrets.SystemRandom()

        below := rng.randbelow(5)
        AhkTest.AssertTrue(below >= 0 && below < 5)

        bits := rng.getrandbits(8)
        AhkTest.AssertTrue(bits >= 0 && bits < 256)

        picked := rng.choice([10, 20, 30])
        AhkTest.AssertTrue(picked = 10 || picked = 20 || picked = 30)

        ranged := rng.randrange(2, 8, 2)
        AhkTest.AssertTrue(ranged = 2 || ranged = 4 || ranged = 6)

        single := rng.randint(7, 7)
        AhkTest.AssertEqual(7, single)

        AhkTest.RaisesMatch(ValueError, "^empty range for randrange\(\)$", (*) => rng.randrange(0))
        AhkTest.RaisesMatch(ValueError, "^zero step for randrange\(\)$", (*) => rng.randrange(0, 10, 0))
    }

    static Bytes(text)
    {
        size := StrPut(text, "UTF-8") - 1
        bytes := Buffer(size, 0)
        if size > 0
            StrPut(text, bytes, "UTF-8")
        return bytes
    }
}

AhkTest.Collect(StdlibSecretsTest)
