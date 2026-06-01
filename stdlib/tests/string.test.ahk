#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\string>

class StdlibStringTest
{
    static TestModuleConstantsAndCapwordsMatchObservedLocal310Surface()
    {
        AhkTest.AssertEqual("abcdefghijklmnopqrstuvwxyz", stdlib.string.ascii_lowercase)
        AhkTest.AssertEqual("ABCDEFGHIJKLMNOPQRSTUVWXYZ", stdlib.string.ascii_uppercase)
        AhkTest.AssertEqual("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", stdlib.string.ascii_letters)
        AhkTest.AssertEqual("0123456789", stdlib.string.digits)
        AhkTest.AssertEqual("0123456789abcdefABCDEF", stdlib.string.hexdigits)
        AhkTest.AssertEqual("01234567", stdlib.string.octdigits)
        AhkTest.AssertEqual("!" Chr(34) "#$%&'()*+,-./:;<=>?@[\]^_``{|}~", stdlib.string.punctuation)
        AhkTest.AssertEqual(" `t`n`r" Chr(11) Chr(12), stdlib.string.whitespace)
        AhkTest.AssertEqual("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!" Chr(34) "#$%&'()*+,-./:;<=>?@[\]^_``{|}~ `t`n`r" Chr(11) Chr(12), stdlib.string.printable)

        AhkTest.AssertEqual("Hello World", stdlib.string.capwords("  hello   world  "))
        AhkTest.AssertEqual("A B", stdlib.string.capwords("a  b", stdlib.None))
        AhkTest.AssertEqual("A,,B,", stdlib.string.capwords("a,,b,", ","))
        AhkTest.AssertEqual("A B  C", stdlib.string.capwords("a b  c", " "))
        AhkTest.AssertEqual("A B C", stdlib.string.capwords("a`t b`nc"))
        AhkTest.AssertEqual("Hello World", stdlib.string.capwords("hELLo woRLD"))
        AhkTest.AssertEqual("", stdlib.string.capwords(""))
    }

    static TestObservedCapwordsErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^capwords\(\) missing 1 required positional argument: 's'$", (*) => stdlib.string.capwords())
        AhkTest.RaisesMatch(TypeError, "^capwords\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.string.capwords("a", ",", ","))
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'split'$", (*) => stdlib.string.capwords(1))
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'join'$", (*) => stdlib.string.capwords("a", 1))
        AhkTest.RaisesMatch(ValueError, "^empty separator$", (*) => stdlib.string.capwords("abc", ""))
        AhkTest.RaisesMatch(AttributeError, "^'bool' object has no attribute 'join'$", (*) => stdlib.string.capwords("abc", stdlib.True))
        AhkTest.RaisesMatch(TypeError, "^must be str or None, not bool$", (*) => stdlib.string.capwords("abc", stdlib.False))
    }
}

AhkTest.Collect(StdlibStringTest)
