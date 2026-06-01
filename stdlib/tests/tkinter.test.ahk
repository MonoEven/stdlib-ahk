#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\hashlib>
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
        AhkTest.AssertEqual(stdlib.None, interp.setvar("none_value", stdlib.None))
        AhkTest.AssertEqual("None", interp.getvar("none_value"))
        AhkTest.AssertEqual(".", String(interp._root()))
        AhkTest.AssertEqual("seed", named.get())
        AhkTest.AssertEqual("custom_name", named._name)
        AhkTest.AssertEqual("custom_name", String(named))
        AhkTest.AssertEqual(stdlib.None, named.set("grown"))
        AhkTest.AssertEqual("grown", named.get())
        AhkTest.AssertEqual(stdlib.None, named.set(stdlib.None))
        AhkTest.AssertEqual("None", named.get())
        AhkTest.AssertEqual("grown", generated.get())
        AhkTest.AssertRegex(generated._name, "^" Chr(80) Chr(89) "_VAR[0-9]+$")
    }

    static TestIntVarMatchesObservedLocal310Surface()
    {
        interp := stdlib.tkinter.Tcl()
        value := stdlib.tkinter.IntVar(interp, 7, "custom_int")

        AhkTest.AssertEqual(7, value.get())
        AhkTest.AssertEqual("custom_int", value._name)
        AhkTest.AssertEqual("custom_int", String(value))
        AhkTest.AssertEqual("7", interp.getvar("custom_int"))
        AhkTest.AssertEqual(stdlib.None, value.set(42))
        AhkTest.AssertEqual(42, value.get())
        AhkTest.AssertEqual(stdlib.None, value.set(stdlib.True))
        AhkTest.AssertEqual(1, value.get())
        AhkTest.AssertEqual(stdlib.None, value.set(stdlib.False))
        AhkTest.AssertEqual(0, value.get())
        AhkTest.AssertEqual(stdlib.None, value.set("3.5"))
        AhkTest.AssertEqual(3, value.get())
        AhkTest.AssertEqual(stdlib.None, value.set("09"))
        AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^expected floating-point number but got " Chr(34) "09" Chr(34) " \(looks like invalid octal number\)$", (*) => value.get())
        AhkTest.AssertEqual(stdlib.None, value.set("abc"))
        AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^expected floating-point number but got " Chr(34) "abc" Chr(34) "$", (*) => value.get())
    }

    static TestDoubleVarMatchesObservedLocal310Surface()
    {
        interp := stdlib.tkinter.Tcl()
        value := stdlib.tkinter.DoubleVar(interp, 1.25, "custom_double")

        AhkTest.AssertEqual(1.25, value.get())
        AhkTest.AssertEqual("custom_double", value._name)
        AhkTest.AssertEqual("custom_double", String(value))
        AhkTest.AssertEqual("1.25", interp.getvar("custom_double"))
        AhkTest.AssertEqual(stdlib.None, value.set(2))
        AhkTest.AssertEqual(2.0, value.get())
        AhkTest.AssertEqual(stdlib.None, value.set(stdlib.True))
        AhkTest.AssertEqual(1.0, value.get())
        AhkTest.AssertEqual(stdlib.None, value.set(stdlib.False))
        AhkTest.AssertEqual(0.0, value.get())
        AhkTest.AssertEqual(stdlib.None, value.set("09"))
        AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^expected floating-point number but got " Chr(34) "09" Chr(34) " \(looks like invalid octal number\)$", (*) => value.get())
        AhkTest.AssertEqual(stdlib.None, value.set(stdlib.None))
        AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^expected floating-point number but got " Chr(34) "None" Chr(34) "$", (*) => value.get())
    }

    static TestBooleanVarMatchesObservedLocal310Surface()
    {
        interp := stdlib.tkinter.Tcl()
        value := stdlib.tkinter.BooleanVar(interp, stdlib.True, "custom_bool")

        AhkTest.AssertSame(stdlib.True, value.get())
        AhkTest.AssertEqual("custom_bool", value._name)
        AhkTest.AssertEqual("custom_bool", String(value))
        AhkTest.AssertEqual("1", interp.getvar("custom_bool"))
        AhkTest.AssertEqual(stdlib.None, value.set(stdlib.False))
        AhkTest.AssertSame(stdlib.False, value.get())
        AhkTest.AssertEqual("0", interp.getvar("custom_bool"))
        AhkTest.AssertEqual(stdlib.None, value.set("yes"))
        AhkTest.AssertSame(stdlib.True, value.get())
        AhkTest.AssertEqual("1", interp.getvar("custom_bool"))
        AhkTest.AssertEqual(stdlib.None, value.set("off"))
        AhkTest.AssertSame(stdlib.False, value.get())
        AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^expected boolean value but got " Chr(34) "maybe" Chr(34) "$", (*) => value.set("maybe"))
        AhkTest.RaisesMatch(TypeError, "^getboolean\(\) argument must be str, not None$", (*) => value.set(stdlib.None))
        interp.setvar("custom_bool", "maybe")
        AhkTest.RaisesMatch(ValueError, "^invalid literal for getboolean\(\)$", (*) => value.get())
    }

    static TestVariableConstructorNameRetentionMatchesObservedLocal310()
    {
        interp := stdlib.tkinter.Tcl()
        interp.setvar("existing_string", "pre")
        interp.setvar("existing_int", "7")
        interp.setvar("existing_double", "2.5")
        interp.setvar("existing_bool", "yes")

        stringValue := stdlib.tkinter.StringVar({ master: interp, name: "existing_string" })
        intValue := stdlib.tkinter.IntVar({ master: interp, name: "existing_int" })
        doubleValue := stdlib.tkinter.DoubleVar({ master: interp, name: "existing_double" })
        boolValue := stdlib.tkinter.BooleanVar({ master: interp, name: "existing_bool" })
        emptyName := stdlib.tkinter.StringVar(interp, "x", "")

        AhkTest.AssertEqual("pre", stringValue.get())
        AhkTest.AssertEqual("existing_string", String(stringValue))
        AhkTest.AssertEqual(7, intValue.get())
        AhkTest.AssertEqual(2.5, doubleValue.get())
        AhkTest.AssertSame(stdlib.True, boolValue.get())
        AhkTest.AssertRegex(emptyName._name, "^" Chr(80) Chr(89) "_VAR[0-9]+$")
        AhkTest.AssertEqual("x", emptyName.get())
    }

    static TestVariablePublicClassAndInitializeMatchObservedLocal310()
    {
        interp := stdlib.tkinter.Tcl()
        interp.setvar("existing_variable", "kept")
        interp.setvar("existing_variable_none", "kept")

        value := stdlib.tkinter.Variable(interp, "seed", "custom_var")
        existingOmit := stdlib.tkinter.Variable({ master: interp, name: "existing_variable" })
        existingNone := stdlib.tkinter.Variable({ master: interp, value: stdlib.None, name: "existing_variable_none" })
        generated := stdlib.tkinter.Variable(interp, "x", "")
        stringValue := stdlib.tkinter.StringVar(interp, "s", "string_init")
        intValue := stdlib.tkinter.IntVar(interp, 1, "int_init")
        doubleValue := stdlib.tkinter.DoubleVar(interp, 1.25, "double_init")
        boolValue := stdlib.tkinter.BooleanVar(interp, stdlib.True, "bool_init")

        AhkTest.AssertEqual("seed", value.get())
        AhkTest.AssertEqual("custom_var", value._name)
        AhkTest.AssertEqual("custom_var", String(value))
        AhkTest.AssertEqual(stdlib.None, value.set("grown"))
        AhkTest.AssertEqual("grown", value.get())
        AhkTest.AssertEqual(stdlib.None, value.initialize("fresh"))
        AhkTest.AssertEqual("fresh", value.get())
        AhkTest.AssertEqual(stdlib.None, value.set(stdlib.None))
        AhkTest.AssertEqual("None", value.get())
        AhkTest.AssertEqual("kept", existingOmit.get())
        AhkTest.AssertEqual("kept", existingNone.get())
        AhkTest.AssertRegex(generated._name, "^" Chr(80) Chr(89) "_VAR[0-9]+$")
        AhkTest.AssertEqual("x", generated.get())

        AhkTest.AssertEqual(stdlib.None, stringValue.initialize(stdlib.None))
        AhkTest.AssertEqual("None", stringValue.get())
        AhkTest.AssertEqual(stdlib.None, intValue.initialize("3.5"))
        AhkTest.AssertEqual(3, intValue.get())
        AhkTest.AssertEqual(stdlib.None, doubleValue.initialize(2))
        AhkTest.AssertEqual(2.0, doubleValue.get())
        AhkTest.AssertEqual(stdlib.None, boolValue.initialize("off"))
        AhkTest.AssertSame(stdlib.False, boolValue.get())
    }

    static TestVariableTraceCallbacksMatchLocal310()
    {
        interp := stdlib.tkinter.Tcl()
        value := stdlib.tkinter.StringVar(interp, "seed", "trace_var")
        writeRecorder := StdlibTkinterTest.TraceRecorder()

        writeName := value.trace_add("write", writeRecorder)
        info := value.trace_info()
        AhkTest.AssertRegex(writeName, "^ahkstdlib_tkinter_command_[0-9]+$")
        AhkTest.AssertEqual(1, info.Length)
        AhkTest.AssertEqual(stdlib.tuple(["write"]), info[1][1])
        AhkTest.AssertEqual(writeName, info[1][2])
        AhkTest.AssertEqual(stdlib.None, value.set("grown"))
        AhkTest.AssertEqual(1, writeRecorder.Calls.Length)
        AhkTest.AssertEqual(stdlib.tuple(["trace_var", "", "write"]), writeRecorder.Calls[1])
        AhkTest.AssertEqual(stdlib.None, value.trace_remove("write", writeName))
        AhkTest.AssertEqual(0, value.trace_info().Length)
        AhkTest.AssertEqual(stdlib.None, value.set("after_remove"))
        AhkTest.AssertEqual(1, writeRecorder.Calls.Length)

        readWriteRecorder := StdlibTkinterTest.TraceRecorder()
        readWriteName := value.trace_add(["read", "write"], readWriteRecorder)
        info := value.trace_info()
        AhkTest.AssertEqual(1, info.Length)
        AhkTest.AssertEqual(stdlib.tuple(["read", "write"]), info[1][1])
        AhkTest.AssertEqual(readWriteName, info[1][2])
        AhkTest.AssertEqual("after_remove", value.get())
        AhkTest.AssertEqual(stdlib.None, value.set("tuple_set"))
        AhkTest.AssertEqual(2, readWriteRecorder.Calls.Length)
        AhkTest.AssertEqual(stdlib.tuple(["trace_var", "", "read"]), readWriteRecorder.Calls[1])
        AhkTest.AssertEqual(stdlib.tuple(["trace_var", "", "write"]), readWriteRecorder.Calls[2])
        AhkTest.AssertEqual(stdlib.None, value.trace_remove(["read", "write"], readWriteName))
        AhkTest.AssertEqual(0, value.trace_info().Length)

        legacyRecorder := StdlibTkinterTest.TraceRecorder()
        legacyName := value.trace_variable("w", legacyRecorder)
        AhkTest.AssertEqual(stdlib.tuple([stdlib.tuple(["w", legacyName])]), value.trace_vinfo())
        info := value.trace_info()
        AhkTest.AssertEqual(1, info.Length)
        AhkTest.AssertEqual(stdlib.tuple(["write"]), info[1][1])
        AhkTest.AssertEqual(legacyName, info[1][2])
        AhkTest.AssertEqual(stdlib.None, value.set("legacy_set"))
        AhkTest.AssertEqual(stdlib.tuple(["trace_var", "", "w"]), legacyRecorder.Calls[1])
        AhkTest.AssertEqual(stdlib.None, value.trace_vdelete("w", legacyName))
        AhkTest.AssertEqual(0, value.trace_vinfo().Length)

        unsetRecorder := StdlibTkinterTest.TraceRecorder()
        unsetValue := stdlib.tkinter.StringVar(interp, "seed", "unset_var")
        unsetName := unsetValue.trace_add("unset", unsetRecorder)
        AhkTest.AssertRegex(unsetName, "^ahkstdlib_tkinter_command_[0-9]+$")
        AhkTest.AssertEqual("", interp.eval("unset unset_var"))
        AhkTest.AssertEqual(stdlib.tuple(["unset_var", "", "unset"]), unsetRecorder.Calls[1])
        AhkTest.AssertEqual(0, unsetValue.trace_info().Length)
    }

    static TestTclUseTkLoadsTkPackageLikeLocal310()
    {
        interp := stdlib.tkinter.Tcl({ useTk: stdlib.True })

        AhkTest.AssertEqual("winfo", interp.eval("info commands winfo"))
        AhkTest.AssertEqual("8.6.12", interp.eval("package require Tk"))
    }

    static TestTkMiscNumericAndBooleanConversionsMatchLocal310()
    {
        interp := stdlib.tkinter.Tcl()
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            label := stdlib.tkinter.Label(root, { text: "Convert" })

            for owner in [interp, root, label] {
                AhkTest.AssertEqual(7, owner.getint("7"))
                AhkTest.AssertEqual(7, owner.getint("+7"))
                AhkTest.AssertEqual(-7, owner.getint("-7"))
                AhkTest.AssertEqual(7, owner.getint(" 7 "))
                AhkTest.AssertEqual(16, owner.getint("0x10"))
                AhkTest.AssertSame(stdlib.True, owner.getint(stdlib.True))
                AhkTest.AssertSame(stdlib.False, owner.getint(stdlib.False))

                AhkTest.AssertEqual(1.25, owner.getdouble("1.25"))
                AhkTest.AssertEqual(2.0, owner.getdouble("2"))
                AhkTest.AssertEqual(3.5, owner.getdouble("+3.5"))
                AhkTest.AssertEqual(4.5, owner.getdouble(" 4.5 "))
                AhkTest.AssertEqual(1.0, owner.getdouble(stdlib.True))
                AhkTest.AssertEqual(0.0, owner.getdouble(stdlib.False))

                AhkTest.AssertSame(stdlib.True, owner.getboolean("1"))
                AhkTest.AssertSame(stdlib.False, owner.getboolean("0"))
                AhkTest.AssertSame(stdlib.True, owner.getboolean("true"))
                AhkTest.AssertSame(stdlib.False, owner.getboolean("false"))
                AhkTest.AssertSame(stdlib.True, owner.getboolean("yes"))
                AhkTest.AssertSame(stdlib.False, owner.getboolean("no"))
                AhkTest.AssertSame(stdlib.True, owner.getboolean("on"))
                AhkTest.AssertSame(stdlib.False, owner.getboolean("off"))
                AhkTest.AssertSame(stdlib.True, owner.getboolean(stdlib.True))
                AhkTest.AssertSame(stdlib.False, owner.getboolean(stdlib.False))
                AhkTest.AssertSame(stdlib.True, owner.getboolean(1))
                AhkTest.AssertSame(stdlib.False, owner.getboolean(0))

                AhkTest.RaisesMatch(ValueError, '^expected integer but got "3\.5"$', ObjBindMethod(owner, "getint", "3.5"))
                AhkTest.RaisesMatch(ValueError, '^expected integer but got "09"$', ObjBindMethod(owner, "getint", "09"))
                AhkTest.RaisesMatch(TypeError, "^getint\(\) argument must be str, not None$", ObjBindMethod(owner, "getint", stdlib.None))
                AhkTest.RaisesMatch(TypeError, "^getint\(\) argument must be str, not list$", ObjBindMethod(owner, "getint", []))
                AhkTest.RaisesMatch(ValueError, "^floating point value is Not a Number$", ObjBindMethod(owner, "getdouble", "nan"))
                AhkTest.RaisesMatch(ValueError, '^expected floating-point number but got "09" \(looks like invalid octal number\)$', ObjBindMethod(owner, "getdouble", "09"))
                AhkTest.RaisesMatch(TypeError, "^getdouble\(\) argument must be str, not None$", ObjBindMethod(owner, "getdouble", stdlib.None))
                AhkTest.RaisesMatch(TypeError, "^getdouble\(\) argument must be str, not list$", ObjBindMethod(owner, "getdouble", []))
                AhkTest.RaisesMatch(ValueError, "^invalid literal for getboolean\(\)$", ObjBindMethod(owner, "getboolean", "maybe"))
                AhkTest.RaisesMatch(TypeError, "^getboolean\(\) argument must be str, not None$", ObjBindMethod(owner, "getboolean", stdlib.None))
                AhkTest.RaisesMatch(TypeError, "^Misc\.getint\(\) missing 1 required positional argument: 's'$", ObjBindMethod(owner, "getint"))
                AhkTest.RaisesMatch(TypeError, "^Misc\.getint\(\) takes 2 positional arguments but 3 were given$", ObjBindMethod(owner, "getint", "1", "2"))
                AhkTest.RaisesMatch(TypeError, "^Misc\.getdouble\(\) missing 1 required positional argument: 's'$", ObjBindMethod(owner, "getdouble"))
                AhkTest.RaisesMatch(TypeError, "^Misc\.getdouble\(\) takes 2 positional arguments but 3 were given$", ObjBindMethod(owner, "getdouble", "1", "2"))
                AhkTest.RaisesMatch(TypeError, "^Misc\.getboolean\(\) missing 1 required positional argument: 's'$", ObjBindMethod(owner, "getboolean"))
                AhkTest.RaisesMatch(TypeError, "^Misc\.getboolean\(\) takes 2 positional arguments but 3 were given$", ObjBindMethod(owner, "getboolean", "1", "2"))
            }
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkPublicConstructorLoadsTkRootLikeLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")

            AhkTest.AssertEqual("Tk", Type(root))
            AhkTest.AssertEqual(".", String(root))
            AhkTest.AssertSame(root, root._root())
            AhkTest.AssertEqual("winfo", root.eval("info commands winfo"))
            AhkTest.AssertEqual("8.6.12", root.eval("package require Tk"))
            AhkTest.AssertEqual("1", root.eval("winfo exists ."))
            try root.update_idletasks()
            AhkTest.AssertEqual(stdlib.None, root.destroy())
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkRootWindowVisibilityAndGeometryMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual(".", String(root))
            AhkTest.AssertEqual("wm", root.winfo_manager())
            AhkTest.AssertEqual(1, root.winfo_exists())
            AhkTest.AssertEqual("normal", root.state())
            AhkTest.AssertEqual("", root.withdraw())
            AhkTest.AssertEqual("withdrawn", root.state())
            AhkTest.AssertEqual(0, root.winfo_viewable())
            AhkTest.AssertEqual("", root.deiconify())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("normal", root.state())
            AhkTest.AssertEqual(1, root.winfo_viewable())
            AhkTest.AssertEqual(1, root.winfo_ismapped())
            AhkTest.AssertEqual("", root.geometry("240x120+20+30"))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("240x120+20+30", root.geometry())
            AhkTest.AssertEqual(240, root.winfo_width())
            AhkTest.AssertEqual(120, root.winfo_height())
            AhkTest.AssertSame(root, root.winfo_toplevel())

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_geometry\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.geometry("1x1", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_state\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.state("normal", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_withdraw\(\) takes 1 positional argument but 2 were given$", (*) => root.withdraw(1))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_deiconify\(\) takes 1 positional argument but 2 were given$", (*) => root.deiconify(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_viewable\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_viewable(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_width\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_width(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad geometry specifier "bad"$', (*) => root.geometry("bad"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWidgetVisibilityAndToplevelGeometryMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.geometry("260x180+10+20"))
            frame := stdlib.tkinter.Frame(root, { name: "host", width: 90, height: 40, bg: "white" })
            label := stdlib.tkinter.Label(frame, { name: "caption", text: "Hello" })
            AhkTest.AssertEqual(stdlib.None, frame.pack())
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual(1, frame.winfo_viewable())
            AhkTest.AssertEqual(1, frame.winfo_ismapped())
            AhkTest.AssertTrue(frame.winfo_width() > 0)
            AhkTest.AssertTrue(frame.winfo_height() > 0)
            AhkTest.AssertEqual(1, label.winfo_viewable())
            AhkTest.AssertEqual(1, label.winfo_ismapped())
            AhkTest.AssertTrue(label.winfo_width() > 0)
            AhkTest.AssertTrue(label.winfo_height() > 0)
            AhkTest.AssertSame(root, label.winfo_toplevel())

            top := stdlib.tkinter.Toplevel(root, { name: "dialog" })
            AhkTest.AssertEqual("", top.geometry("180x90+30+40"))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("180x90+30+40", top.geometry())
            AhkTest.AssertEqual(180, top.winfo_width())
            AhkTest.AssertEqual(90, top.winfo_height())
            AhkTest.AssertEqual(1, top.winfo_viewable())
            AhkTest.AssertEqual(1, top.winfo_ismapped())
            AhkTest.AssertSame(top, top.winfo_toplevel())
            child := stdlib.tkinter.Label(top, { name: "inner", text: "Inside" })
            AhkTest.AssertEqual(stdlib.None, child.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertSame(top, child.winfo_toplevel())

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_geometry\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.geometry("1x1", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad geometry specifier "bad"$', (*) => top.geometry("bad"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_height\(\) takes 1 positional argument but 2 were given$", (*) => label.winfo_height(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_toplevel\(\) takes 1 positional argument but 2 were given$", (*) => label.winfo_toplevel(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWindowIconifyLifecycleMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("normal", root.state())
            AhkTest.AssertEqual("", root.iconify())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("iconic", root.state())
            AhkTest.AssertEqual(0, root.winfo_viewable())
            AhkTest.AssertEqual(0, root.winfo_ismapped())
            AhkTest.AssertEqual("", root.deiconify())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("normal", root.state())
            AhkTest.AssertEqual(1, root.winfo_viewable())
            AhkTest.AssertEqual(1, root.winfo_ismapped())
            AhkTest.AssertEqual("", root.withdraw())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("withdrawn", root.state())
            AhkTest.AssertEqual("", root.iconify())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("iconic", root.state())

            top := stdlib.tkinter.Toplevel(root, { name: "icon_dialog" })
            AhkTest.AssertEqual("normal", top.state())
            AhkTest.AssertEqual("", top.iconify())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("iconic", top.state())
            AhkTest.AssertEqual("", top.deiconify())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("normal", top.state())

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_iconify\(\) takes 1 positional argument but 2 were given$", (*) => root.iconify(1))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_iconify\(\) takes 1 positional argument but 2 were given$", (*) => top.iconify(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWindowOverrideredirectMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            top := stdlib.tkinter.Toplevel(root, { name: "dialog" })
            top.withdraw()

            AhkTest.AssertEqual(stdlib.None, root.overrideredirect())
            AhkTest.AssertEqual(stdlib.None, root.overrideredirect(stdlib.True))
            AhkTest.AssertSame(stdlib.True, root.overrideredirect())
            AhkTest.AssertEqual(stdlib.None, root.wm_overrideredirect(stdlib.False))
            AhkTest.AssertEqual(stdlib.None, root.overrideredirect())
            AhkTest.AssertEqual(stdlib.None, root.overrideredirect(1))
            AhkTest.AssertSame(stdlib.True, root.overrideredirect())
            AhkTest.AssertEqual(stdlib.None, root.overrideredirect(0))
            AhkTest.AssertEqual(stdlib.None, root.overrideredirect())
            AhkTest.AssertEqual(stdlib.None, root.overrideredirect(stdlib.None))

            AhkTest.AssertEqual(stdlib.None, top.overrideredirect())
            AhkTest.AssertEqual(stdlib.None, top.overrideredirect(stdlib.True))
            AhkTest.AssertSame(stdlib.True, top.overrideredirect())
            AhkTest.AssertEqual(stdlib.None, top.wm_overrideredirect(stdlib.False))
            AhkTest.AssertEqual(stdlib.None, top.overrideredirect())

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_overrideredirect\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.overrideredirect(stdlib.True, stdlib.False))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected boolean value but got "bad"$', (*) => root.overrideredirect("bad"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_overrideredirect\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.overrideredirect(stdlib.True, stdlib.False))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected boolean value but got "bad"$', (*) => top.overrideredirect("bad"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWindowTransientRelationshipsMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            top := stdlib.tkinter.Toplevel(root, { name: "transient_dialog" })
            child := stdlib.tkinter.Toplevel(top, { name: "child" })
            top.withdraw()
            child.withdraw()

            AhkTest.AssertEqual("", root.transient())
            AhkTest.AssertEqual("", top.transient())
            AhkTest.AssertEqual("", top.transient(root))
            AhkTest.AssertEqual(".", top.wm_transient())
            AhkTest.AssertEqual(".", top.transient(stdlib.None))
            AhkTest.AssertEqual(".", top.transient())
            AhkTest.AssertEqual("", top.transient(""))
            AhkTest.AssertEqual("", top.transient())
            AhkTest.AssertEqual("", child.transient(top))
            AhkTest.AssertEqual(".transient_dialog", child.transient())
            AhkTest.AssertEqual("", child.wm_transient(""))
            AhkTest.AssertEqual("", child.transient())

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_transient\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.transient(root, child))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.missing"$', (*) => top.transient(".missing"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "1"$', (*) => top.transient(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^setting "\." as master creates a transient/master cycle$', (*) => root.transient(root))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^setting "\.transient_dialog" as master creates a transient/master cycle$', (*) => top.transient(top))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWindowAndWidgetStackingMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            top := stdlib.tkinter.Toplevel(root, { name: "stack_dialog" })
            frame := stdlib.tkinter.Frame(root, { name: "stack_host" })
            label := stdlib.tkinter.Label(frame, { name: "front", text: "front" })
            button := stdlib.tkinter.Button(frame, { name: "back", text: "back" })
            AhkTest.AssertEqual(stdlib.None, frame.pack())
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, button.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual(stdlib.None, root.lift())
            AhkTest.AssertEqual(stdlib.None, root.tkraise(top))
            AhkTest.AssertEqual(stdlib.None, root.lower())
            AhkTest.AssertEqual(stdlib.None, top.lift(root))
            AhkTest.AssertEqual(stdlib.None, top.tkraise())
            AhkTest.AssertEqual(stdlib.None, top.lower(root))
            AhkTest.AssertEqual(stdlib.None, frame.lift())
            AhkTest.AssertEqual(stdlib.None, label.lift(button))
            AhkTest.AssertEqual(stdlib.None, button.tkraise(label))
            AhkTest.AssertEqual(stdlib.None, label.lower(button))
            AhkTest.AssertEqual(stdlib.None, label.lift(stdlib.None))
            AhkTest.AssertEqual(stdlib.None, label.lower(stdlib.None))

            AhkTest.RaisesMatch(TypeError, "^Misc\.tkraise\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => label.lift(button, frame))
            AhkTest.RaisesMatch(TypeError, "^Misc\.lower\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => label.lower(button, frame))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.missing"$', (*) => label.lift(".missing"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.missing"$', (*) => label.lower(".missing"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "1"$', (*) => label.lift(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkGrabLocalModalStateMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            top := stdlib.tkinter.Toplevel(root, { name: "grab_dialog" })
            button := stdlib.tkinter.Button(top, { name: "ok", text: "OK" })
            top.withdraw()
            AhkTest.AssertEqual(stdlib.None, button.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual(stdlib.None, root.grab_current())
            AhkTest.AssertEqual(stdlib.None, top.grab_status())
            AhkTest.AssertEqual(stdlib.None, button.grab_status())
            AhkTest.AssertEqual(stdlib.None, top.grab_set())
            AhkTest.AssertSame(top, root.grab_current())
            AhkTest.AssertSame(top, top.grab_current())
            AhkTest.AssertSame(top, button.grab_current())
            AhkTest.AssertEqual("local", top.grab_status())
            AhkTest.AssertEqual(stdlib.None, button.grab_status())
            AhkTest.AssertEqual(stdlib.None, button.grab_set())
            AhkTest.AssertSame(button, root.grab_current())
            AhkTest.AssertEqual("local", button.grab_status())
            AhkTest.AssertEqual(stdlib.None, top.grab_status())
            AhkTest.AssertEqual(stdlib.None, button.grab_release())
            AhkTest.AssertEqual(stdlib.None, root.grab_current())
            AhkTest.AssertEqual(stdlib.None, top.grab_status())
            AhkTest.AssertEqual(stdlib.None, top.grab_release())
            AhkTest.AssertEqual(stdlib.None, root.grab_current())

            AhkTest.RaisesMatch(TypeError, "^Misc\.grab_set\(\) takes 1 positional argument but 2 were given$", (*) => top.grab_set(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grab_release\(\) takes 1 positional argument but 2 were given$", (*) => top.grab_release(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grab_current\(\) takes 1 positional argument but 2 were given$", (*) => top.grab_current(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grab_status\(\) takes 1 positional argument but 2 were given$", (*) => top.grab_status(1))
        } finally {
            try root.grab_release()
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWaitWindowAndVisibilityMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            visibleTop := stdlib.tkinter.Toplevel(root, { name: "visible_wait" })
            AhkTest.AssertEqual(stdlib.None, visibleTop.wait_visibility())

            visibleTop2 := stdlib.tkinter.Toplevel(root, { name: "visible_wait2" })
            AhkTest.AssertEqual(stdlib.None, root.wait_visibility(visibleTop2))

            closeTop := stdlib.tkinter.Toplevel(root, { name: "close_wait" })
            AhkTest.AssertRegex(root.after(0, (*) => closeTop.destroy()), "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, root.wait_window(closeTop))
            AhkTest.AssertEqual("0", root.eval("winfo exists .close_wait"))

            selfCloseTop := stdlib.tkinter.Toplevel(root, { name: "self_close_wait" })
            AhkTest.AssertRegex(root.after(0, (*) => selfCloseTop.destroy()), "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, selfCloseTop.wait_window())
            AhkTest.AssertEqual("0", root.eval("winfo exists .self_close_wait"))

            noneCloseTop := stdlib.tkinter.Toplevel(root, { name: "none_close_wait" })
            AhkTest.AssertRegex(root.after(0, (*) => noneCloseTop.destroy()), "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, noneCloseTop.wait_window(stdlib.None))
            AhkTest.AssertEqual("0", root.eval("winfo exists .none_close_wait"))

            noneVisibleTop := stdlib.tkinter.Toplevel(root, { name: "none_visible_wait" })
            AhkTest.AssertEqual(stdlib.None, noneVisibleTop.wait_visibility(stdlib.None))

            AhkTest.RaisesMatch(TypeError, "^Misc\.wait_window\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.wait_window(root, visibleTop))
            AhkTest.RaisesMatch(TypeError, "^Misc\.wait_visibility\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.wait_visibility(root, visibleTop))
            AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute '_w'$", (*) => root.wait_window(".missing"))
            AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute '_w'$", (*) => root.wait_visibility(".missing"))
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '_w'$", (*) => root.wait_window(1))
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '_w'$", (*) => root.wait_visibility(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWaitVariableAndAliasMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            value := stdlib.tkinter.StringVar(root, "before", "wait_var")
            AhkTest.AssertRegex(root.after(0, (*) => value.set("after")), "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, root.wait_variable(value))
            AhkTest.AssertEqual("after", value.get())

            AhkTest.AssertRegex(root.after(0, (*) => root.setvar("string_wait_var", "done")), "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, root.wait_variable("string_wait_var"))
            AhkTest.AssertEqual("done", root.getvar("string_wait_var"))

            defaultName := Chr(80) Chr(89) "_VAR"
            AhkTest.AssertRegex(root.after(0, (*) => root.setvar(defaultName, "default_done")), "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, root.wait_variable())
            AhkTest.AssertEqual("default_done", root.getvar(defaultName))

            aliasValue := stdlib.tkinter.StringVar(root, "before_alias", "alias_wait_var")
            AhkTest.AssertRegex(root.after(0, (*) => aliasValue.set("alias_after")), "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, root.waitvar(aliasValue))
            AhkTest.AssertEqual("alias_after", aliasValue.get())

            label := stdlib.tkinter.Label(root, { name: "wait_label" })
            widgetValue := stdlib.tkinter.StringVar(root, "widget_before", "widget_wait_var")
            AhkTest.AssertRegex(root.after(0, (*) => widgetValue.set("widget_after")), "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, label.wait_variable(widgetValue))
            AhkTest.AssertEqual("widget_after", widgetValue.get())

            AhkTest.RaisesMatch(TypeError, "^Misc\.wait_variable\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.wait_variable("a", "b"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.wait_variable\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.waitvar("a", "b"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWinfoCoordinateQueriesMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.geometry("260x180+25+35"))
            frame := stdlib.tkinter.Frame(root, { name: "coord_host", width: 100, height: 60, bg: "white" })
            label := stdlib.tkinter.Label(frame, { name: "caption", text: "Hello", width: 8 })
            AhkTest.AssertEqual(stdlib.None, frame.pack({ padx: 11, pady: 13 }))
            AhkTest.AssertEqual(stdlib.None, label.pack({ padx: 5, pady: 7 }))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            rootScreenWidth := root.winfo_screenwidth()
            rootScreenHeight := root.winfo_screenheight()
            AhkTest.AssertEqual(25, root.winfo_x())
            AhkTest.AssertEqual(35, root.winfo_y())
            AhkTest.AssertTrue(root.winfo_rootx() >= root.winfo_x())
            AhkTest.AssertTrue(root.winfo_rooty() >= root.winfo_y())
            AhkTest.AssertTrue(rootScreenWidth > 0)
            AhkTest.AssertTrue(rootScreenHeight > 0)
            AhkTest.AssertTrue(root.winfo_reqwidth() > 0)
            AhkTest.AssertTrue(root.winfo_reqheight() > 0)

            AhkTest.AssertTrue(frame.winfo_x() >= 0)
            AhkTest.AssertTrue(frame.winfo_y() >= 0)
            AhkTest.AssertTrue(frame.winfo_rootx() >= root.winfo_rootx())
            AhkTest.AssertTrue(frame.winfo_rooty() >= root.winfo_rooty())
            AhkTest.AssertEqual(frame.winfo_width(), frame.winfo_reqwidth())
            AhkTest.AssertEqual(frame.winfo_height(), frame.winfo_reqheight())
            AhkTest.AssertEqual(rootScreenWidth, frame.winfo_screenwidth())
            AhkTest.AssertEqual(rootScreenHeight, frame.winfo_screenheight())

            AhkTest.AssertEqual(5, label.winfo_x())
            AhkTest.AssertEqual(7, label.winfo_y())
            AhkTest.AssertTrue(label.winfo_rootx() >= frame.winfo_rootx())
            AhkTest.AssertTrue(label.winfo_rooty() >= frame.winfo_rooty())
            AhkTest.AssertEqual(label.winfo_width(), label.winfo_reqwidth())
            AhkTest.AssertEqual(label.winfo_height(), label.winfo_reqheight())
            AhkTest.AssertEqual(rootScreenWidth, label.winfo_screenwidth())
            AhkTest.AssertEqual(rootScreenHeight, label.winfo_screenheight())

            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_x\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_x(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_y\(\) takes 1 positional argument but 2 were given$", (*) => label.winfo_y(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_rootx\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_rootx(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_screenwidth\(\) takes 1 positional argument but 2 were given$", (*) => label.winfo_screenwidth(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_reqheight\(\) takes 1 positional argument but 2 were given$", (*) => label.winfo_reqheight(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWinfoPixelsAndRgbQueriesMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            frame := stdlib.tkinter.Frame(root, { name: "pixels_host" })
            label := stdlib.tkinter.Label(frame, { name: "caption", text: "Hello" })
            canvas := stdlib.tkinter.Canvas(root, { width: 80, height: 40 })
            AhkTest.AssertEqual(stdlib.None, frame.pack())
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, canvas.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            AhkTest.AssertEqual(10, root.winfo_pixels("10"))
            AhkTest.AssertEqual(96, root.winfo_pixels("1i"))
            AhkTest.AssertEqual(48, frame.winfo_pixels("0.5i"))
            AhkTest.AssertEqual(76, label.winfo_pixels("2c"))
            AhkTest.AssertEqual(16, canvas.winfo_pixels("12p"))
            AhkTest.AssertEqual(10.0, root.winfo_fpixels("10"))
            AhkTest.AssertTrue(Abs(root.winfo_fpixels("1i") - 95.92433628318584) < 0.000001)
            AhkTest.AssertTrue(Abs(frame.winfo_fpixels("2c") - 75.53097345132744) < 0.000001)
            AhkTest.AssertTrue(Abs(label.winfo_fpixels("3m") - 11.329646017699115) < 0.000001)
            AhkTest.AssertEqual(stdlib.tuple([65535, 0, 0]), root.winfo_rgb("red"))
            AhkTest.AssertEqual(stdlib.tuple([0, 0, 0]), frame.winfo_rgb("black"))
            AhkTest.AssertEqual(stdlib.tuple([4369, 8738, 13107]), label.winfo_rgb("#112233"))
            AhkTest.AssertEqual(stdlib.tuple([43690, 48059, 52428]), canvas.winfo_rgb("#abc"))

            label.destroy()
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.pixels_host\.caption"$', (*) => label.winfo_pixels("1i"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.pixels_host\.caption"$', (*) => label.winfo_rgb("red"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_pixels\(\) missing 1 required positional argument: 'number'$", (*) => root.winfo_pixels())
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_pixels\(\) takes 2 positional arguments but 3 were given$", (*) => root.winfo_pixels("1i", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_fpixels\(\) missing 1 required positional argument: 'number'$", (*) => frame.winfo_fpixels())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => frame.winfo_fpixels("bad"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_rgb\(\) missing 1 required positional argument: 'color'$", (*) => canvas.winfo_rgb())
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_rgb\(\) takes 2 positional arguments but 3 were given$", (*) => canvas.winfo_rgb("red", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown color name "notacolor"$', (*) => canvas.winfo_rgb("notacolor"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWinfoScreenMetadataQueriesMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            frame := stdlib.tkinter.Frame(root, { name: "screen_host" })
            label := stdlib.tkinter.Label(frame, { name: "caption", text: "Hello" })
            AhkTest.AssertEqual(stdlib.None, frame.pack())
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            for widget in [root, frame, label] {
                AhkTest.AssertEqual(":0.0", widget.winfo_screen())
                AhkTest.AssertEqual(452, widget.winfo_screenmmwidth())
                AhkTest.AssertEqual(282, widget.winfo_screenmmheight())
                AhkTest.AssertEqual(32, widget.winfo_screendepth())
                AhkTest.AssertEqual(256, widget.winfo_screencells())
                AhkTest.AssertEqual("truecolor", widget.winfo_screenvisual())
                AhkTest.AssertEqual("Windows 10.0 29599 Win64", widget.winfo_server())
            }

            label.destroy()
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.screen_host\.caption"$', (*) => label.winfo_screen())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.screen_host\.caption"$', (*) => label.winfo_server())
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_screen\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_screen(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_screenmmwidth\(\) takes 1 positional argument but 2 were given$", (*) => frame.winfo_screenmmwidth(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_screendepth\(\) takes 1 positional argument but 2 were given$", (*) => frame.winfo_screendepth(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_server\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_server(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWinfoLogicalScreenAndVirtualRootQueriesMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            frame := stdlib.tkinter.Frame(root, { name: "vroot_host" })
            label := stdlib.tkinter.Label(frame, { name: "caption", text: "Hello" })
            AhkTest.AssertEqual(stdlib.None, frame.pack())
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            for widget in [root, frame, label] {
                AhkTest.AssertEqual(1707, widget.winfo_screenwidth())
                AhkTest.AssertEqual(1067, widget.winfo_screenheight())
                AhkTest.AssertEqual(1707, widget.winfo_vrootwidth())
                AhkTest.AssertEqual(1067, widget.winfo_vrootheight())
                AhkTest.AssertEqual(0, widget.winfo_vrootx())
                AhkTest.AssertEqual(0, widget.winfo_vrooty())
            }

            label.destroy()
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.vroot_host\.caption"$', (*) => label.winfo_vrootwidth())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.vroot_host\.caption"$', (*) => label.winfo_screenwidth())
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_vrootwidth\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_vrootwidth(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_vrootx\(\) takes 1 positional argument but 2 were given$", (*) => frame.winfo_vrootx(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_screenwidth\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_screenwidth(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWinfoVisualColormapAndPointerQueriesMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            frame := stdlib.tkinter.Frame(root, { name: "visual_host" })
            label := stdlib.tkinter.Label(frame, { name: "caption", text: "Visual" })
            AhkTest.AssertEqual(stdlib.None, frame.pack())
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            for widget in [root, frame, label] {
                AhkTest.AssertEqual(256, widget.winfo_cells())
                AhkTest.AssertSame(stdlib.False, widget.winfo_colormapfull())
                AhkTest.AssertEqual(32, widget.winfo_depth())
                AhkTest.AssertEqual("truecolor", widget.winfo_visual())
                AhkTest.AssertEqual("0x0", widget.winfo_visualid())
                AhkTest.AssertEqual([stdlib.tuple(["truecolor", 32])], widget.winfo_visualsavailable())
                AhkTest.AssertEqual([stdlib.tuple(["truecolor", 32, 0])], widget.winfo_visualsavailable(stdlib.True))
                AhkTest.AssertEqual([stdlib.tuple(["truecolor", 32])], widget.winfo_visualsavailable(stdlib.False))
                AhkTest.AssertEqual([stdlib.tuple(["truecolor", 32])], widget.winfo_visualsavailable(stdlib.None))
                AhkTest.AssertTrue(widget.winfo_geometry() ~= "^\d+x\d+\+\d+\+\d+$")
                AhkTest.AssertTrue(widget.winfo_id() is Integer)
                AhkTest.AssertTrue(widget.winfo_id() >= 0)
                pointer := widget.winfo_pointerxy()
                AhkTest.AssertTrue(pointer is Array)
                AhkTest.AssertEqual(2, pointer.Length)
                AhkTest.AssertTrue(pointer[1] is Integer)
                AhkTest.AssertTrue(pointer[2] is Integer)
                AhkTest.AssertEqual(pointer[1], widget.winfo_pointerx())
                AhkTest.AssertEqual(pointer[2], widget.winfo_pointery())
            }

            label.destroy()
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.visual_host\.caption"$', (*) => label.winfo_cells())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.visual_host\.caption"$', (*) => label.winfo_visualsavailable())
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_cells\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_cells(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_colormapfull\(\) takes 1 positional argument but 2 were given$", (*) => frame.winfo_colormapfull(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_depth\(\) takes 1 positional argument but 2 were given$", (*) => label.winfo_depth(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_geometry\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_geometry(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_id\(\) takes 1 positional argument but 2 were given$", (*) => frame.winfo_id(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_pointerxy\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_pointerxy(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_visual\(\) takes 1 positional argument but 2 were given$", (*) => frame.winfo_visual(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_visualid\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_visualid(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_visualsavailable\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.winfo_visualsavailable(stdlib.True, "extra"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWinfoAtomPathAndContainingQueriesMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.geometry("260x180+25+35"))
            frame := stdlib.tkinter.Frame(root, { name: "atom_host", width: 160, height: 90, bg: "white" })
            label := stdlib.tkinter.Label(frame, { name: "caption", text: "AtomPath" })
            AhkTest.AssertEqual(stdlib.None, frame.pack({ padx: 8, pady: 9 }))
            AhkTest.AssertEqual(stdlib.None, label.pack({ padx: 6, pady: 7 }))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            atom := root.winfo_atom("WM_DELETE_WINDOW")
            customAtom := root.winfo_atom("STDLIB_AHK_TEST_ATOM")
            AhkTest.AssertTrue(atom is Integer)
            AhkTest.AssertTrue(customAtom is Integer)
            AhkTest.AssertEqual("WM_DELETE_WINDOW", root.winfo_atomname(atom))
            AhkTest.AssertEqual("STDLIB_AHK_TEST_ATOM", frame.winfo_atomname(customAtom))
            AhkTest.AssertEqual(atom, root.winfo_atom("WM_DELETE_WINDOW", stdlib.None))
            AhkTest.AssertEqual(atom, label.winfo_atom("WM_DELETE_WINDOW", root))
            AhkTest.AssertEqual("WM_DELETE_WINDOW", label.winfo_atomname(atom, stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple(), root.winfo_interps())
            AhkTest.AssertEqual(stdlib.tuple(), label.winfo_interps(root))

            rootId := root.eval("winfo id .")
            frameId := root.eval("winfo id " String(frame))
            labelId := root.eval("winfo id " String(label))
            AhkTest.AssertEqual(".", root.winfo_pathname(rootId))
            AhkTest.AssertEqual(".atom_host", root.winfo_pathname(frameId))
            AhkTest.AssertEqual(".atom_host.caption", label.winfo_pathname(labelId, root))
            AhkTest.AssertEqual(".", label.winfo_pathname(rootId, stdlib.None))

            rootHit := root.winfo_containing(root.winfo_rootx() + 2, root.winfo_rooty() + 2)
            labelHit := root.winfo_containing(label.winfo_rootx() + 1, label.winfo_rooty() + 1)
            AhkTest.AssertSame(root, rootHit)
            AhkTest.AssertSame(label, labelHit)
            AhkTest.AssertSame(label, label.winfo_containing(label.winfo_rootx() + 1, label.winfo_rooty() + 1, stdlib.None))
            AhkTest.AssertSame(label, label.winfo_containing(label.winfo_rootx() + 1, label.winfo_rooty() + 1, root))
            AhkTest.AssertSame(stdlib.None, root.winfo_containing(-10000, -10000))

            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_atom\(\) missing 1 required positional argument: 'name'$", (*) => root.winfo_atom())
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_atom\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => root.winfo_atom("WM_DELETE_WINDOW", root, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_atomname\(\) missing 1 required positional argument: 'id'$", (*) => root.winfo_atomname())
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_atomname\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => root.winfo_atomname(atom, root, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_interps\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.winfo_interps(root, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_pathname\(\) missing 1 required positional argument: 'id'$", (*) => root.winfo_pathname())
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_pathname\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => root.winfo_pathname(rootId, root, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_containing\(\) missing 2 required positional arguments: 'rootX' and 'rootY'$", (*) => root.winfo_containing())
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_containing\(\) missing 1 required positional argument: 'rootY'$", (*) => root.winfo_containing(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_containing\(\) takes from 3 to 4 positional arguments but 5 were given$", (*) => root.winfo_containing(1, 2, root, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => root.winfo_atomname("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => root.winfo_pathname("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => root.winfo_containing("bad", 1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWidgetIdentityTreeSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            frame := stdlib.tkinter.Frame(root, { name: "host" })
            label := stdlib.tkinter.Label(root, { text: "Hello" })
            button := stdlib.tkinter.Button(frame, { name: "press", text: "Press" })
            top := stdlib.tkinter.Toplevel(root, { name: "dialog" })
            child := stdlib.tkinter.Label(top, { name: "inner", text: "Inside" })
            AhkTest.AssertEqual(stdlib.None, frame.pack())
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, button.pack())
            AhkTest.AssertEqual(stdlib.None, child.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual("Tk", root.winfo_class())
            AhkTest.AssertEqual("tk", root.winfo_name())
            AhkTest.AssertEqual("", root.winfo_parent())
            AhkTest.AssertEqual("Frame", frame.winfo_class())
            AhkTest.AssertEqual("host", frame.winfo_name())
            AhkTest.AssertEqual(".", frame.winfo_parent())
            AhkTest.AssertEqual("Label", label.winfo_class())
            AhkTest.AssertEqual("!label", label.winfo_name())
            AhkTest.AssertEqual(".", label.winfo_parent())
            AhkTest.AssertEqual("Button", button.winfo_class())
            AhkTest.AssertEqual("press", button.winfo_name())
            AhkTest.AssertEqual(".host", button.winfo_parent())
            AhkTest.AssertEqual("Toplevel", top.winfo_class())
            AhkTest.AssertEqual("dialog", top.winfo_name())
            AhkTest.AssertEqual(".", top.winfo_parent())
            AhkTest.AssertEqual("Label", child.winfo_class())
            AhkTest.AssertEqual("inner", child.winfo_name())
            AhkTest.AssertEqual(".dialog", child.winfo_parent())

            rootChildren := root.winfo_children()
            AhkTest.AssertEqual(3, rootChildren.Length)
            AhkTest.AssertSame(frame, rootChildren[1])
            AhkTest.AssertSame(label, rootChildren[2])
            AhkTest.AssertSame(top, rootChildren[3])
            frameChildren := frame.winfo_children()
            AhkTest.AssertEqual(1, frameChildren.Length)
            AhkTest.AssertSame(button, frameChildren[1])
            AhkTest.AssertEqual([], label.winfo_children())
            topChildren := top.winfo_children()
            AhkTest.AssertEqual(1, topChildren.Length)
            AhkTest.AssertSame(child, topChildren[1])

            AhkTest.AssertEqual(stdlib.None, label.destroy())
            rootChildrenAfterDestroy := root.winfo_children()
            AhkTest.AssertEqual(2, rootChildrenAfterDestroy.Length)
            AhkTest.AssertSame(frame, rootChildrenAfterDestroy[1])
            AhkTest.AssertSame(top, rootChildrenAfterDestroy[2])
            AhkTest.AssertEqual(0, label.winfo_exists())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.!label"$', (*) => label.winfo_class())

            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_children\(\) takes 1 positional argument but 2 were given$", (*) => frame.winfo_children(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_class\(\) takes 1 positional argument but 2 were given$", (*) => frame.winfo_class(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_name\(\) takes 1 positional argument but 2 were given$", (*) => frame.winfo_name(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_parent\(\) takes 1 positional argument but 2 were given$", (*) => frame.winfo_parent(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkNameToWidgetMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            frame := stdlib.tkinter.Frame(root, { name: "host" })
            label := stdlib.tkinter.Label(root, { name: "named_label" })
            button := stdlib.tkinter.Button(frame, { name: "press" })
            top := stdlib.tkinter.Toplevel(root, { name: "dialog" })
            child := stdlib.tkinter.Label(top, { name: "inner" })

            AhkTest.AssertSame(root, root.nametowidget("."))
            AhkTest.AssertSame(frame, root.nametowidget("host"))
            AhkTest.AssertSame(frame, root.nametowidget(".host"))
            AhkTest.AssertSame(button, root.nametowidget(".host.press"))
            AhkTest.AssertSame(button, frame.nametowidget("press"))
            AhkTest.AssertSame(button, frame.nametowidget(".host.press"))
            AhkTest.AssertSame(child, top.nametowidget("inner"))
            AhkTest.AssertSame(child, root.nametowidget(".dialog.inner"))
            AhkTest.AssertSame(root, label.nametowidget("."))

            AhkTest.RaisesMatch(KeyError, "^'missing'$", (*) => root.nametowidget(".missing"))
            AhkTest.RaisesMatch(KeyError, "^'missing'$", (*) => root.nametowidget(".host.missing"))
            AhkTest.RaisesMatch(KeyError, "^'missing'$", (*) => frame.nametowidget("missing"))
            AhkTest.RaisesMatch(KeyError, "^'1'$", (*) => root.nametowidget(1))
            AhkTest.AssertEqual(stdlib.None, label.destroy())
            AhkTest.RaisesMatch(KeyError, "^'named_label'$", (*) => root.nametowidget(".named_label"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.nametowidget\(\) missing 1 required positional argument: 'name'$", (*) => root.nametowidget())
            AhkTest.RaisesMatch(TypeError, "^Misc\.nametowidget\(\) takes 2 positional arguments but 3 were given$", (*) => root.nametowidget(".", "extra"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWindowResizableMinMaxSizeMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "dialog" })
            AhkTest.AssertEqual("", top.withdraw())

            AhkTest.AssertEqual(stdlib.tuple([1, 1]), root.resizable())
            AhkTest.AssertEqual("", root.resizable(stdlib.False, stdlib.True))
            AhkTest.AssertEqual(stdlib.tuple([0, 1]), root.resizable())
            AhkTest.AssertEqual("", root.resizable(1, 0))
            AhkTest.AssertEqual(stdlib.tuple([1, 0]), root.resizable())
            AhkTest.AssertEqual(stdlib.tuple([1, 1]), root.minsize())
            AhkTest.AssertEqual(stdlib.None, root.minsize(120, 80))
            AhkTest.AssertEqual(stdlib.tuple([120, 80]), root.minsize())
            AhkTest.AssertEqual(stdlib.None, root.maxsize(500, 400))
            AhkTest.AssertEqual(stdlib.tuple([500, 400]), root.maxsize())

            AhkTest.AssertEqual(stdlib.tuple([1, 1]), top.resizable())
            AhkTest.AssertEqual("", top.resizable(stdlib.False, stdlib.False))
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), top.resizable())
            AhkTest.AssertEqual(stdlib.None, top.minsize(90, 60))
            AhkTest.AssertEqual(stdlib.tuple([90, 60]), top.minsize())
            AhkTest.AssertEqual(stdlib.None, top.maxsize(300, 200))
            AhkTest.AssertEqual(stdlib.tuple([300, 200]), top.maxsize())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm resizable window \?width height\?"$', (*) => root.resizable(stdlib.False))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_resizable\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => root.resizable(stdlib.True, stdlib.True, stdlib.True))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected boolean value but got "maybe"$', (*) => root.resizable("maybe", stdlib.True))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm minsize window \?width height\?"$', (*) => root.minsize(1))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_minsize\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => root.minsize(1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => root.minsize("bad", 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm maxsize window \?width height\?"$', (*) => root.maxsize(1))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_maxsize\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => root.maxsize(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_resizable\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => top.resizable(stdlib.True, stdlib.True, stdlib.True))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_minsize\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => top.minsize(1, 2, 3))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWidgetBindAndEventGenerateMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.geometry("240x120+20+30"))
            label := stdlib.tkinter.Label(root, { name: "caption", text: "Click" })
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            recorder := StdlibTkinterTest.EventRecorder("handled")
            extra := StdlibTkinterTest.EventRecorder(stdlib.None, "extra")

            commandName := label.bind("<Button-1>", recorder)
            AhkTest.AssertTrue(commandName != "")
            AhkTest.AssertTrue(InStr(label.bind("<Button-1>"), commandName) > 0)
            AhkTest.AssertEqual(stdlib.tuple(["<Button-1>"]), label.bind())
            AhkTest.AssertEqual("", label.bind("<Key>"))
            AhkTest.AssertEqual(stdlib.None, label.event_generate("<Button-1>", { x: 7, y: 8 }))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(1, recorder.Calls.Length)
            event := recorder.Calls[1]
            AhkTest.AssertEqual("Event", Type(event))
            AhkTest.AssertSame(label, event.widget)
            AhkTest.AssertEqual("ButtonPress", event.type.name)
            AhkTest.AssertEqual(7, event.x)
            AhkTest.AssertEqual(8, event.y)
            AhkTest.AssertEqual(1, event.num)

            extraCommand := label.bind("<Button-1>", extra, "+")
            AhkTest.AssertTrue(extraCommand != "")
            AhkTest.AssertEqual(stdlib.None, label.event_generate("<Button-1>", { x: 9, y: 10 }))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(2, recorder.Calls.Length)
            AhkTest.AssertEqual(1, extra.Calls.Length)
            AhkTest.AssertEqual(9, recorder.Calls[2].x)
            AhkTest.AssertEqual(10, extra.Calls[1].y)
            AhkTest.AssertTrue(InStr(label.bind("<Button-1>"), extraCommand) > 0)
            AhkTest.AssertTrue(InStr(label.bind("<Button-1>", stdlib.None), commandName) > 0)
            AhkTest.AssertEqual(stdlib.None, label.event_generate("<Button-1>"))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(0, recorder.Calls[3].x)
            AhkTest.AssertEqual(0, extra.Calls[2].y)

            AhkTest.RaisesMatch(TypeError, "^Misc\.bind\(\) takes from 1 to 4 positional arguments but 5 were given$", (*) => label.bind("<Button-1>", recorder, "+", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.event_generate\(\) missing 1 required positional argument: 'sequence'$", (*) => label.event_generate())
            AhkTest.RaisesMatch(TypeError, "^Misc\.event_generate\(\) takes 2 positional arguments but 3 were given$", (*) => label.event_generate("<Button-1>", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad option "-bad": must be -when, -above, -borderwidth, -button, -count, -data, -delta, -detail, -focus, -height, -keycode, -keysym, -mode, -override, -place, -root, -rootx, -rooty, -sendevent, -serial, -state, -subwindow, -time, -warp, -width, -window, -x, or -y$', (*) => label.event_generate("<Button-1>", { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^only one event specification allowed$", (*) => label.event_generate("bad"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkBindClassAllAndUnbindSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.geometry("240x120+20+30"))
            label := stdlib.tkinter.Label(root, { name: "caption", text: "Click", width: 10, height: 2 })
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            widgetRecorder := StdlibTkinterTest.EventRecorder(stdlib.None, "widget")
            classRecorder := StdlibTkinterTest.EventRecorder(stdlib.None, "class")
            allRecorder := StdlibTkinterTest.EventRecorder(stdlib.None, "all")

            AhkTest.AssertContains("<<PrevWindow>>", root.bind_all())
            AhkTest.AssertEqual("", root.bind_all("<Button-1>"))
            AhkTest.AssertEqual(stdlib.tuple([]), root.bind_class("Label"))
            AhkTest.AssertEqual("", label.bind_class("Label", "<Button-1>"))

            allCommand := root.bind_all("<Button-1>", allRecorder)
            classCommand := label.bind_class("Label", "<Button-1>", classRecorder)
            widgetCommand := label.bind("<Button-1>", widgetRecorder)
            AhkTest.AssertTrue(allCommand != "")
            AhkTest.AssertTrue(classCommand != "")
            AhkTest.AssertTrue(widgetCommand != "")
            AhkTest.AssertTrue(InStr(root.bind_all("<Button-1>"), allCommand) > 0)
            AhkTest.AssertTrue(InStr(label.bind_class("Label", "<Button-1>"), classCommand) > 0)

            AhkTest.AssertEqual(stdlib.None, label.event_generate("<Button-1>", { x: 7, y: 8 }))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(1, widgetRecorder.Calls.Length)
            AhkTest.AssertEqual(1, classRecorder.Calls.Length)
            AhkTest.AssertEqual(1, allRecorder.Calls.Length)
            AhkTest.AssertSame(label, widgetRecorder.Calls[1].widget)
            AhkTest.AssertSame(label, classRecorder.Calls[1].widget)
            AhkTest.AssertSame(label, allRecorder.Calls[1].widget)

            AhkTest.AssertEqual(stdlib.None, label.unbind("<Button-1>", widgetCommand))
            AhkTest.AssertEqual("", label.bind("<Button-1>"))
            AhkTest.AssertEqual(stdlib.None, label.event_generate("<Button-1>", { x: 9, y: 10 }))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(1, widgetRecorder.Calls.Length)
            AhkTest.AssertEqual(2, classRecorder.Calls.Length)
            AhkTest.AssertEqual(2, allRecorder.Calls.Length)

            AhkTest.AssertEqual(stdlib.None, label.unbind_class("Label", "<Button-1>"))
            AhkTest.AssertEqual("", root.bind_class("Label", "<Button-1>"))
            AhkTest.AssertEqual(stdlib.None, label.event_generate("<Button-1>", { x: 11, y: 12 }))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(1, widgetRecorder.Calls.Length)
            AhkTest.AssertEqual(2, classRecorder.Calls.Length)
            AhkTest.AssertEqual(3, allRecorder.Calls.Length)

            AhkTest.AssertEqual(stdlib.None, root.unbind_all("<Button-1>"))
            AhkTest.AssertEqual("", label.bind_all("<Button-1>"))
            AhkTest.AssertEqual(stdlib.None, label.event_generate("<Button-1>", { x: 13, y: 14 }))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(1, widgetRecorder.Calls.Length)
            AhkTest.AssertEqual(2, classRecorder.Calls.Length)
            AhkTest.AssertEqual(3, allRecorder.Calls.Length)

            AhkTest.RaisesMatch(TypeError, "^Misc\.bind_all\(\) takes from 1 to 4 positional arguments but 5 were given$", (*) => root.bind_all("<Button-1>", allRecorder, "+", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.bind_class\(\) missing 1 required positional argument: 'className'$", (*) => root.bind_class())
            AhkTest.RaisesMatch(TypeError, "^Misc\.bind_class\(\) takes from 2 to 5 positional arguments but 6 were given$", (*) => root.bind_class("Label", "<Button-1>", classRecorder, "+", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.unbind\(\) missing 1 required positional argument: 'sequence'$", (*) => label.unbind())
            AhkTest.RaisesMatch(TypeError, "^Misc\.unbind\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => label.unbind("<Button-1>", widgetCommand, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.unbind_all\(\) missing 1 required positional argument: 'sequence'$", (*) => label.unbind_all())
            AhkTest.RaisesMatch(TypeError, "^Misc\.unbind_all\(\) takes 2 positional arguments but 3 were given$", (*) => label.unbind_all("<Button-1>", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.unbind_class\(\) missing 2 required positional arguments: 'className' and 'sequence'$", (*) => label.unbind_class())
            AhkTest.RaisesMatch(TypeError, "^Misc\.unbind_class\(\) missing 1 required positional argument: 'sequence'$", (*) => label.unbind_class("Label"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.unbind_class\(\) takes 3 positional arguments but 4 were given$", (*) => label.unbind_class("Label", "<Button-1>", classCommand))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkVirtualEventRegistryMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            label := stdlib.tkinter.Label(root, { name: "event_label", text: "Events" })

            AhkTest.AssertContains("<<Cut>>", root.event_info())
            AhkTest.AssertContains("<<Cut>>", label.event_info(stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple([]), label.event_info("<<StdlibMissing>>"))

            AhkTest.AssertEqual(stdlib.None, label.event_add("<<StdlibProbe>>", "<Button-1>", "<Key-a>"))
            AhkTest.AssertContains("<<StdlibProbe>>", label.event_info())
            AhkTest.AssertContains("<<StdlibProbe>>", root.event_info())
            AhkTest.AssertEqual(stdlib.tuple(["<Button-1>", "a"]), label.event_info("<<StdlibProbe>>"))
            AhkTest.AssertEqual(stdlib.tuple(["<Button-1>", "a"]), root.event_info("<<StdlibProbe>>"))

            AhkTest.AssertEqual(stdlib.None, label.event_add("<<StdlibProbe>>", "<Button-1>"))
            AhkTest.AssertEqual(stdlib.tuple(["<Button-1>", "a"]), label.event_info("<<StdlibProbe>>"))
            AhkTest.AssertEqual(stdlib.None, label.event_delete("<<StdlibProbe>>", "<Key-a>"))
            AhkTest.AssertEqual(stdlib.tuple(["<Button-1>"]), label.event_info("<<StdlibProbe>>"))
            AhkTest.AssertEqual(stdlib.None, root.event_delete("<<StdlibProbe>>", "<Button-1>"))
            AhkTest.AssertEqual(stdlib.tuple([]), label.event_info("<<StdlibProbe>>"))
            AhkTest.AssertEqual(stdlib.None, label.event_delete("<<StdlibProbe>>"))
            AhkTest.AssertEqual(stdlib.tuple([]), root.event_info("<<StdlibProbe>>"))

            AhkTest.RaisesMatch(TypeError, "^Misc\.event_add\(\) missing 1 required positional argument: 'virtual'$", (*) => label.event_add())
            AhkTest.RaisesMatch(TypeError, "^Misc\.event_delete\(\) missing 1 required positional argument: 'virtual'$", (*) => root.event_delete())
            AhkTest.RaisesMatch(TypeError, "^Misc\.event_info\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => label.event_info("<<A>>", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "event add virtual sequence \?sequence \.\.\.\?"$', (*) => label.event_add("<<NoSeq>>"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^virtual event "bad" is badly formed$', (*) => label.event_add("bad", "<Button-1>"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkBindtagsEventRoutingMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            frame := stdlib.tkinter.Frame(root, { name: "host" })
            label := stdlib.tkinter.Label(frame, { name: "caption", text: "Tags" })
            top := stdlib.tkinter.Toplevel(root, { name: "dialog" })
            top.withdraw()

            AhkTest.AssertEqual(stdlib.tuple([".", "Tk", "all"]), root.bindtags())
            AhkTest.AssertEqual(stdlib.tuple([".host", "Frame", ".", "all"]), frame.bindtags())
            AhkTest.AssertEqual(stdlib.tuple([".host.caption", "Label", ".", "all"]), label.bindtags())
            AhkTest.AssertEqual(stdlib.tuple([".dialog", "Toplevel", "all"]), top.bindtags())

            AhkTest.AssertEqual(stdlib.None, label.bindtags(stdlib.tuple(["Custom", ".host.caption", "all"])))
            AhkTest.AssertEqual(stdlib.tuple(["Custom", ".host.caption", "all"]), label.bindtags())
            AhkTest.AssertEqual(stdlib.None, label.bindtags([".host.caption", "Label", ".", "all"]))
            AhkTest.AssertEqual(stdlib.tuple([".host.caption", "Label", ".", "all"]), label.bindtags())
            AhkTest.AssertEqual(stdlib.None, label.bindtags(stdlib.tuple([])))
            AhkTest.AssertEqual(stdlib.tuple([".host.caption", "Label", ".", "all"]), label.bindtags())
            AhkTest.AssertEqual(stdlib.None, label.bindtags("abc"))
            AhkTest.AssertEqual(stdlib.tuple(["abc"]), label.bindtags())
            AhkTest.AssertEqual(stdlib.tuple(["abc"]), label.bindtags(stdlib.None))

            AhkTest.RaisesMatch(TypeError, "^Misc\.bindtags\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => label.bindtags(stdlib.tuple([]), stdlib.tuple([])))
            label.destroy()
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.host\.caption"$', (*) => label.bindtags())
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWidgetsSupportVisibleGuiSurfaceLikeLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")

            AhkTest.AssertEqual("tk", root.title())
            AhkTest.AssertEqual("", root.title("Stdlib Probe"))
            AhkTest.AssertEqual("Stdlib Probe", root.title())

            frame := stdlib.tkinter.Frame(root, { name: "host" })
            label := stdlib.tkinter.Label(root, { text: "Hello" })
            button := stdlib.tkinter.Button(frame, { text: "Press" })

            AhkTest.AssertEqual("Frame", Type(frame))
            AhkTest.AssertEqual("Label", Type(label))
            AhkTest.AssertEqual("Button", Type(button))
            AhkTest.AssertEqual(".host", String(frame))
            AhkTest.AssertEqual(".!label", String(label))
            AhkTest.AssertEqual(".host.!button", String(button))
            AhkTest.AssertSame(root, frame._root())
            AhkTest.AssertSame(root, label._root())
            AhkTest.AssertSame(root, button._root())
            AhkTest.AssertEqual(1, frame.winfo_exists())
            AhkTest.AssertEqual(1, label.winfo_exists())
            AhkTest.AssertEqual(1, button.winfo_exists())
            AhkTest.AssertEqual("Hello", label.cget("text"))
            AhkTest.AssertEqual(stdlib.None, label.configure({ text: "Changed" }))
            AhkTest.AssertEqual("Changed", label.cget("text"))
            AhkTest.AssertEqual("Press", button.cget("text"))
            AhkTest.AssertEqual(stdlib.None, frame.pack())
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, button.pack())
            AhkTest.AssertEqual("pack", frame.winfo_manager())
            AhkTest.AssertEqual("pack", label.winfo_manager())
            AhkTest.AssertEqual("pack", button.winfo_manager())
            AhkTest.AssertEqual(stdlib.None, label.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .!label"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkRootOptionConfigurationMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")

            AhkTest.AssertEqual(stdlib.None, root.configure({ bg: "#112233" }))
            AhkTest.AssertEqual("#112233", root.cget("bg"))
            AhkTest.AssertEqual(stdlib.None, root.config({ bg: "white" }))
            AhkTest.AssertEqual("white", root.cget("background"))

            AhkTest.RaisesMatch(TypeError, "^Misc\.cget\(\) missing 1 required positional argument: 'key'$", (*) => root.cget())
            AhkTest.RaisesMatch(TypeError, "^Misc\.cget\(\) takes 2 positional arguments but 3 were given$", (*) => root.cget("bg", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => root.cget("bad"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.configure\(\) takes from 1 to 2 positional arguments but 4 were given$", (*) => root.configure({}, {}, {}))
            AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => root.configure(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => root.configure({ bad: 1 }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWidgetOptionKeysMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            top := stdlib.tkinter.Toplevel(root, { name: "keys_top" })
            frame := stdlib.tkinter.Frame(root, { name: "keys_frame" })
            label := stdlib.tkinter.Label(root, { name: "keys_label", text: "Hi" })
            entry := stdlib.tkinter.Entry(root, { name: "keys_entry" })
            canvas := stdlib.tkinter.Canvas(root, { name: "keys_canvas" })
            menu := stdlib.tkinter.Menu(root, { name: "keys_menu", tearoff: 0 })

            rootKeys := ["bd", "borderwidth", "class", "menu", "relief", "screen", "use", "background", "bg", "colormap", "container", "cursor", "height", "highlightbackground", "highlightcolor", "highlightthickness", "padx", "pady", "takefocus", "visual", "width"]
            frameKeys := ["bd", "borderwidth", "class", "relief", "background", "bg", "colormap", "container", "cursor", "height", "highlightbackground", "highlightcolor", "highlightthickness", "padx", "pady", "takefocus", "visual", "width"]
            labelKeys := ["activebackground", "activeforeground", "anchor", "background", "bd", "bg", "bitmap", "borderwidth", "compound", "cursor", "disabledforeground", "fg", "font", "foreground", "height", "highlightbackground", "highlightcolor", "highlightthickness", "image", "justify", "padx", "pady", "relief", "state", "takefocus", "text", "textvariable", "underline", "width", "wraplength"]
            entryKeys := ["background", "bd", "bg", "borderwidth", "cursor", "disabledbackground", "disabledforeground", "exportselection", "fg", "font", "foreground", "highlightbackground", "highlightcolor", "highlightthickness", "insertbackground", "insertborderwidth", "insertofftime", "insertontime", "insertwidth", "invalidcommand", "invcmd", "justify", "readonlybackground", "relief", "selectbackground", "selectborderwidth", "selectforeground", "show", "state", "takefocus", "textvariable", "validate", "validatecommand", "vcmd", "width", "xscrollcommand"]
            canvasKeys := ["background", "bd", "bg", "borderwidth", "closeenough", "confine", "cursor", "height", "highlightbackground", "highlightcolor", "highlightthickness", "insertbackground", "insertborderwidth", "insertofftime", "insertontime", "insertwidth", "offset", "relief", "scrollregion", "selectbackground", "selectborderwidth", "selectforeground", "state", "takefocus", "width", "xscrollcommand", "xscrollincrement", "yscrollcommand", "yscrollincrement"]
            menuKeys := ["activebackground", "activeborderwidth", "activeforeground", "background", "bd", "bg", "borderwidth", "cursor", "disabledforeground", "fg", "font", "foreground", "postcommand", "relief", "selectcolor", "takefocus", "tearoff", "tearoffcommand", "title", "type"]

            AhkTest.AssertEqual(rootKeys, root.keys())
            AhkTest.AssertEqual(rootKeys, top.keys())
            AhkTest.AssertEqual(frameKeys, frame.keys())
            AhkTest.AssertEqual(labelKeys, label.keys())
            AhkTest.AssertEqual(entryKeys, entry.keys())
            AhkTest.AssertEqual(canvasKeys, canvas.keys())
            AhkTest.AssertEqual(menuKeys, menu.keys())

            AhkTest.RaisesMatch(TypeError, "^Misc\.keys\(\) takes 1 positional argument but 2 were given$", (*) => root.keys(1))
            AhkTest.AssertEqual(stdlib.None, label.destroy())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^invalid command name "\.keys_label"$', (*) => label.keys())
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestToplevelWindowSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            top := stdlib.tkinter.Toplevel(root, { name: "dialog", width: 120, height: 80, bg: "white" })

            AhkTest.AssertEqual("Toplevel", Type(top))
            AhkTest.AssertEqual(".dialog", String(top))
            AhkTest.AssertSame(root, top._root())
            AhkTest.AssertEqual(1, top.winfo_exists())
            AhkTest.AssertEqual("wm", top.winfo_manager())
            AhkTest.AssertEqual(120, top.cget("width"))
            AhkTest.AssertEqual(80, top.cget("height"))
            AhkTest.AssertEqual("white", top.cget("bg"))
            AhkTest.AssertEqual("tk", top.title())
            AhkTest.AssertEqual("", top.title("Dialog Title"))
            AhkTest.AssertEqual("Dialog Title", top.title())
            AhkTest.AssertEqual("normal", top.state())
            AhkTest.AssertEqual("", top.withdraw())
            AhkTest.AssertEqual("withdrawn", top.state())
            AhkTest.AssertEqual("", top.deiconify())
            AhkTest.AssertEqual("normal", top.state())
            child := stdlib.tkinter.Label(top, { text: "Inside" })
            AhkTest.AssertEqual(".dialog.!label", String(child))
            AhkTest.AssertSame(root, child._root())
            AhkTest.AssertEqual("Inside", child.cget("text"))
            AhkTest.AssertEqual(stdlib.None, top.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .dialog"))

            AhkTest.AssertEqual(".kw", String(stdlib.tkinter.Toplevel({ master: root, name: "kw" })))
            AhkTest.AssertEqual(50, stdlib.tkinter.Toplevel(root, { name: "cnf", width: 50 }).cget("width"))
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.Toplevel({ master: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Toplevel\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Toplevel(root, {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-extra_kw"$', (*) => stdlib.tkinter.Toplevel(root, { extra_kw: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_title\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Toplevel(root).title("a", "b"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_state\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Toplevel(root).state("normal", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_withdraw\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Toplevel(root).withdraw(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestListboxSelectionAndItemSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            listbox := stdlib.tkinter.Listbox(root, { name: "choices", height: 4, width: 12, selectmode: "extended" })

            AhkTest.AssertEqual("Listbox", Type(listbox))
            AhkTest.AssertEqual(".choices", String(listbox))
            AhkTest.AssertSame(root, listbox._root())
            AhkTest.AssertEqual(1, listbox.winfo_exists())
            AhkTest.AssertEqual(4, listbox.cget("height"))
            AhkTest.AssertEqual(12, listbox.cget("width"))
            AhkTest.AssertEqual("extended", listbox.cget("selectmode"))
            AhkTest.AssertEqual(0, listbox.size())
            AhkTest.AssertEqual("", listbox.get(0))
            AhkTest.AssertEqual(stdlib.None, listbox.insert("end", "alpha", "beta"))
            AhkTest.AssertEqual(stdlib.None, listbox.insert(1, "gamma"))
            AhkTest.AssertEqual(stdlib.None, listbox.insert("end"))
            AhkTest.AssertEqual(3, listbox.size())
            AhkTest.AssertEqual("alpha", listbox.get(0))
            AhkTest.AssertEqual(stdlib.tuple(["alpha", "gamma", "beta"]), listbox.get(0, "end"))
            AhkTest.AssertEqual(stdlib.tuple(["gamma", "beta"]), listbox.get(1, 2))
            AhkTest.AssertEqual(3, listbox.index("end"))
            AhkTest.AssertEqual(stdlib.None, listbox.selection_set(0, 1))
            AhkTest.AssertEqual(stdlib.tuple([0, 1]), listbox.curselection())
            AhkTest.AssertSame(stdlib.True, listbox.selection_includes(0))
            AhkTest.AssertSame(stdlib.False, listbox.selection_includes(2))
            AhkTest.AssertEqual(stdlib.None, listbox.selection_clear(0))
            AhkTest.AssertEqual(stdlib.tuple([1]), listbox.curselection())
            AhkTest.AssertEqual(stdlib.None, listbox.delete(1))
            AhkTest.AssertEqual(stdlib.tuple(["alpha", "beta"]), listbox.get(0, "end"))
            AhkTest.AssertEqual(stdlib.None, listbox.delete(0, "end"))
            AhkTest.AssertEqual(0, listbox.size())
            AhkTest.AssertEqual(stdlib.tuple(), listbox.curselection())
            AhkTest.AssertEqual(stdlib.None, listbox.pack())
            AhkTest.AssertEqual("pack", listbox.winfo_manager())
            AhkTest.AssertEqual(stdlib.None, listbox.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .choices"))

            AhkTest.AssertEqual(".kw", String(stdlib.tkinter.Listbox({ master: root, name: "kw" })))
            AhkTest.AssertEqual(3, stdlib.tkinter.Listbox(root, { name: "cnf", height: 3 }).cget("height"))
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.Listbox({ master: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Listbox(root, {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-extra_kw"$', (*) => stdlib.tkinter.Listbox(root, { extra_kw: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.insert\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Listbox(root).insert())
            AhkTest.RaisesMatch(TypeError, "^Listbox\.get\(\) missing 1 required positional argument: 'first'$", (*) => stdlib.tkinter.Listbox(root).get())
            AhkTest.RaisesMatch(TypeError, "^Listbox\.get\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Listbox(root).get(0, 1, 2))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.delete\(\) missing 1 required positional argument: 'first'$", (*) => stdlib.tkinter.Listbox(root).delete())
            AhkTest.RaisesMatch(TypeError, "^Listbox\.size\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Listbox(root).size(1))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.curselection\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Listbox(root).curselection(1))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.selection_set\(\) missing 1 required positional argument: 'first'$", (*) => stdlib.tkinter.Listbox(root).selection_set())
            AhkTest.RaisesMatch(TypeError, "^Listbox\.selection_includes\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Listbox(root).selection_includes())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad listbox index "bad": must be active, anchor, end, @x,y, or a number$', (*) => stdlib.tkinter.Listbox(root).selection_includes("bad"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestButtonCommandInvokeMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            noneCommand := StdlibTkinterTest.CommandRecorder(stdlib.None, "none")
            strCommand := StdlibTkinterTest.CommandRecorder("done", "str")
            noCommandButton := stdlib.tkinter.Button(root, { text: "No command" })
            noneButton := stdlib.tkinter.Button(root, { text: "None command", command: noneCommand })
            strButton := stdlib.tkinter.Button(root, { text: "String command", command: strCommand })

            AhkTest.AssertEqual("", noCommandButton.cget("command"))
            AhkTest.AssertTrue(noneButton.cget("command") != "")
            AhkTest.AssertTrue(strButton.cget("command") != "")
            AhkTest.AssertEqual("", noCommandButton.invoke())
            AhkTest.AssertEqual([], noneCommand.Calls)
            AhkTest.AssertEqual("None", noneButton.invoke())
            AhkTest.AssertEqual(["none"], noneCommand.Calls)
            AhkTest.AssertEqual("done", strButton.invoke())
            AhkTest.AssertEqual(["str"], strCommand.Calls)
            AhkTest.AssertEqual(stdlib.None, noCommandButton.configure({ command: strCommand }))
            AhkTest.AssertEqual("done", noCommandButton.invoke())
            AhkTest.AssertEqual(["str", "str"], strCommand.Calls)

            badButton := stdlib.tkinter.Button(root, { command: 1 })
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^invalid command name " Chr(34) "1" Chr(34) "$", (*) => badButton.invoke())
            AhkTest.RaisesMatch(TypeError, "^Button\.invoke\(\) takes 1 positional argument but 2 were given$", (*) => strButton.invoke(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestAfterMainloopAndQuitMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            noneCommand := StdlibTkinterTest.CommandRecorder(stdlib.None, "none")
            strCommand := StdlibTkinterTest.CommandRecorder("done", "str")
            quitCommand := StdlibTkinterTest.QuitRecorder(root, "mainloop")

            AhkTest.AssertEqual(stdlib.None, root.quit())
            AhkTest.RaisesMatch(TypeError, "^Misc\.quit\(\) takes 1 positional argument but 2 were given$", (*) => root.quit(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.after\(\) missing 1 required positional argument: 'ms'$", (*) => root.after())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad argument "bad": must be cancel, idle, info, or an integer$', (*) => root.after("bad"))
            AhkTest.AssertEqual(stdlib.None, root.after(0))

            noneId := root.after(0, noneCommand)
            strId := root.after(0, strCommand, "x")
            AhkTest.AssertRegex(noneId, "^after#[0-9]+$")
            AhkTest.AssertRegex(strId, "^after#[0-9]+$")
            AhkTest.AssertEqual([], noneCommand.Calls)
            AhkTest.AssertEqual([], strCommand.Calls)
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(["none"], noneCommand.Calls)
            AhkTest.AssertEqual(["str:x"], strCommand.Calls)

            cancelId := root.after(1000, StdlibTkinterTest.CommandRecorder(stdlib.None, "cancelled"))
            AhkTest.AssertEqual(stdlib.None, root.after_cancel(cancelId))
            AhkTest.AssertEqual(stdlib.None, root.after_cancel("missing"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.after_cancel\(\) missing 1 required positional argument: 'id'$", (*) => root.after_cancel())

            AhkTest.AssertRegex(root.after(0, quitCommand), "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, root.mainloop())
            AhkTest.AssertEqual(["mainloop"], quitCommand.Calls)
            AhkTest.RaisesMatch(TypeError, "^Misc\.mainloop\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.mainloop(0, 1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkAfterIdleCallbacksMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            label := stdlib.tkinter.Label(root, { name: "idle_label", text: "Idle" })
            rootIdle := StdlibTkinterTest.CommandRecorder(stdlib.None, "idle")
            argIdle := StdlibTkinterTest.CommandRecorder("ignored", "arg")
            widgetIdle := StdlibTkinterTest.CommandRecorder(stdlib.None, "widget")
            cancelledIdle := StdlibTkinterTest.CommandRecorder(stdlib.None, "cancelled")

            AhkTest.RaisesMatch(TypeError, "^Misc\.after_idle\(\) missing 1 required positional argument: 'func'$", (*) => root.after_idle())
            rootIdleId := root.after_idle(rootIdle)
            argIdleId := root.after_idle(argIdle, "x")
            widgetIdleId := label.after_idle(widgetIdle)
            AhkTest.AssertRegex(rootIdleId, "^after#[0-9]+$")
            AhkTest.AssertRegex(argIdleId, "^after#[0-9]+$")
            AhkTest.AssertRegex(widgetIdleId, "^after#[0-9]+$")
            AhkTest.AssertEqual([], rootIdle.Calls)
            AhkTest.AssertEqual([], argIdle.Calls)
            AhkTest.AssertEqual([], widgetIdle.Calls)

            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(["idle"], rootIdle.Calls)
            AhkTest.AssertEqual(["arg:x"], argIdle.Calls)
            AhkTest.AssertEqual(["widget"], widgetIdle.Calls)

            cancelId := root.after_idle(cancelledIdle)
            AhkTest.AssertRegex(cancelId, "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, root.after_cancel(cancelId))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual([], cancelledIdle.Calls)
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWindowProtocolCallbacksMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            rootCommand := StdlibTkinterTest.CommandRecorder("root-result", "root-protocol")
            topCommand := StdlibTkinterTest.CommandRecorder(stdlib.None, "top-protocol")

            AhkTest.AssertEqual(stdlib.tuple(["WM_DELETE_WINDOW"]), root.protocol())
            AhkTest.AssertTrue(root.protocol("WM_DELETE_WINDOW") != "")
            AhkTest.AssertEqual("", root.protocol("WM_DELETE_WINDOW", rootCommand))
            rootProtocolCommand := root.protocol("WM_DELETE_WINDOW")
            AhkTest.AssertTrue(rootProtocolCommand != "")
            AhkTest.AssertEqual("root-result", root.eval(rootProtocolCommand))
            AhkTest.AssertEqual(["root-protocol"], rootCommand.Calls)
            AhkTest.AssertEqual("", root.wm_protocol("WM_DELETE_WINDOW", ""))
            AhkTest.AssertEqual("", root.protocol("WM_DELETE_WINDOW"))

            top := stdlib.tkinter.Toplevel(root, { name: "protocol_dialog" })
            AhkTest.AssertEqual(stdlib.tuple(["WM_DELETE_WINDOW"]), top.protocol())
            AhkTest.AssertTrue(top.protocol("WM_DELETE_WINDOW") != "")
            AhkTest.AssertEqual("", top.protocol("WM_DELETE_WINDOW", topCommand))
            topProtocolCommand := top.wm_protocol("WM_DELETE_WINDOW")
            AhkTest.AssertTrue(topProtocolCommand != "")
            AhkTest.AssertEqual("None", root.eval(topProtocolCommand))
            AhkTest.AssertEqual(["top-protocol"], topCommand.Calls)
            AhkTest.AssertEqual("", top.protocol("WM_TAKE_FOCUS"))
            AhkTest.AssertEqual("", top.protocol("WM_DELETE_WINDOW", 1))
            AhkTest.AssertEqual("1", top.protocol("WM_DELETE_WINDOW"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^invalid command name " Chr(34) "1" Chr(34) "$", (*) => root.eval(top.protocol("WM_DELETE_WINDOW")))

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_protocol\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => root.protocol("WM_DELETE_WINDOW", rootCommand, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_protocol\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => top.wm_protocol("WM_DELETE_WINDOW", topCommand, "extra"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkFocusQueriesMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.geometry("220x120+40+50"))
            entry := stdlib.tkinter.Entry(root, { name: "field" })
            button := stdlib.tkinter.Button(root, { name: "press", text: "Press" })
            AhkTest.AssertEqual(stdlib.None, entry.pack())
            AhkTest.AssertEqual(stdlib.None, button.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual(stdlib.None, entry.focus_set())
            AhkTest.AssertEqual(stdlib.None, entry.focus_force())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertSame(entry, root.focus_get())
            AhkTest.AssertSame(entry, entry.focus_displayof())
            AhkTest.AssertEqual(stdlib.None, button.focus_force())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertSame(button, root.focus_get())
            AhkTest.AssertSame(button, button.focus_displayof())
            AhkTest.AssertEqual("", root.withdraw())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertSame(stdlib.None, root.focus_get())

            AhkTest.RaisesMatch(TypeError, "^Misc\.focus_get\(\) takes 1 positional argument but 2 were given$", (*) => root.focus_get(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.focus_set\(\) takes 1 positional argument but 2 were given$", (*) => entry.focus_set(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.focus_force\(\) takes 1 positional argument but 2 were given$", (*) => button.focus_force(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.focus_displayof\(\) takes 1 positional argument but 2 were given$", (*) => button.focus_displayof(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCheckbuttonVariableAndInvokeSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            calls := []
            command := (*) => (calls.Push("cmd"), "done")
            value := stdlib.tkinter.StringVar(root, "off", "check_var")
            check := stdlib.tkinter.Checkbutton(root, { name: "agree", text: "Agree", variable: value, onvalue: "yes", offvalue: "no", command: command })

            AhkTest.AssertEqual("Checkbutton", Type(check))
            AhkTest.AssertEqual(".agree", String(check))
            AhkTest.AssertSame(root, check._root())
            AhkTest.AssertEqual(1, check.winfo_exists())
            AhkTest.AssertEqual("Agree", check.cget("text"))
            AhkTest.AssertEqual("check_var", check.cget("variable"))
            AhkTest.AssertEqual("yes", check.cget("onvalue"))
            AhkTest.AssertEqual("no", check.cget("offvalue"))
            AhkTest.AssertTrue(check.cget("command") != "")
            AhkTest.AssertEqual("off", value.get())
            AhkTest.AssertEqual(stdlib.None, check.select())
            AhkTest.AssertEqual("yes", value.get())
            AhkTest.AssertEqual(stdlib.None, check.deselect())
            AhkTest.AssertEqual("no", value.get())
            AhkTest.AssertEqual(stdlib.None, check.toggle())
            AhkTest.AssertEqual("yes", value.get())
            AhkTest.AssertEqual("done", check.invoke())
            AhkTest.AssertEqual("no", value.get())
            AhkTest.AssertEqual(["cmd"], calls)
            AhkTest.AssertEqual(stdlib.None, check.pack())
            AhkTest.AssertEqual("pack", check.winfo_manager())
            AhkTest.AssertEqual(stdlib.None, check.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .agree"))

            noCommand := stdlib.tkinter.Checkbutton(root)
            AhkTest.AssertEqual("", noCommand.invoke())
            AhkTest.AssertEqual("", noCommand.invoke())
            noneButton := stdlib.tkinter.Checkbutton(root, { command: (*) => stdlib.None })
            AhkTest.AssertEqual("None", noneButton.invoke())
            strButton := stdlib.tkinter.Checkbutton(root, { command: (*) => "value" })
            AhkTest.AssertEqual("value", strButton.invoke())
            badButton := stdlib.tkinter.Checkbutton(root, { command: 1 })
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^invalid command name " Chr(34) "1" Chr(34) "$", (*) => badButton.invoke())
            AhkTest.AssertEqual(".kw", String(stdlib.tkinter.Checkbutton({ master: root, name: "kw" })))
            AhkTest.AssertEqual("CNF", stdlib.tkinter.Checkbutton(root, { name: "cnf", text: "CNF" }).cget("text"))
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.Checkbutton({ master: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Checkbutton\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Checkbutton(root, {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-extra_kw"$', (*) => stdlib.tkinter.Checkbutton(root, { extra_kw: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Checkbutton\.invoke\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Checkbutton(root).invoke(1))
            AhkTest.RaisesMatch(TypeError, "^Checkbutton\.select\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Checkbutton(root).select(1))
            AhkTest.RaisesMatch(TypeError, "^Checkbutton\.deselect\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Checkbutton(root).deselect(1))
            AhkTest.RaisesMatch(TypeError, "^Checkbutton\.toggle\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Checkbutton(root).toggle(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestRadiobuttonVariableAndInvokeSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            calls := []
            command := (*) => (calls.Push("cmd"), "done")
            value := stdlib.tkinter.StringVar(root, "none", "radio_var")
            radio := stdlib.tkinter.Radiobutton(root, { name: "choice", text: "Choice A", variable: value, value: "A", command: command })

            AhkTest.AssertEqual("Radiobutton", Type(radio))
            AhkTest.AssertEqual(".choice", String(radio))
            AhkTest.AssertSame(root, radio._root())
            AhkTest.AssertEqual(1, radio.winfo_exists())
            AhkTest.AssertEqual("Choice A", radio.cget("text"))
            AhkTest.AssertEqual("radio_var", radio.cget("variable"))
            AhkTest.AssertEqual("A", radio.cget("value"))
            AhkTest.AssertTrue(radio.cget("command") != "")
            AhkTest.AssertEqual("none", value.get())
            AhkTest.AssertEqual(stdlib.None, radio.select())
            AhkTest.AssertEqual("A", value.get())
            AhkTest.AssertEqual(stdlib.None, radio.deselect())
            AhkTest.AssertEqual("", value.get())
            AhkTest.AssertEqual(stdlib.None, radio.flash())
            AhkTest.AssertEqual("done", radio.invoke())
            AhkTest.AssertEqual("A", value.get())
            AhkTest.AssertEqual(["cmd"], calls)
            AhkTest.AssertEqual(stdlib.None, radio.pack())
            AhkTest.AssertEqual("pack", radio.winfo_manager())
            AhkTest.AssertEqual(stdlib.None, radio.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .choice"))

            noCommand := stdlib.tkinter.Radiobutton(root)
            AhkTest.AssertEqual("", noCommand.invoke())
            noneButton := stdlib.tkinter.Radiobutton(root, { command: (*) => stdlib.None })
            AhkTest.AssertEqual("None", noneButton.invoke())
            strButton := stdlib.tkinter.Radiobutton(root, { command: (*) => "value" })
            AhkTest.AssertEqual("value", strButton.invoke())
            badButton := stdlib.tkinter.Radiobutton(root, { command: 1 })
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^invalid command name " Chr(34) "1" Chr(34) "$", (*) => badButton.invoke())
            AhkTest.AssertEqual(".kw", String(stdlib.tkinter.Radiobutton({ master: root, name: "kw" })))
            AhkTest.AssertEqual("CNF", stdlib.tkinter.Radiobutton(root, { name: "cnf", text: "CNF" }).cget("text"))
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.Radiobutton({ master: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Radiobutton\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Radiobutton(root, {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-extra_kw"$', (*) => stdlib.tkinter.Radiobutton(root, { extra_kw: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Radiobutton\.invoke\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Radiobutton(root).invoke(1))
            AhkTest.RaisesMatch(TypeError, "^Radiobutton\.select\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Radiobutton(root).select(1))
            AhkTest.RaisesMatch(TypeError, "^Radiobutton\.deselect\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Radiobutton(root).deselect(1))
            AhkTest.RaisesMatch(TypeError, "^Radiobutton\.flash\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Radiobutton(root).flash(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestScaleNumericControlSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            calls := []
            command := (current) => (calls.Push([current, Type(current)]), "done")
            value := stdlib.tkinter.DoubleVar(root, 2.0, "scale_var")
            scale := stdlib.tkinter.Scale(root, { name: "volume", from_: 0, to: 10, orient: "horizontal", resolution: 0.5, variable: value, command: command, length: 120, label: "Volume" })

            AhkTest.AssertEqual("Scale", Type(scale))
            AhkTest.AssertEqual(".volume", String(scale))
            AhkTest.AssertSame(root, scale._root())
            AhkTest.AssertEqual(1, scale.winfo_exists())
            AhkTest.AssertEqual(0.0, scale.cget("from"))
            AhkTest.AssertEqual(10.0, scale.cget("to"))
            AhkTest.AssertEqual("horizontal", scale.cget("orient"))
            AhkTest.AssertEqual(0.5, scale.cget("resolution"))
            AhkTest.AssertEqual("scale_var", scale.cget("variable"))
            AhkTest.AssertTrue(scale.cget("command") != "")
            AhkTest.AssertEqual(120, scale.cget("length"))
            AhkTest.AssertEqual("Volume", scale.cget("label"))
            AhkTest.AssertEqual(2.0, scale.get())
            AhkTest.AssertEqual(2.0, value.get())
            AhkTest.AssertEqual(stdlib.None, scale.set(4.5))
            AhkTest.AssertEqual(4.5, scale.get())
            AhkTest.AssertEqual(4.5, value.get())
            AhkTest.AssertEqual([], calls)
            AhkTest.AssertEqual("done", root.eval(scale.cget("command") " 7.5"))
            AhkTest.AssertEqual([["7.5", "String"]], calls)
            coords := scale.coords()
            AhkTest.AssertEqual(2, coords.Length)
            AhkTest.AssertTrue(coords[1] is Integer)
            AhkTest.AssertTrue(coords[2] is Integer)
            AhkTest.AssertEqual(coords, scale.coords(5))
            AhkTest.AssertEqual("", scale.identify(10, 10))
            AhkTest.AssertEqual(stdlib.None, scale.pack())
            AhkTest.AssertEqual("pack", scale.winfo_manager())
            AhkTest.AssertEqual(stdlib.None, scale.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .volume"))

            AhkTest.AssertEqual(".kw", String(stdlib.tkinter.Scale({ master: root, name: "kw" })))
            AhkTest.AssertEqual(1.0, stdlib.tkinter.Scale(root, { name: "cnf", from_: 1, to: 3 }).cget("from"))
            AhkTest.AssertEqual(3.0, stdlib.tkinter.Scale(root, { name: "cnf2", from_: 1, to: 3 }).cget("to"))
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.Scale({ master: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Scale\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Scale(root, {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-extra_kw"$', (*) => stdlib.tkinter.Scale(root, { extra_kw: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Scale\.get\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Scale(root).get(1))
            AhkTest.RaisesMatch(TypeError, "^Scale\.set\(\) missing 1 required positional argument: 'value'$", (*) => stdlib.tkinter.Scale(root).set())
            AhkTest.RaisesMatch(TypeError, "^Scale\.set\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Scale(root).set(1, 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected floating-point number but got "bad"$', (*) => stdlib.tkinter.Scale(root).set("bad"))
            AhkTest.RaisesMatch(TypeError, "^Scale\.coords\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Scale(root).coords(1, 2))
            AhkTest.RaisesMatch(TypeError, "^Scale\.identify\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => stdlib.tkinter.Scale(root).identify())
            AhkTest.RaisesMatch(TypeError, "^Scale\.identify\(\) missing 1 required positional argument: 'y'$", (*) => stdlib.tkinter.Scale(root).identify(1))
            AhkTest.RaisesMatch(TypeError, "^Scale\.identify\(\) takes 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Scale(root).identify(1, 2, 3))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestScrollbarControlSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            calls := []
            command := (args*) => (calls.Push(args), "done")
            bar := stdlib.tkinter.Scrollbar(root, { name: "bar", orient: "vertical", command: command, width: 17 })

            AhkTest.AssertEqual("Scrollbar", Type(bar))
            AhkTest.AssertEqual(".bar", String(bar))
            AhkTest.AssertSame(root, bar._root())
            AhkTest.AssertEqual(1, bar.winfo_exists())
            AhkTest.AssertEqual("vertical", bar.cget("orient"))
            AhkTest.AssertTrue(bar.cget("command") != "")
            AhkTest.AssertEqual("17", bar.cget("width"))
            AhkTest.AssertEqual(stdlib.tuple([0.0, 0.0, 0.0, 0.0]), bar.get())
            AhkTest.AssertEqual(stdlib.None, bar.set(0.25, 0.75))
            AhkTest.AssertEqual(stdlib.tuple([0.25, 0.75]), bar.get())
            AhkTest.AssertEqual(stdlib.None, bar.activate())
            AhkTest.AssertEqual(stdlib.None, bar.activate("arrow1"))
            AhkTest.AssertEqual("arrow1", bar.activate())
            AhkTest.AssertEqual(stdlib.None, bar.activate("slider"))
            AhkTest.AssertEqual("slider", bar.activate())
            AhkTest.AssertEqual(stdlib.None, bar.activate("bad"))
            AhkTest.AssertEqual(stdlib.None, bar.activate())
            AhkTest.AssertTrue(bar.delta(0, 10) is Float)
            AhkTest.AssertTrue(bar.fraction(0, 10) is Float)
            AhkTest.AssertEqual("", bar.identify(1, 1))
            AhkTest.AssertEqual("done", root.eval(bar.cget("command") " moveto 0.5"))
            AhkTest.AssertEqual("done", root.eval(bar.cget("command") " scroll 1 units"))
            AhkTest.AssertEqual([["moveto", "0.5"], ["scroll", "1", "units"]], calls)
            AhkTest.AssertEqual(stdlib.None, bar.pack())
            AhkTest.AssertEqual("pack", bar.winfo_manager())
            AhkTest.AssertEqual(stdlib.None, bar.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .bar"))

            AhkTest.AssertEqual(".kw", String(stdlib.tkinter.Scrollbar({ master: root, name: "kw" })))
            AhkTest.AssertEqual("horizontal", stdlib.tkinter.Scrollbar(root, { name: "cnf", orient: "horizontal" }).cget("orient"))
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.Scrollbar({ master: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Scrollbar(root, {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-extra_kw"$', (*) => stdlib.tkinter.Scrollbar(root, { extra_kw: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.activate\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Scrollbar(root).activate("x", "y"))
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.delta\(\) missing 2 required positional arguments: 'deltax' and 'deltay'$", (*) => stdlib.tkinter.Scrollbar(root).delta())
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.delta\(\) missing 1 required positional argument: 'deltay'$", (*) => stdlib.tkinter.Scrollbar(root).delta(1))
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.delta\(\) takes 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Scrollbar(root).delta(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.fraction\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => stdlib.tkinter.Scrollbar(root).fraction())
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.fraction\(\) missing 1 required positional argument: 'y'$", (*) => stdlib.tkinter.Scrollbar(root).fraction(1))
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.fraction\(\) takes 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Scrollbar(root).fraction(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.identify\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => stdlib.tkinter.Scrollbar(root).identify())
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.identify\(\) missing 1 required positional argument: 'y'$", (*) => stdlib.tkinter.Scrollbar(root).identify(1))
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.identify\(\) takes 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Scrollbar(root).identify(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.set\(\) missing 2 required positional arguments: 'first' and 'last'$", (*) => stdlib.tkinter.Scrollbar(root).set())
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.set\(\) missing 1 required positional argument: 'last'$", (*) => stdlib.tkinter.Scrollbar(root).set(0.1))
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.set\(\) takes 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Scrollbar(root).set(0.1, 0.2, 0.3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected floating-point number but got "bad"$', (*) => stdlib.tkinter.Scrollbar(root).set("bad", 0.2))
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.get\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Scrollbar(root).get(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestMenuCommandEntrySurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            calls := []
            command := (*) => (calls.Push("cmd"), "done")
            menu := stdlib.tkinter.Menu(root, { name: "menubar", tearoff: 0 })

            AhkTest.AssertEqual("Menu", Type(menu))
            AhkTest.AssertEqual(".menubar", String(menu))
            AhkTest.AssertSame(root, menu._root())
            AhkTest.AssertEqual(1, menu.winfo_exists())
            AhkTest.AssertEqual(0, menu.cget("tearoff"))
            AhkTest.AssertEqual("", menu.cget("title"))
            AhkTest.AssertEqual("normal", menu.cget("type"))
            AhkTest.AssertEqual(stdlib.None, menu.index("end"))
            AhkTest.AssertEqual(stdlib.None, menu.add_command({ label: "Open", command: command, accelerator: "Ctrl+O" }))
            AhkTest.AssertEqual(0, menu.index("end"))
            AhkTest.AssertEqual("Open", menu.entrycget(0, "label"))
            AhkTest.AssertTrue(menu.entrycget(0, "command") != "")
            AhkTest.AssertEqual("Ctrl+O", menu.entrycget(0, "accelerator"))
            AhkTest.AssertEqual("normal", menu.entrycget(0, "state"))
            AhkTest.AssertEqual("done", menu.invoke(0))
            AhkTest.AssertEqual(["cmd"], calls)
            AhkTest.AssertEqual(stdlib.None, menu.entryconfigure(0, { label: "Open file", state: "disabled" }))
            AhkTest.AssertEqual("Open file", menu.entrycget(0, "label"))
            AhkTest.AssertEqual("disabled", menu.entrycget(0, "state"))
            AhkTest.AssertEqual("", menu.invoke(0))
            AhkTest.AssertEqual(["cmd"], calls)
            AhkTest.AssertEqual(stdlib.None, menu.delete(0))
            AhkTest.AssertEqual(stdlib.None, menu.index("end"))
            AhkTest.AssertEqual(stdlib.None, menu.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .menubar"))

            AhkTest.AssertEqual(".kw", String(stdlib.tkinter.Menu({ master: root, name: "kw" })))
            AhkTest.AssertEqual(0, stdlib.tkinter.Menu(root, { name: "cnf", tearoff: 0 }).cget("tearoff"))
            dictMenu := stdlib.tkinter.Menu(root, { tearoff: 0 })
            AhkTest.AssertEqual(stdlib.None, dictMenu.add_command({ label: "Dict" }))
            AhkTest.AssertEqual("Dict", dictMenu.entrycget(0, "label"))
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.Menu({ master: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Menu\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Menu(root, {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-extra_kw"$', (*) => stdlib.tkinter.Menu(root, { extra_kw: 1 }))
            AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => stdlib.tkinter.Menu(root).add_command(1))
            AhkTest.RaisesMatch(TypeError, "^Menu\.entrycget\(\) missing 2 required positional arguments: 'index' and 'option'$", (*) => stdlib.tkinter.Menu(root).entrycget())
            AhkTest.RaisesMatch(TypeError, "^Menu\.entrycget\(\) missing 1 required positional argument: 'option'$", (*) => stdlib.tkinter.Menu(root).entrycget(0))
            AhkTest.RaisesMatch(TypeError, "^Menu\.entrycget\(\) takes 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Menu(root).entrycget(0, "label", "x"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.entryconfigure\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Menu(root).entryconfigure())
            AhkTest.RaisesMatch(TypeError, "^Menu\.entryconfigure\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Menu(root).entryconfigure(0, { label: "x" }, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.index\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Menu(root).index())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad menu entry index "bad"$', (*) => stdlib.tkinter.Menu(root).index("bad"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.index\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Menu(root).index("end", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.invoke\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Menu(root).invoke())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad menu entry index "bad"$', (*) => stdlib.tkinter.Menu(root).invoke("bad"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.invoke\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Menu(root).invoke(0, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.delete\(\) missing 1 required positional argument: 'index1'$", (*) => stdlib.tkinter.Menu(root).delete())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad menu entry index "bad"$', (*) => stdlib.tkinter.Menu(root).delete("bad"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.delete\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Menu(root).delete(0, 1, 2))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestEntryWidgetSupportsInputSurfaceLikeLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            text := stdlib.tkinter.StringVar(root, "seed", "entry_var")
            entry := stdlib.tkinter.Entry(root, { textvariable: text, width: 12 })

            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual("Entry", Type(entry))
            AhkTest.AssertEqual(".!entry", String(entry))
            AhkTest.AssertSame(root, entry._root())
            AhkTest.AssertEqual(1, entry.winfo_exists())
            AhkTest.AssertEqual(12, entry.cget("width"))
            AhkTest.AssertEqual("entry_var", entry.cget("textvariable"))
            AhkTest.AssertEqual("seed", entry.get())
            AhkTest.AssertEqual("seed", text.get())
            AhkTest.AssertEqual(stdlib.None, entry.delete(0, "end"))
            AhkTest.AssertEqual(stdlib.None, entry.insert(0, "abc"))
            AhkTest.AssertEqual("abc", entry.get())
            AhkTest.AssertEqual("abc", text.get())
            AhkTest.AssertEqual(stdlib.None, entry.insert("end", "XYZ"))
            AhkTest.AssertEqual("abcXYZ", entry.get())
            AhkTest.AssertEqual(stdlib.None, entry.delete(1, 3))
            AhkTest.AssertEqual("aXYZ", entry.get())
            AhkTest.AssertEqual("aXYZ", text.get())
            AhkTest.AssertEqual(stdlib.None, entry.pack())
            AhkTest.AssertEqual("pack", entry.winfo_manager())
            AhkTest.AssertEqual(stdlib.None, entry.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .!entry"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestEntryCursorAndSelectionSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            entry := stdlib.tkinter.Entry(root, { width: 12 })
            AhkTest.AssertEqual(stdlib.None, entry.insert(0, "abcdef"))
            AhkTest.AssertEqual(stdlib.None, entry.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual(6, entry.index("end"))
            AhkTest.AssertEqual(6, entry.index("insert"))
            AhkTest.AssertEqual(stdlib.None, entry.icursor(2))
            AhkTest.AssertEqual(2, entry.index("insert"))
            AhkTest.AssertSame(stdlib.False, entry.select_present())
            AhkTest.AssertSame(stdlib.False, entry.selection_present())

            AhkTest.AssertEqual(stdlib.None, entry.select_range(1, 4))
            AhkTest.AssertSame(stdlib.True, entry.select_present())
            AhkTest.AssertSame(stdlib.True, entry.selection_present())
            AhkTest.AssertEqual("bcd", entry.selection_get())
            AhkTest.AssertEqual(stdlib.None, entry.select_clear())
            AhkTest.AssertSame(stdlib.False, entry.selection_present())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^PRIMARY selection doesn't exist or form `"STRING`" not defined$", (*) => entry.selection_get())

            AhkTest.AssertEqual(stdlib.None, entry.selection_range(2, 5))
            AhkTest.AssertEqual("cde", entry.selection_get())
            AhkTest.AssertEqual(stdlib.None, entry.selection_clear())
            AhkTest.AssertSame(stdlib.False, entry.selection_present())
            AhkTest.AssertEqual(stdlib.None, entry.select_from(1))
            AhkTest.AssertEqual(stdlib.None, entry.select_to(3))
            AhkTest.AssertEqual("bc", entry.selection_get())
            AhkTest.AssertEqual(stdlib.None, entry.select_adjust(4))
            AhkTest.AssertEqual("bcd", entry.selection_get())

            AhkTest.RaisesMatch(TypeError, "^Entry\.icursor\(\) missing 1 required positional argument: 'index'$", (*) => entry.icursor())
            AhkTest.RaisesMatch(TypeError, "^Entry\.selection_range\(\) missing 1 required positional argument: 'end'$", (*) => entry.selection_range(1))
            AhkTest.RaisesMatch(TypeError, "^Entry\.selection_present\(\) takes 1 positional argument but 2 were given$", (*) => entry.selection_present(1))
            AhkTest.RaisesMatch(TypeError, "^Entry\.selection_clear\(\) takes 1 positional argument but 2 were given$", (*) => entry.selection_clear(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad entry index "bad"$', (*) => entry.index("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad entry index "bad"$', (*) => entry.icursor("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad entry index "bad"$', (*) => entry.select_range("bad", 2))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkClipboardSurfaceMatchesLocal310()
    {
        oldClipboard := A_Clipboard
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            frame := stdlib.tkinter.Frame(root, { name: "cliphost" })
            AhkTest.AssertEqual(stdlib.None, frame.pack())

            AhkTest.AssertEqual(stdlib.None, root.clipboard_clear())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^CLIPBOARD selection doesn't exist or form " Chr(34) "STRING" Chr(34) " not defined$", (*) => root.clipboard_get())
            AhkTest.AssertEqual(stdlib.None, root.clipboard_append("alpha"))
            AhkTest.AssertEqual("alpha", root.clipboard_get())
            AhkTest.AssertEqual(stdlib.None, root.clipboard_append("beta"))
            AhkTest.AssertEqual("alphabeta", root.clipboard_get({ type: "STRING" }))

            AhkTest.AssertEqual(stdlib.None, frame.clipboard_clear())
            AhkTest.AssertEqual(stdlib.None, frame.clipboard_append("widget"))
            AhkTest.AssertEqual("widget", frame.clipboard_get())
            AhkTest.AssertEqual(stdlib.None, frame.clipboard_append(7))
            AhkTest.AssertEqual("widget7", frame.clipboard_get({ displayof: root }))

            AhkTest.RaisesMatch(TypeError, "^Misc\.clipboard_clear\(\) takes 1 positional argument but 2 were given$", (*) => root.clipboard_clear(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.clipboard_append\(\) missing 1 required positional argument: 'string'$", (*) => root.clipboard_append())
            AhkTest.RaisesMatch(TypeError, "^Misc\.clipboard_append\(\) takes 2 positional arguments but 3 were given$", (*) => root.clipboard_append("a", "b"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.clipboard_get\(\) takes 1 positional argument but 2 were given$", (*) => root.clipboard_get(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^CLIPBOARD selection doesn't exist or form " Chr(34) "BAD_TYPE" Chr(34) " not defined$", (*) => root.clipboard_get({ type: "BAD_TYPE" }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad option "-bad": must be -displayof, -format, or -type$', (*) => root.clipboard_append("x", { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad option "-bad": must be -displayof or -type$', (*) => root.clipboard_get({ bad: 1 }))
        } finally {
            try root.clipboard_clear()
            try root.update_idletasks()
            try root.destroy()
            A_Clipboard := oldClipboard
        }
    }

    static TestTkOptionDatabaseSurfaceMatchesLocal310()
    {
        optionPath := A_Temp "\stdlib-tk-options-" A_TickCount "-" Random(100000, 999999) ".txt"
        badOptionPath := A_Temp "\stdlib-tk-options-bad-" A_TickCount "-" Random(100000, 999999) ".txt"
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")

            AhkTest.AssertEqual("", root.option_get("foreground", "Foreground"))
            AhkTest.AssertEqual(stdlib.None, root.option_add("*Label.foreground", "red"))
            AhkTest.AssertEqual("", root.option_get("foreground", "Foreground"))
            label := stdlib.tkinter.Label(root, { name: "optionlabel" })
            AhkTest.AssertEqual("red", label.cget("foreground"))
            AhkTest.AssertEqual("red", label.option_get("foreground", "Foreground"))

            AhkTest.AssertEqual(stdlib.None, root.option_add("*Label.background", "yellow", 80))
            labelWithBackground := stdlib.tkinter.Label(root, { name: "optionlabel2" })
            AhkTest.AssertEqual("yellow", labelWithBackground.cget("background"))
            AhkTest.AssertEqual(stdlib.None, root.option_clear())
            AhkTest.AssertEqual("", label.option_get("foreground", "Foreground"))

            FileAppend "*Label.foreground: blue`n*Button.text: FromOptions`n", optionPath, "UTF-8-RAW"
            AhkTest.AssertEqual(stdlib.None, root.option_readfile(optionPath))
            fileLabel := stdlib.tkinter.Label(root, { name: "fileoptionlabel" })
            fileButton := stdlib.tkinter.Button(root, { name: "fileoptionbutton" })
            AhkTest.AssertEqual("blue", fileLabel.cget("foreground"))
            AhkTest.AssertEqual("FromOptions", fileButton.cget("text"))
            AhkTest.AssertEqual(stdlib.None, fileLabel.option_readfile(optionPath, 80))

            FileAppend "*Label.foreground blue`n", badOptionPath, "UTF-8-RAW"
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^missing colon on line 1$", (*) => root.option_readfile(badOptionPath))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^couldn't open " Chr(34) "missing-options-file" Chr(34) ": no such file or directory$", (*) => root.option_readfile("missing-options-file"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.option_add\(\) missing 2 required positional arguments: 'pattern' and 'value'$", (*) => root.option_add())
            AhkTest.RaisesMatch(TypeError, "^Misc\.option_add\(\) missing 1 required positional argument: 'value'$", (*) => root.option_add("*Label.foreground"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.option_add\(\) takes from 3 to 4 positional arguments but 5 were given$", (*) => root.option_add("*Label.foreground", "red", 80, 90))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad priority level "bad": must be widgetDefault, startupFile, userDefault, interactive, or a number between 0 and 100$', (*) => root.option_add("*Label.foreground", "red", "bad"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.option_clear\(\) takes 1 positional argument but 2 were given$", (*) => root.option_clear(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.option_get\(\) missing 2 required positional arguments: 'name' and 'className'$", (*) => root.option_get())
            AhkTest.RaisesMatch(TypeError, "^Misc\.option_get\(\) missing 1 required positional argument: 'className'$", (*) => root.option_get("foreground"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.option_get\(\) takes 3 positional arguments but 4 were given$", (*) => root.option_get("foreground", "Foreground", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.option_readfile\(\) missing 1 required positional argument: 'fileName'$", (*) => root.option_readfile())
            AhkTest.RaisesMatch(TypeError, "^Misc\.option_readfile\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => root.option_readfile(optionPath, 80, 90))
        } finally {
            try FileDelete optionPath
            try FileDelete badOptionPath
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTextWidgetEditingSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            text := stdlib.tkinter.Text(root, { width: 20, height: 4, wrap: "none" })

            AhkTest.AssertEqual("Text", Type(text))
            AhkTest.AssertEqual(".!text", String(text))
            AhkTest.AssertEqual(20, text.cget("width"))
            AhkTest.AssertEqual(4, text.cget("height"))
            AhkTest.AssertEqual("none", text.cget("wrap"))
            AhkTest.AssertEqual("`n", text.get("1.0", "end"))
            AhkTest.AssertEqual("", text.get("1.0", "end-1c"))
            AhkTest.AssertEqual(stdlib.None, text.insert("1.0", "hello"))
            AhkTest.AssertEqual("hello", text.get("1.0", "end-1c"))
            AhkTest.AssertEqual(stdlib.None, text.insert("end", "`nworld"))
            AhkTest.AssertEqual("hello`nworld`n", text.get("1.0", "end"))
            AhkTest.AssertEqual("hello`nworld", text.get("1.0", "end-1c"))
            AhkTest.AssertEqual("2.5", text.index("insert"))
            AhkTest.AssertEqual("3.0", text.index("end"))
            AhkTest.AssertEqual(stdlib.None, text.delete("1.0", "1.5"))
            AhkTest.AssertEqual("`nworld", text.get("1.0", "end-1c"))
            AhkTest.AssertEqual(stdlib.None, text.delete("1.0"))
            AhkTest.AssertEqual("world", text.get("1.0", "end-1c"))
            AhkTest.AssertEqual(stdlib.None, text.delete("1.0", "end"))
            AhkTest.AssertEqual(stdlib.None, text.insert("1.0", "fresh"))
            AhkTest.AssertEqual("fresh", text.get("1.0", "end-1c"))
            AhkTest.AssertEqual("f", text.get("1.0"))
            AhkTest.AssertEqual(stdlib.None, text.insert("end", "!", "tag1"))
            AhkTest.AssertEqual("fresh!", text.get("1.0", "end-1c"))
            AhkTest.RaisesMatch(TypeError, "^Text\.insert\(\) missing 2 required positional arguments: 'index' and 'chars'$", (*) => text.insert())
            AhkTest.RaisesMatch(TypeError, "^Text\.insert\(\) missing 1 required positional argument: 'chars'$", (*) => text.insert("1.0"))
            AhkTest.RaisesMatch(TypeError, "^Text\.get\(\) missing 1 required positional argument: 'index1'$", (*) => text.get())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.get("bad", "end"))
            AhkTest.RaisesMatch(TypeError, "^Text\.delete\(\) missing 1 required positional argument: 'index1'$", (*) => text.delete())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.delete("bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.index\(\) missing 1 required positional argument: 'index'$", (*) => text.index())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.index("bad"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestPhotoImagePixelAndWidgetImageSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            image := stdlib.tkinter.PhotoImage({ master: root, width: 2, height: 2 })
            imageName := String(image)
            imageNamePattern := "^p" "y" "image\d+$"

            AhkTest.AssertEqual("PhotoImage", Type(image))
            AhkTest.AssertRegex(imageName, imageNamePattern)
            AhkTest.AssertEqual(2, image.width())
            AhkTest.AssertEqual(2, image.height())
            AhkTest.AssertEqual("photo", image.type())
            AhkTest.AssertEqual("2", image.cget("width"))
            AhkTest.AssertEqual("2", image.cget("height"))
            AhkTest.AssertEqual("", image.cget("format"))
            AhkTest.AssertEqual(stdlib.tuple([0, 0, 0]), image.get(0, 0))
            AhkTest.AssertEqual(stdlib.None, image.put("#ff0000", { to: [0, 0] }))
            AhkTest.AssertEqual(stdlib.tuple([255, 0, 0]), image.get(0, 0))
            AhkTest.AssertEqual(stdlib.None, image.put("{#ff0000 #00ff00} {#0000ff #ffffff}", { to: [0, 0, 2, 2] }))
            AhkTest.AssertEqual(stdlib.tuple([0, 255, 0]), image.get(1, 0))
            AhkTest.AssertEqual(stdlib.tuple([0, 0, 255]), image.get(0, 1))
            AhkTest.AssertEqual(stdlib.tuple([255, 255, 255]), image.get(1, 1))
            label := stdlib.tkinter.Label(root, { image: image })
            AhkTest.AssertEqual(imageName, label.cget("image"))
            AhkTest.AssertEqual(stdlib.None, label.configure({ image: image }))
            AhkTest.AssertEqual(imageName, label.cget("image"))
            AhkTest.AssertEqual(stdlib.None, image.config({ width: 3, height: 1 }))
            AhkTest.AssertEqual(3, image.width())
            AhkTest.AssertEqual(1, image.height())
            AhkTest.AssertEqual("3", image.cget("width"))
            AhkTest.AssertEqual(stdlib.None, image.blank())
            AhkTest.AssertEqual(stdlib.tuple([0, 0, 0]), image.get(0, 0))

            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.cget\(\) missing 1 required positional argument: 'option'$", (*) => image.cget())
            AhkTest.RaisesMatch(TypeError, "^Image\.width\(\) takes 1 positional argument but 2 were given$", (*) => image.width(1))
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.get\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => image.get())
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.get\(\) missing 1 required positional argument: 'y'$", (*) => image.get(0))
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.put\(\) missing 1 required positional argument: 'data'$", (*) => image.put())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => image.get("bad", 0))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^the "-to" option requires one to four integer values$', (*) => image.put("#ff0000", { to: "bad" }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestPhotoImageTransformWriteAndTransparencySurfaceMatchesLocal310()
    {
        outputPath := A_Temp "\stdlib-tkinter-photo-transform-" A_TickCount "-" Random(100000, 999999) ".png"
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            image := stdlib.tkinter.PhotoImage({ master: root, width: 3, height: 2 })
            AhkTest.AssertEqual(stdlib.None, image.put("#112233", { to: [0, 0, 2, 1] }))
            AhkTest.AssertEqual(stdlib.None, image.put("#abcdef", { to: [2, 1] }))

            dupImage := image.copy()
            AhkTest.AssertEqual("PhotoImage", Type(dupImage))
            AhkTest.AssertEqual(3, dupImage.width())
            AhkTest.AssertEqual(2, dupImage.height())
            AhkTest.AssertEqual("photo", dupImage.type())
            AhkTest.AssertEqual(stdlib.tuple([17, 34, 51]), dupImage.get(0, 0))
            AhkTest.AssertEqual(stdlib.tuple([171, 205, 239]), dupImage.get(2, 1))

            zoomed := image.zoom(2, 3)
            AhkTest.AssertEqual(6, zoomed.width())
            AhkTest.AssertEqual(6, zoomed.height())
            AhkTest.AssertEqual(stdlib.tuple([17, 34, 51]), zoomed.get(1, 2))
            sampled := zoomed.subsample(2, 3)
            AhkTest.AssertEqual(3, sampled.width())
            AhkTest.AssertEqual(2, sampled.height())
            AhkTest.AssertEqual(stdlib.tuple([171, 205, 239]), sampled.get(2, 1))

            AhkTest.AssertSame(stdlib.False, image.transparency_get(0, 0))
            AhkTest.AssertEqual(stdlib.None, image.transparency_set(0, 0, stdlib.True))
            AhkTest.AssertSame(stdlib.True, image.transparency_get(0, 0))
            AhkTest.AssertEqual(stdlib.None, image.transparency_set(0, 0, stdlib.False))
            AhkTest.AssertSame(stdlib.False, image.transparency_get(0, 0))

            try FileDelete outputPath
            AhkTest.AssertEqual(stdlib.None, image.write(outputPath, "png"))
            AhkTest.AssertTrue(FileExist(outputPath) != "")

            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.copy\(\) takes 1 positional argument but 2 were given$", (*) => image.copy(1))
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.zoom\(\) missing 1 required positional argument: 'x'$", (*) => image.zoom())
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.zoom\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => image.zoom(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.subsample\(\) missing 1 required positional argument: 'x'$", (*) => image.subsample())
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.subsample\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => image.subsample(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.write\(\) missing 1 required positional argument: 'filename'$", (*) => image.write())
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.transparency_get\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => image.transparency_get())
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.transparency_get\(\) missing 1 required positional argument: 'y'$", (*) => image.transparency_get(0))
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.transparency_get\(\) takes 3 positional arguments but 4 were given$", (*) => image.transparency_get(0, 0, 0))
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.transparency_set\(\) missing 3 required positional arguments: 'x', 'y', and 'boolean'$", (*) => image.transparency_set())
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.transparency_set\(\) missing 1 required positional argument: 'boolean'$", (*) => image.transparency_set(0, 0))
            AhkTest.RaisesMatch(TypeError, "^PhotoImage\.transparency_set\(\) takes 4 positional arguments but 5 were given$", (*) => image.transparency_set(0, 0, stdlib.True, stdlib.False))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => image.transparency_get("bad", 0))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected boolean value but got "maybe"$', (*) => image.transparency_set(0, 0, "maybe"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
            try FileDelete outputPath
        }
    }

    static TestTkImageRegistryQueriesMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            label := stdlib.tkinter.Label(root, { text: "Images" })
            defaultNames := stdlib.tuple(["::tk::icons::information", "::tk::icons::error", "::tk::icons::warning", "::tk::icons::question"])

            AhkTest.AssertEqual(stdlib.tuple(["photo", "bitmap"]), root.image_types())
            AhkTest.AssertEqual(stdlib.tuple(["photo", "bitmap"]), label.image_types())
            AhkTest.AssertEqual(defaultNames, root.image_names())
            AhkTest.AssertEqual(defaultNames, label.image_names())

            first := stdlib.tkinter.PhotoImage({ master: root, name: "registry_a", width: 1, height: 1 })
            second := stdlib.tkinter.PhotoImage({ master: root, name: "registry_b", width: 1, height: 1 })
            AhkTest.AssertEqual(stdlib.tuple(["registry_a", "::tk::icons::information", "::tk::icons::error", "::tk::icons::warning", "registry_b", "::tk::icons::question"]), root.image_names())
            AhkTest.AssertEqual(root.image_names(), label.image_names())

            root.eval("image delete registry_a")
            AhkTest.AssertEqual(stdlib.tuple(["::tk::icons::information", "::tk::icons::error", "::tk::icons::warning", "registry_b", "::tk::icons::question"]), root.image_names())
            root.eval("image delete registry_b")
            AhkTest.AssertEqual(defaultNames, root.image_names())

            AhkTest.RaisesMatch(TypeError, "^Misc\.image_names\(\) takes 1 positional argument but 2 were given$", (*) => root.image_names(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.image_types\(\) takes 1 positional argument but 2 were given$", (*) => label.image_types(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCanvasDrawableSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            canvas := stdlib.tkinter.Canvas(root, { width: 120, height: 80, bg: "white" })
            lineId := canvas.create_line(0, 1, 10, 20, { fill: "red", width: 2 })
            rectId := canvas.create_rectangle(5, 6, 30, 40, { outline: "blue", fill: "green" })

            AhkTest.AssertEqual("Canvas", Type(canvas))
            AhkTest.AssertEqual(".!canvas", String(canvas))
            AhkTest.AssertEqual("120", canvas.cget("width"))
            AhkTest.AssertEqual("80", canvas.cget("height"))
            AhkTest.AssertEqual("white", canvas.cget("bg"))
            AhkTest.AssertEqual(1, lineId)
            AhkTest.AssertEqual(2, rectId)
            AhkTest.AssertEqual([0.0, 1.0, 10.0, 20.0], canvas.coords(lineId))
            AhkTest.AssertEqual([5.0, 6.0, 30.0, 40.0], canvas.coords(rectId))
            AhkTest.AssertEqual("red", canvas.itemcget(lineId, "fill"))
            AhkTest.AssertEqual("2.0", canvas.itemcget(lineId, "width"))
            AhkTest.AssertEqual("blue", canvas.itemcget(rectId, "outline"))
            AhkTest.AssertEqual(stdlib.None, canvas.itemconfigure(lineId, { fill: "purple" }))
            AhkTest.AssertEqual("purple", canvas.itemcget(lineId, "fill"))
            AhkTest.AssertEqual([], canvas.coords(lineId, 2, 3, 12, 13))
            AhkTest.AssertEqual([2.0, 3.0, 12.0, 13.0], canvas.coords(lineId))
            AhkTest.AssertEqual(stdlib.None, canvas.delete(lineId))
            AhkTest.AssertEqual([], canvas.coords(lineId))
            AhkTest.AssertEqual("", canvas.itemcget(lineId, "fill"))
            AhkTest.AssertEqual(stdlib.None, canvas.delete(999))
            AhkTest.AssertEqual(stdlib.None, canvas.delete())
            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => canvas.create_line())
            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => canvas.create_rectangle())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^wrong # args: should be .* coords tagOrId", (*) => canvas.coords())
            AhkTest.AssertEqual([], canvas.coords("bad"))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.itemcget\(\) missing 2 required positional arguments: 'tagOrId' and 'option'$", (*) => canvas.itemcget())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.itemcget\(\) missing 1 required positional argument: 'option'$", (*) => canvas.itemcget(lineId))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.itemconfigure\(\) missing 1 required positional argument: 'tagOrId'$", (*) => canvas.itemconfigure())
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCanvasItemDiscoveryAndMoveSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            canvas := stdlib.tkinter.Canvas(root, { width: 120, height: 80, bg: "white" })
            AhkTest.AssertEqual(stdlib.None, canvas.pack())
            lineId := canvas.create_line(0, 1, 10, 20, { fill: "red", width: 2, tags: "path shape" })
            rectId := canvas.create_rectangle(5, 6, 30, 40, { outline: "blue", fill: "green", tags: "box shape" })
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual(stdlib.tuple([lineId, rectId]), canvas.find_all())
            AhkTest.AssertEqual(stdlib.tuple([lineId]), canvas.find_withtag("path"))
            AhkTest.AssertEqual(stdlib.tuple([lineId, rectId]), canvas.find_withtag("shape"))
            AhkTest.AssertEqual(stdlib.tuple([]), canvas.find_withtag("missing"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas bbox tagOrId \?tagOrId \.\.\.\?"$', (*) => canvas.bbox())
            AhkTest.AssertEqual(stdlib.tuple([-3, -2, 13, 23]), canvas.bbox(lineId))
            AhkTest.AssertEqual(stdlib.tuple([-3, -2, 31, 41]), canvas.bbox("shape"))
            AhkTest.AssertEqual(stdlib.None, canvas.bbox("missing"))
            AhkTest.AssertEqual("line", canvas.type(lineId))
            AhkTest.AssertEqual("rectangle", canvas.type(rectId))
            AhkTest.AssertEqual(stdlib.None, canvas.type(999))

            AhkTest.AssertEqual(stdlib.None, canvas.move(lineId, 2, 3))
            AhkTest.AssertEqual([2.0, 4.0, 12.0, 23.0], canvas.coords(lineId))
            AhkTest.AssertEqual(stdlib.tuple([-1, 1, 15, 26]), canvas.bbox(lineId))
            AhkTest.AssertEqual(stdlib.None, canvas.move("shape", -1, -1))
            AhkTest.AssertEqual([1.0, 3.0, 11.0, 22.0], canvas.coords(lineId))
            AhkTest.AssertEqual([4.0, 5.0, 29.0, 39.0], canvas.coords(rectId))

            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_all\(\) takes 1 positional argument but 2 were given$", (*) => canvas.find_all(1))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_withtag\(\) missing 1 required positional argument: 'tagOrId'$", (*) => canvas.find_withtag())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_withtag\(\) takes 2 positional arguments but 3 were given$", (*) => canvas.find_withtag("shape", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas move tagOrId xAmount yAmount"$', (*) => canvas.move(lineId, 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.move(lineId, "bad", 1))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.type\(\) missing 1 required positional argument: 'tagOrId'$", (*) => canvas.type())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.type\(\) takes 2 positional arguments but 3 were given$", (*) => canvas.type(lineId, "extra"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCanvasMovetoLayerAndItemAliasSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            canvas := stdlib.tkinter.Canvas(root, { width: 160, height: 120, bg: "white" })
            AhkTest.AssertEqual(stdlib.None, canvas.pack())
            lineId := canvas.create_line(10, 20, 30, 40, { fill: "red", width: 1, tags: "shape line" })
            rectId := canvas.create_rectangle(50, 60, 80, 90, { fill: "blue", tags: "shape box" })
            textId := canvas.create_text(100, 50, { text: "Hi", tags: "label" })
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual(stdlib.tuple([lineId, rectId, textId]), canvas.find_all())
            AhkTest.AssertEqual(stdlib.None, canvas.itemconfig(lineId, { fill: "green" }))
            AhkTest.AssertEqual("green", canvas.itemcget(lineId, "fill"))
            AhkTest.AssertEqual(stdlib.None, canvas.moveto(lineId, 15, 25))
            AhkTest.AssertEqual([17.0, 27.0, 37.0, 47.0], canvas.coords(lineId))
            AhkTest.AssertEqual(stdlib.None, canvas.moveto("shape", 5, 6))
            AhkTest.AssertEqual([7.0, 8.0, 27.0, 28.0], canvas.coords(lineId))
            AhkTest.AssertEqual([40.0, 41.0, 70.0, 71.0], canvas.coords(rectId))
            AhkTest.AssertEqual(stdlib.None, canvas.moveto("missing", 1, 2))
            AhkTest.AssertEqual([7.0, 8.0, 27.0, 28.0], canvas.coords(lineId))
            AhkTest.AssertEqual(stdlib.None, canvas.tag_raise(lineId))
            AhkTest.AssertEqual(stdlib.tuple([rectId, textId, lineId]), canvas.find_all())
            AhkTest.AssertEqual(stdlib.None, canvas.tag_lower(textId))
            AhkTest.AssertEqual(stdlib.tuple([textId, rectId, lineId]), canvas.find_all())
            AhkTest.AssertEqual(stdlib.None, canvas.tag_lower("shape", textId))
            AhkTest.AssertEqual(stdlib.tuple([rectId, lineId, textId]), canvas.find_all())
            AhkTest.AssertEqual(stdlib.None, canvas.tag_raise("shape", textId))
            AhkTest.AssertEqual(stdlib.tuple([textId, rectId, lineId]), canvas.find_all())

            probeId := canvas.create_line(10, 20, 30, 40, { width: 1 })
            AhkTest.AssertEqual(stdlib.None, canvas.moveto(probeId))
            AhkTest.AssertEqual([10.0, 20.0, 30.0, 40.0], canvas.coords(probeId))
            AhkTest.AssertEqual(stdlib.None, canvas.moveto(probeId, 1))
            AhkTest.AssertEqual([3.0, 20.0, 23.0, 40.0], canvas.coords(probeId))
            AhkTest.AssertEqual(stdlib.None, canvas.moveto(probeId, "", 2))
            AhkTest.AssertEqual([3.0, 4.0, 23.0, 24.0], canvas.coords(probeId))

            AhkTest.RaisesMatch(TypeError, "^Canvas\.itemconfigure\(\) missing 1 required positional argument: 'tagOrId'$", (*) => canvas.itemconfig())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.itemconfigure\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => canvas.itemconfig(lineId, { fill: "x" }, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => canvas.itemconfig(lineId, { bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.moveto\(\) missing 1 required positional argument: 'tagOrId'$", (*) => canvas.moveto())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.moveto\(\) takes from 2 to 4 positional arguments but 5 were given$", (*) => canvas.moveto(lineId, 1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.moveto(lineId, "bad", 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas raise tagOrId \?aboveThis\?"$', (*) => canvas.tag_raise())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas raise tagOrId \?aboveThis\?"$', (*) => canvas.tag_raise(lineId, rectId, textId))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^tagOrId "missing" doesn.t match any items$', (*) => canvas.tag_raise(lineId, "missing"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas lower tagOrId \?belowThis\?"$', (*) => canvas.tag_lower())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas lower tagOrId \?belowThis\?"$', (*) => canvas.tag_lower(lineId, rectId, textId))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^tagOrId "missing" doesn.t match any items$', (*) => canvas.tag_lower(lineId, "missing"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCanvasTagBindAndUnbindSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.geometry("200x160+0+0")
            canvas := stdlib.tkinter.Canvas(root, { width: 120, height: 80, bg: "white" })
            AhkTest.AssertEqual(stdlib.None, canvas.pack())
            lineId := canvas.create_line(10, 10, 60, 60, { tags: "shape path", width: 4 })
            rectId := canvas.create_rectangle(70, 10, 110, 50, { tags: "shape box" })
            AhkTest.AssertEqual(stdlib.None, root.update())

            recorder := StdlibTkinterTest.EventRecorder(stdlib.None, "tag")
            breaker := StdlibTkinterTest.EventRecorder("break", "breaker")
            AhkTest.AssertEqual(stdlib.tuple([]), canvas.tag_bind("shape"))
            AhkTest.AssertEqual("", canvas.tag_bind("shape", "<Button-1>"))
            commandName := canvas.tag_bind("shape", "<Button-1>", recorder)
            AhkTest.AssertTrue(commandName != "")
            AhkTest.AssertEqual(stdlib.tuple(["<Button-1>"]), canvas.tag_bind("shape"))
            AhkTest.AssertTrue(InStr(canvas.tag_bind("shape", "<Button-1>"), commandName) > 0)
            AhkTest.AssertTrue(InStr(canvas.tag_bind("shape", "<Button-1>", stdlib.None), commandName) > 0)

            AhkTest.AssertEqual(stdlib.None, canvas.event_generate("<Button-1>", { x: 20, y: 20 }))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(1, recorder.Calls.Length)
            AhkTest.AssertSame(canvas, recorder.Calls[1].widget)
            AhkTest.AssertEqual("ButtonPress", recorder.Calls[1].type.name)
            AhkTest.AssertEqual(20, recorder.Calls[1].x)
            AhkTest.AssertEqual(20, recorder.Calls[1].y)

            extraCommand := canvas.tag_bind("shape", "<Button-1>", breaker, "+")
            AhkTest.AssertTrue(extraCommand != "")
            AhkTest.AssertTrue(InStr(canvas.tag_bind("shape", "<Button-1>"), extraCommand) > 0)
            AhkTest.AssertEqual(stdlib.None, canvas.event_generate("<Button-1>", { x: 25, y: 26 }))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(2, recorder.Calls.Length)
            AhkTest.AssertEqual(1, breaker.Calls.Length)
            AhkTest.AssertEqual(25, recorder.Calls[2].x)
            AhkTest.AssertEqual(26, breaker.Calls[1].y)

            AhkTest.AssertEqual(stdlib.None, canvas.tag_unbind("shape", "<Button-1>", commandName))
            AhkTest.AssertEqual("", canvas.tag_bind("shape", "<Button-1>"))
            AhkTest.AssertEqual(stdlib.None, canvas.event_generate("<Button-1>", { x: 30, y: 31 }))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(2, recorder.Calls.Length)
            AhkTest.AssertEqual(1, breaker.Calls.Length)
            AhkTest.AssertEqual(stdlib.None, canvas.tag_unbind("shape", "<Button-1>"))
            AhkTest.AssertEqual("", canvas.tag_bind("shape", "<Button-1>"))

            missingCommand := canvas.tag_bind("missing", "<Button-1>", recorder)
            AhkTest.AssertTrue(missingCommand != "")
            AhkTest.AssertEqual(stdlib.tuple(["<Button-1>"]), canvas.tag_bind("missing"))
            AhkTest.AssertTrue(InStr(canvas.tag_bind("missing", "<Button-1>"), missingCommand) > 0)
            AhkTest.AssertEqual(stdlib.None, canvas.tag_unbind("missing", "<Button-1>", missingCommand))

            AhkTest.RaisesMatch(TypeError, "^Canvas\.tag_bind\(\) missing 1 required positional argument: 'tagOrId'$", (*) => canvas.tag_bind())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.tag_bind\(\) takes from 2 to 5 positional arguments but 6 were given$", (*) => canvas.tag_bind("shape", "<Button-1>", recorder, "+", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.tag_unbind\(\) missing 2 required positional arguments: 'tagOrId' and 'sequence'$", (*) => canvas.tag_unbind())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.tag_unbind\(\) missing 1 required positional argument: 'sequence'$", (*) => canvas.tag_unbind("shape"))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.tag_unbind\(\) takes from 3 to 4 positional arguments but 5 were given$", (*) => canvas.tag_unbind("shape", "<Button-1>", extraCommand, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^can't delete Tcl command$", (*) => canvas.tag_unbind("shape", "<Button-1>", "missingCommand"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCanvasPostscriptSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        outputPath := A_Temp "\stdlib-tkinter-postscript-" A_TickCount "-" Random(100000, 999999) ".ps"
        try {
            root.geometry("240x180+0+0")
            canvas := stdlib.tkinter.Canvas(root, { width: 120, height: 80, bg: "white" })
            AhkTest.AssertEqual(stdlib.None, canvas.pack())
            canvas.create_line(0, 1, 10, 20, { fill: "red", width: 2 })
            canvas.create_rectangle(20, 25, 60, 70, { outline: "blue", fill: "green" })
            canvas.create_text(40, 20, { text: "Hi", anchor: "nw" })
            AhkTest.AssertEqual(stdlib.None, root.update())

            raw := canvas.postscript()
            AhkTest.AssertTrue(InStr(raw, "%!PS-Adobe-3.0 EPSF-3.0") = 1)
            AhkTest.AssertTrue(InStr(raw, "%%Creator: Tk Canvas Widget") > 0)
            AhkTest.AssertTrue(InStr(raw, "%%BoundingBox:") > 0)
            AhkTest.AssertTrue(StrLen(canvas.postscript({ colormode: "color" })) > 1000)
            AhkTest.AssertTrue(StrLen(canvas.postscript({ colormode: "gray" })) > 1000)
            AhkTest.AssertTrue(StrLen(canvas.postscript({ x: 0, y: 0, width: 60, height: 40 })) > 1000)
            AhkTest.AssertTrue(StrLen(canvas.postscript({ pagex: 10, pagey: 20, pagewidth: 50, pageheight: 40, rotate: stdlib.True })) > 1000)
            AhkTest.AssertTrue(InStr(canvas.postscript({}), "%!PS-Adobe-3.0 EPSF-3.0") = 1)

            try FileDelete outputPath
            AhkTest.AssertEqual("", canvas.postscript({ file: outputPath }))
            AhkTest.AssertTrue(FileExist(outputPath) != "")
            fileText := FileRead(outputPath, "UTF-8")
            AhkTest.AssertTrue(InStr(fileText, "%!PS-Adobe-3.0 EPSF-3.0") = 1)

            missingPath := "Z:\definitely\missing\out.ps"
            AhkTest.AssertEqual('couldn' Chr(39) 't open "' missingPath '": no such file or directory', canvas.postscript({ file: missingPath }))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.postscript\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => canvas.postscript({}, "extra"))
            AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => canvas.postscript(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => canvas.postscript({ bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad color mode "bad": must be monochrome, gray, or color$', (*) => canvas.postscript({ colormode: "bad" }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.postscript({ x: "bad" }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected boolean value but got "bad"$', (*) => canvas.postscript({ rotate: "bad" }))
        } finally {
            try FileDelete outputPath
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCanvasFindQuerySurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            canvas := stdlib.tkinter.Canvas(root, { width: 120, height: 120, bg: "white" })
            AhkTest.AssertEqual(stdlib.None, canvas.pack())
            lineId := canvas.create_line(0, 0, 10, 10, { tags: "path shape" })
            rectId := canvas.create_rectangle(20, 20, 50, 50, { tags: "box shape" })
            ovalId := canvas.create_oval(60, 60, 90, 90, { tags: "round shape" })
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual(stdlib.tuple([lineId, rectId, ovalId]), canvas.find_all())
            AhkTest.AssertEqual(stdlib.tuple([lineId, rectId, ovalId]), canvas.find("all"))
            AhkTest.AssertEqual(stdlib.tuple([lineId, rectId, ovalId]), canvas.find("withtag", "shape"))
            AhkTest.AssertEqual(stdlib.tuple([lineId, rectId, ovalId]), canvas.find_withtag("shape"))
            AhkTest.AssertEqual(stdlib.tuple([]), canvas.find_withtag("missing"))
            AhkTest.AssertEqual(stdlib.tuple([rectId]), canvas.find_above(lineId))
            AhkTest.AssertEqual(stdlib.tuple([ovalId]), canvas.find_above(rectId))
            AhkTest.AssertEqual(stdlib.tuple([]), canvas.find_above(ovalId))
            AhkTest.AssertEqual(stdlib.tuple([]), canvas.find_above("missing"))
            AhkTest.AssertEqual(stdlib.tuple([]), canvas.find_below(lineId))
            AhkTest.AssertEqual(stdlib.tuple([lineId]), canvas.find_below(rectId))
            AhkTest.AssertEqual(stdlib.tuple([rectId]), canvas.find_below(ovalId))
            AhkTest.AssertEqual(stdlib.tuple([lineId]), canvas.find_closest(2, 2))
            AhkTest.AssertEqual(stdlib.tuple([rectId]), canvas.find_closest(30, 30))
            AhkTest.AssertEqual(stdlib.tuple([ovalId]), canvas.find_closest(65, 65))
            AhkTest.AssertEqual(stdlib.tuple([rectId]), canvas.find_closest(65, 65, 100, ovalId))
            AhkTest.AssertEqual(stdlib.tuple([lineId]), canvas.find_closest(2, 2, stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple([lineId]), canvas.find_closest(2, 2, stdlib.None, stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple([rectId]), canvas.find_enclosed(15, 15, 55, 55))
            AhkTest.AssertEqual(stdlib.tuple([rectId, ovalId]), canvas.find_enclosed(0, 0, 100, 100))
            AhkTest.AssertEqual(stdlib.tuple([]), canvas.find_enclosed(100, 100, 110, 110))
            AhkTest.AssertEqual(stdlib.tuple([lineId, rectId]), canvas.find_overlapping(0, 0, 25, 25))
            AhkTest.AssertEqual(stdlib.tuple([ovalId]), canvas.find_overlapping(55, 55, 65, 65))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas find searchCommand \?arg \.\.\.\?"$', (*) => canvas.find())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad search command "badsearch": must be above, all, below, closest, enclosed, overlapping, or withtag$', (*) => canvas.find("badsearch"))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_above\(\) missing 1 required positional argument: 'tagOrId'$", (*) => canvas.find_above())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_above\(\) takes 2 positional arguments but 3 were given$", (*) => canvas.find_above(lineId, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_below\(\) missing 1 required positional argument: 'tagOrId'$", (*) => canvas.find_below())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_below\(\) takes 2 positional arguments but 3 were given$", (*) => canvas.find_below(lineId, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_closest\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => canvas.find_closest())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_closest\(\) missing 1 required positional argument: 'y'$", (*) => canvas.find_closest(1))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_closest\(\) takes from 3 to 5 positional arguments but 6 were given$", (*) => canvas.find_closest(1, 2, 3, 4, 5))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.find_closest("bad", 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.find_closest(1, "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.find_closest(1, 2, "bad"))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_enclosed\(\) missing 4 required positional arguments: 'x1', 'y1', 'x2', and 'y2'$", (*) => canvas.find_enclosed())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_enclosed\(\) missing 2 required positional arguments: 'x2' and 'y2'$", (*) => canvas.find_enclosed(1, 2))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_enclosed\(\) takes 5 positional arguments but 6 were given$", (*) => canvas.find_enclosed(1, 2, 3, 4, 5))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.find_enclosed("bad", 1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_overlapping\(\) missing 4 required positional arguments: 'x1', 'y1', 'x2', and 'y2'$", (*) => canvas.find_overlapping())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.find_overlapping\(\) takes 5 positional arguments but 6 were given$", (*) => canvas.find_overlapping(1, 2, 3, 4, 5))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.find_overlapping(1, "bad", 2, 3))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCanvasTagManagementSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            canvas := stdlib.tkinter.Canvas(root, { width: 160, height: 120, bg: "white" })
            AhkTest.AssertEqual(stdlib.None, canvas.pack())
            lineId := canvas.create_line(0, 0, 10, 10, { tags: "path shape" })
            rectId := canvas.create_rectangle(20, 20, 50, 50, { tags: "box shape" })
            ovalId := canvas.create_oval(60, 60, 90, 90, { tags: "round" })
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual(stdlib.tuple(["path", "shape"]), canvas.gettags(lineId))
            AhkTest.AssertEqual(stdlib.tuple(["path", "shape"]), canvas.gettags("shape"))
            AhkTest.AssertEqual(stdlib.None, canvas.addtag_withtag("selected", "shape"))
            AhkTest.AssertEqual(stdlib.tuple(["path", "shape", "selected"]), canvas.gettags(lineId))
            AhkTest.AssertEqual(stdlib.tuple(["box", "shape", "selected"]), canvas.gettags(rectId))
            AhkTest.AssertEqual(stdlib.None, canvas.addtag_all("everything"))
            AhkTest.AssertEqual(stdlib.tuple(["round", "everything"]), canvas.gettags(ovalId))
            AhkTest.AssertEqual(stdlib.None, canvas.addtag_above("above_line", lineId))
            AhkTest.AssertEqual(stdlib.tuple(["box", "shape", "selected", "everything", "above_line"]), canvas.gettags(rectId))
            AhkTest.AssertEqual(stdlib.None, canvas.addtag_below("below_oval", ovalId))
            AhkTest.AssertEqual(stdlib.tuple(["box", "shape", "selected", "everything", "above_line", "below_oval"]), canvas.gettags(rectId))
            AhkTest.AssertEqual(stdlib.None, canvas.addtag_closest("near_line", 2, 2))
            AhkTest.AssertEqual(stdlib.tuple(["path", "shape", "selected", "everything", "near_line"]), canvas.gettags(lineId))
            AhkTest.AssertEqual(stdlib.None, canvas.addtag_closest("near_rect", 62, 62, 100, ovalId))
            AhkTest.AssertEqual(stdlib.tuple(["box", "shape", "selected", "everything", "above_line", "below_oval", "near_rect"]), canvas.gettags(rectId))
            AhkTest.AssertEqual(stdlib.None, canvas.addtag_enclosed("inside_rect", 15, 15, 55, 55))
            AhkTest.AssertEqual(stdlib.tuple(["box", "shape", "selected", "everything", "above_line", "below_oval", "near_rect", "inside_rect"]), canvas.gettags(rectId))
            AhkTest.AssertEqual(stdlib.None, canvas.addtag_overlapping("overlap_left", 0, 0, 25, 25))
            AhkTest.AssertEqual(stdlib.tuple(["path", "shape", "selected", "everything", "near_line", "overlap_left"]), canvas.gettags(lineId))
            AhkTest.AssertEqual(stdlib.tuple(["box", "shape", "selected", "everything", "above_line", "below_oval", "near_rect", "inside_rect", "overlap_left"]), canvas.gettags(rectId))
            AhkTest.AssertEqual(stdlib.None, canvas.addtag("rawtag", "withtag", lineId))
            AhkTest.AssertEqual(stdlib.tuple(["path", "shape", "selected", "everything", "near_line", "overlap_left", "rawtag"]), canvas.gettags(lineId))
            AhkTest.AssertEqual(stdlib.None, canvas.dtag("shape", "selected"))
            AhkTest.AssertEqual(stdlib.tuple(["path", "shape", "everything", "near_line", "overlap_left", "rawtag"]), canvas.gettags(lineId))
            AhkTest.AssertEqual(stdlib.tuple(["box", "shape", "everything", "above_line", "below_oval", "near_rect", "inside_rect", "overlap_left"]), canvas.gettags(rectId))
            AhkTest.AssertEqual(stdlib.None, canvas.dtag(lineId))
            AhkTest.AssertEqual(stdlib.tuple(["path", "shape", "everything", "near_line", "overlap_left", "rawtag"]), canvas.gettags(lineId))
            AhkTest.AssertEqual(stdlib.tuple([]), canvas.gettags("missing"))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas gettags tagOrId"$', (*) => canvas.gettags())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas gettags tagOrId"$', (*) => canvas.gettags(lineId, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.addtag_all\(\) missing 1 required positional argument: 'newtag'$", (*) => canvas.addtag_all())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.addtag_withtag\(\) missing 2 required positional arguments: 'newtag' and 'tagOrId'$", (*) => canvas.addtag_withtag())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.addtag_withtag\(\) missing 1 required positional argument: 'tagOrId'$", (*) => canvas.addtag_withtag("tag"))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.addtag_closest\(\) missing 3 required positional arguments: 'newtag', 'x', and 'y'$", (*) => canvas.addtag_closest())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.addtag_closest\(\) takes from 4 to 6 positional arguments but 7 were given$", (*) => canvas.addtag_closest("tag", 1, 2, 3, 4, 5))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.addtag_closest("tag", "bad", 2))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.addtag_enclosed\(\) missing 5 required positional arguments: 'newtag', 'x1', 'y1', 'x2', and 'y2'$", (*) => canvas.addtag_enclosed())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.addtag_enclosed\(\) takes 6 positional arguments but 7 were given$", (*) => canvas.addtag_enclosed("tag", 1, 2, 3, 4, 5))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.addtag_enclosed("tag", 1, 2, 3, "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas addtag tag searchCommand \?arg \.\.\.\?"$', (*) => canvas.addtag())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad search command "badsearch": must be above, all, below, closest, enclosed, overlapping, or withtag$', (*) => canvas.addtag("tag", "badsearch"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas dtag tagOrId \?tagToDelete\?"$', (*) => canvas.dtag())
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCanvasViewAndCoordinateSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.geometry("220x180+0+0")
            canvas := stdlib.tkinter.Canvas(root, { width: 100, height: 80, scrollregion: "0 0 500 400", xscrollincrement: 10, yscrollincrement: 20 })
            AhkTest.AssertEqual(stdlib.None, canvas.pack())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual(stdlib.tuple([0.0, 0.2]), canvas.xview())
            AhkTest.AssertEqual(stdlib.tuple([0.0, 0.2]), canvas.yview())
            AhkTest.AssertEqual(-2.0, canvas.canvasx(0))
            AhkTest.AssertEqual(-2.0, canvas.canvasy(0))
            AhkTest.AssertEqual(10.0, canvas.canvasx(13, 10))
            AhkTest.AssertEqual(40.0, canvas.canvasy(33, 20))
            AhkTest.AssertEqual(11.0, canvas.canvasx(13, stdlib.None))
            AhkTest.AssertEqual(31.0, canvas.canvasy(33, stdlib.None))

            AhkTest.AssertEqual(stdlib.None, canvas.xview_moveto(0.5))
            AhkTest.AssertEqual(stdlib.tuple([0.5, 0.7]), canvas.xview())
            AhkTest.AssertEqual(248.0, canvas.canvasx(0))
            AhkTest.AssertEqual(stdlib.None, canvas.xview_scroll(2, "units"))
            AhkTest.AssertEqual(stdlib.tuple([0.54, 0.74]), canvas.xview())

            AhkTest.AssertEqual(stdlib.None, canvas.yview("moveto", 0.25))
            AhkTest.AssertEqual(stdlib.tuple([0.25, 0.45]), canvas.yview())
            AhkTest.AssertEqual(98.0, canvas.canvasy(0))
            AhkTest.AssertEqual(stdlib.None, canvas.yview("scroll", 1, "units"))
            AhkTest.AssertEqual(stdlib.tuple([0.3, 0.5]), canvas.yview())

            AhkTest.RaisesMatch(TypeError, "^Canvas\.canvasx\(\) missing 1 required positional argument: 'screenx'$", (*) => canvas.canvasx())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.canvasx\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => canvas.canvasx(1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.canvasx("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.canvasx(1, "bad"))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.canvasy\(\) missing 1 required positional argument: 'screeny'$", (*) => canvas.canvasy())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.canvasy\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => canvas.canvasy(1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.canvasy("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "bad": must be moveto or scroll$', (*) => canvas.xview("bad"))
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_moveto\(\) missing 1 required positional argument: 'fraction'$", (*) => canvas.xview_moveto())
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_moveto\(\) takes 2 positional arguments but 3 were given$", (*) => canvas.xview_moveto(0.1, 0.2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected floating-point number but got "bad"$', (*) => canvas.xview_moveto("bad"))
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_scroll\(\) missing 2 required positional arguments: 'number' and 'what'$", (*) => canvas.xview_scroll())
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_scroll\(\) missing 1 required positional argument: 'what'$", (*) => canvas.xview_scroll(1))
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_scroll\(\) takes 3 positional arguments but 4 were given$", (*) => canvas.xview_scroll(1, "units", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => canvas.xview_scroll("bad", "units"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad argument "bad": must be units or pages$', (*) => canvas.xview_scroll(1, "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "bad": must be moveto or scroll$', (*) => canvas.yview("bad"))
            AhkTest.RaisesMatch(TypeError, "^YView\.yview_moveto\(\) missing 1 required positional argument: 'fraction'$", (*) => canvas.yview_moveto())
            AhkTest.RaisesMatch(TypeError, "^YView\.yview_scroll\(\) missing 1 required positional argument: 'what'$", (*) => canvas.yview_scroll(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCanvasScanAndScaleSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.geometry("240x180+0+0")
            canvas := stdlib.tkinter.Canvas(root, { width: 100, height: 80, scrollregion: "0 0 500 400", xscrollincrement: 10, yscrollincrement: 20 })
            AhkTest.AssertEqual(stdlib.None, canvas.pack())
            lineId := canvas.create_line(10, 20, 30, 40, { tags: "shape" })
            rectId := canvas.create_rectangle(40, 50, 70, 90, { tags: "shape" })
            textId := canvas.create_text(10, 10, { text: "Text", anchor: "nw", tags: "label" })
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual([10.0, 20.0, 30.0, 40.0], canvas.coords(lineId))
            AhkTest.AssertEqual([40.0, 50.0, 70.0, 90.0], canvas.coords(rectId))
            AhkTest.AssertEqual([10.0, 10.0], canvas.coords(textId))
            AhkTest.AssertEqual(stdlib.None, canvas.scale(lineId, 0, 0, 2, 3))
            AhkTest.AssertEqual([20.0, 60.0, 60.0, 120.0], canvas.coords(lineId))
            AhkTest.AssertEqual(stdlib.None, canvas.scale("shape", 10, 10, 0.5, 0.25))
            AhkTest.AssertEqual([15.0, 22.5, 35.0, 37.5], canvas.coords(lineId))
            AhkTest.AssertEqual([25.0, 20.0, 40.0, 30.0], canvas.coords(rectId))
            AhkTest.AssertEqual(stdlib.None, canvas.scale("missing", 0, 0, 2, 2))

            AhkTest.AssertEqual(stdlib.tuple([0.0, 0.2]), canvas.xview())
            AhkTest.AssertEqual(stdlib.tuple([0.0, 0.2]), canvas.yview())
            AhkTest.AssertEqual(stdlib.None, canvas.scan_mark(10, 10))
            AhkTest.AssertEqual(stdlib.tuple([0.0, 0.2]), canvas.xview())
            AhkTest.AssertEqual(stdlib.tuple([0.0, 0.2]), canvas.yview())
            AhkTest.AssertEqual(stdlib.None, canvas.scan_dragto(0, 0))
            AhkTest.AssertEqual(stdlib.tuple([0.2, 0.4]), canvas.xview())
            AhkTest.AssertEqual(stdlib.tuple([0.25, 0.45]), canvas.yview())
            AhkTest.AssertEqual(stdlib.None, canvas.scan_mark(50, 50))
            AhkTest.AssertEqual(stdlib.None, canvas.scan_dragto(40, 40, 1))
            AhkTest.AssertEqual(stdlib.tuple([0.22, 0.42]), canvas.xview())
            AhkTest.AssertEqual(stdlib.tuple([0.3, 0.5]), canvas.yview())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas scale tagOrId xOrigin yOrigin xScale yScale"$', (*) => canvas.scale())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas scale tagOrId xOrigin yOrigin xScale yScale"$', (*) => canvas.scale(lineId, 0, 0, 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas scale tagOrId xOrigin yOrigin xScale yScale"$', (*) => canvas.scale(lineId, 0, 0, 2, 3, 4))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.scale(lineId, "bad", 0, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected floating-point number but got "bad"$', (*) => canvas.scale(lineId, 0, 0, "bad", 3))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.scan_mark\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => canvas.scan_mark())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.scan_mark\(\) missing 1 required positional argument: 'y'$", (*) => canvas.scan_mark(1))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.scan_mark\(\) takes 3 positional arguments but 4 were given$", (*) => canvas.scan_mark(1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => canvas.scan_mark("bad", 2))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.scan_dragto\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => canvas.scan_dragto())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.scan_dragto\(\) missing 1 required positional argument: 'y'$", (*) => canvas.scan_dragto(1))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.scan_dragto\(\) takes from 3 to 4 positional arguments but 5 were given$", (*) => canvas.scan_dragto(1, 2, 3, 4))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => canvas.scan_dragto("bad", 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => canvas.scan_dragto(1, 2, "bad"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCanvasAdditionalItemCreationSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            canvas := stdlib.tkinter.Canvas(root, { width: 140, height: 90, bg: "white" })
            AhkTest.AssertEqual(stdlib.None, canvas.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            ovalId := canvas.create_oval(1, 2, 20, 30, { outline: "blue", fill: "yellow", width: 2, tags: "round shape" })
            polygonId := canvas.create_polygon(0, 0, 10, 0, 5, 8, { fill: "green", outline: "black", tags: "poly shape" })
            textId := canvas.create_text(40, 20, { text: "Hello", anchor: "nw", fill: "red", tags: "caption shape" })

            AhkTest.AssertEqual(stdlib.tuple([ovalId, polygonId, textId]), canvas.find_all())
            AhkTest.AssertEqual(stdlib.tuple([ovalId, polygonId, textId]), canvas.find_withtag("shape"))
            AhkTest.AssertEqual("oval", canvas.type(ovalId))
            AhkTest.AssertEqual("polygon", canvas.type(polygonId))
            AhkTest.AssertEqual("text", canvas.type(textId))
            AhkTest.AssertEqual([1.0, 2.0, 20.0, 30.0], canvas.coords(ovalId))
            AhkTest.AssertEqual([0.0, 0.0, 10.0, 0.0, 5.0, 8.0], canvas.coords(polygonId))
            AhkTest.AssertEqual([40.0, 20.0], canvas.coords(textId))
            AhkTest.AssertEqual("yellow", canvas.itemcget(ovalId, "fill"))
            AhkTest.AssertEqual("2.0", canvas.itemcget(ovalId, "width"))
            AhkTest.AssertEqual("black", canvas.itemcget(polygonId, "outline"))
            AhkTest.AssertEqual("Hello", canvas.itemcget(textId, "text"))
            AhkTest.AssertEqual("nw", canvas.itemcget(textId, "anchor"))

            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => canvas.create_oval())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^wrong # coordinates: expected 0 or 4, got 1$", (*) => canvas.create_oval(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.create_oval("bad", 1, 2, 3))
            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => canvas.create_polygon())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^wrong # coordinates: expected an even number, got 1$", (*) => canvas.create_polygon(1))
            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => canvas.create_text())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^wrong # coordinates: expected 2, got 1$", (*) => canvas.create_text(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.create_text("bad", 1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCanvasArcAndBitmapItemCreationSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            canvas := stdlib.tkinter.Canvas(root, { width: 140, height: 100, bg: "white" })
            AhkTest.AssertEqual(stdlib.None, canvas.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            arcId := canvas.create_arc(5, 6, 40, 50, { start: 30, extent: 120, style: "arc", outline: "purple", width: 3, tags: "curve shape" })
            bitmapId := canvas.create_bitmap(60, 20, { bitmap: "questhead", foreground: "red", background: "white", anchor: "nw", tags: "asset shape" })

            AhkTest.AssertEqual(stdlib.tuple([arcId, bitmapId]), canvas.find_all())
            AhkTest.AssertEqual(stdlib.tuple([arcId, bitmapId]), canvas.find_withtag("shape"))
            AhkTest.AssertEqual("arc", canvas.type(arcId))
            AhkTest.AssertEqual("bitmap", canvas.type(bitmapId))
            AhkTest.AssertEqual([5.0, 6.0, 40.0, 50.0], canvas.coords(arcId))
            AhkTest.AssertEqual([60.0, 20.0], canvas.coords(bitmapId))
            AhkTest.AssertEqual("30.0", canvas.itemcget(arcId, "start"))
            AhkTest.AssertEqual("120.0", canvas.itemcget(arcId, "extent"))
            AhkTest.AssertEqual("arc", canvas.itemcget(arcId, "style"))
            AhkTest.AssertEqual("purple", canvas.itemcget(arcId, "outline"))
            AhkTest.AssertEqual("3.0", canvas.itemcget(arcId, "width"))
            AhkTest.AssertEqual("questhead", canvas.itemcget(bitmapId, "bitmap"))
            AhkTest.AssertEqual("red", canvas.itemcget(bitmapId, "foreground"))
            AhkTest.AssertEqual("white", canvas.itemcget(bitmapId, "background"))
            AhkTest.AssertEqual("nw", canvas.itemcget(bitmapId, "anchor"))
            AhkTest.AssertEqual(stdlib.tuple([4, 3, 40, 20]), canvas.bbox(arcId))
            AhkTest.AssertEqual(stdlib.tuple([60, 20, 80, 42]), canvas.bbox(bitmapId))

            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => canvas.create_arc())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^wrong # coordinates: expected 4, got 1$", (*) => canvas.create_arc(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.create_arc("bad", 1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => canvas.create_arc(1, 2, 3, 4, { bad: 1 }))
            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => canvas.create_bitmap())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^wrong # coordinates: expected 2, got 1$", (*) => canvas.create_bitmap(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.create_bitmap("bad", 1, { bitmap: "questhead" }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bitmap "missing_bitmap_name" not defined$', (*) => canvas.create_bitmap(1, 2, { bitmap: "missing_bitmap_name" }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => canvas.create_bitmap(1, 2, { bad: 1 }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCanvasTextItemEditAndSelectionSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            canvas := stdlib.tkinter.Canvas(root, { width: 200, height: 100, bg: "white" })
            AhkTest.AssertEqual(stdlib.None, canvas.pack())
            textId := canvas.create_text(10, 10, { text: "Hello", anchor: "nw", tags: "caption editable" })
            rectId := canvas.create_rectangle(80, 10, 120, 40, { tags: "box" })
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual("Hello", canvas.itemcget(textId, "text"))
            AhkTest.AssertEqual(5, canvas.index(textId, "end"))
            AhkTest.AssertEqual(2, canvas.index(textId, 2))
            AhkTest.AssertEqual("", canvas.focus())
            AhkTest.AssertEqual("", canvas.focus(textId))
            AhkTest.AssertEqual(textId, canvas.focus())
            AhkTest.AssertEqual("", canvas.focus("missing"))
            AhkTest.AssertEqual(textId, canvas.focus())
            AhkTest.AssertEqual("", canvas.focus(rectId))
            AhkTest.AssertEqual(textId, canvas.focus())
            AhkTest.AssertEqual(stdlib.None, canvas.icursor(textId, 2))
            AhkTest.AssertEqual(stdlib.None, canvas.insert(textId, 2, "YY"))
            AhkTest.AssertEqual("HeYYllo", canvas.itemcget(textId, "text"))
            AhkTest.AssertEqual(7, canvas.index(textId, "end"))
            AhkTest.AssertEqual(stdlib.None, canvas.dchars(textId, 2))
            AhkTest.AssertEqual("HeYllo", canvas.itemcget(textId, "text"))
            AhkTest.AssertEqual(stdlib.None, canvas.dchars(textId, 2, 3))
            AhkTest.AssertEqual("Helo", canvas.itemcget(textId, "text"))
            AhkTest.AssertEqual(stdlib.None, canvas.insert(textId, "end", "!"))
            AhkTest.AssertEqual("Helo!", canvas.itemcget(textId, "text"))
            AhkTest.AssertEqual(stdlib.None, canvas.select_item())
            AhkTest.AssertEqual(stdlib.None, canvas.select_from(textId, 1))
            AhkTest.AssertEqual(stdlib.None, canvas.select_item())
            AhkTest.AssertEqual(stdlib.None, canvas.select_to(textId, 4))
            AhkTest.AssertEqual(textId, canvas.select_item())
            AhkTest.AssertEqual(stdlib.None, canvas.select_adjust(textId, 2))
            AhkTest.AssertEqual(textId, canvas.select_item())
            AhkTest.AssertEqual(stdlib.None, canvas.select_clear())
            AhkTest.AssertEqual(stdlib.None, canvas.select_item())
            AhkTest.AssertEqual(stdlib.None, canvas.dchars("missing", 1))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas dchars tagOrId first \?last\?"$', (*) => canvas.dchars())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas dchars tagOrId first \?last\?"$', (*) => canvas.dchars(textId))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas dchars tagOrId first \?last\?"$', (*) => canvas.dchars(textId, 1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad index "bad"$', (*) => canvas.dchars(textId, "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas focus \?tagOrId\?"$', (*) => canvas.focus(textId, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas icursor tagOrId index"$', (*) => canvas.icursor())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas icursor tagOrId index"$', (*) => canvas.icursor(textId))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad index "bad"$', (*) => canvas.icursor(textId, "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas index tagOrId string"$', (*) => canvas.index())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas index tagOrId string"$', (*) => canvas.index(textId))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad index "bad"$', (*) => canvas.index(textId, "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^can't find an indexable item `"missing`"$", (*) => canvas.index("missing", 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^can't find an indexable item `"" rectId "`"$", (*) => canvas.index(rectId, 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas insert tagOrId beforeThis string"$', (*) => canvas.insert())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!canvas insert tagOrId beforeThis string"$', (*) => canvas.insert(textId, 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad index "bad"$', (*) => canvas.insert(textId, "bad", "x"))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.select_adjust\(\) missing 2 required positional arguments: 'tagOrId' and 'index'$", (*) => canvas.select_adjust())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.select_adjust\(\) missing 1 required positional argument: 'index'$", (*) => canvas.select_adjust(textId))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.select_adjust\(\) takes 3 positional arguments but 4 were given$", (*) => canvas.select_adjust(textId, 1, 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad index "bad"$', (*) => canvas.select_adjust(textId, "bad"))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.select_clear\(\) takes 1 positional argument but 2 were given$", (*) => canvas.select_clear(1))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.select_from\(\) missing 2 required positional arguments: 'tagOrId' and 'index'$", (*) => canvas.select_from())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.select_from\(\) missing 1 required positional argument: 'index'$", (*) => canvas.select_from(textId))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.select_item\(\) takes 1 positional argument but 2 were given$", (*) => canvas.select_item(1))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.select_to\(\) missing 2 required positional arguments: 'tagOrId' and 'index'$", (*) => canvas.select_to())
            AhkTest.RaisesMatch(TypeError, "^Canvas\.select_to\(\) missing 1 required positional argument: 'index'$", (*) => canvas.select_to(textId))
            AhkTest.RaisesMatch(TypeError, "^Canvas\.select_to\(\) takes 3 positional arguments but 4 were given$", (*) => canvas.select_to(textId, 1, 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad index "bad"$', (*) => canvas.select_to(textId, "bad"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestCanvasImageAndWindowItemSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            canvas := stdlib.tkinter.Canvas(root, { width: 120, height: 80, bg: "white" })
            AhkTest.AssertEqual(stdlib.None, canvas.pack())
            image := stdlib.tkinter.PhotoImage({ master: root, width: 2, height: 2 })
            AhkTest.AssertEqual(stdlib.None, image.put("#ff0000", { to: [0, 0] }))
            label := stdlib.tkinter.Label(root, { text: "Inside" })
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            imageItem := canvas.create_image(10, 11, { image: image, anchor: "nw", tags: "asset media" })
            windowItem := canvas.create_window(30, 31, { window: label, anchor: "nw", width: 70, height: 20, tags: "embedded media" })

            AhkTest.AssertEqual(stdlib.tuple([imageItem, windowItem]), canvas.find_all())
            AhkTest.AssertEqual(stdlib.tuple([imageItem, windowItem]), canvas.find_withtag("media"))
            AhkTest.AssertEqual("image", canvas.type(imageItem))
            AhkTest.AssertEqual("window", canvas.type(windowItem))
            AhkTest.AssertEqual([10.0, 11.0], canvas.coords(imageItem))
            AhkTest.AssertEqual([30.0, 31.0], canvas.coords(windowItem))
            AhkTest.AssertEqual(String(image), canvas.itemcget(imageItem, "image"))
            AhkTest.AssertEqual("nw", canvas.itemcget(imageItem, "anchor"))
            AhkTest.AssertEqual(String(label), canvas.itemcget(windowItem, "window"))
            AhkTest.AssertEqual("nw", canvas.itemcget(windowItem, "anchor"))
            AhkTest.AssertEqual("70", canvas.itemcget(windowItem, "width"))
            AhkTest.AssertEqual("20", canvas.itemcget(windowItem, "height"))
            AhkTest.AssertEqual(stdlib.tuple([10, 11, 12, 13]), canvas.bbox(imageItem))
            AhkTest.AssertEqual(stdlib.tuple([30, 31, 100, 51]), canvas.bbox(windowItem))

            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => canvas.create_image())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^wrong # coordinates: expected 2, got 1$", (*) => canvas.create_image(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.create_image("bad", 1, { image: image }))
            AhkTest.RaisesMatch(IndexError, "^tuple index out of range$", (*) => canvas.create_window())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^wrong # coordinates: expected 2, got 1$", (*) => canvas.create_window(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => canvas.create_window("bad", 1, { window: label }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestGridAndPlaceManagersMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            frame := stdlib.tkinter.Frame(root, { name: "host", width: 100, height: 80 })
            label := stdlib.tkinter.Label(frame, { text: "Hello" })
            entry := stdlib.tkinter.Entry(root, { width: 12 })

            AhkTest.AssertEqual(stdlib.None, frame.grid({ row: 1, column: 2, padx: 3, pady: 4, sticky: "nsew" }))
            AhkTest.AssertEqual("grid", frame.winfo_manager())
            gridInfo := frame.grid_info()
            AhkTest.AssertTrue(gridInfo is Map)
            AhkTest.AssertSame(root, gridInfo["in"])
            AhkTest.AssertEqual(2, gridInfo["column"])
            AhkTest.AssertEqual(1, gridInfo["row"])
            AhkTest.AssertEqual(1, gridInfo["columnspan"])
            AhkTest.AssertEqual(1, gridInfo["rowspan"])
            AhkTest.AssertEqual(0, gridInfo["ipadx"])
            AhkTest.AssertEqual(0, gridInfo["ipady"])
            AhkTest.AssertEqual(3, gridInfo["padx"])
            AhkTest.AssertEqual(4, gridInfo["pady"])
            AhkTest.AssertEqual("nesw", gridInfo["sticky"])

            AhkTest.AssertEqual(stdlib.None, label.place({ x: 5, y: 6, width: 70, height: 20, anchor: "nw" }))
            AhkTest.AssertEqual("place", label.winfo_manager())
            placeInfo := label.place_info()
            AhkTest.AssertTrue(placeInfo is Map)
            AhkTest.AssertSame(frame, placeInfo["in"])
            AhkTest.AssertEqual("5", placeInfo["x"])
            AhkTest.AssertEqual("0", placeInfo["relx"])
            AhkTest.AssertEqual("6", placeInfo["y"])
            AhkTest.AssertEqual("0", placeInfo["rely"])
            AhkTest.AssertEqual("70", placeInfo["width"])
            AhkTest.AssertEqual("", placeInfo["relwidth"])
            AhkTest.AssertEqual("20", placeInfo["height"])
            AhkTest.AssertEqual("", placeInfo["relheight"])
            AhkTest.AssertEqual("nw", placeInfo["anchor"])
            AhkTest.AssertEqual("inside", placeInfo["bordermode"])

            AhkTest.AssertEqual(stdlib.None, entry.place())
            AhkTest.AssertEqual("", entry.winfo_manager())
            AhkTest.AssertEqual(0, entry.place_info().Count)
            AhkTest.AssertEqual(stdlib.None, frame.grid())
            AhkTest.AssertEqual(1, frame.grid_info()["row"])
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestGridRowAndColumnConfigureSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            host := stdlib.tkinter.Frame(root, { name: "gridhost", width: 200, height: 120 })
            label := stdlib.tkinter.Label(host, { text: "A" })
            AhkTest.AssertEqual(stdlib.None, host.grid())
            AhkTest.AssertEqual(stdlib.None, label.grid({ row: 0, column: 0 }))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            initialColumn := host.grid_columnconfigure(0)
            AhkTest.AssertEqual(0, initialColumn["minsize"])
            AhkTest.AssertEqual(0, initialColumn["pad"])
            AhkTest.AssertEqual(stdlib.None, initialColumn["uniform"])
            AhkTest.AssertEqual(0, initialColumn["weight"])
            AhkTest.AssertEqual(0, host.grid_columnconfigure(0, "weight"))
            AhkTest.AssertEqual(0, root.columnconfigure(0, "weight"))
            AhkTest.AssertEqual(0, label.grid_rowconfigure(0, "weight"))

            AhkTest.AssertEqual(stdlib.None, host.grid_columnconfigure(0, { weight: 2, minsize: 30, pad: 4, uniform: "group" }))
            columnInfo := host.grid_columnconfigure(0)
            AhkTest.AssertEqual(30, columnInfo["minsize"])
            AhkTest.AssertEqual(4, columnInfo["pad"])
            AhkTest.AssertEqual("group", columnInfo["uniform"])
            AhkTest.AssertEqual(2, columnInfo["weight"])
            AhkTest.AssertEqual(2, host.columnconfigure(0, "weight"))
            AhkTest.AssertEqual(30, host.grid_columnconfigure(0, "minsize"))
            AhkTest.AssertEqual(4, host.grid_columnconfigure(0, "pad"))
            AhkTest.AssertEqual("group", host.grid_columnconfigure(0, "uniform"))

            AhkTest.AssertEqual(stdlib.None, host.columnconfigure(1, { weight: 3, minsize: 10 }))
            columnOneInfo := host.grid_columnconfigure(1)
            AhkTest.AssertEqual(10, columnOneInfo["minsize"])
            AhkTest.AssertEqual(0, columnOneInfo["pad"])
            AhkTest.AssertEqual(stdlib.None, columnOneInfo["uniform"])
            AhkTest.AssertEqual(3, columnOneInfo["weight"])

            AhkTest.AssertEqual(stdlib.None, host.grid_rowconfigure(0, { weight: 5, minsize: 25, pad: 6, uniform: "rows" }))
            rowInfo := host.grid_rowconfigure(0)
            AhkTest.AssertEqual(25, rowInfo["minsize"])
            AhkTest.AssertEqual(6, rowInfo["pad"])
            AhkTest.AssertEqual("rows", rowInfo["uniform"])
            AhkTest.AssertEqual(5, rowInfo["weight"])
            AhkTest.AssertEqual(5, host.rowconfigure(0, "weight"))
            AhkTest.AssertEqual(25, host.grid_rowconfigure(0, "minsize"))
            AhkTest.AssertEqual(6, host.grid_rowconfigure(0, "pad"))
            AhkTest.AssertEqual("rows", host.grid_rowconfigure(0, "uniform"))

            AhkTest.AssertEqual(stdlib.None, host.rowconfigure(1, { weight: 7, pad: 8 }))
            rowOneInfo := host.grid_rowconfigure(1)
            AhkTest.AssertEqual(0, rowOneInfo["minsize"])
            AhkTest.AssertEqual(8, rowOneInfo["pad"])
            AhkTest.AssertEqual(stdlib.None, rowOneInfo["uniform"])
            AhkTest.AssertEqual(7, rowOneInfo["weight"])

            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_columnconfigure\(\) missing 1 required positional argument: 'index'$", (*) => host.grid_columnconfigure())
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_columnconfigure\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => host.columnconfigure(0, {}, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_rowconfigure\(\) missing 1 required positional argument: 'index'$", (*) => host.grid_rowconfigure())
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_rowconfigure\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => host.rowconfigure(0, {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad" \(when retrieving options only integer indices are allowed\)$', (*) => host.grid_columnconfigure("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad option "-bad": must be -minsize, -pad, -uniform, or -weight$', (*) => host.grid_columnconfigure(0, { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => host.grid_rowconfigure(0, { weight: "bad" }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestLayoutPropagationAndGridAnchorSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            packHost := stdlib.tkinter.Frame(root, { name: "packhost", width: 120, height: 90 })
            AhkTest.AssertEqual(stdlib.None, packHost.pack())
            gridShell := stdlib.tkinter.Toplevel(root, { name: "gridshell" })
            AhkTest.AssertEqual("", gridShell.withdraw())
            gridHost := stdlib.tkinter.Frame(gridShell, { name: "gridhost", width: 120, height: 90 })
            AhkTest.AssertEqual(stdlib.None, gridHost.grid())

            for owner in [root, packHost, gridShell, gridHost] {
                AhkTest.AssertSame(stdlib.True, owner.pack_propagate())
                AhkTest.AssertEqual(stdlib.None, owner.pack_propagate(stdlib.False))
                AhkTest.AssertEqual(stdlib.None, owner.pack_propagate())
                AhkTest.AssertEqual(stdlib.None, owner.pack_propagate(stdlib.True))
                AhkTest.AssertSame(stdlib.True, owner.pack_propagate())
                AhkTest.AssertEqual(stdlib.None, owner.pack_propagate(stdlib.None))
                AhkTest.AssertSame(stdlib.True, owner.pack_propagate())
                AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected boolean value but got "bad"$', ObjBindMethod(owner, "pack_propagate", "bad"))
                AhkTest.RaisesMatch(TypeError, "^Misc\.pack_propagate\(\) takes from 1 to 2 positional arguments but 3 were given$", ObjBindMethod(owner, "pack_propagate", stdlib.True, stdlib.False))

                AhkTest.AssertSame(stdlib.True, owner.grid_propagate())
                AhkTest.AssertEqual(stdlib.None, owner.grid_propagate(stdlib.False))
                AhkTest.AssertEqual(stdlib.None, owner.grid_propagate())
                AhkTest.AssertEqual(stdlib.None, owner.grid_propagate(stdlib.True))
                AhkTest.AssertSame(stdlib.True, owner.grid_propagate())
                AhkTest.AssertEqual(stdlib.None, owner.grid_propagate(stdlib.None))
                AhkTest.AssertSame(stdlib.True, owner.grid_propagate())
                AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected boolean value but got "bad"$', ObjBindMethod(owner, "grid_propagate", "bad"))
                AhkTest.RaisesMatch(TypeError, "^Misc\.grid_propagate\(\) takes from 1 to 2 positional arguments but 3 were given$", ObjBindMethod(owner, "grid_propagate", stdlib.True, stdlib.False))

                AhkTest.AssertEqual(stdlib.None, owner.grid_anchor())
                AhkTest.AssertEqual(stdlib.None, owner.grid_anchor("center"))
                AhkTest.AssertEqual(stdlib.None, owner.grid_anchor())
                AhkTest.AssertEqual(stdlib.None, owner.grid_anchor("n"))
                AhkTest.AssertEqual(stdlib.None, owner.grid_anchor())
                AhkTest.AssertEqual(stdlib.None, owner.grid_anchor(stdlib.None))
                AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad anchor "bad": must be n, ne, e, se, s, sw, w, nw, or center$', ObjBindMethod(owner, "grid_anchor", "bad"))
                AhkTest.RaisesMatch(TypeError, "^Misc\.grid_anchor\(\) takes from 1 to 2 positional arguments but 3 were given$", ObjBindMethod(owner, "grid_anchor", "n", "s"))
            }
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestLayoutInfoForgetAndRemoveSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            packHost := stdlib.tkinter.Frame(root, { name: "packhost", width: 120, height: 90 })
            gridHost := stdlib.tkinter.Frame(root, { name: "gridhost", width: 120, height: 90 })
            placeHost := stdlib.tkinter.Frame(root, { name: "placehost", width: 120, height: 90 })
            AhkTest.AssertEqual(stdlib.None, packHost.pack())
            AhkTest.AssertEqual(stdlib.None, gridHost.pack())
            AhkTest.AssertEqual(stdlib.None, placeHost.pack())
            packed := stdlib.tkinter.Label(packHost, { name: "packed", text: "Packed" })
            gridded := stdlib.tkinter.Label(gridHost, { name: "gridded", text: "Grid" })
            placed := stdlib.tkinter.Label(placeHost, { name: "placed", text: "Place" })
            AhkTest.AssertEqual(stdlib.None, packed.pack({ side: "left", fill: "x", expand: stdlib.True, padx: 3, pady: 4, ipadx: 5, ipady: 6, anchor: "n" }))
            AhkTest.AssertEqual(stdlib.None, gridded.grid({ row: 1, column: 2, padx: 7, pady: 8, ipadx: 9, ipady: 10, sticky: "nsew", columnspan: 3, rowspan: 4 }))
            AhkTest.AssertEqual(stdlib.None, placed.place({ x: 11, y: 12, width: 70, height: 20, anchor: "nw" }))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            packInfo := packed.pack_info()
            AhkTest.AssertSame(packHost, packInfo["in"])
            AhkTest.AssertEqual("n", packInfo["anchor"])
            AhkTest.AssertEqual(1, packInfo["expand"])
            AhkTest.AssertEqual("x", packInfo["fill"])
            AhkTest.AssertEqual(5, packInfo["ipadx"])
            AhkTest.AssertEqual(6, packInfo["ipady"])
            AhkTest.AssertEqual(3, packInfo["padx"])
            AhkTest.AssertEqual(4, packInfo["pady"])
            AhkTest.AssertEqual("left", packInfo["side"])
            AhkTest.AssertEqual(stdlib.None, packed.pack_forget())
            AhkTest.AssertEqual("", packed.winfo_manager())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^window " Chr(34) "\.packhost\.packed" Chr(34) " isn't packed$", (*) => packed.pack_info())
            AhkTest.AssertEqual(stdlib.None, packed.pack())
            restoredPackInfo := packed.pack_info()
            AhkTest.AssertEqual("center", restoredPackInfo["anchor"])
            AhkTest.AssertEqual(0, restoredPackInfo["expand"])
            AhkTest.AssertEqual("none", restoredPackInfo["fill"])
            AhkTest.AssertEqual(0, restoredPackInfo["padx"])
            AhkTest.AssertEqual("top", restoredPackInfo["side"])

            AhkTest.AssertEqual(stdlib.None, gridded.grid_forget())
            AhkTest.AssertEqual("", gridded.winfo_manager())
            AhkTest.AssertEqual(Map(), gridded.grid_info())
            AhkTest.AssertEqual(stdlib.None, gridded.grid())
            gridInfoAfterForgetRestore := gridded.grid_info()
            AhkTest.AssertSame(gridHost, gridInfoAfterForgetRestore["in"])
            AhkTest.AssertEqual(0, gridInfoAfterForgetRestore["column"])
            AhkTest.AssertEqual(0, gridInfoAfterForgetRestore["row"])
            AhkTest.AssertEqual(1, gridInfoAfterForgetRestore["columnspan"])
            AhkTest.AssertEqual(1, gridInfoAfterForgetRestore["rowspan"])
            AhkTest.AssertEqual("", gridInfoAfterForgetRestore["sticky"])
            AhkTest.AssertEqual(stdlib.None, gridded.grid({ row: 1, column: 2, padx: 7, pady: 8, sticky: "nsew" }))
            AhkTest.AssertEqual(stdlib.None, gridded.grid_remove())
            AhkTest.AssertEqual("", gridded.winfo_manager())
            AhkTest.AssertEqual(Map(), gridded.grid_info())
            AhkTest.AssertEqual(stdlib.None, gridded.grid())
            gridInfoAfterRemoveRestore := gridded.grid_info()
            AhkTest.AssertEqual(2, gridInfoAfterRemoveRestore["column"])
            AhkTest.AssertEqual(1, gridInfoAfterRemoveRestore["row"])
            AhkTest.AssertEqual(7, gridInfoAfterRemoveRestore["padx"])
            AhkTest.AssertEqual(8, gridInfoAfterRemoveRestore["pady"])
            AhkTest.AssertEqual("nesw", gridInfoAfterRemoveRestore["sticky"])

            AhkTest.AssertEqual(stdlib.None, placed.place_forget())
            AhkTest.AssertEqual("", placed.winfo_manager())
            AhkTest.AssertEqual(Map(), placed.place_info())
            AhkTest.AssertEqual(stdlib.None, placed.place())
            AhkTest.AssertEqual(Map(), placed.place_info())

            AhkTest.RaisesMatch(TypeError, "^Pack\.pack_info\(\) takes 1 positional argument but 2 were given$", (*) => packed.pack_info(1))
            AhkTest.RaisesMatch(TypeError, "^Pack\.pack_forget\(\) takes 1 positional argument but 2 were given$", (*) => packed.pack_forget(1))
            AhkTest.RaisesMatch(TypeError, "^Grid\.grid_forget\(\) takes 1 positional argument but 2 were given$", (*) => gridded.grid_forget(1))
            AhkTest.RaisesMatch(TypeError, "^Grid\.grid_remove\(\) takes 1 positional argument but 2 were given$", (*) => gridded.grid_remove(1))
            AhkTest.RaisesMatch(TypeError, "^Place\.place_forget\(\) takes 1 positional argument but 2 were given$", (*) => placed.place_forget(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestLayoutAliasSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            packHost := stdlib.tkinter.Frame(root, { name: "alias_packhost" })
            gridShell := stdlib.tkinter.Toplevel(root, { name: "alias_gridshell" })
            placeShell := stdlib.tkinter.Toplevel(root, { name: "alias_placeshell" })
            gridHost := stdlib.tkinter.Frame(gridShell, { name: "gridhost" })
            placeHost := stdlib.tkinter.Frame(placeShell, { name: "placehost" })
            packed := stdlib.tkinter.Label(packHost, { name: "packed", text: "P" })
            gridded := stdlib.tkinter.Label(gridHost, { name: "gridded", text: "G" })
            placed := stdlib.tkinter.Label(placeHost, { name: "placed", text: "L" })
            AhkTest.AssertEqual(stdlib.None, packHost.pack())
            AhkTest.AssertEqual("", gridShell.withdraw())
            AhkTest.AssertEqual(stdlib.None, gridHost.grid())
            AhkTest.AssertEqual("", placeShell.withdraw())
            AhkTest.AssertEqual(stdlib.None, placeHost.pack())
            AhkTest.AssertEqual(stdlib.None, packed.pack({ side: "left", padx: 3 }))
            AhkTest.AssertEqual(stdlib.None, gridded.grid({ row: 1, column: 2, padx: 4 }))
            AhkTest.AssertEqual(stdlib.None, placed.place({ x: 10, y: 20 }))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            AhkTest.AssertEqual(stdlib.None, packed.pack_configure({ pady: 5 }))
            packedInfo := packed.info()
            AhkTest.AssertSame(packHost, packedInfo["in"])
            AhkTest.AssertEqual(3, packedInfo["padx"])
            AhkTest.AssertEqual(5, packedInfo["pady"])
            AhkTest.AssertEqual("left", packedInfo["side"])
            packChildren := packHost.slaves()
            AhkTest.AssertEqual(1, packChildren.Length)
            AhkTest.AssertSame(packed, packChildren[1])
            AhkTest.AssertSame(stdlib.True, packHost.propagate())
            AhkTest.AssertEqual(stdlib.None, packHost.propagate(stdlib.False))
            AhkTest.AssertEqual(stdlib.None, packHost.propagate())
            AhkTest.AssertEqual(stdlib.None, packed.forget())
            AhkTest.AssertEqual("", packed.winfo_manager())

            AhkTest.AssertEqual(stdlib.None, gridded.grid_configure({ row: 2, column: 3 }))
            gridInfo := gridded.grid_info()
            AhkTest.AssertEqual(2, gridInfo["row"])
            AhkTest.AssertEqual(3, gridInfo["column"])
            AhkTest.AssertEqual(stdlib.tuple([0, 0, 0, 0]), gridHost.bbox())
            AhkTest.AssertEqual(stdlib.tuple([3, 2]), gridHost.location(5, 5))
            AhkTest.AssertEqual(stdlib.tuple([4, 3]), gridHost.size())
            AhkTest.AssertEqual(stdlib.None, gridHost.anchor())
            AhkTest.AssertEqual(stdlib.None, gridHost.anchor("n"))
            AhkTest.AssertEqual(stdlib.None, gridHost.anchor())
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), root.size())
            AhkTest.AssertEqual(stdlib.None, root.anchor())

            AhkTest.AssertEqual(stdlib.None, placed.place_configure({ x: 15, y: 25 }))
            placeInfo := placed.place_info()
            AhkTest.AssertEqual("15", placeInfo["x"])
            AhkTest.AssertEqual("25", placeInfo["y"])
            AhkTest.AssertEqual(stdlib.None, placed.place({ x: 16, y: 26 }))
            placeInfoAfterAlias := placed.place_info()
            AhkTest.AssertEqual("16", placeInfoAfterAlias["x"])
            AhkTest.AssertEqual("26", placeInfoAfterAlias["y"])
            placeChildren := placeHost.place_slaves()
            AhkTest.AssertEqual(1, placeChildren.Length)
            AhkTest.AssertSame(placed, placeChildren[1])

            AhkTest.RaisesMatch(TypeError, "^Pack\.pack_configure\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => packed.pack_configure({}, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Grid\.grid_configure\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => gridded.grid_configure({}, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Place\.place_configure\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => placed.place_configure({}, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Pack\.pack_info\(\) takes 1 positional argument but 2 were given$", (*) => packed.info(1))
            AhkTest.RaisesMatch(TypeError, "^Pack\.pack_forget\(\) takes 1 positional argument but 2 were given$", (*) => packed.forget(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.pack_slaves\(\) takes 1 positional argument but 2 were given$", (*) => root.slaves(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.pack_propagate\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.propagate(stdlib.True, stdlib.False))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_anchor\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.anchor("n", "s"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_bbox\(\) takes from 1 to 5 positional arguments but 6 were given$", (*) => root.bbox(1, 2, 3, 4, 5))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_size\(\) takes 1 positional argument but 2 were given$", (*) => root.size(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestLayoutSlaveQuerySurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            packHost := stdlib.tkinter.Frame(root, { name: "packhost" })
            gridHost := stdlib.tkinter.Frame(root, { name: "gridhost" })
            placeHost := stdlib.tkinter.Frame(root, { name: "placehost" })
            AhkTest.AssertEqual(stdlib.None, packHost.pack())
            AhkTest.AssertEqual(stdlib.None, gridHost.pack())
            AhkTest.AssertEqual(stdlib.None, placeHost.pack())
            packedOne := stdlib.tkinter.Label(packHost, { name: "p1", text: "p1" })
            packedTwo := stdlib.tkinter.Label(packHost, { name: "p2", text: "p2" })
            griddedOrigin := stdlib.tkinter.Label(gridHost, { name: "g00", text: "00" })
            griddedFirst := stdlib.tkinter.Label(gridHost, { name: "g12a", text: "12a" })
            griddedSecond := stdlib.tkinter.Label(gridHost, { name: "g12b", text: "12b" })
            placedOne := stdlib.tkinter.Label(placeHost, { name: "pl1", text: "pl1" })
            placedTwo := stdlib.tkinter.Label(placeHost, { name: "pl2", text: "pl2" })
            AhkTest.AssertEqual(stdlib.None, packedOne.pack())
            AhkTest.AssertEqual(stdlib.None, packedTwo.pack())
            AhkTest.AssertEqual(stdlib.None, griddedOrigin.grid({ row: 0, column: 0 }))
            AhkTest.AssertEqual(stdlib.None, griddedFirst.grid({ row: 1, column: 2 }))
            AhkTest.AssertEqual(stdlib.None, griddedSecond.grid({ row: 1, column: 2 }))
            AhkTest.AssertEqual(stdlib.None, placedOne.place({ x: 1, y: 2 }))
            AhkTest.AssertEqual(stdlib.None, placedTwo.place({ x: 3, y: 4 }))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            rootPacked := root.pack_slaves()
            AhkTest.AssertEqual(3, rootPacked.Length)
            AhkTest.AssertSame(packHost, rootPacked[1])
            AhkTest.AssertSame(gridHost, rootPacked[2])
            AhkTest.AssertSame(placeHost, rootPacked[3])
            AhkTest.AssertEqual([], root.grid_slaves())
            AhkTest.AssertEqual([], root.place_slaves())

            packedChildren := packHost.pack_slaves()
            AhkTest.AssertEqual(2, packedChildren.Length)
            AhkTest.AssertSame(packedOne, packedChildren[1])
            AhkTest.AssertSame(packedTwo, packedChildren[2])
            gridChildren := gridHost.grid_slaves()
            AhkTest.AssertEqual(3, gridChildren.Length)
            AhkTest.AssertSame(griddedSecond, gridChildren[1])
            AhkTest.AssertSame(griddedFirst, gridChildren[2])
            AhkTest.AssertSame(griddedOrigin, gridChildren[3])
            gridRowChildren := gridHost.grid_slaves(1)
            AhkTest.AssertEqual(2, gridRowChildren.Length)
            AhkTest.AssertSame(griddedSecond, gridRowChildren[1])
            AhkTest.AssertSame(griddedFirst, gridRowChildren[2])
            gridColumnChildren := gridHost.grid_slaves({ column: 2 })
            AhkTest.AssertEqual(2, gridColumnChildren.Length)
            AhkTest.AssertSame(griddedSecond, gridColumnChildren[1])
            AhkTest.AssertSame(griddedFirst, gridColumnChildren[2])
            gridCellChildren := gridHost.grid_slaves(1, 2)
            AhkTest.AssertEqual(2, gridCellChildren.Length)
            AhkTest.AssertSame(griddedSecond, gridCellChildren[1])
            AhkTest.AssertSame(griddedFirst, gridCellChildren[2])
            placeChildren := placeHost.place_slaves()
            AhkTest.AssertEqual(2, placeChildren.Length)
            AhkTest.AssertSame(placedTwo, placeChildren[1])
            AhkTest.AssertSame(placedOne, placeChildren[2])

            AhkTest.AssertEqual(stdlib.None, packedOne.pack_forget())
            AhkTest.AssertEqual(stdlib.None, griddedSecond.grid_forget())
            AhkTest.AssertEqual(stdlib.None, placedOne.place_forget())
            AhkTest.AssertEqual(1, packHost.pack_slaves().Length)
            AhkTest.AssertSame(packedTwo, packHost.pack_slaves()[1])
            AhkTest.AssertEqual(2, gridHost.grid_slaves().Length)
            AhkTest.AssertSame(griddedFirst, gridHost.grid_slaves()[1])
            AhkTest.AssertEqual(1, placeHost.place_slaves().Length)
            AhkTest.AssertSame(placedTwo, placeHost.place_slaves()[1])

            AhkTest.RaisesMatch(TypeError, "^Misc\.pack_slaves\(\) takes 1 positional argument but 2 were given$", (*) => packHost.pack_slaves(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_slaves\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => gridHost.grid_slaves(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_slaves\(\) got an unexpected keyword argument 'bad'$", (*) => gridHost.grid_slaves({ bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => gridHost.grid_slaves({ row: "bad" }))
            AhkTest.RaisesMatch(TypeError, "^Misc\.place_slaves\(\) takes 1 positional argument but 2 were given$", (*) => placeHost.place_slaves(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestGridGeometryQuerySurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            host := stdlib.tkinter.Frame(root, { name: "gridhost", width: 200, height: 120, bg: "white" })
            AhkTest.AssertEqual(stdlib.None, host.pack())
            labelOrigin := stdlib.tkinter.Label(host, { name: "a", text: "A", width: 4 })
            labelWide := stdlib.tkinter.Label(host, { name: "b", text: "B", width: 6 })
            labelBottom := stdlib.tkinter.Label(host, { name: "c", text: "C", width: 3 })
            AhkTest.AssertEqual(stdlib.None, labelOrigin.grid({ row: 0, column: 0, ipadx: 2, ipady: 1, padx: 3, pady: 4 }))
            AhkTest.AssertEqual(stdlib.None, labelWide.grid({ row: 1, column: 2, columnspan: 2, ipadx: 1, ipady: 2, padx: 5, pady: 6 }))
            AhkTest.AssertEqual(stdlib.None, labelBottom.grid({ row: 2, column: 1, sticky: "nsew" }))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual(stdlib.tuple([0, 0]), root.grid_size())
            AhkTest.AssertEqual(stdlib.tuple([4, 3]), host.grid_size())
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), labelOrigin.grid_size())
            wholeBox := host.grid_bbox()
            originBox := host.grid_bbox(0, 0)
            rowCellBox := host.grid_bbox(2, 1)
            spannedBox := host.grid_bbox(2, 1, 3, 1)
            AhkTest.AssertEqual(4, wholeBox.Length)
            AhkTest.AssertEqual(4, originBox.Length)
            AhkTest.AssertEqual(4, rowCellBox.Length)
            AhkTest.AssertTrue(wholeBox[3] > originBox[3])
            AhkTest.AssertTrue(wholeBox[4] > originBox[4])
            AhkTest.AssertTrue(spannedBox[3] >= rowCellBox[3])
            AhkTest.AssertEqual(wholeBox, host.grid_bbox("bad"))
            AhkTest.AssertEqual(wholeBox, host.grid_bbox({ column: 2 }))
            AhkTest.AssertEqual(rowCellBox, host.grid_bbox({ column: 2, row: 1 }))
            AhkTest.AssertEqual(rowCellBox, host.grid_bbox({ col2: 2, row2: 1 }))
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), host.grid_location(0, 0))
            AhkTest.AssertEqual(stdlib.tuple([4, 3]), host.grid_location(999, 999))
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), host.grid_location(originBox[1] + Floor(originBox[3] / 2), originBox[2] + Floor(originBox[4] / 2)))
            AhkTest.AssertEqual(stdlib.tuple([2, 1]), host.grid_location(rowCellBox[1] + Floor(rowCellBox[3] / 2), rowCellBox[2] + Floor(rowCellBox[4] / 2)))
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), host.grid_location({ x: 0, y: 0 }))

            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_size\(\) takes 1 positional argument but 2 were given$", (*) => host.grid_size(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_bbox\(\) takes from 1 to 5 positional arguments but 6 were given$", (*) => host.grid_bbox(1, 2, 3, 4, 5))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_bbox\(\) got an unexpected keyword argument 'bad'$", (*) => host.grid_bbox({ bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => host.grid_bbox("bad", 1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_location\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => host.grid_location())
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_location\(\) missing 1 required positional argument: 'y'$", (*) => host.grid_location(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_location\(\) takes 3 positional arguments but 4 were given$", (*) => host.grid_location(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grid_location\(\) got an unexpected keyword argument 'bad'$", (*) => host.grid_location({ bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad screen distance "bad"$', (*) => host.grid_location("bad", 1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestBundledTclTkDllsExistForUseTkRuntime()
    {
        dllDir := StdlibTkinterTest.RuntimeLibDir()

        AhkTest.AssertTrue(FileExist(dllDir "\tcl86t.dll") != "")
        AhkTest.AssertTrue(FileExist(dllDir "\tk86t.dll") != "")
    }

    static TestBundledTclTkDllChecksumsAndSourceAreDocumented()
    {
        dllDir := StdlibTkinterTest.RuntimeLibDir()
        checksums := StdlibTkinterTest.ReadSha256Sums(dllDir "\SHA256SUMS")
        readme := FileRead(dllDir "\README.md", "UTF-8")
        sourceRoot := "F:\Python\Python310"
        releaseUrl := "https://www.python.org/downloads/release/python-31011/"

        AhkTest.AssertEqual("FBFD065F861EC0A90DD513BC209C56BBC23C54D2839964A0EC2DF95848AF7860", checksums["tcl86t.dll"])
        AhkTest.AssertEqual("CD2F60075064DFC2E65C88B239A970CB4BD07CB3EEC7CC26FB1BF978D4356B08", checksums["tk86t.dll"])
        AhkTest.AssertEqual(checksums["tcl86t.dll"], StrUpper(stdlib.hashlib.sha256(FileRead(dllDir "\tcl86t.dll", "RAW")).hexdigest()))
        AhkTest.AssertEqual(checksums["tk86t.dll"], StrUpper(stdlib.hashlib.sha256(FileRead(dllDir "\tk86t.dll", "RAW")).hexdigest()))
        AhkTest.AssertTrue(InStr(readme, releaseUrl) > 0)
        AhkTest.AssertTrue(InStr(readme, sourceRoot "\DLLs\tcl86t.dll") > 0)
        AhkTest.AssertTrue(InStr(readme, sourceRoot "\DLLs\tk86t.dll") > 0)
        AhkTest.AssertTrue(InStr(readme, checksums["tcl86t.dll"]) > 0)
        AhkTest.AssertTrue(InStr(readme, checksums["tk86t.dll"]) > 0)
    }

    static TestObservedTkinterArityAndTypeErrorsMatchLocal310()
    {
        interp := stdlib.tkinter.Tcl()
        gui := stdlib.tkinter.Tk()
        gui.eval("wm withdraw .")

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
        AhkTest.RaisesMatch(RuntimeError, "^Too early to create variable: no default root window$", (*) => stdlib.tkinter.Variable())
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '_root'$", (*) => stdlib.tkinter.Variable({ master: 1 }))
        AhkTest.RaisesMatch(TypeError, "^Variable\.__init__\(\) got an unexpected keyword argument 'extra'$", (*) => stdlib.tkinter.Variable({ master: interp, extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "^Variable\.__init__\(\) takes from 1 to 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.Variable(interp, "seed", "custom_var", "extra"))
        AhkTest.RaisesMatch(TypeError, "^name must be a string$", (*) => stdlib.tkinter.Variable({ master: interp, name: 1 }))
        AhkTest.RaisesMatch(RuntimeError, "^Too early to create variable: no default root window$", (*) => stdlib.tkinter.StringVar())
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '_root'$", (*) => stdlib.tkinter.StringVar({ master: 1 }))
        AhkTest.RaisesMatch(TypeError, "^StringVar\.__init__\(\) got an unexpected keyword argument 'extra'$", (*) => stdlib.tkinter.StringVar({ master: interp, extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "^StringVar\.__init__\(\) takes from 1 to 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.StringVar(interp, "seed", "custom_name", "extra"))
        AhkTest.RaisesMatch(TypeError, "^name must be a string$", (*) => stdlib.tkinter.StringVar({ master: interp, name: 1 }))
        AhkTest.RaisesMatch(RuntimeError, "^Too early to create variable: no default root window$", (*) => stdlib.tkinter.IntVar())
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '_root'$", (*) => stdlib.tkinter.IntVar({ master: 1 }))
        AhkTest.RaisesMatch(TypeError, "^IntVar\.__init__\(\) got an unexpected keyword argument 'extra'$", (*) => stdlib.tkinter.IntVar({ master: interp, extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "^IntVar\.__init__\(\) takes from 1 to 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.IntVar(interp, 1, "custom_int", "extra"))
        AhkTest.RaisesMatch(TypeError, "^name must be a string$", (*) => stdlib.tkinter.IntVar({ master: interp, name: 1 }))
        AhkTest.RaisesMatch(RuntimeError, "^Too early to create variable: no default root window$", (*) => stdlib.tkinter.DoubleVar())
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '_root'$", (*) => stdlib.tkinter.DoubleVar({ master: 1 }))
        AhkTest.RaisesMatch(TypeError, "^DoubleVar\.__init__\(\) got an unexpected keyword argument 'extra'$", (*) => stdlib.tkinter.DoubleVar({ master: interp, extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "^DoubleVar\.__init__\(\) takes from 1 to 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.DoubleVar(interp, 1, "custom_double", "extra"))
        AhkTest.RaisesMatch(TypeError, "^name must be a string$", (*) => stdlib.tkinter.DoubleVar({ master: interp, name: 1 }))
        AhkTest.RaisesMatch(RuntimeError, "^Too early to create variable: no default root window$", (*) => stdlib.tkinter.BooleanVar())
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '_root'$", (*) => stdlib.tkinter.BooleanVar({ master: 1 }))
        AhkTest.RaisesMatch(TypeError, "^BooleanVar\.__init__\(\) got an unexpected keyword argument 'extra'$", (*) => stdlib.tkinter.BooleanVar({ master: interp, extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "^BooleanVar\.__init__\(\) takes from 1 to 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.BooleanVar(interp, 1, "custom_bool", "extra"))
        AhkTest.RaisesMatch(TypeError, "^name must be a string$", (*) => stdlib.tkinter.BooleanVar({ master: interp, name: 1 }))
        traceValue := stdlib.tkinter.StringVar(interp, "seed", "trace_error_var")
        traceRecorder := StdlibTkinterTest.TraceRecorder()
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_add\(\) missing 2 required positional arguments: 'mode' and 'callback'$", (*) => traceValue.trace_add())
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_add\(\) missing 1 required positional argument: 'callback'$", (*) => traceValue.trace_add("write"))
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_add\(\) takes 3 positional arguments but 4 were given$", (*) => traceValue.trace_add("write", traceRecorder, "extra"))
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_remove\(\) missing 2 required positional arguments: 'mode' and 'cbname'$", (*) => traceValue.trace_remove())
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_remove\(\) missing 1 required positional argument: 'cbname'$", (*) => traceValue.trace_remove("write"))
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_remove\(\) takes 3 positional arguments but 4 were given$", (*) => traceValue.trace_remove("write", "name", "extra"))
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_info\(\) takes 1 positional argument but 2 were given$", (*) => traceValue.trace_info("extra"))
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_variable\(\) missing 2 required positional arguments: 'mode' and 'callback'$", (*) => traceValue.trace_variable())
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_variable\(\) missing 1 required positional argument: 'callback'$", (*) => traceValue.trace_variable("w"))
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_variable\(\) takes 3 positional arguments but 4 were given$", (*) => traceValue.trace_variable("w", traceRecorder, "extra"))
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_vdelete\(\) missing 2 required positional arguments: 'mode' and 'cbname'$", (*) => traceValue.trace_vdelete())
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_vdelete\(\) missing 1 required positional argument: 'cbname'$", (*) => traceValue.trace_vdelete("w"))
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_vdelete\(\) takes 3 positional arguments but 4 were given$", (*) => traceValue.trace_vdelete("w", "name", "extra"))
        AhkTest.RaisesMatch(TypeError, "^Variable\.trace_vinfo\(\) takes 1 positional argument but 2 were given$", (*) => traceValue.trace_vinfo("extra"))
        AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad operation "bad": must be array, read, unset, or write$', (*) => traceValue.trace_add("bad", traceRecorder))
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.Label({ master: 1 }))
        AhkTest.RaisesMatch(TypeError, "^Label\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Label(gui, {}, "extra"))
        AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-extra_kw"$', (*) => stdlib.tkinter.Label(gui, { extra_kw: 1 }))
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.Entry({ master: 1 }))
        AhkTest.RaisesMatch(TypeError, "^Entry\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Entry(gui, {}, "extra"))
        AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-extra_kw"$', (*) => stdlib.tkinter.Entry(gui, { extra_kw: 1 }))
        AhkTest.RaisesMatch(TypeError, "^Entry\.get\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Entry(gui).get(1))
        AhkTest.RaisesMatch(TypeError, "^Entry\.insert\(\) missing 2 required positional arguments: 'index' and 'string'$", (*) => stdlib.tkinter.Entry(gui).insert())
        AhkTest.RaisesMatch(TypeError, "^Entry\.insert\(\) missing 1 required positional argument: 'string'$", (*) => stdlib.tkinter.Entry(gui).insert(0))
        AhkTest.RaisesMatch(TypeError, "^Entry\.insert\(\) takes 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Entry(gui).insert(0, "a", "b"))
        AhkTest.RaisesMatch(TypeError, "^Entry\.delete\(\) missing 1 required positional argument: 'first'$", (*) => stdlib.tkinter.Entry(gui).delete())
        AhkTest.RaisesMatch(TypeError, "^Entry\.delete\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Entry(gui).delete(0, 1, 2))
        AhkTest.RaisesMatch(TypeError, "^Misc\.update\(\) takes 1 positional argument but 2 were given$", (*) => gui.update(1))
        AhkTest.RaisesMatch(TypeError, "^Misc\.update_idletasks\(\) takes 1 positional argument but 2 were given$", (*) => gui.update_idletasks(1))
        try gui.update_idletasks()
        try gui.destroy()
    }

    class CommandRecorder
    {
        __New(result, label)
        {
            this.Result := result
            this.Label := label
            this.Calls := []
        }

        Call(args*)
        {
            if args.Length
                this.Calls.Push(this.Label ":" args[1])
            else
                this.Calls.Push(this.Label)
            return this.Result
        }
    }

    class QuitRecorder
    {
        __New(root, label)
        {
            this.Root := root
            this.Label := label
            this.Calls := []
        }

        Call()
        {
            this.Calls.Push(this.Label)
            this.Root.quit()
            return "ignored"
        }
    }

    class EventRecorder
    {
        __New(result, label := "")
        {
            this.Result := result
            this.Label := label
            this.Calls := []
        }

        Call(event)
        {
            this.Calls.Push(event)
            return this.Result
        }
    }

    class TraceRecorder
    {
        __New()
        {
            this.Calls := []
        }

        Call(args*)
        {
            this.Calls.Push(stdlib.tuple(args))
            return "ignored"
        }
    }

    static RuntimeLibDir()
    {
        SplitPath A_LineFile, , &testsDir
        stdlibDir := RegExReplace(testsDir, "\\tests$")
        return stdlibDir "\tkinter\lib"
    }

    static ReadSha256Sums(path)
    {
        checksums := Map()
        for line in StrSplit(Trim(FileRead(path, "UTF-8"), "`r`n"), "`n") {
            line := Trim(line, "`r")
            if line = ""
                continue
            checksums[Trim(SubStr(line, 67))] := SubStr(line, 1, 64)
        }
        return checksums
    }
}

AhkTest.Collect(StdlibTkinterTest)
