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
        AhkTest.AssertTrue(interp is stdlib.tkinter.Tk)
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

    static TestModuleConstantsMatchLocal310()
    {
        constants := [
            ["ACTIVE", "active"], ["ALL", "all"], ["ANCHOR", "anchor"],
            ["ARC", "arc"], ["BASELINE", "baseline"], ["BEVEL", "bevel"],
            ["BOTH", "both"], ["BOTTOM", "bottom"], ["BROWSE", "browse"],
            ["BUTT", "butt"], ["CASCADE", "cascade"], ["CENTER", "center"],
            ["CHAR", "char"], ["CHORD", "chord"], ["COMMAND", "command"],
            ["CURRENT", "current"], ["DISABLED", "disabled"],
            ["DOTBOX", "dotbox"], ["E", "e"], ["END", "end"], ["EW", "ew"],
            ["EXTENDED", "extended"], ["FALSE", 0], ["FIRST", "first"],
            ["FLAT", "flat"], ["GROOVE", "groove"], ["HIDDEN", "hidden"],
            ["HORIZONTAL", "horizontal"], ["INSERT", "insert"],
            ["INSIDE", "inside"], ["LAST", "last"], ["LEFT", "left"],
            ["MITER", "miter"], ["MOVETO", "moveto"], ["MULTIPLE", "multiple"],
            ["N", "n"], ["NE", "ne"], ["NO", 0], ["NONE", "none"],
            ["NORMAL", "normal"], ["NS", "ns"], ["NSEW", "nsew"],
            ["NUMERIC", "numeric"], ["NW", "nw"], ["OFF", 0], ["ON", 1],
            ["OUTSIDE", "outside"], ["PAGES", "pages"],
            ["PIESLICE", "pieslice"], ["PROJECTING", "projecting"],
            ["RAISED", "raised"], ["RIDGE", "ridge"], ["RIGHT", "right"],
            ["ROUND", "round"],
            ["S", "s"], ["SCROLL", "scroll"], ["SE", "se"], ["SEL", "sel"],
            ["SEL_FIRST", "sel.first"], ["SEL_LAST", "sel.last"],
            ["SEPARATOR", "separator"], ["SINGLE", "single"],
            ["SOLID", "solid"], ["SUNKEN", "sunken"], ["SW", "sw"],
            ["TOP", "top"], ["TRUE", 1], ["UNDERLINE", "underline"],
            ["UNITS", "units"], ["VERTICAL", "vertical"], ["W", "w"],
            ["WORD", "word"], ["X", "x"], ["Y", "y"], ["YES", 1],
            ["wantobjects", 1]
        ]

        for entry in constants
            AhkTest.AssertEqual(entry[2], StdlibTkinterTest.TkinterModuleConstant(entry[1]), entry[1])
    }

    static TestEventPublicConstructorMatchesLocal310()
    {
        AhkTest.AssertTrue(HasMethod(stdlib.tkinter, "Event"))

        event := stdlib.tkinter.Event()
        AhkTest.AssertTrue(event is stdlib.tkinter.Event)
        AhkTest.AssertFalse(HasProp(event, "widget"))
        AhkTest.AssertFalse(HasProp(event, "x"))
        AhkTest.AssertFalse(HasProp(event, "y"))
        AhkTest.AssertFalse(HasProp(event, "type"))
        AhkTest.AssertFalse(HasProp(event, "char"))

        event.widget := "widget-sentinel"
        event.x := 7
        event.y := 8
        event.type := "ButtonPress"
        AhkTest.AssertEqual("widget-sentinel", event.widget)
        AhkTest.AssertEqual(7, event.x)
        AhkTest.AssertEqual(8, event.y)
        AhkTest.AssertEqual("ButtonPress", event.type)

        AhkTest.RaisesMatch(TypeError, "^Event\(\) takes no arguments$", (*) => stdlib.tkinter.Event(1))
        AhkTest.RaisesMatch(TypeError, "^Event\(\) takes no arguments$", (*) => stdlib.tkinter.Event(1, 2))
    }

    static TestEventTypePublicConstructorMatchesLocal310()
    {
        AhkTest.AssertTrue(HasMethod(stdlib.tkinter, "EventType"))

        eventTypes := [
            ["2", "KeyPress"], ["3", "KeyRelease"], ["4", "ButtonPress"],
            ["5", "ButtonRelease"], ["6", "Motion"], ["7", "Enter"],
            ["8", "Leave"], ["9", "FocusIn"], ["10", "FocusOut"],
            ["11", "Keymap"], ["12", "Expose"], ["13", "GraphicsExpose"],
            ["14", "NoExpose"], ["15", "Visibility"], ["16", "Create"],
            ["17", "Destroy"], ["18", "Unmap"], ["19", "Map"],
            ["20", "MapRequest"], ["21", "Reparent"], ["22", "Configure"],
            ["23", "ConfigureRequest"], ["24", "Gravity"],
            ["25", "ResizeRequest"], ["26", "Circulate"],
            ["27", "CirculateRequest"], ["28", "Property"],
            ["29", "SelectionClear"], ["30", "SelectionRequest"],
            ["31", "Selection"], ["32", "Colormap"],
            ["33", "ClientMessage"], ["34", "Mapping"],
            ["35", "VirtualEvent"], ["36", "Activate"],
            ["37", "Deactivate"], ["38", "MouseWheel"]
        ]

        for entry in eventTypes {
            eventType := stdlib.tkinter.EventType(entry[1])
            AhkTest.AssertTrue(eventType is stdlib.tkinter.EventType, entry[1])
            AhkTest.AssertEqual(entry[2], eventType.name, entry[1])
            AhkTest.AssertEqual(entry[1], eventType.value, entry[1])
            AhkTest.AssertEqual(entry[1], String(eventType), entry[1])
        }

        AhkTest.RaisesMatch(TypeError, "^EnumMeta\.__call__\(\) missing 1 required positional argument: 'value'$", (*) => stdlib.tkinter.EventType())
        AhkTest.RaisesMatch(TypeError, "^Cannot extend enumerations$", (*) => stdlib.tkinter.EventType("4", "extra"))
        AhkTest.RaisesMatch(ValueError, "^'bad' is not a valid EventType$", (*) => stdlib.tkinter.EventType("bad"))
        AhkTest.RaisesMatch(ValueError, "^4 is not a valid EventType$", (*) => stdlib.tkinter.EventType(4))
        AhkTest.RaisesMatch(ValueError, "^None is not a valid EventType$", (*) => stdlib.tkinter.EventType(stdlib.None))
    }

    static TestCallWrapperPublicClassMatchesLocal310()
    {
        AhkTest.AssertTrue(HasMethod(stdlib.tkinter, "CallWrapper"))

        widget := StdlibTkinterTest.CallWrapperWidgetProbe()
        directCalls := []
        directFunc := (args*) => (directCalls.Push(args), "ret:" StdlibTkinterTest.JoinCallWrapperArgs(args*))
        wrapper := stdlib.tkinter.CallWrapper(directFunc, stdlib.None, widget)
        AhkTest.AssertEqual(directFunc, wrapper.func)
        AhkTest.AssertEqual(stdlib.None, wrapper.subst)
        AhkTest.AssertSame(widget, wrapper.widget)
        AhkTest.AssertEqual("ret:a|b c", wrapper.Call("a", "b c"))
        AhkTest.AssertEqual(1, directCalls.Length)
        AhkTest.AssertEqual("a", directCalls[1][1])
        AhkTest.AssertEqual("b c", directCalls[1][2])

        substCalls := []
        substFunc := (args*) => (substCalls.Push(args), ["sub:" StdlibTkinterTest.JoinCallWrapperArgs(args*), args.Length])
        convertedCalls := []
        convertedFunc := (args*) => (convertedCalls.Push(args), "ret:" StdlibTkinterTest.JoinCallWrapperArgs(args*))
        converted := stdlib.tkinter.CallWrapper(convertedFunc, substFunc, widget)
        AhkTest.AssertEqual("ret:sub:a|b c|2", converted.Call("a", "b c"))
        AhkTest.AssertEqual(1, substCalls.Length)
        AhkTest.AssertEqual(1, convertedCalls.Length)
        AhkTest.AssertEqual("sub:a|b c", convertedCalls[1][1])
        AhkTest.AssertEqual(2, convertedCalls[1][2])

        scalarCalls := []
        scalarFunc := (args*) => (scalarCalls.Push(args), "ret:" StdlibTkinterTest.JoinCallWrapperArgs(args*))
        scalarWrapper := stdlib.tkinter.CallWrapper(scalarFunc, (*) => "one", widget)
        AhkTest.AssertEqual("ret:o|n|e", scalarWrapper.Call("x", "y"))
        AhkTest.AssertEqual(3, scalarCalls[1].Length)
        AhkTest.AssertEqual("o", scalarCalls[1][1])
        AhkTest.AssertEqual("n", scalarCalls[1][2])
        AhkTest.AssertEqual("e", scalarCalls[1][3])

        badSubst := stdlib.tkinter.CallWrapper(directFunc, (*) => StdlibTkinterTest.ThrowCallbackError("subst boom"), widget)
        AhkTest.AssertEqual(stdlib.None, badSubst.Call("x"))
        AhkTest.AssertEqual(1, widget.Reports.Length)

        badFunc := stdlib.tkinter.CallWrapper((*) => StdlibTkinterTest.ThrowCallbackError("func boom"), stdlib.None, widget)
        AhkTest.AssertEqual(stdlib.None, badFunc.Call("x"))
        AhkTest.AssertEqual(2, widget.Reports.Length)

        AhkTest.RaisesMatch(TypeError, "^CallWrapper\.__init__\(\) missing 3 required positional arguments: 'func', 'subst', and 'widget'$", (*) => stdlib.tkinter.CallWrapper())
        AhkTest.RaisesMatch(TypeError, "^CallWrapper\.__init__\(\) missing 2 required positional arguments: 'subst' and 'widget'$", (*) => stdlib.tkinter.CallWrapper(directFunc))
        AhkTest.RaisesMatch(TypeError, "^CallWrapper\.__init__\(\) missing 1 required positional argument: 'widget'$", (*) => stdlib.tkinter.CallWrapper(directFunc, stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^CallWrapper\.__init__\(\) takes 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.CallWrapper(directFunc, stdlib.None, widget, "extra"))
    }

    static TestTclErrorPublicConstructorMatchesLocal310()
    {
        empty := stdlib.tkinter.TclError()
        AhkTest.AssertTrue(empty is stdlib.tkinter.TclError)
        AhkTest.AssertEqual("", empty.Message)
        AhkTest.AssertEqual(stdlib.tuple(), empty.args)

        one := stdlib.tkinter.TclError("bad")
        AhkTest.AssertTrue(one is stdlib.tkinter.TclError)
        AhkTest.AssertEqual("bad", one.Message)
        AhkTest.AssertEqual(stdlib.tuple(["bad"]), one.args)

        two := stdlib.tkinter.TclError("bad", 3)
        AhkTest.AssertTrue(two is stdlib.tkinter.TclError)
        AhkTest.AssertEqual("('bad', 3)", two.Message)
        AhkTest.AssertEqual(stdlib.tuple(["bad", 3]), two.args)

        negative := stdlib.tkinter.TclError("bad", -1)
        AhkTest.AssertTrue(negative is stdlib.tkinter.TclError)
        AhkTest.AssertEqual("('bad', -1)", negative.Message)
        AhkTest.AssertEqual(stdlib.tuple(["bad", -1]), negative.args)

        interp := stdlib.tkinter.Tcl()
        try {
            try interp.eval("badcommand")
            catch as err {
                AhkTest.AssertTrue(err is stdlib.tkinter.TclError)
                AhkTest.AssertEqual('invalid command name "badcommand"', err.Message)
                AhkTest.AssertEqual(stdlib.tuple(['invalid command name "badcommand"']), err.args)
                return
            }
            AhkTest.Fail("expected TclError")
        } finally {
            try interp.destroy()
        }
    }

    static TestTtkButtonPublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Button"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Button("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            button := stdlib.tkinter.ttk.Button(root, { text: "Hi", name: "ttk_button_probe" })
            AhkTest.AssertTrue(button is stdlib.tkinter.ttk.Button)
            AhkTest.AssertEqual(".ttk_button_probe", String(button))
            AhkTest.AssertEqual("ttk::button", button.widgetName)
            AhkTest.AssertSame(root, button.master)
            AhkTest.AssertSame(root.tk, button.tk)
            AhkTest.AssertEqual("TButton", button.winfo_class())
            AhkTest.AssertEqual("Hi", button.cget("text"))
            AhkTest.AssertEqual("", button.cget("style"))
            AhkTest.AssertContains("class", button.keys())
            AhkTest.AssertContains("text", button.keys())
            AhkTest.AssertEqual(stdlib.tuple(["text", "text", "Text", "", "Hi"]), button.configure("text"))
            AhkTest.AssertEqual(stdlib.None, button.configure({ text: "Changed" }))
            AhkTest.AssertEqual("Changed", button.cget("text"))
            AhkTest.AssertSame(button, root.nametowidget("ttk_button_probe"))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.Button(root, { bad: 1 }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkButtonStateAndInvokeMatchObservedLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            calls := []
            button := stdlib.tkinter.ttk.Button(root, { text: "Hi", command: (*) => (calls.Push("called"), "done"), name: "ttk_button_state_probe" })

            AhkTest.AssertEqual("done", button.invoke())
            AhkTest.AssertEqual(1, calls.Length)
            AhkTest.AssertEqual(stdlib.tuple(), button.state())
            AhkTest.AssertEqual(stdlib.tuple(["!disabled"]), button.state(["disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(["disabled"]), button.state())
            AhkTest.AssertSame(stdlib.False, button.instate(["!disabled"]))
            AhkTest.AssertSame(stdlib.True, button.instate(["disabled"]))
            AhkTest.AssertEqual("callback-result", button.instate(["disabled"], (*) => "callback-result"))
            AhkTest.AssertSame(stdlib.False, button.instate(["pressed"], (*) => "nope"))
            AhkTest.AssertEqual(stdlib.tuple(["disabled"]), button.state(["!disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(), button.state())

            AhkTest.RaisesMatch(TypeError, "^Button\.invoke\(\) takes 1 positional argument but 2 were given$", (*) => button.invoke("extra"))
            AhkTest.RaisesMatch(TypeError, "^Widget\.state\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => button.state(["disabled"], "extra"))
            AhkTest.RaisesMatch(TypeError, "^Widget\.instate\(\) missing 1 required positional argument: 'statespec'$", (*) => button.instate())
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => button.state(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^Invalid state name d$", (*) => button.state("disabled"))
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => button.instate(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkCheckbuttonPublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Checkbutton"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Checkbutton("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            defaultCheck := stdlib.tkinter.ttk.Checkbutton({ name: "ttk_check_default_probe" })
            AhkTest.AssertTrue(defaultCheck is stdlib.tkinter.ttk.Checkbutton)
            AhkTest.AssertEqual(".ttk_check_default_probe", String(defaultCheck))
            AhkTest.AssertEqual("ttk::checkbutton", defaultCheck.widgetName)
            AhkTest.AssertEqual("TCheckbutton", defaultCheck.winfo_class())
            AhkTest.AssertEqual(stdlib.tuple(["alternate"]), defaultCheck.state())

            variable := stdlib.tkinter.StringVar(root, "off", "ttk_check_var")
            check := stdlib.tkinter.ttk.Checkbutton(root, { text: "Hi", variable: variable, onvalue: "on", offvalue: "off", takefocus: 1, cursor: "arrow", style: "Probe.TCheckbutton", name: "ttk_check_probe" })
            AhkTest.AssertTrue(check is stdlib.tkinter.ttk.Checkbutton)
            AhkTest.AssertEqual(".ttk_check_probe", String(check))
            AhkTest.AssertEqual("ttk::checkbutton", check.widgetName)
            AhkTest.AssertSame(root, check.master)
            AhkTest.AssertSame(root.tk, check.tk)
            AhkTest.AssertEqual("TCheckbutton", check.winfo_class())
            AhkTest.AssertEqual("Hi", check.cget("text"))
            AhkTest.AssertEqual("ttk_check_var", check.cget("variable"))
            AhkTest.AssertEqual("on", check.cget("onvalue"))
            AhkTest.AssertEqual("off", check.cget("offvalue"))
            AhkTest.AssertEqual(1, check.cget("takefocus"))
            AhkTest.AssertEqual("arrow", check.cget("cursor"))
            AhkTest.AssertEqual("Probe.TCheckbutton", check.cget("style"))
            AhkTest.AssertEqual("", check.cget("class"))
            AhkTest.AssertContains("variable", check.keys())
            AhkTest.AssertContains("onvalue", check.keys())
            AhkTest.AssertContains("offvalue", check.keys())
            AhkTest.AssertContains("takefocus", check.keys())
            AhkTest.AssertContains("text", check.keys())
            AhkTest.AssertContains("cursor", check.keys())
            AhkTest.AssertContains("style", check.keys())
            AhkTest.AssertContains("class", check.keys())
            AhkTest.AssertEqual(stdlib.tuple(["text", "text", "Text", "", "Hi"]), check.configure("text"))
            AhkTest.AssertEqual(stdlib.tuple(["variable", "variable", "Variable", "", "ttk_check_var"]), check.configure("variable"))
            AhkTest.AssertEqual(stdlib.tuple(["onvalue", "onValue", "OnValue", 1, "on"]), check.configure("onvalue"))
            AhkTest.AssertEqual(stdlib.tuple(["offvalue", "offValue", "OffValue", 0, "off"]), check.configure("offvalue"))
            AhkTest.AssertEqual(stdlib.tuple(["takefocus", "takeFocus", "TakeFocus", "ttk::takefocus", 1]), check.configure("takefocus"))
            AhkTest.AssertEqual(stdlib.tuple(["cursor", "cursor", "Cursor", "", "arrow"]), check.configure("cursor"))
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", "Probe.TCheckbutton"]), check.configure("style"))
            AhkTest.AssertEqual(stdlib.tuple(["class", "", "", "", ""]), check.configure("class"))
            AhkTest.AssertSame(check, root.nametowidget("ttk_check_probe"))
            AhkTest.AssertFalse(HasMethod(check, "select"))
            AhkTest.AssertFalse(HasMethod(check, "deselect"))
            AhkTest.AssertFalse(HasMethod(check, "toggle"))

            AhkTest.AssertEqual("", check.invoke())
            AhkTest.AssertEqual("on", variable.get())
            AhkTest.AssertEqual("", check.invoke())
            AhkTest.AssertEqual("off", variable.get())
            AhkTest.AssertEqual(stdlib.tuple(["!disabled"]), check.state(["disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(["disabled"]), check.state())
            AhkTest.AssertSame(stdlib.True, check.instate(["disabled"]))
            AhkTest.AssertSame(stdlib.False, check.instate(["!disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(["cb", "alpha"]), check.instate(["disabled"], (args*) => stdlib.tuple(["cb", args[1]]), "alpha"))
            AhkTest.AssertSame(stdlib.False, check.instate(["pressed"], (*) => "nope"))
            AhkTest.AssertEqual(stdlib.tuple(["disabled"]), check.state(["!disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(), check.state())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.Checkbutton(root, { bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Checkbutton\.invoke\(\) takes 1 positional argument but 2 were given$", (*) => check.invoke("extra"))
            AhkTest.RaisesMatch(TypeError, "^Widget\.state\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => check.state(["disabled"], "extra"))
            AhkTest.RaisesMatch(TypeError, "^Widget\.instate\(\) missing 1 required positional argument: 'statespec'$", (*) => check.instate())
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => check.state(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^Invalid state name d$", (*) => check.state("disabled"))
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => check.instate(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkRadiobuttonPublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Radiobutton"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Radiobutton("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            defaultRadio := stdlib.tkinter.ttk.Radiobutton({ name: "ttk_radio_default_probe" })
            AhkTest.AssertTrue(defaultRadio is stdlib.tkinter.ttk.Radiobutton)
            AhkTest.AssertEqual(".ttk_radio_default_probe", String(defaultRadio))
            AhkTest.AssertEqual("ttk::radiobutton", defaultRadio.widgetName)
            AhkTest.AssertEqual("TRadiobutton", defaultRadio.winfo_class())
            AhkTest.AssertEqual(stdlib.tuple(["alternate"]), defaultRadio.state())

            variable := stdlib.tkinter.StringVar(root, "left", "ttk_radio_var")
            radio := stdlib.tkinter.ttk.Radiobutton(root, { text: "Hi", variable: variable, value: "right", takefocus: 1, cursor: "arrow", style: "Probe.TRadiobutton", class: "ProbeClass", name: "ttk_radio_probe" })
            AhkTest.AssertTrue(radio is stdlib.tkinter.ttk.Radiobutton)
            AhkTest.AssertEqual(".ttk_radio_probe", String(radio))
            AhkTest.AssertEqual("ttk::radiobutton", radio.widgetName)
            AhkTest.AssertSame(root, radio.master)
            AhkTest.AssertSame(root.tk, radio.tk)
            AhkTest.AssertEqual("ProbeClass", radio.winfo_class())
            AhkTest.AssertEqual("Hi", radio.cget("text"))
            AhkTest.AssertEqual("ttk_radio_var", radio.cget("variable"))
            AhkTest.AssertEqual("right", radio.cget("value"))
            AhkTest.AssertEqual(1, radio.cget("takefocus"))
            AhkTest.AssertEqual("arrow", radio.cget("cursor"))
            AhkTest.AssertEqual("Probe.TRadiobutton", radio.cget("style"))
            AhkTest.AssertEqual("ProbeClass", radio.cget("class"))
            AhkTest.AssertContains("variable", radio.keys())
            AhkTest.AssertContains("value", radio.keys())
            AhkTest.AssertContains("takefocus", radio.keys())
            AhkTest.AssertContains("text", radio.keys())
            AhkTest.AssertContains("cursor", radio.keys())
            AhkTest.AssertContains("style", radio.keys())
            AhkTest.AssertContains("class", radio.keys())
            AhkTest.AssertEqual(stdlib.tuple(["text", "text", "Text", "", "Hi"]), radio.configure("text"))
            AhkTest.AssertEqual(stdlib.tuple(["variable", "variable", "Variable", "::selectedButton", "ttk_radio_var"]), radio.configure("variable"))
            AhkTest.AssertEqual(stdlib.tuple(["value", "Value", "Value", 1, "right"]), radio.configure("value"))
            AhkTest.AssertEqual(stdlib.tuple(["takefocus", "takeFocus", "TakeFocus", "ttk::takefocus", 1]), radio.configure("takefocus"))
            AhkTest.AssertEqual(stdlib.tuple(["cursor", "cursor", "Cursor", "", "arrow"]), radio.configure("cursor"))
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", "Probe.TRadiobutton"]), radio.configure("style"))
            AhkTest.AssertEqual(stdlib.tuple(["class", "", "", "", "ProbeClass"]), radio.configure("class"))
            AhkTest.AssertSame(radio, root.nametowidget("ttk_radio_probe"))
            AhkTest.AssertFalse(HasMethod(radio, "select"))
            AhkTest.AssertFalse(HasMethod(radio, "deselect"))
            AhkTest.AssertFalse(HasMethod(radio, "toggle"))
            AhkTest.AssertFalse(HasMethod(radio, "flash"))

            AhkTest.AssertEqual("", radio.invoke())
            AhkTest.AssertEqual("right", variable.get())
            AhkTest.AssertSame(stdlib.True, radio.instate(["selected"]))
            AhkTest.AssertEqual(stdlib.tuple(["!disabled"]), radio.state(["disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(["disabled", "selected"]), radio.state())
            AhkTest.AssertEqual(stdlib.tuple(["cb", "x", "y"]), radio.instate(["disabled"], (args*) => stdlib.tuple(["cb", args[1], args[2]]), "x", "y"))
            AhkTest.AssertEqual(stdlib.tuple(["disabled"]), radio.state(["!disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(["selected"]), radio.state())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.Radiobutton(root, { bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Radiobutton\.invoke\(\) takes 1 positional argument but 2 were given$", (*) => radio.invoke("extra"))
            AhkTest.RaisesMatch(TypeError, "^Widget\.state\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => radio.state(["disabled"], "extra"))
            AhkTest.RaisesMatch(TypeError, "^Widget\.instate\(\) missing 1 required positional argument: 'statespec'$", (*) => radio.instate())
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => radio.state(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^Invalid state name d$", (*) => radio.state("disabled"))
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => radio.instate(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkFramePublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Frame"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Frame("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            frame := stdlib.tkinter.ttk.Frame(root, { style: "Probe.TFrame", name: "ttk_frame_probe" })
            AhkTest.AssertTrue(frame is stdlib.tkinter.ttk.Frame)
            AhkTest.AssertEqual(".ttk_frame_probe", String(frame))
            AhkTest.AssertEqual("ttk::frame", frame.widgetName)
            AhkTest.AssertSame(root, frame.master)
            AhkTest.AssertSame(root.tk, frame.tk)
            AhkTest.AssertEqual("TFrame", frame.winfo_class())
            AhkTest.AssertEqual("Probe.TFrame", frame.cget("style"))
            AhkTest.AssertContains("class", frame.keys())
            AhkTest.AssertContains("style", frame.keys())
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", "Probe.TFrame"]), frame.configure("style"))
            AhkTest.AssertEqual(stdlib.None, frame.configure({ style: "Other.TFrame" }))
            AhkTest.AssertEqual("Other.TFrame", frame.cget("style"))
            AhkTest.AssertSame(frame, root.nametowidget("ttk_frame_probe"))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.Frame(root, { bad: 1 }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkLabelPublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Label"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Label("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            label := stdlib.tkinter.ttk.Label(root, { text: "Hi", style: "Probe.TLabel", name: "ttk_label_probe" })
            AhkTest.AssertTrue(label is stdlib.tkinter.ttk.Label)
            AhkTest.AssertEqual(".ttk_label_probe", String(label))
            AhkTest.AssertEqual("ttk::label", label.widgetName)
            AhkTest.AssertSame(root, label.master)
            AhkTest.AssertSame(root.tk, label.tk)
            AhkTest.AssertEqual("TLabel", label.winfo_class())
            AhkTest.AssertEqual("Hi", label.cget("text"))
            AhkTest.AssertEqual("Probe.TLabel", label.cget("style"))
            AhkTest.AssertContains("class", label.keys())
            AhkTest.AssertContains("text", label.keys())
            AhkTest.AssertContains("style", label.keys())
            AhkTest.AssertEqual(stdlib.tuple(["text", "text", "Text", "", "Hi"]), label.configure("text"))
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", "Probe.TLabel"]), label.configure("style"))
            AhkTest.AssertEqual(stdlib.None, label.configure({ text: "There", style: "Other.TLabel" }))
            AhkTest.AssertEqual("There", label.cget("text"))
            AhkTest.AssertEqual("Other.TLabel", label.cget("style"))
            AhkTest.AssertSame(label, root.nametowidget("ttk_label_probe"))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.Label(root, { bad: 1 }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkEntryPublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Entry"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Entry("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            text := stdlib.tkinter.StringVar(root, "seed", "ttk_entry_var")
            entry := stdlib.tkinter.ttk.Entry(root, { textvariable: text, width: 12, style: "Probe.TEntry", name: "ttk_entry_probe" })
            AhkTest.AssertTrue(entry is stdlib.tkinter.ttk.Entry)
            AhkTest.AssertEqual(".ttk_entry_probe", String(entry))
            AhkTest.AssertEqual("ttk::entry", entry.widgetName)
            AhkTest.AssertSame(root, entry.master)
            AhkTest.AssertSame(root.tk, entry.tk)
            AhkTest.AssertEqual("TEntry", entry.winfo_class())
            AhkTest.AssertEqual(12, entry.cget("width"))
            AhkTest.AssertEqual("ttk_entry_var", entry.cget("textvariable"))
            AhkTest.AssertEqual("Probe.TEntry", entry.cget("style"))
            AhkTest.AssertEqual("seed", entry.get())
            AhkTest.AssertEqual("seed", text.get())
            AhkTest.AssertEqual(stdlib.None, entry.delete(0, "end"))
            AhkTest.AssertEqual(stdlib.None, entry.insert(0, "abc"))
            AhkTest.AssertEqual("abc", entry.get())
            AhkTest.AssertEqual("abc", text.get())
            AhkTest.AssertEqual(3, entry.index("end"))
            AhkTest.AssertContains("class", entry.keys())
            AhkTest.AssertContains("width", entry.keys())
            AhkTest.AssertContains("textvariable", entry.keys())
            AhkTest.AssertContains("style", entry.keys())
            AhkTest.AssertEqual(stdlib.tuple(["width", "width", "Width", "20", 12]), entry.configure("width"))
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", "Probe.TEntry"]), entry.configure("style"))
            AhkTest.AssertEqual(stdlib.None, entry.configure({ width: 8, style: "Other.TEntry" }))
            AhkTest.AssertEqual(8, entry.cget("width"))
            AhkTest.AssertEqual("Other.TEntry", entry.cget("style"))
            AhkTest.AssertSame(entry, root.nametowidget("ttk_entry_probe"))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.Entry(root, { bad: 1 }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkEntrySelectionSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            entry := stdlib.tkinter.ttk.Entry(root, { width: 12, name: "ttk_entry_selection_probe" })
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
            AhkTest.AssertSame(entry, root.selection_own_get())
            AhkTest.AssertSame(entry, entry.selection_own_get())
            AhkTest.AssertEqual("bcd", entry.selection_get())
            AhkTest.AssertEqual("bcd", root.selection_get())

            AhkTest.AssertEqual(stdlib.None, root.selection_clear())
            AhkTest.AssertEqual(stdlib.None, root.selection_own_get())
            AhkTest.AssertEqual(stdlib.None, entry.selection_own_get())
            AhkTest.AssertSame(stdlib.False, entry.selection_present())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^PRIMARY selection doesn't exist or form `"STRING`" not defined$", (*) => entry.selection_get())

            AhkTest.AssertEqual(stdlib.None, entry.selection_range(0, 2))
            AhkTest.AssertEqual("ab", entry.selection_get())
            AhkTest.AssertEqual(stdlib.None, entry.select_clear())
            AhkTest.AssertSame(stdlib.False, entry.selection_present())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad command "from": must be clear, present, or range$', (*) => entry.select_from(2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad command "from": must be clear, present, or range$', (*) => entry.selection_from(2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad command "to": must be clear, present, or range$', (*) => entry.select_to(5))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad command "to": must be clear, present, or range$', (*) => entry.selection_to(5))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad command "adjust": must be clear, present, or range$', (*) => entry.select_adjust(4))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad command "adjust": must be clear, present, or range$', (*) => entry.selection_adjust(4))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkEntryXViewAndScanSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            entry := stdlib.tkinter.ttk.Entry(root, { width: 5, name: "ttk_entry_xview_probe" })
            AhkTest.AssertEqual(stdlib.None, entry.insert(0, "abcdefghijklmnopqrstuvwxyz"))
            AhkTest.AssertEqual(stdlib.None, entry.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertEqual(stdlib.tuple([0.0, 1.0]), entry.xview())
            AhkTest.AssertEqual(stdlib.None, entry.xview_moveto(1.0))
            AhkTest.AssertEqual(stdlib.tuple([0.0, 1.0]), entry.xview())
            AhkTest.AssertEqual(stdlib.None, entry.xview_scroll(-2, "units"))
            AhkTest.AssertEqual(stdlib.tuple([0.0, 1.0]), entry.xview())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad entry index "moveto"$', (*) => entry.xview("moveto"))

            AhkTest.RaisesMatch(TypeError, "^XView\.xview_moveto\(\) missing 1 required positional argument: 'fraction'$", (*) => entry.xview_moveto())
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_moveto\(\) takes 2 positional arguments but 3 were given$", (*) => entry.xview_moveto(0.1, 0.2))
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_scroll\(\) missing 2 required positional arguments: 'number' and 'what'$", (*) => entry.xview_scroll())
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_scroll\(\) missing 1 required positional argument: 'what'$", (*) => entry.xview_scroll(1))
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_scroll\(\) takes 3 positional arguments but 4 were given$", (*) => entry.xview_scroll(1, "units", "extra"))

            AhkTest.RaisesMatch(TypeError, "^Entry\.scan_mark\(\) missing 1 required positional argument: 'x'$", (*) => entry.scan_mark())
            AhkTest.RaisesMatch(TypeError, "^Entry\.scan_mark\(\) takes 2 positional arguments but 3 were given$", (*) => entry.scan_mark(1, 2))
            AhkTest.RaisesMatch(TypeError, "^Entry\.scan_dragto\(\) missing 1 required positional argument: 'x'$", (*) => entry.scan_dragto())
            AhkTest.RaisesMatch(TypeError, "^Entry\.scan_dragto\(\) takes 2 positional arguments but 3 were given$", (*) => entry.scan_dragto(1, 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad command "scan": must be bbox, cget, configure, delete, get, icursor, identify, index, insert, instate, selection, state, validate, or xview$', (*) => entry.scan_mark(10))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad command "scan": must be bbox, cget, configure, delete, get, icursor, identify, index, insert, instate, selection, state, validate, or xview$', (*) => entry.scan_dragto(0))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkComboboxPublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Combobox"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Combobox("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            text := stdlib.tkinter.StringVar(root, "seed", "ttk_combo_var")
            combo := stdlib.tkinter.ttk.Combobox(root, { values: ["one", "two words", "3"], textvariable: text, width: 14, state: "readonly", name: "ttk_combo_probe" })
            AhkTest.AssertTrue(combo is stdlib.tkinter.ttk.Combobox)
            AhkTest.AssertEqual(".ttk_combo_probe", String(combo))
            AhkTest.AssertEqual("ttk::combobox", combo.widgetName)
            AhkTest.AssertSame(root, combo.master)
            AhkTest.AssertSame(root.tk, combo.tk)
            AhkTest.AssertEqual("TCombobox", combo.winfo_class())
            AhkTest.AssertEqual(stdlib.tuple(["one", "two words", "3"]), combo.cget("values"))
            AhkTest.AssertEqual("ttk_combo_var", combo.cget("textvariable"))
            AhkTest.AssertEqual(14, combo.cget("width"))
            AhkTest.AssertEqual("readonly", combo.cget("state"))
            AhkTest.AssertEqual("", combo.cget("style"))
            AhkTest.AssertEqual("seed", combo.get())
            AhkTest.AssertEqual("seed", text.get())
            AhkTest.AssertEqual(-1, combo.current())
            AhkTest.AssertContains("class", combo.keys())
            AhkTest.AssertContains("values", combo.keys())
            AhkTest.AssertContains("textvariable", combo.keys())
            AhkTest.AssertContains("width", combo.keys())
            AhkTest.AssertContains("state", combo.keys())
            AhkTest.AssertContains("style", combo.keys())
            AhkTest.AssertEqual(stdlib.tuple(["values", "values", "Values", "", stdlib.tuple(["one", "two words", "3"])]), combo.configure("values"))
            AhkTest.AssertEqual(stdlib.tuple(["state", "state", "State", "normal", "readonly"]), combo.configure("state"))
            AhkTest.AssertEqual(stdlib.tuple(["width", "width", "Width", 20, 14]), combo.configure("width"))

            AhkTest.AssertEqual(stdlib.None, combo.current(1))
            AhkTest.AssertEqual("two words", combo.get())
            AhkTest.AssertEqual("two words", text.get())
            AhkTest.AssertEqual(1, combo.current())
            AhkTest.AssertEqual(stdlib.None, combo.set("3"))
            AhkTest.AssertEqual("3", combo.get())
            AhkTest.AssertEqual("3", text.get())
            AhkTest.AssertEqual(2, combo.current())
            AhkTest.AssertEqual(stdlib.None, combo.set("missing"))
            AhkTest.AssertEqual("missing", combo.get())
            AhkTest.AssertEqual("missing", text.get())
            AhkTest.AssertEqual(-1, combo.current())

            AhkTest.AssertEqual(stdlib.None, combo.configure({ values: ["alpha", "beta gamma", "delta"] }))
            AhkTest.AssertEqual(stdlib.tuple(["alpha", "beta gamma", "delta"]), combo.cget("values"))
            AhkTest.AssertEqual(stdlib.tuple(["values", "values", "Values", "", stdlib.tuple(["alpha", "beta gamma", "delta"])]), combo.configure("values"))
            AhkTest.AssertEqual(stdlib.None, combo.configure({ values: [] }))
            AhkTest.AssertEqual("", combo.cget("values"))
            AhkTest.AssertEqual(stdlib.tuple(["values", "values", "Values", "", ""]), combo.configure("values"))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^Incorrect index bad$", (*) => combo.current("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^Index 99 out of range$", (*) => combo.current(99))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^Index -1 out of range$", (*) => combo.current(-1))
            AhkTest.RaisesMatch(TypeError, "^Combobox\.set\(\) missing 1 required positional argument: 'value'$", (*) => combo.set())
            AhkTest.RaisesMatch(TypeError, "^Combobox\.set\(\) takes 2 positional arguments but 3 were given$", (*) => combo.set("a", "b"))
            AhkTest.RaisesMatch(TypeError, "^Entry\.get\(\) takes 1 positional argument but 2 were given$", (*) => combo.get("x"))
            AhkTest.RaisesMatch(TypeError, "^Combobox\.current\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => combo.current(1, 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.Combobox(root, { bad: 1 }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkSeparatorPublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Separator"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Separator("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            defaultSep := stdlib.tkinter.ttk.Separator({ name: "ttk_separator_default_probe" })
            AhkTest.AssertTrue(defaultSep is stdlib.tkinter.ttk.Separator)
            AhkTest.AssertEqual(".ttk_separator_default_probe", String(defaultSep))
            AhkTest.AssertEqual("ttk::separator", defaultSep.widgetName)
            AhkTest.AssertEqual("TSeparator", defaultSep.winfo_class())
            AhkTest.AssertEqual("horizontal", defaultSep.cget("orient"))
            AhkTest.AssertSame(defaultSep, defaultSep.master.nametowidget("ttk_separator_default_probe"))

            sep := stdlib.tkinter.ttk.Separator(root, { orient: "vertical", style: "Probe.TSeparator", cursor: "arrow", takefocus: 1, name: "ttk_separator_probe" })
            AhkTest.AssertTrue(sep is stdlib.tkinter.ttk.Separator)
            AhkTest.AssertEqual(".ttk_separator_probe", String(sep))
            AhkTest.AssertEqual("ttk::separator", sep.widgetName)
            AhkTest.AssertSame(root, sep.master)
            AhkTest.AssertSame(root.tk, sep.tk)
            AhkTest.AssertEqual("TSeparator", sep.winfo_class())
            AhkTest.AssertEqual("vertical", sep.cget("orient"))
            AhkTest.AssertEqual("Probe.TSeparator", sep.cget("style"))
            AhkTest.AssertEqual("arrow", sep.cget("cursor"))
            AhkTest.AssertEqual(1, sep.cget("takefocus"))
            AhkTest.AssertContains("orient", sep.keys())
            AhkTest.AssertContains("takefocus", sep.keys())
            AhkTest.AssertContains("cursor", sep.keys())
            AhkTest.AssertContains("style", sep.keys())
            AhkTest.AssertContains("class", sep.keys())
            AhkTest.AssertEqual(stdlib.tuple(["orient", "orient", "Orient", "horizontal", "vertical"]), sep.configure("orient"))
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", "Probe.TSeparator"]), sep.configure("style"))
            AhkTest.AssertEqual(stdlib.tuple(["cursor", "cursor", "Cursor", "", "arrow"]), sep.configure("cursor"))
            AhkTest.AssertEqual(stdlib.tuple(["takefocus", "takeFocus", "TakeFocus", "", 1]), sep.configure("takefocus"))
            AhkTest.AssertEqual(stdlib.tuple(["class", "", "", "", ""]), sep.configure("class"))
            AhkTest.AssertSame(sep, root.nametowidget("ttk_separator_probe"))

            AhkTest.AssertEqual(stdlib.None, sep.configure({ orient: "horizontal", style: "" }))
            AhkTest.AssertEqual("horizontal", sep.cget("orient"))
            AhkTest.AssertEqual("", sep.cget("style"))
            AhkTest.AssertEqual(stdlib.tuple(["orient", "orient", "Orient", "horizontal", "horizontal"]), sep.configure("orient"))
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", ""]), sep.configure("style"))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.Separator(root, { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad orient "diagonal": must be horizontal or vertical$', (*) => stdlib.tkinter.ttk.Separator(root, { orient: "diagonal" }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => sep.configure({ bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad orient "diagonal": must be horizontal or vertical$', (*) => sep.configure({ orient: "diagonal" }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkProgressbarPublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Progressbar"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Progressbar("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            defaultProgress := stdlib.tkinter.ttk.Progressbar({ name: "ttk_progress_default_probe" })
            AhkTest.AssertTrue(defaultProgress is stdlib.tkinter.ttk.Progressbar)
            AhkTest.AssertEqual(".ttk_progress_default_probe", String(defaultProgress))
            AhkTest.AssertEqual("ttk::progressbar", defaultProgress.widgetName)
            AhkTest.AssertEqual("TProgressbar", defaultProgress.winfo_class())
            AhkTest.AssertEqual("horizontal", defaultProgress.cget("orient"))
            AhkTest.AssertEqual("determinate", defaultProgress.cget("mode"))
            AhkTest.AssertEqual(100, defaultProgress.cget("maximum"))
            AhkTest.AssertEqual(0.0, defaultProgress.cget("value"))
            AhkTest.AssertSame(defaultProgress, defaultProgress.master.nametowidget("ttk_progress_default_probe"))

            value := stdlib.tkinter.DoubleVar(root, 10.5, "ttk_progress_var")
            progress := stdlib.tkinter.ttk.Progressbar(root, { orient: "horizontal", length: 120, mode: "determinate", maximum: 200, value: 10.5, variable: value, style: "Horizontal.TProgressbar", takefocus: 1, cursor: "arrow", name: "ttk_progress_probe" })
            AhkTest.AssertTrue(progress is stdlib.tkinter.ttk.Progressbar)
            AhkTest.AssertEqual(".ttk_progress_probe", String(progress))
            AhkTest.AssertEqual("ttk::progressbar", progress.widgetName)
            AhkTest.AssertSame(root, progress.master)
            AhkTest.AssertSame(root.tk, progress.tk)
            AhkTest.AssertEqual("TProgressbar", progress.winfo_class())
            AhkTest.AssertEqual("horizontal", progress.cget("orient"))
            AhkTest.AssertEqual(120, progress.cget("length"))
            AhkTest.AssertEqual("determinate", progress.cget("mode"))
            AhkTest.AssertEqual(200, progress.cget("maximum"))
            AhkTest.AssertEqual(10.5, progress.cget("value"))
            AhkTest.AssertEqual("ttk_progress_var", progress.cget("variable"))
            AhkTest.AssertEqual("Horizontal.TProgressbar", progress.cget("style"))
            AhkTest.AssertEqual(1, progress.cget("takefocus"))
            AhkTest.AssertEqual("arrow", progress.cget("cursor"))
            AhkTest.AssertEqual(10.5, value.get())
            AhkTest.AssertContains("orient", progress.keys())
            AhkTest.AssertContains("length", progress.keys())
            AhkTest.AssertContains("mode", progress.keys())
            AhkTest.AssertContains("maximum", progress.keys())
            AhkTest.AssertContains("variable", progress.keys())
            AhkTest.AssertContains("value", progress.keys())
            AhkTest.AssertContains("phase", progress.keys())
            AhkTest.AssertContains("takefocus", progress.keys())
            AhkTest.AssertContains("cursor", progress.keys())
            AhkTest.AssertContains("style", progress.keys())
            AhkTest.AssertContains("class", progress.keys())
            AhkTest.AssertEqual(stdlib.tuple(["orient", "orient", "Orient", "horizontal", "horizontal"]), progress.configure("orient"))
            AhkTest.AssertEqual(stdlib.tuple(["length", "length", "Length", "100", 120]), progress.configure("length"))
            AhkTest.AssertEqual(stdlib.tuple(["mode", "mode", "ProgressMode", "determinate", "determinate"]), progress.configure("mode"))
            AhkTest.AssertEqual(stdlib.tuple(["maximum", "maximum", "Maximum", 100, 200]), progress.configure("maximum"))
            AhkTest.AssertEqual(stdlib.tuple(["value", "value", "Value", 0.0, 10.5]), progress.configure("value"))
            AhkTest.AssertEqual(stdlib.tuple(["variable", "variable", "Variable", "", "ttk_progress_var"]), progress.configure("variable"))
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", "Horizontal.TProgressbar"]), progress.configure("style"))
            AhkTest.AssertEqual(stdlib.tuple(["takefocus", "takeFocus", "TakeFocus", "", 1]), progress.configure("takefocus"))
            AhkTest.AssertEqual(stdlib.tuple(["cursor", "cursor", "Cursor", "", "arrow"]), progress.configure("cursor"))
            AhkTest.AssertEqual(stdlib.tuple(["class", "", "", "", ""]), progress.configure("class"))
            AhkTest.AssertSame(progress, root.nametowidget("ttk_progress_probe"))

            AhkTest.AssertEqual(stdlib.None, progress.step())
            AhkTest.AssertEqual(11.5, progress.cget("value"))
            AhkTest.AssertEqual(11.5, value.get())
            AhkTest.AssertEqual(stdlib.None, progress.step(5.25))
            AhkTest.AssertEqual(16.75, progress.cget("value"))
            AhkTest.AssertEqual(16.75, value.get())
            AhkTest.AssertEqual(stdlib.None, progress.configure({ value: 30.25, maximum: 50.5, mode: "indeterminate", length: 80, style: "" }))
            AhkTest.AssertEqual(16.75, progress.cget("value"))
            AhkTest.AssertEqual(50.5, progress.cget("maximum"))
            AhkTest.AssertEqual("indeterminate", progress.cget("mode"))
            AhkTest.AssertEqual(80, progress.cget("length"))
            AhkTest.AssertEqual("", progress.cget("style"))
            AhkTest.AssertEqual(stdlib.tuple(["value", "value", "Value", 0.0, 16.75]), progress.configure("value"))
            AhkTest.AssertEqual(stdlib.tuple(["maximum", "maximum", "Maximum", 100, 50.5]), progress.configure("maximum"))
            AhkTest.AssertEqual(stdlib.tuple(["length", "length", "Length", "100", 80]), progress.configure("length"))

            AhkTest.AssertEqual(stdlib.None, progress.start())
            AhkTest.AssertEqual(stdlib.None, progress.start(5))
            AhkTest.AssertEqual(stdlib.None, progress.stop())
            AhkTest.AssertEqual(17.75, progress.cget("value"))
            AhkTest.AssertEqual(17.75, value.get())
            AhkTest.RaisesMatch(TypeError, "^Progressbar\.start\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => progress.start(1, 2))
            AhkTest.RaisesMatch(TypeError, "^Progressbar\.step\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => progress.step(1, 2))
            AhkTest.RaisesMatch(TypeError, "^Progressbar\.stop\(\) takes 1 positional argument but 2 were given$", (*) => progress.stop(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.Progressbar(root, { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad orient "diagonal": must be horizontal or vertical$', (*) => stdlib.tkinter.ttk.Progressbar(root, { orient: "diagonal" }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad mode "weird": must be determinate or indeterminate$', (*) => stdlib.tkinter.ttk.Progressbar(root, { mode: "weird" }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^Layout Vertical\.Probe\.TProgressbar not found$', (*) => stdlib.tkinter.ttk.Progressbar(root, { orient: "vertical", style: "Probe.TProgressbar" }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => progress.configure({ bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad orient "diagonal": must be horizontal or vertical$', (*) => progress.configure({ orient: "diagonal" }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad mode "weird": must be determinate or indeterminate$', (*) => progress.configure({ mode: "weird" }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkScalePublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Scale"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Scale("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            defaultScale := stdlib.tkinter.ttk.Scale({ name: "ttk_scale_default_probe" })
            AhkTest.AssertTrue(defaultScale is stdlib.tkinter.ttk.Scale)
            AhkTest.AssertEqual(".ttk_scale_default_probe", String(defaultScale))
            AhkTest.AssertEqual("ttk::scale", defaultScale.widgetName)
            AhkTest.AssertEqual("TScale", defaultScale.winfo_class())
            AhkTest.AssertEqual(stdlib.tuple(), defaultScale.state())
            AhkTest.AssertEqual(0, defaultScale.get())

            variable := stdlib.tkinter.DoubleVar(root, 2.5, "ttk_scale_var")
            scale := stdlib.tkinter.ttk.Scale(root, { from: 1.5, to: 9.5, value: 4.5, variable: variable, orient: "horizontal", length: 120, takefocus: 1, cursor: "arrow", style: "Horizontal.TScale", class: "ProbeScale", name: "ttk_scale_probe" })
            AhkTest.AssertTrue(scale is stdlib.tkinter.ttk.Scale)
            AhkTest.AssertEqual(".ttk_scale_probe", String(scale))
            AhkTest.AssertEqual("ttk::scale", scale.widgetName)
            AhkTest.AssertSame(root, scale.master)
            AhkTest.AssertSame(root.tk, scale.tk)
            AhkTest.AssertEqual("ProbeScale", scale.winfo_class())
            AhkTest.AssertEqual(2.5, scale.get())
            AhkTest.AssertEqual(1.5, scale.cget("from"))
            AhkTest.AssertEqual(9.5, scale.cget("to"))
            AhkTest.AssertEqual(2.5, scale.cget("value"))
            AhkTest.AssertEqual("ttk_scale_var", scale.cget("variable"))
            AhkTest.AssertEqual("horizontal", scale.cget("orient"))
            AhkTest.AssertEqual(120, scale.cget("length"))
            AhkTest.AssertEqual(1, scale.cget("takefocus"))
            AhkTest.AssertEqual("arrow", scale.cget("cursor"))
            AhkTest.AssertEqual("Horizontal.TScale", scale.cget("style"))
            AhkTest.AssertEqual("ProbeScale", scale.cget("class"))
            AhkTest.AssertContains("from", scale.keys())
            AhkTest.AssertContains("to", scale.keys())
            AhkTest.AssertContains("value", scale.keys())
            AhkTest.AssertContains("variable", scale.keys())
            AhkTest.AssertContains("orient", scale.keys())
            AhkTest.AssertContains("length", scale.keys())
            AhkTest.AssertContains("takefocus", scale.keys())
            AhkTest.AssertContains("cursor", scale.keys())
            AhkTest.AssertContains("style", scale.keys())
            AhkTest.AssertContains("class", scale.keys())
            AhkTest.AssertEqual(stdlib.tuple(["from", "from", "From", 0, 1.5]), scale.configure("from"))
            AhkTest.AssertEqual(stdlib.tuple(["to", "to", "To", 1.0, 9.5]), scale.configure("to"))
            AhkTest.AssertEqual(stdlib.tuple(["value", "value", "Value", 0, 2.5]), scale.configure("value"))
            AhkTest.AssertEqual(stdlib.tuple(["variable", "variable", "Variable", "", "ttk_scale_var"]), scale.configure("variable"))
            AhkTest.AssertEqual(stdlib.tuple(["orient", "orient", "Orient", "horizontal", "horizontal"]), scale.configure("orient"))
            AhkTest.AssertEqual(stdlib.tuple(["length", "length", "Length", 100, 120]), scale.configure("length"))
            AhkTest.AssertEqual(stdlib.tuple(["takefocus", "takeFocus", "TakeFocus", "ttk::takefocus", 1]), scale.configure("takefocus"))
            AhkTest.AssertEqual(stdlib.tuple(["cursor", "cursor", "Cursor", "", "arrow"]), scale.configure("cursor"))
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", "Horizontal.TScale"]), scale.configure("style"))
            AhkTest.AssertEqual(stdlib.tuple(["class", "", "", "", "ProbeScale"]), scale.configure("class"))
            AhkTest.AssertSame(scale, root.nametowidget("ttk_scale_probe"))

            AhkTest.AssertEqual("", scale.identify(5, 5))
            AhkTest.AssertEqual(stdlib.None, scale.set(7.25))
            AhkTest.AssertEqual(7.25, scale.get())
            AhkTest.AssertEqual(7.25, variable.get())
            AhkTest.AssertEqual(stdlib.tuple(), scale.state())
            AhkTest.AssertEqual(stdlib.tuple(["!disabled"]), scale.state(["disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(["disabled"]), scale.state())
            AhkTest.AssertSame(stdlib.True, scale.instate(["disabled"]))
            AhkTest.AssertSame(stdlib.False, scale.instate(["!disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(["cb", "x"]), scale.instate(["disabled"], (args*) => stdlib.tuple(["cb", args[1]]), "x"))
            AhkTest.AssertEqual(stdlib.tuple(["disabled"]), scale.state(["!disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(), scale.state())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.Scale(root, { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad orient "diagonal": must be horizontal or vertical$', (*) => stdlib.tkinter.ttk.Scale(root, { orient: "diagonal" }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.ttk_scale_probe get \?x y\?"$', (*) => scale.get(1))
            AhkTest.RaisesMatch(TypeError, "^Widget\.identify\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => scale.identify())
            AhkTest.RaisesMatch(TypeError, "^Scale\.set\(\) missing 1 required positional argument: 'value'$", (*) => scale.set())
            AhkTest.RaisesMatch(TypeError, "^Widget\.state\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => scale.state(["disabled"], "extra"))
            AhkTest.RaisesMatch(TypeError, "^Widget\.instate\(\) missing 1 required positional argument: 'statespec'$", (*) => scale.instate())
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => scale.state(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^Invalid state name d$", (*) => scale.state("disabled"))
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => scale.instate(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkScrollbarPublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Scrollbar"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Scrollbar("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            defaultScrollbar := stdlib.tkinter.ttk.Scrollbar({ name: "ttk_scroll_default_probe" })
            AhkTest.AssertTrue(defaultScrollbar is stdlib.tkinter.ttk.Scrollbar)
            AhkTest.AssertEqual(".ttk_scroll_default_probe", String(defaultScrollbar))
            AhkTest.AssertEqual("ttk::scrollbar", defaultScrollbar.widgetName)
            AhkTest.AssertEqual("TScrollbar", defaultScrollbar.winfo_class())
            AhkTest.AssertEqual(stdlib.tuple(), defaultScrollbar.state())

            scrollbar := stdlib.tkinter.ttk.Scrollbar(root, { orient: "vertical", takefocus: 1, cursor: "arrow", style: "Vertical.TScrollbar", class: "ProbeScroll", name: "ttk_scroll_probe" })
            AhkTest.AssertTrue(scrollbar is stdlib.tkinter.ttk.Scrollbar)
            AhkTest.AssertEqual(".ttk_scroll_probe", String(scrollbar))
            AhkTest.AssertEqual("ttk::scrollbar", scrollbar.widgetName)
            AhkTest.AssertSame(root, scrollbar.master)
            AhkTest.AssertSame(root.tk, scrollbar.tk)
            AhkTest.AssertEqual("ProbeScroll", scrollbar.winfo_class())
            AhkTest.AssertEqual("vertical", scrollbar.cget("orient"))
            AhkTest.AssertEqual(1, scrollbar.cget("takefocus"))
            AhkTest.AssertEqual("arrow", scrollbar.cget("cursor"))
            AhkTest.AssertEqual("Vertical.TScrollbar", scrollbar.cget("style"))
            AhkTest.AssertEqual("ProbeScroll", scrollbar.cget("class"))
            AhkTest.AssertContains("orient", scrollbar.keys())
            AhkTest.AssertContains("takefocus", scrollbar.keys())
            AhkTest.AssertContains("cursor", scrollbar.keys())
            AhkTest.AssertContains("style", scrollbar.keys())
            AhkTest.AssertContains("class", scrollbar.keys())
            AhkTest.AssertEqual(stdlib.tuple(["orient", "orient", "Orient", "vertical", "vertical"]), scrollbar.configure("orient"))
            AhkTest.AssertEqual(stdlib.tuple(["takefocus", "takeFocus", "TakeFocus", "", 1]), scrollbar.configure("takefocus"))
            AhkTest.AssertEqual(stdlib.tuple(["cursor", "cursor", "Cursor", "", "arrow"]), scrollbar.configure("cursor"))
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", "Vertical.TScrollbar"]), scrollbar.configure("style"))
            AhkTest.AssertEqual(stdlib.tuple(["class", "", "", "", "ProbeScroll"]), scrollbar.configure("class"))
            AhkTest.AssertSame(scrollbar, root.nametowidget("ttk_scroll_probe"))
            AhkTest.AssertTrue(HasMethod(scrollbar, "activate"))

            AhkTest.AssertEqual(stdlib.tuple([0.0, 1.0]), scrollbar.get())
            AhkTest.AssertEqual(stdlib.None, scrollbar.set(0.25, 0.75))
            AhkTest.AssertEqual(stdlib.tuple([0.25, 0.75]), scrollbar.get())
            AhkTest.AssertEqual(0.0, scrollbar.delta(10, 5))
            AhkTest.AssertEqual(0.0, scrollbar.fraction(10, 5))
            AhkTest.AssertEqual("", scrollbar.identify(5, 5))
            AhkTest.AssertEqual(stdlib.tuple(), scrollbar.state())
            AhkTest.AssertEqual(stdlib.tuple(["!disabled"]), scrollbar.state(["disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(["disabled"]), scrollbar.state())
            AhkTest.AssertSame(stdlib.True, scrollbar.instate(["disabled"]))
            AhkTest.AssertSame(stdlib.False, scrollbar.instate(["!disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(["cb", "x"]), scrollbar.instate(["disabled"], (args*) => stdlib.tuple(["cb", args[1]]), "x"))
            AhkTest.AssertEqual(stdlib.tuple(["disabled"]), scrollbar.state(["!disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(), scrollbar.state())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.Scrollbar(root, { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad orient "diagonal": must be horizontal or vertical$', (*) => stdlib.tkinter.ttk.Scrollbar(root, { orient: "diagonal" }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad command "activate": must be configure, cget, delta, fraction, get, identify, instate, set, or state$', (*) => scrollbar.activate())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad command "activate": must be configure, cget, delta, fraction, get, identify, instate, set, or state$', (*) => scrollbar.activate("arrow1"))
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.activate\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => scrollbar.activate("a", "b"))
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.delta\(\) missing 2 required positional arguments: 'deltax' and 'deltay'$", (*) => scrollbar.delta())
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.fraction\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => scrollbar.fraction())
            AhkTest.RaisesMatch(TypeError, "^Widget\.identify\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => scrollbar.identify())
            AhkTest.RaisesMatch(TypeError, "^Scrollbar\.set\(\) missing 2 required positional arguments: 'first' and 'last'$", (*) => scrollbar.set())
            AhkTest.RaisesMatch(TypeError, "^Widget\.state\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => scrollbar.state(["disabled"], "extra"))
            AhkTest.RaisesMatch(TypeError, "^Widget\.instate\(\) missing 1 required positional argument: 'statespec'$", (*) => scrollbar.instate())
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => scrollbar.state(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^Invalid state name d$", (*) => scrollbar.state("disabled"))
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => scrollbar.instate(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkNotebookPublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Notebook"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Notebook("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            defaultNotebook := stdlib.tkinter.ttk.Notebook({ name: "ttk_notebook_default_probe" })
            AhkTest.AssertTrue(defaultNotebook is stdlib.tkinter.ttk.Notebook)
            AhkTest.AssertEqual(".ttk_notebook_default_probe", String(defaultNotebook))
            AhkTest.AssertEqual("ttk::notebook", defaultNotebook.widgetName)
            AhkTest.AssertEqual("TNotebook", defaultNotebook.winfo_class())
            AhkTest.AssertEqual(0, defaultNotebook.index("end"))
            AhkTest.AssertEqual(stdlib.tuple(), defaultNotebook.tabs())
            AhkTest.AssertEqual("", defaultNotebook.select())
            AhkTest.AssertSame(defaultNotebook, defaultNotebook.master.nametowidget("ttk_notebook_default_probe"))

            notebook := stdlib.tkinter.ttk.Notebook(root, { padding: 5, takefocus: 1, cursor: "arrow", style: "Probe.TNotebook", name: "ttk_notebook_probe" })
            AhkTest.AssertTrue(notebook is stdlib.tkinter.ttk.Notebook)
            AhkTest.AssertEqual(".ttk_notebook_probe", String(notebook))
            AhkTest.AssertEqual("ttk::notebook", notebook.widgetName)
            AhkTest.AssertSame(root, notebook.master)
            AhkTest.AssertSame(root.tk, notebook.tk)
            AhkTest.AssertEqual("TNotebook", notebook.winfo_class())
            AhkTest.AssertEqual(stdlib.tuple(["5"]), notebook.cget("padding"))
            AhkTest.AssertEqual(1, notebook.cget("takefocus"))
            AhkTest.AssertEqual("arrow", notebook.cget("cursor"))
            AhkTest.AssertEqual("Probe.TNotebook", notebook.cget("style"))
            AhkTest.AssertEqual("", notebook.cget("class"))
            AhkTest.AssertContains("width", notebook.keys())
            AhkTest.AssertContains("height", notebook.keys())
            AhkTest.AssertContains("padding", notebook.keys())
            AhkTest.AssertContains("takefocus", notebook.keys())
            AhkTest.AssertContains("cursor", notebook.keys())
            AhkTest.AssertContains("style", notebook.keys())
            AhkTest.AssertContains("class", notebook.keys())
            AhkTest.AssertEqual(stdlib.tuple(["padding", "padding", "Padding", "", stdlib.tuple(["5"])]), notebook.configure("padding"))
            AhkTest.AssertEqual(stdlib.tuple(["takefocus", "takeFocus", "TakeFocus", "ttk::takefocus", 1]), notebook.configure("takefocus"))
            AhkTest.AssertEqual(stdlib.tuple(["cursor", "cursor", "Cursor", "", "arrow"]), notebook.configure("cursor"))
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", "Probe.TNotebook"]), notebook.configure("style"))
            AhkTest.AssertEqual(stdlib.tuple(["class", "", "", "", ""]), notebook.configure("class"))
            AhkTest.AssertSame(notebook, root.nametowidget("ttk_notebook_probe"))

            pageOne := stdlib.tkinter.ttk.Frame(notebook, { name: "page_one" })
            pageTwo := stdlib.tkinter.ttk.Frame(notebook, { name: "page_two" })
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^\.ttk_notebook_probe\.page_one is not managed by \.ttk_notebook_probe$", (*) => notebook.tab(pageOne))
            AhkTest.AssertEqual(stdlib.None, notebook.add(pageOne, { text: "Page One", padding: 4, sticky: "nsew" }))
            AhkTest.AssertEqual(stdlib.None, notebook.add(pageTwo, { text: "Page Two", state: "disabled" }))
            AhkTest.AssertEqual(stdlib.tuple([".ttk_notebook_probe.page_one", ".ttk_notebook_probe.page_two"]), notebook.tabs())
            AhkTest.AssertEqual(2, notebook.index("end"))
            AhkTest.AssertEqual(0, notebook.index(pageOne))
            AhkTest.AssertEqual(1, notebook.index(pageTwo))
            AhkTest.AssertEqual(".ttk_notebook_probe.page_one", notebook.select())
            AhkTest.AssertEqual(".ttk_notebook_probe.page_one", notebook.select(stdlib.None))
            AhkTest.AssertEqual("", notebook.select(pageTwo))
            AhkTest.AssertEqual(".ttk_notebook_probe.page_one", notebook.select())
            AhkTest.AssertTrue(HasMethod(notebook, "identify"))
            AhkTest.AssertEqual(stdlib.None, notebook.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("", notebook.identify(1, 1))
            AhkTest.AssertEqual("tab", notebook.identify(5, 5))
            AhkTest.RaisesMatch(TypeError, "^Notebook\.identify\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => notebook.identify())
            AhkTest.RaisesMatch(TypeError, "^Notebook\.identify\(\) missing 1 required positional argument: 'y'$", (*) => notebook.identify(1))
            AhkTest.RaisesMatch(TypeError, "^Notebook\.identify\(\) takes 3 positional arguments but 4 were given$", (*) => notebook.identify(1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => notebook.identify("bad", 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => notebook.identify(1, "bad"))

            tabInfo := notebook.tab(pageOne)
            AhkTest.AssertTrue(tabInfo is Map)
            AhkTest.AssertEqual("Page One", tabInfo["text"])
            AhkTest.AssertEqual([4], tabInfo["padding"])
            AhkTest.AssertEqual("nsew", tabInfo["sticky"])
            AhkTest.AssertEqual("normal", tabInfo["state"])
            AhkTest.AssertEqual("", tabInfo["image"])
            AhkTest.AssertEqual("", tabInfo["compound"])
            AhkTest.AssertEqual(-1, tabInfo["underline"])
            AhkTest.AssertEqual("Page One", notebook.tab(pageOne, "text"))
            AhkTest.AssertEqual(stdlib.tuple(["4"]), notebook.tab(pageOne, "padding"))
            AhkTest.AssertEqual("nsew", notebook.tab(pageOne, "sticky"))
            AhkTest.AssertEqual("normal", notebook.tab(pageOne, "state"))
            AhkTest.AssertEqual(Map(), notebook.tab(pageOne, { text: "One", state: "disabled" }))
            AhkTest.AssertEqual("One", notebook.tab(pageOne, "text"))
            AhkTest.AssertEqual("disabled", notebook.tab(pageOne, "state"))
            AhkTest.AssertEqual(stdlib.None, notebook.hide(pageOne))
            AhkTest.AssertEqual("hidden", notebook.tab(pageOne, "state"))
            AhkTest.AssertEqual(stdlib.None, notebook.forget(pageOne))
            AhkTest.AssertEqual(stdlib.tuple([".ttk_notebook_probe.page_two"]), notebook.tabs())

            pageThree := stdlib.tkinter.ttk.Frame(notebook, { name: "page_three" })
            AhkTest.AssertEqual(stdlib.None, notebook.insert("end", pageThree, { text: "Page Three" }))
            AhkTest.AssertEqual(stdlib.tuple([".ttk_notebook_probe.page_two", ".ttk_notebook_probe.page_three"]), notebook.tabs())
            AhkTest.AssertEqual("", notebook.select(pageThree))
            AhkTest.AssertEqual(".ttk_notebook_probe.page_three", notebook.select())
            AhkTest.AssertEqual(stdlib.None, notebook.enable_traversal())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-text"$', (*) => stdlib.tkinter.ttk.Notebook(root, { text: "bad" }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => notebook.add(pageThree, { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^Invalid slave specification bad$', (*) => notebook.index("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^Invalid slave specification bad$', (*) => notebook.select("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => notebook.tab(pageThree, "bad"))
            AhkTest.RaisesMatch(TypeError, "^Notebook\.add\(\) missing 1 required positional argument: 'child'$", (*) => notebook.add())
            AhkTest.RaisesMatch(TypeError, "^Notebook\.insert\(\) missing 2 required positional arguments: 'pos' and 'child'$", (*) => notebook.insert())
            AhkTest.RaisesMatch(TypeError, "^Notebook\.tab\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => notebook.tab(pageThree, "text", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Notebook\.tabs\(\) takes 1 positional argument but 2 were given$", (*) => notebook.tabs("extra"))
            AhkTest.RaisesMatch(TypeError, "^Notebook\.enable_traversal\(\) takes 1 positional argument but 2 were given$", (*) => notebook.enable_traversal("extra"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkPanedwindowPublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Panedwindow"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Panedwindow("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            defaultPaned := stdlib.tkinter.ttk.Panedwindow({ name: "ttk_paned_default_probe" })
            AhkTest.AssertTrue(defaultPaned is stdlib.tkinter.ttk.Panedwindow)
            AhkTest.AssertEqual(".ttk_paned_default_probe", String(defaultPaned))
            AhkTest.AssertEqual("ttk::panedwindow", defaultPaned.widgetName)
            AhkTest.AssertEqual("TPanedwindow", defaultPaned.winfo_class())
            AhkTest.AssertEqual(stdlib.tuple(), defaultPaned.panes())
            AhkTest.AssertSame(defaultPaned, defaultPaned.master.nametowidget("ttk_paned_default_probe"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^sash index 0 out of range$", (*) => defaultPaned.sashpos(0))

            paned := stdlib.tkinter.ttk.Panedwindow(root, { orient: "vertical", width: 160, height: 90, style: "Probe.TPanedwindow", takefocus: 1, cursor: "arrow", name: "ttk_paned_probe" })
            AhkTest.AssertTrue(paned is stdlib.tkinter.ttk.Panedwindow)
            AhkTest.AssertEqual(".ttk_paned_probe", String(paned))
            AhkTest.AssertEqual("ttk::panedwindow", paned.widgetName)
            AhkTest.AssertSame(root, paned.master)
            AhkTest.AssertSame(root.tk, paned.tk)
            AhkTest.AssertEqual("TPanedwindow", paned.winfo_class())
            AhkTest.AssertEqual("vertical", paned.cget("orient"))
            AhkTest.AssertEqual(160, paned.cget("width"))
            AhkTest.AssertEqual(90, paned.cget("height"))
            AhkTest.AssertEqual("Probe.TPanedwindow", paned.cget("style"))
            AhkTest.AssertEqual(1, paned.cget("takefocus"))
            AhkTest.AssertEqual("arrow", paned.cget("cursor"))
            AhkTest.AssertEqual("", paned.cget("class"))
            AhkTest.AssertContains("orient", paned.keys())
            AhkTest.AssertContains("width", paned.keys())
            AhkTest.AssertContains("height", paned.keys())
            AhkTest.AssertContains("takefocus", paned.keys())
            AhkTest.AssertContains("cursor", paned.keys())
            AhkTest.AssertContains("style", paned.keys())
            AhkTest.AssertContains("class", paned.keys())
            AhkTest.AssertEqual(stdlib.tuple(["orient", "orient", "Orient", "vertical", "vertical"]), paned.configure("orient"))
            AhkTest.AssertEqual(stdlib.tuple(["width", "width", "Width", 0, 160]), paned.configure("width"))
            AhkTest.AssertEqual(stdlib.tuple(["height", "height", "Height", 0, 90]), paned.configure("height"))
            AhkTest.AssertEqual(stdlib.tuple(["takefocus", "takeFocus", "TakeFocus", "", 1]), paned.configure("takefocus"))
            AhkTest.AssertEqual(stdlib.tuple(["cursor", "cursor", "Cursor", "", "arrow"]), paned.configure("cursor"))
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", "Probe.TPanedwindow"]), paned.configure("style"))
            AhkTest.AssertEqual(stdlib.tuple(["class", "", "", "", ""]), paned.configure("class"))
            AhkTest.AssertSame(paned, root.nametowidget("ttk_paned_probe"))

            paneOne := stdlib.tkinter.ttk.Frame(paned, { name: "one" })
            paneTwo := stdlib.tkinter.ttk.Frame(paned, { name: "two" })
            AhkTest.AssertEqual(stdlib.None, paned.add(paneOne, { weight: 2 }))
            AhkTest.AssertEqual(stdlib.None, paned.add(paneTwo, { weight: 3 }))
            AhkTest.AssertEqual(stdlib.tuple([".ttk_paned_probe.one", ".ttk_paned_probe.two"]), paned.panes())
            paneOneInfo := paned.pane(paneOne)
            AhkTest.AssertTrue(paneOneInfo is Map)
            AhkTest.AssertEqual(2, paneOneInfo["weight"])
            AhkTest.AssertEqual(3, paned.pane(paneTwo, "weight"))
            AhkTest.AssertEqual(Map(), paned.pane(paneOne, { weight: 4 }))
            AhkTest.AssertEqual(4, paned.pane(paneOne, "weight"))
            AhkTest.AssertEqual(0, paned.identify(5, 5))
            AhkTest.AssertEqual(stdlib.None, paned.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            sashposInitial := paned.sashpos(0)
            AhkTest.AssertTrue(sashposInitial is Integer)
            sashposSet := paned.sashpos(0, 33)
            AhkTest.AssertTrue(sashposSet is Integer)
            AhkTest.AssertEqual(sashposSet, paned.sashpos(0))
            AhkTest.AssertEqual(stdlib.None, paned.insert("end", paneOne))
            AhkTest.AssertEqual(stdlib.None, paned.forget(paneTwo))
            AhkTest.AssertEqual(stdlib.tuple([".ttk_paned_probe.one"]), paned.panes())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.Panedwindow(root, { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => paned.add(paneTwo, { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => paned.pane(paneOne, "bad"))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.add\(\) missing 1 required positional argument: 'child'$", (*) => paned.add())
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.add\(\) takes 2 positional arguments but 4 were given$", (*) => paned.add(paneOne, {}, "extra"))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.remove\(\) missing 1 required positional argument: 'child'$", (*) => paned.forget())
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.remove\(\) takes 2 positional arguments but 3 were given$", (*) => paned.forget(paneOne, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Widget\.identify\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => paned.identify())
            AhkTest.RaisesMatch(TypeError, "^Widget\.identify\(\) missing 1 required positional argument: 'y'$", (*) => paned.identify(1))
            AhkTest.RaisesMatch(TypeError, "^Widget\.identify\(\) takes 3 positional arguments but 4 were given$", (*) => paned.identify(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^Panedwindow\.insert\(\) missing 2 required positional arguments: 'pos' and 'child'$", (*) => paned.insert())
            AhkTest.RaisesMatch(TypeError, "^Panedwindow\.insert\(\) missing 1 required positional argument: 'child'$", (*) => paned.insert("end"))
            AhkTest.RaisesMatch(TypeError, "^Panedwindow\.insert\(\) takes 3 positional arguments but 5 were given$", (*) => paned.insert("end", paneOne, {}, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Panedwindow\.pane\(\) missing 1 required positional argument: 'pane'$", (*) => paned.pane())
            AhkTest.RaisesMatch(TypeError, "^Panedwindow\.pane\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => paned.pane(paneOne, "weight", "extra"))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.panes\(\) takes 1 positional argument but 2 were given$", (*) => paned.panes("extra"))
            AhkTest.RaisesMatch(TypeError, "^Panedwindow\.sashpos\(\) missing 1 required positional argument: 'index'$", (*) => paned.sashpos())
            AhkTest.RaisesMatch(TypeError, "^Panedwindow\.sashpos\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => paned.sashpos(0, 1, 2))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTtkSizegripPublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "Sizegrip"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.Sizegrip("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            defaultSizegrip := stdlib.tkinter.ttk.Sizegrip({ name: "ttk_sizegrip_default_probe" })
            AhkTest.AssertTrue(defaultSizegrip is stdlib.tkinter.ttk.Sizegrip)
            AhkTest.AssertEqual(".ttk_sizegrip_default_probe", String(defaultSizegrip))
            AhkTest.AssertEqual("ttk::sizegrip", defaultSizegrip.widgetName)
            AhkTest.AssertEqual("TSizegrip", defaultSizegrip.winfo_class())
            AhkTest.AssertSame(defaultSizegrip, defaultSizegrip.master.nametowidget("ttk_sizegrip_default_probe"))

            sizegrip := stdlib.tkinter.ttk.Sizegrip(root, { cursor: "sizing", style: "Probe.TSizegrip", name: "ttk_sizegrip_probe" })
            AhkTest.AssertTrue(sizegrip is stdlib.tkinter.ttk.Sizegrip)
            AhkTest.AssertEqual(".ttk_sizegrip_probe", String(sizegrip))
            AhkTest.AssertEqual("ttk::sizegrip", sizegrip.widgetName)
            AhkTest.AssertSame(root, sizegrip.master)
            AhkTest.AssertSame(root.tk, sizegrip.tk)
            AhkTest.AssertEqual("TSizegrip", sizegrip.winfo_class())
            AhkTest.AssertEqual("sizing", sizegrip.cget("cursor"))
            AhkTest.AssertEqual("Probe.TSizegrip", sizegrip.cget("style"))
            AhkTest.AssertEqual("", sizegrip.cget("class"))
            AhkTest.AssertContains("cursor", sizegrip.keys())
            AhkTest.AssertContains("style", sizegrip.keys())
            AhkTest.AssertContains("class", sizegrip.keys())
            AhkTest.AssertContains("takefocus", sizegrip.keys())
            AhkTest.AssertEqual(stdlib.tuple(["cursor", "cursor", "Cursor", "", "sizing"]), sizegrip.configure("cursor"))
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", "Probe.TSizegrip"]), sizegrip.configure("style"))
            AhkTest.AssertEqual(stdlib.tuple(["class", "", "", "", ""]), sizegrip.configure("class"))
            AhkTest.AssertSame(sizegrip, root.nametowidget("ttk_sizegrip_probe"))

            AhkTest.AssertEqual("", sizegrip.identify(5, 5))
            AhkTest.AssertEqual(stdlib.tuple(), sizegrip.state())
            AhkTest.AssertSame(stdlib.False, sizegrip.instate(["selected"]))
            AhkTest.AssertEqual(stdlib.None, sizegrip.instate(["!disabled"], (*) => stdlib.None, "ok"))
            AhkTest.AssertEqual(stdlib.tuple(["!disabled"]), sizegrip.state(["disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(["disabled"]), sizegrip.state())
            AhkTest.AssertSame(stdlib.True, sizegrip.instate(["disabled"]))
            AhkTest.AssertSame(stdlib.False, sizegrip.instate(["!disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(["cb", "x"]), sizegrip.instate(["disabled"], (args*) => stdlib.tuple(["cb", args[1]]), "x"))
            AhkTest.AssertEqual(stdlib.tuple(["disabled"]), sizegrip.state(["!disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(), sizegrip.state())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.Sizegrip(root, { bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Widget\.identify\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => sizegrip.identify())
            AhkTest.RaisesMatch(TypeError, "^Widget\.identify\(\) missing 1 required positional argument: 'y'$", (*) => sizegrip.identify(1))
            AhkTest.RaisesMatch(TypeError, "^Widget\.identify\(\) takes 3 positional arguments but 4 were given$", (*) => sizegrip.identify(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^Widget\.state\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => sizegrip.state(["disabled"], "extra"))
            AhkTest.RaisesMatch(TypeError, "^Widget\.instate\(\) missing 1 required positional argument: 'statespec'$", (*) => sizegrip.instate())
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => sizegrip.state(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^Invalid state name d$", (*) => sizegrip.state("disabled"))
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => sizegrip.instate(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestPublicMixinConstructorsMatchLocal310()
    {
        mixins := [
            ["Pack", "pack", "tk"],
            ["Place", "place", "tk"],
            ["Grid", "grid", "tk"],
            ["XView", "xview", "tk"],
            ["YView", "yview", "tk"],
            ["Misc", "destroy", ""],
            ["Wm", "wm_title", "tk"]
        ]

        for entry in mixins {
            className := entry[1]
            methodName := entry[2]
            missingAttr := entry[3]
            AhkTest.AssertTrue(HasMethod(stdlib.tkinter, className), className)
            instance := StdlibTkinterTest.TkinterModuleCall(className)
            classObject := stdlib.tkinter.%className%
            AhkTest.AssertTrue(instance is classObject, className)
            AhkTest.AssertFalse(HasProp(instance, "tk"), className)
            AhkTest.AssertFalse(HasProp(instance, "_w"), className)
            AhkTest.AssertTrue(HasMethod(instance, methodName), className "." methodName)
            if missingAttr != ""
                AhkTest.RaisesMatch(AttributeError, "^'" className "' object has no attribute '" missingAttr "'$", (*) => StdlibTkinterTest.CallObjectMethod(instance, methodName))
            else
                AhkTest.AssertEqual(stdlib.None, StdlibTkinterTest.CallObjectMethod(instance, methodName))
            AhkTest.RaisesMatch(TypeError, "^" className "\(\) takes no arguments$", (*) => StdlibTkinterTest.TkinterModuleCall(className, "extra"))
        }
    }

    static TestTtkLabelFramePublicSurfaceMatchesLocal310()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "ttk"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter.ttk, "LabelFrame"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.ttk.LabelFrame("master"))

        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            labelFrame := stdlib.tkinter.ttk.LabelFrame(root, { text: "Group", width: 120, height: 40, padding: [1, 2, 3, 4], labelanchor: "ne", takefocus: 1, cursor: "crosshair", style: "Demo.TLabelframe", class: "CustomGroup", name: "ttk_labelframe_probe" })
            AhkTest.AssertTrue(labelFrame is stdlib.tkinter.ttk.LabelFrame)
            AhkTest.AssertEqual(".ttk_labelframe_probe", String(labelFrame))
            AhkTest.AssertEqual("ttk::labelframe", labelFrame.widgetName)
            AhkTest.AssertSame(root, labelFrame.master)
            AhkTest.AssertSame(root.tk, labelFrame.tk)
            AhkTest.AssertEqual("CustomGroup", labelFrame.winfo_class())
            AhkTest.AssertEqual("Group", labelFrame.cget("text"))
            AhkTest.AssertEqual(120, labelFrame.cget("width"))
            AhkTest.AssertEqual(40, labelFrame.cget("height"))
            AhkTest.AssertEqual(stdlib.tuple(["1", "2", "3", "4"]), labelFrame.cget("padding"))
            AhkTest.AssertEqual("ne", labelFrame.cget("labelanchor"))
            AhkTest.AssertEqual(1, labelFrame.cget("takefocus"))
            AhkTest.AssertEqual("crosshair", labelFrame.cget("cursor"))
            AhkTest.AssertEqual("Demo.TLabelframe", labelFrame.cget("style"))
            AhkTest.AssertEqual("CustomGroup", labelFrame.cget("class"))
            AhkTest.AssertContains("text", labelFrame.keys())
            AhkTest.AssertContains("width", labelFrame.keys())
            AhkTest.AssertContains("height", labelFrame.keys())
            AhkTest.AssertContains("padding", labelFrame.keys())
            AhkTest.AssertContains("labelanchor", labelFrame.keys())
            AhkTest.AssertContains("takefocus", labelFrame.keys())
            AhkTest.AssertContains("cursor", labelFrame.keys())
            AhkTest.AssertContains("style", labelFrame.keys())
            AhkTest.AssertContains("class", labelFrame.keys())
            AhkTest.AssertEqual(stdlib.tuple(["text", "text", "Text", "", "Group"]), labelFrame.configure("text"))
            AhkTest.AssertEqual(stdlib.tuple(["width", "width", "Width", 0, 120]), labelFrame.configure("width"))
            AhkTest.AssertEqual(stdlib.tuple(["height", "height", "Height", 0, 40]), labelFrame.configure("height"))
            AhkTest.AssertEqual(stdlib.tuple(["padding", "padding", "Pad", "", stdlib.tuple(["1", "2", "3", "4"])]), labelFrame.configure("padding"))
            AhkTest.AssertEqual(stdlib.tuple(["labelanchor", "labelAnchor", "LabelAnchor", "nw", "ne"]), labelFrame.configure("labelanchor"))
            AhkTest.AssertEqual(stdlib.tuple(["takefocus", "takeFocus", "TakeFocus", "", 1]), labelFrame.configure("takefocus"))
            AhkTest.AssertEqual(stdlib.tuple(["cursor", "cursor", "Cursor", "", "crosshair"]), labelFrame.configure("cursor"))
            AhkTest.AssertEqual(stdlib.tuple(["style", "style", "Style", "", "Demo.TLabelframe"]), labelFrame.configure("style"))
            AhkTest.AssertEqual(stdlib.tuple(["class", "", "", "", "CustomGroup"]), labelFrame.configure("class"))
            AhkTest.AssertSame(labelFrame, root.nametowidget("ttk_labelframe_probe"))

            AhkTest.AssertEqual("", labelFrame.identify(5, 5))
            AhkTest.AssertEqual(stdlib.tuple(), labelFrame.state())
            AhkTest.AssertSame(stdlib.False, labelFrame.instate(["selected"]))
            AhkTest.AssertEqual(stdlib.None, labelFrame.instate(["!disabled"], (*) => stdlib.None, "ok"))
            AhkTest.AssertEqual(stdlib.tuple(["!disabled"]), labelFrame.state(["disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(["disabled"]), labelFrame.state())
            AhkTest.AssertSame(stdlib.True, labelFrame.instate(["disabled"]))
            AhkTest.AssertSame(stdlib.False, labelFrame.instate(["!disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(["cb", "x"]), labelFrame.instate(["disabled"], (args*) => stdlib.tuple(["cb", args[1]]), "x"))
            AhkTest.AssertEqual(stdlib.tuple(["disabled"]), labelFrame.state(["!disabled"]))
            AhkTest.AssertEqual(stdlib.tuple(), labelFrame.state())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.ttk.LabelFrame(root, { bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Widget\.identify\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => labelFrame.identify())
            AhkTest.RaisesMatch(TypeError, "^Widget\.identify\(\) missing 1 required positional argument: 'y'$", (*) => labelFrame.identify(1))
            AhkTest.RaisesMatch(TypeError, "^Widget\.identify\(\) takes 3 positional arguments but 4 were given$", (*) => labelFrame.identify(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^Widget\.state\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => labelFrame.state(["disabled"], "extra"))
            AhkTest.RaisesMatch(TypeError, "^Widget\.instate\(\) missing 1 required positional argument: 'statespec'$", (*) => labelFrame.instate())
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => labelFrame.state(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^Invalid state name d$", (*) => labelFrame.state("disabled"))
            AhkTest.RaisesMatch(TypeError, "^can only join an iterable$", (*) => labelFrame.instate(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestWidgetPublicClassMatchesLocal310()
    {
        AhkTest.AssertTrue(HasMethod(stdlib.tkinter, "Widget"))
        AhkTest.RaisesMatch(TypeError, "^BaseWidget\.__init__\(\) missing 2 required positional arguments: 'master' and 'widgetName'$", (*) => stdlib.tkinter.Widget())
        AhkTest.RaisesMatch(TypeError, "^BaseWidget\.__init__\(\) missing 1 required positional argument: 'widgetName'$", (*) => stdlib.tkinter.Widget("master"))
        AhkTest.RaisesMatch(TypeError, "^BaseWidget\.__init__\(\) takes from 3 to 6 positional arguments but 7 were given$", (*) => stdlib.tkinter.Widget(stdlib.None, "label", {}, {}, [], "extra"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.Widget("master", "label"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'items'$", (*) => stdlib.tkinter.Widget(stdlib.None, "label", "bad"))
        AhkTest.RaisesMatch(ValueError, "^dictionary update sequence element #0 has length 1; 2 is required$", (*) => stdlib.tkinter.Widget(stdlib.None, "label", {}, "bad"))

        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            widget := stdlib.tkinter.Widget(root, "label", { text: "Widget", name: "public_widget_probe" })
            AhkTest.AssertTrue(widget is stdlib.tkinter.Widget)
            AhkTest.AssertEqual(".public_widget_probe", String(widget))
            AhkTest.AssertEqual("label", widget.widgetName)
            AhkTest.AssertSame(root, widget.master)
            AhkTest.AssertSame(root.tk, widget.tk)
            AhkTest.AssertEqual("Widget", widget.cget("text"))
            AhkTest.AssertSame(widget, root.nametowidget("public_widget_probe"))
            AhkTest.AssertEqual(stdlib.None, widget.pack())
            AhkTest.AssertSame(root, widget.pack_info()["in"])

            merged := stdlib.tkinter.Widget(root, "label", { text: "cnf" }, { text: "kw", name: "public_widget_kw_probe" })
            AhkTest.AssertEqual(".public_widget_kw_probe", String(merged))
            AhkTest.AssertEqual("kw", merged.cget("text"))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.Widget(root, "label", { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^invalid command name "badwidget"$', (*) => stdlib.tkinter.Widget(root, "badwidget", {}))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestBaseWidgetPublicClassMatchesLocal310()
    {
        AhkTest.AssertTrue(HasMethod(stdlib.tkinter, "BaseWidget"))
        AhkTest.RaisesMatch(TypeError, "^BaseWidget\.__init__\(\) missing 2 required positional arguments: 'master' and 'widgetName'$", (*) => stdlib.tkinter.BaseWidget())
        AhkTest.RaisesMatch(TypeError, "^BaseWidget\.__init__\(\) missing 1 required positional argument: 'widgetName'$", (*) => stdlib.tkinter.BaseWidget("master"))
        AhkTest.RaisesMatch(TypeError, "^BaseWidget\.__init__\(\) takes from 3 to 6 positional arguments but 7 were given$", (*) => stdlib.tkinter.BaseWidget(stdlib.None, "label", {}, {}, [], "extra"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'tk'$", (*) => stdlib.tkinter.BaseWidget("master", "label"))
        AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'items'$", (*) => stdlib.tkinter.BaseWidget(stdlib.None, "label", "bad"))
        AhkTest.RaisesMatch(ValueError, "^dictionary update sequence element #0 has length 1; 2 is required$", (*) => stdlib.tkinter.BaseWidget(stdlib.None, "label", {}, "bad"))

        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            widget := stdlib.tkinter.BaseWidget(root, "label", { text: "BaseWidget", name: "public_basewidget_probe" })
            AhkTest.AssertTrue(widget is stdlib.tkinter.BaseWidget)
            AhkTest.AssertEqual(".public_basewidget_probe", String(widget))
            AhkTest.AssertEqual("label", widget.widgetName)
            AhkTest.AssertSame(root, widget.master)
            AhkTest.AssertSame(root.tk, widget.tk)
            AhkTest.AssertEqual("BaseWidget", widget.cget("text"))
            AhkTest.AssertEqual("Label", widget.winfo_class())
            AhkTest.AssertTrue(HasMethod(widget, "destroy"))
            AhkTest.AssertFalse(HasMethod(widget, "pack"))
            AhkTest.AssertFalse(HasMethod(widget, "place"))
            AhkTest.AssertFalse(HasMethod(widget, "grid"))
            AhkTest.AssertSame(widget, root.nametowidget("public_basewidget_probe"))
            AhkTest.AssertEqual(stdlib.None, widget.configure({ text: "Changed" }))
            AhkTest.AssertEqual("Changed", widget.cget("text"))

            merged := stdlib.tkinter.BaseWidget(root, "label", { text: "cnf" }, { text: "kw", name: "public_basewidget_kw_probe" })
            AhkTest.AssertEqual(".public_basewidget_kw_probe", String(merged))
            AhkTest.AssertEqual("kw", merged.cget("text"))

            AhkTest.RaisesMatch(AttributeError, "^'BaseWidget' object has no attribute 'pack'$", (*) => StdlibTkinterTest.CallObjectMethod(widget, "pack"))
            AhkTest.RaisesMatch(TypeError, '^can only concatenate tuple \(not "str"\) to tuple$', (*) => stdlib.tkinter.BaseWidget(root, "label", {}, {}, "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.BaseWidget(root, "label", { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^invalid command name "badwidget"$', (*) => stdlib.tkinter.BaseWidget(root, "badwidget", {}))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkLoadtkMatchesLocal310()
    {
        interp := stdlib.tkinter.Tcl()
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            AhkTest.AssertTrue(HasMethod(interp, "loadtk"))
            AhkTest.AssertTrue(HasMethod(root, "loadtk"))
            AhkTest.AssertEqual("", interp.eval("info commands winfo"))
            AhkTest.AssertEqual(stdlib.None, interp.loadtk())
            AhkTest.AssertEqual("winfo", interp.eval("info commands winfo"))
            AhkTest.AssertEqual("8.6.12", interp.eval("package require Tk"))
            AhkTest.AssertEqual(stdlib.None, interp.loadtk())
            AhkTest.AssertEqual(stdlib.None, root.loadtk())
            AhkTest.RaisesMatch(TypeError, "^Tk\.loadtk\(\) takes 1 positional argument but 2 were given$", (*) => root.loadtk(1))
        } finally {
            try interp.destroy()
            try root.destroy()
        }
    }

    static TestTkReadprofileTclFilesMatchLocal310()
    {
        profileRoot := A_Temp "\stdlib-tkinter-readprofile-" A_TickCount "-" Random(100000, 999999)
        badRoot := A_Temp "\stdlib-tkinter-readprofile-bad-" A_TickCount "-" Random(100000, 999999)
        savedHome := EnvGet("HOME")
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            DirCreate profileRoot
            FileAppend "set class_tcl_seen 1`nlappend profile_order class_tcl`n", profileRoot "\.ClassProbe.tcl", "UTF-8-RAW"
            FileAppend "set base_tcl_seen 1`nlappend profile_order base_tcl`n", profileRoot "\.BaseProbe.tcl", "UTF-8-RAW"
            EnvSet("HOME", profileRoot)

            AhkTest.AssertTrue(HasMethod(root, "readprofile"))
            AhkTest.AssertEqual(stdlib.None, root.readprofile("BaseProbe", "ClassProbe"))
            AhkTest.AssertEqual("1", root.getvar("class_tcl_seen"))
            AhkTest.AssertEqual("1", root.getvar("base_tcl_seen"))
            AhkTest.AssertEqual("class_tcl base_tcl", root.getvar("profile_order"))
            AhkTest.AssertEqual(stdlib.None, root.readprofile("MissingBase", "MissingClass"))

            AhkTest.RaisesMatch(TypeError, "^Tk\.readprofile\(\) missing 2 required positional arguments: 'baseName' and 'className'$", (*) => root.readprofile())
            AhkTest.RaisesMatch(TypeError, "^Tk\.readprofile\(\) takes 3 positional arguments but 4 were given$", (*) => root.readprofile("a", "b", "c"))

            DirCreate badRoot
            FileAppend "this is not valid tcl !!!`n", badRoot "\.ClassBad.tcl", "UTF-8-RAW"
            EnvSet("HOME", badRoot)
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^invalid command name "this"$', (*) => root.readprofile("BaseBad", "ClassBad"))
        } finally {
            if savedHome != ""
                EnvSet("HOME", savedHome)
            else
                EnvSet("HOME")
            try root.destroy()
            try DirDelete profileRoot, true
            try DirDelete badRoot, true
        }
    }

    static TestTkReportCallbackExceptionMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            label := stdlib.tkinter.Label(root, { name: "report_callback_label", text: "report" })

            AhkTest.AssertTrue(HasMethod(root, "report_callback_exception"))
            AhkTest.AssertFalse(HasMethod(label, "report_callback_exception"))
            AhkTest.AssertEqual(stdlib.None, root.report_callback_exception("Error", Error("direct"), "traceback"))
            AhkTest.RaisesMatch(TypeError, "^Tk\.report_callback_exception\(\) missing 3 required positional arguments: 'exc', 'val', and 'tb'$", (*) => root.report_callback_exception())
            AhkTest.RaisesMatch(TypeError, "^Tk\.report_callback_exception\(\) missing 2 required positional arguments: 'val' and 'tb'$", (*) => root.report_callback_exception("exc"))
            AhkTest.RaisesMatch(TypeError, "^Tk\.report_callback_exception\(\) missing 1 required positional argument: 'tb'$", (*) => root.report_callback_exception("exc", "val"))
            AhkTest.RaisesMatch(TypeError, "^Tk\.report_callback_exception\(\) takes 4 positional arguments but 5 were given$", (*) => root.report_callback_exception("exc", "val", "tb", "extra"))

            reports := []
            root.DefineProp("report_callback_exception", { Call: (self, exc, val, tb) => (reports.Push({ Exc: exc, Value: val, Traceback: tb }), "ignored") })
            button := stdlib.tkinter.Button(root, { name: "report_callback_button", command: (*) => StdlibTkinterTest.ThrowCallbackError("callback boom") })

            AhkTest.AssertEqual("None", button.invoke())
            AhkTest.AssertEqual(1, reports.Length)
            AhkTest.AssertEqual("Error", reports[1].Exc)
            AhkTest.AssertTrue(reports[1].Value is Error)
            AhkTest.AssertEqual("callback boom", reports[1].Value.Message)
            AhkTest.AssertTrue(reports[1].Traceback != "")
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
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

    static TestTkStrictMotifMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            label := stdlib.tkinter.Label(root, { name: "strict_label", text: "strict" })
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            AhkTest.AssertTrue(HasMethod(root, "tk_strictMotif"))
            AhkTest.AssertTrue(HasMethod(label, "tk_strictMotif"))
            AhkTest.AssertSame(stdlib.False, root.tk_strictMotif())
            AhkTest.AssertSame(stdlib.False, label.tk_strictMotif())
            AhkTest.AssertSame(stdlib.True, root.tk_strictMotif(stdlib.True))
            AhkTest.AssertSame(stdlib.True, root.tk_strictMotif())
            AhkTest.AssertSame(stdlib.True, label.tk_strictMotif())
            AhkTest.AssertEqual("1", root.eval("set tk_strictMotif"))
            AhkTest.AssertSame(stdlib.False, label.tk_strictMotif(stdlib.False))
            AhkTest.AssertSame(stdlib.False, root.tk_strictMotif())
            AhkTest.AssertEqual("0", root.eval("set tk_strictMotif"))
            AhkTest.AssertSame(stdlib.True, root.tk_strictMotif("yes"))
            AhkTest.AssertSame(stdlib.False, label.tk_strictMotif("no"))
            AhkTest.AssertSame(stdlib.False, root.tk_strictMotif(stdlib.None))
            AhkTest.AssertSame(stdlib.True, root.tk_strictMotif(1))
            AhkTest.AssertSame(stdlib.False, label.tk_strictMotif(0))

            AhkTest.RaisesMatch(TypeError, "^Misc\.tk_strictMotif\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.tk_strictMotif(stdlib.True, stdlib.False))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^can't set " Chr(34) "tk_strictMotif" Chr(34) ": variable must have boolean value$", (*) => label.tk_strictMotif("bad"))
        } finally {
            try root.tk_strictMotif(stdlib.False)
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkBisquePaletteMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            before := stdlib.tkinter.Label(root, { name: "bisque_before", text: "before" })
            AhkTest.AssertEqual(stdlib.None, before.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            AhkTest.AssertTrue(HasMethod(root, "tk_bisque"))
            AhkTest.AssertTrue(HasMethod(before, "tk_bisque"))
            AhkTest.AssertEqual(stdlib.None, root.tk_bisque())

            after := stdlib.tkinter.Label(root, { name: "bisque_after", text: "after" })
            AhkTest.AssertEqual(stdlib.None, after.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual("#ffe4c4", after.cget("background"))
            AhkTest.AssertEqual("black", after.cget("foreground"))
            AhkTest.AssertEqual("#ffe4c4", root.option_get("background", "Background"))
            AhkTest.AssertEqual("black", root.option_get("foreground", "Foreground"))

            AhkTest.AssertEqual(stdlib.None, after.tk_bisque())
            another := stdlib.tkinter.Label(root, { name: "bisque_another", text: "another" })
            AhkTest.AssertEqual(stdlib.None, another.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual("#ffe4c4", another.cget("background"))

            AhkTest.RaisesMatch(TypeError, "^Misc\.tk_bisque\(\) takes 1 positional argument but 2 were given$", (*) => root.tk_bisque("extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.tk_bisque\(\) takes 1 positional argument but 2 were given$", (*) => after.tk_bisque("extra"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkSetPaletteMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            label := stdlib.tkinter.Label(root, { name: "palette_label", text: "palette" })
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            AhkTest.AssertTrue(HasMethod(root, "tk_setPalette"))
            AhkTest.AssertTrue(HasMethod(label, "tk_setPalette"))
            AhkTest.AssertEqual(stdlib.None, root.tk_setPalette("gray20"))
            AhkTest.AssertEqual("gray20", root.cget("background"))
            AhkTest.AssertEqual("gray20", label.cget("background"))
            AhkTest.AssertEqual("gray20", root.option_get("background", "Background"))

            AhkTest.AssertEqual(stdlib.None, label.tk_setPalette({ background: "gray30", foreground: "white" }))
            AhkTest.AssertEqual("gray30", root.cget("background"))
            AhkTest.AssertEqual("gray30", label.cget("background"))
            AhkTest.AssertEqual("white", label.cget("foreground"))
            AhkTest.AssertEqual("white", root.option_get("foreground", "Foreground"))

            after := stdlib.tkinter.Label(root, { name: "palette_after", text: "after" })
            AhkTest.AssertEqual(stdlib.None, after.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual("gray30", after.cget("background"))
            AhkTest.AssertEqual("white", after.cget("foreground"))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^must specify a background color$", (*) => root.tk_setPalette())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^must specify a background color$", (*) => label.tk_setPalette("gray10", "gray20"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown color name "notacolor"$', (*) => root.tk_setPalette("notacolor"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkRegisterAndDeletecommandMatchLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            label := stdlib.tkinter.Label(root, { name: "register_label", text: "register" })
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            calls := []
            callback := (args*) => (
                calls.Push(args),
                args.Length = 0 ? "ret:" : "ret:" args[1] (args.Length > 1 ? "|" args[2] : "")
            )

            AhkTest.AssertTrue(HasMethod(root, "register"))
            AhkTest.AssertTrue(HasMethod(root, "deletecommand"))
            AhkTest.AssertTrue(HasMethod(label, "register"))
            AhkTest.AssertTrue(HasMethod(label, "deletecommand"))

            commandName := root.register(callback)
            AhkTest.AssertTrue(commandName != "")
            AhkTest.AssertEqual(commandName, root.eval("info commands " commandName))
            AhkTest.AssertEqual("ret:", root.eval(commandName))
            AhkTest.AssertEqual(1, calls.Length)
            AhkTest.AssertEqual(0, calls[1].Length)
            AhkTest.AssertEqual("ret:a|b c", root.eval(commandName " a {b c}"))
            AhkTest.AssertEqual(2, calls.Length)
            AhkTest.AssertEqual("a", calls[2][1])
            AhkTest.AssertEqual("b c", calls[2][2])

            widgetCommandName := label.register(callback, stdlib.None)
            AhkTest.AssertTrue(widgetCommandName != "")
            AhkTest.AssertEqual(widgetCommandName, root.eval("info commands " widgetCommandName))
            AhkTest.AssertEqual("ret:x", root.eval(widgetCommandName " x"))
            AhkTest.AssertEqual(stdlib.None, label.deletecommand(widgetCommandName))
            AhkTest.AssertEqual("", root.eval("info commands " widgetCommandName))

            AhkTest.AssertEqual(stdlib.None, root.deletecommand(commandName))
            AhkTest.AssertEqual("", root.eval("info commands " commandName))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^invalid command name " Chr(34) commandName Chr(34) "$", (*) => root.eval(commandName))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^can't delete Tcl command$", (*) => root.deletecommand(commandName))

            AhkTest.RaisesMatch(TypeError, "^Misc\._register\(\) missing 1 required positional argument: 'func'$", (*) => root.register())
            AhkTest.RaisesMatch(TypeError, "^Misc\._register\(\) takes from 2 to 4 positional arguments but 5 were given$", (*) => root.register(callback, stdlib.None, 1, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.deletecommand\(\) missing 1 required positional argument: 'name'$", (*) => root.deletecommand())
            AhkTest.RaisesMatch(TypeError, "^Misc\.deletecommand\(\) takes 2 positional arguments but 3 were given$", (*) => label.deletecommand("x", "y"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^can't delete Tcl command$", (*) => label.deletecommand("missingCommand"))
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

            AhkTest.AssertTrue(root is stdlib.tkinter.Tk)
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

    static TestTkSendSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            label := stdlib.tkinter.Label(root, { name: "send_label", text: "send" })
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            AhkTest.AssertTrue(HasMethod(root, "send"))
            AhkTest.AssertTrue(HasMethod(label, "send"))
            AhkTest.AssertEqual("", root.eval("info commands send"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.send\(\) missing 2 required positional arguments: 'interp' and 'cmd'$", (*) => root.send())
            AhkTest.RaisesMatch(TypeError, "^Misc\.send\(\) missing 1 required positional argument: 'cmd'$", (*) => label.send("remote"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^invalid command name "send"$', (*) => root.send("tk", "expr", "2+3"))

            root.eval("proc send {interp cmd args} {return `"$interp|$cmd|$args`"}")
            AhkTest.AssertEqual("remote|expr|2+3", root.send("remote", "expr", "2+3"))
            AhkTest.AssertEqual("remote name|cmd name|{a b} c", label.send("remote name", "cmd name", "a b", "c"))
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

    static TestTkWmGeometryAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertTrue(HasMethod(root, "wm_geometry"))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("", root.wm_geometry("240x120+20+30"))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("240x120+20+30", root.geometry())
            AhkTest.AssertEqual("240x120+20+30", root.wm_geometry())
            AhkTest.AssertEqual("240x120+20+30", root.geometry(stdlib.None))
            AhkTest.AssertEqual("240x120+20+30", root.wm_geometry(stdlib.None))

            top := stdlib.tkinter.Toplevel(root, { name: "geometry_alias" })
            AhkTest.AssertTrue(HasMethod(top, "wm_geometry"))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("", top.wm_geometry("180x90+30+40"))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("180x90+30+40", top.geometry())
            AhkTest.AssertEqual("180x90+30+40", top.wm_geometry())
            AhkTest.AssertEqual("180x90+30+40", top.geometry(stdlib.None))
            AhkTest.AssertEqual("180x90+30+40", top.wm_geometry(stdlib.None))

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_geometry\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.wm_geometry("1x1", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_geometry\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.wm_geometry("1x1", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad geometry specifier "bad"$', (*) => root.wm_geometry("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad geometry specifier "bad"$', (*) => top.wm_geometry("bad"))
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
            AhkTest.AssertTrue(HasMethod(label, "update"))
            AhkTest.AssertTrue(HasMethod(label, "update_idletasks"))
            AhkTest.AssertEqual(stdlib.None, label.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, label.update())

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
            AhkTest.RaisesMatch(TypeError, "^Misc\.update\(\) takes 1 positional argument but 2 were given$", (*) => label.update(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.update_idletasks\(\) takes 1 positional argument but 2 were given$", (*) => label.update_idletasks(1))
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

    static TestTkGrabGlobalModalStateMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.geometry("180x80+40+40"))
            button := stdlib.tkinter.Button(root, { name: "global_grab_button", text: "Grab" })
            AhkTest.AssertEqual(stdlib.None, button.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertTrue(HasMethod(root, "grab_set_global"))
            AhkTest.AssertTrue(HasMethod(button, "grab_set_global"))
            AhkTest.AssertEqual(stdlib.None, root.grab_current())
            AhkTest.AssertEqual(stdlib.None, root.grab_set_global())
            AhkTest.AssertSame(root, root.grab_current())
            AhkTest.AssertSame(root, button.grab_current())
            AhkTest.AssertEqual("global", root.grab_status())
            AhkTest.AssertEqual(stdlib.None, button.grab_status())
            AhkTest.AssertEqual(stdlib.None, root.grab_release())
            AhkTest.AssertEqual(stdlib.None, root.grab_current())

            AhkTest.AssertEqual(stdlib.None, button.grab_set_global())
            AhkTest.AssertSame(button, root.grab_current())
            AhkTest.AssertSame(button, button.grab_current())
            AhkTest.AssertEqual("global", button.grab_status())
            AhkTest.AssertEqual(stdlib.None, root.grab_status())
            AhkTest.AssertEqual(stdlib.None, button.grab_release())
            AhkTest.AssertEqual(stdlib.None, root.grab_current())

            AhkTest.RaisesMatch(TypeError, "^Misc\.grab_set_global\(\) takes 1 positional argument but 2 were given$", (*) => root.grab_set_global(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.grab_set_global\(\) takes 1 positional argument but 2 were given$", (*) => button.grab_set_global(1))
        } finally {
            try button.grab_release()
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

    static TestTkWidgetVariableAccessMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            label := stdlib.tkinter.Label(root, { name: "var_label" })
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            AhkTest.AssertTrue(HasMethod(label, "setvar"))
            AhkTest.AssertTrue(HasMethod(label, "getvar"))
            AhkTest.AssertEqual(stdlib.None, root.setvar("root_var", "alpha"))
            AhkTest.AssertEqual("alpha", label.getvar("root_var"))
            AhkTest.AssertEqual(stdlib.None, label.setvar("widget_var", "beta"))
            AhkTest.AssertEqual("beta", root.getvar("widget_var"))
            AhkTest.AssertEqual(stdlib.None, label.setvar("none_value", stdlib.None))
            AhkTest.AssertEqual("None", root.getvar("none_value"))
            AhkTest.AssertEqual(stdlib.None, label.setvar())
            AhkTest.AssertEqual("1", root.getvar())
            AhkTest.AssertEqual("1", label.getvar())
            AhkTest.AssertEqual(stdlib.None, label.setvar("delta"))
            AhkTest.AssertEqual("1", root.getvar("delta"))
            AhkTest.AssertEqual("1", label.getvar("delta"))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^can't read " Chr(34) "missing_widget_var" Chr(34) ": no such variable$", (*) => label.getvar("missing_widget_var"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.setvar\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => label.setvar("x", "y", "z"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.getvar\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => label.getvar("x", "y"))
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
                AhkTest.AssertTrue(widget.winfo_pointerx() is Integer)
                AhkTest.AssertTrue(widget.winfo_pointery() is Integer)
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
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_pointerx\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_pointerx(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.winfo_pointery\(\) takes 1 positional argument but 2 were given$", (*) => root.winfo_pointery(1))
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

    static TestTkWmResizableAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "resizable_alias" })
            AhkTest.AssertEqual("", top.withdraw())

            AhkTest.AssertTrue(HasMethod(root, "wm_resizable"))
            AhkTest.AssertTrue(HasMethod(top, "wm_resizable"))
            AhkTest.AssertEqual(stdlib.tuple([1, 1]), root.wm_resizable())
            AhkTest.AssertEqual("", root.wm_resizable(stdlib.False, stdlib.True))
            AhkTest.AssertEqual(stdlib.tuple([0, 1]), root.resizable())
            AhkTest.AssertEqual(stdlib.tuple([0, 1]), root.wm_resizable(stdlib.None, stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple([0, 1]), root.wm_resizable(stdlib.None, stdlib.True))
            AhkTest.AssertEqual(stdlib.tuple([0, 1]), root.wm_resizable())

            AhkTest.AssertEqual(stdlib.tuple([1, 1]), top.wm_resizable())
            AhkTest.AssertEqual("", top.wm_resizable(0, 0))
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), top.resizable())
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), top.wm_resizable(stdlib.None, stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), top.wm_resizable(stdlib.None, stdlib.True))
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), top.wm_resizable())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm resizable window \?width height\?"$', (*) => root.wm_resizable(stdlib.False))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm resizable window \?width height\?"$', (*) => top.wm_resizable(stdlib.False))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_resizable\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => root.wm_resizable(stdlib.True, stdlib.True, stdlib.True))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_resizable\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => top.wm_resizable(stdlib.True, stdlib.True, stdlib.True))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected boolean value but got "maybe"$', (*) => root.wm_resizable("maybe", stdlib.True))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm resizable window \?width height\?"$', (*) => top.wm_resizable(stdlib.True, stdlib.None))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmMinsizeAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "minsize_alias" })
            AhkTest.AssertEqual("", top.withdraw())

            AhkTest.AssertTrue(HasMethod(root, "wm_minsize"))
            AhkTest.AssertTrue(HasMethod(top, "wm_minsize"))
            AhkTest.AssertEqual(stdlib.tuple([1, 1]), root.wm_minsize())
            AhkTest.AssertEqual(stdlib.None, root.wm_minsize(120, 80))
            AhkTest.AssertEqual(stdlib.tuple([120, 80]), root.minsize())
            AhkTest.AssertEqual(stdlib.None, root.wm_minsize(stdlib.True, stdlib.False))
            AhkTest.AssertEqual(stdlib.tuple([1, 0]), root.wm_minsize())
            AhkTest.AssertEqual(stdlib.tuple([1, 0]), root.wm_minsize(stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple([1, 0]), root.wm_minsize(stdlib.None, stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple([1, 0]), root.wm_minsize(stdlib.None, 1))

            AhkTest.AssertEqual(stdlib.tuple([1, 1]), top.wm_minsize())
            AhkTest.AssertEqual(stdlib.None, top.wm_minsize(90, 60))
            AhkTest.AssertEqual(stdlib.tuple([90, 60]), top.minsize())
            AhkTest.AssertEqual(stdlib.None, top.wm_minsize(0, 0))
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), top.wm_minsize())
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), top.wm_minsize(stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), top.wm_minsize(stdlib.None, stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple([0, 0]), top.wm_minsize(stdlib.None, 1))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm minsize window \?width height\?"$', (*) => root.wm_minsize(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm minsize window \?width height\?"$', (*) => top.wm_minsize(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm minsize window \?width height\?"$', (*) => root.wm_minsize(1, stdlib.None))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_minsize\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => root.wm_minsize(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_minsize\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => top.wm_minsize(1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => root.wm_minsize("bad", 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => top.wm_minsize(2, "bad"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmMaxsizeAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "maxsize_alias" })
            AhkTest.AssertEqual("", top.withdraw())

            AhkTest.AssertTrue(HasMethod(root, "wm_maxsize"))
            AhkTest.AssertTrue(HasMethod(top, "wm_maxsize"))
            initialRootMaxsize := root.maxsize()
            initialTopMaxsize := top.maxsize()
            AhkTest.AssertEqual(initialRootMaxsize, root.wm_maxsize())
            AhkTest.AssertEqual(stdlib.None, root.wm_maxsize(500, 400))
            AhkTest.AssertEqual(stdlib.tuple([500, 400]), root.maxsize())
            AhkTest.AssertEqual(stdlib.None, root.wm_maxsize(stdlib.True, stdlib.False))
            rootBoolMaxsize := root.wm_maxsize()
            AhkTest.AssertEqual(1, rootBoolMaxsize[1])
            AhkTest.AssertEqual(initialRootMaxsize[2], rootBoolMaxsize[2])
            AhkTest.AssertEqual(rootBoolMaxsize, root.wm_maxsize(stdlib.None))
            AhkTest.AssertEqual(rootBoolMaxsize, root.wm_maxsize(stdlib.None, stdlib.None))
            AhkTest.AssertEqual(rootBoolMaxsize, root.wm_maxsize(stdlib.None, 1))

            AhkTest.AssertEqual(initialTopMaxsize, top.wm_maxsize())
            AhkTest.AssertEqual(stdlib.None, top.wm_maxsize(300, 200))
            AhkTest.AssertEqual(stdlib.tuple([300, 200]), top.maxsize())
            AhkTest.AssertEqual(stdlib.None, top.wm_maxsize(stdlib.True, stdlib.False))
            topBoolMaxsize := top.wm_maxsize()
            AhkTest.AssertEqual(1, topBoolMaxsize[1])
            AhkTest.AssertEqual(initialTopMaxsize[2], topBoolMaxsize[2])
            AhkTest.AssertEqual(topBoolMaxsize, top.wm_maxsize(stdlib.None))
            AhkTest.AssertEqual(topBoolMaxsize, top.wm_maxsize(stdlib.None, stdlib.None))
            AhkTest.AssertEqual(topBoolMaxsize, top.wm_maxsize(stdlib.None, 1))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm maxsize window \?width height\?"$', (*) => root.wm_maxsize(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm maxsize window \?width height\?"$', (*) => top.wm_maxsize(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm maxsize window \?width height\?"$', (*) => root.wm_maxsize(1, stdlib.None))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_maxsize\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => root.wm_maxsize(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_maxsize\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => top.wm_maxsize(1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => root.wm_maxsize("bad", 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => top.wm_maxsize(2, "bad"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmStateAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "state_alias" })
            AhkTest.AssertEqual("", top.withdraw())

            AhkTest.AssertTrue(HasMethod(root, "wm_state"))
            AhkTest.AssertTrue(HasMethod(top, "wm_state"))
            AhkTest.AssertEqual("withdrawn", root.wm_state())
            AhkTest.AssertEqual("withdrawn", root.wm_state(stdlib.None))
            AhkTest.AssertEqual("", root.wm_state("normal"))
            AhkTest.AssertEqual("normal", root.wm_state())
            AhkTest.AssertEqual("", root.wm_state("withdrawn"))
            AhkTest.AssertEqual("withdrawn", root.state())
            AhkTest.AssertEqual("withdrawn", root.wm_state(stdlib.None))

            AhkTest.AssertEqual("withdrawn", top.wm_state())
            AhkTest.AssertEqual("withdrawn", top.wm_state(stdlib.None))
            AhkTest.AssertEqual("", top.wm_state("normal"))
            AhkTest.AssertEqual("normal", top.wm_state())
            AhkTest.AssertEqual("", top.wm_state("withdrawn"))
            AhkTest.AssertEqual("withdrawn", top.state())
            AhkTest.AssertEqual("withdrawn", top.wm_state(stdlib.None))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad argument "bad": must be normal, iconic, withdrawn, or zoomed$', (*) => root.wm_state("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad argument "bad": must be normal, iconic, withdrawn, or zoomed$', (*) => top.wm_state("bad"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_state\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.wm_state("normal", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_state\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.wm_state("normal", "extra"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmWithdrawAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            top := stdlib.tkinter.Toplevel(root, { name: "withdraw_alias" })

            AhkTest.AssertTrue(HasMethod(root, "wm_withdraw"))
            AhkTest.AssertTrue(HasMethod(top, "wm_withdraw"))
            AhkTest.AssertEqual("normal", root.state())
            AhkTest.AssertEqual("", root.wm_withdraw())
            AhkTest.AssertEqual("withdrawn", root.state())
            AhkTest.AssertEqual("", root.deiconify())
            AhkTest.AssertEqual("normal", root.state())

            AhkTest.AssertEqual("normal", top.state())
            AhkTest.AssertEqual("", top.wm_withdraw())
            AhkTest.AssertEqual("withdrawn", top.state())
            AhkTest.AssertEqual("", top.deiconify())
            AhkTest.AssertEqual("normal", top.state())

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_withdraw\(\) takes 1 positional argument but 2 were given$", (*) => root.wm_withdraw(1))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_withdraw\(\) takes 1 positional argument but 2 were given$", (*) => top.wm_withdraw(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmDeiconifyAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            top := stdlib.tkinter.Toplevel(root, { name: "deiconify_alias" })

            AhkTest.AssertTrue(HasMethod(root, "wm_deiconify"))
            AhkTest.AssertTrue(HasMethod(top, "wm_deiconify"))
            AhkTest.AssertEqual("normal", root.state())
            AhkTest.AssertEqual("", root.withdraw())
            AhkTest.AssertEqual("withdrawn", root.state())
            AhkTest.AssertEqual("", root.wm_deiconify())
            AhkTest.AssertEqual("normal", root.state())

            AhkTest.AssertEqual("normal", top.state())
            AhkTest.AssertEqual("", top.withdraw())
            AhkTest.AssertEqual("withdrawn", top.state())
            AhkTest.AssertEqual("", top.wm_deiconify())
            AhkTest.AssertEqual("normal", top.state())

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_deiconify\(\) takes 1 positional argument but 2 were given$", (*) => root.wm_deiconify(1))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_deiconify\(\) takes 1 positional argument but 2 were given$", (*) => top.wm_deiconify(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmIconifyAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertTrue(HasMethod(root, "wm_iconify"))
            AhkTest.AssertEqual("normal", root.state())
            AhkTest.AssertEqual("", root.wm_iconify())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("iconic", root.state())
            AhkTest.AssertEqual(0, root.winfo_viewable())
            AhkTest.AssertEqual(0, root.winfo_ismapped())
            AhkTest.AssertEqual("", root.deiconify())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("normal", root.state())
            AhkTest.AssertEqual("", root.withdraw())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("withdrawn", root.state())
            AhkTest.AssertEqual("", root.wm_iconify())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("iconic", root.state())
            AhkTest.AssertEqual("", root.deiconify())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("normal", root.state())

            top := stdlib.tkinter.Toplevel(root, { name: "iconify_alias" })
            AhkTest.AssertTrue(HasMethod(top, "wm_iconify"))
            AhkTest.AssertEqual("normal", top.state())
            AhkTest.AssertEqual("", top.wm_iconify())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("iconic", top.state())
            AhkTest.AssertEqual("", top.deiconify())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("normal", top.state())

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_iconify\(\) takes 1 positional argument but 2 were given$", (*) => root.wm_iconify(1))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_iconify\(\) takes 1 positional argument but 2 were given$", (*) => top.wm_iconify(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmFrameAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            top := stdlib.tkinter.Toplevel(root, { name: "frame_alias" })
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertTrue(HasMethod(root, "frame"))
            AhkTest.AssertTrue(HasMethod(root, "wm_frame"))
            rootFrame := root.frame()
            AhkTest.AssertEqual("String", Type(rootFrame))
            AhkTest.AssertTrue(StrLen(rootFrame) > 0)
            AhkTest.AssertEqual(rootFrame, root.wm_frame())

            AhkTest.AssertTrue(HasMethod(top, "frame"))
            AhkTest.AssertTrue(HasMethod(top, "wm_frame"))
            topFrame := top.frame()
            AhkTest.AssertEqual("String", Type(topFrame))
            AhkTest.AssertTrue(StrLen(topFrame) > 0)
            AhkTest.AssertEqual(topFrame, top.wm_frame())

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_frame\(\) takes 1 positional argument but 2 were given$", (*) => root.frame(1))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_frame\(\) takes 1 positional argument but 2 were given$", (*) => root.wm_frame(1))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_frame\(\) takes 1 positional argument but 2 were given$", (*) => top.frame(1))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_frame\(\) takes 1 positional argument but 2 were given$", (*) => top.wm_frame(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmFocusmodelAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            top := stdlib.tkinter.Toplevel(root, { name: "focusmodel_alias" })

            AhkTest.AssertTrue(HasMethod(root, "focusmodel"))
            AhkTest.AssertTrue(HasMethod(root, "wm_focusmodel"))
            AhkTest.AssertEqual("passive", root.focusmodel())
            AhkTest.AssertEqual("passive", root.wm_focusmodel())
            AhkTest.AssertEqual("passive", root.focusmodel(stdlib.None))
            AhkTest.AssertEqual("", root.focusmodel("active"))
            AhkTest.AssertEqual("active", root.focusmodel())
            AhkTest.AssertEqual("active", root.wm_focusmodel(stdlib.None))
            AhkTest.AssertEqual("", root.wm_focusmodel("passive"))
            AhkTest.AssertEqual("passive", root.focusmodel())

            AhkTest.AssertTrue(HasMethod(top, "focusmodel"))
            AhkTest.AssertTrue(HasMethod(top, "wm_focusmodel"))
            AhkTest.AssertEqual("passive", top.focusmodel())
            AhkTest.AssertEqual("passive", top.wm_focusmodel())
            AhkTest.AssertEqual("passive", top.focusmodel(stdlib.None))
            AhkTest.AssertEqual("", top.focusmodel("active"))
            AhkTest.AssertEqual("active", top.focusmodel())
            AhkTest.AssertEqual("active", top.wm_focusmodel(stdlib.None))
            AhkTest.AssertEqual("", top.wm_focusmodel("passive"))
            AhkTest.AssertEqual("passive", top.focusmodel())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad argument "bad": must be active or passive$', (*) => root.focusmodel("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad argument "bad": must be active or passive$', (*) => top.focusmodel("bad"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_focusmodel\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.focusmodel("active", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_focusmodel\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.wm_focusmodel("active", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_focusmodel\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.focusmodel("active", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_focusmodel\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.wm_focusmodel("active", "extra"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmPositionfromAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            top := stdlib.tkinter.Toplevel(root, { name: "positionfrom_alias" })

            AhkTest.AssertTrue(HasMethod(root, "positionfrom"))
            AhkTest.AssertTrue(HasMethod(root, "wm_positionfrom"))
            AhkTest.AssertEqual("", root.positionfrom())
            AhkTest.AssertEqual("", root.wm_positionfrom())
            AhkTest.AssertEqual("", root.positionfrom(stdlib.None))
            AhkTest.AssertEqual("", root.positionfrom("user"))
            AhkTest.AssertEqual("user", root.positionfrom())
            AhkTest.AssertEqual("user", root.wm_positionfrom(stdlib.None))
            AhkTest.AssertEqual("", root.wm_positionfrom("program"))
            AhkTest.AssertEqual("program", root.positionfrom())
            AhkTest.AssertEqual("", root.positionfrom(""))
            AhkTest.AssertEqual("", root.wm_positionfrom())

            AhkTest.AssertTrue(HasMethod(top, "positionfrom"))
            AhkTest.AssertTrue(HasMethod(top, "wm_positionfrom"))
            AhkTest.AssertEqual("", top.positionfrom())
            AhkTest.AssertEqual("", top.wm_positionfrom())
            AhkTest.AssertEqual("", top.positionfrom(stdlib.None))
            AhkTest.AssertEqual("", top.positionfrom("user"))
            AhkTest.AssertEqual("user", top.positionfrom())
            AhkTest.AssertEqual("user", top.wm_positionfrom(stdlib.None))
            AhkTest.AssertEqual("", top.wm_positionfrom("program"))
            AhkTest.AssertEqual("program", top.positionfrom())
            AhkTest.AssertEqual("", top.positionfrom(""))
            AhkTest.AssertEqual("", top.wm_positionfrom())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad argument "bad": must be program or user$', (*) => root.positionfrom("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad argument "bad": must be program or user$', (*) => top.positionfrom("bad"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_positionfrom\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.positionfrom("user", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_positionfrom\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.wm_positionfrom("user", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_positionfrom\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.positionfrom("user", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_positionfrom\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.wm_positionfrom("user", "extra"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmSizefromAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            top := stdlib.tkinter.Toplevel(root, { name: "sizefrom_alias" })

            AhkTest.AssertTrue(HasMethod(root, "sizefrom"))
            AhkTest.AssertTrue(HasMethod(root, "wm_sizefrom"))
            AhkTest.AssertEqual("", root.sizefrom())
            AhkTest.AssertEqual("", root.wm_sizefrom())
            AhkTest.AssertEqual("", root.sizefrom(stdlib.None))
            AhkTest.AssertEqual("", root.sizefrom("user"))
            AhkTest.AssertEqual("user", root.sizefrom())
            AhkTest.AssertEqual("user", root.wm_sizefrom(stdlib.None))
            AhkTest.AssertEqual("", root.wm_sizefrom("program"))
            AhkTest.AssertEqual("program", root.sizefrom())
            AhkTest.AssertEqual("", root.sizefrom(""))
            AhkTest.AssertEqual("", root.wm_sizefrom())

            AhkTest.AssertTrue(HasMethod(top, "sizefrom"))
            AhkTest.AssertTrue(HasMethod(top, "wm_sizefrom"))
            AhkTest.AssertEqual("", top.sizefrom())
            AhkTest.AssertEqual("", top.wm_sizefrom())
            AhkTest.AssertEqual("", top.sizefrom(stdlib.None))
            AhkTest.AssertEqual("", top.sizefrom("user"))
            AhkTest.AssertEqual("user", top.sizefrom())
            AhkTest.AssertEqual("user", top.wm_sizefrom(stdlib.None))
            AhkTest.AssertEqual("", top.wm_sizefrom("program"))
            AhkTest.AssertEqual("program", top.sizefrom())
            AhkTest.AssertEqual("", top.sizefrom(""))
            AhkTest.AssertEqual("", top.wm_sizefrom())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad argument "bad": must be program or user$', (*) => root.sizefrom("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad argument "bad": must be program or user$', (*) => top.sizefrom("bad"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_sizefrom\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.sizefrom("user", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_sizefrom\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.wm_sizefrom("user", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_sizefrom\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.sizefrom("user", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_sizefrom\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.wm_sizefrom("user", "extra"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmIconnameAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            top := stdlib.tkinter.Toplevel(root, { name: "iconname_alias" })

            AhkTest.AssertTrue(HasMethod(root, "iconname"))
            AhkTest.AssertTrue(HasMethod(root, "wm_iconname"))
            AhkTest.AssertEqual("", root.iconname())
            AhkTest.AssertEqual("", root.wm_iconname())
            AhkTest.AssertEqual("", root.iconname(stdlib.None))
            AhkTest.AssertEqual("", root.iconname("Alpha Icon"))
            AhkTest.AssertEqual("Alpha Icon", root.iconname())
            AhkTest.AssertEqual("Alpha Icon", root.wm_iconname(stdlib.None))
            AhkTest.AssertEqual("", root.wm_iconname("Icon 2"))
            AhkTest.AssertEqual("Icon 2", root.iconname())
            AhkTest.AssertEqual("", root.iconname(""))
            AhkTest.AssertEqual("", root.wm_iconname())

            AhkTest.AssertTrue(HasMethod(top, "iconname"))
            AhkTest.AssertTrue(HasMethod(top, "wm_iconname"))
            AhkTest.AssertEqual("", top.iconname())
            AhkTest.AssertEqual("", top.wm_iconname())
            AhkTest.AssertEqual("", top.iconname(stdlib.None))
            AhkTest.AssertEqual("", top.iconname("Alpha Icon"))
            AhkTest.AssertEqual("Alpha Icon", top.iconname())
            AhkTest.AssertEqual("Alpha Icon", top.wm_iconname(stdlib.None))
            AhkTest.AssertEqual("", top.wm_iconname("Icon 2"))
            AhkTest.AssertEqual("Icon 2", top.iconname())
            AhkTest.AssertEqual("", top.iconname(""))
            AhkTest.AssertEqual("", top.wm_iconname())

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_iconname\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.iconname("one", "two"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_iconname\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.wm_iconname("one", "two"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_iconname\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.iconname("one", "two"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_iconname\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.wm_iconname("one", "two"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmClientAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            top := stdlib.tkinter.Toplevel(root, { name: "client_alias" })

            AhkTest.AssertTrue(HasMethod(root, "client"))
            AhkTest.AssertTrue(HasMethod(root, "wm_client"))
            AhkTest.AssertEqual("", root.client())
            AhkTest.AssertEqual("", root.wm_client())
            AhkTest.AssertEqual("", root.client(stdlib.None))
            AhkTest.AssertEqual("", root.client("client-alpha"))
            AhkTest.AssertEqual("client-alpha", root.client())
            AhkTest.AssertEqual("client-alpha", root.wm_client(stdlib.None))
            AhkTest.AssertEqual("", root.wm_client("client beta"))
            AhkTest.AssertEqual("client beta", root.client())
            AhkTest.AssertEqual("", root.client(""))
            AhkTest.AssertEqual("", root.wm_client())

            AhkTest.AssertTrue(HasMethod(top, "client"))
            AhkTest.AssertTrue(HasMethod(top, "wm_client"))
            AhkTest.AssertEqual("", top.client())
            AhkTest.AssertEqual("", top.wm_client())
            AhkTest.AssertEqual("", top.client(stdlib.None))
            AhkTest.AssertEqual("", top.client("client-alpha"))
            AhkTest.AssertEqual("client-alpha", top.client())
            AhkTest.AssertEqual("client-alpha", top.wm_client(stdlib.None))
            AhkTest.AssertEqual("", top.wm_client("client beta"))
            AhkTest.AssertEqual("client beta", top.client())
            AhkTest.AssertEqual("", top.client(""))
            AhkTest.AssertEqual("", top.wm_client())

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_client\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.client("one", "two"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_client\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.wm_client("one", "two"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_client\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.client("one", "two"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_client\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.wm_client("one", "two"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmAspectAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "aspect_alias" })
            AhkTest.AssertEqual("", top.withdraw())

            AhkTest.AssertTrue(HasMethod(root, "aspect"))
            AhkTest.AssertTrue(HasMethod(root, "wm_aspect"))
            AhkTest.AssertEqual(stdlib.None, root.aspect())
            AhkTest.AssertEqual(stdlib.None, root.wm_aspect())
            AhkTest.AssertEqual(stdlib.None, root.aspect(stdlib.None))
            AhkTest.AssertEqual(stdlib.None, root.wm_aspect(1, 2, 3, 4))
            AhkTest.AssertEqual(stdlib.tuple([1, 2, 3, 4]), root.aspect())
            AhkTest.AssertEqual(stdlib.tuple([1, 2, 3, 4]), root.wm_aspect(stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple([1, 2, 3, 4]), root.aspect(stdlib.None, 2, 3, 4))
            AhkTest.AssertEqual(stdlib.None, root.aspect("", "", "", ""))
            AhkTest.AssertEqual(stdlib.None, root.wm_aspect())

            AhkTest.AssertTrue(HasMethod(top, "aspect"))
            AhkTest.AssertTrue(HasMethod(top, "wm_aspect"))
            AhkTest.AssertEqual(stdlib.None, top.aspect())
            AhkTest.AssertEqual(stdlib.None, top.wm_aspect())
            AhkTest.AssertEqual(stdlib.None, top.aspect(stdlib.None))
            AhkTest.AssertEqual(stdlib.None, top.wm_aspect(5, 6, 7, 8))
            AhkTest.AssertEqual(stdlib.tuple([5, 6, 7, 8]), top.aspect())
            AhkTest.AssertEqual(stdlib.tuple([5, 6, 7, 8]), top.wm_aspect(stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple([5, 6, 7, 8]), top.aspect(stdlib.None, 6, 7, 8))
            AhkTest.AssertEqual(stdlib.None, top.aspect("", "", "", ""))
            AhkTest.AssertEqual(stdlib.None, top.wm_aspect())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm aspect window \?minNumer minDenom maxNumer maxDenom\?"$', (*) => root.aspect(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm aspect window \?minNumer minDenom maxNumer maxDenom\?"$', (*) => root.wm_aspect(1, 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm aspect window \?minNumer minDenom maxNumer maxDenom\?"$', (*) => root.aspect(1, stdlib.None, 3, 4))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => root.wm_aspect("bad", 2, 3, 4))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_aspect\(\) takes from 1 to 5 positional arguments but 6 were given$", (*) => root.aspect(1, 2, 3, 4, 5))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_aspect\(\) takes from 1 to 5 positional arguments but 6 were given$", (*) => top.wm_aspect(1, 2, 3, 4, 5))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmGridAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "grid_alias" })
            AhkTest.AssertEqual("", top.withdraw())

            AhkTest.AssertTrue(HasMethod(root, "grid"))
            AhkTest.AssertTrue(HasMethod(root, "wm_grid"))
            AhkTest.AssertEqual(stdlib.None, root.grid())
            AhkTest.AssertEqual(stdlib.None, root.wm_grid())
            AhkTest.AssertEqual(stdlib.None, root.grid(stdlib.None))
            AhkTest.AssertEqual(stdlib.None, root.wm_grid(10, 20, 3, 4))
            AhkTest.AssertEqual(stdlib.tuple([10, 20, 3, 4]), root.grid())
            AhkTest.AssertEqual(stdlib.tuple([10, 20, 3, 4]), root.wm_grid(stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple([10, 20, 3, 4]), root.grid(stdlib.None, 20, 3, 4))
            AhkTest.AssertEqual(stdlib.None, root.grid("", "", "", ""))
            AhkTest.AssertEqual(stdlib.None, root.wm_grid())

            AhkTest.AssertTrue(HasMethod(top, "grid"))
            AhkTest.AssertTrue(HasMethod(top, "wm_grid"))
            AhkTest.AssertEqual(stdlib.None, top.grid())
            AhkTest.AssertEqual(stdlib.None, top.wm_grid())
            AhkTest.AssertEqual(stdlib.None, top.grid(stdlib.None))
            AhkTest.AssertEqual(stdlib.None, top.wm_grid(11, 21, 5, 6))
            AhkTest.AssertEqual(stdlib.tuple([11, 21, 5, 6]), top.grid())
            AhkTest.AssertEqual(stdlib.tuple([11, 21, 5, 6]), top.wm_grid(stdlib.None))
            AhkTest.AssertEqual(stdlib.tuple([11, 21, 5, 6]), top.grid(stdlib.None, 21, 5, 6))
            AhkTest.AssertEqual(stdlib.None, top.grid("", "", "", ""))
            AhkTest.AssertEqual(stdlib.None, top.wm_grid())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm grid window \?baseWidth baseHeight widthInc heightInc\?"$', (*) => root.grid(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm grid window \?baseWidth baseHeight widthInc heightInc\?"$', (*) => root.wm_grid(1, 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm grid window \?baseWidth baseHeight widthInc heightInc\?"$', (*) => root.grid(1, stdlib.None, 3, 4))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => root.wm_grid("bad", 2, 3, 4))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_grid\(\) takes from 1 to 5 positional arguments but 6 were given$", (*) => root.grid(1, 2, 3, 4, 5))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_grid\(\) takes from 1 to 5 positional arguments but 6 were given$", (*) => top.wm_grid(1, 2, 3, 4, 5))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmGroupAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "group_alias" })
            AhkTest.AssertEqual("", top.withdraw())
            leader := stdlib.tkinter.Toplevel(root, { name: "group_leader" })
            AhkTest.AssertEqual("", leader.withdraw())

            AhkTest.AssertTrue(HasMethod(root, "group"))
            AhkTest.AssertTrue(HasMethod(root, "wm_group"))
            AhkTest.AssertEqual("", root.group())
            AhkTest.AssertEqual("", root.wm_group())
            AhkTest.AssertEqual("", root.group(stdlib.None))
            AhkTest.AssertEqual("", root.group(root))
            AhkTest.AssertEqual(".", root.group())
            AhkTest.AssertEqual(".", root.wm_group(stdlib.None))
            AhkTest.AssertEqual("", root.wm_group(leader))
            AhkTest.AssertEqual(".group_leader", root.wm_group())
            AhkTest.AssertEqual("", root.group(String(root)))
            AhkTest.AssertEqual(".", root.group())
            AhkTest.AssertEqual("", root.group(""))
            AhkTest.AssertEqual("", root.wm_group())

            AhkTest.AssertTrue(HasMethod(top, "group"))
            AhkTest.AssertTrue(HasMethod(top, "wm_group"))
            AhkTest.AssertEqual("", top.group())
            AhkTest.AssertEqual("", top.wm_group())
            AhkTest.AssertEqual("", top.group(stdlib.None))
            AhkTest.AssertEqual("", top.group(root))
            AhkTest.AssertEqual(".", top.group())
            AhkTest.AssertEqual(".", top.wm_group(stdlib.None))
            AhkTest.AssertEqual("", top.wm_group(leader))
            AhkTest.AssertEqual(".group_leader", top.wm_group())
            AhkTest.AssertEqual("", top.group(String(root)))
            AhkTest.AssertEqual(".", top.group())
            AhkTest.AssertEqual("", top.group(""))
            AhkTest.AssertEqual("", top.wm_group())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.missing"$', (*) => top.group(".missing"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_group\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.group(root, leader))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_group\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.wm_group(root, leader))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmCommandAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "command_alias" })
            AhkTest.AssertEqual("", top.withdraw())

            AhkTest.AssertTrue(HasMethod(root, "command"))
            AhkTest.AssertTrue(HasMethod(root, "wm_command"))
            AhkTest.AssertEqual("", root.command())
            AhkTest.AssertEqual("", root.wm_command())
            AhkTest.AssertEqual("", root.command(stdlib.None))
            AhkTest.AssertEqual("", root.command("alpha beta"))
            AhkTest.AssertEqual("alpha beta", root.command())
            AhkTest.AssertEqual("alpha beta", root.wm_command(stdlib.None))
            AhkTest.AssertEqual("", root.wm_command(["cmd", "arg one"]))
            AhkTest.AssertEqual("cmd {arg one}", root.wm_command())
            AhkTest.AssertEqual("", root.command(["listcmd", "two words"]))
            AhkTest.AssertEqual("listcmd {two words}", root.command())
            AhkTest.AssertEqual("", root.command(""))
            AhkTest.AssertEqual("", root.wm_command())

            AhkTest.AssertTrue(HasMethod(top, "command"))
            AhkTest.AssertTrue(HasMethod(top, "wm_command"))
            AhkTest.AssertEqual("", top.command())
            AhkTest.AssertEqual("", top.wm_command())
            AhkTest.AssertEqual("", top.command(stdlib.None))
            AhkTest.AssertEqual("", top.command("alpha beta"))
            AhkTest.AssertEqual("alpha beta", top.command())
            AhkTest.AssertEqual("alpha beta", top.wm_command(stdlib.None))
            AhkTest.AssertEqual("", top.wm_command(["cmd", "arg one"]))
            AhkTest.AssertEqual("cmd {arg one}", top.wm_command())
            AhkTest.AssertEqual("", top.command(["listcmd", "two words"]))
            AhkTest.AssertEqual("listcmd {two words}", top.command())
            AhkTest.AssertEqual("", top.command(""))
            AhkTest.AssertEqual("", top.wm_command())

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_command\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.command("one", "two"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_command\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.wm_command("one", "two"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmColormapwindowsAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "cmap_alias" })
            AhkTest.AssertEqual("", top.withdraw())
            child := stdlib.tkinter.Toplevel(root, { name: "cmap_child" })
            AhkTest.AssertEqual("", child.withdraw())

            AhkTest.AssertTrue(HasMethod(root, "colormapwindows"))
            AhkTest.AssertTrue(HasMethod(root, "wm_colormapwindows"))
            AhkTest.AssertEqual([], root.colormapwindows())
            AhkTest.AssertEqual([], root.wm_colormapwindows())
            AhkTest.AssertEqual(stdlib.None, root.colormapwindows(top))
            rootAfterTop := root.colormapwindows()
            AhkTest.AssertEqual(1, rootAfterTop.Length)
            AhkTest.AssertSame(top, rootAfterTop[1])
            AhkTest.AssertEqual(stdlib.None, root.wm_colormapwindows(top, child))
            rootAfterTwo := root.wm_colormapwindows()
            AhkTest.AssertEqual(2, rootAfterTwo.Length)
            AhkTest.AssertSame(top, rootAfterTwo[1])
            AhkTest.AssertSame(child, rootAfterTwo[2])
            AhkTest.AssertEqual(stdlib.None, root.colormapwindows(""))
            AhkTest.AssertEqual([], root.colormapwindows())
            AhkTest.AssertEqual(stdlib.None, root.wm_colormapwindows(stdlib.None))
            AhkTest.AssertEqual([], root.wm_colormapwindows())
            AhkTest.AssertEqual(stdlib.None, root.colormapwindows(String(top)))
            rootAfterString := root.colormapwindows()
            AhkTest.AssertEqual(1, rootAfterString.Length)
            AhkTest.AssertSame(top, rootAfterString[1])
            AhkTest.AssertEqual(stdlib.None, root.wm_colormapwindows([top, child]))
            rootAfterArray := root.wm_colormapwindows()
            AhkTest.AssertEqual(2, rootAfterArray.Length)
            AhkTest.AssertSame(top, rootAfterArray[1])
            AhkTest.AssertSame(child, rootAfterArray[2])

            AhkTest.AssertTrue(HasMethod(top, "colormapwindows"))
            AhkTest.AssertTrue(HasMethod(top, "wm_colormapwindows"))
            AhkTest.AssertEqual([], top.colormapwindows())
            AhkTest.AssertEqual([], top.wm_colormapwindows())
            AhkTest.AssertEqual(stdlib.None, top.colormapwindows(root))
            topAfterRoot := top.wm_colormapwindows()
            AhkTest.AssertEqual(1, topAfterRoot.Length)
            AhkTest.AssertSame(root, topAfterRoot[1])
            AhkTest.AssertEqual(stdlib.None, top.wm_colormapwindows(""))
            AhkTest.AssertEqual([], top.colormapwindows())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.missing"$', (*) => root.colormapwindows(".missing"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "None"$', (*) => root.wm_colormapwindows("None"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmIconpositionAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "iconpos_alias" })
            AhkTest.AssertEqual("", top.withdraw())

            AhkTest.AssertTrue(HasMethod(root, "iconposition"))
            AhkTest.AssertTrue(HasMethod(root, "wm_iconposition"))
            AhkTest.AssertEqual(stdlib.None, root.iconposition())
            AhkTest.AssertEqual(stdlib.None, root.wm_iconposition())
            AhkTest.AssertEqual(stdlib.None, root.iconposition(stdlib.None, stdlib.None))
            AhkTest.AssertEqual(stdlib.None, root.iconposition(11, 22))
            AhkTest.AssertEqual(stdlib.tuple([11, 22]), root.wm_iconposition())
            AhkTest.AssertEqual(stdlib.tuple([11, 22]), root.iconposition(stdlib.None, 44))
            AhkTest.AssertEqual(stdlib.None, root.iconposition("", ""))
            AhkTest.AssertEqual(stdlib.None, root.wm_iconposition())

            AhkTest.AssertTrue(HasMethod(top, "iconposition"))
            AhkTest.AssertTrue(HasMethod(top, "wm_iconposition"))
            AhkTest.AssertEqual(stdlib.None, top.iconposition())
            AhkTest.AssertEqual(stdlib.None, top.wm_iconposition())
            AhkTest.AssertEqual(stdlib.None, top.iconposition(stdlib.None, stdlib.None))
            AhkTest.AssertEqual(stdlib.None, top.wm_iconposition(11, 22))
            AhkTest.AssertEqual(stdlib.tuple([11, 22]), top.iconposition())
            AhkTest.AssertEqual(stdlib.tuple([11, 22]), top.wm_iconposition(stdlib.None, 44))
            AhkTest.AssertEqual(stdlib.None, top.wm_iconposition("", ""))
            AhkTest.AssertEqual(stdlib.None, top.iconposition())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm iconposition window \?x y\?"$', (*) => root.iconposition(33))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => root.wm_iconposition("bad", 2))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_iconposition\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => top.wm_iconposition(1, 2, 3))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmIconwindowAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "iconwindow_alias" })
            AhkTest.AssertEqual("", top.withdraw())
            child := stdlib.tkinter.Toplevel(root, { name: "iconwindow_child" })
            AhkTest.AssertEqual("", child.withdraw())
            frame := stdlib.tkinter.Frame(root, { name: "iconwindow_frame" })

            AhkTest.AssertTrue(HasMethod(root, "iconwindow"))
            AhkTest.AssertTrue(HasMethod(root, "wm_iconwindow"))
            AhkTest.AssertEqual("", root.iconwindow())
            AhkTest.AssertEqual("", root.wm_iconwindow(stdlib.None))
            AhkTest.AssertEqual("", root.iconwindow(child))
            AhkTest.AssertEqual(".iconwindow_child", root.wm_iconwindow())
            AhkTest.AssertEqual("", root.iconwindow(""))
            AhkTest.AssertEqual("", root.wm_iconwindow())

            AhkTest.AssertTrue(HasMethod(top, "iconwindow"))
            AhkTest.AssertTrue(HasMethod(top, "wm_iconwindow"))
            AhkTest.AssertEqual("", top.iconwindow())
            AhkTest.AssertEqual("", top.wm_iconwindow(stdlib.None))
            AhkTest.AssertEqual("", top.wm_iconwindow(root))
            AhkTest.AssertEqual(".", top.iconwindow())
            AhkTest.AssertEqual("", top.iconwindow(String(child)))
            AhkTest.AssertEqual(".iconwindow_child", top.wm_iconwindow())
            AhkTest.AssertEqual("", top.wm_iconwindow(""))
            AhkTest.AssertEqual("", top.iconwindow())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^can't use \.iconwindow_frame as icon window: not at top level$", (*) => root.iconwindow(frame))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.missing_iconwindow"$', (*) => root.wm_iconwindow(".missing_iconwindow"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_iconwindow\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.iconwindow(root, child))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmIconmaskAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "iconmask_alias" })
            AhkTest.AssertEqual("", top.withdraw())

            AhkTest.AssertTrue(HasMethod(root, "iconmask"))
            AhkTest.AssertTrue(HasMethod(root, "wm_iconmask"))
            AhkTest.AssertEqual("", root.iconmask())
            AhkTest.AssertEqual("", root.wm_iconmask(stdlib.None))
            AhkTest.AssertEqual("", root.iconmask("info"))
            AhkTest.AssertEqual("info", root.wm_iconmask())
            AhkTest.AssertEqual("", root.iconmask(""))
            AhkTest.AssertEqual("", root.wm_iconmask())

            AhkTest.AssertTrue(HasMethod(top, "iconmask"))
            AhkTest.AssertTrue(HasMethod(top, "wm_iconmask"))
            AhkTest.AssertEqual("", top.iconmask())
            AhkTest.AssertEqual("", top.wm_iconmask(stdlib.None))
            AhkTest.AssertEqual("", top.wm_iconmask("question"))
            AhkTest.AssertEqual("question", top.iconmask())
            AhkTest.AssertEqual("", top.wm_iconmask(""))
            AhkTest.AssertEqual("", top.iconmask())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bitmap "not_a_bitmap" not defined$', (*) => root.iconmask("not_a_bitmap"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_iconmask\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.wm_iconmask("info", "extra"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmIconbitmapAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "iconbitmap_alias" })
            AhkTest.AssertEqual("", top.withdraw())

            AhkTest.AssertTrue(HasMethod(root, "iconbitmap"))
            AhkTest.AssertTrue(HasMethod(root, "wm_iconbitmap"))
            AhkTest.AssertEqual("", root.iconbitmap())
            AhkTest.AssertEqual("", root.wm_iconbitmap(stdlib.None))
            AhkTest.AssertEqual("", root.iconbitmap("info"))
            AhkTest.AssertEqual("info", root.wm_iconbitmap())
            AhkTest.AssertEqual("", root.iconbitmap(""))
            AhkTest.AssertEqual("", root.wm_iconbitmap())
            AhkTest.AssertEqual("", root.iconbitmap(stdlib.None, "info"))
            AhkTest.AssertEqual("info", root.wm_iconbitmap())
            AhkTest.AssertEqual("info", root.iconbitmap(stdlib.None, ""))
            AhkTest.AssertEqual("info", root.wm_iconbitmap())
            AhkTest.AssertEqual("", root.iconbitmap(""))
            AhkTest.AssertEqual("", root.wm_iconbitmap())

            AhkTest.AssertTrue(HasMethod(top, "iconbitmap"))
            AhkTest.AssertTrue(HasMethod(top, "wm_iconbitmap"))
            AhkTest.AssertEqual("", top.iconbitmap())
            AhkTest.AssertEqual("", top.wm_iconbitmap(stdlib.None))
            AhkTest.AssertEqual("", top.wm_iconbitmap("question"))
            AhkTest.AssertEqual("question", top.iconbitmap())
            AhkTest.AssertEqual("", top.wm_iconbitmap(""))
            AhkTest.AssertEqual("", top.iconbitmap())
            AhkTest.AssertEqual("", top.wm_iconbitmap("info", "question"))
            AhkTest.AssertEqual("question", top.iconbitmap())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bitmap "not_a_bitmap" not defined$', (*) => root.iconbitmap("not_a_bitmap"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bitmap "not_a_bitmap" not defined$', (*) => root.wm_iconbitmap(stdlib.None, "not_a_bitmap"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_iconbitmap\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => top.wm_iconbitmap("info", "question", "warning"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmIconphotoAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "iconphoto_alias" })
            AhkTest.AssertEqual("", top.withdraw())
            imageOne := stdlib.tkinter.PhotoImage({ master: root, name: "iconphoto_one", width: 1, height: 1 })
            imageTwo := stdlib.tkinter.PhotoImage({ master: root, name: "iconphoto_two", width: 2, height: 1 })
            AhkTest.AssertEqual(stdlib.None, imageOne.put("#ff0000", { to: [0, 0] }))
            AhkTest.AssertEqual(stdlib.None, imageTwo.put("{#00ff00 #0000ff}", { to: [0, 0, 2, 1] }))

            AhkTest.AssertTrue(HasMethod(root, "iconphoto"))
            AhkTest.AssertTrue(HasMethod(root, "wm_iconphoto"))
            AhkTest.AssertEqual(stdlib.None, root.iconphoto(stdlib.False, imageOne))
            AhkTest.AssertEqual(stdlib.None, root.iconphoto(stdlib.True, imageOne))
            AhkTest.AssertEqual(stdlib.None, root.wm_iconphoto(stdlib.False, imageOne, imageTwo))
            AhkTest.AssertEqual(stdlib.None, root.iconphoto("bad", imageOne))
            AhkTest.AssertEqual(stdlib.None, root.iconphoto(stdlib.None, imageOne))
            AhkTest.AssertEqual(stdlib.None, root.iconphoto(stdlib.False, imageOne, stdlib.None))

            AhkTest.AssertTrue(HasMethod(top, "iconphoto"))
            AhkTest.AssertTrue(HasMethod(top, "wm_iconphoto"))
            AhkTest.AssertEqual(stdlib.None, top.iconphoto(stdlib.False, imageOne))
            AhkTest.AssertEqual(stdlib.None, top.wm_iconphoto(stdlib.True, imageOne))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm iconphoto window \?-default\? image1 \?image2 \.\.\.\?"$', (*) => root.iconphoto())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm iconphoto window \?-default\? image1 \?image2 \.\.\.\?"$', (*) => root.wm_iconphoto(stdlib.False))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm iconphoto window \?-default\? image1 \?image2 \.\.\.\?"$', (*) => root.iconphoto(stdlib.False, stdlib.None, imageOne))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^can't use " Chr(34) "not_image" Chr(34) " as iconphoto: not a photo image$", (*) => root.iconphoto(stdlib.False, "not_image"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^can't use " Chr(34) "123" Chr(34) " as iconphoto: not a photo image$", (*) => root.iconphoto(stdlib.False, 123))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmManageForgetAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "wm_manage_alias" })
            AhkTest.AssertEqual("", top.withdraw())
            frame := stdlib.tkinter.Frame(root, { name: "wm_manage_frame" })
            topFrame := stdlib.tkinter.Frame(root, { name: "wm_manage_top_frame" })

            AhkTest.AssertTrue(HasMethod(root, "manage"))
            AhkTest.AssertTrue(HasMethod(root, "wm_manage"))
            AhkTest.AssertTrue(HasMethod(root, "forget"))
            AhkTest.AssertTrue(HasMethod(root, "wm_forget"))
            AhkTest.AssertEqual("", frame.winfo_manager())
            AhkTest.AssertEqual(stdlib.None, root.manage(frame))
            AhkTest.AssertEqual("wm", frame.winfo_manager())
            AhkTest.AssertEqual("normal", root.eval("wm state " String(frame)))
            AhkTest.AssertEqual(stdlib.None, root.wm_forget(frame))
            AhkTest.AssertEqual("", frame.winfo_manager())
            AhkTest.AssertEqual(1, frame.winfo_exists())
            AhkTest.AssertEqual(stdlib.None, root.wm_manage(String(frame)))
            AhkTest.AssertEqual("wm", frame.winfo_manager())
            AhkTest.AssertEqual(stdlib.None, root.forget(String(frame)))
            AhkTest.AssertEqual("", frame.winfo_manager())

            AhkTest.AssertTrue(HasMethod(top, "manage"))
            AhkTest.AssertTrue(HasMethod(top, "wm_manage"))
            AhkTest.AssertTrue(HasMethod(top, "forget"))
            AhkTest.AssertTrue(HasMethod(top, "wm_forget"))
            AhkTest.AssertEqual(stdlib.None, top.wm_manage(topFrame))
            AhkTest.AssertEqual("wm", topFrame.winfo_manager())
            AhkTest.AssertEqual(stdlib.None, top.forget(topFrame))
            AhkTest.AssertEqual("", topFrame.winfo_manager())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.missing_manage"$', (*) => root.manage(".missing_manage"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "\.missing_manage"$', (*) => root.forget(".missing_manage"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_manage\(\) missing 1 required positional argument: 'widget'$", (*) => root.manage())
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_forget\(\) missing 1 required positional argument: 'window'$", (*) => root.forget())
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_manage\(\) takes 2 positional arguments but 3 were given$", (*) => top.wm_manage(frame, topFrame))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_forget\(\) takes 2 positional arguments but 3 were given$", (*) => top.wm_forget(frame, topFrame))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkWmAttributesAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            AhkTest.AssertEqual("", root.withdraw())
            top := stdlib.tkinter.Toplevel(root, { name: "attributes_alias" })
            AhkTest.AssertEqual("", top.withdraw())
            expectedAttributes := stdlib.tuple(["-alpha", 1.0, "-transparentcolor", "", "-disabled", 0, "-fullscreen", 0, "-toolwindow", 0, "-topmost", 0])

            AhkTest.AssertTrue(HasMethod(root, "attributes"))
            AhkTest.AssertTrue(HasMethod(root, "wm_attributes"))
            AhkTest.AssertEqual(expectedAttributes, root.attributes())
            AhkTest.AssertEqual(1.0, root.wm_attributes("-alpha"))
            AhkTest.AssertEqual(0, root.attributes("-topmost"))
            AhkTest.AssertEqual("", root.attributes("-alpha", 0.75))
            AhkTest.AssertEqual(0.75, root.wm_attributes("-alpha"))
            AhkTest.AssertEqual("", root.wm_attributes("-alpha", 1.0))
            AhkTest.AssertEqual(1.0, root.attributes("-alpha"))
            AhkTest.AssertEqual("", root.attributes("-topmost", stdlib.True))
            AhkTest.AssertEqual(1, root.wm_attributes("-topmost"))
            AhkTest.AssertEqual("", root.wm_attributes("-topmost", stdlib.False))
            AhkTest.AssertEqual(0, root.attributes("-topmost"))

            AhkTest.AssertTrue(HasMethod(top, "attributes"))
            AhkTest.AssertTrue(HasMethod(top, "wm_attributes"))
            AhkTest.AssertEqual(expectedAttributes, top.attributes())
            AhkTest.AssertEqual("", top.wm_attributes("-disabled", stdlib.True))
            AhkTest.AssertEqual(1, top.attributes("-disabled"))
            AhkTest.AssertEqual("", top.attributes("-disabled", stdlib.False))
            AhkTest.AssertEqual(0, top.wm_attributes("-disabled"))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad attribute "-not_an_attribute": must be -alpha, -transparentcolor, -disabled, -fullscreen, -toolwindow, or -topmost$', (*) => root.attributes("-not_an_attribute"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected floating-point number but got "bad"$', (*) => root.wm_attributes("-alpha", "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad attribute "alpha": must be -alpha, -transparentcolor, -disabled, -fullscreen, -toolwindow, or -topmost$', (*) => root.attributes("alpha"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "wm attributes window \?-alpha \?double\?\? \?-transparentcolor \?color\?\? \?-disabled \?bool\?\? \?-fullscreen \?bool\?\? \?-toolwindow \?bool\?\? \?-topmost \?bool\?\?"$', (*) => root.attributes("-alpha", 1.0, "-topmost"))
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
            AhkTest.AssertTrue(event is stdlib.tkinter.Event)
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

            AhkTest.AssertTrue(frame is stdlib.tkinter.Frame)
            AhkTest.AssertTrue(label is stdlib.tkinter.Label)
            AhkTest.AssertTrue(button is stdlib.tkinter.Button)
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

    static TestTkWmTitleAliasMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            top := stdlib.tkinter.Toplevel(root, { name: "title_alias" })
            top.withdraw()

            AhkTest.AssertTrue(HasMethod(root, "wm_title"))
            AhkTest.AssertTrue(HasMethod(top, "wm_title"))
            AhkTest.AssertEqual("tk", root.title())
            AhkTest.AssertEqual("tk", root.wm_title())
            AhkTest.AssertEqual("", root.wm_title("Root Alias"))
            AhkTest.AssertEqual("Root Alias", root.title())
            AhkTest.AssertEqual("Root Alias", root.wm_title(stdlib.None))
            AhkTest.AssertEqual("Root Alias", root.title(stdlib.None))

            AhkTest.AssertEqual("tk", top.title())
            AhkTest.AssertEqual("tk", top.wm_title())
            AhkTest.AssertEqual("", top.wm_title("Top Alias"))
            AhkTest.AssertEqual("Top Alias", top.title())
            AhkTest.AssertEqual("Top Alias", top.wm_title(stdlib.None))
            AhkTest.AssertEqual("Top Alias", top.title(stdlib.None))

            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_title\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.wm_title("a", "b"))
            AhkTest.RaisesMatch(TypeError, "^Wm\.wm_title\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => top.wm_title("a", "b"))
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

            AhkTest.AssertTrue(top is stdlib.tkinter.Toplevel)
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

            AhkTest.AssertTrue(listbox is stdlib.tkinter.Listbox)
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
            AhkTest.AssertEqual(stdlib.None, listbox.insert("end", "delta", "epsilon", "zeta", "eta", "theta"))
            AhkTest.AssertEqual(8, listbox.size())
            AhkTest.AssertEqual("alpha", listbox.get(0))
            AhkTest.AssertEqual(stdlib.tuple(["alpha", "gamma", "beta", "delta", "epsilon", "zeta", "eta", "theta"]), listbox.get(0, "end"))
            AhkTest.AssertEqual(stdlib.tuple(["gamma", "beta"]), listbox.get(1, 2))
            AhkTest.AssertEqual(8, listbox.index("end"))
            AhkTest.AssertEqual(stdlib.None, listbox.activate(2))
            AhkTest.AssertEqual(2, listbox.index("active"))
            AhkTest.AssertEqual(0, listbox.nearest(0))
            AhkTest.AssertEqual(stdlib.None, listbox.see(7))
            AhkTest.AssertEqual(7, listbox.nearest(20))
            AhkTest.AssertEqual(stdlib.None, listbox.scan_mark(5, 5))
            AhkTest.AssertEqual(stdlib.None, listbox.scan_dragto(1, 1))
            AhkTest.AssertEqual(stdlib.None, listbox.itemconfigure(0, { background: "red" }))
            AhkTest.AssertEqual("red", listbox.itemcget(0, "background"))
            AhkTest.AssertEqual(stdlib.None, listbox.itemconfig(0, { foreground: "blue" }))
            AhkTest.AssertEqual("blue", listbox.itemcget(0, "foreground"))
            backgroundConfig := listbox.itemconfigure(0, "background")
            AhkTest.AssertEqual(stdlib.tuple(["background", "background", "Background", "", "red"]), backgroundConfig)
            itemConfig := listbox.itemconfigure(0)
            AhkTest.AssertEqual(backgroundConfig, itemConfig["background"])
            AhkTest.AssertEqual(stdlib.tuple(["fg", "-foreground"]), itemConfig["fg"])
            AhkTest.AssertEqual(stdlib.None, listbox.xview_moveto(0.5))
            AhkTest.AssertEqual(stdlib.None, listbox.xview_scroll(1, "units"))
            AhkTest.AssertEqual(stdlib.None, listbox.xview("scroll", 1, "units"))
            AhkTest.AssertEqual(2, listbox.xview().Length)
            AhkTest.AssertEqual(stdlib.None, listbox.yview_moveto(0.5))
            AhkTest.AssertEqual(stdlib.None, listbox.yview_scroll(1, "units"))
            AhkTest.AssertEqual(stdlib.None, listbox.yview("scroll", 1, "units"))
            AhkTest.AssertEqual(2, listbox.yview().Length)
            bboxListbox := stdlib.tkinter.Listbox(root, { name: "bboxlist", height: 3, width: 12 })
            AhkTest.AssertTrue(HasMethod(bboxListbox, "bbox"))
            AhkTest.AssertEqual(stdlib.None, bboxListbox.insert("end", "alpha", "beta", "gamma", "delta", "epsilon"))
            AhkTest.AssertEqual(stdlib.None, bboxListbox.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            listboxFirstBox := bboxListbox.bbox(0)
            AhkTest.AssertEqual(4, listboxFirstBox.Length)
            AhkTest.AssertEqual(2, listboxFirstBox[1])
            AhkTest.AssertEqual(2, listboxFirstBox[2])
            AhkTest.AssertTrue(listboxFirstBox[3] > 0)
            AhkTest.AssertTrue(listboxFirstBox[4] > 0)
            AhkTest.AssertEqual(stdlib.None, bboxListbox.bbox(1))
            AhkTest.AssertEqual(stdlib.None, bboxListbox.activate(0))
            listboxActiveBox := bboxListbox.bbox("active")
            AhkTest.AssertEqual(listboxFirstBox[1], listboxActiveBox[1])
            AhkTest.AssertEqual(listboxFirstBox[2], listboxActiveBox[2])
            AhkTest.AssertEqual(listboxFirstBox[3], listboxActiveBox[3])
            AhkTest.AssertEqual(listboxFirstBox[4], listboxActiveBox[4])
            AhkTest.AssertEqual(stdlib.None, bboxListbox.bbox("end"))
            AhkTest.AssertEqual(stdlib.None, bboxListbox.bbox(4))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.bbox\(\) missing 1 required positional argument: 'index'$", (*) => bboxListbox.bbox())
            AhkTest.RaisesMatch(TypeError, "^Listbox\.bbox\(\) takes 2 positional arguments but 3 were given$", (*) => bboxListbox.bbox(0, 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad listbox index "bad": must be active, anchor, end, @x,y, or a number$', (*) => bboxListbox.bbox("bad"))
            AhkTest.AssertEqual(stdlib.None, listbox.selection_set(0, 1))
            AhkTest.AssertEqual(stdlib.tuple([0, 1]), listbox.curselection())
            AhkTest.AssertSame(stdlib.True, listbox.selection_includes(0))
            AhkTest.AssertSame(stdlib.False, listbox.selection_includes(2))
            AhkTest.AssertEqual(stdlib.None, listbox.select_set(2))
            AhkTest.AssertSame(stdlib.True, listbox.select_includes(2))
            AhkTest.AssertEqual(stdlib.None, listbox.select_clear(2))
            AhkTest.AssertSame(stdlib.False, listbox.select_includes(2))
            AhkTest.AssertEqual(stdlib.None, listbox.select_anchor(3))
            AhkTest.AssertEqual(3, listbox.index("anchor"))
            AhkTest.AssertEqual(stdlib.None, listbox.selection_anchor(2))
            AhkTest.AssertEqual(2, listbox.index("anchor"))
            AhkTest.AssertEqual(stdlib.None, listbox.selection_clear(0))
            AhkTest.AssertEqual(stdlib.tuple([1]), listbox.curselection())
            AhkTest.AssertEqual(stdlib.None, listbox.delete(1))
            AhkTest.AssertEqual(stdlib.tuple(["alpha", "beta", "delta", "epsilon", "zeta", "eta", "theta"]), listbox.get(0, "end"))
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
            AhkTest.RaisesMatch(TypeError, "^Listbox\.activate\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Listbox(root).activate())
            AhkTest.RaisesMatch(TypeError, "^Listbox\.activate\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Listbox(root).activate(1, 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad listbox index "bad": must be active, anchor, end, @x,y, or a number$', (*) => stdlib.tkinter.Listbox(root).activate("bad"))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.nearest\(\) missing 1 required positional argument: 'y'$", (*) => stdlib.tkinter.Listbox(root).nearest())
            AhkTest.RaisesMatch(TypeError, "^Listbox\.nearest\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Listbox(root).nearest(1, 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => stdlib.tkinter.Listbox(root).nearest("bad"))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.see\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Listbox(root).see())
            AhkTest.RaisesMatch(TypeError, "^Listbox\.see\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Listbox(root).see(1, 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad listbox index "bad": must be active, anchor, end, @x,y, or a number$', (*) => stdlib.tkinter.Listbox(root).see("bad"))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.scan_mark\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => stdlib.tkinter.Listbox(root).scan_mark())
            AhkTest.RaisesMatch(TypeError, "^Listbox\.scan_mark\(\) missing 1 required positional argument: 'y'$", (*) => stdlib.tkinter.Listbox(root).scan_mark(1))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.scan_mark\(\) takes 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Listbox(root).scan_mark(1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => stdlib.tkinter.Listbox(root).scan_mark("bad", 1))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.scan_dragto\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => stdlib.tkinter.Listbox(root).scan_dragto())
            AhkTest.RaisesMatch(TypeError, "^Listbox\.scan_dragto\(\) missing 1 required positional argument: 'y'$", (*) => stdlib.tkinter.Listbox(root).scan_dragto(1))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.scan_dragto\(\) takes 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Listbox(root).scan_dragto(1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => stdlib.tkinter.Listbox(root).scan_dragto(1, "bad"))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.selection_anchor\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Listbox(root).selection_anchor())
            AhkTest.RaisesMatch(TypeError, "^Listbox\.selection_anchor\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Listbox(root).select_anchor(1, 2))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.itemcget\(\) missing 2 required positional arguments: 'index' and 'option'$", (*) => stdlib.tkinter.Listbox(root).itemcget())
            AhkTest.RaisesMatch(TypeError, "^Listbox\.itemcget\(\) missing 1 required positional argument: 'option'$", (*) => stdlib.tkinter.Listbox(root).itemcget(0))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.itemcget\(\) takes 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Listbox(root).itemcget(0, "background", "x"))
            AhkTest.RaisesMatch(TypeError, "^Listbox\.itemconfigure\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Listbox(root).itemconfigure())
            AhkTest.RaisesMatch(TypeError, "^Listbox\.itemconfigure\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Listbox(root).itemconfigure(0, {}, "extra"))
            errorListbox := stdlib.tkinter.Listbox(root)
            errorListbox.insert("end", "item")
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => errorListbox.itemconfigure(0, { bad: 1 }))
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
            AhkTest.AssertEqual(stdlib.None, noCommandButton.flash())
            AhkTest.AssertEqual(stdlib.None, noCommandButton.configure({ command: strCommand }))
            AhkTest.AssertEqual("done", noCommandButton.invoke())
            AhkTest.AssertEqual(["str", "str"], strCommand.Calls)

            badButton := stdlib.tkinter.Button(root, { command: 1 })
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^invalid command name " Chr(34) "1" Chr(34) "$", (*) => badButton.invoke())
            AhkTest.RaisesMatch(TypeError, "^Button\.invoke\(\) takes 1 positional argument but 2 were given$", (*) => strButton.invoke(1))
            AhkTest.RaisesMatch(TypeError, "^Button\.flash\(\) takes 1 positional argument but 2 were given$", (*) => strButton.flash(1))
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
            label := stdlib.tkinter.Label(root, { name: "mainloop_label", text: "Mainloop" })
            button := stdlib.tkinter.Button(root, { name: "mainloop_button", text: "Quit" })
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, button.pack())
            noneCommand := StdlibTkinterTest.CommandRecorder(stdlib.None, "none")
            strCommand := StdlibTkinterTest.CommandRecorder("done", "str")
            quitCommand := StdlibTkinterTest.QuitRecorder(root, "mainloop")
            widgetQuitCommand := StdlibTkinterTest.QuitRecorder(label, "widget-mainloop")

            AhkTest.AssertEqual(stdlib.None, root.quit())
            AhkTest.AssertTrue(HasMethod(label, "mainloop"))
            AhkTest.AssertTrue(HasMethod(label, "quit"))
            AhkTest.AssertEqual(stdlib.None, label.quit())
            AhkTest.AssertEqual(stdlib.None, button.quit())
            AhkTest.RaisesMatch(TypeError, "^Misc\.quit\(\) takes 1 positional argument but 2 were given$", (*) => root.quit(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.quit\(\) takes 1 positional argument but 2 were given$", (*) => label.quit(1))
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
            AhkTest.AssertRegex(label.after(0, widgetQuitCommand), "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, label.mainloop())
            AhkTest.AssertEqual(["widget-mainloop"], widgetQuitCommand.Calls)
            AhkTest.RaisesMatch(TypeError, "^Misc\.mainloop\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => root.mainloop(0, 1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.mainloop\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => label.mainloop(0, 1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestModuleLevelDefaultRootImageAndMainloopSurfaceMatchesLocal310()
    {
        AhkTest.RaisesMatch(RuntimeError, "^Too early to use image_names\(\): no default root window$", (*) => stdlib.tkinter.image_names())
        AhkTest.RaisesMatch(RuntimeError, "^Too early to use image_types\(\): no default root window$", (*) => stdlib.tkinter.image_types())
        AhkTest.RaisesMatch(RuntimeError, "^Too early to run the main loop: no default root window$", (*) => stdlib.tkinter.mainloop())
        AhkTest.RaisesMatch(TypeError, "^image_names\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.tkinter.image_names(1))
        AhkTest.RaisesMatch(TypeError, "^image_types\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.tkinter.image_types(1))
        AhkTest.RaisesMatch(TypeError, "^mainloop\(\) takes from 0 to 1 positional arguments but 2 were given$", (*) => stdlib.tkinter.mainloop(0, 1))

        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            defaultNames := stdlib.tuple(["::tk::icons::information", "::tk::icons::error", "::tk::icons::warning", "::tk::icons::question"])

            AhkTest.AssertEqual(stdlib.tuple(["photo", "bitmap"]), stdlib.tkinter.image_types())
            AhkTest.AssertEqual(defaultNames, stdlib.tkinter.image_names())
            AhkTest.AssertEqual(root.image_types(), stdlib.tkinter.image_types())
            AhkTest.AssertEqual(root.image_names(), stdlib.tkinter.image_names())

            value := stdlib.tkinter.StringVar()
            AhkTest.AssertEqual("", value.get())
            AhkTest.AssertEqual(stdlib.None, value.set("defaulted"))
            AhkTest.AssertEqual("defaulted", value.get())
            label := stdlib.tkinter.Label({ name: "module_default_label", text: "Default" })
            image := stdlib.tkinter.PhotoImage({ name: "module_default_image", width: 1, height: 1 })
            AhkTest.AssertEqual(".module_default_label", String(label))
            AhkTest.AssertEqual("Default", label.cget("text"))
            AhkTest.AssertContains("module_default_image", stdlib.tkinter.image_names())

            AhkTest.AssertRegex(root.after(0, (*) => root.quit()), "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, stdlib.tkinter.mainloop())
            AhkTest.AssertEqual(stdlib.None, root.destroy())
            AhkTest.RaisesMatch(RuntimeError, "^Too early to use image_types\(\): no default root window$", (*) => stdlib.tkinter.image_types())
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkMainloopReturnsAfterDefaultWindowCloseMatchesLocal310()
    {
        scriptPath := A_Temp "\stdlib-tkinter-mainloop-close-" A_TickCount "-" Random(100000, 999999) ".ahk"
        SplitPath A_LineFile, , &testsDir
        stdlibDir := RegExReplace(testsDir, "\\tests$")
        tkinterPath := stdlibDir "\tkinter.ahk"
        script := '#Requires AutoHotkey v2.0`n'
            . '#ErrorStdOut "UTF-8"`n'
            . '#Include "' tkinterPath '"`n'
            . 'fail(message) {`n'
            . '    FileAppend "FAIL:" message "``n", "**", "UTF-8"`n'
            . '    ExitApp 7`n'
            . '}`n'
            . 'assert_same(expected, actual, label) {`n'
            . '    if expected !== actual`n'
            . '        fail(label ": unexpected object")`n'
            . '}`n'
            . 'raises(errorType, pattern, callback, label) {`n'
            . '    try {`n'
            . '        callback.Call()`n'
            . '    } catch as err {`n'
            . '        if !(err is errorType)`n'
            . '            fail(label ": wrong error type " Type(err) ": " err.Message)`n'
            . '        if !RegExMatch(err.Message, pattern)`n'
            . '            fail(label ": wrong message " err.Message)`n'
            . '        return`n'
            . '    }`n'
            . '    fail(label ": no error")`n'
            . '}`n'
            . 'root := stdlib.tkinter.Tk()`n'
            . 'root.eval("wm withdraw .")`n'
            . 'closeCommand := root.protocol("WM_DELETE_WINDOW")`n'
            . 'if closeCommand = ""`n'
            . '    fail("missing close command")`n'
            . 'root.eval(closeCommand)`n'
            . 'assert_same(stdlib.None, root.mainloop(), "mainloop return")`n'
            . 'raises(RuntimeError, "^Too early to create widget: no default root window$", (*) => stdlib.tkinter.Label({ text: "closed" }), "closed default widget")`n'
            . 'nextRoot := stdlib.tkinter.Tk()`n'
            . 'label := stdlib.tkinter.Label({ text: "new default" })`n'
            . 'assert_same(nextRoot, label._root(), "new default root")`n'
            . 'if label.cget("text") != "new default"`n'
            . '    fail("new default label text")`n'
            . 'nextRoot.destroy()`n'
            . 'FileAppend "ok``n", "*", "UTF-8"`n'
            . 'ExitApp 0`n'
        try {
            FileAppend script, scriptPath, "UTF-8"
            result := AhkTest.CaptureFixture().RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", scriptPath], { WorkingDir: stdlibDir, TimeoutSeconds: 10 })
        } finally {
            try FileDelete scriptPath
        }
        diagnostic := "exit=" result.ExitCode " stdout=" result.Out " stderr=" result.Err
        AhkTest.AssertEqual(0, result.ExitCode, diagnostic)
        AhkTest.AssertContains("ok", result.Out, diagnostic)
    }

    static TestModuleLevelGetbooleanUsesDefaultRootMatchesLocal310()
    {
        AhkTest.RaisesMatch(RuntimeError, "^Too early to use getboolean\(\): no default root window$", (*) => stdlib.tkinter.getboolean("1"))
        AhkTest.RaisesMatch(TypeError, "^getboolean\(\) missing 1 required positional argument: 's'$", (*) => stdlib.tkinter.getboolean())
        AhkTest.RaisesMatch(TypeError, "^getboolean\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.getboolean("1", "0"))

        root := stdlib.tkinter.Tk()
        rootDestroyed := false
        try {
            root.eval("wm withdraw .")
            AhkTest.AssertSame(stdlib.True, stdlib.tkinter.getboolean("1"))
            AhkTest.AssertSame(stdlib.False, stdlib.tkinter.getboolean("0"))
            AhkTest.AssertSame(stdlib.True, stdlib.tkinter.getboolean("yes"))
            AhkTest.AssertSame(stdlib.False, stdlib.tkinter.getboolean("no"))
            AhkTest.AssertSame(stdlib.True, stdlib.tkinter.getboolean(stdlib.True))
            AhkTest.AssertSame(stdlib.False, stdlib.tkinter.getboolean(stdlib.False))
            AhkTest.AssertSame(stdlib.True, stdlib.tkinter.getboolean(1))
            AhkTest.AssertSame(stdlib.False, stdlib.tkinter.getboolean(0))
            AhkTest.RaisesMatch(ValueError, "^invalid literal for getboolean\(\)$", (*) => stdlib.tkinter.getboolean("maybe"))
            AhkTest.RaisesMatch(ValueError, "^invalid literal for getboolean\(\)$", (*) => stdlib.tkinter.getboolean(" 1 "))
            AhkTest.RaisesMatch(TypeError, "^getboolean\(\) argument must be str, not None$", (*) => stdlib.tkinter.getboolean(stdlib.None))
            AhkTest.RaisesMatch(TypeError, "^getboolean\(\) argument must be str, not float$", (*) => stdlib.tkinter.getboolean(1.25))

            AhkTest.AssertEqual(stdlib.None, root.destroy())
            rootDestroyed := true
            AhkTest.RaisesMatch(RuntimeError, "^Too early to use getboolean\(\): no default root window$", (*) => stdlib.tkinter.getboolean("1"))
        } finally {
            if !rootDestroyed
                try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestModuleLevelGetintGetdoubleUsePythonAliasesMatchLocal310()
    {
        AhkTest.AssertTrue(HasMethod(stdlib.tkinter, "getint"))
        AhkTest.AssertTrue(HasMethod(stdlib.tkinter, "getdouble"))

        AhkTest.AssertEqual(0, stdlib.tkinter.getint())
        AhkTest.AssertEqual(7, stdlib.tkinter.getint("7"))
        AhkTest.AssertEqual(7, stdlib.tkinter.getint(" 7 "))
        AhkTest.AssertEqual(7, stdlib.tkinter.getint("+7"))
        AhkTest.AssertEqual(9, stdlib.tkinter.getint("09"))
        AhkTest.AssertEqual(3, stdlib.tkinter.getint(3.5))
        AhkTest.AssertEqual(1, stdlib.tkinter.getint(stdlib.True))
        AhkTest.AssertEqual(0, stdlib.tkinter.getint(stdlib.False))
        AhkTest.RaisesMatch(ValueError, "^invalid literal for int\(\) with base 10: '0x10'$", (*) => stdlib.tkinter.getint("0x10"))
        AhkTest.RaisesMatch(ValueError, "^invalid literal for int\(\) with base 10: '3\.5'$", (*) => stdlib.tkinter.getint("3.5"))
        AhkTest.RaisesMatch(TypeError, "^int\(\) argument must be a string, a bytes-like object or a real number, not 'NoneType'$", (*) => stdlib.tkinter.getint(stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^int\(\) argument must be a string, a bytes-like object or a real number, not 'list'$", (*) => stdlib.tkinter.getint([]))

        AhkTest.AssertEqual(0.0, stdlib.tkinter.getdouble())
        AhkTest.AssertEqual(1.25, stdlib.tkinter.getdouble("1.25"))
        AhkTest.AssertEqual(2.0, stdlib.tkinter.getdouble("2"))
        AhkTest.AssertEqual(4.5, stdlib.tkinter.getdouble(" 4.5 "))
        AhkTest.AssertEqual(9.0, stdlib.tkinter.getdouble("09"))
        AhkTest.AssertEqual(1.0, stdlib.tkinter.getdouble(stdlib.True))
        AhkTest.AssertEqual(0.0, stdlib.tkinter.getdouble(stdlib.False))
        AhkTest.RaisesMatch(TypeError, "^float\(\) argument must be a string or a real number, not 'NoneType'$", (*) => stdlib.tkinter.getdouble(stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^float\(\) argument must be a string or a real number, not 'list'$", (*) => stdlib.tkinter.getdouble([]))
        AhkTest.RaisesMatch(TypeError, "^float expected at most 1 argument, got 2$", (*) => stdlib.tkinter.getdouble("1", "2"))
    }

    static TestNoDefaultRootMatchesLocal310()
    {
        scriptPath := A_Temp "\stdlib-tkinter-nodefaultroot-" A_TickCount "-" Random(100000, 999999) ".ahk"
        SplitPath A_LineFile, , &testsDir
        stdlibDir := RegExReplace(testsDir, "\\tests$")
        tkinterPath := stdlibDir "\tkinter.ahk"
        script := '#Requires AutoHotkey v2.0`n'
            . '#ErrorStdOut "UTF-8"`n'
            . '#Include "' tkinterPath '"`n'
            . 'fail(message) {`n'
            . '    FileAppend "FAIL:" message "``n", "**", "UTF-8"`n'
            . '    ExitApp 7`n'
            . '}`n'
            . 'assert_equal(expected, actual, label) {`n'
            . '    if expected != actual`n'
            . '        fail(label ": expected " expected ", got " actual)`n'
            . '}`n'
            . 'assert_same(expected, actual, label) {`n'
            . '    if expected !== actual`n'
            . '        fail(label ": unexpected object")`n'
            . '}`n'
            . 'raises(errorType, pattern, callback, label) {`n'
            . '    try {`n'
            . '        callback.Call()`n'
            . '    } catch as err {`n'
            . '        if !(err is errorType)`n'
            . '            fail(label ": wrong error type " Type(err) ": " err.Message)`n'
            . '        if !RegExMatch(err.Message, pattern)`n'
            . '            fail(label ": wrong message " err.Message)`n'
            . '        return`n'
            . '    }`n'
            . '    fail(label ": no error")`n'
            . '}`n'
            . 'if !HasMethod(stdlib.tkinter, "NoDefaultRoot")`n'
            . '    fail("missing NoDefaultRoot")`n'
            . 'root := stdlib.tkinter.Tk()`n'
            . 'root.withdraw()`n'
            . 'assert_same(stdlib.None, stdlib.tkinter.NoDefaultRoot(), "return")`n'
            . 'assert_same(stdlib.True, root.getboolean("1"), "explicit root still works")`n'
            . 'raises(RuntimeError, "^No master specified and tkinter is configured to not support default root$", (*) => stdlib.tkinter.getboolean("1"), "module getboolean")`n'
            . 'raises(RuntimeError, "^No master specified and tkinter is configured to not support default root$", (*) => stdlib.tkinter.image_names(), "module image_names")`n'
            . 'raises(RuntimeError, "^No master specified and tkinter is configured to not support default root$", (*) => stdlib.tkinter.mainloop(), "module mainloop")`n'
            . 'raises(RuntimeError, "^No master specified and tkinter is configured to not support default root$", (*) => stdlib.tkinter.StringVar(), "StringVar")`n'
            . 'raises(RuntimeError, "^No master specified and tkinter is configured to not support default root$", (*) => stdlib.tkinter.Label({ text: "x" }), "Label")`n'
            . 'raises(RuntimeError, "^No master specified and tkinter is configured to not support default root$", (*) => stdlib.tkinter.Toplevel(), "Toplevel")`n'
            . 'raises(TypeError, "^NoDefaultRoot\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.tkinter.NoDefaultRoot(1), "arity one")`n'
            . 'nextRoot := stdlib.tkinter.Tk()`n'
            . 'nextRoot.withdraw()`n'
            . 'raises(RuntimeError, "^No master specified and tkinter is configured to not support default root$", (*) => stdlib.tkinter.getboolean("1"), "new root not default")`n'
            . 'nextRoot.destroy()`n'
            . 'root.destroy()`n'
            . 'FileAppend "ok``n", "*", "UTF-8"`n'
            . 'ExitApp 0`n'
        try {
            FileAppend script, scriptPath, "UTF-8"
            result := AhkTest.CaptureFixture().RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", scriptPath], { WorkingDir: stdlibDir, TimeoutSeconds: 10 })
        } finally {
            try FileDelete scriptPath
        }
        diagnostic := "exit=" result.ExitCode " stdout=" result.Out " stderr=" result.Err
        AhkTest.AssertEqual(0, result.ExitCode, diagnostic)
        AhkTest.AssertContains("ok", result.Out, diagnostic)
    }

    static TestTkinterIncludeToleratesHostClassNameCollisions()
    {
        scriptPath := A_Temp "\stdlib-tkinter-class-collision-" A_TickCount "-" Random(100000, 999999) ".ahk"
        SplitPath A_LineFile, , &testsDir
        stdlibDir := RegExReplace(testsDir, "\\tests$")
        tkinterPath := stdlibDir "\tkinter.ahk"
        script := '#Requires AutoHotkey v2.0`n'
            . '#ErrorStdOut "UTF-8"`n'
            . 'class Menu`n'
            . '{`n'
            . '}`n'
            . 'class Button`n'
            . '{`n'
            . '}`n'
            . 'class Event`n'
            . '{`n'
            . '}`n'
            . 'class Image`n'
            . '{`n'
            . '}`n'
            . 'class Text`n'
            . '{`n'
            . '}`n'
            . '#Include "' tkinterPath '"`n'
            . 'interp := stdlib.tkinter.Tcl()`n'
            . 'evtInstance := stdlib.tkinter.Event()`n'
            . 'eventTypeInstance := stdlib.tkinter.EventType("4")`n'
            . 'if !(interp is stdlib.tkinter.Tk)`n'
            . '    ExitApp 11`n'
            . 'if !(evtInstance is stdlib.tkinter.Event)`n'
            . '    ExitApp 12`n'
            . 'if !(eventTypeInstance is stdlib.tkinter.EventType)`n'
            . '    ExitApp 13`n'
            . 'if !HasMethod(stdlib.tkinter, "Menu")`n'
            . '    ExitApp 14`n'
            . 'if (stdlib.tkinter.Menu = Menu)`n'
            . '    ExitApp 15`n'
            . 'FileAppend "ok``n", "*", "UTF-8"`n'
            . 'ExitApp 0`n'
        try {
            FileAppend script, scriptPath, "UTF-8"
            result := AhkTest.CaptureFixture().RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", scriptPath], { WorkingDir: stdlibDir, TimeoutSeconds: 10 })
        } finally {
            try FileDelete scriptPath
        }
        diagnostic := "exit=" result.ExitCode " stdout=" result.Out " stderr=" result.Err
        AhkTest.AssertEqual(0, result.ExitCode, diagnostic)
        AhkTest.AssertContains("ok", result.Out, diagnostic)
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
            widgetAfter := StdlibTkinterTest.CommandRecorder(stdlib.None, "after_widget")
            widgetAfterArg := StdlibTkinterTest.CommandRecorder("ignored", "after_arg")
            cancelledAfter := StdlibTkinterTest.CommandRecorder(stdlib.None, "cancelled_after")
            cancelledIdle := StdlibTkinterTest.CommandRecorder(stdlib.None, "cancelled")

            AhkTest.RaisesMatch(TypeError, "^Misc\.after_idle\(\) missing 1 required positional argument: 'func'$", (*) => root.after_idle())
            AhkTest.RaisesMatch(TypeError, "^Misc\.after\(\) missing 1 required positional argument: 'ms'$", (*) => label.after())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad argument "bad": must be cancel, idle, info, or an integer$', (*) => label.after("bad"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.after_cancel\(\) missing 1 required positional argument: 'id'$", (*) => label.after_cancel())
            AhkTest.RaisesMatch(TypeError, "^Misc\.after_cancel\(\) takes 2 positional arguments but 3 were given$", (*) => label.after_cancel("missing", "extra"))
            AhkTest.AssertEqual(stdlib.None, label.after(0))
            widgetAfterId := label.after(0, widgetAfter)
            widgetAfterArgId := label.after(0, widgetAfterArg, "x")
            rootIdleId := root.after_idle(rootIdle)
            argIdleId := root.after_idle(argIdle, "x")
            widgetIdleId := label.after_idle(widgetIdle)
            AhkTest.AssertRegex(widgetAfterId, "^after#[0-9]+$")
            AhkTest.AssertRegex(widgetAfterArgId, "^after#[0-9]+$")
            AhkTest.AssertRegex(rootIdleId, "^after#[0-9]+$")
            AhkTest.AssertRegex(argIdleId, "^after#[0-9]+$")
            AhkTest.AssertRegex(widgetIdleId, "^after#[0-9]+$")
            AhkTest.AssertEqual([], widgetAfter.Calls)
            AhkTest.AssertEqual([], widgetAfterArg.Calls)
            AhkTest.AssertEqual([], rootIdle.Calls)
            AhkTest.AssertEqual([], argIdle.Calls)
            AhkTest.AssertEqual([], widgetIdle.Calls)

            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual(["after_widget"], widgetAfter.Calls)
            AhkTest.AssertEqual(["after_arg:x"], widgetAfterArg.Calls)
            AhkTest.AssertEqual(["idle"], rootIdle.Calls)
            AhkTest.AssertEqual(["arg:x"], argIdle.Calls)
            AhkTest.AssertEqual(["widget"], widgetIdle.Calls)

            cancelAfterId := label.after(1000, cancelledAfter)
            AhkTest.AssertRegex(cancelAfterId, "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, label.after_cancel(cancelAfterId))
            AhkTest.AssertEqual(stdlib.None, label.after_cancel("missing"))
            cancelId := root.after_idle(cancelledIdle)
            AhkTest.AssertRegex(cancelId, "^after#[0-9]+$")
            AhkTest.AssertEqual(stdlib.None, root.after_cancel(cancelId))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual([], cancelledAfter.Calls)
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
            second := stdlib.tkinter.Entry(root, { name: "second" })
            button := stdlib.tkinter.Button(root, { name: "press", text: "Press" })
            AhkTest.AssertEqual(stdlib.None, entry.pack())
            AhkTest.AssertEqual(stdlib.None, second.pack())
            AhkTest.AssertEqual(stdlib.None, button.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertTrue(HasMethod(root, "focus"))
            AhkTest.AssertTrue(HasMethod(entry, "focus"))
            AhkTest.AssertTrue(HasMethod(button, "focus"))
            AhkTest.AssertTrue(HasMethod(root, "tk_focusNext"))
            AhkTest.AssertTrue(HasMethod(entry, "tk_focusPrev"))
            AhkTest.AssertSame(entry, root.tk_focusNext())
            AhkTest.AssertSame(second, entry.tk_focusNext())
            AhkTest.AssertSame(button, second.tk_focusNext())
            AhkTest.AssertSame(button, root.tk_focusPrev())
            AhkTest.AssertSame(second, button.tk_focusPrev())
            AhkTest.AssertSame(entry, second.tk_focusPrev())
            AhkTest.AssertEqual(stdlib.None, root.focus())
            AhkTest.AssertEqual(stdlib.None, entry.focus())
            AhkTest.AssertEqual(stdlib.None, entry.focus_set())
            AhkTest.AssertEqual(stdlib.None, entry.focus_force())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertSame(entry, root.focus_get())
            AhkTest.AssertSame(entry, entry.focus_displayof())
            AhkTest.AssertEqual(stdlib.None, button.focus())
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
            AhkTest.RaisesMatch(TypeError, "^Misc\.focus_set\(\) takes 1 positional argument but 2 were given$", (*) => root.focus(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.focus_set\(\) takes 1 positional argument but 2 were given$", (*) => entry.focus(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.focus_set\(\) takes 1 positional argument but 2 were given$", (*) => entry.focus_set(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.focus_force\(\) takes 1 positional argument but 2 were given$", (*) => button.focus_force(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.focus_displayof\(\) takes 1 positional argument but 2 were given$", (*) => button.focus_displayof(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.tk_focusNext\(\) takes 1 positional argument but 2 were given$", (*) => root.tk_focusNext(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.tk_focusPrev\(\) takes 1 positional argument but 2 were given$", (*) => entry.tk_focusPrev(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkFocusFollowsMouseMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            label := stdlib.tkinter.Label(root, { name: "focus_follows_mouse_label", text: "Focus follows" })
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            AhkTest.AssertTrue(HasMethod(root, "tk_focusFollowsMouse"))
            AhkTest.AssertTrue(HasMethod(label, "tk_focusFollowsMouse"))
            AhkTest.AssertEqual(stdlib.None, root.tk_focusFollowsMouse())
            AhkTest.AssertEqual(stdlib.None, label.tk_focusFollowsMouse())
            AhkTest.RaisesMatch(TypeError, "^Misc\.tk_focusFollowsMouse\(\) takes 1 positional argument but 2 were given$", (*) => root.tk_focusFollowsMouse(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.tk_focusFollowsMouse\(\) takes 1 positional argument but 2 were given$", (*) => label.tk_focusFollowsMouse(1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkBellMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            label := stdlib.tkinter.Label(root, { name: "bell_label", text: "Bell" })
            AhkTest.AssertEqual(stdlib.None, label.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            AhkTest.AssertTrue(HasMethod(root, "bell"))
            AhkTest.AssertTrue(HasMethod(label, "bell"))
            AhkTest.AssertEqual(stdlib.None, root.bell())
            AhkTest.AssertEqual(stdlib.None, label.bell())
            AhkTest.AssertEqual(stdlib.None, root.bell(stdlib.None))
            AhkTest.AssertEqual(stdlib.None, label.bell(0))
            AhkTest.AssertEqual(stdlib.None, root.bell(root))
            AhkTest.AssertEqual(stdlib.None, label.bell(label))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "bad"$', (*) => root.bell("bad"))
            AhkTest.RaisesMatch(TypeError, "^Misc\.bell\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => label.bell(0, 1))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkFocusLastforMatchesLocal310()
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

            AhkTest.AssertTrue(HasMethod(root, "focus_lastfor"))
            AhkTest.AssertTrue(HasMethod(entry, "focus_lastfor"))
            AhkTest.AssertTrue(HasMethod(button, "focus_lastfor"))
            AhkTest.AssertSame(root, root.focus_lastfor())
            AhkTest.AssertSame(root, entry.focus_lastfor())
            AhkTest.AssertSame(root, button.focus_lastfor())

            AhkTest.AssertEqual(stdlib.None, entry.focus_force())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertSame(entry, root.focus_get())
            AhkTest.AssertSame(entry, root.focus_lastfor())
            AhkTest.AssertSame(entry, entry.focus_lastfor())
            AhkTest.AssertSame(entry, button.focus_lastfor())

            AhkTest.AssertEqual(stdlib.None, button.focus_force())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertSame(button, root.focus_get())
            AhkTest.AssertSame(button, root.focus_lastfor())
            AhkTest.AssertSame(button, entry.focus_lastfor())
            AhkTest.AssertSame(button, button.focus_lastfor())

            AhkTest.AssertEqual("", root.withdraw())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertSame(stdlib.None, root.focus_get())
            AhkTest.AssertSame(button, root.focus_lastfor())
            AhkTest.AssertSame(button, entry.focus_lastfor())

            AhkTest.RaisesMatch(TypeError, "^Misc\.focus_lastfor\(\) takes 1 positional argument but 2 were given$", (*) => root.focus_lastfor(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.focus_lastfor\(\) takes 1 positional argument but 2 were given$", (*) => entry.focus_lastfor(1))
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

            AhkTest.AssertTrue(check is stdlib.tkinter.Checkbutton)
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
            AhkTest.AssertEqual(stdlib.None, check.flash())
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
            AhkTest.RaisesMatch(TypeError, "^Checkbutton\.flash\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Checkbutton(root).flash(1))
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

            AhkTest.AssertTrue(radio is stdlib.tkinter.Radiobutton)
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

            AhkTest.AssertTrue(scale is stdlib.tkinter.Scale)
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

            AhkTest.AssertTrue(bar is stdlib.tkinter.Scrollbar)
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

            AhkTest.AssertTrue(menu is stdlib.tkinter.Menu)
            AhkTest.AssertEqual(".menubar", String(menu))
            AhkTest.AssertSame(root, menu._root())
            AhkTest.AssertEqual(1, menu.winfo_exists())
            AhkTest.AssertEqual(0, menu.cget("tearoff"))
            AhkTest.AssertEqual("", menu.cget("title"))
            AhkTest.AssertEqual("normal", menu.cget("type"))
            AhkTest.AssertEqual(stdlib.None, menu.index("end"))
            AhkTest.AssertTrue(HasMethod(menu, "add"))
            AhkTest.AssertTrue(HasMethod(menu, "add_cascade"))
            AhkTest.AssertTrue(HasMethod(menu, "add_checkbutton"))
            AhkTest.AssertTrue(HasMethod(menu, "add_radiobutton"))
            AhkTest.AssertTrue(HasMethod(menu, "add_separator"))
            AhkTest.AssertTrue(HasMethod(menu, "type"))
            AhkTest.AssertTrue(HasMethod(menu, "activate"))
            AhkTest.AssertTrue(HasMethod(menu, "post"))
            AhkTest.AssertTrue(HasMethod(menu, "unpost"))
            AhkTest.AssertTrue(HasMethod(menu, "tk_popup"))
            AhkTest.AssertTrue(HasMethod(menu, "xposition"))
            AhkTest.AssertTrue(HasMethod(menu, "yposition"))
            AhkTest.AssertEqual("", menu.type("end"))
            AhkTest.AssertEqual(stdlib.None, menu.index("active"))
            AhkTest.AssertEqual(stdlib.None, menu.activate("end"))
            AhkTest.AssertEqual(stdlib.None, menu.index("active"))
            AhkTest.AssertEqual(stdlib.None, menu.add_command({ label: "Open", command: command, accelerator: "Ctrl+O", underline: 0 }))
            AhkTest.AssertEqual(0, menu.index("end"))
            AhkTest.AssertEqual("command", menu.type(0))
            AhkTest.AssertEqual("Open", menu.entrycget(0, "label"))
            AhkTest.AssertTrue(menu.entrycget(0, "command") != "")
            AhkTest.AssertEqual("Ctrl+O", menu.entrycget(0, "accelerator"))
            AhkTest.AssertEqual("normal", menu.entrycget(0, "state"))
            AhkTest.AssertEqual("done", menu.invoke(0))
            AhkTest.AssertEqual(["cmd"], calls)
            AhkTest.AssertEqual(stdlib.None, menu.add_separator())
            AhkTest.AssertEqual(1, menu.index("end"))
            AhkTest.AssertEqual("separator", menu.type(1))
            AhkTest.AssertEqual("separator", menu.type("end"))
            AhkTest.AssertEqual(stdlib.None, menu.add_separator({}))
            AhkTest.AssertEqual(2, menu.index("end"))
            AhkTest.AssertEqual("separator", menu.type(2))
            AhkTest.AssertEqual(stdlib.None, menu.add_command({ label: "Save" }))
            AhkTest.AssertEqual(3, menu.index("end"))
            AhkTest.AssertEqual("command", menu.type(3))
            AhkTest.AssertEqual(stdlib.None, menu.activate(0))
            AhkTest.AssertEqual(0, menu.index("active"))
            AhkTest.AssertEqual(stdlib.None, menu.activate(1))
            AhkTest.AssertEqual(stdlib.None, menu.index("active"))
            AhkTest.AssertEqual(stdlib.None, menu.activate("end"))
            AhkTest.AssertEqual(3, menu.index("active"))
            AhkTest.AssertEqual(stdlib.None, menu.activate("none"))
            AhkTest.AssertEqual(stdlib.None, menu.index("active"))
            cascadeMenu := stdlib.tkinter.Menu(menu, { name: "filemenu", tearoff: 0 })
            AhkTest.AssertEqual(stdlib.None, cascadeMenu.add_command({ label: "Nested" }))
            AhkTest.AssertEqual(stdlib.None, menu.add_cascade({ label: "File", menu: cascadeMenu, underline: 0 }))
            AhkTest.AssertEqual(4, menu.index("end"))
            AhkTest.AssertEqual("cascade", menu.type(4))
            AhkTest.AssertEqual("File", menu.entrycget(4, "label"))
            AhkTest.AssertEqual(String(cascadeMenu), menu.entrycget(4, "menu"))
            AhkTest.AssertEqual(stdlib.None, menu.add_cascade())
            AhkTest.AssertEqual(5, menu.index("end"))
            AhkTest.AssertEqual("cascade", menu.type(5))
            AhkTest.AssertEqual("", menu.entrycget(5, "label"))
            AhkTest.AssertEqual("", menu.entrycget(5, "menu"))
            AhkTest.AssertEqual(stdlib.None, menu.add_cascade({}))
            AhkTest.AssertEqual(6, menu.index("end"))
            AhkTest.AssertEqual("cascade", menu.type(6))
            menuCheckVar := stdlib.tkinter.StringVar(root, "no", "menu_check_var")
            menuRadioVar := stdlib.tkinter.StringVar(root, "none", "menu_radio_var")
            AhkTest.AssertEqual(stdlib.None, menu.add_checkbutton({ label: "Enabled", variable: menuCheckVar, onvalue: "yes", offvalue: "no" }))
            AhkTest.AssertEqual(7, menu.index("end"))
            AhkTest.AssertEqual("checkbutton", menu.type(7))
            AhkTest.AssertEqual("Enabled", menu.entrycget(7, "label"))
            AhkTest.AssertEqual("menu_check_var", menu.entrycget(7, "variable"))
            AhkTest.AssertEqual("yes", menu.entrycget(7, "onvalue"))
            AhkTest.AssertEqual("no", menu.entrycget(7, "offvalue"))
            AhkTest.AssertEqual("no", menuCheckVar.get())
            AhkTest.AssertEqual("", menu.invoke(7))
            AhkTest.AssertEqual("yes", menuCheckVar.get())
            AhkTest.AssertEqual("", menu.invoke(7))
            AhkTest.AssertEqual("no", menuCheckVar.get())
            AhkTest.AssertEqual(stdlib.None, menu.add_radiobutton({ label: "Choice A", variable: menuRadioVar, value: "A" }))
            AhkTest.AssertEqual(8, menu.index("end"))
            AhkTest.AssertEqual("radiobutton", menu.type(8))
            AhkTest.AssertEqual("Choice A", menu.entrycget(8, "label"))
            AhkTest.AssertEqual("menu_radio_var", menu.entrycget(8, "variable"))
            AhkTest.AssertEqual("A", menu.entrycget(8, "value"))
            AhkTest.AssertEqual("none", menuRadioVar.get())
            AhkTest.AssertEqual("", menu.invoke(8))
            AhkTest.AssertEqual("A", menuRadioVar.get())
            AhkTest.AssertEqual(stdlib.None, menu.add_checkbutton())
            AhkTest.AssertEqual(9, menu.index("end"))
            AhkTest.AssertEqual("checkbutton", menu.type(9))
            AhkTest.AssertEqual(stdlib.None, menu.add_radiobutton({}))
            AhkTest.AssertEqual(10, menu.index("end"))
            AhkTest.AssertEqual("radiobutton", menu.type(10))
            commandEntryConfig := menu.entryconfigure(0)
            AhkTest.AssertTrue(commandEntryConfig is Map)
            AhkTest.AssertEqual(stdlib.tuple(["label", "", "", "", "Open"]), commandEntryConfig["label"])
            AhkTest.AssertEqual(stdlib.tuple(["state", "", "", "normal", "normal"]), commandEntryConfig["state"])
            AhkTest.AssertEqual(stdlib.tuple(["underline", "", "", -1, 0]), commandEntryConfig["underline"])
            AhkTest.AssertEqual(stdlib.tuple(["label", "", "", "", "Open"]), menu.entryconfigure(0, "label"))
            AhkTest.AssertEqual(stdlib.tuple(["accelerator", "", "", "", "Ctrl+O"]), menu.entryconfigure(0, "accelerator"))
            commandOptionConfig := menu.entryconfigure(0, "command")
            AhkTest.AssertEqual("command", commandOptionConfig[1])
            AhkTest.AssertEqual("", commandOptionConfig[2])
            AhkTest.AssertEqual("", commandOptionConfig[3])
            AhkTest.AssertEqual("", commandOptionConfig[4])
            AhkTest.AssertTrue(commandOptionConfig[5] != "")
            AhkTest.AssertEqual(stdlib.tuple(["variable", "", "", "", "menu_check_var"]), menu.entryconfigure(7, "variable"))
            AhkTest.AssertEqual(stdlib.tuple(["onvalue", "", "", "1", "yes"]), menu.entryconfigure(7, "onvalue"))
            AhkTest.AssertEqual(stdlib.tuple(["value", "", "", "", "A"]), menu.entryconfigure(8, "value"))
            AhkTest.AssertEqual(stdlib.tuple(["menu", "", "", "", String(cascadeMenu)]), menu.entryconfig(4, "menu"))
            aliasEntryConfig := menu.entryconfig(0)
            AhkTest.AssertTrue(aliasEntryConfig is Map)
            AhkTest.AssertEqual(commandEntryConfig["label"], aliasEntryConfig["label"])
            AhkTest.AssertEqual(stdlib.None, menu.entryconfigure(0, { label: "Open file", state: "disabled" }))
            AhkTest.AssertEqual("Open file", menu.entrycget(0, "label"))
            AhkTest.AssertEqual("disabled", menu.entrycget(0, "state"))
            AhkTest.AssertEqual("", menu.invoke(0))
            AhkTest.AssertEqual(["cmd"], calls)
            AhkTest.AssertEqual(stdlib.None, menu.delete(0, "end"))
            AhkTest.AssertEqual(stdlib.None, menu.index("end"))
            AhkTest.AssertEqual(stdlib.None, menu.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .menubar"))

            AhkTest.AssertEqual(".kw", String(stdlib.tkinter.Menu({ master: root, name: "kw" })))
            AhkTest.AssertEqual(0, stdlib.tkinter.Menu(root, { name: "cnf", tearoff: 0 }).cget("tearoff"))
            dictMenu := stdlib.tkinter.Menu(root, { tearoff: 0 })
            AhkTest.AssertEqual(stdlib.None, dictMenu.add_command({ label: "Dict" }))
            AhkTest.AssertEqual("Dict", dictMenu.entrycget(0, "label"))
            genericAddCalls := []
            genericAddMenu := stdlib.tkinter.Menu(root, { name: "genericadd", tearoff: 0 })
            genericAddCascadeMenu := stdlib.tkinter.Menu(genericAddMenu, { name: "genericcascade", tearoff: 0 })
            genericAddCheckVar := stdlib.tkinter.StringVar(root, "no", "generic_add_check_var")
            genericAddRadioVar := stdlib.tkinter.StringVar(root, "none", "generic_add_radio_var")
            AhkTest.AssertEqual(stdlib.None, genericAddCascadeMenu.add_command({ label: "Nested" }))
            AhkTest.AssertEqual(stdlib.None, genericAddMenu.add("command", { label: "Generic", command: (*) => (genericAddCalls.Push("generic"), "generic") }))
            AhkTest.AssertEqual(stdlib.None, genericAddMenu.add("cascade", { label: "Sub", menu: genericAddCascadeMenu }))
            AhkTest.AssertEqual(stdlib.None, genericAddMenu.add("checkbutton", { label: "Enabled", variable: genericAddCheckVar, onvalue: "yes", offvalue: "no" }))
            AhkTest.AssertEqual(stdlib.None, genericAddMenu.add("radiobutton", { label: "Choice A", variable: genericAddRadioVar, value: "A" }))
            AhkTest.AssertEqual(stdlib.None, genericAddMenu.add("separator"))
            AhkTest.AssertEqual(stdlib.None, genericAddMenu.add("command", {}))
            AhkTest.AssertEqual(5, genericAddMenu.index("end"))
            AhkTest.AssertEqual("command", genericAddMenu.type(0))
            AhkTest.AssertEqual("Generic", genericAddMenu.entrycget(0, "label"))
            AhkTest.AssertEqual("cascade", genericAddMenu.type(1))
            AhkTest.AssertEqual("Sub", genericAddMenu.entrycget(1, "label"))
            AhkTest.AssertEqual(String(genericAddCascadeMenu), genericAddMenu.entrycget(1, "menu"))
            AhkTest.AssertEqual("checkbutton", genericAddMenu.type(2))
            AhkTest.AssertEqual("generic_add_check_var", genericAddMenu.entrycget(2, "variable"))
            AhkTest.AssertEqual("yes", genericAddMenu.entrycget(2, "onvalue"))
            AhkTest.AssertEqual("no", genericAddMenu.entrycget(2, "offvalue"))
            AhkTest.AssertEqual("radiobutton", genericAddMenu.type(3))
            AhkTest.AssertEqual("Choice A", genericAddMenu.entrycget(3, "label"))
            AhkTest.AssertEqual("generic_add_radio_var", genericAddMenu.entrycget(3, "variable"))
            AhkTest.AssertEqual("A", genericAddMenu.entrycget(3, "value"))
            AhkTest.AssertEqual("separator", genericAddMenu.type(4))
            AhkTest.AssertEqual("command", genericAddMenu.type(5))
            AhkTest.AssertEqual("", genericAddMenu.entrycget(5, "label"))
            AhkTest.AssertEqual("no", genericAddCheckVar.get())
            AhkTest.AssertEqual("", genericAddMenu.invoke(2))
            AhkTest.AssertEqual("yes", genericAddCheckVar.get())
            AhkTest.AssertEqual("none", genericAddRadioVar.get())
            AhkTest.AssertEqual("", genericAddMenu.invoke(3))
            AhkTest.AssertEqual("A", genericAddRadioVar.get())
            AhkTest.AssertEqual("generic", genericAddMenu.invoke(0))
            AhkTest.AssertEqual(["generic"], genericAddCalls)
            insertCalls := []
            insertMenu := stdlib.tkinter.Menu(root, { name: "insertmenu", tearoff: 0 })
            insertCascadeMenu := stdlib.tkinter.Menu(insertMenu, { name: "insertcascade", tearoff: 0 })
            insertCheckVar := stdlib.tkinter.StringVar(root, "no", "insert_check_var")
            insertRadioVar := stdlib.tkinter.StringVar(root, "none", "insert_radio_var")
            AhkTest.AssertTrue(HasMethod(insertMenu, "insert"))
            AhkTest.AssertTrue(HasMethod(insertMenu, "insert_cascade"))
            AhkTest.AssertTrue(HasMethod(insertMenu, "insert_checkbutton"))
            AhkTest.AssertTrue(HasMethod(insertMenu, "insert_command"))
            AhkTest.AssertTrue(HasMethod(insertMenu, "insert_radiobutton"))
            AhkTest.AssertTrue(HasMethod(insertMenu, "insert_separator"))
            AhkTest.AssertEqual(stdlib.None, insertCascadeMenu.add_command({ label: "Nested" }))
            AhkTest.AssertEqual(stdlib.None, insertMenu.add_command({ label: "Tail", command: (*) => "tail" }))
            AhkTest.AssertEqual(stdlib.None, insertMenu.insert_command(0, { label: "First", command: (*) => (insertCalls.Push("first"), "first"), accelerator: "Ctrl+F" }))
            AhkTest.AssertEqual(stdlib.None, insertMenu.insert_separator("end"))
            AhkTest.AssertEqual(stdlib.None, insertMenu.insert_cascade(1, { label: "Sub", menu: insertCascadeMenu, underline: 0 }))
            AhkTest.AssertEqual(stdlib.None, insertMenu.insert_radiobutton(2, { label: "Choice A", variable: insertRadioVar, value: "A" }))
            AhkTest.AssertEqual(stdlib.None, insertMenu.insert_checkbutton("end", { label: "Enabled", variable: insertCheckVar, onvalue: "yes", offvalue: "no" }))
            AhkTest.AssertEqual(5, insertMenu.index("end"))
            AhkTest.AssertEqual("command", insertMenu.type(0))
            AhkTest.AssertEqual("First", insertMenu.entrycget(0, "label"))
            AhkTest.AssertEqual("Ctrl+F", insertMenu.entrycget(0, "accelerator"))
            AhkTest.AssertEqual("cascade", insertMenu.type(1))
            AhkTest.AssertEqual("Sub", insertMenu.entrycget(1, "label"))
            AhkTest.AssertEqual(String(insertCascadeMenu), insertMenu.entrycget(1, "menu"))
            AhkTest.AssertEqual("radiobutton", insertMenu.type(2))
            AhkTest.AssertEqual("Choice A", insertMenu.entrycget(2, "label"))
            AhkTest.AssertEqual("insert_radio_var", insertMenu.entrycget(2, "variable"))
            AhkTest.AssertEqual("A", insertMenu.entrycget(2, "value"))
            AhkTest.AssertEqual("command", insertMenu.type(3))
            AhkTest.AssertEqual("Tail", insertMenu.entrycget(3, "label"))
            AhkTest.AssertEqual("separator", insertMenu.type(4))
            AhkTest.AssertEqual("checkbutton", insertMenu.type(5))
            AhkTest.AssertEqual("Enabled", insertMenu.entrycget(5, "label"))
            AhkTest.AssertEqual("insert_check_var", insertMenu.entrycget(5, "variable"))
            AhkTest.AssertEqual("yes", insertMenu.entrycget(5, "onvalue"))
            AhkTest.AssertEqual("no", insertMenu.entrycget(5, "offvalue"))
            AhkTest.AssertEqual("no", insertCheckVar.get())
            AhkTest.AssertEqual("", insertMenu.invoke(5))
            AhkTest.AssertEqual("yes", insertCheckVar.get())
            AhkTest.AssertEqual("none", insertRadioVar.get())
            AhkTest.AssertEqual("", insertMenu.invoke(2))
            AhkTest.AssertEqual("A", insertRadioVar.get())
            AhkTest.AssertEqual("first", insertMenu.invoke(0))
            AhkTest.AssertEqual(["first"], insertCalls)
            emptyInsertMenu := stdlib.tkinter.Menu(root, { tearoff: 0 })
            AhkTest.AssertEqual(stdlib.None, emptyInsertMenu.insert_command(0, {}))
            AhkTest.AssertEqual("command", emptyInsertMenu.type(0))
            AhkTest.AssertEqual(stdlib.None, emptyInsertMenu.insert_separator(0, {}))
            AhkTest.AssertEqual("separator", emptyInsertMenu.type(0))
            AhkTest.AssertEqual("command", emptyInsertMenu.type(1))
            genericInsertMenu := stdlib.tkinter.Menu(root, { tearoff: 0 })
            AhkTest.AssertEqual(stdlib.None, genericInsertMenu.insert(0, "command", { label: "Generic" }))
            AhkTest.AssertEqual("command", genericInsertMenu.type(0))
            AhkTest.AssertEqual("Generic", genericInsertMenu.entrycget(0, "label"))
            postMenu := stdlib.tkinter.Menu(root, { name: "postmenu", tearoff: 0 })
            AhkTest.AssertEqual(stdlib.None, postMenu.add_command({ label: "Top" }))
            AhkTest.AssertEqual(stdlib.None, postMenu.add_separator())
            AhkTest.AssertEqual(stdlib.None, postMenu.add_command({ label: "Bottom" }))
            AhkTest.AssertEqual(2, postMenu.index("end"))
            postMenuY0 := postMenu.yposition(0)
            postMenuY1 := postMenu.yposition(1)
            postMenuYEnd := postMenu.yposition("end")
            postMenuX0 := postMenu.xposition(0)
            postMenuX1 := postMenu.xposition(1)
            postMenuXEnd := postMenu.xposition("end")
            postMenuXActiveBefore := postMenu.xposition("active")
            AhkTest.AssertTrue(postMenuY0 is Integer)
            AhkTest.AssertTrue(postMenuY1 is Integer)
            AhkTest.AssertTrue(postMenuYEnd is Integer)
            AhkTest.AssertTrue(postMenuX0 is Integer)
            AhkTest.AssertTrue(postMenuX1 is Integer)
            AhkTest.AssertTrue(postMenuXEnd is Integer)
            AhkTest.AssertEqual(0, postMenuXActiveBefore)
            AhkTest.AssertTrue(postMenuY0 < postMenuY1)
            AhkTest.AssertTrue(postMenuY1 <= postMenuYEnd)
            AhkTest.AssertEqual(stdlib.None, postMenu.activate(0))
            AhkTest.AssertEqual(0, postMenu.index("active"))
            AhkTest.AssertEqual(postMenuX0, postMenu.xposition("active"))
            AhkTest.AssertEqual(0, postMenu.winfo_ismapped())
            AhkTest.AssertEqual(stdlib.None, postMenu.unpost())
            AhkTest.AssertEqual(0, postMenu.winfo_ismapped())
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.Menu({ master: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Menu\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Menu(root, {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-extra_kw"$', (*) => stdlib.tkinter.Menu(root, { extra_kw: 1 }))
            AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => stdlib.tkinter.Menu(root).add_command(1))
            AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => stdlib.tkinter.Menu(root).add_cascade(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.Menu(root).add_cascade({ bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Menu\.add_cascade\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Menu(root).add_cascade({}, {}))
            AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => stdlib.tkinter.Menu(root).add_checkbutton(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.Menu(root).add_checkbutton({ bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Menu\.add_checkbutton\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Menu(root).add_checkbutton({}, {}))
            AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => stdlib.tkinter.Menu(root).add_radiobutton(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.Menu(root).add_radiobutton({ bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Menu\.add_radiobutton\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Menu(root).add_radiobutton({}, {}))
            AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => stdlib.tkinter.Menu(root).add_separator(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.Menu(root).add_separator({ bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Menu\.add_separator\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Menu(root).add_separator({}, {}))
            AhkTest.RaisesMatch(TypeError, "^Menu\.add\(\) missing 1 required positional argument: 'itemType'$", (*) => stdlib.tkinter.Menu(root).add())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad menu entry type "badtype": must be cascade, checkbutton, command, radiobutton, or separator$', (*) => stdlib.tkinter.Menu(root).add("badtype", {}))
            AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => stdlib.tkinter.Menu(root).add("command", 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.Menu(root).add("command", { bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Menu\.add\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Menu(root).add("command", {}, {}))
            AhkTest.RaisesMatch(TypeError, "^Menu\.insert\(\) missing 1 required positional argument: 'itemType'$", (*) => stdlib.tkinter.Menu(root).insert(0))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad menu entry type "badtype": must be cascade, checkbutton, command, radiobutton, or separator$', (*) => stdlib.tkinter.Menu(root).insert(0, "badtype", {}))
            AhkTest.RaisesMatch(TypeError, "^Menu\.insert_command\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Menu(root).insert_command())
            AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => stdlib.tkinter.Menu(root).insert_command(0, 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.Menu(root).insert_command(0, { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad menu entry index "bad"$', (*) => stdlib.tkinter.Menu(root).insert_command("bad", { label: "Bad" }))
            AhkTest.RaisesMatch(TypeError, "^Menu\.insert_command\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Menu(root).insert_command(0, {}, {}))
            AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => stdlib.tkinter.Menu(root).insert_separator(0, 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.Menu(root).insert_separator(0, { bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Menu\.insert_separator\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Menu(root).insert_separator(0, {}, {}))
            AhkTest.RaisesMatch(TypeError, "^Menu\.post\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => stdlib.tkinter.Menu(root).post())
            AhkTest.RaisesMatch(TypeError, "^Menu\.post\(\) missing 1 required positional argument: 'y'$", (*) => stdlib.tkinter.Menu(root).post(10))
            AhkTest.RaisesMatch(TypeError, "^Menu\.post\(\) takes 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Menu(root).post(10, 20, 30))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => stdlib.tkinter.Menu(root).post("bad", 20))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => stdlib.tkinter.Menu(root).post(10, "bad"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.unpost\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.tkinter.Menu(root).unpost(1))
            AhkTest.RaisesMatch(TypeError, "^Menu\.tk_popup\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => stdlib.tkinter.Menu(root).tk_popup())
            AhkTest.RaisesMatch(TypeError, "^Menu\.tk_popup\(\) missing 1 required positional argument: 'y'$", (*) => stdlib.tkinter.Menu(root).tk_popup(10))
            AhkTest.RaisesMatch(TypeError, "^Menu\.tk_popup\(\) takes from 3 to 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.Menu(root).tk_popup(10, 20, 0, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => stdlib.tkinter.Menu(root).tk_popup("bad", 20))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => stdlib.tkinter.Menu(root).tk_popup(10, "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad menu entry index "badentry"$', (*) => stdlib.tkinter.Menu(root).tk_popup(10, 20, "badentry"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.xposition\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Menu(root).xposition())
            AhkTest.RaisesMatch(TypeError, "^Menu\.xposition\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Menu(root).xposition(0, 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad menu entry index "bad"$', (*) => stdlib.tkinter.Menu(root).xposition("bad"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.yposition\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Menu(root).yposition())
            AhkTest.RaisesMatch(TypeError, "^Menu\.yposition\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Menu(root).yposition(0, 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad menu entry index "bad"$', (*) => stdlib.tkinter.Menu(root).yposition("bad"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.entrycget\(\) missing 2 required positional arguments: 'index' and 'option'$", (*) => stdlib.tkinter.Menu(root).entrycget())
            AhkTest.RaisesMatch(TypeError, "^Menu\.entrycget\(\) missing 1 required positional argument: 'option'$", (*) => stdlib.tkinter.Menu(root).entrycget(0))
            AhkTest.RaisesMatch(TypeError, "^Menu\.entrycget\(\) takes 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Menu(root).entrycget(0, "label", "x"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.entryconfigure\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Menu(root).entryconfigure())
            AhkTest.RaisesMatch(TypeError, "^Menu\.entryconfigure\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Menu(root).entryconfigure(0, { label: "x" }, "extra"))
            AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => stdlib.tkinter.Menu(root).entryconfigure(0, 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.Menu(root).entryconfigure(0, "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "--label"$', (*) => stdlib.tkinter.Menu(root).entryconfigure(0, "-label"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.index\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Menu(root).index())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad menu entry index "bad"$', (*) => stdlib.tkinter.Menu(root).index("bad"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.index\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Menu(root).index("end", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.type\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Menu(root).type())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad menu entry index "bad"$', (*) => stdlib.tkinter.Menu(root).type("bad"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.type\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Menu(root).type(0, 1))
            AhkTest.RaisesMatch(TypeError, "^Menu\.activate\(\) missing 1 required positional argument: 'index'$", (*) => stdlib.tkinter.Menu(root).activate())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad menu entry index "bad"$', (*) => stdlib.tkinter.Menu(root).activate("bad"))
            AhkTest.RaisesMatch(TypeError, "^Menu\.activate\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.tkinter.Menu(root).activate(0, 1))
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
            AhkTest.AssertTrue(entry is stdlib.tkinter.Entry)
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
            AhkTest.AssertTrue(HasMethod(root, "selection_get"))
            AhkTest.AssertTrue(HasMethod(root, "selection_clear"))
            AhkTest.AssertTrue(HasMethod(root, "selection_own"))
            AhkTest.AssertTrue(HasMethod(root, "selection_own_get"))
            AhkTest.AssertTrue(HasMethod(entry, "selection_clear"))
            AhkTest.AssertTrue(HasMethod(entry, "selection_own"))
            AhkTest.AssertTrue(HasMethod(entry, "selection_own_get"))
            AhkTest.AssertSame(entry, root.selection_own_get())
            AhkTest.AssertSame(entry, entry.selection_own_get())
            AhkTest.AssertEqual("bcd", entry.selection_get())
            AhkTest.AssertEqual("bcd", root.selection_get())
            AhkTest.AssertEqual(stdlib.None, root.selection_clear())
            AhkTest.AssertEqual(stdlib.None, root.selection_own_get())
            AhkTest.AssertEqual(stdlib.None, entry.selection_own_get())
            AhkTest.AssertSame(stdlib.True, entry.selection_present())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^PRIMARY selection doesn't exist or form `"STRING`" not defined$", (*) => entry.selection_get())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^PRIMARY selection doesn't exist or form `"STRING`" not defined$", (*) => root.selection_get())

            AhkTest.AssertEqual(stdlib.None, entry.selection_range(2, 5))
            AhkTest.AssertEqual(stdlib.None, root.selection_own())
            AhkTest.AssertSame(root, root.selection_own_get())
            AhkTest.AssertSame(root, entry.selection_own_get())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^PRIMARY selection doesn't exist or form `"STRING`" not defined$", (*) => root.selection_get())
            AhkTest.AssertEqual(stdlib.None, entry.selection_own())
            AhkTest.AssertSame(entry, root.selection_own_get())
            AhkTest.AssertSame(entry, entry.selection_own_get())
            AhkTest.AssertEqual("cde", entry.selection_get())
            AhkTest.AssertEqual(stdlib.None, entry.selection_clear())
            AhkTest.AssertSame(stdlib.False, entry.selection_present())
            AhkTest.AssertEqual(stdlib.None, entry.select_from(1))
            AhkTest.AssertEqual(stdlib.None, entry.select_to(3))
            AhkTest.AssertEqual("bc", entry.selection_get())
            AhkTest.AssertEqual(stdlib.None, entry.select_adjust(4))
            AhkTest.AssertEqual("bcd", entry.selection_get())
            AhkTest.AssertEqual(stdlib.None, entry.scan_mark(3))
            AhkTest.AssertEqual(stdlib.None, entry.scan_dragto(1))
            AhkTest.AssertEqual(stdlib.None, entry.delete(0, "end"))
            AhkTest.AssertEqual(stdlib.None, entry.insert(0, "abcdefghijklmnopqrstuvwxyz"))
            initialXView := entry.xview()
            AhkTest.AssertEqual(2, initialXView.Length)
            AhkTest.AssertEqual(stdlib.None, entry.xview_moveto(0.5))
            movedXView := entry.xview()
            AhkTest.AssertEqual(2, movedXView.Length)
            AhkTest.AssertTrue(movedXView[1] > initialXView[1])
            AhkTest.AssertEqual(stdlib.None, entry.xview_scroll(1, "units"))
            scrolledXView := entry.xview()
            AhkTest.AssertEqual(2, scrolledXView.Length)
            AhkTest.AssertTrue(scrolledXView[1] >= movedXView[1])
            AhkTest.AssertEqual(stdlib.None, entry.xview("moveto", 0.25))
            AhkTest.AssertEqual(2, entry.xview().Length)
            AhkTest.AssertEqual(stdlib.None, entry.xview("scroll", 1, "units"))
            AhkTest.AssertEqual(2, entry.xview().Length)
            AhkTest.AssertEqual(stdlib.None, entry.xview(1))

            AhkTest.RaisesMatch(TypeError, "^Entry\.icursor\(\) missing 1 required positional argument: 'index'$", (*) => entry.icursor())
            AhkTest.RaisesMatch(TypeError, "^Entry\.scan_mark\(\) missing 1 required positional argument: 'x'$", (*) => entry.scan_mark())
            AhkTest.RaisesMatch(TypeError, "^Entry\.scan_mark\(\) takes 2 positional arguments but 3 were given$", (*) => entry.scan_mark(1, 2))
            AhkTest.RaisesMatch(TypeError, "^Entry\.scan_dragto\(\) missing 1 required positional argument: 'x'$", (*) => entry.scan_dragto())
            AhkTest.RaisesMatch(TypeError, "^Entry\.scan_dragto\(\) takes 2 positional arguments but 3 were given$", (*) => entry.scan_dragto(1, 2))
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_moveto\(\) missing 1 required positional argument: 'fraction'$", (*) => entry.xview_moveto())
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_moveto\(\) takes 2 positional arguments but 3 were given$", (*) => entry.xview_moveto(0.1, "extra"))
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_scroll\(\) missing 2 required positional arguments: 'number' and 'what'$", (*) => entry.xview_scroll())
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_scroll\(\) missing 1 required positional argument: 'what'$", (*) => entry.xview_scroll(1))
            AhkTest.RaisesMatch(TypeError, "^XView\.xview_scroll\(\) takes 3 positional arguments but 4 were given$", (*) => entry.xview_scroll(1, "units", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Entry\.selection_range\(\) missing 1 required positional argument: 'end'$", (*) => entry.selection_range(1))
            AhkTest.RaisesMatch(TypeError, "^Entry\.selection_present\(\) takes 1 positional argument but 2 were given$", (*) => entry.selection_present(1))
            AhkTest.RaisesMatch(TypeError, "^Entry\.selection_clear\(\) takes 1 positional argument but 2 were given$", (*) => entry.selection_clear(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.selection_get\(\) takes 1 positional argument but 2 were given$", (*) => root.selection_get(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.selection_clear\(\) takes 1 positional argument but 2 were given$", (*) => root.selection_clear(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.selection_own\(\) takes 1 positional argument but 2 were given$", (*) => root.selection_own(1))
            AhkTest.RaisesMatch(TypeError, "^Misc\.selection_own_get\(\) takes 1 positional argument but 2 were given$", (*) => root.selection_own_get(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad entry index "bad"$', (*) => entry.index("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad entry index "bad"$', (*) => entry.icursor("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => entry.scan_mark("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => entry.scan_dragto("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad entry index "bad"$', (*) => entry.xview("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad entry index "moveto"$', (*) => entry.xview("moveto"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected floating-point number but got "bad"$', (*) => entry.xview("moveto", "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.!entry xview scroll number units\|pages"$', (*) => entry.xview("scroll", 1, "units", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => entry.xview("scroll", "bad", "units"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad argument "bad": must be units or pages$', (*) => entry.xview("scroll", 1, "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected floating-point number but got "bad"$', (*) => entry.xview_moveto("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => entry.xview_scroll("bad", "units"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad argument "bad": must be units or pages$', (*) => entry.xview_scroll(1, "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad entry index "bad"$', (*) => entry.select_range("bad", 2))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkSelectionHandleMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            entry := stdlib.tkinter.Entry(root, { name: "selection_handle_entry", width: 12 })
            AhkTest.AssertEqual(stdlib.None, entry.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            rootCalls := []
            rootHandler := (offset, length) => (
                rootCalls.Push([offset, length]),
                "handled:" offset ":" length
            )
            entryCalls := []
            entryHandler := (offset, length) => (
                entryCalls.Push([offset, length]),
                "entry:" offset ":" length
            )

            AhkTest.AssertTrue(HasMethod(root, "selection_handle"))
            AhkTest.AssertTrue(HasMethod(entry, "selection_handle"))
            AhkTest.AssertEqual(stdlib.None, root.selection_handle(rootHandler))
            AhkTest.AssertEqual(stdlib.None, root.selection_own())
            AhkTest.AssertEqual("handled:0:4000", root.selection_get())
            AhkTest.AssertEqual(1, rootCalls.Length)
            AhkTest.AssertEqual("0", rootCalls[1][1])
            AhkTest.AssertEqual("4000", rootCalls[1][2])

            AhkTest.AssertEqual(stdlib.None, entry.selection_handle(entryHandler, { type: "STRING" }))
            AhkTest.AssertEqual(stdlib.None, entry.selection_own())
            AhkTest.AssertEqual("entry:0:4000", root.selection_get())
            AhkTest.AssertEqual(1, entryCalls.Length)
            AhkTest.AssertEqual("0", entryCalls[1][1])
            AhkTest.AssertEqual("4000", entryCalls[1][2])

            AhkTest.AssertEqual(stdlib.None, root.selection_handle(123))
            AhkTest.RaisesMatch(TypeError, "^Misc\.selection_handle\(\) missing 1 required positional argument: 'command'$", (*) => root.selection_handle())
            AhkTest.RaisesMatch(TypeError, "^Misc\.selection_handle\(\) takes 2 positional arguments but 3 were given$", (*) => root.selection_handle(rootHandler, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad option "-bad": must be -format, -selection, or -type$', (*) => entry.selection_handle(entryHandler, { bad: "x" }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestSpinboxWidgetValueSelectionAndInvokeSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            seenValues := []
            value := stdlib.tkinter.StringVar(root, "2", "spin_var")
            spin := stdlib.tkinter.Spinbox(root, { from_: 0, to: 5, increment: 1, textvariable: value, width: 6, command: (*) => seenValues.Push(value.get()) })
            AhkTest.AssertEqual(stdlib.None, spin.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertTrue(spin is stdlib.tkinter.Spinbox)
            AhkTest.AssertEqual(".!spinbox", String(spin))
            AhkTest.AssertSame(root, spin._root())
            AhkTest.AssertEqual(1, spin.winfo_exists())
            AhkTest.AssertEqual("Spinbox", spin.winfo_class())
            AhkTest.AssertEqual(6, spin.cget("width"))
            AhkTest.AssertEqual("spin_var", spin.cget("textvariable"))
            AhkTest.AssertEqual("2", spin.get())
            AhkTest.AssertEqual("2", value.get())

            AhkTest.AssertEqual(stdlib.None, spin.delete(0, "end"))
            AhkTest.AssertEqual(stdlib.None, spin.insert(0, "abc"))
            AhkTest.AssertEqual("abc", spin.get())
            AhkTest.AssertEqual("abc", value.get())
            AhkTest.AssertEqual(stdlib.None, spin.icursor(1))
            AhkTest.AssertEqual(1, spin.index("insert"))
            AhkTest.AssertEqual(3, spin.index("end"))

            AhkTest.AssertSame(stdlib.False, spin.selection_present())
            AhkTest.AssertEqual(stdlib.None, spin.selection_range(0, 2))
            AhkTest.AssertSame(stdlib.True, spin.selection_present())
            AhkTest.AssertEqual("ab", spin.selection_get())
            AhkTest.AssertEqual(stdlib.None, spin.selection_clear())
            AhkTest.AssertSame(stdlib.False, spin.selection_present())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^PRIMARY selection doesn't exist or form `"STRING`" not defined$", (*) => spin.selection_get())

            AhkTest.AssertEqual(stdlib.None, spin.delete(0, "end"))
            AhkTest.AssertEqual(stdlib.None, spin.insert(0, "2"))
            AhkTest.AssertEqual(stdlib.None, spin.invoke("buttonup"))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("3", spin.get())
            AhkTest.AssertEqual("3", seenValues[1])
            AhkTest.AssertEqual(stdlib.None, spin.invoke("buttondown"))
            AhkTest.AssertEqual(stdlib.None, root.update())
            AhkTest.AssertEqual("2", spin.get())
            AhkTest.AssertEqual("2", seenValues[2])

            AhkTest.AssertEqual("none", spin.selection_element())
            AhkTest.AssertEqual(stdlib.None, spin.selection_element("buttonup"))
            AhkTest.AssertEqual("buttonup", spin.selection_element())
            AhkTest.AssertEqual(stdlib.None, spin.selection_element("none"))
            AhkTest.AssertEqual("none", spin.selection_element())
            AhkTest.AssertEqual(4, spin.bbox(0).Length)
            AhkTest.AssertEqual("buttondown", spin.identify(1, 1))
            AhkTest.AssertEqual(2, spin.xview().Length)
            AhkTest.AssertEqual(stdlib.None, spin.xview_moveto(0.5))
            AhkTest.AssertEqual(stdlib.None, spin.xview_scroll(1, "units"))
            AhkTest.AssertEqual(stdlib.tuple([]), spin.scan("mark", 3))
            AhkTest.AssertEqual(stdlib.tuple([]), spin.scan("dragto", 1))
            AhkTest.AssertEqual(stdlib.tuple([]), spin.scan_mark(3))
            AhkTest.AssertEqual(stdlib.tuple([]), spin.scan_dragto(1))

            AhkTest.RaisesMatch(TypeError, "^Spinbox\.get\(\) takes 1 positional argument but 2 were given$", (*) => spin.get(1))
            AhkTest.RaisesMatch(TypeError, "^Spinbox\.insert\(\) missing 2 required positional arguments: 'index' and 's'$", (*) => spin.insert())
            AhkTest.RaisesMatch(TypeError, "^Spinbox\.insert\(\) missing 1 required positional argument: 's'$", (*) => spin.insert(0))
            AhkTest.RaisesMatch(TypeError, "^Spinbox\.delete\(\) missing 1 required positional argument: 'first'$", (*) => spin.delete())
            AhkTest.RaisesMatch(TypeError, "^Spinbox\.invoke\(\) missing 1 required positional argument: 'element'$", (*) => spin.invoke())
            AhkTest.RaisesMatch(TypeError, "^Spinbox\.scan_mark\(\) missing 1 required positional argument: 'x'$", (*) => spin.scan_mark())
            AhkTest.RaisesMatch(TypeError, "^Spinbox\.scan_mark\(\) takes 2 positional arguments but 3 were given$", (*) => spin.scan_mark(1, 2))
            AhkTest.RaisesMatch(TypeError, "^Spinbox\.scan_dragto\(\) missing 1 required positional argument: 'x'$", (*) => spin.scan_dragto())
            AhkTest.RaisesMatch(TypeError, "^Spinbox\.scan_dragto\(\) takes 2 positional arguments but 3 were given$", (*) => spin.scan_dragto(1, 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad element "bad": must be none, buttondown, or buttonup$', (*) => spin.invoke("bad"))
            AhkTest.RaisesMatch(TypeError, "^Spinbox\.selection_range\(\) missing 1 required positional argument: 'end'$", (*) => spin.selection_range(1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad spinbox index "bad"$', (*) => spin.selection_range("bad", 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad selection element "bad": must be none, buttondown, or buttonup$', (*) => spin.selection_element("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad spinbox index "bad"$', (*) => spin.bbox("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => spin.identify("bad", 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be ".!spinbox scan mark\|dragto x"$', (*) => spin.scan())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be ".!spinbox scan mark\|dragto x"$', (*) => spin.scan("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be ".!spinbox scan mark\|dragto x"$', (*) => spin.scan("mark", 1, 2))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => spin.scan("mark", "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => spin.scan_mark("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => spin.scan_dragto("bad"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestClassicWidgetConstructionSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            menuCalls := []
            message := stdlib.tkinter.Message(root, { name: "msg_probe", text: "Hello wrap", width: 120, aspect: 200 })
            menubutton := stdlib.tkinter.Menubutton(root, { name: "mb_probe", text: "Menu", direction: "below", relief: "raised" })
            menu := stdlib.tkinter.Menu(menubutton, { name: "menu", tearoff: 0 })
            AhkTest.AssertEqual(stdlib.None, menu.add_command({ label: "Open", command: (*) => (menuCalls.Push("open"), "opened") }))
            AhkTest.AssertEqual(stdlib.None, menubutton.configure({ menu: menu }))
            caption := stdlib.tkinter.Label(root, { name: "caption", text: "Caption" })
            labelframe := stdlib.tkinter.LabelFrame(root, { name: "lf_probe", text: "Group", labelanchor: "n", labelwidget: caption, width: 100, height: 50 })
            inside := stdlib.tkinter.Label(labelframe, { name: "inside", text: "Inside" })

            AhkTest.AssertEqual(stdlib.None, message.pack())
            AhkTest.AssertEqual(stdlib.None, menubutton.pack())
            AhkTest.AssertEqual(stdlib.None, inside.pack())
            AhkTest.AssertEqual(stdlib.None, labelframe.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())

            AhkTest.AssertTrue(message is stdlib.tkinter.Message)
            AhkTest.AssertEqual(".msg_probe", String(message))
            AhkTest.AssertSame(root, message._root())
            AhkTest.AssertEqual(1, message.winfo_exists())
            AhkTest.AssertEqual("Message", message.winfo_class())
            AhkTest.AssertEqual("pack", message.winfo_manager())
            AhkTest.AssertEqual("Hello wrap", message.cget("text"))
            AhkTest.AssertEqual(120, message.cget("width"))
            AhkTest.AssertEqual(200, message.cget("aspect"))

            AhkTest.AssertTrue(menubutton is stdlib.tkinter.Menubutton)
            AhkTest.AssertEqual(".mb_probe", String(menubutton))
            AhkTest.AssertSame(root, menubutton._root())
            AhkTest.AssertEqual(1, menubutton.winfo_exists())
            AhkTest.AssertEqual("Menubutton", menubutton.winfo_class())
            AhkTest.AssertEqual("pack", menubutton.winfo_manager())
            AhkTest.AssertEqual("Menu", menubutton.cget("text"))
            AhkTest.AssertEqual("below", menubutton.cget("direction"))
            AhkTest.AssertEqual("raised", menubutton.cget("relief"))
            AhkTest.AssertEqual(".mb_probe.menu", menubutton.cget("menu"))
            AhkTest.AssertEqual("opened", menu.invoke(0))
            AhkTest.AssertEqual("open", menuCalls[1])

            AhkTest.AssertTrue(labelframe is stdlib.tkinter.LabelFrame)
            AhkTest.AssertEqual(".lf_probe", String(labelframe))
            AhkTest.AssertSame(root, labelframe._root())
            AhkTest.AssertEqual(1, labelframe.winfo_exists())
            AhkTest.AssertEqual("Labelframe", labelframe.winfo_class())
            AhkTest.AssertEqual("pack", labelframe.winfo_manager())
            AhkTest.AssertEqual("Group", labelframe.cget("text"))
            AhkTest.AssertEqual("n", labelframe.cget("labelanchor"))
            AhkTest.AssertEqual(".caption", labelframe.cget("labelwidget"))
            AhkTest.AssertEqual(100, labelframe.cget("width"))
            AhkTest.AssertEqual(50, labelframe.cget("height"))
            AhkTest.AssertEqual(".lf_probe", inside.winfo_parent())
            AhkTest.AssertEqual(".lf_probe.inside", String(inside))

            AhkTest.AssertEqual(stdlib.None, message.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .msg_probe"))
            AhkTest.AssertEqual(stdlib.None, menubutton.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .mb_probe"))
            AhkTest.AssertEqual(stdlib.None, labelframe.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .lf_probe"))

            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.Message({ master: 1 }))
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.Menubutton({ master: 1 }))
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.LabelFrame({ master: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Message\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Message(root, {}, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Menubutton\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.Menubutton(root, {}, "extra"))
            AhkTest.RaisesMatch(TypeError, "^LabelFrame\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.LabelFrame(root, {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.Message(root, { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.Menubutton(root, { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.LabelFrame(root, { bad: 1 }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestOptionMenuVariableMenuAndCommandSurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            commandCalls := []
            selected := stdlib.tkinter.StringVar(root, "seed", "option_var")
            option := stdlib.tkinter.OptionMenu(root, selected, "one", "two", "three", { command: (value) => (commandCalls.Push([value, selected.get()]), "ignored") })
            AhkTest.AssertEqual(stdlib.None, option.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual(stdlib.None, root.update())
            menu := option["menu"]

            AhkTest.AssertTrue(option is stdlib.tkinter.OptionMenu)
            AhkTest.AssertEqual(".!optionmenu", String(option))
            AhkTest.AssertSame(root, option._root())
            AhkTest.AssertEqual(1, option.winfo_exists())
            AhkTest.AssertEqual("Menubutton", option.winfo_class())
            AhkTest.AssertEqual("pack", option.winfo_manager())
            AhkTest.AssertEqual("option_var", option.cget("textvariable"))
            AhkTest.AssertEqual(".!optionmenu.menu", option.cget("menu"))
            AhkTest.AssertEqual("center", option.cget("anchor"))
            AhkTest.AssertEqual(2, option.cget("borderwidth"))
            AhkTest.AssertEqual(1, option.cget("indicatoron"))
            AhkTest.AssertEqual("raised", option.cget("relief"))
            AhkTest.AssertEqual(2, option.cget("highlightthickness"))
            AhkTest.AssertTrue(menu is stdlib.tkinter.Menu)
            AhkTest.AssertEqual(".!optionmenu.menu", String(menu))
            AhkTest.AssertEqual(0, menu.cget("tearoff"))
            AhkTest.AssertEqual(2, menu.index("end"))
            AhkTest.AssertEqual("one", menu.entrycget(0, "label"))
            AhkTest.AssertEqual("two", menu.entrycget(1, "label"))
            AhkTest.AssertEqual("three", menu.entrycget(2, "label"))
            AhkTest.AssertEqual("seed", selected.get())

            AhkTest.AssertEqual("None", menu.invoke(0))
            AhkTest.AssertEqual("one", selected.get())
            AhkTest.AssertEqual("one", commandCalls[1][1])
            AhkTest.AssertEqual("one", commandCalls[1][2])
            AhkTest.AssertEqual("None", menu.invoke(2))
            AhkTest.AssertEqual("three", selected.get())
            AhkTest.AssertEqual("three", commandCalls[2][1])
            AhkTest.AssertEqual("three", commandCalls[2][2])

            singleValue := stdlib.tkinter.StringVar(root, "seed", "single_option_var")
            single := stdlib.tkinter.OptionMenu(root, singleValue, "solo")
            singleMenu := single["menu"]
            AhkTest.AssertEqual(0, singleMenu.index("end"))
            AhkTest.AssertEqual("solo", singleMenu.entrycget(0, "label"))
            AhkTest.AssertEqual("None", singleMenu.invoke(0))
            AhkTest.AssertEqual("solo", singleValue.get())

            AhkTest.AssertEqual(stdlib.None, option.destroy())
            AhkTest.AssertEqual("0", root.eval("winfo exists .!optionmenu"))
            AhkTest.RaisesMatch(TypeError, "^OptionMenu\.__init__\(\) missing 3 required positional arguments: 'master', 'variable', and 'value'$", (*) => stdlib.tkinter.OptionMenu())
            AhkTest.RaisesMatch(TypeError, "^OptionMenu\.__init__\(\) missing 2 required positional arguments: 'variable' and 'value'$", (*) => stdlib.tkinter.OptionMenu(root))
            AhkTest.RaisesMatch(TypeError, "^OptionMenu\.__init__\(\) missing 1 required positional argument: 'value'$", (*) => stdlib.tkinter.OptionMenu(root, selected))
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.OptionMenu(1, selected, "x"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^unknown option -bad$", (*) => stdlib.tkinter.OptionMenu(root, selected, "x", { bad: 1 }))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestPanedWindowPaneSashAndProxySurfaceMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            panes := stdlib.tkinter.PanedWindow(root, { name: "panes_probe", orient: "horizontal", sashwidth: 7, showhandle: 1 })
            left := stdlib.tkinter.Label(panes, { name: "left", text: "L" })
            right := stdlib.tkinter.Label(panes, { name: "right", text: "R" })

            AhkTest.AssertEqual(stdlib.None, panes.pack())
            AhkTest.AssertEqual(stdlib.None, panes.add(left, { minsize: 20, padx: 3, pady: 4, sticky: "nsew" }))
            AhkTest.AssertEqual(stdlib.None, panes.add(right, { minsize: 30 }))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())

            AhkTest.AssertTrue(panes is stdlib.tkinter.PanedWindow)
            AhkTest.AssertEqual(".panes_probe", String(panes))
            AhkTest.AssertSame(root, panes._root())
            AhkTest.AssertEqual(1, panes.winfo_exists())
            AhkTest.AssertEqual("Panedwindow", panes.winfo_class())
            AhkTest.AssertEqual("pack", panes.winfo_manager())
            AhkTest.AssertEqual("horizontal", panes.cget("orient"))
            AhkTest.AssertEqual(7, panes.cget("sashwidth"))
            AhkTest.AssertEqual(1, panes.cget("showhandle"))

            AhkTest.AssertEqual(stdlib.tuple([".panes_probe.left", ".panes_probe.right"]), panes.panes())
            AhkTest.AssertEqual(20, panes.panecget(left, "minsize"))
            AhkTest.AssertEqual(3, panes.panecget(left, "padx"))
            AhkTest.AssertEqual(4, panes.panecget(left, "pady"))
            AhkTest.AssertEqual("nesw", panes.panecget(left, "sticky"))

            minsizeConfig := panes.paneconfigure(left, "minsize")
            AhkTest.AssertEqual(5, minsizeConfig.Length)
            AhkTest.AssertEqual("minsize", minsizeConfig[1])
            AhkTest.AssertEqual("0", minsizeConfig[4])
            AhkTest.AssertEqual(20, minsizeConfig[5])
            AhkTest.AssertEqual(minsizeConfig, panes.paneconfig(left, "minsize"))
            paneConfig := panes.paneconfigure(left)
            AhkTest.AssertEqual(20, paneConfig["minsize"][5])
            AhkTest.AssertEqual(3, paneConfig["padx"][5])
            AhkTest.AssertEqual("nesw", paneConfig["sticky"][5])
            AhkTest.AssertEqual(stdlib.None, panes.paneconfigure(left, { minsize: 25 }))
            AhkTest.AssertEqual(25, panes.panecget(left, "minsize"))

            AhkTest.AssertEqual("", panes.identify(1, 1))
            proxyCoord := panes.proxy_coord()
            AhkTest.AssertEqual(2, proxyCoord.Length)
            AhkTest.AssertTrue(proxyCoord[1] is Integer)
            AhkTest.AssertTrue(proxyCoord[2] is Integer)
            AhkTest.AssertEqual(stdlib.tuple(), panes.proxy_place(5, 6))
            AhkTest.AssertEqual(2, panes.proxy_coord().Length)
            AhkTest.AssertEqual(stdlib.tuple(), panes.proxy_forget())
            AhkTest.AssertEqual(2, panes.sash_coord(0).Length)
            AhkTest.AssertEqual(2, panes.sash_mark(0).Length)
            AhkTest.AssertEqual(stdlib.tuple(), panes.sash_place(0, 20, 21))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => panes.paneconfigure(left, { bad: 1 }))

            AhkTest.AssertEqual(stdlib.None, panes.remove(left))
            AhkTest.AssertEqual(stdlib.tuple([".panes_probe.right"]), panes.panes())
            AhkTest.AssertEqual(stdlib.None, panes.forget(right))
            AhkTest.AssertEqual(stdlib.tuple(), panes.panes())
            AhkTest.AssertEqual(stdlib.None, panes.remove("missing"))

            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'tk'$", (*) => stdlib.tkinter.PanedWindow(1))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.__init__\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.tkinter.PanedWindow(root, {}, "extra"))
            AhkTest.RaisesMatch(TypeError, "^argument of type 'int' is not iterable$", (*) => stdlib.tkinter.PanedWindow(root, 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.PanedWindow(root, { bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.add\(\) missing 1 required positional argument: 'child'$", (*) => panes.add())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "missing"$', (*) => panes.add("missing"))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.remove\(\) missing 1 required positional argument: 'child'$", (*) => panes.remove())
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.identify\(\) missing 1 required positional argument: 'y'$", (*) => panes.identify(1))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.identify\(\) takes 3 positional arguments but 4 were given$", (*) => panes.identify(1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => panes.identify("bad", 1))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.panecget\(\) missing 2 required positional arguments: 'child' and 'option'$", (*) => panes.panecget())
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.panecget\(\) missing 1 required positional argument: 'option'$", (*) => panes.panecget(left))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "missing"$', (*) => panes.panecget("missing", "minsize"))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.paneconfigure\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => panes.paneconfigure(left, "minsize", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad window path name "missing"$', (*) => panes.paneconfigure("missing"))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.panes\(\) takes 1 positional argument but 2 were given$", (*) => panes.panes(1))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.proxy_coord\(\) takes 1 positional argument but 2 were given$", (*) => panes.proxy_coord(1))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.proxy_place\(\) missing 1 required positional argument: 'y'$", (*) => panes.proxy_place(1))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.proxy_place\(\) takes 3 positional arguments but 4 were given$", (*) => panes.proxy_place(1, 2, 3))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.sash_coord\(\) missing 1 required positional argument: 'index'$", (*) => panes.sash_coord())
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.sash_coord\(\) takes 2 positional arguments but 3 were given$", (*) => panes.sash_coord(0, 1))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => panes.sash_coord("bad"))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.sash_mark\(\) missing 1 required positional argument: 'index'$", (*) => panes.sash_mark())
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.sash_mark\(\) takes 2 positional arguments but 3 were given$", (*) => panes.sash_mark(0, 1))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.sash_place\(\) missing 1 required positional argument: 'y'$", (*) => panes.sash_place(0, 1))
            AhkTest.RaisesMatch(TypeError, "^PanedWindow\.sash_place\(\) takes 4 positional arguments but 5 were given$", (*) => panes.sash_place(0, 1, 2, 3))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestTkClipboardSurfaceMatchesLocal310()
    {
        oldClipboardWasRead := false
        try {
            oldClipboard := StdlibTkinterTest.ReadClipboardWithRetry()
            oldClipboardWasRead := true
        }
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
            if oldClipboardWasRead
                StdlibTkinterTest.WriteClipboardWithRetry(oldClipboard)
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

            AhkTest.AssertTrue(text is stdlib.tkinter.Text)
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
            AhkTest.AssertEqual(stdlib.None, text.delete("1.0", "end"))
            AhkTest.AssertEqual(stdlib.None, text.insert("1.0", "alpha beta gamma`nsecond line value`nthird line value`nfourth line value`nfifth line value`nsixth line value"))
            AhkTest.AssertEqual(stdlib.None, text.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertSame(stdlib.True, text.compare("1.0", "<", "1.1"))
            AhkTest.AssertSame(stdlib.True, text.compare("1.0", "<=", "1.1"))
            AhkTest.AssertSame(stdlib.False, text.compare("1.0", "==", "1.1"))
            AhkTest.AssertSame(stdlib.False, text.compare("1.0", ">=", "1.1"))
            AhkTest.AssertSame(stdlib.False, text.compare("1.0", ">", "1.1"))
            AhkTest.AssertSame(stdlib.True, text.compare("1.0", "!=", "1.1"))
            AhkTest.AssertSame(stdlib.True, text.compare("end", "==", "7.0"))
            AhkTest.AssertSame(stdlib.True, text.compare("end", "!=", "2.4"))
            AhkTest.AssertEqual(stdlib.tuple([104]), text.count("1.0", "end"))
            AhkTest.AssertEqual(stdlib.tuple([104]), text.count("1.0", "end", "chars"))
            AhkTest.AssertEqual(stdlib.tuple([6]), text.count("1.0", "end", "lines"))
            AhkTest.AssertEqual(stdlib.tuple([104, 6]), text.count("1.0", "end", "chars", "lines"))
            AhkTest.AssertEqual(stdlib.tuple([-104, -6]), text.count("end", "1.0", "chars", "lines"))
            AhkTest.AssertEqual(stdlib.tuple([104, 6]), text.count("1.0", "end", "displaychars", "displaylines"))
            AhkTest.AssertEqual(104, text.count("1.0", "end", "update", "chars"))
            AhkTest.AssertEqual(stdlib.tuple([104, 6]), text.count("1.0", "end", "update", "chars", "lines"))
            AhkTest.AssertEqual(stdlib.None, text.insert("end-1c", "`n-dash token"))
            searchCount := stdlib.tkinter.IntVar(root, 0, "search_count")
            ignoredSearchCount := stdlib.tkinter.IntVar(root, 0, "ignored_search_count")
            AhkTest.AssertEqual("1.6", text.search("beta", "1.0"))
            AhkTest.AssertEqual("", text.search("missing", "1.0"))
            AhkTest.AssertEqual("", text.search("gamma", "1.0", "1.10"))
            AhkTest.AssertEqual("1.11", text.search("gamma", "1.0", "2.0"))
            AhkTest.AssertEqual("1.0", text.search("alpha", "end", { forwards: stdlib.False, backwards: stdlib.False }))
            AhkTest.AssertEqual("1.0", text.search("ALPHA", "1.0", { nocase: stdlib.True }))
            AhkTest.AssertEqual("", text.search("ALPHA", "1.0", { nocase: stdlib.False }))
            AhkTest.AssertEqual("6.0", text.search("^sixth", "1.0", { regexp: stdlib.True }))
            AhkTest.AssertEqual("", text.search("^sixth", "1.0", { exact: stdlib.True }))
            AhkTest.AssertEqual("", text.search("alpha", "end", { backwards: stdlib.True, stopindex: "1.1" }))
            AhkTest.AssertEqual("1.0", text.search("alpha", "end", { backwards: stdlib.True }))
            AhkTest.AssertEqual("2.7", text.search("line", "1.0", { count: searchCount }))
            AhkTest.AssertEqual(4, searchCount.get())
            AhkTest.AssertEqual("2.7", text.search("line", "1.0", stdlib.None, stdlib.None, stdlib.None, stdlib.None, stdlib.None, stdlib.None, stdlib.False))
            AhkTest.AssertEqual(0, ignoredSearchCount.get())
            AhkTest.AssertEqual("7.0", text.search("-dash", "1.0"))
            editText := stdlib.tkinter.Text(root, { name: "edittext", undo: stdlib.True, width: 20, height: 4 })
            AhkTest.AssertSame(stdlib.False, editText.debug())
            AhkTest.AssertEqual(stdlib.None, editText.debug(stdlib.True))
            AhkTest.AssertSame(stdlib.True, editText.debug())
            AhkTest.AssertEqual(stdlib.None, editText.debug(stdlib.False))
            AhkTest.AssertSame(stdlib.False, editText.debug())
            AhkTest.AssertEqual(0, editText.edit_modified())
            AhkTest.AssertEqual(0, editText.edit_modified(stdlib.None))
            AhkTest.AssertEqual("", editText.edit_modified(stdlib.True))
            AhkTest.AssertEqual(1, editText.edit_modified())
            AhkTest.AssertEqual("", editText.edit_modified(stdlib.False))
            AhkTest.AssertEqual(0, editText.edit_modified())
            AhkTest.AssertEqual(0, editText.edit("canundo"))
            AhkTest.AssertEqual(0, editText.edit("canredo"))
            AhkTest.AssertEqual(stdlib.None, editText.insert("1.0", "alpha"))
            AhkTest.AssertEqual(1, editText.edit("canundo"))
            AhkTest.AssertEqual("", editText.edit_separator())
            AhkTest.AssertEqual(stdlib.None, editText.insert("end-1c", " beta"))
            AhkTest.AssertEqual("alpha beta", editText.get("1.0", "end-1c"))
            AhkTest.AssertEqual(1, editText.edit("canundo"))
            AhkTest.AssertEqual(0, editText.edit("canredo"))
            AhkTest.AssertEqual("", editText.edit_undo())
            AhkTest.AssertEqual("alpha", editText.get("1.0", "end-1c"))
            AhkTest.AssertEqual(1, editText.edit("canredo"))
            AhkTest.AssertEqual("", editText.edit_redo())
            AhkTest.AssertEqual("alpha beta", editText.get("1.0", "end-1c"))
            AhkTest.AssertEqual(1, editText.edit("modified", stdlib.None))
            AhkTest.AssertEqual("", editText.edit("modified", stdlib.False))
            AhkTest.AssertEqual(0, editText.edit("modified"))
            AhkTest.AssertEqual("", editText.edit("modified", stdlib.True))
            AhkTest.AssertEqual(1, editText.edit("modified"))
            AhkTest.AssertEqual("", editText.edit_reset())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^nothing to undo$", (*) => editText.edit_undo())
            textBbox := text.bbox("1.0")
            AhkTest.AssertEqual(4, textBbox.Length)
            AhkTest.AssertEqual(stdlib.None, text.bbox("end"))
            textLineInfo := text.dlineinfo("1.0")
            AhkTest.AssertEqual(5, textLineInfo.Length)
            AhkTest.AssertEqual(stdlib.None, text.dlineinfo("end"))
            AhkTest.AssertEqual(stdlib.None, text.see("6.0"))
            AhkTest.AssertEqual(stdlib.None, text.scan_mark(5, 5))
            AhkTest.AssertEqual(stdlib.None, text.scan_dragto(1, 1))
            AhkTest.AssertEqual(stdlib.None, text.xview_moveto(0.5))
            AhkTest.AssertEqual(stdlib.None, text.xview_scroll(1, "units"))
            AhkTest.AssertEqual(stdlib.None, text.xview("scroll", 1, "units"))
            AhkTest.AssertEqual(2, text.xview().Length)
            AhkTest.AssertEqual(stdlib.None, text.yview_moveto(0.5))
            AhkTest.AssertEqual(stdlib.None, text.yview_scroll(1, "units"))
            AhkTest.AssertEqual(stdlib.None, text.yview("scroll", 1, "units"))
            AhkTest.AssertEqual(2, text.yview().Length)
            pickText := stdlib.tkinter.Text(root, { name: "picktext", width: 20, height: 4 })
            AhkTest.AssertTrue(HasMethod(pickText, "yview_pickplace"))
            pickTextLines := ""
            Loop 30
                pickTextLines .= "line`n"
            AhkTest.AssertEqual(stdlib.None, pickText.insert("1.0", pickTextLines))
            AhkTest.AssertEqual(stdlib.None, pickText.pack())
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual("1.0", pickText.index("@0,0"))
            AhkTest.AssertEqual(stdlib.None, pickText.yview_pickplace("20.0"))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual("20.0", pickText.index("@0,0"))
            AhkTest.AssertEqual(stdlib.None, pickText.yview_pickplace("end"))
            AhkTest.AssertEqual(stdlib.None, root.update_idletasks())
            AhkTest.AssertEqual("31.0", pickText.index("@0,0"))
            AhkTest.AssertEqual(stdlib.None, text.mark_set("alpha", "1.2"))
            AhkTest.AssertEqual("1.2", text.index("alpha"))
            AhkTest.AssertEqual("right", text.mark_gravity("alpha"))
            AhkTest.AssertEqual("", text.mark_gravity("alpha", "left"))
            AhkTest.AssertEqual("left", text.mark_gravity("alpha"))
            AhkTest.AssertEqual(stdlib.None, text.mark_set("beta", "2.0"))
            AhkTest.AssertEqual(stdlib.None, text.mark_set("gamma", "end-1c"))
            textMarkNames := text.mark_names()
            AhkTest.AssertContains("alpha", textMarkNames)
            AhkTest.AssertContains("beta", textMarkNames)
            AhkTest.AssertContains("gamma", textMarkNames)
            AhkTest.AssertEqual("alpha", text.mark_next("1.0"))
            AhkTest.AssertEqual("beta", text.mark_next("alpha"))
            AhkTest.AssertEqual(stdlib.None, text.mark_previous("alpha"))
            AhkTest.AssertEqual(stdlib.None, text.mark_unset("alpha", "beta"))
            textMarkNamesAfterUnset := text.mark_names()
            AhkTest.AssertNotContains("alpha", textMarkNamesAfterUnset)
            AhkTest.AssertNotContains("beta", textMarkNamesAfterUnset)
            AhkTest.AssertContains("gamma", textMarkNamesAfterUnset)
            AhkTest.AssertEqual(stdlib.None, text.mark_unset())
            AhkTest.AssertEqual(stdlib.None, text.mark_unset("missing"))
            AhkTest.AssertContains("sel", text.tag_names())
            AhkTest.AssertEqual(stdlib.None, text.tag_add("emphasis", "1.0", "1.5"))
            AhkTest.AssertEqual(stdlib.None, text.tag_add("phrase", "1.6", "1.10", "2.0", "2.6"))
            AhkTest.AssertEqual(stdlib.tuple(["1.0", "1.5"]), text.tag_ranges("emphasis"))
            AhkTest.AssertEqual(stdlib.tuple(["1.6", "1.10", "2.0", "2.6"]), text.tag_ranges("phrase"))
            AhkTest.AssertEqual("", text.tag_cget("emphasis", "foreground"))
            AhkTest.AssertEqual(stdlib.None, text.tag_configure("emphasis", { foreground: "red", underline: 1 }))
            AhkTest.AssertEqual("red", text.tag_cget("emphasis", "foreground"))
            AhkTest.AssertEqual("red", text.tag_cget("emphasis", "-foreground"))
            AhkTest.AssertEqual("", text.tag_cget("emphasis", "bgstipple_"))
            textTagForegroundConfig := text.tag_configure("emphasis", "foreground")
            AhkTest.AssertEqual(stdlib.tuple(["foreground", "", "", "", "red"]), textTagForegroundConfig)
            textTagConfig := text.tag_configure("emphasis")
            AhkTest.AssertEqual(textTagForegroundConfig, textTagConfig["foreground"])
            AhkTest.AssertEqual(stdlib.tuple(["underline", "", "", "", "1"]), textTagConfig["underline"])
            AhkTest.AssertEqual(textTagForegroundConfig, text.tag_config("emphasis", "foreground"))
            AhkTest.AssertEqual(stdlib.None, text.tag_config("emphasis", { foreground: "blue" }))
            AhkTest.AssertEqual("blue", text.tag_cget("emphasis", "foreground"))
            AhkTest.AssertEqual(stdlib.tuple(), text.tag_bind("emphasis", stdlib.None, stdlib.None))
            AhkTest.AssertEqual("", text.tag_bind("emphasis", "<Button-1>", stdlib.None))
            textTagEvents := []
            textTagCommand := text.tag_bind("emphasis", "<Button-1>", (event) => (textTagEvents.Push(stdlib.tuple([event.type.name, event.x, event.y])), stdlib.None))
            AhkTest.AssertTrue(InStr(text.tag_bind("emphasis", "<Button-1>", stdlib.None), textTagCommand) > 0)
            AhkTest.AssertEqual("None", root.eval(textTagCommand " " String(text) " 4 7 8 1"))
            AhkTest.AssertEqual(stdlib.tuple([stdlib.tuple(["ButtonPress", 7, 8])]), stdlib.tuple(textTagEvents))
            AhkTest.AssertEqual(stdlib.None, text.tag_unbind("emphasis", "<Button-1>", textTagCommand))
            AhkTest.AssertEqual("", text.tag_bind("emphasis", "<Button-1>", stdlib.None))
            imageText := stdlib.tkinter.Text(root, { name: "imagetext", width: 10, height: 2 })
            AhkTest.AssertEqual(stdlib.None, imageText.insert("1.0", "alpha beta"))
            AhkTest.AssertEqual("", imageText.image_names())
            textImage := stdlib.tkinter.PhotoImage({ master: root, name: "text_photo_probe", width: 2, height: 2 })
            textImageName := imageText.image_create("1.1", { image: textImage, align: "center", padx: 3, pady: 4 })
            AhkTest.AssertEqual("text_photo_probe", textImageName)
            AhkTest.AssertEqual(stdlib.tuple(["text_photo_probe"]), imageText.image_names())
            AhkTest.AssertEqual("text_photo_probe", imageText.image_cget(textImageName, "image"))
            AhkTest.AssertEqual("center", imageText.image_cget(textImageName, "align"))
            AhkTest.AssertEqual(3, imageText.image_cget(textImageName, "padx"))
            AhkTest.AssertEqual(4, imageText.image_cget(textImageName, "-pady"))
            AhkTest.AssertEqual(stdlib.tuple(["align", "", "", "center", "center"]), imageText.image_configure(textImageName, "align"))
            textImageConfig := imageText.image_configure(textImageName)
            AhkTest.AssertEqual(stdlib.tuple(["image", "", "", "", "text_photo_probe"]), textImageConfig["image"])
            AhkTest.AssertEqual(stdlib.tuple(["padx", "", "", "0", 3]), textImageConfig["padx"])
            AhkTest.AssertEqual(stdlib.tuple(["pady", "", "", "0", 4]), textImageConfig["pady"])
            AhkTest.AssertEqual(stdlib.None, imageText.image_configure(textImageName, { padx: 5, pady: 6 }))
            AhkTest.AssertEqual(5, imageText.image_cget(textImageName, "padx"))
            AhkTest.AssertEqual(6, imageText.image_cget(textImageName, "pady"))
            generatedTextImageName := imageText.image_create("1.2", { image: textImage })
            AhkTest.AssertEqual("text_photo_probe#1", generatedTextImageName)
            AhkTest.AssertEqual(stdlib.tuple(["text_photo_probe#1", "text_photo_probe"]), imageText.image_names())
            AhkTest.AssertEqual(stdlib.tuple([stdlib.tuple(["image", "text_photo_probe", "1.1"]), stdlib.tuple(["image", "text_photo_probe#1", "1.2"])]), stdlib.tuple(imageText.dump("1.0", "end", { image: stdlib.True })))
            windowText := stdlib.tkinter.Text(root, { name: "windowtext", width: 10, height: 2 })
            AhkTest.AssertTrue(HasMethod(windowText, "window_names"))
            AhkTest.AssertEqual(stdlib.None, windowText.insert("1.0", "alpha beta"))
            embeddedLabel := stdlib.tkinter.Label(root, { name: "embedded_label", text: "Inside" })
            AhkTest.AssertEqual(stdlib.tuple(), windowText.window_names())
            AhkTest.AssertEqual(stdlib.None, windowText.window_create("1.1", { window: embeddedLabel, align: "center", padx: 3, pady: 4, stretch: 1 }))
            AhkTest.AssertEqual(stdlib.tuple([".embedded_label"]), windowText.window_names())
            AhkTest.AssertEqual(".embedded_label", windowText.window_cget("1.1", "window"))
            AhkTest.AssertEqual("center", windowText.window_cget("1.1", "align"))
            AhkTest.AssertEqual(3, windowText.window_cget("1.1", "padx"))
            AhkTest.AssertEqual(4, windowText.window_cget("1.1", "-pady"))
            AhkTest.AssertEqual(1, windowText.window_cget("1.1", "stretch"))
            AhkTest.AssertEqual(stdlib.tuple(["align", "", "", "center", "center"]), windowText.window_configure("1.1", "align"))
            windowConfig := windowText.window_configure("1.1")
            AhkTest.AssertEqual(stdlib.tuple(["window", "", "", "", ".embedded_label"]), windowConfig["window"])
            AhkTest.AssertEqual(stdlib.tuple(["padx", "", "", "0", 3]), windowConfig["padx"])
            AhkTest.AssertEqual(stdlib.tuple(["pady", "", "", "0", 4]), windowConfig["pady"])
            AhkTest.AssertEqual(stdlib.tuple(["stretch", "", "", "0", 1]), windowConfig["stretch"])
            AhkTest.AssertEqual(stdlib.tuple(["padx", "", "", "0", 3]), windowText.window_config("1.1", "padx"))
            AhkTest.AssertEqual(stdlib.None, windowText.window_configure("1.1", { padx: 5, pady: 6, stretch: 0 }))
            AhkTest.AssertEqual(5, windowText.window_cget("1.1", "padx"))
            AhkTest.AssertEqual(6, windowText.window_cget("1.1", "pady"))
            AhkTest.AssertEqual(0, windowText.window_cget("1.1", "stretch"))
            embeddedButton := stdlib.tkinter.Button(root, { name: "embedded_button", text: "Button" })
            AhkTest.AssertEqual(stdlib.None, windowText.window_create("1.2", { window: embeddedButton }))
            AhkTest.AssertEqual(stdlib.tuple([".embedded_button", ".embedded_label"]), windowText.window_names())
            AhkTest.AssertEqual(stdlib.tuple([stdlib.tuple(["window", ".embedded_label", "1.1"]), stdlib.tuple(["window", ".embedded_button", "1.2"])]), stdlib.tuple(windowText.dump("1.0", "end", { window: stdlib.True })))
            replaceText := stdlib.tkinter.Text(root, { name: "replacetext", width: 10, height: 2 })
            AhkTest.AssertTrue(HasMethod(replaceText, "replace"))
            AhkTest.AssertEqual(stdlib.None, replaceText.insert("1.0", "alpha beta"))
            AhkTest.AssertEqual(stdlib.None, replaceText.tag_configure("emphasis", { foreground: "red" }))
            AhkTest.AssertEqual(stdlib.None, replaceText.tag_add("emphasis", "1.0", "1.5"))
            AhkTest.AssertEqual(stdlib.None, replaceText.replace("1.6", "1.10", "GAMMA"))
            AhkTest.AssertEqual("alpha GAMMA", replaceText.get("1.0", "end-1c"))
            AhkTest.AssertEqual(stdlib.None, replaceText.replace("1.0", "1.0", ">>", "emphasis"))
            AhkTest.AssertEqual(">>alpha GAMMA", replaceText.get("1.0", "end-1c"))
            AhkTest.AssertEqual(stdlib.tuple(["1.0", "1.7"]), replaceText.tag_ranges("emphasis"))
            AhkTest.AssertEqual(stdlib.None, replaceText.replace("1.0", "1.2", ""))
            AhkTest.AssertEqual("alpha GAMMA", replaceText.get("1.0", "end-1c"))
            peerText := stdlib.tkinter.Text(root, { name: "peertextsource", width: 20, height: 4 })
            AhkTest.AssertTrue(HasMethod(peerText, "peer_create"))
            AhkTest.AssertTrue(HasMethod(peerText, "peer_names"))
            AhkTest.AssertEqual(stdlib.None, peerText.insert("1.0", "alpha beta"))
            AhkTest.AssertEqual(stdlib.tuple(), peerText.peer_names())
            AhkTest.AssertEqual(stdlib.None, peerText.peer_create(".peer_text", { width: 12, height: 3, wrap: "none" }))
            AhkTest.AssertEqual(stdlib.tuple([".peer_text"]), peerText.peer_names())
            AhkTest.AssertEqual("alpha beta", root.eval(".peer_text get 1.0 end-1c"))
            AhkTest.AssertEqual(12, Integer(root.eval(".peer_text cget -width")))
            AhkTest.AssertEqual(3, Integer(root.eval(".peer_text cget -height")))
            AhkTest.AssertEqual("none", root.eval(".peer_text cget -wrap"))
            AhkTest.AssertEqual(stdlib.None, peerText.insert("end-1c", " shared"))
            AhkTest.AssertEqual("alpha beta shared", root.eval(".peer_text get 1.0 end-1c"))
            AhkTest.AssertEqual("", root.eval(".peer_text insert end-1c { peer}"))
            AhkTest.AssertEqual("alpha beta shared peer", peerText.get("1.0", "end-1c"))
            AhkTest.AssertEqual(stdlib.None, peerText.peer_create(".peer_text2", { width: 9, height: 2 }))
            AhkTest.AssertEqual(stdlib.tuple([".peer_text2", ".peer_text"]), peerText.peer_names())
            AhkTest.AssertEqual(9, Integer(root.eval(".peer_text2 cget -width")))
            AhkTest.AssertEqual(2, Integer(root.eval(".peer_text2 cget -height")))
            AhkTest.AssertEqual(stdlib.tuple(["emphasis"]), text.tag_names("1.2"))
            AhkTest.AssertEqual(stdlib.tuple(["phrase"]), text.tag_names("2.1"))
            AhkTest.AssertEqual(stdlib.tuple(["1.6", "1.10"]), text.tag_nextrange("phrase", "1.0"))
            AhkTest.AssertEqual(stdlib.tuple(["2.0", "2.6"]), text.tag_nextrange("phrase", "1.11"))
            AhkTest.AssertEqual(stdlib.tuple(), text.tag_nextrange("phrase", "3.0"))
            AhkTest.AssertEqual(stdlib.tuple(["2.0", "2.6"]), text.tag_prevrange("phrase", "end"))
            AhkTest.AssertEqual(stdlib.tuple(["1.6", "1.10"]), text.tag_prevrange("phrase", "2.0"))
            AhkTest.AssertEqual(stdlib.tuple(), text.tag_prevrange("phrase", "1.0"))
            AhkTest.AssertEqual(stdlib.None, text.tag_remove("phrase", "1.6", "1.10"))
            AhkTest.AssertEqual(stdlib.tuple(["2.0", "2.6"]), text.tag_ranges("phrase"))
            AhkTest.AssertEqual(stdlib.None, text.tag_raise("phrase"))
            AhkTest.AssertEqual(stdlib.None, text.tag_lower("phrase", "emphasis"))
            dumpText := stdlib.tkinter.Text(root, { name: "dumptext", width: 20, height: 4 })
            AhkTest.AssertEqual(stdlib.None, dumpText.insert("1.0", "ab`ncd"))
            AhkTest.AssertEqual(stdlib.None, dumpText.mark_set("mymark", "1.1"))
            AhkTest.AssertEqual(stdlib.None, dumpText.tag_add("tagone", "1.0", "1.2"))
            AhkTest.AssertEqual(stdlib.None, dumpText.tag_add("tagtwo", "2.0", "2.2"))
            dumpAll := dumpText.dump("1.0", "end")
            AhkTest.AssertEqual(12, dumpAll.Length)
            AhkTest.AssertEqual(stdlib.tuple(["tagon", "tagone", "1.0"]), dumpAll[1])
            AhkTest.AssertEqual(stdlib.tuple(["text", "a", "1.0"]), dumpAll[2])
            AhkTest.AssertEqual(stdlib.tuple(["mark", "mymark", "1.1"]), dumpAll[3])
            AhkTest.AssertEqual(stdlib.tuple(["text", "b", "1.1"]), dumpAll[4])
            AhkTest.AssertEqual(stdlib.tuple(["tagoff", "tagone", "1.2"]), dumpAll[5])
            AhkTest.AssertEqual(stdlib.tuple(["text", "`n", "1.2"]), dumpAll[6])
            AhkTest.AssertEqual(stdlib.tuple(["tagon", "tagtwo", "2.0"]), dumpAll[7])
            AhkTest.AssertEqual(stdlib.tuple(["text", "cd", "2.0"]), dumpAll[8])
            AhkTest.AssertEqual(stdlib.tuple(["tagoff", "tagtwo", "2.2"]), dumpAll[9])
            AhkTest.AssertEqual(stdlib.tuple(["text", "`n", "2.2"]), dumpAll[12])
            AhkTest.AssertEqual(stdlib.tuple([stdlib.tuple(["tagon", "tagone", "1.0"]), stdlib.tuple(["text", "a", "1.0"])]), stdlib.tuple(dumpText.dump("1.0")))
            dumpTextOnly := dumpText.dump("1.0", "end", { text: stdlib.True })
            AhkTest.AssertEqual(stdlib.tuple(["text", "a", "1.0"]), dumpTextOnly[1])
            AhkTest.AssertEqual(stdlib.tuple(["text", "cd", "2.0"]), dumpTextOnly[4])
            AhkTest.AssertEqual(5, dumpTextOnly.Length)
            dumpTagOnly := dumpText.dump("1.0", "end", { tag: stdlib.True })
            AhkTest.AssertEqual(stdlib.tuple([stdlib.tuple(["tagon", "tagone", "1.0"]), stdlib.tuple(["tagoff", "tagone", "1.2"]), stdlib.tuple(["tagon", "tagtwo", "2.0"]), stdlib.tuple(["tagoff", "tagtwo", "2.2"])]), stdlib.tuple(dumpTagOnly))
            dumpMarkOnly := dumpText.dump("1.0", "end", { mark: stdlib.True })
            AhkTest.AssertEqual(stdlib.tuple(["mark", "mymark", "1.1"]), dumpMarkOnly[1])
            AhkTest.AssertEqual(3, dumpMarkOnly.Length)
            AhkTest.AssertEqual(12, dumpText.dump("1.0", "end", { all: stdlib.True, text: stdlib.False }).Length)
            dumpCalls := []
            dumpReturn := dumpText.dump("1.0", "1.2", (kind, value, index) => dumpCalls.Push(stdlib.tuple([kind, value, index])))
            AhkTest.AssertEqual(stdlib.None, dumpReturn)
            AhkTest.AssertEqual(stdlib.tuple([stdlib.tuple(["tagon", "tagone", "1.0"]), stdlib.tuple(["text", "a", "1.0"]), stdlib.tuple(["mark", "mymark", "1.1"]), stdlib.tuple(["text", "b", "1.1"])]), stdlib.tuple(dumpCalls))
            AhkTest.AssertEqual(stdlib.None, text.tag_delete("phrase", "missing"))
            AhkTest.AssertEqual(stdlib.tuple(), text.tag_ranges("phrase"))
            AhkTest.AssertContains("emphasis", text.tag_names())
            AhkTest.AssertNotContains("phrase", text.tag_names())
            AhkTest.RaisesMatch(TypeError, "^Text\.insert\(\) missing 2 required positional arguments: 'index' and 'chars'$", (*) => text.insert())
            AhkTest.RaisesMatch(TypeError, "^Text\.insert\(\) missing 1 required positional argument: 'chars'$", (*) => text.insert("1.0"))
            AhkTest.RaisesMatch(TypeError, "^Text\.get\(\) missing 1 required positional argument: 'index1'$", (*) => text.get())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.get("bad", "end"))
            AhkTest.RaisesMatch(TypeError, "^Text\.delete\(\) missing 1 required positional argument: 'index1'$", (*) => text.delete())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.delete("bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.index\(\) missing 1 required positional argument: 'index'$", (*) => text.index())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.index("bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.compare\(\) missing 3 required positional arguments: 'index1', 'op', and 'index2'$", (*) => text.compare())
            AhkTest.RaisesMatch(TypeError, "^Text\.compare\(\) missing 2 required positional arguments: 'op' and 'index2'$", (*) => text.compare("1.0"))
            AhkTest.RaisesMatch(TypeError, "^Text\.compare\(\) missing 1 required positional argument: 'index2'$", (*) => text.compare("1.0", "<"))
            AhkTest.RaisesMatch(TypeError, "^Text\.compare\(\) takes 4 positional arguments but 5 were given$", (*) => text.compare("1.0", "<", "1.1", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.compare("bad", "<", "1.1"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.compare("1.0", "<", "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad comparison operator "bad": must be <, <=, ==, >=, >, or !=$', (*) => text.compare("1.0", "bad", "1.1"))
            AhkTest.RaisesMatch(TypeError, "^Text\.count\(\) missing 2 required positional arguments: 'index1' and 'index2'$", (*) => text.count())
            AhkTest.RaisesMatch(TypeError, "^Text\.count\(\) missing 1 required positional argument: 'index2'$", (*) => text.count("1.0"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.count("bad", "end", "chars"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.count("1.0", "bad", "chars"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad option "-bad" must be -chars, -displaychars, -displayindices, -displaylines, -indices, -lines, -update, -xpixels, or -ypixels$', (*) => text.count("1.0", "end", "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad option "--chars" must be -chars, -displaychars, -displayindices, -displaylines, -indices, -lines, -update, -xpixels, or -ypixels$', (*) => text.count("1.0", "end", "-chars"))
            AhkTest.RaisesMatch(TypeError, "^Text\.search\(\) missing 2 required positional arguments: 'pattern' and 'index'$", (*) => text.search())
            AhkTest.RaisesMatch(TypeError, "^Text\.search\(\) missing 1 required positional argument: 'index'$", (*) => text.search("alpha"))
            AhkTest.RaisesMatch(TypeError, "^Text\.search\(\) takes from 3 to 11 positional arguments but 12 were given$", (*) => text.search("alpha", "1.0", stdlib.None, stdlib.None, stdlib.None, stdlib.None, stdlib.None, stdlib.None, stdlib.None, stdlib.None, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Text\.search\(\) got an unexpected keyword argument 'extra'$", (*) => text.search("alpha", "1.0", { extra: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Text\.search\(\) got multiple values for argument 'stopindex'$", (*) => text.search("alpha", "1.0", "end", { stopindex: "end" }))
            AhkTest.RaisesMatch(TypeError, "^Text\.search\(\) got multiple values for argument 'count'$", (*) => text.search("alpha", "1.0", stdlib.None, stdlib.None, stdlib.None, stdlib.None, stdlib.None, stdlib.None, searchCount, { count: searchCount }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.search("alpha", "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.search("alpha", "1.0", "bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^couldn't compile regular expression pattern: brackets \[\] not balanced$", (*) => text.search("[", "1.0", { regexp: stdlib.True }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.picktext yview -pickplace lineNum\|index"$', (*) => pickText.yview_pickplace())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => pickText.yview_pickplace("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.picktext yview -pickplace lineNum\|index"$', (*) => pickText.yview_pickplace("1.0", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Text\.debug\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => editText.debug(stdlib.True, stdlib.False))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected boolean value but got "bad"$', (*) => editText.debug("bad"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.edittext edit option \?arg \.\.\.\?"$', (*) => editText.edit())
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad edit option "bogus": must be canundo, canredo, modified, redo, reset, separator, or undo$', (*) => editText.edit("bogus"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^wrong # args: should be "\.edittext edit modified \?boolean\?"$', (*) => editText.edit("modified", stdlib.True, stdlib.False))
            AhkTest.RaisesMatch(TypeError, "^Text\.edit_modified\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => editText.edit_modified(stdlib.True, stdlib.False))
            AhkTest.RaisesMatch(TypeError, "^Text\.edit_undo\(\) takes 1 positional argument but 2 were given$", (*) => editText.edit_undo("extra"))
            AhkTest.RaisesMatch(TypeError, "^Text\.edit_redo\(\) takes 1 positional argument but 2 were given$", (*) => editText.edit_redo("extra"))
            AhkTest.RaisesMatch(TypeError, "^Text\.edit_reset\(\) takes 1 positional argument but 2 were given$", (*) => editText.edit_reset("extra"))
            AhkTest.RaisesMatch(TypeError, "^Text\.edit_separator\(\) takes 1 positional argument but 2 were given$", (*) => editText.edit_separator("extra"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_cget\(\) missing 2 required positional arguments: 'tagName' and 'option'$", (*) => text.tag_cget())
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_cget\(\) missing 1 required positional argument: 'option'$", (*) => text.tag_cget("emphasis"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_cget\(\) takes 3 positional arguments but 4 were given$", (*) => text.tag_cget("emphasis", "foreground", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => text.tag_cget("emphasis", "bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_configure\(\) missing 1 required positional argument: 'tagName'$", (*) => text.tag_configure())
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_configure\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => text.tag_configure("emphasis", {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => text.tag_configure("emphasis", { bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_bind\(\) missing 3 required positional arguments: 'tagName', 'sequence', and 'func'$", (*) => text.tag_bind())
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_bind\(\) missing 2 required positional arguments: 'sequence' and 'func'$", (*) => text.tag_bind("emphasis"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_bind\(\) missing 1 required positional argument: 'func'$", (*) => text.tag_bind("emphasis", "<Button-1>"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_bind\(\) takes from 4 to 5 positional arguments but 6 were given$", (*) => text.tag_bind("emphasis", "<Button-1>", (event) => stdlib.None, "+", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_unbind\(\) missing 2 required positional arguments: 'tagName' and 'sequence'$", (*) => text.tag_unbind())
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_unbind\(\) missing 1 required positional argument: 'sequence'$", (*) => text.tag_unbind("emphasis"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_unbind\(\) takes from 3 to 4 positional arguments but 5 were given$", (*) => text.tag_unbind("emphasis", "<Button-1>", "id", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^can't delete Tcl command$", (*) => text.tag_unbind("emphasis", "<Button-1>", "missingCommand"))
            AhkTest.RaisesMatch(TypeError, "^Text\.image_create\(\) missing 1 required positional argument: 'index'$", (*) => imageText.image_create())
            AhkTest.RaisesMatch(TypeError, "^Text\.image_create\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => imageText.image_create("1.0", {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => imageText.image_create("bad", { image: textImage }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => imageText.image_create("1.0", { bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Text\.image_cget\(\) missing 2 required positional arguments: 'index' and 'option'$", (*) => imageText.image_cget())
            AhkTest.RaisesMatch(TypeError, "^Text\.image_cget\(\) missing 1 required positional argument: 'option'$", (*) => imageText.image_cget(textImageName))
            AhkTest.RaisesMatch(TypeError, "^Text\.image_cget\(\) takes 3 positional arguments but 4 were given$", (*) => imageText.image_cget(textImageName, "image", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "missing_image"$', (*) => imageText.image_cget("missing_image", "image"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => imageText.image_cget(textImageName, "bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.image_configure\(\) missing 1 required positional argument: 'index'$", (*) => imageText.image_configure())
            AhkTest.RaisesMatch(TypeError, "^Text\.image_configure\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => imageText.image_configure(textImageName, {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "missing_image"$', (*) => imageText.image_configure("missing_image"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => imageText.image_configure(textImageName, { bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Text\.image_names\(\) takes 1 positional argument but 2 were given$", (*) => imageText.image_names(1))
            AhkTest.RaisesMatch(TypeError, "^Text\.window_create\(\) missing 1 required positional argument: 'index'$", (*) => windowText.window_create())
            AhkTest.RaisesMatch(TypeError, "^Text\.window_create\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => windowText.window_create("1.0", {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => windowText.window_create("bad", { window: embeddedLabel }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => windowText.window_create("1.0", { bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Text\.window_cget\(\) missing 2 required positional arguments: 'index' and 'option'$", (*) => windowText.window_cget())
            AhkTest.RaisesMatch(TypeError, "^Text\.window_cget\(\) missing 1 required positional argument: 'option'$", (*) => windowText.window_cget("1.1"))
            AhkTest.RaisesMatch(TypeError, "^Text\.window_cget\(\) takes 3 positional arguments but 4 were given$", (*) => windowText.window_cget("1.1", "window", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "missing_window"$', (*) => windowText.window_cget("missing_window", "window"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => windowText.window_cget("1.1", "bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.window_configure\(\) missing 1 required positional argument: 'index'$", (*) => windowText.window_configure())
            AhkTest.RaisesMatch(TypeError, "^Text\.window_configure\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => windowText.window_configure("1.1", {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "missing_window"$', (*) => windowText.window_configure("missing_window"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => windowText.window_configure("1.1", { bad: 1 }))
            AhkTest.RaisesMatch(TypeError, "^Text\.window_names\(\) takes 1 positional argument but 2 were given$", (*) => windowText.window_names(1))
            AhkTest.RaisesMatch(TypeError, "^Text\.replace\(\) missing 3 required positional arguments: 'index1', 'index2', and 'chars'$", (*) => replaceText.replace())
            AhkTest.RaisesMatch(TypeError, "^Text\.replace\(\) missing 2 required positional arguments: 'index2' and 'chars'$", (*) => replaceText.replace("1.0"))
            AhkTest.RaisesMatch(TypeError, "^Text\.replace\(\) missing 1 required positional argument: 'chars'$", (*) => replaceText.replace("1.0", "1.1"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => replaceText.replace("bad", "1.1", "x"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => replaceText.replace("1.0", "bad", "x"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^index "1.3" before "1.8" in the text$', (*) => replaceText.replace("1.8", "1.3", "X"))
            AhkTest.RaisesMatch(TypeError, "^Text\.peer_create\(\) missing 1 required positional argument: 'newPathName'$", (*) => peerText.peer_create())
            AhkTest.RaisesMatch(TypeError, "^Text\.peer_create\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => peerText.peer_create(".extra_peer", {}, "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => peerText.peer_create(".bad_peer", { bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^window name "peer_text" already exists in parent$', (*) => peerText.peer_create(".peer_text"))
            AhkTest.RaisesMatch(TypeError, "^Text\.peer_names\(\) takes 1 positional argument but 2 were given$", (*) => peerText.peer_names(1))
            AhkTest.RaisesMatch(TypeError, "^Text\.dump\(\) missing 1 required positional argument: 'index1'$", (*) => dumpText.dump())
            AhkTest.RaisesMatch(TypeError, "^Text\.dump\(\) takes from 2 to 4 positional arguments but 5 were given$", (*) => dumpText.dump("1.0", "end", (kind, value, index) => stdlib.None, "extra"))
            AhkTest.RaisesMatch(TypeError, "^Text\.dump\(\) got multiple values for argument 'index2'$", (*) => dumpText.dump("1.0", "end", { index2: "end" }))
            AhkTest.RaisesMatch(TypeError, "^Text\.dump\(\) got multiple values for argument 'command'$", (*) => dumpText.dump("1.0", "end", (kind, value, index) => stdlib.None, { command: (kind, value, index) => stdlib.None }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad option "-bad": must be -all, -command, -image, -mark, -tag, -text, or -window$', (*) => dumpText.dump("1.0", "end", { bad: stdlib.True }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => dumpText.dump("bad", "end"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => dumpText.dump("1.0", "bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.bbox\(\) missing 1 required positional argument: 'index'$", (*) => text.bbox())
            AhkTest.RaisesMatch(TypeError, "^Text\.bbox\(\) takes 2 positional arguments but 3 were given$", (*) => text.bbox("1.0", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.bbox("bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.dlineinfo\(\) missing 1 required positional argument: 'index'$", (*) => text.dlineinfo())
            AhkTest.RaisesMatch(TypeError, "^Text\.dlineinfo\(\) takes 2 positional arguments but 3 were given$", (*) => text.dlineinfo("1.0", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.dlineinfo("bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.see\(\) missing 1 required positional argument: 'index'$", (*) => text.see())
            AhkTest.RaisesMatch(TypeError, "^Text\.see\(\) takes 2 positional arguments but 3 were given$", (*) => text.see("1.0", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.see("bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.scan_mark\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => text.scan_mark())
            AhkTest.RaisesMatch(TypeError, "^Text\.scan_mark\(\) missing 1 required positional argument: 'y'$", (*) => text.scan_mark(1))
            AhkTest.RaisesMatch(TypeError, "^Text\.scan_mark\(\) takes 3 positional arguments but 4 were given$", (*) => text.scan_mark(1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => text.scan_mark("bad", 1))
            AhkTest.RaisesMatch(TypeError, "^Text\.scan_dragto\(\) missing 2 required positional arguments: 'x' and 'y'$", (*) => text.scan_dragto())
            AhkTest.RaisesMatch(TypeError, "^Text\.scan_dragto\(\) missing 1 required positional argument: 'y'$", (*) => text.scan_dragto(1))
            AhkTest.RaisesMatch(TypeError, "^Text\.scan_dragto\(\) takes 3 positional arguments but 4 were given$", (*) => text.scan_dragto(1, 2, 3))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^expected integer but got "bad"$', (*) => text.scan_dragto(1, "bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.mark_set\(\) missing 2 required positional arguments: 'markName' and 'index'$", (*) => text.mark_set())
            AhkTest.RaisesMatch(TypeError, "^Text\.mark_set\(\) missing 1 required positional argument: 'index'$", (*) => text.mark_set("alpha"))
            AhkTest.RaisesMatch(TypeError, "^Text\.mark_set\(\) takes 3 positional arguments but 4 were given$", (*) => text.mark_set("alpha", "1.0", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.mark_set("alpha", "bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.mark_gravity\(\) missing 1 required positional argument: 'markName'$", (*) => text.mark_gravity())
            AhkTest.RaisesMatch(TypeError, "^Text\.mark_gravity\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => text.mark_gravity("alpha", "left", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^there is no mark named "missing"$', (*) => text.mark_gravity("missing"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad mark gravity "bad": must be left or right$', (*) => text.mark_gravity("gamma", "bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.mark_names\(\) takes 1 positional argument but 2 were given$", (*) => text.mark_names(1))
            AhkTest.RaisesMatch(TypeError, "^Text\.mark_next\(\) missing 1 required positional argument: 'index'$", (*) => text.mark_next())
            AhkTest.RaisesMatch(TypeError, "^Text\.mark_next\(\) takes 2 positional arguments but 3 were given$", (*) => text.mark_next("1.0", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.mark_next("bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.mark_previous\(\) missing 1 required positional argument: 'index'$", (*) => text.mark_previous())
            AhkTest.RaisesMatch(TypeError, "^Text\.mark_previous\(\) takes 2 positional arguments but 3 were given$", (*) => text.mark_previous("1.0", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.mark_previous("bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_add\(\) missing 2 required positional arguments: 'tagName' and 'index1'$", (*) => text.tag_add())
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_add\(\) missing 1 required positional argument: 'index1'$", (*) => text.tag_add("tag"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.tag_add("tag", "bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_remove\(\) missing 2 required positional arguments: 'tagName' and 'index1'$", (*) => text.tag_remove())
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_remove\(\) missing 1 required positional argument: 'index1'$", (*) => text.tag_remove("tag"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.tag_remove("tag", "bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_ranges\(\) missing 1 required positional argument: 'tagName'$", (*) => text.tag_ranges())
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_ranges\(\) takes 2 positional arguments but 3 were given$", (*) => text.tag_ranges("tag", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_names\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => text.tag_names("1.0", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.tag_names("bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_nextrange\(\) missing 2 required positional arguments: 'tagName' and 'index1'$", (*) => text.tag_nextrange())
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_nextrange\(\) missing 1 required positional argument: 'index1'$", (*) => text.tag_nextrange("tag"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_nextrange\(\) takes from 3 to 4 positional arguments but 5 were given$", (*) => text.tag_nextrange("tag", "1.0", "end", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.tag_nextrange("tag", "bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_prevrange\(\) missing 2 required positional arguments: 'tagName' and 'index1'$", (*) => text.tag_prevrange())
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_prevrange\(\) missing 1 required positional argument: 'index1'$", (*) => text.tag_prevrange("tag"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_prevrange\(\) takes from 3 to 4 positional arguments but 5 were given$", (*) => text.tag_prevrange("tag", "end", "1.0", "extra"))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^bad text index "bad"$', (*) => text.tag_prevrange("tag", "bad"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_raise\(\) missing 1 required positional argument: 'tagName'$", (*) => text.tag_raise())
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_raise\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => text.tag_raise("tag", "above", "extra"))
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_lower\(\) missing 1 required positional argument: 'tagName'$", (*) => text.tag_lower())
            AhkTest.RaisesMatch(TypeError, "^Text\.tag_lower\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => text.tag_lower("tag", "below", "extra"))
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

            AhkTest.AssertTrue(image is stdlib.tkinter.PhotoImage)
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
            AhkTest.AssertTrue(dupImage is stdlib.tkinter.PhotoImage)
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

    static TestImagePublicClassMatchesLocal310()
    {
        AhkTest.AssertTrue(HasMethod(stdlib.tkinter, "Image"))
        AhkTest.RaisesMatch(TypeError, "^Image\.__init__\(\) missing 1 required positional argument: 'imgtype'$", (*) => stdlib.tkinter.Image())
        AhkTest.RaisesMatch(TypeError, "^Image\.__init__\(\) takes from 2 to 5 positional arguments but 6 were given$", (*) => stdlib.tkinter.Image("photo", stdlib.None, {}, stdlib.None, "extra"))
        AhkTest.RaisesMatch(RuntimeError, "^Too early to create image: no default root window$", (*) => stdlib.tkinter.Image("photo"))

        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            image := stdlib.tkinter.Image("photo", "public_image_probe", { width: 2, height: 3 }, root)
            AhkTest.AssertTrue(image is stdlib.tkinter.Image)
            AhkTest.AssertEqual("public_image_probe", String(image))
            AhkTest.AssertEqual("photo", image.type())
            AhkTest.AssertEqual(2, image.width())
            AhkTest.AssertEqual(3, image.height())
            AhkTest.AssertContains("public_image_probe", root.image_names())

            generated := stdlib.tkinter.Image("photo", stdlib.None, { width: 2, height: 3 }, root)
            AhkTest.AssertRegex(String(generated), "^" Chr(112) Chr(121) "image\d+$")
            AhkTest.AssertEqual("photo", generated.type())
            AhkTest.AssertEqual(2, generated.width())
            AhkTest.AssertEqual(3, generated.height())
            AhkTest.AssertContains(String(generated), root.image_names())

            bitmap := stdlib.tkinter.Image("bitmap", stdlib.None, {}, root)
            AhkTest.AssertTrue(bitmap is stdlib.tkinter.Image)
            AhkTest.AssertEqual("bitmap", bitmap.type())
            AhkTest.AssertEqual(0, bitmap.width())
            AhkTest.AssertEqual(0, bitmap.height())

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^image type " Chr(34) "badtype" Chr(34) " doesn't exist$", (*) => stdlib.tkinter.Image("badtype", stdlib.None, {}, root))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.Image("photo", stdlib.None, { bad: 1 }, root))
            AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'items'$", (*) => stdlib.tkinter.Image("photo", stdlib.None, "bad", root))
            AhkTest.RaisesMatch(AttributeError, "^'str' object has no attribute 'call'$", (*) => stdlib.tkinter.Image("photo", stdlib.None, {}, "bad"))
        } finally {
            try root.update_idletasks()
            try root.destroy()
        }
    }

    static TestBitmapImageDataFileAndWidgetSurfaceMatchesLocal310()
    {
        bitmapPath := A_Temp "\stdlib-tkinter-bitmap-" A_TickCount "-" Random(100000, 999999) ".xbm"
        bitmapData := "#define stdlib_width 2`n#define stdlib_height 2`nstatic unsigned char stdlib_bits[] = { 0x01, 0x02 };`n"
        root := stdlib.tkinter.Tk()
        try {
            root.eval("wm withdraw .")
            image := stdlib.tkinter.BitmapImage({ master: root, name: "bitmap_probe", data: bitmapData, foreground: "red", background: "white" })

            AhkTest.AssertTrue(image is stdlib.tkinter.BitmapImage)
            AhkTest.AssertEqual("bitmap_probe", String(image))
            AhkTest.AssertEqual(2, image.width())
            AhkTest.AssertEqual(2, image.height())
            AhkTest.AssertEqual("bitmap", image.type())
            AhkTest.AssertEqual(stdlib.None, image.configure({ foreground: "blue" }))
            AhkTest.AssertEqual(2, image.width())
            AhkTest.AssertEqual(2, image.height())

            label := stdlib.tkinter.Label(root, { image: image })
            AhkTest.AssertEqual("bitmap_probe", label.cget("image"))
            AhkTest.AssertContains("bitmap_probe", root.image_names())

            try FileDelete bitmapPath
            FileAppend bitmapData, bitmapPath, "UTF-8-RAW"
            fileImage := stdlib.tkinter.BitmapImage({ master: root, name: "bitmap_file_probe", file: bitmapPath })
            AhkTest.AssertTrue(fileImage is stdlib.tkinter.BitmapImage)
            AhkTest.AssertEqual(2, fileImage.width())
            AhkTest.AssertEqual(2, fileImage.height())
            AhkTest.AssertEqual("bitmap", fileImage.type())
            AhkTest.AssertContains("bitmap_file_probe", root.image_names())

            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'call'$", (*) => stdlib.tkinter.BitmapImage({ master: 1, data: bitmapData }))
            AhkTest.RaisesMatch(TypeError, "^BitmapImage\.__init__\(\) takes from 1 to 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.BitmapImage("a", {}, root, "extra"))
            AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'items'$", (*) => stdlib.tkinter.BitmapImage("a", 1, root))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, '^unknown option "-bad"$', (*) => stdlib.tkinter.BitmapImage({ master: root, bad: 1 }))
            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "^format error in bitmap data$", (*) => stdlib.tkinter.BitmapImage({ master: root, data: "bad" }))
            AhkTest.RaisesMatch(TypeError, "^Image\.width\(\) takes 1 positional argument but 2 were given$", (*) => image.width(1))
            AhkTest.RaisesMatch(TypeError, "^Image\.height\(\) takes 1 positional argument but 2 were given$", (*) => image.height(1))
            AhkTest.RaisesMatch(TypeError, "^Image\.type\(\) takes 1 positional argument but 2 were given$", (*) => image.type(1))
            AhkTest.RaisesMatch(TypeError, "^Image\.configure\(\) takes 1 positional argument but 3 were given$", (*) => image.configure({}, {}))
        } finally {
            try root.update_idletasks()
            try root.destroy()
            try FileDelete bitmapPath
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

            AhkTest.AssertTrue(canvas is stdlib.tkinter.Canvas)
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
        AhkTest.RaisesMatch(RuntimeError, "^Too early to create variable: no default root window$", (*) => stdlib.tkinter.Variable())
        AhkTest.RaisesMatch(RuntimeError, "^Too early to create variable: no default root window$", (*) => stdlib.tkinter.StringVar())
        AhkTest.RaisesMatch(RuntimeError, "^Too early to create variable: no default root window$", (*) => stdlib.tkinter.IntVar())
        AhkTest.RaisesMatch(RuntimeError, "^Too early to create variable: no default root window$", (*) => stdlib.tkinter.DoubleVar())
        AhkTest.RaisesMatch(RuntimeError, "^Too early to create variable: no default root window$", (*) => stdlib.tkinter.BooleanVar())
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
        defaultVariable := stdlib.tkinter.Variable()
        AhkTest.AssertEqual("", defaultVariable.get())
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '_root'$", (*) => stdlib.tkinter.Variable({ master: 1 }))
        AhkTest.RaisesMatch(TypeError, "^Variable\.__init__\(\) got an unexpected keyword argument 'extra'$", (*) => stdlib.tkinter.Variable({ master: interp, extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "^Variable\.__init__\(\) takes from 1 to 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.Variable(interp, "seed", "custom_var", "extra"))
        AhkTest.RaisesMatch(TypeError, "^name must be a string$", (*) => stdlib.tkinter.Variable({ master: interp, name: 1 }))
        AhkTest.AssertEqual("", stdlib.tkinter.StringVar().get())
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '_root'$", (*) => stdlib.tkinter.StringVar({ master: 1 }))
        AhkTest.RaisesMatch(TypeError, "^StringVar\.__init__\(\) got an unexpected keyword argument 'extra'$", (*) => stdlib.tkinter.StringVar({ master: interp, extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "^StringVar\.__init__\(\) takes from 1 to 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.StringVar(interp, "seed", "custom_name", "extra"))
        AhkTest.RaisesMatch(TypeError, "^name must be a string$", (*) => stdlib.tkinter.StringVar({ master: interp, name: 1 }))
        AhkTest.AssertEqual(0, stdlib.tkinter.IntVar().get())
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '_root'$", (*) => stdlib.tkinter.IntVar({ master: 1 }))
        AhkTest.RaisesMatch(TypeError, "^IntVar\.__init__\(\) got an unexpected keyword argument 'extra'$", (*) => stdlib.tkinter.IntVar({ master: interp, extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "^IntVar\.__init__\(\) takes from 1 to 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.IntVar(interp, 1, "custom_int", "extra"))
        AhkTest.RaisesMatch(TypeError, "^name must be a string$", (*) => stdlib.tkinter.IntVar({ master: interp, name: 1 }))
        AhkTest.AssertEqual(0.0, stdlib.tkinter.DoubleVar().get())
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute '_root'$", (*) => stdlib.tkinter.DoubleVar({ master: 1 }))
        AhkTest.RaisesMatch(TypeError, "^DoubleVar\.__init__\(\) got an unexpected keyword argument 'extra'$", (*) => stdlib.tkinter.DoubleVar({ master: interp, extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "^DoubleVar\.__init__\(\) takes from 1 to 4 positional arguments but 5 were given$", (*) => stdlib.tkinter.DoubleVar(interp, 1, "custom_double", "extra"))
        AhkTest.RaisesMatch(TypeError, "^name must be a string$", (*) => stdlib.tkinter.DoubleVar({ master: interp, name: 1 }))
        AhkTest.AssertSame(stdlib.False, stdlib.tkinter.BooleanVar().get())
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

    class CallWrapperWidgetProbe
    {
        __New()
        {
            this.Reports := []
        }

        _report_exception()
        {
            this.Reports.Push("reported")
        }
    }

    static RuntimeLibDir()
    {
        SplitPath A_LineFile, , &testsDir
        stdlibDir := RegExReplace(testsDir, "\\tests$")
        return stdlibDir "\tkinter\lib"
    }

    static TkinterModuleConstant(name)
    {
        return stdlib.tkinter.%name%
    }

    static TkinterModuleCall(name, args*)
    {
        return stdlib.tkinter.%name%(args*)
    }

    static CallObjectMethod(instance, name, args*)
    {
        return instance.%name%(args*)
    }

    static JoinCallWrapperArgs(args*)
    {
        text := ""
        for index, value in args {
            if index > 1
                text .= "|"
            text .= value
        }
        return text
    }

    static ReadClipboardWithRetry()
    {
        lastError := Error("Can't open clipboard for reading.")
        Loop 8 {
            try return A_Clipboard
            catch as err {
                lastError := err
                Sleep 50
            }
        }
        throw lastError
    }

    static WriteClipboardWithRetry(value)
    {
        lastError := Error("Can't open clipboard for writing.")
        Loop 8 {
            try {
                A_Clipboard := value
                return stdlib.None
            } catch as err {
                lastError := err
                Sleep 50
            }
        }
        throw lastError
    }

    static ThrowCallbackError(message)
    {
        throw Error(message, -1)
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
