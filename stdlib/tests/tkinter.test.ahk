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

    static TestTclUseTkLoadsTkPackageLikeLocal310()
    {
        interp := stdlib.tkinter.Tcl({ useTk: stdlib.True })

        AhkTest.AssertEqual("winfo", interp.eval("info commands winfo"))
        AhkTest.AssertEqual("8.6.12", interp.eval("package require Tk"))
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
            imageName := "p" "y" "image1"
            image := stdlib.tkinter.PhotoImage({ master: root, width: 2, height: 2 })

            AhkTest.AssertEqual("PhotoImage", Type(image))
            AhkTest.AssertEqual(imageName, String(image))
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
