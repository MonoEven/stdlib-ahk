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
