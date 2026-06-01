#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\tkinter>

class StdlibTkinterTest
{
    static TestTclAndStringVarMatchObservedLocal310Surface()
    {
        interp := stdlib.tkinter.Tcl()
        named := stdlib.tkinter.StringVar(interp, "seed", "custom_name")
        generated := stdlib.tkinter.StringVar(interp, "grown")

        AhkTest.AssertEqual(8.6, stdlib.tkinter.TclVersion)
        AhkTest.AssertEqual(8.6, stdlib.tkinter.TkVersion)
        AhkTest.AssertEqual(2, stdlib.tkinter.READABLE)
        AhkTest.AssertEqual(4, stdlib.tkinter.WRITABLE)
        AhkTest.AssertEqual(8, stdlib.tkinter.EXCEPTION)
        AhkTest.AssertEqual("Tk", Type(interp))
        AhkTest.AssertEqual("3", interp.eval("expr 1 + 2"))
        AhkTest.AssertEqual(stdlib.None, interp.setvar("x", "hello"))
        AhkTest.AssertEqual("hello", interp.getvar("x"))
        AhkTest.AssertEqual(".", String(interp._root()))
        AhkTest.AssertEqual("seed", named.get())
        AhkTest.AssertEqual("custom_name", named._name)
        AhkTest.AssertEqual(stdlib.None, named.set("grown"))
        AhkTest.AssertEqual("grown", named.get())
        AhkTest.AssertEqual("grown", generated.get())
        AhkTest.AssertRegex(generated._name, "^" Chr(80) Chr(89) "_VAR[0-9]+$")
    }

    static TestObservedTkinterArityAndTypeErrorsMatchLocal310()
    {
        interp := stdlib.tkinter.Tcl()

        AhkTest.RaisesMatch(TypeError, "^Tcl\(\) takes from 0 to 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.Tcl(1, 2, 3, 4, 5))
        AhkTest.RaisesMatch(TypeError, "^Tcl\(\) got an unexpected keyword argument 'extra'$", (*) => stdlib.tkinter.Tcl({ extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => stdlib.tkinter.Tcl({ useTk: "x" }))
        AhkTest.RaisesMatch(TypeError, "^create\(\) argument 1 must be str or None, not int$", (*) => stdlib.tkinter.Tcl({ screenName: 1 }))
        AhkTest.RaisesMatch(TypeError, "^create\(\) argument 2 must be str, not int$", (*) => stdlib.tkinter.Tcl({ baseName: 1 }))
        AhkTest.RaisesMatch(TypeError, "^create\(\) argument 3 must be str, not int$", (*) => stdlib.tkinter.Tcl({ className: 1 }))
        AhkTest.RaisesMatch(TypeError, "^tkapp\.eval\(\) takes exactly one argument \(0 given\)$", (*) => interp.eval())
        AhkTest.RaisesMatch(TypeError, "^Misc\.setvar\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => interp.setvar("x", "y", "z"))
        AhkTest.RaisesMatch(TypeError, "^Misc\.getvar\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => interp.getvar("x", "y"))
        AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^can't read " Chr(34) "missing" Chr(34) ": no such variable$", (*) => interp.getvar("missing"))
        AhkTest.RaisesMatch(RuntimeError, "^Too early to create variable: no default root window$", (*) => stdlib.tkinter.StringVar())
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '_root'$", (*) => stdlib.tkinter.StringVar({ master: 1 }))
        AhkTest.RaisesMatch(TypeError, "^StringVar\.__init__\(\) got an unexpected keyword argument 'extra'$", (*) => stdlib.tkinter.StringVar({ master: interp, extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "^StringVar\.__init__\(\) takes from 1 to 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.StringVar(interp, "seed", "custom_name", "extra"))
        AhkTest.RaisesMatch(TypeError, "^name must be a string$", (*) => stdlib.tkinter.StringVar({ master: interp, name: 1 }))
    }
}

AhkTest.Collect(StdlibTkinterTest)
