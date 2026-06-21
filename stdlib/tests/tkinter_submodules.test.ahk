#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\tkinter>

class StdlibTkinterSubmodulesTest
{
    static TestSubmoduleAccessorsExist()
    {
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "messagebox"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "colorchooser"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "filedialog"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "simpledialog"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "font"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "scrolledtext"))
        AhkTest.AssertTrue(HasProp(stdlib.tkinter, "commondialog"))
    }

    static TestMessageboxConstantsMatchLocal310()
    {
        mb := stdlib.tkinter.messagebox
        AhkTest.AssertEqual("error", mb.ERROR)
        AhkTest.AssertEqual("info", mb.INFO)
        AhkTest.AssertEqual("question", mb.QUESTION)
        AhkTest.AssertEqual("warning", mb.WARNING)
        AhkTest.AssertEqual("ok", mb.OK)
        AhkTest.AssertEqual("okcancel", mb.OKCANCEL)
        AhkTest.AssertEqual("yesno", mb.YESNO)
        AhkTest.AssertEqual("yesnocancel", mb.YESNOCANCEL)
        AhkTest.AssertEqual("retrycancel", mb.RETRYCANCEL)
        AhkTest.AssertEqual("abortretryignore", mb.ABORTRETRYIGNORE)
        AhkTest.AssertEqual("abort", mb.ABORT)
        AhkTest.AssertEqual("retry", mb.RETRY)
        AhkTest.AssertEqual("ignore", mb.IGNORE)
        AhkTest.AssertEqual("cancel", mb.CANCEL)
        AhkTest.AssertEqual("yes", mb.YES)
        AhkTest.AssertEqual("no", mb.NO)
    }

    static TestFontConstantsMatchLocal310()
    {
        ft := stdlib.tkinter.font
        AhkTest.AssertEqual("normal", ft.NORMAL)
        AhkTest.AssertEqual("roman", ft.ROMAN)
        AhkTest.AssertEqual("bold", ft.BOLD)
        AhkTest.AssertEqual("italic", ft.ITALIC)
    }

    static TestFontCreateConfigureMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            f := stdlib.tkinter.font.Font({ root: root, family: "Courier", size: 12, weight: "bold", name: "submod_probe_font" })
            AhkTest.AssertEqual("submod_probe_font", String(f))
            AhkTest.AssertEqual("Courier", f.cget("family"))
            AhkTest.AssertEqual("bold", f.cget("weight"))
            AhkTest.AssertEqual("12", f.cget("size"))
            AhkTest.AssertEqual("Courier", f["family"])

            a := f.actual()
            AhkTest.AssertEqual("bold", a["weight"])
            AhkTest.AssertEqual("roman", a["slant"])
            AhkTest.AssertEqual(12, Integer(a["size"]))

            cfg := f.config()
            AhkTest.AssertTrue(cfg.Has("family"))
            AhkTest.AssertTrue(cfg.Has("weight"))
            AhkTest.AssertTrue(cfg.Has("size"))
            AhkTest.AssertTrue(cfg.Has("slant"))
            AhkTest.AssertTrue(cfg.Has("underline"))
            AhkTest.AssertTrue(cfg.Has("overstrike"))

            ; names() includes our named font; nametofont round-trips.
            names := stdlib.tkinter.font.names(root)
            found := false
            for n in names {
                if n = "submod_probe_font" {
                    found := true
                    break
                }
            }
            AhkTest.AssertTrue(found)

            ; configure mutates; measure/metrics return integers.
            AhkTest.AssertSame(stdlib.None, f.configure({ size: 20 }))
            AhkTest.AssertEqual("20", f.cget("size"))
            AhkTest.AssertTrue(f.measure("hello") > 0)
            AhkTest.AssertTrue(f.metrics("linespace") > 0)
        } finally {
            try root.destroy()
        }
    }

    static TestNametofontMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            stdlib.tkinter.font.Font({ root: root, family: "Times", size: 10, name: "submod_named_font" })
            again := stdlib.tkinter.font.nametofont("submod_named_font", root)
            AhkTest.AssertEqual("submod_named_font", String(again))
            AhkTest.AssertEqual("Times", again.cget("family"))

            AhkTest.RaisesMatch(stdlib.tkinter.TclError, "does not already exist", (*) => stdlib.tkinter.font.nametofont("no_such_font_xyz", root))
        } finally {
            try root.destroy()
        }
    }

    static TestFamiliesAndNamesReturnTuples()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            fams := stdlib.tkinter.font.families(root)
            AhkTest.AssertTrue(fams is AhkStdlibTuple)
            AhkTest.AssertTrue(fams.Length > 0)
            names := stdlib.tkinter.font.names(root)
            AhkTest.AssertTrue(names is AhkStdlibTuple)
        } finally {
            try root.destroy()
        }
    }

    static TestMessageboxResultMappingMatchesLocal310()
    {
        ; Install a hook that returns a canned dialog reply so the modal
        ; tk_messageBox call never pops; assert the Python-side result mapping.
        prev := AhkStdlibTkinterDialogSetTestHook((command, options, master) => StdlibTkinterSubmodulesTest.cannedReply)
        try {
            mb := stdlib.tkinter.messagebox

            StdlibTkinterSubmodulesTest.cannedReply := "ok"
            AhkTest.AssertEqual("ok", mb.showinfo("T", "M"))
            AhkTest.AssertSame(stdlib.True, mb.askokcancel("T", "M"))

            StdlibTkinterSubmodulesTest.cannedReply := "cancel"
            AhkTest.AssertSame(stdlib.False, mb.askokcancel("T", "M"))

            StdlibTkinterSubmodulesTest.cannedReply := "yes"
            AhkTest.AssertSame(stdlib.True, mb.askyesno("T", "M"))
            AhkTest.AssertSame(stdlib.True, mb.askyesnocancel("T", "M"))

            StdlibTkinterSubmodulesTest.cannedReply := "no"
            AhkTest.AssertSame(stdlib.False, mb.askyesno("T", "M"))
            AhkTest.AssertSame(stdlib.False, mb.askyesnocancel("T", "M"))

            StdlibTkinterSubmodulesTest.cannedReply := "cancel"
            AhkTest.AssertSame(stdlib.None, mb.askyesnocancel("T", "M"))

            StdlibTkinterSubmodulesTest.cannedReply := "retry"
            AhkTest.AssertSame(stdlib.True, mb.askretrycancel("T", "M"))

            StdlibTkinterSubmodulesTest.cannedReply := "warning"
            AhkTest.AssertEqual("warning", mb.showwarning("T", "M"))
        } finally {
            AhkStdlibTkinterDialogSetTestHook(prev)
        }
    }

    static TestMessageboxBuildsCorrectTclOptions()
    {
        ; The hook receives the resolved command + options; verify icon/type.
        captured := Map()
        prev := AhkStdlibTkinterDialogSetTestHook((command, options, master) => (
            captured["command"] := command,
            captured["icon"] := options.HasOwnProp("icon") ? options.icon : "",
            captured["type"] := options.HasOwnProp("type") ? options.type : "",
            captured["title"] := options.HasOwnProp("title") ? options.title : "",
            "ok"))
        try {
            stdlib.tkinter.messagebox.showerror("Boom", "It broke")
            AhkTest.AssertEqual("tk_messageBox", captured["command"])
            AhkTest.AssertEqual("error", captured["icon"])
            AhkTest.AssertEqual("ok", captured["type"])
            AhkTest.AssertEqual("Boom", captured["title"])

            stdlib.tkinter.messagebox.askquestion("Q", "Sure?")
            AhkTest.AssertEqual("question", captured["icon"])
            AhkTest.AssertEqual("yesno", captured["type"])
        } finally {
            AhkStdlibTkinterDialogSetTestHook(prev)
        }
    }

    static TestColorchooserConversionMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        prev := AhkStdlibTkinterDialogSetTestHook((command, options, master) => "#ff8000")
        try {
            root.withdraw()
            result := stdlib.tkinter.colorchooser.askcolor(stdlib.None, { parent: root })
            ; result is (rgb_triple, "#ff8000")
            AhkTest.AssertEqual("#ff8000", result[2])
            triple := result[1]
            AhkTest.AssertEqual(255, triple[1])
            AhkTest.AssertEqual(128, triple[2])
            AhkTest.AssertEqual(0, triple[3])
        } finally {
            AhkStdlibTkinterDialogSetTestHook(prev)
            try root.destroy()
        }
    }

    static TestColorchooserCancelReturnsNonePair()
    {
        root := stdlib.tkinter.Tk()
        prev := AhkStdlibTkinterDialogSetTestHook((command, options, master) => "")
        try {
            root.withdraw()
            result := stdlib.tkinter.colorchooser.askcolor(stdlib.None, { parent: root })
            AhkTest.AssertSame(stdlib.None, result[1])
            AhkTest.AssertSame(stdlib.None, result[2])
        } finally {
            AhkStdlibTkinterDialogSetTestHook(prev)
            try root.destroy()
        }
    }

    static TestColorchooserInitialColorTupleConvertedToHex()
    {
        captured := Map()
        prev := AhkStdlibTkinterDialogSetTestHook((command, options, master) => (
            captured["command"] := command,
            captured["initialcolor"] := options.HasOwnProp("initialcolor") ? options.initialcolor : "",
            ""))
        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            stdlib.tkinter.colorchooser.askcolor(stdlib.tuple([255, 128, 0]), { parent: root })
            AhkTest.AssertEqual("tk_chooseColor", captured["command"])
            AhkTest.AssertEqual("#ff8000", captured["initialcolor"])
        } finally {
            AhkStdlibTkinterDialogSetTestHook(prev)
            try root.destroy()
        }
    }

    static TestFiledialogResultAndCommandMatchLocal310()
    {
        captured := Map()
        prev := AhkStdlibTkinterDialogSetTestHook((command, options, master) => (
            captured["command"] := command,
            "C:\Users\me\report.txt"))
        try {
            opened := stdlib.tkinter.filedialog.askopenfilename()
            AhkTest.AssertEqual("tk_getOpenFile", captured["command"])
            AhkTest.AssertEqual("C:\Users\me\report.txt", opened)

            stdlib.tkinter.filedialog.asksaveasfilename()
            AhkTest.AssertEqual("tk_getSaveFile", captured["command"])

            stdlib.tkinter.filedialog.askdirectory()
            AhkTest.AssertEqual("tk_chooseDirectory", captured["command"])

            stdlib.tkinter.filedialog.askopenfilenames()
            AhkTest.AssertEqual("tk_getOpenFile", captured["command"])
        } finally {
            AhkStdlibTkinterDialogSetTestHook(prev)
        }
    }

    static TestSimpledialogCoercionMatchesLocal310()
    {
        prev := AhkStdlibTkinterDialogSetTestHook((kind, options, master) => StdlibTkinterSubmodulesTest.cannedReply)
        try {
            StdlibTkinterSubmodulesTest.cannedReply := "42"
            AhkTest.AssertEqual(42, stdlib.tkinter.simpledialog.askinteger("T", "P"))

            StdlibTkinterSubmodulesTest.cannedReply := "3.5"
            AhkTest.AssertEqual(3.5, stdlib.tkinter.simpledialog.askfloat("T", "P"))

            StdlibTkinterSubmodulesTest.cannedReply := "hello"
            AhkTest.AssertEqual("hello", stdlib.tkinter.simpledialog.askstring("T", "P"))

            ; cancel (None) propagates as None for all three
            StdlibTkinterSubmodulesTest.cannedReply := stdlib.None
            AhkTest.AssertSame(stdlib.None, stdlib.tkinter.simpledialog.askinteger("T", "P"))
            AhkTest.AssertSame(stdlib.None, stdlib.tkinter.simpledialog.askstring("T", "P"))

            ; non-integer text raises ValueError (matching getint semantics)
            StdlibTkinterSubmodulesTest.cannedReply := "notnum"
            AhkTest.RaisesMatch(ValueError, "Not an integer", (*) => stdlib.tkinter.simpledialog.askinteger("T", "P"))
        } finally {
            AhkStdlibTkinterDialogSetTestHook(prev)
        }
    }

    static TestSimpledialogMinMaxValidationMatchesLocal310()
    {
        prev := AhkStdlibTkinterDialogSetTestHook((kind, options, master) => StdlibTkinterSubmodulesTest.cannedReply)
        try {
            StdlibTkinterSubmodulesTest.cannedReply := "5"
            AhkTest.RaisesMatch(ValueError, "minimum value is 10", (*) => stdlib.tkinter.simpledialog.askinteger("T", "P", { minvalue: 10 }))
            StdlibTkinterSubmodulesTest.cannedReply := "50"
            AhkTest.RaisesMatch(ValueError, "maximum value is 20", (*) => stdlib.tkinter.simpledialog.askinteger("T", "P", { maxvalue: 20 }))
            StdlibTkinterSubmodulesTest.cannedReply := "15"
            AhkTest.AssertEqual(15, stdlib.tkinter.simpledialog.askinteger("T", "P", { minvalue: 10, maxvalue: 20 }))
        } finally {
            AhkStdlibTkinterDialogSetTestHook(prev)
        }
    }

    static TestScrolledtextConstructionMatchesLocal310()
    {
        root := stdlib.tkinter.Tk()
        try {
            root.withdraw()
            st := stdlib.tkinter.scrolledtext.ScrolledText(root, { width: 40, height: 10 })
            ; ScrolledText str() is its frame's path
            AhkTest.AssertEqual(String(st.frame), String(st))
            AhkTest.AssertTrue(st is stdlib.tkinter.Text)
            ; the embedded text widget accepts Text methods
            st.insert("end", "hello world")
            AhkTest.AssertEqual("hello world`n", st.get("1.0", "end"))
            ; vbar exists and is a Scrollbar
            AhkTest.AssertTrue(st.vbar is stdlib.tkinter.Scrollbar)
        } finally {
            try root.destroy()
        }
    }
}

StdlibTkinterSubmodulesTest.cannedReply := ""

AhkTest.Collect(StdlibTkinterSubmodulesTest)
