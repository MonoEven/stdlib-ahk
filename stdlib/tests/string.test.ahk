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

    static TestTemplateSubstituteFollowsPython()
    {
        template := stdlib.string.Template("$who likes $what")

        AhkTest.AssertEqual("tim likes pie", template.substitute(Map("who", "tim", "what", "pie")))
        AhkTest.AssertEqual("tim likes pie", template.substitute({ who: "tim", what: "pie" }))
    }

    static TestTemplateSupportsBracesAndEscaping()
    {
        AhkTest.AssertEqual("gentrification", stdlib.string.Template("${noun}ification").substitute(Map("noun", "gentr")))
        AhkTest.AssertEqual("Give $5", stdlib.string.Template("Give $$5").substitute(Map()))
    }

    static TestTemplateSafeSubstituteLeavesMissing()
    {
        template := stdlib.string.Template("$who likes $what")

        AhkTest.AssertEqual("tim likes $what", template.safe_substitute(Map("who", "tim")))
    }

    static TestTemplateMissingKeyRaisesKeyError()
    {
        AhkTest.RaisesMatch(stdlib.KeyError, "who", (*) => stdlib.string.Template("$who").substitute(Map()))
    }

    static TestTemplateInvalidTrailingDollarRaisesValueError()
    {
        AhkTest.RaisesMatch(ValueError, "Invalid placeholder in string", (*) => stdlib.string.Template("abc $").substitute(Map()))
    }

    static TestFormatterFormatPositionalAndNamedFields()
    {
        f := stdlib.string.Formatter()
        ; Reference: py -3.10 string.Formatter().format("{0} {1}","a","b") == 'a b'
        AhkTest.AssertEqual("a b", f.format("{0} {1}", "a", "b"))
        ; Auto-numbered fields
        AhkTest.AssertEqual("a b", f.format("{} {}", "a", "b"))
        ; Named field via Map kwargs
        AhkTest.AssertEqual("hi", f.vformat("{x}", [], Map("x", "hi")))
    }

    static TestFormatterFormatSpecsAndConversions()
    {
        f := stdlib.string.Formatter()
        ; Reference values from py -3.10 string.Formatter().format(...)
        AhkTest.AssertEqual("    x", f.format("{0:>5}", "x"))
        AhkTest.AssertEqual("00042", f.format("{0:05d}", 42))
        AhkTest.AssertContains("3.14", f.format("{0:.2f}", 3.14159))
        ; !r conversion: strings get single-quoted (Python repr)
        AhkTest.AssertEqual("'abc'", f.format("{0!r}", "abc"))
        AhkTest.AssertEqual("42", f.format("{0!s}", 42))
    }

    static TestFormatterParseYieldsTuples()
    {
        f := stdlib.string.Formatter()
        result := []
        for entry in f.parse("a{0}b{name}")
            result.Push(entry)
        ; Reference: list(string.Formatter().parse("a{0}b{name}")) ==
        ; [('a', '0', '', None), ('b', 'name', '', None)]
        AhkTest.AssertEqual(2, result.Length)
        AhkTest.AssertEqual("a", result[1][1])
        AhkTest.AssertEqual("0", result[1][2])
        AhkTest.AssertEqual("b", result[2][1])
        AhkTest.AssertEqual("name", result[2][2])
    }
}

AhkTest.Collect(StdlibStringTest)
