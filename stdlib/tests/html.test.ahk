#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\html>

class StdlibHtmlTest
{
    static TestEscapeAndUnescapeMatchObservedLocal310Surface()
    {
        sample := "<tag>&" Chr(34) "'"
        quotesOnly := Chr(34) "'"

        AhkTest.AssertEqual("&lt;tag&gt;&amp;&quot;&#x27;", stdlib.html.escape(sample))
        AhkTest.AssertEqual("&lt;tag&gt;&amp;" Chr(34) "'", stdlib.html.escape(sample, stdlib.False))
        AhkTest.AssertEqual(Chr(34) "'", stdlib.html.escape(quotesOnly, stdlib.None))
        AhkTest.AssertEqual("&quot;&#x27;", stdlib.html.escape(quotesOnly, stdlib.True))
        AhkTest.AssertEqual("", stdlib.html.escape(""))

        AhkTest.AssertEqual("<tag>&'" Chr(34), stdlib.html.unescape("&lt;tag&gt;&amp;&#x27;&quot;"))
        AhkTest.AssertEqual(Chr(160) "><", stdlib.html.unescape("&nbsp;&gt;&lt;"))
        AhkTest.AssertEqual("&bogus; &", stdlib.html.unescape("&bogus; &amp"))
        AhkTest.AssertEqual(">&", stdlib.html.unescape("&#62;&#38;"))
    }

    static TestObservedErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^escape\(\) missing 1 required positional argument: 's'$", (*) => stdlib.html.escape())
        AhkTest.RaisesMatch(TypeError, "^escape\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.html.escape("a", stdlib.True, 1))
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'replace'$", (*) => stdlib.html.escape(1))

        AhkTest.RaisesMatch(TypeError, "^unescape\(\) missing 1 required positional argument: 's'$", (*) => stdlib.html.unescape())
        AhkTest.RaisesMatch(TypeError, "^unescape\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.html.unescape("a", 1))
        AhkTest.RaisesMatch(TypeError, "^argument of type 'int' is not iterable$", (*) => stdlib.html.unescape(1))
    }
}

AhkTest.Collect(StdlibHtmlTest)
