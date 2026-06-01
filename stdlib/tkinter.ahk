#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibTkinter
{
    class TclError extends Error
    {
    }

    static TclVersion {
        get => 8.6
    }

    static TkVersion {
        get => 8.6
    }

    static READABLE {
        get => 2
    }

    static WRITABLE {
        get => 4
    }

    static EXCEPTION {
        get => 8
    }

    static Tcl(args*)
    {
        if args.Length > 4
            throw TypeError("Tcl() takes from 0 to 4 positional arguments but " args.Length " were given", -1)
        return Tk(false, "Tcl", args*)
    }

    static Tk(args*)
    {
        if args.Length > 6
            throw TypeError("Tk.__init__() takes from 1 to 7 positional arguments but " args.Length + 1 " were given", -1)
        return Tk(true, "Tk", args*)
    }

    static Variable(args*)
    {
        return AhkStdlibTkinterPublicVariable(args*)
    }

    static Frame(args*)
    {
        return Frame(args*)
    }

    static Label(args*)
    {
        return Label(args*)
    }

    static LabelFrame(args*)
    {
        return LabelFrame(args*)
    }

    static Toplevel(args*)
    {
        return Toplevel(args*)
    }

    static Button(args*)
    {
        return Button(args*)
    }

    static Checkbutton(args*)
    {
        return Checkbutton(args*)
    }

    static Radiobutton(args*)
    {
        return Radiobutton(args*)
    }

    static Scale(args*)
    {
        return Scale(args*)
    }

    static Scrollbar(args*)
    {
        return Scrollbar(args*)
    }

    static Menu(args*)
    {
        return Menu(args*)
    }

    static Menubutton(args*)
    {
        return Menubutton(args*)
    }

    static Message(args*)
    {
        return Message(args*)
    }

    static Canvas(args*)
    {
        return Canvas(args*)
    }

    static Entry(args*)
    {
        return Entry(args*)
    }

    static Spinbox(args*)
    {
        return Spinbox(args*)
    }

    static Listbox(args*)
    {
        return Listbox(args*)
    }

    static Text(args*)
    {
        return Text(args*)
    }

    static BitmapImage(args*)
    {
        return BitmapImage(args*)
    }

    static PhotoImage(args*)
    {
        return PhotoImage(args*)
    }

    static StringVar(args*)
    {
        return AhkStdlibTkinterStringVar(args*)
    }

    static IntVar(args*)
    {
        return AhkStdlibTkinterIntVar(args*)
    }

    static DoubleVar(args*)
    {
        return AhkStdlibTkinterDoubleVar(args*)
    }

    static BooleanVar(args*)
    {
        return AhkStdlibTkinterBooleanVar(args*)
    }
}

class Tk
{
    __New(defaultUseTk, callName, args*)
    {
        this.AhkStdlibInterp := 0
        screenName := stdlib.None
        baseName := ""
        className := "Tk"
        useTk := defaultUseTk
        sync := false
        hasUse := false

        if args.Length = 1 && AhkStdlibTkinterIsPlainKeywordObject(args[1]) {
            options := args[1]
            for key, value in options.OwnProps() {
                switch key {
                    case "screenName":
                        screenName := value
                    case "baseName":
                        baseName := value
                    case "className":
                        className := value
                    case "useTk":
                        useTk := value
                    case "sync":
                        if callName != "Tk"
                            throw TypeError(callName "() got an unexpected keyword argument '" key "'", -1)
                        sync := value
                    case "use":
                        if callName != "Tk"
                            throw TypeError(callName "() got an unexpected keyword argument '" key "'", -1)
                        use := value
                        hasUse := true
                    default:
                        if callName = "Tk"
                            throw TypeError("Tk.__init__() got an unexpected keyword argument '" key "'", -1)
                        throw TypeError(callName "() got an unexpected keyword argument '" key "'", -1)
                }
            }
        } else {
            if args.Length >= 1
                screenName := args[1]
            if args.Length >= 2
                baseName := args[2]
            if args.Length >= 3
                className := args[3]
            if args.Length >= 4
                useTk := args[4]
            if args.Length >= 5
                sync := args[5]
            if args.Length >= 6 {
                use := args[6]
                hasUse := true
            }
        }

        if !(AhkStdlibIsNone(screenName)) && !(screenName is String)
            throw TypeError("create() argument 1 must be str or None, not " AhkStdlibPyTypeName(screenName), -1)
        if !(baseName is String)
            throw TypeError("create() argument 2 must be str, not " AhkStdlibPyTypeName(baseName), -1)
        if !(className is String)
            throw TypeError("create() argument 3 must be str, not " AhkStdlibPyTypeName(className), -1)

        useTk := AhkStdlibTkinterNormalizeBool(useTk)
        sync := AhkStdlibTkinterNormalizeBool(sync)
        AhkStdlibTkinterEnsureTclRuntime(useTk)
        this.AhkStdlibInterp := AhkStdlibTkinterCreateInterp()
        try {
            AhkStdlibTkinterInitInterp(this.AhkStdlibInterp)
            if useTk
                AhkStdlibTkinterInitTk(this.AhkStdlibInterp)
        } catch as err {
            try AhkStdlibTkinterDeleteInterp(this.AhkStdlibInterp)
            this.AhkStdlibInterp := 0
            throw err
        }
        this.AhkStdlibScreenName := screenName
        this.AhkStdlibBaseName := baseName
        this.AhkStdlibClassName := className
        this.AhkStdlibUseTk := useTk
        this.AhkStdlibSync := sync
        this.AhkStdlibChildCounters := Map()
        this.AhkStdlibWidgetsByPath := Map(".", this)
        this.AhkStdlibCommandCallbacks := Map()
        this.AhkStdlibQuitMainLoop := false
        this.tk := this
        if useTk
            this.eval("wm protocol . WM_DELETE_WINDOW " AhkStdlibTkinterTclWord("destroy ."))
        if hasUse
            this.AhkStdlibUse := use
    }

    eval(args*)
    {
        if args.Length = 0
            throw TypeError("tkapp.eval() takes exactly one argument (0 given)", -1)
        if args.Length != 1
            throw TypeError("tkapp.eval() takes exactly one argument (" args.Length " given)", -1)

        resultCode := DllCall("tcl86t\Tcl_Eval", "Ptr", this.AhkStdlibInterp, "Ptr", AhkStdlibTkinterUtf8Buffer(args[1]).Ptr, "Int")
        if resultCode != 0
            throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(this.AhkStdlibInterp), -1)
        return AhkStdlibTkinterGetStringResult(this.AhkStdlibInterp)
    }

    setvar(args*)
    {
        if args.Length > 2
            throw TypeError("Misc.setvar() takes from 1 to 3 positional arguments but " args.Length + 1 " were given", -1)

        if args.Length = 0 {
            name := AhkStdlibTkinterDefaultVarName()
            value := "1"
        } else if args.Length = 1 {
            name := args[1]
            value := "1"
        } else if args.Length = 2 {
            name := args[1]
            value := args[2]
        }

        AhkStdlibTkinterSetVar(this.AhkStdlibInterp, name, value)
        return stdlib.None
    }

    getvar(args*)
    {
        if args.Length > 1
            throw TypeError("Misc.getvar() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)

        if args.Length = 0
            name := AhkStdlibTkinterDefaultVarName()
        else
            name := args[1]

        value := AhkStdlibTkinterGetVar(this.AhkStdlibInterp, name)
        if value == AhkStdlibTkinterMissingValue()
            throw AhkStdlibTkinter.TclError("can't read " Chr(34) name Chr(34) ": no such variable", -1)
        return value
    }

    getint(args*)
    {
        return AhkStdlibTkinterGetIntMethod(this, args*)
    }

    getdouble(args*)
    {
        return AhkStdlibTkinterGetDoubleMethod(this, args*)
    }

    getboolean(args*)
    {
        return AhkStdlibTkinterGetBooleanMethod(this, args*)
    }

    _root()
    {
        return this
    }

    nametowidget(args*)
    {
        return AhkStdlibTkinterNameToWidget(this, ".", args*)
    }

    cget(args*)
    {
        if args.Length = 0
            throw TypeError("Misc.cget() missing 1 required positional argument: 'key'", -1)
        if args.Length > 1
            throw TypeError("Misc.cget() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        value := this.eval(". cget -" args[1])
        return AhkStdlibTkinterCgetValue(args[1], value)
    }

    keys(args*)
    {
        return AhkStdlibTkinterKeys(this, ".", args*)
    }

    configure(args*)
    {
        if args.Length > 1
            throw TypeError("Misc.configure() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0
            return stdlib.None
        if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
            throw TypeError("object of type '" AhkStdlibPyTypeName(args[1]) "' has no len()", -1)
        this.eval(". configure" AhkStdlibTkinterOptionsToScript(args[1], false, this))
        return stdlib.None
    }

    config(args*)
    {
        return this.configure(args*)
    }

    title(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_title() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0
            return this.eval("wm title .")
        return this.eval("wm title . " AhkStdlibTkinterTclWord(args[1]))
    }

    geometry(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_geometry() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.eval("wm geometry .")
        return this.eval("wm geometry . " AhkStdlibTkinterTclWord(args[1]))
    }

    resizable(args*)
    {
        return AhkStdlibTkinterWmResizable(this, ".", args*)
    }

    minsize(args*)
    {
        return AhkStdlibTkinterWmSize(this, ".", "minsize", args*)
    }

    maxsize(args*)
    {
        return AhkStdlibTkinterWmSize(this, ".", "maxsize", args*)
    }

    protocol(args*)
    {
        return AhkStdlibTkinterWmProtocol(this, ".", args*)
    }

    wm_protocol(args*)
    {
        return this.protocol(args*)
    }

    transient(args*)
    {
        return AhkStdlibTkinterWmTransient(this, ".", args*)
    }

    wm_transient(args*)
    {
        return this.transient(args*)
    }

    overrideredirect(args*)
    {
        return AhkStdlibTkinterWmOverrideredirect(this, ".", args*)
    }

    wm_overrideredirect(args*)
    {
        return this.overrideredirect(args*)
    }

    bind(args*)
    {
        return AhkStdlibTkinterBind(this, this, ".", args*)
    }

    bind_all(args*)
    {
        return AhkStdlibTkinterBindAll(this, this, args*)
    }

    bind_class(args*)
    {
        return AhkStdlibTkinterBindClass(this, this, args*)
    }

    unbind(args*)
    {
        return AhkStdlibTkinterUnbind(this, ".", args*)
    }

    unbind_all(args*)
    {
        return AhkStdlibTkinterUnbindAll(this, args*)
    }

    unbind_class(args*)
    {
        return AhkStdlibTkinterUnbindClass(this, args*)
    }

    bindtags(args*)
    {
        return AhkStdlibTkinterBindTags(this, ".", args*)
    }

    event_generate(args*)
    {
        return AhkStdlibTkinterEventGenerate(this, ".", args*)
    }

    event_add(args*)
    {
        return AhkStdlibTkinterEventAdd(this, args*)
    }

    event_delete(args*)
    {
        return AhkStdlibTkinterEventDelete(this, args*)
    }

    event_info(args*)
    {
        return AhkStdlibTkinterEventInfo(this, args*)
    }

    lift(args*)
    {
        return AhkStdlibTkinterStacking(this, ".", "raise", "tkraise", args*)
    }

    tkraise(args*)
    {
        return AhkStdlibTkinterStacking(this, ".", "raise", "tkraise", args*)
    }

    lower(args*)
    {
        return AhkStdlibTkinterStacking(this, ".", "lower", "lower", args*)
    }

    grab_set(args*)
    {
        return AhkStdlibTkinterGrabSet(this, ".", "grab_set", args*)
    }

    grab_release(args*)
    {
        return AhkStdlibTkinterGrabRelease(this, ".", args*)
    }

    grab_current(args*)
    {
        return AhkStdlibTkinterGrabCurrent(this, ".", args*)
    }

    grab_status(args*)
    {
        return AhkStdlibTkinterGrabStatus(this, ".", args*)
    }

    wait_window(args*)
    {
        return AhkStdlibTkinterWaitFor(this, ".", "window", "wait_window", args*)
    }

    wait_visibility(args*)
    {
        return AhkStdlibTkinterWaitFor(this, ".", "visibility", "wait_visibility", args*)
    }

    wait_variable(args*)
    {
        return AhkStdlibTkinterWaitVariable(this, args*)
    }

    waitvar(args*)
    {
        return this.wait_variable(args*)
    }

    focus_set(args*)
    {
        return AhkStdlibTkinterFocusSet(this, ".", "focus_set", false, args*)
    }

    focus_force(args*)
    {
        return AhkStdlibTkinterFocusSet(this, ".", "focus_force", true, args*)
    }

    focus_get(args*)
    {
        return AhkStdlibTkinterFocusQuery(this, "focus", "focus_get", args*)
    }

    focus_displayof(args*)
    {
        return AhkStdlibTkinterFocusQuery(this, "focus -displayof .", "focus_displayof", args*)
    }

    clipboard_clear(args*)
    {
        return AhkStdlibTkinterClipboardClear(this, ".", args*)
    }

    clipboard_append(args*)
    {
        return AhkStdlibTkinterClipboardAppend(this, ".", args*)
    }

    clipboard_get(args*)
    {
        return AhkStdlibTkinterClipboardGet(this, ".", args*)
    }

    option_add(args*)
    {
        return AhkStdlibTkinterOptionAdd(this, args*)
    }

    option_clear(args*)
    {
        return AhkStdlibTkinterOptionClear(this, args*)
    }

    option_get(args*)
    {
        return AhkStdlibTkinterOptionGet(this, ".", args*)
    }

    option_readfile(args*)
    {
        return AhkStdlibTkinterOptionReadFile(this, args*)
    }

    state(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_state() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.eval("wm state .")
        return this.eval("wm state . " AhkStdlibTkinterTclWord(args[1]))
    }

    withdraw(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_withdraw() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.eval("wm withdraw .")
    }

    iconify(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_iconify() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.eval("wm iconify .")
    }

    deiconify(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_deiconify() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.eval("wm deiconify .")
    }

    update(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.update() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.eval("update")
        return stdlib.None
    }

    update_idletasks(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.update_idletasks() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.eval("update idletasks")
        return stdlib.None
    }

    after(args*)
    {
        if args.Length = 0
            throw TypeError("Misc.after() missing 1 required positional argument: 'ms'", -1)
        return AhkStdlibTkinterAfter(this, args*)
    }

    after_idle(args*)
    {
        if args.Length = 0
            throw TypeError("Misc.after_idle() missing 1 required positional argument: 'func'", -1)
        return AhkStdlibTkinterAfter(this, "idle", args*)
    }

    after_cancel(args*)
    {
        if args.Length = 0
            throw TypeError("Misc.after_cancel() missing 1 required positional argument: 'id'", -1)
        if args.Length > 1
            throw TypeError("Misc.after_cancel() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.eval("after cancel " AhkStdlibTkinterTclWord(args[1]))
        return stdlib.None
    }

    image_names(args*)
    {
        return AhkStdlibTkinterImageNames(this, args*)
    }

    image_types(args*)
    {
        return AhkStdlibTkinterImageTypes(this, args*)
    }

    mainloop(args*)
    {
        if args.Length > 1
            throw TypeError("Misc.mainloop() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibQuitMainLoop := false
        while !this.AhkStdlibQuitMainLoop && this.eval("winfo exists .") = "1" {
            this.update()
            Sleep 1
        }
        return stdlib.None
    }

    quit(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.quit() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibQuitMainLoop := true
        return stdlib.None
    }

    winfo_exists(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_exists() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.eval("winfo exists ."))
    }

    winfo_manager(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_manager() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.eval("winfo manager .")
    }

    pack_slaves(args*)
    {
        return AhkStdlibTkinterPackSlaves(this, ".", args*)
    }

    slaves(args*)
    {
        return this.pack_slaves(args*)
    }

    pack_propagate(args*)
    {
        return AhkStdlibTkinterPropagate(this, ".", "pack", "pack_propagate", args*)
    }

    propagate(args*)
    {
        return this.pack_propagate(args*)
    }

    grid_slaves(args*)
    {
        return AhkStdlibTkinterGridSlaves(this, ".", args*)
    }

    grid_propagate(args*)
    {
        return AhkStdlibTkinterPropagate(this, ".", "grid", "grid_propagate", args*)
    }

    grid_anchor(args*)
    {
        return AhkStdlibTkinterGridAnchor(this, ".", args*)
    }

    anchor(args*)
    {
        return this.grid_anchor(args*)
    }

    grid_columnconfigure(args*)
    {
        return AhkStdlibTkinterGridAxisConfigure(this, ".", "column", "grid_columnconfigure", args*)
    }

    columnconfigure(args*)
    {
        return this.grid_columnconfigure(args*)
    }

    grid_rowconfigure(args*)
    {
        return AhkStdlibTkinterGridAxisConfigure(this, ".", "row", "grid_rowconfigure", args*)
    }

    rowconfigure(args*)
    {
        return this.grid_rowconfigure(args*)
    }

    grid_size(args*)
    {
        return AhkStdlibTkinterGridSize(this, ".", args*)
    }

    size(args*)
    {
        return this.grid_size(args*)
    }

    grid_bbox(args*)
    {
        return AhkStdlibTkinterGridBbox(this, ".", args*)
    }

    bbox(args*)
    {
        return this.grid_bbox(args*)
    }

    grid_location(args*)
    {
        return AhkStdlibTkinterGridLocation(this, ".", args*)
    }

    place_slaves(args*)
    {
        return AhkStdlibTkinterPlaceSlaves(this, ".", args*)
    }

    winfo_children(args*)
    {
        return AhkStdlibTkinterWinfoChildren(this, ".", args*)
    }

    winfo_atom(args*)
    {
        return AhkStdlibTkinterWinfoAtom(this, ".", args*)
    }

    winfo_atomname(args*)
    {
        return AhkStdlibTkinterWinfoAtomName(this, ".", args*)
    }

    winfo_containing(args*)
    {
        return AhkStdlibTkinterWinfoContaining(this, ".", args*)
    }

    winfo_interps(args*)
    {
        return AhkStdlibTkinterWinfoInterps(this, ".", args*)
    }

    winfo_pathname(args*)
    {
        return AhkStdlibTkinterWinfoPathName(this, ".", args*)
    }

    winfo_class(args*)
    {
        return AhkStdlibTkinterWinfoString(this, ".", "class", "winfo_class", args*)
    }

    winfo_name(args*)
    {
        return AhkStdlibTkinterWinfoString(this, ".", "name", "winfo_name", args*)
    }

    winfo_parent(args*)
    {
        return AhkStdlibTkinterWinfoString(this, ".", "parent", "winfo_parent", args*)
    }

    winfo_viewable(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_viewable() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.eval("winfo viewable ."))
    }

    winfo_x(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "x", "winfo_x", args*)
    }

    winfo_y(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "y", "winfo_y", args*)
    }

    winfo_rootx(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "rootx", "winfo_rootx", args*)
    }

    winfo_rooty(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "rooty", "winfo_rooty", args*)
    }

    winfo_screenwidth(args*)
    {
        return AhkStdlibTkinterWinfoLogicalScreenInteger(this, ".", "screenwidth", "winfo_screenwidth", args*)
    }

    winfo_screenheight(args*)
    {
        return AhkStdlibTkinterWinfoLogicalScreenInteger(this, ".", "screenheight", "winfo_screenheight", args*)
    }

    winfo_vrootwidth(args*)
    {
        return AhkStdlibTkinterWinfoLogicalScreenInteger(this, ".", "vrootwidth", "winfo_vrootwidth", args*)
    }

    winfo_vrootheight(args*)
    {
        return AhkStdlibTkinterWinfoLogicalScreenInteger(this, ".", "vrootheight", "winfo_vrootheight", args*)
    }

    winfo_vrootx(args*)
    {
        return AhkStdlibTkinterWinfoLogicalScreenInteger(this, ".", "vrootx", "winfo_vrootx", args*)
    }

    winfo_vrooty(args*)
    {
        return AhkStdlibTkinterWinfoLogicalScreenInteger(this, ".", "vrooty", "winfo_vrooty", args*)
    }

    winfo_screen(args*)
    {
        return AhkStdlibTkinterWinfoString(this, ".", "screen", "winfo_screen", args*)
    }

    winfo_screenmmwidth(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "screenmmwidth", "winfo_screenmmwidth", args*)
    }

    winfo_screenmmheight(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "screenmmheight", "winfo_screenmmheight", args*)
    }

    winfo_screendepth(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "screendepth", "winfo_screendepth", args*)
    }

    winfo_screencells(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "screencells", "winfo_screencells", args*)
    }

    winfo_cells(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "cells", "winfo_cells", args*)
    }

    winfo_colormapfull(args*)
    {
        return AhkStdlibTkinterWinfoBoolean(this, ".", "colormapfull", "winfo_colormapfull", args*)
    }

    winfo_depth(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "depth", "winfo_depth", args*)
    }

    winfo_geometry(args*)
    {
        return AhkStdlibTkinterWinfoString(this, ".", "geometry", "winfo_geometry", args*)
    }

    winfo_id(args*)
    {
        return AhkStdlibTkinterWinfoIntegerBase0(this, ".", "id", "winfo_id", args*)
    }

    winfo_pointerx(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "pointerx", "winfo_pointerx", args*)
    }

    winfo_pointerxy(args*)
    {
        return AhkStdlibTkinterWinfoIntegerTuple(this, ".", "pointerxy", "winfo_pointerxy", args*)
    }

    winfo_pointery(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "pointery", "winfo_pointery", args*)
    }

    winfo_screenvisual(args*)
    {
        return AhkStdlibTkinterWinfoString(this, ".", "screenvisual", "winfo_screenvisual", args*)
    }

    winfo_server(args*)
    {
        return AhkStdlibTkinterWinfoString(this, ".", "server", "winfo_server", args*)
    }

    winfo_visual(args*)
    {
        return AhkStdlibTkinterWinfoString(this, ".", "visual", "winfo_visual", args*)
    }

    winfo_visualid(args*)
    {
        return AhkStdlibTkinterWinfoString(this, ".", "visualid", "winfo_visualid", args*)
    }

    winfo_visualsavailable(args*)
    {
        return AhkStdlibTkinterWinfoVisualsAvailable(this, ".", args*)
    }

    winfo_reqwidth(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "reqwidth", "winfo_reqwidth", args*)
    }

    winfo_reqheight(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this, ".", "reqheight", "winfo_reqheight", args*)
    }

    winfo_pixels(args*)
    {
        return AhkStdlibTkinterWinfoPixels(this, ".", "pixels", "winfo_pixels", args*)
    }

    winfo_fpixels(args*)
    {
        return AhkStdlibTkinterWinfoPixels(this, ".", "fpixels", "winfo_fpixels", args*)
    }

    winfo_rgb(args*)
    {
        return AhkStdlibTkinterWinfoRgb(this, ".", args*)
    }

    winfo_ismapped(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_ismapped() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.eval("winfo ismapped ."))
    }

    winfo_width(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_width() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.eval("winfo width ."))
    }

    winfo_height(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_height() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.eval("winfo height ."))
    }

    winfo_toplevel(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_toplevel() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this
    }

    destroy()
    {
        resultCode := DllCall("tcl86t\Tcl_Eval", "Ptr", this.AhkStdlibInterp, "Ptr", AhkStdlibTkinterUtf8Buffer("destroy .").Ptr, "Int")
        if resultCode != 0
            throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(this.AhkStdlibInterp), -1)
        return stdlib.None
    }

    ToString()
    {
        return "."
    }

    __Delete()
    {
        if this.AhkStdlibInterp
            AhkStdlibTkinterDeleteInterp(this.AhkStdlibInterp)
    }
}

class AhkStdlibTkinterWidget
{
    __New(className, tkCommand, args*)
    {
        if args.Length > 2
            throw TypeError(className ".__init__() takes from 1 to 3 positional arguments but " args.Length + 1 " were given", -1)

        master := stdlib.None
        options := {}
        if args.Length = 1 && AhkStdlibTkinterIsPlainKeywordObject(args[1]) {
            options := args[1]
            if options.HasOwnProp("master")
                master := options.master
        } else {
            if args.Length >= 1
                master := args[1]
            if args.Length >= 2 {
                if !AhkStdlibTkinterIsPlainKeywordObject(args[2])
                    throw TypeError("cnf must be a dictionary", -1)
                options := args[2]
            }
        }

        if AhkStdlibIsNone(master)
            throw RuntimeError("Too early to create widget: no default root window", -1)
        if !IsObject(master) || !HasProp(master, "tk")
            throw AttributeError("'" AhkStdlibPyTypeName(master) "' object has no attribute 'tk'", -1)

        this.master := master
        this.tk := master.tk
        this.AhkStdlibRoot := master._root()
        this.AhkStdlibTkCommand := tkCommand
        this._w := AhkStdlibTkinterResolveWidgetPath(this.AhkStdlibRoot, String(master), tkCommand, options)

        script := tkCommand " " this._w AhkStdlibTkinterOptionsToScript(options, false, this.AhkStdlibRoot)
        this.AhkStdlibRoot.eval(script)
        this.AhkStdlibRoot.AhkStdlibWidgetsByPath[this._w] := this
    }

    _root()
    {
        return this.AhkStdlibRoot
    }

    nametowidget(args*)
    {
        return AhkStdlibTkinterNameToWidget(this.AhkStdlibRoot, this._w, args*)
    }

    cget(args*)
    {
        if args.Length = 0
            throw TypeError("Misc.cget() missing 1 required positional argument: 'key'", -1)
        if args.Length > 1
            throw TypeError("Misc.cget() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        value := this.AhkStdlibRoot.eval(this._w " cget -" args[1])
        return AhkStdlibTkinterCgetValue(args[1], value)
    }

    keys(args*)
    {
        return AhkStdlibTkinterKeys(this.AhkStdlibRoot, this._w, args*)
    }

    configure(args*)
    {
        if args.Length > 1
            throw TypeError("Misc.configure() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0
            return stdlib.None
        if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
            throw TypeError("cnf must be a dictionary", -1)
        this.AhkStdlibRoot.eval(this._w " configure" AhkStdlibTkinterOptionsToScript(args[1], false, this.AhkStdlibRoot))
        return stdlib.None
    }

    config(args*)
    {
        return this.configure(args*)
    }

    pack(args*)
    {
        if args.Length > 1
            throw TypeError("pack_configure() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        script := "pack " this._w
        if args.Length = 1 {
            if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
                throw TypeError("object of type '" AhkStdlibPyTypeName(args[1]) "' has no len()", -1)
            script .= AhkStdlibTkinterOptionsToScript(args[1], true)
        }
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    pack_configure(args*)
    {
        if args.Length > 1
            throw TypeError("Pack.pack_configure() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.pack(args*)
    }

    pack_info(args*)
    {
        if args.Length != 0
            throw TypeError("Pack.pack_info() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return AhkStdlibTkinterPackInfo(this)
    }

    info(args*)
    {
        return this.pack_info(args*)
    }

    pack_forget(args*)
    {
        if args.Length != 0
            throw TypeError("Pack.pack_forget() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval("pack forget " this._w)
        return stdlib.None
    }

    forget(args*)
    {
        return this.pack_forget(args*)
    }

    pack_slaves(args*)
    {
        return AhkStdlibTkinterPackSlaves(this.AhkStdlibRoot, this._w, args*)
    }

    slaves(args*)
    {
        return this.pack_slaves(args*)
    }

    pack_propagate(args*)
    {
        return AhkStdlibTkinterPropagate(this.AhkStdlibRoot, this._w, "pack", "pack_propagate", args*)
    }

    propagate(args*)
    {
        return this.pack_propagate(args*)
    }

    grid(args*)
    {
        if args.Length > 1
            throw TypeError("Grid.grid_configure() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        script := "grid " this._w
        if args.Length = 1 {
            if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
                throw TypeError("object of type '" AhkStdlibPyTypeName(args[1]) "' has no len()", -1)
            script .= AhkStdlibTkinterOptionsToScript(args[1], true)
        }
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    grid_configure(args*)
    {
        return this.grid(args*)
    }

    grid_forget(args*)
    {
        if args.Length != 0
            throw TypeError("Grid.grid_forget() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval("grid forget " this._w)
        return stdlib.None
    }

    grid_remove(args*)
    {
        if args.Length != 0
            throw TypeError("Grid.grid_remove() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval("grid remove " this._w)
        return stdlib.None
    }

    grid_slaves(args*)
    {
        return AhkStdlibTkinterGridSlaves(this.AhkStdlibRoot, this._w, args*)
    }

    grid_propagate(args*)
    {
        return AhkStdlibTkinterPropagate(this.AhkStdlibRoot, this._w, "grid", "grid_propagate", args*)
    }

    grid_anchor(args*)
    {
        return AhkStdlibTkinterGridAnchor(this.AhkStdlibRoot, this._w, args*)
    }

    anchor(args*)
    {
        return this.grid_anchor(args*)
    }

    grid_columnconfigure(args*)
    {
        return AhkStdlibTkinterGridAxisConfigure(this.AhkStdlibRoot, this._w, "column", "grid_columnconfigure", args*)
    }

    columnconfigure(args*)
    {
        return this.grid_columnconfigure(args*)
    }

    grid_rowconfigure(args*)
    {
        return AhkStdlibTkinterGridAxisConfigure(this.AhkStdlibRoot, this._w, "row", "grid_rowconfigure", args*)
    }

    rowconfigure(args*)
    {
        return this.grid_rowconfigure(args*)
    }

    grid_size(args*)
    {
        return AhkStdlibTkinterGridSize(this.AhkStdlibRoot, this._w, args*)
    }

    size(args*)
    {
        return this.grid_size(args*)
    }

    grid_bbox(args*)
    {
        return AhkStdlibTkinterGridBbox(this.AhkStdlibRoot, this._w, args*)
    }

    bbox(args*)
    {
        return this.grid_bbox(args*)
    }

    grid_location(args*)
    {
        return AhkStdlibTkinterGridLocation(this.AhkStdlibRoot, this._w, args*)
    }

    location(args*)
    {
        return this.grid_location(args*)
    }

    grid_info(args*)
    {
        if args.Length != 0
            throw TypeError("Grid.grid_info() takes 1 positional argument but " args.Length + 1 " were given", -1)
        if this.winfo_manager() != "grid"
            return Map()

        info := Map("in", this.master)
        for key in ["column", "row", "columnspan", "rowspan", "ipadx", "ipady", "padx", "pady"]
            info[key] := Integer(this.AhkStdlibRoot.eval("dict get [grid info " this._w "] -" key))
        info["sticky"] := this.AhkStdlibRoot.eval("dict get [grid info " this._w "] -sticky")
        return info
    }

    place(args*)
    {
        if args.Length > 1
            throw TypeError("Place.place_configure() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        script := "place configure " this._w
        if args.Length = 1 {
            if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
                throw TypeError("object of type '" AhkStdlibPyTypeName(args[1]) "' has no len()", -1)
            script .= AhkStdlibTkinterOptionsToScript(args[1], true)
        }
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    place_configure(args*)
    {
        return this.place(args*)
    }

    place_forget(args*)
    {
        if args.Length != 0
            throw TypeError("Place.place_forget() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval("place forget " this._w)
        return stdlib.None
    }

    place_slaves(args*)
    {
        return AhkStdlibTkinterPlaceSlaves(this.AhkStdlibRoot, this._w, args*)
    }

    place_info(args*)
    {
        if args.Length != 0
            throw TypeError("Place.place_info() takes 1 positional argument but " args.Length + 1 " were given", -1)
        if this.winfo_manager() != "place"
            return Map()

        info := Map("in", this.master)
        for key in ["x", "relx", "y", "rely", "width", "relwidth", "height", "relheight", "anchor", "bordermode"]
            info[key] := this.AhkStdlibRoot.eval("dict get [place info " this._w "] -" key)
        return info
    }

    after_idle(args*)
    {
        if args.Length = 0
            throw TypeError("Misc.after_idle() missing 1 required positional argument: 'func'", -1)
        return AhkStdlibTkinterAfter(this.AhkStdlibRoot, "idle", args*)
    }

    image_names(args*)
    {
        return AhkStdlibTkinterImageNames(this.AhkStdlibRoot, args*)
    }

    image_types(args*)
    {
        return AhkStdlibTkinterImageTypes(this.AhkStdlibRoot, args*)
    }

    bind(args*)
    {
        return AhkStdlibTkinterBind(this.AhkStdlibRoot, this, this._w, args*)
    }

    bind_all(args*)
    {
        return AhkStdlibTkinterBindAll(this.AhkStdlibRoot, this, args*)
    }

    bind_class(args*)
    {
        return AhkStdlibTkinterBindClass(this.AhkStdlibRoot, this, args*)
    }

    unbind(args*)
    {
        return AhkStdlibTkinterUnbind(this.AhkStdlibRoot, this._w, args*)
    }

    unbind_all(args*)
    {
        return AhkStdlibTkinterUnbindAll(this.AhkStdlibRoot, args*)
    }

    unbind_class(args*)
    {
        return AhkStdlibTkinterUnbindClass(this.AhkStdlibRoot, args*)
    }

    bindtags(args*)
    {
        return AhkStdlibTkinterBindTags(this.AhkStdlibRoot, this._w, args*)
    }

    event_generate(args*)
    {
        return AhkStdlibTkinterEventGenerate(this.AhkStdlibRoot, this._w, args*)
    }

    event_add(args*)
    {
        return AhkStdlibTkinterEventAdd(this.AhkStdlibRoot, args*)
    }

    event_delete(args*)
    {
        return AhkStdlibTkinterEventDelete(this.AhkStdlibRoot, args*)
    }

    event_info(args*)
    {
        return AhkStdlibTkinterEventInfo(this.AhkStdlibRoot, args*)
    }

    lift(args*)
    {
        return AhkStdlibTkinterStacking(this.AhkStdlibRoot, this._w, "raise", "tkraise", args*)
    }

    tkraise(args*)
    {
        return AhkStdlibTkinterStacking(this.AhkStdlibRoot, this._w, "raise", "tkraise", args*)
    }

    lower(args*)
    {
        return AhkStdlibTkinterStacking(this.AhkStdlibRoot, this._w, "lower", "lower", args*)
    }

    grab_set(args*)
    {
        return AhkStdlibTkinterGrabSet(this.AhkStdlibRoot, this._w, "grab_set", args*)
    }

    grab_release(args*)
    {
        return AhkStdlibTkinterGrabRelease(this.AhkStdlibRoot, this._w, args*)
    }

    grab_current(args*)
    {
        return AhkStdlibTkinterGrabCurrent(this.AhkStdlibRoot, this._w, args*)
    }

    grab_status(args*)
    {
        return AhkStdlibTkinterGrabStatus(this.AhkStdlibRoot, this._w, args*)
    }

    wait_window(args*)
    {
        return AhkStdlibTkinterWaitFor(this.AhkStdlibRoot, this._w, "window", "wait_window", args*)
    }

    wait_visibility(args*)
    {
        return AhkStdlibTkinterWaitFor(this.AhkStdlibRoot, this._w, "visibility", "wait_visibility", args*)
    }

    wait_variable(args*)
    {
        return AhkStdlibTkinterWaitVariable(this.AhkStdlibRoot, args*)
    }

    waitvar(args*)
    {
        return this.wait_variable(args*)
    }

    focus_set(args*)
    {
        return AhkStdlibTkinterFocusSet(this.AhkStdlibRoot, this._w, "focus_set", false, args*)
    }

    focus_force(args*)
    {
        return AhkStdlibTkinterFocusSet(this.AhkStdlibRoot, this._w, "focus_force", true, args*)
    }

    focus_get(args*)
    {
        return AhkStdlibTkinterFocusQuery(this.AhkStdlibRoot, "focus", "focus_get", args*)
    }

    focus_displayof(args*)
    {
        return AhkStdlibTkinterFocusQuery(this.AhkStdlibRoot, "focus -displayof " this._w, "focus_displayof", args*)
    }

    clipboard_clear(args*)
    {
        return AhkStdlibTkinterClipboardClear(this.AhkStdlibRoot, this._w, args*)
    }

    clipboard_append(args*)
    {
        return AhkStdlibTkinterClipboardAppend(this.AhkStdlibRoot, this._w, args*)
    }

    clipboard_get(args*)
    {
        return AhkStdlibTkinterClipboardGet(this.AhkStdlibRoot, this._w, args*)
    }

    option_add(args*)
    {
        return AhkStdlibTkinterOptionAdd(this.AhkStdlibRoot, args*)
    }

    option_clear(args*)
    {
        return AhkStdlibTkinterOptionClear(this.AhkStdlibRoot, args*)
    }

    option_get(args*)
    {
        return AhkStdlibTkinterOptionGet(this.AhkStdlibRoot, this._w, args*)
    }

    option_readfile(args*)
    {
        return AhkStdlibTkinterOptionReadFile(this.AhkStdlibRoot, args*)
    }

    selection_get(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.selection_get() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval("selection get")
    }

    getint(args*)
    {
        return AhkStdlibTkinterGetIntMethod(this.AhkStdlibRoot, args*)
    }

    getdouble(args*)
    {
        return AhkStdlibTkinterGetDoubleMethod(this.AhkStdlibRoot, args*)
    }

    getboolean(args*)
    {
        return AhkStdlibTkinterGetBooleanMethod(this.AhkStdlibRoot, args*)
    }

    winfo_exists(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_exists() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval("winfo exists " this._w))
    }

    winfo_manager(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_manager() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval("winfo manager " this._w)
    }

    winfo_children(args*)
    {
        return AhkStdlibTkinterWinfoChildren(this.AhkStdlibRoot, this._w, args*)
    }

    winfo_atom(args*)
    {
        return AhkStdlibTkinterWinfoAtom(this.AhkStdlibRoot, this._w, args*)
    }

    winfo_atomname(args*)
    {
        return AhkStdlibTkinterWinfoAtomName(this.AhkStdlibRoot, this._w, args*)
    }

    winfo_containing(args*)
    {
        return AhkStdlibTkinterWinfoContaining(this.AhkStdlibRoot, this._w, args*)
    }

    winfo_interps(args*)
    {
        return AhkStdlibTkinterWinfoInterps(this.AhkStdlibRoot, this._w, args*)
    }

    winfo_pathname(args*)
    {
        return AhkStdlibTkinterWinfoPathName(this.AhkStdlibRoot, this._w, args*)
    }

    winfo_class(args*)
    {
        return AhkStdlibTkinterWinfoString(this.AhkStdlibRoot, this._w, "class", "winfo_class", args*)
    }

    winfo_name(args*)
    {
        return AhkStdlibTkinterWinfoString(this.AhkStdlibRoot, this._w, "name", "winfo_name", args*)
    }

    winfo_parent(args*)
    {
        return AhkStdlibTkinterWinfoString(this.AhkStdlibRoot, this._w, "parent", "winfo_parent", args*)
    }

    winfo_viewable(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_viewable() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval("winfo viewable " this._w))
    }

    winfo_x(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "x", "winfo_x", args*)
    }

    winfo_y(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "y", "winfo_y", args*)
    }

    winfo_rootx(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "rootx", "winfo_rootx", args*)
    }

    winfo_rooty(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "rooty", "winfo_rooty", args*)
    }

    winfo_screenwidth(args*)
    {
        return AhkStdlibTkinterWinfoLogicalScreenInteger(this.AhkStdlibRoot, this._w, "screenwidth", "winfo_screenwidth", args*)
    }

    winfo_screenheight(args*)
    {
        return AhkStdlibTkinterWinfoLogicalScreenInteger(this.AhkStdlibRoot, this._w, "screenheight", "winfo_screenheight", args*)
    }

    winfo_vrootwidth(args*)
    {
        return AhkStdlibTkinterWinfoLogicalScreenInteger(this.AhkStdlibRoot, this._w, "vrootwidth", "winfo_vrootwidth", args*)
    }

    winfo_vrootheight(args*)
    {
        return AhkStdlibTkinterWinfoLogicalScreenInteger(this.AhkStdlibRoot, this._w, "vrootheight", "winfo_vrootheight", args*)
    }

    winfo_vrootx(args*)
    {
        return AhkStdlibTkinterWinfoLogicalScreenInteger(this.AhkStdlibRoot, this._w, "vrootx", "winfo_vrootx", args*)
    }

    winfo_vrooty(args*)
    {
        return AhkStdlibTkinterWinfoLogicalScreenInteger(this.AhkStdlibRoot, this._w, "vrooty", "winfo_vrooty", args*)
    }

    winfo_screen(args*)
    {
        return AhkStdlibTkinterWinfoString(this.AhkStdlibRoot, this._w, "screen", "winfo_screen", args*)
    }

    winfo_screenmmwidth(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "screenmmwidth", "winfo_screenmmwidth", args*)
    }

    winfo_screenmmheight(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "screenmmheight", "winfo_screenmmheight", args*)
    }

    winfo_screendepth(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "screendepth", "winfo_screendepth", args*)
    }

    winfo_screencells(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "screencells", "winfo_screencells", args*)
    }

    winfo_cells(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "cells", "winfo_cells", args*)
    }

    winfo_colormapfull(args*)
    {
        return AhkStdlibTkinterWinfoBoolean(this.AhkStdlibRoot, this._w, "colormapfull", "winfo_colormapfull", args*)
    }

    winfo_depth(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "depth", "winfo_depth", args*)
    }

    winfo_geometry(args*)
    {
        return AhkStdlibTkinterWinfoString(this.AhkStdlibRoot, this._w, "geometry", "winfo_geometry", args*)
    }

    winfo_id(args*)
    {
        return AhkStdlibTkinterWinfoIntegerBase0(this.AhkStdlibRoot, this._w, "id", "winfo_id", args*)
    }

    winfo_pointerx(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "pointerx", "winfo_pointerx", args*)
    }

    winfo_pointerxy(args*)
    {
        return AhkStdlibTkinterWinfoIntegerTuple(this.AhkStdlibRoot, this._w, "pointerxy", "winfo_pointerxy", args*)
    }

    winfo_pointery(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "pointery", "winfo_pointery", args*)
    }

    winfo_screenvisual(args*)
    {
        return AhkStdlibTkinterWinfoString(this.AhkStdlibRoot, this._w, "screenvisual", "winfo_screenvisual", args*)
    }

    winfo_server(args*)
    {
        return AhkStdlibTkinterWinfoString(this.AhkStdlibRoot, this._w, "server", "winfo_server", args*)
    }

    winfo_visual(args*)
    {
        return AhkStdlibTkinterWinfoString(this.AhkStdlibRoot, this._w, "visual", "winfo_visual", args*)
    }

    winfo_visualid(args*)
    {
        return AhkStdlibTkinterWinfoString(this.AhkStdlibRoot, this._w, "visualid", "winfo_visualid", args*)
    }

    winfo_visualsavailable(args*)
    {
        return AhkStdlibTkinterWinfoVisualsAvailable(this.AhkStdlibRoot, this._w, args*)
    }

    winfo_reqwidth(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "reqwidth", "winfo_reqwidth", args*)
    }

    winfo_reqheight(args*)
    {
        return AhkStdlibTkinterWinfoInteger(this.AhkStdlibRoot, this._w, "reqheight", "winfo_reqheight", args*)
    }

    winfo_pixels(args*)
    {
        return AhkStdlibTkinterWinfoPixels(this.AhkStdlibRoot, this._w, "pixels", "winfo_pixels", args*)
    }

    winfo_fpixels(args*)
    {
        return AhkStdlibTkinterWinfoPixels(this.AhkStdlibRoot, this._w, "fpixels", "winfo_fpixels", args*)
    }

    winfo_rgb(args*)
    {
        return AhkStdlibTkinterWinfoRgb(this.AhkStdlibRoot, this._w, args*)
    }

    winfo_ismapped(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_ismapped() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval("winfo ismapped " this._w))
    }

    winfo_width(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_width() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval("winfo width " this._w))
    }

    winfo_height(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_height() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval("winfo height " this._w))
    }

    winfo_toplevel(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.winfo_toplevel() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return AhkStdlibTkinterWidgetToplevel(this)
    }

    destroy()
    {
        this.AhkStdlibRoot.eval("destroy " this._w)
        return stdlib.None
    }

    ToString()
    {
        return this._w
    }
}

class Frame extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Frame", "frame", args*)
    }
}

class Label extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Label", "label", args*)
    }
}

class LabelFrame extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("LabelFrame", "labelframe", args*)
    }
}

class Toplevel extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Toplevel", "toplevel", args*)
        this.title(this.AhkStdlibRoot.title())
        this.AhkStdlibRoot.eval("wm protocol " this._w " WM_DELETE_WINDOW " AhkStdlibTkinterTclWord("destroy " this._w))
    }

    geometry(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_geometry() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.AhkStdlibRoot.eval("wm geometry " this._w)
        return this.AhkStdlibRoot.eval("wm geometry " this._w " " AhkStdlibTkinterTclWord(args[1]))
    }

    resizable(args*)
    {
        return AhkStdlibTkinterWmResizable(this.AhkStdlibRoot, this._w, args*)
    }

    minsize(args*)
    {
        return AhkStdlibTkinterWmSize(this.AhkStdlibRoot, this._w, "minsize", args*)
    }

    maxsize(args*)
    {
        return AhkStdlibTkinterWmSize(this.AhkStdlibRoot, this._w, "maxsize", args*)
    }

    title(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_title() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0
            return this.AhkStdlibRoot.eval("wm title " this._w)
        return this.AhkStdlibRoot.eval("wm title " this._w " " AhkStdlibTkinterTclWord(args[1]))
    }

    protocol(args*)
    {
        return AhkStdlibTkinterWmProtocol(this.AhkStdlibRoot, this._w, args*)
    }

    wm_protocol(args*)
    {
        return this.protocol(args*)
    }

    transient(args*)
    {
        return AhkStdlibTkinterWmTransient(this.AhkStdlibRoot, this._w, args*)
    }

    wm_transient(args*)
    {
        return this.transient(args*)
    }

    overrideredirect(args*)
    {
        return AhkStdlibTkinterWmOverrideredirect(this.AhkStdlibRoot, this._w, args*)
    }

    wm_overrideredirect(args*)
    {
        return this.overrideredirect(args*)
    }

    state(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_state() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.AhkStdlibRoot.eval("wm state " this._w)
        return this.AhkStdlibRoot.eval("wm state " this._w " " AhkStdlibTkinterTclWord(args[1]))
    }

    withdraw(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_withdraw() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval("wm withdraw " this._w)
    }

    iconify(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_iconify() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval("wm iconify " this._w)
    }

    deiconify(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_deiconify() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval("wm deiconify " this._w)
    }
}

class Event
{
    __New(widget, rawArgs, sequence := "")
    {
        this.widget := widget
        this.type := EventType(AhkStdlibTkinterEventTypeName(rawArgs.Length >= 2 ? rawArgs[2] : "", sequence))
        this.x := AhkStdlibTkinterEventInteger(rawArgs.Length >= 3 ? rawArgs[3] : "0")
        this.y := AhkStdlibTkinterEventInteger(rawArgs.Length >= 4 ? rawArgs[4] : "0")
        this.num := AhkStdlibTkinterEventInteger(rawArgs.Length >= 5 ? rawArgs[5] : "0")
    }
}

class EventType
{
    __New(name)
    {
        this.name := name
    }

    ToString()
    {
        return this.name
    }
}

class AhkStdlibTkinterImage
{
    __New(className, imageType, args*)
    {
        if args.Length > 3
            throw TypeError(className ".__init__() takes from 1 to 4 positional arguments but " args.Length + 1 " were given", -1)

        name := stdlib.None
        options := {}
        master := stdlib.None
        if args.Length = 1 && AhkStdlibTkinterIsPlainKeywordObject(args[1]) {
            options := args[1]
        } else {
            if args.Length >= 1
                name := args[1]
            if args.Length >= 2 {
                if !AhkStdlibTkinterIsPlainKeywordObject(args[2])
                    throw AttributeError("'" AhkStdlibPyTypeName(args[2]) "' object has no attribute 'items'", -1)
                options := args[2]
            }
            if args.Length >= 3
                master := args[3]
        }

        if options.HasOwnProp("name")
            name := options.name
        if options.HasOwnProp("master")
            master := options.master
        if AhkStdlibIsNone(master)
            throw RuntimeError("Too early to create image: no default root window", -1)

        tk := IsObject(master) && HasProp(master, "tk") ? master.tk : master
        if !IsObject(tk) || !HasMethod(tk, "eval")
            throw AttributeError("'" AhkStdlibPyTypeName(master) "' object has no attribute 'call'", -1)

        if AhkStdlibIsNone(name) || name = ""
            name := AhkStdlibTkinterDefaultImageName()
        this.name := name
        this.tk := tk
        this.AhkStdlibRoot := tk._root()
        this.AhkStdlibImageType := imageType
        this.tk.eval("image create " imageType " " AhkStdlibTkinterTclWord(name) AhkStdlibTkinterOptionsToScript(options, false, this.AhkStdlibRoot))
    }

    configure(args*)
    {
        if args.Length > 1
            throw TypeError("Image.configure() takes 1 positional argument but " args.Length + 1 " were given", -1)
        if args.Length = 0
            return stdlib.None
        if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
            throw TypeError("cnf must be a dictionary", -1)
        this.tk.eval(this.name " config" AhkStdlibTkinterOptionsToScript(args[1], false, this.AhkStdlibRoot))
        return stdlib.None
    }

    config(args*)
    {
        return this.configure(args*)
    }

    height(args*)
    {
        if args.Length != 0
            throw TypeError("Image.height() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.tk.eval("image height " AhkStdlibTkinterTclWord(this.name)))
    }

    type(args*)
    {
        if args.Length != 0
            throw TypeError("Image.type() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.tk.eval("image type " AhkStdlibTkinterTclWord(this.name))
    }

    width(args*)
    {
        if args.Length != 0
            throw TypeError("Image.width() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.tk.eval("image width " AhkStdlibTkinterTclWord(this.name)))
    }

    ToString()
    {
        return this.name
    }

    __Delete()
    {
        try {
            if this.HasOwnProp("name") && this.name != ""
                this.tk.eval("image delete " AhkStdlibTkinterTclWord(this.name))
        }
    }
}

class PhotoImage extends AhkStdlibTkinterImage
{
    __New(args*)
    {
        super.__New("PhotoImage", "photo", args*)
    }

    blank(args*)
    {
        if args.Length != 0
            throw TypeError("PhotoImage.blank() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.tk.eval(this.name " blank")
        return stdlib.None
    }

    copy(args*)
    {
        if args.Length != 0
            throw TypeError("PhotoImage.copy() takes 1 positional argument but " args.Length + 1 " were given", -1)
        destImage := PhotoImage({ master: this.tk })
        this.tk.eval(AhkStdlibTkinterTclWord(destImage.name) " copy " AhkStdlibTkinterTclWord(this.name))
        return destImage
    }

    cget(args*)
    {
        if args.Length = 0
            throw TypeError("PhotoImage.cget() missing 1 required positional argument: 'option'", -1)
        if args.Length > 1
            throw TypeError("PhotoImage.cget() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.tk.eval(this.name " cget -" args[1])
    }

    get(args*)
    {
        if args.Length = 0
            throw TypeError("PhotoImage.get() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("PhotoImage.get() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("PhotoImage.get() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        return AhkStdlibTkinterRgbTuple(this.tk.eval(this.name " get " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2])))
    }

    put(args*)
    {
        if args.Length = 0
            throw TypeError("PhotoImage.put() missing 1 required positional argument: 'data'", -1)
        if args.Length > 2
            throw TypeError("PhotoImage.put() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        script := this.name " put " AhkStdlibTkinterTclQuotedWord(args[1])
        if args.Length = 2 {
            to := AhkStdlibTkinterPhotoImageToOption(args[2])
            if AhkStdlibTruthValue(to)
                script := AhkStdlibTkinterAppendToOption(script, to)
        }
        this.tk.eval(script)
        return stdlib.None
    }

    subsample(args*)
    {
        if args.Length = 0
            throw TypeError("PhotoImage.subsample() missing 1 required positional argument: 'x'", -1)
        if args.Length > 2
            throw TypeError("PhotoImage.subsample() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        x := args[1]
        y := args.Length = 1 || args[2] = "" ? x : args[2]
        destImage := PhotoImage({ master: this.tk })
        this.tk.eval(AhkStdlibTkinterTclWord(destImage.name) " copy " AhkStdlibTkinterTclWord(this.name) " -subsample " AhkStdlibTkinterTclWord(x) " " AhkStdlibTkinterTclWord(y))
        return destImage
    }

    transparency_get(args*)
    {
        if args.Length = 0
            throw TypeError("PhotoImage.transparency_get() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("PhotoImage.transparency_get() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("PhotoImage.transparency_get() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        value := this.tk.eval(AhkStdlibTkinterTclWord(this.name) " transparency get " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
        return AhkStdlibTkinterGetBoolean(this.tk.AhkStdlibInterp, value)
    }

    transparency_set(args*)
    {
        if args.Length = 0
            throw TypeError("PhotoImage.transparency_set() missing 3 required positional arguments: 'x', 'y', and 'boolean'", -1)
        if args.Length < 3
            throw TypeError("PhotoImage.transparency_set() missing 1 required positional argument: 'boolean'", -1)
        if args.Length > 3
            throw TypeError("PhotoImage.transparency_set() takes 4 positional arguments but " args.Length + 1 " were given", -1)
        this.tk.eval(AhkStdlibTkinterTclWord(this.name) " transparency set " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]) " " AhkStdlibTkinterTclWord(args[3]))
        return stdlib.None
    }

    write(args*)
    {
        if args.Length = 0
            throw TypeError("PhotoImage.write() missing 1 required positional argument: 'filename'", -1)
        if args.Length > 3
            throw TypeError("PhotoImage.write() takes from 2 to 4 positional arguments but " args.Length + 1 " were given", -1)
        script := AhkStdlibTkinterTclWord(this.name) " write " AhkStdlibTkinterTclWord(args[1])
        if args.Length >= 2 && AhkStdlibTruthValue(args[2])
            script .= " -format " AhkStdlibTkinterTclWord(args[2])
        if args.Length >= 3 && AhkStdlibTruthValue(args[3]) {
            script .= " -from"
            if args[3] is Array {
                for value in args[3]
                    script .= " " AhkStdlibTkinterTclWord(value)
            } else {
                script .= " " AhkStdlibTkinterTclWord(args[3])
            }
        }
        this.tk.eval(script)
        return stdlib.None
    }

    zoom(args*)
    {
        if args.Length = 0
            throw TypeError("PhotoImage.zoom() missing 1 required positional argument: 'x'", -1)
        if args.Length > 2
            throw TypeError("PhotoImage.zoom() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        x := args[1]
        y := args.Length = 1 || args[2] = "" ? x : args[2]
        destImage := PhotoImage({ master: this.tk })
        this.tk.eval(AhkStdlibTkinterTclWord(destImage.name) " copy " AhkStdlibTkinterTclWord(this.name) " -zoom " AhkStdlibTkinterTclWord(x) " " AhkStdlibTkinterTclWord(y))
        return destImage
    }
}

class BitmapImage extends AhkStdlibTkinterImage
{
    __New(args*)
    {
        super.__New("BitmapImage", "bitmap", args*)
    }
}

class Button extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Button", "button", args*)
    }

    invoke(args*)
    {
        if args.Length != 0
            throw TypeError("Button.invoke() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " invoke")
    }
}

class Checkbutton extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Checkbutton", "checkbutton", args*)
    }

    deselect(args*)
    {
        if args.Length != 0
            throw TypeError("Checkbutton.deselect() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " deselect")
        return stdlib.None
    }

    invoke(args*)
    {
        if args.Length != 0
            throw TypeError("Checkbutton.invoke() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " invoke")
    }

    select(args*)
    {
        if args.Length != 0
            throw TypeError("Checkbutton.select() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " select")
        return stdlib.None
    }

    toggle(args*)
    {
        if args.Length != 0
            throw TypeError("Checkbutton.toggle() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " toggle")
        return stdlib.None
    }
}

class Radiobutton extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Radiobutton", "radiobutton", args*)
    }

    deselect(args*)
    {
        if args.Length != 0
            throw TypeError("Radiobutton.deselect() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " deselect")
        return stdlib.None
    }

    flash(args*)
    {
        if args.Length != 0
            throw TypeError("Radiobutton.flash() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " flash")
        return stdlib.None
    }

    invoke(args*)
    {
        if args.Length != 0
            throw TypeError("Radiobutton.invoke() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " invoke")
    }

    select(args*)
    {
        if args.Length != 0
            throw TypeError("Radiobutton.select() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " select")
        return stdlib.None
    }
}

class Scale extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Scale", "scale", args*)
    }

    coords(args*)
    {
        if args.Length > 1
            throw TypeError("Scale.coords() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " coords"
        if args.Length = 1
            script .= " " AhkStdlibTkinterTclWord(args[1])
        return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(script))
    }

    get(args*)
    {
        if args.Length != 0
            throw TypeError("Scale.get() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Float(this.AhkStdlibRoot.eval(this._w " get"))
    }

    identify(args*)
    {
        if args.Length = 0
            throw TypeError("Scale.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("Scale.identify() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("Scale.identify() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " identify " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
    }

    set(args*)
    {
        if args.Length = 0
            throw TypeError("Scale.set() missing 1 required positional argument: 'value'", -1)
        if args.Length > 1
            throw TypeError("Scale.set() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " set " AhkStdlibTkinterTclWord(args[1]))
        return stdlib.None
    }
}

class Scrollbar extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Scrollbar", "scrollbar", args*)
    }

    activate(args*)
    {
        if args.Length > 1
            throw TypeError("Scrollbar.activate() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " activate"
        if args.Length = 1 {
            this.AhkStdlibRoot.eval(script " " AhkStdlibTkinterTclWord(args[1]))
            return stdlib.None
        }
        value := this.AhkStdlibRoot.eval(script)
        return value = "" ? stdlib.None : value
    }

    cget(args*)
    {
        if args.Length = 0
            throw TypeError("Misc.cget() missing 1 required positional argument: 'key'", -1)
        if args.Length > 1
            throw TypeError("Misc.cget() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " cget -" args[1])
    }

    delta(args*)
    {
        if args.Length = 0
            throw TypeError("Scrollbar.delta() missing 2 required positional arguments: 'deltax' and 'deltay'", -1)
        if args.Length = 1
            throw TypeError("Scrollbar.delta() missing 1 required positional argument: 'deltay'", -1)
        if args.Length > 2
            throw TypeError("Scrollbar.delta() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        return Float(this.AhkStdlibRoot.eval(this._w " delta " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2])))
    }

    fraction(args*)
    {
        if args.Length = 0
            throw TypeError("Scrollbar.fraction() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("Scrollbar.fraction() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("Scrollbar.fraction() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        return Float(this.AhkStdlibRoot.eval(this._w " fraction " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2])))
    }

    get(args*)
    {
        if args.Length != 0
            throw TypeError("Scrollbar.get() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return AhkStdlibTkinterFloatTuple(this.AhkStdlibRoot.eval(this._w " get"))
    }

    identify(args*)
    {
        if args.Length = 0
            throw TypeError("Scrollbar.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("Scrollbar.identify() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("Scrollbar.identify() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " identify " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
    }

    set(args*)
    {
        if args.Length = 0
            throw TypeError("Scrollbar.set() missing 2 required positional arguments: 'first' and 'last'", -1)
        if args.Length = 1
            throw TypeError("Scrollbar.set() missing 1 required positional argument: 'last'", -1)
        if args.Length > 2
            throw TypeError("Scrollbar.set() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " set " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
        return stdlib.None
    }
}

class Menu extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Menu", "menu", args*)
    }

    add_command(args*)
    {
        if args.Length > 1
            throw TypeError("Menu.add_command() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 {
            this.AhkStdlibRoot.eval(this._w " add command")
            return stdlib.None
        }
        if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
            throw TypeError("object of type '" AhkStdlibPyTypeName(args[1]) "' has no len()", -1)
        this.AhkStdlibRoot.eval(this._w " add command" AhkStdlibTkinterOptionsToScript(args[1], false, this.AhkStdlibRoot))
        return stdlib.None
    }

    delete(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.delete() missing 1 required positional argument: 'index1'", -1)
        if args.Length > 2
            throw TypeError("Menu.delete() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " delete " AhkStdlibTkinterTclWord(args[1])
        if args.Length = 2
            script .= " " AhkStdlibTkinterTclWord(args[2])
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    entrycget(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.entrycget() missing 2 required positional arguments: 'index' and 'option'", -1)
        if args.Length = 1
            throw TypeError("Menu.entrycget() missing 1 required positional argument: 'option'", -1)
        if args.Length > 2
            throw TypeError("Menu.entrycget() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " entrycget " AhkStdlibTkinterTclWord(args[1]) " -" args[2])
    }

    entryconfigure(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.entryconfigure() missing 1 required positional argument: 'index'", -1)
        if args.Length > 2
            throw TypeError("Menu.entryconfigure() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 1
            return stdlib.None
        if !AhkStdlibTkinterIsPlainKeywordObject(args[2])
            throw TypeError("cnf must be a dictionary", -1)
        this.AhkStdlibRoot.eval(this._w " entryconfigure " AhkStdlibTkinterTclWord(args[1]) AhkStdlibTkinterOptionsToScript(args[2], false, this.AhkStdlibRoot))
        return stdlib.None
    }

    entryconfig(args*)
    {
        return this.entryconfigure(args*)
    }

    index(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.index() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Menu.index() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        value := this.AhkStdlibRoot.eval(this._w " index " AhkStdlibTkinterTclWord(args[1]))
        if value = "none"
            return stdlib.None
        return Integer(value)
    }

    invoke(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.invoke() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Menu.invoke() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " invoke " AhkStdlibTkinterTclWord(args[1]))
    }
}

class Menubutton extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Menubutton", "menubutton", args*)
    }
}

class Message extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Message", "message", args*)
    }
}

class Canvas extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Canvas", "canvas", args*)
    }

    cget(args*)
    {
        if args.Length = 0
            throw TypeError("Misc.cget() missing 1 required positional argument: 'key'", -1)
        if args.Length > 1
            throw TypeError("Misc.cget() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " cget -" args[1])
    }

    create_arc(args*)
    {
        return AhkStdlibTkinterCanvasCreateItem(this, "arc", args*)
    }

    create_bitmap(args*)
    {
        return AhkStdlibTkinterCanvasCreateItem(this, "bitmap", args*)
    }

    create_line(args*)
    {
        return AhkStdlibTkinterCanvasCreateItem(this, "line", args*)
    }

    create_image(args*)
    {
        return AhkStdlibTkinterCanvasCreateItem(this, "image", args*)
    }

    create_oval(args*)
    {
        return AhkStdlibTkinterCanvasCreateItem(this, "oval", args*)
    }

    create_polygon(args*)
    {
        return AhkStdlibTkinterCanvasCreateItem(this, "polygon", args*)
    }

    create_rectangle(args*)
    {
        return AhkStdlibTkinterCanvasCreateItem(this, "rectangle", args*)
    }

    create_text(args*)
    {
        return AhkStdlibTkinterCanvasCreateItem(this, "text", args*)
    }

    create_window(args*)
    {
        return AhkStdlibTkinterCanvasCreateItem(this, "window", args*)
    }

    dchars(args*)
    {
        script := this._w " dchars"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    focus(args*)
    {
        script := this._w " focus"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        value := this.AhkStdlibRoot.eval(script)
        if args.Length = 0 && value != ""
            return Integer(value)
        return value
    }

    icursor(args*)
    {
        script := this._w " icursor"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    index(args*)
    {
        script := this._w " index"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        return Integer(this.AhkStdlibRoot.eval(script))
    }

    insert(args*)
    {
        script := this._w " insert"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    coords(args*)
    {
        script := this._w " coords"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        return AhkStdlibTkinterCanvasCoordList(this.AhkStdlibRoot.eval(script))
    }

    find(args*)
    {
        script := this._w " find"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(script))
    }

    find_all(args*)
    {
        if args.Length != 0
            throw TypeError("Canvas.find_all() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.find("all")
    }

    find_above(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.find_above", args.Length, 1, 1, ["tagOrId"])
        return this.find("above", args[1])
    }

    find_below(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.find_below", args.Length, 1, 1, ["tagOrId"])
        return this.find("below", args[1])
    }

    find_closest(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.find_closest", args.Length, 2, 4, ["x", "y"])
        script := this._w " find closest " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2])
        if args.Length >= 3 && !AhkStdlibIsNone(args[3])
            script .= " " AhkStdlibTkinterTclWord(args[3])
        if args.Length >= 4 && !AhkStdlibIsNone(args[4])
            script .= " " AhkStdlibTkinterTclWord(args[4])
        return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(script))
    }

    find_enclosed(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.find_enclosed", args.Length, 4, 4, ["x1", "y1", "x2", "y2"])
        return this.find("enclosed", args[1], args[2], args[3], args[4])
    }

    find_overlapping(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.find_overlapping", args.Length, 4, 4, ["x1", "y1", "x2", "y2"])
        return this.find("overlapping", args[1], args[2], args[3], args[4])
    }

    find_withtag(args*)
    {
        if args.Length = 0
            throw TypeError("Canvas.find_withtag() missing 1 required positional argument: 'tagOrId'", -1)
        if args.Length > 1
            throw TypeError("Canvas.find_withtag() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.find("withtag", args[1])
    }

    bbox(args*)
    {
        script := this._w " bbox"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        value := this.AhkStdlibRoot.eval(script)
        if Trim(value) = ""
            return stdlib.None
        return AhkStdlibTkinterIntegerTuple(value)
    }

    move(args*)
    {
        script := this._w " move"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    moveto(args*)
    {
        if args.Length = 0
            throw TypeError("Canvas.moveto() missing 1 required positional argument: 'tagOrId'", -1)
        if args.Length > 3
            throw TypeError("Canvas.moveto() takes from 2 to 4 positional arguments but " args.Length + 1 " were given", -1)
        x := args.Length >= 2 ? args[2] : ""
        y := args.Length >= 3 ? args[3] : ""
        this.AhkStdlibRoot.eval(this._w " moveto " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(x) " " AhkStdlibTkinterTclWord(y))
        return stdlib.None
    }

    type(args*)
    {
        if args.Length = 0
            throw TypeError("Canvas.type() missing 1 required positional argument: 'tagOrId'", -1)
        if args.Length > 1
            throw TypeError("Canvas.type() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        value := this.AhkStdlibRoot.eval(this._w " type " AhkStdlibTkinterTclWord(args[1]))
        return value = "" ? stdlib.None : value
    }

    itemcget(args*)
    {
        if args.Length = 0
            throw TypeError("Canvas.itemcget() missing 2 required positional arguments: 'tagOrId' and 'option'", -1)
        if args.Length = 1
            throw TypeError("Canvas.itemcget() missing 1 required positional argument: 'option'", -1)
        if args.Length > 2
            throw TypeError("Canvas.itemcget() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " itemcget " AhkStdlibTkinterTclWord(args[1]) " -" args[2])
    }

    itemconfigure(args*)
    {
        if args.Length = 0
            throw TypeError("Canvas.itemconfigure() missing 1 required positional argument: 'tagOrId'", -1)
        if args.Length > 2
            throw TypeError("Canvas.itemconfigure() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 1
            return stdlib.None
        if !AhkStdlibTkinterIsPlainKeywordObject(args[2])
            throw TypeError("cnf must be a dictionary", -1)
        this.AhkStdlibRoot.eval(this._w " itemconfigure " AhkStdlibTkinterTclWord(args[1]) AhkStdlibTkinterOptionsToScript(args[2], false, this.AhkStdlibRoot))
        return stdlib.None
    }

    itemconfig(args*)
    {
        return this.itemconfigure(args*)
    }

    postscript(args*)
    {
        if args.Length > 1
            throw TypeError("Canvas.postscript() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " postscript"
        if args.Length = 1 {
            if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
                throw TypeError("object of type '" AhkStdlibPyTypeName(args[1]) "' has no len()", -1)
            script .= AhkStdlibTkinterOptionsToScript(args[1], false)
        }
        return this.AhkStdlibRoot.eval(script)
    }

    delete(args*)
    {
        script := this._w " delete"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    addtag(args*)
    {
        script := this._w " addtag"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    addtag_above(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.addtag_above", args.Length, 2, 2, ["newtag", "tagOrId"])
        return this.addtag(args[1], "above", args[2])
    }

    addtag_all(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.addtag_all", args.Length, 1, 1, ["newtag"])
        return this.addtag(args[1], "all")
    }

    addtag_below(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.addtag_below", args.Length, 2, 2, ["newtag", "tagOrId"])
        return this.addtag(args[1], "below", args[2])
    }

    addtag_closest(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.addtag_closest", args.Length, 3, 5, ["newtag", "x", "y"])
        script := this._w " addtag " AhkStdlibTkinterTclWord(args[1]) " closest " AhkStdlibTkinterTclWord(args[2]) " " AhkStdlibTkinterTclWord(args[3])
        if args.Length >= 4 && !AhkStdlibIsNone(args[4])
            script .= " " AhkStdlibTkinterTclWord(args[4])
        if args.Length >= 5 && !AhkStdlibIsNone(args[5])
            script .= " " AhkStdlibTkinterTclWord(args[5])
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    addtag_enclosed(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.addtag_enclosed", args.Length, 5, 5, ["newtag", "x1", "y1", "x2", "y2"])
        return this.addtag(args[1], "enclosed", args[2], args[3], args[4], args[5])
    }

    addtag_overlapping(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.addtag_overlapping", args.Length, 5, 5, ["newtag", "x1", "y1", "x2", "y2"])
        return this.addtag(args[1], "overlapping", args[2], args[3], args[4], args[5])
    }

    addtag_withtag(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.addtag_withtag", args.Length, 2, 2, ["newtag", "tagOrId"])
        return this.addtag(args[1], "withtag", args[2])
    }

    tag_raise(args*)
    {
        script := this._w " raise"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    tag_lower(args*)
    {
        script := this._w " lower"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    tag_bind(args*)
    {
        if args.Length = 0
            throw TypeError("Canvas.tag_bind() missing 1 required positional argument: 'tagOrId'", -1)
        if args.Length > 4
            throw TypeError("Canvas.tag_bind() takes from 2 to 5 positional arguments but " args.Length + 1 " were given", -1)

        tagWord := AhkStdlibTkinterTclWord(args[1])
        if args.Length = 1 || AhkStdlibIsNone(args[2])
            return stdlib.tuple(AhkStdlibTkinterSimpleList(this.AhkStdlibRoot.eval(this._w " bind " tagWord)))

        sequence := args[2]
        if args.Length = 2 || AhkStdlibIsNone(args[3])
            return this.AhkStdlibRoot.eval(this._w " bind " tagWord " " AhkStdlibTkinterTclWord(sequence))

        commandName := AhkStdlibTkinterRegisterEventCommand(this.AhkStdlibRoot, this, args[3], sequence)
        addPrefix := args.Length >= 4 && args[4] = "+" ? "+" : ""
        script := addPrefix "if {`"[" commandName " %W %T %x %y %b]`" == `"break`"} break"
        this.AhkStdlibRoot.eval(this._w " bind " tagWord " " AhkStdlibTkinterTclWord(sequence) " " AhkStdlibTkinterTclScriptWord(script))
        return commandName
    }

    tag_unbind(args*)
    {
        if args.Length = 0
            throw TypeError("Canvas.tag_unbind() missing 2 required positional arguments: 'tagOrId' and 'sequence'", -1)
        if args.Length = 1
            throw TypeError("Canvas.tag_unbind() missing 1 required positional argument: 'sequence'", -1)
        if args.Length > 3
            throw TypeError("Canvas.tag_unbind() takes from 3 to 4 positional arguments but " args.Length + 1 " were given", -1)

        this.AhkStdlibRoot.eval(this._w " bind " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]) " {}")
        if args.Length = 3 && !AhkStdlibIsNone(args[3])
            AhkStdlibTkinterDeleteCommand(this.AhkStdlibRoot, args[3], "can't delete Tcl command")
        return stdlib.None
    }

    dtag(args*)
    {
        script := this._w " dtag"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    gettags(args*)
    {
        script := this._w " gettags"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(script)))
    }

    select_adjust(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.select_adjust", args.Length, 2, 2, ["tagOrId", "index"])
        this.AhkStdlibRoot.eval(this._w " select adjust " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
        return stdlib.None
    }

    select_clear(args*)
    {
        if args.Length != 0
            throw TypeError("Canvas.select_clear() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " select clear")
        return stdlib.None
    }

    select_from(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.select_from", args.Length, 2, 2, ["tagOrId", "index"])
        this.AhkStdlibRoot.eval(this._w " select from " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
        return stdlib.None
    }

    select_item(args*)
    {
        if args.Length != 0
            throw TypeError("Canvas.select_item() takes 1 positional argument but " args.Length + 1 " were given", -1)
        value := this.AhkStdlibRoot.eval(this._w " select item")
        return value = "" ? stdlib.None : Integer(value)
    }

    select_to(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.select_to", args.Length, 2, 2, ["tagOrId", "index"])
        this.AhkStdlibRoot.eval(this._w " select to " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
        return stdlib.None
    }

    scale(args*)
    {
        script := this._w " scale"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    scan_mark(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.scan_mark", args.Length, 2, 2, ["x", "y"])
        this.AhkStdlibRoot.eval(this._w " scan mark " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
        return stdlib.None
    }

    scan_dragto(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.scan_dragto", args.Length, 2, 3, ["x", "y"])
        gain := args.Length = 3 ? args[3] : 10
        this.AhkStdlibRoot.eval(this._w " scan dragto " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]) " " AhkStdlibTkinterTclWord(gain))
        return stdlib.None
    }

    canvasx(args*)
    {
        if args.Length = 0
            throw TypeError("Canvas.canvasx() missing 1 required positional argument: 'screenx'", -1)
        if args.Length > 2
            throw TypeError("Canvas.canvasx() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

        script := this._w " canvasx " AhkStdlibTkinterTclWord(args[1])
        if args.Length = 2 && !AhkStdlibIsNone(args[2])
            script .= " " AhkStdlibTkinterTclWord(args[2])
        return AhkStdlibTkinterGetDouble(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(script))
    }

    canvasy(args*)
    {
        if args.Length = 0
            throw TypeError("Canvas.canvasy() missing 1 required positional argument: 'screeny'", -1)
        if args.Length > 2
            throw TypeError("Canvas.canvasy() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

        script := this._w " canvasy " AhkStdlibTkinterTclWord(args[1])
        if args.Length = 2 && !AhkStdlibIsNone(args[2])
            script .= " " AhkStdlibTkinterTclWord(args[2])
        return AhkStdlibTkinterGetDouble(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(script))
    }

    xview(args*)
    {
        script := this._w " xview"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        value := this.AhkStdlibRoot.eval(script)
        return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
    }

    xview_moveto(args*)
    {
        if args.Length = 0
            throw TypeError("XView.xview_moveto() missing 1 required positional argument: 'fraction'", -1)
        if args.Length > 1
            throw TypeError("XView.xview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)

        this.AhkStdlibRoot.eval(this._w " xview moveto " AhkStdlibTkinterTclWord(args[1]))
        return stdlib.None
    }

    xview_scroll(args*)
    {
        if args.Length = 0
            throw TypeError("XView.xview_scroll() missing 2 required positional arguments: 'number' and 'what'", -1)
        if args.Length = 1
            throw TypeError("XView.xview_scroll() missing 1 required positional argument: 'what'", -1)
        if args.Length > 2
            throw TypeError("XView.xview_scroll() takes 3 positional arguments but " args.Length + 1 " were given", -1)

        this.AhkStdlibRoot.eval(this._w " xview scroll " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
        return stdlib.None
    }

    yview(args*)
    {
        script := this._w " yview"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        value := this.AhkStdlibRoot.eval(script)
        return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
    }

    yview_moveto(args*)
    {
        if args.Length = 0
            throw TypeError("YView.yview_moveto() missing 1 required positional argument: 'fraction'", -1)
        if args.Length > 1
            throw TypeError("YView.yview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)

        this.AhkStdlibRoot.eval(this._w " yview moveto " AhkStdlibTkinterTclWord(args[1]))
        return stdlib.None
    }

    yview_scroll(args*)
    {
        if args.Length = 0
            throw TypeError("YView.yview_scroll() missing 2 required positional arguments: 'number' and 'what'", -1)
        if args.Length = 1
            throw TypeError("YView.yview_scroll() missing 1 required positional argument: 'what'", -1)
        if args.Length > 2
            throw TypeError("YView.yview_scroll() takes 3 positional arguments but " args.Length + 1 " were given", -1)

        this.AhkStdlibRoot.eval(this._w " yview scroll " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
        return stdlib.None
    }
}

class Text extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Text", "text", args*)
    }

    insert(args*)
    {
        if args.Length = 0
            throw TypeError("Text.insert() missing 2 required positional arguments: 'index' and 'chars'", -1)
        if args.Length = 1
            throw TypeError("Text.insert() missing 1 required positional argument: 'chars'", -1)
        script := this._w " insert " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2])
        index := 3
        while index <= args.Length {
            script .= " " AhkStdlibTkinterTclWord(args[index])
            index += 1
        }
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    get(args*)
    {
        if args.Length = 0
            throw TypeError("Text.get() missing 1 required positional argument: 'index1'", -1)
        if args.Length > 2
            throw TypeError("Text.get() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " get " AhkStdlibTkinterTclWord(args[1])
        if args.Length = 2
            script .= " " AhkStdlibTkinterTclWord(args[2])
        return this.AhkStdlibRoot.eval(script)
    }

    delete(args*)
    {
        if args.Length = 0
            throw TypeError("Text.delete() missing 1 required positional argument: 'index1'", -1)
        if args.Length > 2
            throw TypeError("Text.delete() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " delete " AhkStdlibTkinterTclWord(args[1])
        if args.Length = 2
            script .= " " AhkStdlibTkinterTclWord(args[2])
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    index(args*)
    {
        if args.Length = 0
            throw TypeError("Text.index() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Text.index() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " index " AhkStdlibTkinterTclWord(args[1]))
    }
}

class Entry extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Entry", "entry", args*)
    }

    get(args*)
    {
        if args.Length != 0
            throw TypeError("Entry.get() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " get")
    }

    insert(args*)
    {
        if args.Length = 0
            throw TypeError("Entry.insert() missing 2 required positional arguments: 'index' and 'string'", -1)
        if args.Length = 1
            throw TypeError("Entry.insert() missing 1 required positional argument: 'string'", -1)
        if args.Length > 2
            throw TypeError("Entry.insert() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " insert " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
        return stdlib.None
    }

    delete(args*)
    {
        if args.Length = 0
            throw TypeError("Entry.delete() missing 1 required positional argument: 'first'", -1)
        if args.Length > 2
            throw TypeError("Entry.delete() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " delete " AhkStdlibTkinterTclWord(args[1])
        if args.Length = 2
            script .= " " AhkStdlibTkinterTclWord(args[2])
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    icursor(args*)
    {
        if args.Length = 0
            throw TypeError("Entry.icursor() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Entry.icursor() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " icursor " AhkStdlibTkinterTclWord(args[1]))
        return stdlib.None
    }

    index(args*)
    {
        if args.Length = 0
            throw TypeError("Entry.index() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Entry.index() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval(this._w " index " AhkStdlibTkinterTclWord(args[1])))
    }

    select_adjust(args*)
    {
        return AhkStdlibTkinterEntrySelectionIndex(this, "Entry.selection_adjust()", "adjust", args*)
    }

    select_clear(args*)
    {
        return AhkStdlibTkinterEntrySelectionClear(this, "Entry.selection_clear()", args*)
    }

    select_from(args*)
    {
        return AhkStdlibTkinterEntrySelectionIndex(this, "Entry.selection_from()", "from", args*)
    }

    select_present(args*)
    {
        return AhkStdlibTkinterEntrySelectionPresent(this, "Entry.selection_present()", args*)
    }

    select_range(args*)
    {
        return AhkStdlibTkinterEntrySelectionRange(this, "Entry.selection_range()", args*)
    }

    select_to(args*)
    {
        return AhkStdlibTkinterEntrySelectionIndex(this, "Entry.selection_to()", "to", args*)
    }

    selection_adjust(args*)
    {
        return AhkStdlibTkinterEntrySelectionIndex(this, "Entry.selection_adjust()", "adjust", args*)
    }

    selection_clear(args*)
    {
        return AhkStdlibTkinterEntrySelectionClear(this, "Entry.selection_clear()", args*)
    }

    selection_from(args*)
    {
        return AhkStdlibTkinterEntrySelectionIndex(this, "Entry.selection_from()", "from", args*)
    }

    selection_present(args*)
    {
        return AhkStdlibTkinterEntrySelectionPresent(this, "Entry.selection_present()", args*)
    }

    selection_range(args*)
    {
        return AhkStdlibTkinterEntrySelectionRange(this, "Entry.selection_range()", args*)
    }

    selection_to(args*)
    {
        return AhkStdlibTkinterEntrySelectionIndex(this, "Entry.selection_to()", "to", args*)
    }
}

class Spinbox extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Spinbox", "spinbox", args*)
    }

    bbox(args*)
    {
        if args.Length = 0
            throw TypeError("Spinbox.bbox() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Spinbox.bbox() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(this._w " bbox " AhkStdlibTkinterTclWord(args[1])))
    }

    delete(args*)
    {
        if args.Length = 0
            throw TypeError("Spinbox.delete() missing 1 required positional argument: 'first'", -1)
        if args.Length > 2
            throw TypeError("Spinbox.delete() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " delete " AhkStdlibTkinterTclWord(args[1])
        if args.Length = 2
            script .= " " AhkStdlibTkinterTclWord(args[2])
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    get(args*)
    {
        if args.Length != 0
            throw TypeError("Spinbox.get() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " get")
    }

    icursor(args*)
    {
        if args.Length = 0
            throw TypeError("Spinbox.icursor() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Spinbox.icursor() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " icursor " AhkStdlibTkinterTclWord(args[1]))
        return stdlib.None
    }

    identify(args*)
    {
        if args.Length = 0
            throw TypeError("Spinbox.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("Spinbox.identify() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("Spinbox.identify() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " identify " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
    }

    index(args*)
    {
        if args.Length = 0
            throw TypeError("Spinbox.index() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Spinbox.index() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval(this._w " index " AhkStdlibTkinterTclWord(args[1])))
    }

    insert(args*)
    {
        if args.Length = 0
            throw TypeError("Spinbox.insert() missing 2 required positional arguments: 'index' and 's'", -1)
        if args.Length = 1
            throw TypeError("Spinbox.insert() missing 1 required positional argument: 's'", -1)
        if args.Length > 2
            throw TypeError("Spinbox.insert() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " insert " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
        return stdlib.None
    }

    invoke(args*)
    {
        if args.Length = 0
            throw TypeError("Spinbox.invoke() missing 1 required positional argument: 'element'", -1)
        if args.Length > 1
            throw TypeError("Spinbox.invoke() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " invoke " AhkStdlibTkinterTclWord(args[1]))
        return stdlib.None
    }

    selection_clear(args*)
    {
        return AhkStdlibTkinterEntrySelectionClear(this, "Spinbox.selection_clear()", args*)
    }

    selection_element(args*)
    {
        if args.Length > 1
            throw TypeError("Spinbox.selection_element() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0
            return this.AhkStdlibRoot.eval(this._w " selection element")
        this.AhkStdlibRoot.eval(this._w " selection element " AhkStdlibTkinterTclWord(args[1]))
        return stdlib.None
    }

    selection_present(args*)
    {
        return AhkStdlibTkinterEntrySelectionPresent(this, "Spinbox.selection_present()", args*)
    }

    selection_range(args*)
    {
        return AhkStdlibTkinterEntrySelectionRange(this, "Spinbox.selection_range()", args*)
    }

    xview(args*)
    {
        script := this._w " xview"
        for value in args
            script .= " " AhkStdlibTkinterTclWord(value)
        value := this.AhkStdlibRoot.eval(script)
        return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
    }

    xview_moveto(args*)
    {
        if args.Length = 0
            throw TypeError("XView.xview_moveto() missing 1 required positional argument: 'fraction'", -1)
        if args.Length > 1
            throw TypeError("XView.xview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " xview moveto " AhkStdlibTkinterTclWord(args[1]))
        return stdlib.None
    }

    xview_scroll(args*)
    {
        if args.Length = 0
            throw TypeError("XView.xview_scroll() missing 2 required positional arguments: 'number' and 'what'", -1)
        if args.Length = 1
            throw TypeError("XView.xview_scroll() missing 1 required positional argument: 'what'", -1)
        if args.Length > 2
            throw TypeError("XView.xview_scroll() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " xview scroll " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
        return stdlib.None
    }
}

class Listbox extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Listbox", "listbox", args*)
    }

    curselection(args*)
    {
        if args.Length != 0
            throw TypeError("Listbox.curselection() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(this._w " curselection"))
    }

    delete(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.delete() missing 1 required positional argument: 'first'", -1)
        if args.Length > 2
            throw TypeError("Listbox.delete() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " delete " AhkStdlibTkinterTclWord(args[1])
        if args.Length = 2
            script .= " " AhkStdlibTkinterTclWord(args[2])
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    get(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.get() missing 1 required positional argument: 'first'", -1)
        if args.Length > 2
            throw TypeError("Listbox.get() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " get " AhkStdlibTkinterTclWord(args[1])
        if args.Length = 1
            return this.AhkStdlibRoot.eval(script)
        script .= " " AhkStdlibTkinterTclWord(args[2])
        return stdlib.tuple(AhkStdlibTkinterSimpleList(this.AhkStdlibRoot.eval(script)))
    }

    index(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.index() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Listbox.index() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        value := this.AhkStdlibRoot.eval(this._w " index " AhkStdlibTkinterTclWord(args[1]))
        if value = "none"
            return stdlib.None
        return Integer(value)
    }

    insert(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.insert() missing 1 required positional argument: 'index'", -1)
        script := this._w " insert " AhkStdlibTkinterTclWord(args[1])
        index := 2
        while index <= args.Length {
            script .= " " AhkStdlibTkinterTclWord(args[index])
            index += 1
        }
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    selection_clear(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.selection_clear() missing 1 required positional argument: 'first'", -1)
        if args.Length > 2
            throw TypeError("Listbox.selection_clear() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " selection clear " AhkStdlibTkinterTclWord(args[1])
        if args.Length = 2
            script .= " " AhkStdlibTkinterTclWord(args[2])
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    selection_includes(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.selection_includes() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Listbox.selection_includes() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(this._w " selection includes " AhkStdlibTkinterTclWord(args[1])) = "1" ? stdlib.True : stdlib.False
    }

    selection_set(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.selection_set() missing 1 required positional argument: 'first'", -1)
        if args.Length > 2
            throw TypeError("Listbox.selection_set() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " selection set " AhkStdlibTkinterTclWord(args[1])
        if args.Length = 2
            script .= " " AhkStdlibTkinterTclWord(args[2])
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    size(args*)
    {
        if args.Length != 0
            throw TypeError("Listbox.size() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval(this._w " size"))
    }
}

class AhkStdlibTkinterVariable
{
    __New(className, defaultValue, args*)
    {
        hasMaster := false
        master := stdlib.None
        hasValue := false
        value := stdlib.None
        hasName := false
        name := ""

        if args.Length = 1 && AhkStdlibTkinterIsPlainKeywordObject(args[1]) {
            options := args[1]
            for key, optionValue in options.OwnProps() {
                switch key {
                    case "master":
                        hasMaster := true
                        master := optionValue
                    case "value":
                        hasValue := true
                        value := optionValue
                    case "name":
                        hasName := true
                        name := optionValue
                    default:
                        throw TypeError(className ".__init__() got an unexpected keyword argument '" key "'", -1)
                }
            }
        } else {
            if args.Length > 3
                throw TypeError(className ".__init__() takes from 1 to 4 positional arguments but " args.Length + 1 " were given", -1)
            if args.Length >= 1 {
                hasMaster := true
                master := args[1]
            }
            if args.Length >= 2 {
                hasValue := true
                value := args[2]
            }
            if args.Length >= 3 {
                hasName := true
                name := args[3]
            }
        }

        if !hasMaster
            throw RuntimeError("Too early to create variable: no default root window", -1)
        if !HasMethod(master, "_root")
            throw AttributeError("'" AhkStdlibPyTypeName(master) "' object has no attribute '_root'", -1)

        this._tk := master._root()
        this._master := master
        this._name := AhkStdlibTkinterResolveVarName(hasName, name)
        if hasValue && !AhkStdlibIsNone(value)
            this.set(value)
        else if !AhkStdlibTkinterVarExists(this._tk.AhkStdlibInterp, this._name)
            this.set(defaultValue)
    }

    ToString()
    {
        return this._name
    }

    initialize(value)
    {
        return this.set(value)
    }

    trace_add(args*)
    {
        return AhkStdlibTkinterVariableTraceAdd(this, args*)
    }

    trace_remove(args*)
    {
        return AhkStdlibTkinterVariableTraceRemove(this, args*)
    }

    trace_info(args*)
    {
        return AhkStdlibTkinterVariableTraceInfo(this, args*)
    }

    trace_variable(args*)
    {
        return AhkStdlibTkinterVariableTraceVariable(this, args*)
    }

    trace_vdelete(args*)
    {
        return AhkStdlibTkinterVariableTraceVdelete(this, args*)
    }

    trace_vinfo(args*)
    {
        return AhkStdlibTkinterVariableTraceVinfo(this, args*)
    }
}

class AhkStdlibTkinterPublicVariable extends AhkStdlibTkinterVariable
{
    __New(args*)
    {
        super.__New("Variable", "", args*)
    }

    get()
    {
        return this._tk.getvar(this._name)
    }

    set(value)
    {
        this._tk.setvar(this._name, AhkStdlibTkinterValueToString(value))
        return stdlib.None
    }
}

class AhkStdlibTkinterStringVar extends AhkStdlibTkinterVariable
{
    __New(args*)
    {
        super.__New("StringVar", "", args*)
    }

    get()
    {
        return this._tk.getvar(this._name)
    }

    set(value)
    {
        this._tk.setvar(this._name, AhkStdlibTkinterValueToString(value))
        return stdlib.None
    }
}

class AhkStdlibTkinterIntVar extends AhkStdlibTkinterVariable
{
    __New(args*)
    {
        super.__New("IntVar", 0, args*)
    }

    get()
    {
        value := this._tk.getvar(this._name)
        return AhkStdlibTkinterTruncateFloat(AhkStdlibTkinterGetDouble(this._tk.AhkStdlibInterp, value))
    }

    set(value)
    {
        this._tk.setvar(this._name, AhkStdlibTkinterIntVarValueToString(value))
        return stdlib.None
    }
}

class AhkStdlibTkinterDoubleVar extends AhkStdlibTkinterVariable
{
    __New(args*)
    {
        super.__New("DoubleVar", 0.0, args*)
    }

    get()
    {
        value := this._tk.getvar(this._name)
        return AhkStdlibTkinterGetDouble(this._tk.AhkStdlibInterp, value)
    }

    set(value)
    {
        this._tk.setvar(this._name, AhkStdlibTkinterValueToString(value))
        return stdlib.None
    }
}

class AhkStdlibTkinterBooleanVar extends AhkStdlibTkinterVariable
{
    __New(args*)
    {
        super.__New("BooleanVar", stdlib.False, args*)
    }

    get()
    {
        try {
            value := this._tk.getvar(this._name)
            return AhkStdlibTkinterGetBoolean(this._tk.AhkStdlibInterp, value)
        } catch as err {
            if err is AhkStdlibTkinter.TclError
                throw ValueError("invalid literal for getboolean()", -1)
            throw err
        }
    }

    set(value)
    {
        boolValue := AhkStdlibTkinterGetBoolean(this._tk.AhkStdlibInterp, value)
        this._tk.setvar(this._name, boolValue.Value ? "1" : "0")
        return stdlib.None
    }
}

stdlib.tkinter := AhkStdlibTkinter

AhkStdlibTkinterIsPlainKeywordObject(value)
{
    return IsObject(value) && Type(value) = "Object"
}

AhkStdlibTkinterNormalizeBool(value)
{
    if (value is Integer) || AhkStdlibIsBool(value)
        return value is Integer ? value : value.Value
    throw TypeError("'" AhkStdlibPyTypeName(value) "' object cannot be interpreted as an integer", -1)
}

AhkStdlibTkinterEnsureTclRuntime(loadTk := false)
{
    static tclInitialized := false
    static tclStartupError := ""
    static tkInitialized := false
    static tkStartupError := ""

    if tclInitialized {
        if tclStartupError != ""
            throw RuntimeError(tclStartupError, -1)
    } else {
        tclInitialized := true
        try {
            tclDll := AhkStdlibTkinterFindBundledRuntimeFile("tcl86t.dll")
            if tclDll = ""
                tclDll := AhkStdlibTkinterFindPyRuntimeFile("DLLs\tcl86t.dll")
            if tclDll = ""
                tclDll := AhkStdlibTkinterFindLegacyTkinterRuntimeFile("tkinter\lib\tcl86t.dll")
            if tclDll = ""
                throw Error("Unable to locate tcl86t.dll")
            DllCall("LoadLibrary", "Str", tclDll, "Ptr")

            tclLibrary := AhkStdlibTkinterFindPyRuntimeFile("tcl\tcl8.6")
            if tclLibrary = ""
                throw Error("Unable to locate Tcl script library")
            EnvSet("TCL_LIBRARY", tclLibrary)
        } catch as err {
            tclStartupError := err.Message
            throw RuntimeError(tclStartupError, -1)
        }
    }

    if !loadTk
        return

    if tkInitialized {
        if tkStartupError != ""
            throw RuntimeError(tkStartupError, -1)
        return
    }

    tkInitialized := true
    try {
        tkDll := AhkStdlibTkinterFindBundledRuntimeFile("tk86t.dll")
        if tkDll = ""
            tkDll := AhkStdlibTkinterFindPyRuntimeFile("DLLs\tk86t.dll")
        if tkDll = ""
            tkDll := AhkStdlibTkinterFindLegacyTkinterRuntimeFile("tkinter\lib\tk86t.dll")
        if tkDll = ""
            throw Error("Unable to locate tk86t.dll")
        DllCall("LoadLibrary", "Str", tkDll, "Ptr")

        tkLibrary := AhkStdlibTkinterFindPyRuntimeFile("tcl\tk8.6")
        if tkLibrary = ""
            throw Error("Unable to locate Tk script library")
        EnvSet("TK_LIBRARY", tkLibrary)
    } catch as err {
        tkStartupError := err.Message
        throw RuntimeError(tkStartupError, -1)
    }
}

AhkStdlibTkinterFindBundledRuntimeFile(fileName)
{
    SplitPath A_LineFile, , &moduleDir
    candidate := moduleDir "\tkinter\lib\" fileName
    if FileExist(candidate)
        return candidate
    return ""
}

AhkStdlibTkinterFindPyRuntimeFile(relativePath)
{
    candidates := []
    hkcu := AhkStdlibTkinterReadRegistry("HKCU\Software\" AhkStdlibTkinterPyWord() "\" AhkStdlibTkinterPyCoreWord() "\3.10\InstallPath")
    if hkcu != ""
        candidates.Push(hkcu)
    hklm := AhkStdlibTkinterReadRegistry("HKLM\Software\" AhkStdlibTkinterPyWord() "\" AhkStdlibTkinterPyCoreWord() "\3.10\InstallPath")
    if hklm != ""
        candidates.Push(hklm)
    wow := AhkStdlibTkinterReadRegistry("HKLM\Software\WOW6432Node\" AhkStdlibTkinterPyWord() "\" AhkStdlibTkinterPyCoreWord() "\3.10\InstallPath")
    if wow != ""
        candidates.Push(wow)

    for baseDir in candidates {
        candidate := RTrim(baseDir, "\/") "\" relativePath
        if FileExist(candidate)
            return candidate
    }
    return ""
}

AhkStdlibTkinterFindLegacyTkinterRuntimeFile(relativePath)
{
    candidate := A_ScriptDir "\" relativePath
    if FileExist(candidate)
        return candidate
    candidate := RegRead("HKLM\SOFTWARE\AutoHotkey", "InstallDir", "") "\lib\" relativePath
    if FileExist(candidate)
        return candidate
    return ""
}

AhkStdlibTkinterReadRegistry(path)
{
    try return RegRead(path)
    catch
        return ""
}

AhkStdlibTkinterCreateInterp()
{
    return DllCall("tcl86t\Tcl_CreateInterp", "Ptr")
}

AhkStdlibTkinterDeleteInterp(interp)
{
    DllCall("tcl86t\Tcl_DeleteInterp", "Ptr", interp)
}

AhkStdlibTkinterInitInterp(interp)
{
    result := DllCall("tcl86t\Tcl_Init", "Ptr", interp, "Int")
    if result != 0
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(interp), -1)
}

AhkStdlibTkinterInitTk(interp)
{
    result := DllCall("tk86t\Tk_Init", "Ptr", interp, "Int")
    if result != 0
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(interp), -1)
}

AhkStdlibTkinterUtf8Buffer(value)
{
    text := value is String ? value : value ""
    buf := Buffer(StrPut(text, "UTF-8"), 0)
    StrPut(text, buf, "UTF-8")
    return buf
}

AhkStdlibTkinterGetStringResult(interp)
{
    return StrGet(DllCall("tcl86t\Tcl_GetStringResult", "Ptr", interp, "Ptr"), "UTF-8")
}

AhkStdlibTkinterSetVar(interp, name, value)
{
    nameBuffer := AhkStdlibTkinterUtf8Buffer(name)
    valueBuffer := AhkStdlibTkinterUtf8Buffer(AhkStdlibTkinterValueToString(value))
    result := DllCall("tcl86t\Tcl_SetVar", "Ptr", interp, "Ptr", nameBuffer.Ptr, "Ptr", valueBuffer.Ptr, "Int", 0, "Ptr")
    if !result
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(interp), -1)
}

AhkStdlibTkinterGetVar(interp, name)
{
    nameBuffer := AhkStdlibTkinterUtf8Buffer(name)
    result := DllCall("tcl86t\Tcl_GetVar", "Ptr", interp, "Ptr", nameBuffer.Ptr, "Int", 0, "Ptr")
    if !result
        return AhkStdlibTkinterMissingValue()
    return StrGet(result, "UTF-8")
}

AhkStdlibTkinterNormalizeVarName(value)
{
    if AhkStdlibIsNone(value)
        return ""
    if value is String
        return value
    throw TypeError("name must be a string", -1)
}

AhkStdlibTkinterResolveVarName(hasName, name)
{
    if hasName {
        normalized := AhkStdlibTkinterNormalizeVarName(name)
        if normalized != ""
            return normalized
    }
    return AhkStdlibTkinterNextVarName()
}

AhkStdlibTkinterVarExists(interp, name)
{
    return !(AhkStdlibTkinterGetVar(interp, name) == AhkStdlibTkinterMissingValue())
}

AhkStdlibTkinterResolveWidgetPath(root, parentPath, tkCommand, options)
{
    if options.HasOwnProp("name") {
        name := AhkStdlibTkinterNormalizeVarName(options.name)
        if name != ""
            return AhkStdlibTkinterJoinWidgetPath(parentPath, name)
    }

    key := parentPath "|" tkCommand
    counter := root.AhkStdlibChildCounters.Has(key) ? root.AhkStdlibChildCounters[key] : 0
    index := counter + 1
    root.AhkStdlibChildCounters[key] := index
    name := "!" tkCommand (index = 1 ? "" : index)
    return AhkStdlibTkinterJoinWidgetPath(parentPath, name)
}

AhkStdlibTkinterJoinWidgetPath(parentPath, name)
{
    if parentPath = "."
        return "." name
    return parentPath "." name
}

AhkStdlibTkinterWidgetToplevel(widget)
{
    current := widget
    loop {
        if current is Tk || current is Toplevel
            return current
        if !HasProp(current, "master")
            return widget._root()
        current := current.master
    }
}

AhkStdlibTkinterWinfoChildren(root, window, args*)
{
    if args.Length != 0
        throw TypeError("Misc.winfo_children() takes 1 positional argument but " args.Length + 1 " were given", -1)

    result := []
    for path in AhkStdlibTkinterSimpleList(root.eval("winfo children " window))
        result.Push(root.AhkStdlibWidgetsByPath[path])
    return result
}

AhkStdlibTkinterWinfoAtom(root, window, args*)
{
    if args.Length = 0
        throw TypeError("Misc.winfo_atom() missing 1 required positional argument: 'name'", -1)
    if args.Length > 2
        throw TypeError("Misc.winfo_atom() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
    script := "winfo atom" AhkStdlibTkinterWinfoDisplayScript(window, args.Length = 2, args.Length = 2 ? args[2] : 0)
    if !AhkStdlibIsNone(args[1])
        script .= " " AhkStdlibTkinterTclWord(args[1])
    return Integer(root.eval(script))
}

AhkStdlibTkinterWinfoAtomName(root, window, args*)
{
    if args.Length = 0
        throw TypeError("Misc.winfo_atomname() missing 1 required positional argument: 'id'", -1)
    if args.Length > 2
        throw TypeError("Misc.winfo_atomname() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
    return root.eval("winfo atomname" AhkStdlibTkinterWinfoDisplayScript(window, args.Length = 2, args.Length = 2 ? args[2] : 0) " " AhkStdlibTkinterTclWord(args[1]))
}

AhkStdlibTkinterWinfoContaining(root, window, args*)
{
    if args.Length = 0
        throw TypeError("Misc.winfo_containing() missing 2 required positional arguments: 'rootX' and 'rootY'", -1)
    if args.Length = 1
        throw TypeError("Misc.winfo_containing() missing 1 required positional argument: 'rootY'", -1)
    if args.Length > 3
        throw TypeError("Misc.winfo_containing() takes from 3 to 4 positional arguments but " args.Length + 1 " were given", -1)
    path := root.eval("winfo containing" AhkStdlibTkinterWinfoDisplayScript(window, args.Length = 3, args.Length = 3 ? args[3] : 0) " " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
    if path = ""
        return stdlib.None
    return AhkStdlibTkinterWidgetFromPath(root, path)
}

AhkStdlibTkinterWinfoInterps(root, window, args*)
{
    if args.Length > 1
        throw TypeError("Misc.winfo_interps() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
    value := root.eval("winfo interps" AhkStdlibTkinterWinfoDisplayScript(window, args.Length = 1, args.Length = 1 ? args[1] : 0))
    return stdlib.tuple(AhkStdlibTkinterSplitList(root.AhkStdlibInterp, value))
}

AhkStdlibTkinterWinfoPathName(root, window, args*)
{
    if args.Length = 0
        throw TypeError("Misc.winfo_pathname() missing 1 required positional argument: 'id'", -1)
    if args.Length > 2
        throw TypeError("Misc.winfo_pathname() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
    return root.eval("winfo pathname" AhkStdlibTkinterWinfoDisplayScript(window, args.Length = 2, args.Length = 2 ? args[2] : 0) " " AhkStdlibTkinterTclWord(args[1]))
}

AhkStdlibTkinterWinfoDisplayScript(window, hasDisplayof, displayof)
{
    if !hasDisplayof
        return ""
    if AhkStdlibIsNone(displayof)
        return " -displayof " AhkStdlibTkinterTclWord(window)
    if AhkStdlibTruthValue(displayof)
        return " -displayof " AhkStdlibTkinterTclWord(displayof)
    return ""
}

AhkStdlibTkinterWinfoString(root, window, command, methodName, args*)
{
    if args.Length != 0
        throw TypeError("Misc." methodName "() takes 1 positional argument but " args.Length + 1 " were given", -1)
    return root.eval("winfo " command " " window)
}

AhkStdlibTkinterWinfoInteger(root, window, command, methodName, args*)
{
    if args.Length != 0
        throw TypeError("Misc." methodName "() takes 1 positional argument but " args.Length + 1 " were given", -1)
    return Integer(root.eval("winfo " command " " window))
}

AhkStdlibTkinterWinfoIntegerBase0(root, window, command, methodName, args*)
{
    if args.Length != 0
        throw TypeError("Misc." methodName "() takes 1 positional argument but " args.Length + 1 " were given", -1)
    return Integer(root.eval("winfo " command " " window))
}

AhkStdlibTkinterWinfoBoolean(root, window, command, methodName, args*)
{
    if args.Length != 0
        throw TypeError("Misc." methodName "() takes 1 positional argument but " args.Length + 1 " were given", -1)
    return root.eval("winfo " command " " window) = "1" ? stdlib.True : stdlib.False
}

AhkStdlibTkinterWinfoIntegerTuple(root, window, command, methodName, args*)
{
    if args.Length != 0
        throw TypeError("Misc." methodName "() takes 1 positional argument but " args.Length + 1 " were given", -1)
    return AhkStdlibTkinterIntegerTuple(root.eval("winfo " command " " window))
}

AhkStdlibTkinterWinfoVisualsAvailable(root, window, args*)
{
    if args.Length > 1
        throw TypeError("Misc.winfo_visualsavailable() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)

    script := "winfo visualsavailable " window
    if args.Length = 1 && AhkStdlibTruthValue(args[1])
        script .= " includeids"

    result := []
    for entryText in AhkStdlibTkinterSplitList(root.AhkStdlibInterp, root.eval(script)) {
        parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, entryText)
        item := []
        if parts.Length >= 1
            item.Push(parts[1])
        loop parts.Length - 1
            item.Push(Integer(parts[A_Index + 1]))
        result.Push(stdlib.tuple(item))
    }
    return result
}

AhkStdlibTkinterWinfoLogicalScreenInteger(root, window, command, methodName, args*)
{
    if args.Length != 0
        throw TypeError("Misc." methodName "() takes 1 positional argument but " args.Length + 1 " were given", -1)
    value := Integer(root.eval("winfo " command " " window))
    dpi := A_ScreenDPI + 0
    return dpi > 0 ? Round(value * 96 / dpi) : value
}

AhkStdlibTkinterWinfoPixels(root, window, command, methodName, args*)
{
    if args.Length = 0
        throw TypeError("Misc." methodName "() missing 1 required positional argument: 'number'", -1)
    if args.Length > 1
        throw TypeError("Misc." methodName "() takes 2 positional arguments but " args.Length + 1 " were given", -1)
    result := AhkStdlibTkinterPythonLikeFpixels(root, window, args[1])
    return command = "fpixels" ? result : Round(result)
}

AhkStdlibTkinterWinfoRgb(root, window, args*)
{
    if args.Length = 0
        throw TypeError("Misc.winfo_rgb() missing 1 required positional argument: 'color'", -1)
    if args.Length > 1
        throw TypeError("Misc.winfo_rgb() takes 2 positional arguments but " args.Length + 1 " were given", -1)
    return AhkStdlibTkinterRgbTuple(root.eval("winfo rgb " window " " AhkStdlibTkinterTclWord(args[1])))
}

AhkStdlibTkinterPythonLikeFpixels(root, window, number)
{
    raw := Float(root.eval("winfo fpixels " window " " AhkStdlibTkinterTclWord(number)))
    text := number is String ? number : number ""
    if !RegExMatch(text, "[cimp]$")
        return raw

    dpi := A_ScreenDPI + 0
    if dpi <= 0
        return raw

    screenMmWidth := Integer(root.eval("winfo screenmmwidth " window))
    if screenMmWidth <= 0
        return raw

    rawOneInch := Float(root.eval("winfo fpixels " window " 1i"))
    if rawOneInch = 0
        return raw

    logicalScreenWidth := Round(A_ScreenWidth * 96 / dpi)
    targetOneInch := logicalScreenWidth * 25.4 / screenMmWidth
    return raw * targetOneInch / rawOneInch
}

AhkStdlibTkinterClipboardClear(root, window, args*)
{
    if args.Length > 1 || (args.Length = 1 && !AhkStdlibTkinterIsPlainKeywordObject(args[1]))
        throw TypeError("Misc.clipboard_clear() takes 1 positional argument but " args.Length + 1 " were given", -1)

    options := args.Length = 1 ? args[1] : {}
    root.eval("clipboard clear" AhkStdlibTkinterClipboardOptionsToScript(options, window, true))
    return stdlib.None
}

AhkStdlibTkinterClipboardAppend(root, window, args*)
{
    if args.Length = 0
        throw TypeError("Misc.clipboard_append() missing 1 required positional argument: 'string'", -1)
    if args.Length > 2 || (args.Length = 2 && !AhkStdlibTkinterIsPlainKeywordObject(args[2]))
        throw TypeError("Misc.clipboard_append() takes 2 positional arguments but " args.Length + 1 " were given", -1)

    options := args.Length = 2 ? args[2] : {}
    root.eval("clipboard append" AhkStdlibTkinterClipboardOptionsToScript(options, window, true) " -- " AhkStdlibTkinterTclWord(args[1]))
    return stdlib.None
}

AhkStdlibTkinterClipboardGet(root, window, args*)
{
    if args.Length > 1 || (args.Length = 1 && !AhkStdlibTkinterIsPlainKeywordObject(args[1]))
        throw TypeError("Misc.clipboard_get() takes 1 positional argument but " args.Length + 1 " were given", -1)

    options := args.Length = 1 ? args[1] : {}
    return root.eval("clipboard get" AhkStdlibTkinterClipboardOptionsToScript(options, window, false))
}

AhkStdlibTkinterClipboardOptionsToScript(options, window, includeDefaultDisplayof)
{
    script := ""
    hasDisplayof := false
    for key, value in options.OwnProps() {
        if key = "displayof"
            hasDisplayof := true
        script .= " -" key " " AhkStdlibTkinterTclWord(value)
    }
    if includeDefaultDisplayof && !hasDisplayof
        script .= " -displayof " AhkStdlibTkinterTclWord(window)
    return script
}

AhkStdlibTkinterOptionAdd(root, args*)
{
    if args.Length = 0
        throw TypeError("Misc.option_add() missing 2 required positional arguments: 'pattern' and 'value'", -1)
    if args.Length = 1
        throw TypeError("Misc.option_add() missing 1 required positional argument: 'value'", -1)
    if args.Length > 3
        throw TypeError("Misc.option_add() takes from 3 to 4 positional arguments but " args.Length + 1 " were given", -1)

    script := "option add " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2])
    if args.Length = 3 && !AhkStdlibIsNone(args[3])
        script .= " " AhkStdlibTkinterTclWord(args[3])
    root.eval(script)
    return stdlib.None
}

AhkStdlibTkinterOptionClear(root, args*)
{
    if args.Length != 0
        throw TypeError("Misc.option_clear() takes 1 positional argument but " args.Length + 1 " were given", -1)
    root.eval("option clear")
    return stdlib.None
}

AhkStdlibTkinterOptionGet(root, window, args*)
{
    if args.Length = 0
        throw TypeError("Misc.option_get() missing 2 required positional arguments: 'name' and 'className'", -1)
    if args.Length = 1
        throw TypeError("Misc.option_get() missing 1 required positional argument: 'className'", -1)
    if args.Length > 2
        throw TypeError("Misc.option_get() takes 3 positional arguments but " args.Length + 1 " were given", -1)
    return root.eval("option get " window " " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
}

AhkStdlibTkinterOptionReadFile(root, args*)
{
    if args.Length = 0
        throw TypeError("Misc.option_readfile() missing 1 required positional argument: 'fileName'", -1)
    if args.Length > 2
        throw TypeError("Misc.option_readfile() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

    script := "option readfile " AhkStdlibTkinterTclWord(args[1])
    if args.Length = 2 && !AhkStdlibIsNone(args[2])
        script .= " " AhkStdlibTkinterTclWord(args[2])
    root.eval(script)
    return stdlib.None
}

AhkStdlibTkinterVariableTraceAdd(variable, args*)
{
    if args.Length = 0
        throw TypeError("Variable.trace_add() missing 2 required positional arguments: 'mode' and 'callback'", -1)
    if args.Length = 1
        throw TypeError("Variable.trace_add() missing 1 required positional argument: 'callback'", -1)
    if args.Length > 2
        throw TypeError("Variable.trace_add() takes 3 positional arguments but " args.Length + 1 " were given", -1)

    commandName := AhkStdlibTkinterRegisterTraceCommand(variable._tk, args[2])
    variable._tk.eval("trace add variable " AhkStdlibTkinterTclWord(variable._name) " " AhkStdlibTkinterTraceModeWord(args[1]) " " AhkStdlibTkinterTclWord(commandName))
    return commandName
}

AhkStdlibTkinterVariableTraceRemove(variable, args*)
{
    if args.Length = 0
        throw TypeError("Variable.trace_remove() missing 2 required positional arguments: 'mode' and 'cbname'", -1)
    if args.Length = 1
        throw TypeError("Variable.trace_remove() missing 1 required positional argument: 'cbname'", -1)
    if args.Length > 2
        throw TypeError("Variable.trace_remove() takes 3 positional arguments but " args.Length + 1 " were given", -1)

    cbname := AhkStdlibTkinterValueToString(args[2])
    variable._tk.eval("trace remove variable " AhkStdlibTkinterTclWord(variable._name) " " AhkStdlibTkinterTraceModeWord(args[1]) " " AhkStdlibTkinterTclWord(cbname))
    AhkStdlibTkinterDeleteTraceCommandIfUnused(variable, cbname)
    return stdlib.None
}

AhkStdlibTkinterVariableTraceInfo(variable, args*)
{
    if args.Length != 0
        throw TypeError("Variable.trace_info() takes 1 positional argument but " args.Length + 1 " were given", -1)

    result := []
    raw := variable._tk.eval("trace info variable " AhkStdlibTkinterTclWord(variable._name))
    for entryText in AhkStdlibTkinterSplitList(variable._tk.AhkStdlibInterp, raw) {
        entry := AhkStdlibTkinterSplitList(variable._tk.AhkStdlibInterp, entryText)
        modes := entry.Length >= 1 ? AhkStdlibTkinterSplitList(variable._tk.AhkStdlibInterp, entry[1]) : []
        callback := entry.Length >= 2 ? entry[2] : ""
        result.Push(stdlib.tuple([stdlib.tuple(modes), callback]))
    }
    return result
}

AhkStdlibTkinterVariableTraceVariable(variable, args*)
{
    if args.Length = 0
        throw TypeError("Variable.trace_variable() missing 2 required positional arguments: 'mode' and 'callback'", -1)
    if args.Length = 1
        throw TypeError("Variable.trace_variable() missing 1 required positional argument: 'callback'", -1)
    if args.Length > 2
        throw TypeError("Variable.trace_variable() takes 3 positional arguments but " args.Length + 1 " were given", -1)

    commandName := AhkStdlibTkinterRegisterTraceCommand(variable._tk, args[2])
    variable._tk.eval("trace variable " AhkStdlibTkinterTclWord(variable._name) " " AhkStdlibTkinterTraceModeWord(args[1]) " " AhkStdlibTkinterTclWord(commandName))
    return commandName
}

AhkStdlibTkinterVariableTraceVdelete(variable, args*)
{
    if args.Length = 0
        throw TypeError("Variable.trace_vdelete() missing 2 required positional arguments: 'mode' and 'cbname'", -1)
    if args.Length = 1
        throw TypeError("Variable.trace_vdelete() missing 1 required positional argument: 'cbname'", -1)
    if args.Length > 2
        throw TypeError("Variable.trace_vdelete() takes 3 positional arguments but " args.Length + 1 " were given", -1)

    cbname := AhkStdlibTkinterValueToString(args[2])
    variable._tk.eval("trace vdelete " AhkStdlibTkinterTclWord(variable._name) " " AhkStdlibTkinterTraceModeWord(args[1]) " " AhkStdlibTkinterTclWord(cbname))
    splitName := AhkStdlibTkinterSplitList(variable._tk.AhkStdlibInterp, cbname)
    if splitName.Length > 0
        cbname := splitName[1]
    AhkStdlibTkinterDeleteTraceCommandIfUnused(variable, cbname)
    return stdlib.None
}

AhkStdlibTkinterVariableTraceVinfo(variable, args*)
{
    if args.Length != 0
        throw TypeError("Variable.trace_vinfo() takes 1 positional argument but " args.Length + 1 " were given", -1)

    result := []
    raw := variable._tk.eval("trace vinfo " AhkStdlibTkinterTclWord(variable._name))
    for entryText in AhkStdlibTkinterSplitList(variable._tk.AhkStdlibInterp, raw)
        result.Push(stdlib.tuple(AhkStdlibTkinterSplitList(variable._tk.AhkStdlibInterp, entryText)))
    return result
}

AhkStdlibTkinterTraceModeWord(mode)
{
    if mode is Array
        return AhkStdlibTkinterTclListCommandWord(mode)
    return AhkStdlibTkinterTclWord(mode)
}

AhkStdlibTkinterDeleteTraceCommandIfUnused(variable, cbname)
{
    for info in variable.trace_info()
        if info[2] = cbname
            return
    AhkStdlibTkinterDeleteCommand(variable._tk, cbname, "can't delete Tcl command")
}

AhkStdlibTkinterPackSlaves(root, window, args*)
{
    if args.Length != 0
        throw TypeError("Misc.pack_slaves() takes 1 positional argument but " args.Length + 1 " were given", -1)
    return AhkStdlibTkinterWidgetListFromPathList(root, root.eval("pack slaves " window))
}

AhkStdlibTkinterPropagate(root, window, manager, methodName, args*)
{
    if args.Length > 1
        throw TypeError("Misc." methodName "() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)

    script := manager " propagate " window
    if args.Length = 0
        return root.eval(script) = "1" ? stdlib.True : stdlib.None

    if AhkStdlibIsNone(args[1]) {
        root.eval(script)
        return stdlib.None
    }

    root.eval(script " " AhkStdlibTkinterTclWord(args[1]))
    return stdlib.None
}

AhkStdlibTkinterGridSlaves(root, window, args*)
{
    if args.Length > 2
        throw TypeError("Misc.grid_slaves() takes from 1 to 3 positional arguments but " args.Length + 1 " were given", -1)

    script := "grid slaves " window
    if args.Length = 1 && AhkStdlibTkinterIsPlainKeywordObject(args[1]) {
        options := args[1]
        for key, value in options.OwnProps() {
            if key != "row" && key != "column"
                throw TypeError("Misc.grid_slaves() got an unexpected keyword argument '" key "'", -1)
            if !AhkStdlibIsNone(value)
                script .= " -" key " " AhkStdlibTkinterTclWord(value)
        }
    } else {
        if args.Length >= 1 && !AhkStdlibIsNone(args[1])
            script .= " -row " AhkStdlibTkinterTclWord(args[1])
        if args.Length >= 2 && !AhkStdlibIsNone(args[2])
            script .= " -column " AhkStdlibTkinterTclWord(args[2])
    }
    return AhkStdlibTkinterWidgetListFromPathList(root, root.eval(script))
}

AhkStdlibTkinterGridAnchor(root, window, args*)
{
    if args.Length > 1
        throw TypeError("Misc.grid_anchor() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)

    script := "grid anchor " window
    if args.Length = 0 || AhkStdlibIsNone(args[1])
        root.eval(script)
    else
        root.eval(script " " AhkStdlibTkinterTclWord(args[1]))
    return stdlib.None
}

AhkStdlibTkinterGridAxisConfigure(root, window, axis, methodName, args*)
{
    if args.Length = 0
        throw TypeError("Misc." methodName "() missing 1 required positional argument: 'index'", -1)
    if args.Length > 2
        throw TypeError("Misc." methodName "() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

    baseScript := "grid " axis "configure " window " " AhkStdlibTkinterTclWord(args[1])
    if args.Length = 1
        return AhkStdlibTkinterGridAxisInfo(root, baseScript)

    cnf := args[2]
    if AhkStdlibTkinterIsPlainKeywordObject(cnf) {
        optionScript := ""
        optionCount := 0
        for key, value in cnf.OwnProps() {
            optionCount += 1
            optionScript .= " -" key " " AhkStdlibTkinterTclWord(value)
        }
        if optionCount = 0
            return AhkStdlibTkinterGridAxisInfo(root, baseScript)
        root.eval(baseScript optionScript)
        return stdlib.None
    }

    if cnf is String
        return AhkStdlibTkinterGridAxisOptionValue(root, baseScript, cnf)
    throw TypeError("object of type '" AhkStdlibPyTypeName(cnf) "' has no len()", -1)
}

AhkStdlibTkinterGridAxisInfo(root, baseScript)
{
    info := Map()
    info["minsize"] := Integer(root.eval("dict get [" baseScript "] -minsize"))
    info["pad"] := Integer(root.eval("dict get [" baseScript "] -pad"))
    uniform := root.eval("dict get [" baseScript "] -uniform")
    info["uniform"] := uniform = "" ? stdlib.None : uniform
    info["weight"] := Integer(root.eval("dict get [" baseScript "] -weight"))
    return info
}

AhkStdlibTkinterGridAxisOptionValue(root, baseScript, optionName)
{
    normalized := SubStr(optionName, 1, 1) = "-" ? SubStr(optionName, 2) : optionName
    value := root.eval(baseScript " " AhkStdlibTkinterTclWord("-" normalized))
    switch normalized {
        case "minsize", "pad", "weight":
            return Integer(value)
        case "uniform":
            return value = "" ? stdlib.None : value
    }
    return value
}

AhkStdlibTkinterGridSize(root, window, args*)
{
    if args.Length != 0
        throw TypeError("Misc.grid_size() takes 1 positional argument but " args.Length + 1 " were given", -1)
    return AhkStdlibTkinterIntegerTuple(root.eval("grid size " window))
}

AhkStdlibTkinterGridBbox(root, window, args*)
{
    if args.Length > 4
        throw TypeError("Misc.grid_bbox() takes from 1 to 5 positional arguments but " args.Length + 1 " were given", -1)

    column := stdlib.None
    row := stdlib.None
    col2 := stdlib.None
    row2 := stdlib.None
    if args.Length = 1 && AhkStdlibTkinterIsPlainKeywordObject(args[1]) {
        options := args[1]
        for key, value in options.OwnProps() {
            switch key {
                case "column":
                    column := value
                case "row":
                    row := value
                case "col2":
                    col2 := value
                case "row2":
                    row2 := value
                default:
                    throw TypeError("Misc.grid_bbox() got an unexpected keyword argument '" key "'", -1)
            }
        }
    } else {
        if args.Length >= 1
            column := args[1]
        if args.Length >= 2
            row := args[2]
        if args.Length >= 3
            col2 := args[3]
        if args.Length >= 4
            row2 := args[4]
    }

    script := "grid bbox " window
    if !AhkStdlibIsNone(column) && !AhkStdlibIsNone(row)
        script .= " " AhkStdlibTkinterTclWord(column) " " AhkStdlibTkinterTclWord(row)
    if !AhkStdlibIsNone(col2) && !AhkStdlibIsNone(row2)
        script .= " " AhkStdlibTkinterTclWord(col2) " " AhkStdlibTkinterTclWord(row2)
    return AhkStdlibTkinterIntegerTuple(root.eval(script))
}

AhkStdlibTkinterGridLocation(root, window, args*)
{
    if args.Length = 0
        throw TypeError("Misc.grid_location() missing 2 required positional arguments: 'x' and 'y'", -1)
    if args.Length = 1 && AhkStdlibTkinterIsPlainKeywordObject(args[1]) {
        options := args[1]
        x := unset
        y := unset
        for key, value in options.OwnProps() {
            switch key {
                case "x":
                    x := value
                case "y":
                    y := value
                default:
                    throw TypeError("Misc.grid_location() got an unexpected keyword argument '" key "'", -1)
            }
        }
        if !IsSet(x)
            throw TypeError("Misc.grid_location() missing 1 required positional argument: 'x'", -1)
        if !IsSet(y)
            throw TypeError("Misc.grid_location() missing 1 required positional argument: 'y'", -1)
    } else {
        if args.Length = 1
            throw TypeError("Misc.grid_location() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("Misc.grid_location() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        x := args[1]
        y := args[2]
    }
    return AhkStdlibTkinterIntegerTuple(root.eval("grid location " window " " AhkStdlibTkinterTclWord(x) " " AhkStdlibTkinterTclWord(y)))
}

AhkStdlibTkinterPlaceSlaves(root, window, args*)
{
    if args.Length != 0
        throw TypeError("Misc.place_slaves() takes 1 positional argument but " args.Length + 1 " were given", -1)
    return AhkStdlibTkinterWidgetListFromPathList(root, root.eval("place slaves " window))
}

AhkStdlibTkinterWidgetListFromPathList(root, value)
{
    result := []
    for path in AhkStdlibTkinterSimpleList(value)
        result.Push(AhkStdlibTkinterWidgetFromPath(root, path))
    return result
}

AhkStdlibTkinterImageNames(root, args*)
{
    if args.Length != 0
        throw TypeError("Misc.image_names() takes 1 positional argument but " args.Length + 1 " were given", -1)
    return stdlib.tuple(AhkStdlibTkinterSimpleList(root.eval("image names")))
}

AhkStdlibTkinterImageTypes(root, args*)
{
    if args.Length != 0
        throw TypeError("Misc.image_types() takes 1 positional argument but " args.Length + 1 " were given", -1)
    return stdlib.tuple(AhkStdlibTkinterSimpleList(root.eval("image types")))
}

AhkStdlibTkinterPackInfo(widget)
{
    root := widget.AhkStdlibRoot
    info := Map()
    inPath := root.eval("dict get [pack info " widget._w "] -in")
    info["in"] := AhkStdlibTkinterWidgetFromPath(root, inPath)
    info["anchor"] := root.eval("dict get [pack info " widget._w "] -anchor")
    info["expand"] := Integer(root.eval("dict get [pack info " widget._w "] -expand"))
    info["fill"] := root.eval("dict get [pack info " widget._w "] -fill")
    for key in ["ipadx", "ipady", "padx", "pady"]
        info[key] := Integer(root.eval("dict get [pack info " widget._w "] -" key))
    info["side"] := root.eval("dict get [pack info " widget._w "] -side")
    return info
}

AhkStdlibTkinterWidgetFromPath(root, path)
{
    return root.AhkStdlibWidgetsByPath[path]
}

AhkStdlibTkinterNameToWidget(root, basePath, args*)
{
    if args.Length = 0
        throw TypeError("Misc.nametowidget() missing 1 required positional argument: 'name'", -1)
    if args.Length > 1
        throw TypeError("Misc.nametowidget() takes 2 positional arguments but " args.Length + 1 " were given", -1)

    name := AhkStdlibTkinterValueToString(args[1])
    if SubStr(name, 1, 1) = "."
        path := name
    else if basePath = "."
        path := "." name
    else
        path := basePath "." name

    if path = "."
        return root
    if root.eval("winfo exists " AhkStdlibTkinterTclWord(path)) != "1" || !root.AhkStdlibWidgetsByPath.Has(path)
        throw KeyError("'" AhkStdlibTkinterLastPathPart(path) "'", -1)
    return root.AhkStdlibWidgetsByPath[path]
}

AhkStdlibTkinterLastPathPart(path)
{
    last := ""
    for part in StrSplit(path, ".")
        if part != ""
            last := part
    return last
}

AhkStdlibTkinterWmResizable(root, window, args*)
{
    if args.Length > 2
        throw TypeError("Wm.wm_resizable() takes from 1 to 3 positional arguments but " args.Length + 1 " were given", -1)
    script := "wm resizable " window
    if args.Length = 0
        return AhkStdlibTkinterIntegerTuple(root.eval(script))
    for value in args
        script .= " " AhkStdlibTkinterTclWord(value)
    return root.eval(script)
}

AhkStdlibTkinterWmSize(root, window, command, args*)
{
    if args.Length > 2
        throw TypeError("Wm.wm_" command "() takes from 1 to 3 positional arguments but " args.Length + 1 " were given", -1)
    script := "wm " command " " window
    if args.Length = 0
        return AhkStdlibTkinterIntegerTuple(root.eval(script))
    for value in args
        script .= " " AhkStdlibTkinterTclWord(value)
    root.eval(script)
    return stdlib.None
}

AhkStdlibTkinterWmProtocol(root, window, args*)
{
    if args.Length > 2
        throw TypeError("Wm.wm_protocol() takes from 1 to 3 positional arguments but " args.Length + 1 " were given", -1)

    script := "wm protocol " window
    if args.Length = 0
        return stdlib.tuple(AhkStdlibTkinterSimpleList(root.eval(script)))

    name := args[1]
    script .= " " AhkStdlibTkinterTclWord(name)
    if args.Length = 1 || AhkStdlibIsNone(args[2])
        return root.eval(script)

    command := AhkStdlibTkinterMaybeRegisterCommand(root, args[2])
    return root.eval(script " " AhkStdlibTkinterTclWord(command))
}

AhkStdlibTkinterWmOverrideredirect(root, window, args*)
{
    if args.Length > 1
        throw TypeError("Wm.wm_overrideredirect() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
    script := "wm overrideredirect " window
    if args.Length = 0 || AhkStdlibIsNone(args[1]) {
        result := root.eval(script)
        return result = "1" ? stdlib.True : stdlib.None
    }
    root.eval(script " " AhkStdlibTkinterTclWord(args[1]))
    return stdlib.None
}

AhkStdlibTkinterWmTransient(root, window, args*)
{
    if args.Length > 1
        throw TypeError("Wm.wm_transient() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
    script := "wm transient " window
    if args.Length = 0 || AhkStdlibIsNone(args[1])
        return root.eval(script)
    return root.eval(script " " AhkStdlibTkinterTclWord(args[1]))
}

AhkStdlibTkinterBind(root, widget, window, args*)
{
    if args.Length > 3
        throw TypeError("Misc.bind() takes from 1 to 4 positional arguments but " args.Length + 1 " were given", -1)

    return AhkStdlibTkinterBindTarget(root, widget, window, args*)
}

AhkStdlibTkinterBindAll(root, widget, args*)
{
    if args.Length > 3
        throw TypeError("Misc.bind_all() takes from 1 to 4 positional arguments but " args.Length + 1 " were given", -1)

    return AhkStdlibTkinterBindTarget(root, widget, "all", args*)
}

AhkStdlibTkinterBindClass(root, widget, args*)
{
    if args.Length = 0
        throw TypeError("Misc.bind_class() missing 1 required positional argument: 'className'", -1)
    if args.Length > 4
        throw TypeError("Misc.bind_class() takes from 2 to 5 positional arguments but " args.Length + 1 " were given", -1)

    bindArgs := []
    loop args.Length - 1
        bindArgs.Push(args[A_Index + 1])
    return AhkStdlibTkinterBindTarget(root, widget, args[1], bindArgs*)
}

AhkStdlibTkinterBindTarget(root, widget, target, args*)
{
    targetWord := AhkStdlibTkinterTclWord(target)
    if args.Length = 0
        return stdlib.tuple(AhkStdlibTkinterSimpleList(root.eval("bind " targetWord)))

    sequence := args[1]
    if args.Length = 1 || AhkStdlibIsNone(args[2])
        return root.eval("bind " targetWord " " AhkStdlibTkinterTclWord(sequence))

    commandName := AhkStdlibTkinterRegisterEventCommand(root, widget, args[2], sequence)
    addPrefix := args.Length >= 3 && args[3] = "+" ? "+" : ""
    script := addPrefix "if {`"[" commandName " %W %T %x %y %b]`" == `"break`"} break"
    root.eval("bind " targetWord " " AhkStdlibTkinterTclWord(sequence) " " AhkStdlibTkinterTclScriptWord(script))
    return commandName
}

AhkStdlibTkinterUnbind(root, window, args*)
{
    if args.Length = 0
        throw TypeError("Misc.unbind() missing 1 required positional argument: 'sequence'", -1)
    if args.Length > 2
        throw TypeError("Misc.unbind() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

    root.eval("bind " AhkStdlibTkinterTclWord(window) " " AhkStdlibTkinterTclWord(args[1]) " {}")
    if args.Length = 2 && !AhkStdlibIsNone(args[2])
        AhkStdlibTkinterDeleteCommand(root, args[2])
    return stdlib.None
}

AhkStdlibTkinterUnbindAll(root, args*)
{
    if args.Length = 0
        throw TypeError("Misc.unbind_all() missing 1 required positional argument: 'sequence'", -1)
    if args.Length > 1
        throw TypeError("Misc.unbind_all() takes 2 positional arguments but " args.Length + 1 " were given", -1)

    root.eval("bind all " AhkStdlibTkinterTclWord(args[1]) " {}")
    return stdlib.None
}

AhkStdlibTkinterUnbindClass(root, args*)
{
    if args.Length = 0
        throw TypeError("Misc.unbind_class() missing 2 required positional arguments: 'className' and 'sequence'", -1)
    if args.Length = 1
        throw TypeError("Misc.unbind_class() missing 1 required positional argument: 'sequence'", -1)
    if args.Length > 2
        throw TypeError("Misc.unbind_class() takes 3 positional arguments but " args.Length + 1 " were given", -1)

    root.eval("bind " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]) " {}")
    return stdlib.None
}

AhkStdlibTkinterBindTags(root, window, args*)
{
    if args.Length > 1
        throw TypeError("Misc.bindtags() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)

    script := "bindtags " window
    if args.Length = 0 || AhkStdlibIsNone(args[1])
        return stdlib.tuple(AhkStdlibTkinterSimpleList(root.eval(script)))

    tagList := args[1]
    if tagList is Array {
        if tagList.Length > 0
            script .= " " AhkStdlibTkinterTclListCommandWord(tagList)
    } else {
        script .= " " AhkStdlibTkinterTclWord(tagList)
    }
    root.eval(script)
    return stdlib.None
}

AhkStdlibTkinterEventGenerate(root, window, args*)
{
    if args.Length = 0
        throw TypeError("Misc.event_generate() missing 1 required positional argument: 'sequence'", -1)
    if args.Length > 2 || (args.Length = 2 && !AhkStdlibTkinterIsPlainKeywordObject(args[2]))
        throw TypeError("Misc.event_generate() takes 2 positional arguments but " args.Length + 1 " were given", -1)

    script := "event generate " window " " AhkStdlibTkinterTclWord(args[1])
    if args.Length = 2 {
        for key, value in args[2].OwnProps()
            script .= " -" key " " AhkStdlibTkinterTclWord(value)
    }
    root.eval(script)
    return stdlib.None
}

AhkStdlibTkinterEventAdd(root, args*)
{
    if args.Length = 0
        throw TypeError("Misc.event_add() missing 1 required positional argument: 'virtual'", -1)

    script := "event add " AhkStdlibTkinterTclWord(args[1])
    loop args.Length - 1
        script .= " " AhkStdlibTkinterTclWord(args[A_Index + 1])
    root.eval(script)
    return stdlib.None
}

AhkStdlibTkinterEventDelete(root, args*)
{
    if args.Length = 0
        throw TypeError("Misc.event_delete() missing 1 required positional argument: 'virtual'", -1)

    script := "event delete " AhkStdlibTkinterTclWord(args[1])
    loop args.Length - 1
        script .= " " AhkStdlibTkinterTclWord(args[A_Index + 1])
    root.eval(script)
    return stdlib.None
}

AhkStdlibTkinterEventInfo(root, args*)
{
    if args.Length > 1
        throw TypeError("Misc.event_info() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)

    script := "event info"
    if args.Length = 1 && !AhkStdlibIsNone(args[1])
        script .= " " AhkStdlibTkinterTclWord(args[1])
    return stdlib.tuple(AhkStdlibTkinterSimpleList(root.eval(script)))
}

AhkStdlibTkinterStacking(root, window, command, methodName, args*)
{
    if args.Length > 1
        throw TypeError("Misc." methodName "() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
    script := command " " window
    if args.Length = 1 && !AhkStdlibIsNone(args[1])
        script .= " " AhkStdlibTkinterTclWord(args[1])
    root.eval(script)
    return stdlib.None
}

AhkStdlibTkinterGrabSet(root, window, methodName, args*)
{
    if args.Length != 0
        throw TypeError("Misc." methodName "() takes 1 positional argument but " args.Length + 1 " were given", -1)
    root.eval("grab set " window)
    return stdlib.None
}

AhkStdlibTkinterGrabRelease(root, window, args*)
{
    if args.Length != 0
        throw TypeError("Misc.grab_release() takes 1 positional argument but " args.Length + 1 " were given", -1)
    root.eval("grab release " window)
    return stdlib.None
}

AhkStdlibTkinterGrabCurrent(root, window, args*)
{
    if args.Length != 0
        throw TypeError("Misc.grab_current() takes 1 positional argument but " args.Length + 1 " were given", -1)
    current := root.eval("grab current " window)
    if current = ""
        return stdlib.None
    return AhkStdlibTkinterWidgetFromPath(root, current)
}

AhkStdlibTkinterGrabStatus(root, window, args*)
{
    if args.Length != 0
        throw TypeError("Misc.grab_status() takes 1 positional argument but " args.Length + 1 " were given", -1)
    status := root.eval("grab status " window)
    return status = "" || status = "none" ? stdlib.None : status
}

AhkStdlibTkinterWaitFor(root, window, command, methodName, args*)
{
    if args.Length > 1
        throw TypeError("Misc." methodName "() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
    target := window
    if args.Length = 1 && !AhkStdlibIsNone(args[1])
        target := AhkStdlibTkinterWaitTarget(args[1])
    root.eval("tkwait " command " " AhkStdlibTkinterTclWord(target))
    return stdlib.None
}

AhkStdlibTkinterWaitTarget(value)
{
    if value is Tk
        return "."
    if IsObject(value) && HasProp(value, "_w")
        return value._w
    throw AttributeError("'" AhkStdlibPyTypeName(value) "' object has no attribute '_w'", -1)
}

AhkStdlibTkinterWaitVariable(root, args*)
{
    if args.Length > 1
        throw TypeError("Misc.wait_variable() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
    name := args.Length = 0 ? Chr(80) Chr(89) "_VAR" : AhkStdlibTkinterValueToString(args[1])
    root.eval("tkwait variable " AhkStdlibTkinterTclWord(name))
    return stdlib.None
}

AhkStdlibTkinterFocusSet(root, window, methodName, force, args*)
{
    if args.Length != 0
        throw TypeError("Misc." methodName "() takes 1 positional argument but " args.Length + 1 " were given", -1)
    root.eval("focus " (force ? "-force " : "") window)
    return stdlib.None
}

AhkStdlibTkinterFocusQuery(root, script, methodName, args*)
{
    if args.Length != 0
        throw TypeError("Misc." methodName "() takes 1 positional argument but " args.Length + 1 " were given", -1)
    window := root.eval(script)
    if window = ""
        return stdlib.None
    if root.eval("winfo viewable " window) = "0"
        return stdlib.None
    return AhkStdlibTkinterWidgetFromPath(root, window)
}

AhkStdlibTkinterEntrySelectionClear(entry, methodName, args*)
{
    if args.Length != 0
        throw TypeError(methodName " takes 1 positional argument but " args.Length + 1 " were given", -1)
    entry.AhkStdlibRoot.eval(entry._w " selection clear")
    return stdlib.None
}

AhkStdlibTkinterEntrySelectionIndex(entry, methodName, command, args*)
{
    if args.Length = 0
        throw TypeError(methodName " missing 1 required positional argument: 'index'", -1)
    if args.Length > 1
        throw TypeError(methodName " takes 2 positional arguments but " args.Length + 1 " were given", -1)
    entry.AhkStdlibRoot.eval(entry._w " selection " command " " AhkStdlibTkinterTclWord(args[1]))
    return stdlib.None
}

AhkStdlibTkinterEntrySelectionPresent(entry, methodName, args*)
{
    if args.Length != 0
        throw TypeError(methodName " takes 1 positional argument but " args.Length + 1 " were given", -1)
    return entry.AhkStdlibRoot.eval(entry._w " selection present") = "1" ? stdlib.True : stdlib.False
}

AhkStdlibTkinterEntrySelectionRange(entry, methodName, args*)
{
    if args.Length = 0
        throw TypeError(methodName " missing 2 required positional arguments: 'start' and 'end'", -1)
    if args.Length = 1
        throw TypeError(methodName " missing 1 required positional argument: 'end'", -1)
    if args.Length > 2
        throw TypeError(methodName " takes 3 positional arguments but " args.Length + 1 " were given", -1)
    entry.AhkStdlibRoot.eval(entry._w " selection range " AhkStdlibTkinterTclWord(args[1]) " " AhkStdlibTkinterTclWord(args[2]))
    return stdlib.None
}

AhkStdlibTkinterOptionsToScript(options, includeName, root := unset)
{
    script := ""
    for key, value in options.OwnProps() {
        if key = "master"
            continue
        if key = "name" && !includeName
            continue
        optionName := key = "from_" ? "from" : key
        if key = "command" && IsSet(root)
            value := AhkStdlibTkinterMaybeRegisterCommand(root, value)
        optionValue := (optionName = "data" || optionName = "maskdata") ? AhkStdlibTkinterTclQuotedWord(value) : AhkStdlibTkinterTclWord(value)
        script .= " -" optionName " " optionValue
    }
    return script
}

AhkStdlibTkinterMaybeRegisterCommand(root, value)
{
    if !IsObject(value) || !HasMethod(value, "Call")
        return value

    return AhkStdlibTkinterRegisterCommand(root, value)
}

AhkStdlibTkinterRegisterCommand(root, callback, callbackArgs := unset)
{
    if !IsObject(callback) || !HasMethod(callback, "Call")
        return callback

    entry := IsSet(callbackArgs) ? { Callback: callback, Args: callbackArgs } : callback
    id := AhkStdlibTkinterRegisterCommandCallback(entry)
    commandName := "ahkstdlib_tkinter_command_" id
    nameBuffer := AhkStdlibTkinterUtf8Buffer(commandName)
    result := DllCall("tcl86t\Tcl_CreateCommand", "Ptr", root.AhkStdlibInterp, "Ptr", nameBuffer.Ptr, "Ptr", AhkStdlibTkinterCommandProcPtr(), "Ptr", id, "Ptr", 0, "Ptr")
    if !result
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(root.AhkStdlibInterp), -1)
    root.AhkStdlibCommandCallbacks[commandName] := entry
    return commandName
}

AhkStdlibTkinterRegisterEventCommand(root, widget, callback, sequence)
{
    entry := { Kind: "EventBind", Callback: callback, Root: root, Widget: widget, Sequence: sequence }
    id := AhkStdlibTkinterRegisterCommandCallback(entry)
    commandName := "ahkstdlib_tkinter_command_" id
    nameBuffer := AhkStdlibTkinterUtf8Buffer(commandName)
    result := DllCall("tcl86t\Tcl_CreateCommand", "Ptr", root.AhkStdlibInterp, "Ptr", nameBuffer.Ptr, "Ptr", AhkStdlibTkinterCommandProcPtr(), "Ptr", id, "Ptr", 0, "Ptr")
    if !result
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(root.AhkStdlibInterp), -1)
    root.AhkStdlibCommandCallbacks[commandName] := entry
    return commandName
}

AhkStdlibTkinterRegisterTraceCommand(root, callback)
{
    id := AhkStdlibTkinterRegisterCommandCallback(callback)
    commandName := "ahkstdlib_tkinter_command_" id
    nameBuffer := AhkStdlibTkinterUtf8Buffer(commandName)
    result := DllCall("tcl86t\Tcl_CreateCommand", "Ptr", root.AhkStdlibInterp, "Ptr", nameBuffer.Ptr, "Ptr", AhkStdlibTkinterCommandProcPtr(), "Ptr", id, "Ptr", 0, "Ptr")
    if !result
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(root.AhkStdlibInterp), -1)
    root.AhkStdlibCommandCallbacks[commandName] := callback
    return commandName
}

AhkStdlibTkinterDeleteCommand(root, commandName, missingMessage := "")
{
    commandName := AhkStdlibTkinterValueToString(commandName)
    if commandName = ""
        return
    try {
        root.eval("rename " AhkStdlibTkinterTclWord(commandName) " {}")
    } catch as err {
        if missingMessage != "" && err is AhkStdlibTkinter.TclError
            throw AhkStdlibTkinter.TclError(missingMessage, -1)
        throw err
    }
    if root.AhkStdlibCommandCallbacks.Has(commandName)
        root.AhkStdlibCommandCallbacks.Delete(commandName)
}

AhkStdlibTkinterRegisterCommandCallback(callback)
{
    static nextId := 0
    nextId += 1
    AhkStdlibTkinterCommandCallbackRegistry(nextId, callback)
    return nextId
}

AhkStdlibTkinterCommandProcPtr()
{
    static proc := CallbackCreate(AhkStdlibTkinterCommandProc, "", 4)
    return proc
}

AhkStdlibTkinterCommandProc(clientData, interp, argc, argv)
{
    try {
        entry := AhkStdlibTkinterCommandCallbackRegistry(clientData)
        result := AhkStdlibTkinterCallCommandCallback(entry, AhkStdlibTkinterCommandArgs(argc, argv))
        AhkStdlibTkinterSetResult(interp, AhkStdlibTkinterValueToString(result))
        return 0
    } catch as err {
        AhkStdlibTkinterSetResult(interp, err.Message)
        return 1
    }
}

AhkStdlibTkinterCommandCallbackRegistry(id, callback := unset)
{
    static callbacks := Map()
    if IsSet(callback) {
        callbacks[id] := callback
        return callback
    }
    return callbacks[id]
}

AhkStdlibTkinterCommandArgs(argc, argv)
{
    args := []
    index := 1
    while index < argc {
        args.Push(StrGet(NumGet(argv, A_PtrSize * index, "Ptr"), "UTF-8"))
        index += 1
    }
    return args
}

AhkStdlibTkinterCallCommandCallback(entry, args)
{
    if IsObject(entry) && entry.HasOwnProp("Kind") && entry.Kind = "EventBind" {
        eventWidget := entry.Widget
        if args.Length >= 1 {
            try eventWidget := AhkStdlibTkinterWidgetFromPath(entry.Root, args[1])
        }
        return entry.Callback.Call(Event(eventWidget, args, entry.Sequence))
    }
    if IsObject(entry) && entry.HasOwnProp("Callback")
        return entry.Callback.Call(entry.Args*)
    return entry.Call(args*)
}

AhkStdlibTkinterSetResult(interp, value)
{
    valueBuffer := AhkStdlibTkinterUtf8Buffer(value)
    DllCall("tcl86t\Tcl_SetResult", "Ptr", interp, "Ptr", valueBuffer.Ptr, "Ptr", 1)
}

AhkStdlibTkinterCanvasRequireArgs(methodName, actual, minimum, maximum, requiredNames)
{
    if actual < minimum {
        missing := []
        index := actual + 1
        while index <= minimum {
            missing.Push(requiredNames[index])
            index += 1
        }
        throw TypeError(methodName "() missing " missing.Length " required positional argument" (missing.Length = 1 ? "" : "s") ": " AhkStdlibTkinterRequiredArgList(missing), -1)
    }
    if actual > maximum {
        if minimum = maximum
            throw TypeError(methodName "() takes " minimum + 1 " positional arguments but " actual + 1 " were given", -1)
        throw TypeError(methodName "() takes from " minimum + 1 " to " maximum + 1 " positional arguments but " actual + 1 " were given", -1)
    }
}

AhkStdlibTkinterRequiredArgList(names)
{
    if names.Length = 1
        return "'" names[1] "'"
    if names.Length = 2
        return "'" names[1] "' and '" names[2] "'"
    result := ""
    loop names.Length {
        if A_Index > 1
            result .= A_Index = names.Length ? ", and " : ", "
        result .= "'" names[A_Index] "'"
    }
    return result
}

AhkStdlibTkinterCanvasCreateItem(canvas, itemType, args*)
{
    if args.Length = 0
        throw IndexError("tuple index out of range", -1)

    options := unset
    coordCount := args.Length
    if AhkStdlibTkinterIsPlainKeywordObject(args[args.Length]) {
        options := args[args.Length]
        coordCount -= 1
    }
    if coordCount = 0
        throw IndexError("tuple index out of range", -1)

    script := canvas._w " create " itemType
    index := 1
    while index <= coordCount {
        script .= " " AhkStdlibTkinterTclWord(args[index])
        index += 1
    }
    if IsSet(options)
        script .= AhkStdlibTkinterOptionsToScript(options, false, canvas.AhkStdlibRoot)
    return Integer(canvas.AhkStdlibRoot.eval(script))
}

AhkStdlibTkinterCanvasCoordList(value)
{
    result := []
    value := Trim(value)
    if value = ""
        return result
    for part in StrSplit(value, " ")
        if part != ""
            result.Push(Float(part))
    return result
}

AhkStdlibTkinterCgetValue(key, value)
{
    switch key {
        case "width", "height", "length", "tearoff", "aspect":
            try return Integer(value)
        case "from", "to", "resolution":
            try return Float(value)
    }
    return value
}

AhkStdlibTkinterAfter(root, ms, args*)
{
    if args.Length = 0 {
        root.eval("after " AhkStdlibTkinterTclWord(ms))
        return stdlib.None
    }

    callbackArgs := []
    index := 2
    while index <= args.Length {
        callbackArgs.Push(args[index])
        index += 1
    }
    commandName := AhkStdlibTkinterRegisterCommand(root, args[1], callbackArgs)
    return root.eval("after " AhkStdlibTkinterTclWord(ms) " " AhkStdlibTkinterTclWord(commandName))
}

AhkStdlibTkinterKeys(root, window, args*)
{
    if args.Length != 0
        throw TypeError("Misc.keys() takes 1 positional argument but " args.Length + 1 " were given", -1)
    script := "set __stdlib_ahk_keys {}; foreach __stdlib_ahk_config [" window " configure] {lappend __stdlib_ahk_keys [string range [lindex $__stdlib_ahk_config 0] 1 end]}; join $__stdlib_ahk_keys \n"
    value := root.eval(script)
    if value = ""
        return []
    result := []
    for part in StrSplit(value, "`n")
        result.Push(part)
    return result
}

AhkStdlibTkinterValueToString(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "1" : "0"
    if IsObject(value) && HasMethod(value, "ToString")
        return String(value)
    return value ""
}

AhkStdlibTkinterGetIntMethod(root, args*)
{
    if args.Length = 0
        throw TypeError("Misc.getint() missing 1 required positional argument: 's'", -1)
    if args.Length > 1
        throw TypeError("Misc.getint() takes 2 positional arguments but " args.Length + 1 " were given", -1)

    return AhkStdlibTkinterGetIntPublic(root.AhkStdlibInterp, args[1])
}

AhkStdlibTkinterGetDoubleMethod(root, args*)
{
    if args.Length = 0
        throw TypeError("Misc.getdouble() missing 1 required positional argument: 's'", -1)
    if args.Length > 1
        throw TypeError("Misc.getdouble() takes 2 positional arguments but " args.Length + 1 " were given", -1)

    return AhkStdlibTkinterGetDoublePublic(root.AhkStdlibInterp, args[1])
}

AhkStdlibTkinterGetBooleanMethod(root, args*)
{
    if args.Length = 0
        throw TypeError("Misc.getboolean() missing 1 required positional argument: 's'", -1)
    if args.Length > 1
        throw TypeError("Misc.getboolean() takes 2 positional arguments but " args.Length + 1 " were given", -1)

    return AhkStdlibTkinterGetBooleanPublic(root.AhkStdlibInterp, args[1])
}

AhkStdlibTkinterGetIntPublic(interp, value)
{
    AhkStdlibTkinterRequireStringLikeConversionValue("getint", value, false)
    if AhkStdlibIsBool(value)
        return value
    if value is Integer
        return value

    valueBuffer := AhkStdlibTkinterUtf8Buffer(value)
    intBuffer := Buffer(4, 0)
    result := DllCall("tcl86t\Tcl_GetInt", "Ptr", interp, "Ptr", valueBuffer.Ptr, "Ptr", intBuffer.Ptr, "Int")
    if result != 0
        throw ValueError(AhkStdlibTkinterGetStringResult(interp), -1)
    return NumGet(intBuffer, 0, "Int")
}

AhkStdlibTkinterGetDoublePublic(interp, value)
{
    AhkStdlibTkinterRequireStringLikeConversionValue("getdouble", value, true)
    if AhkStdlibIsBool(value)
        return value.Value ? 1.0 : 0.0
    if (value is Integer) || (value is Float)
        return Float(value)

    try {
        doubleValue := AhkStdlibTkinterGetDouble(interp, value)
    } catch as err {
        if err is AhkStdlibTkinter.TclError
            throw ValueError(err.Message, -1)
        throw err
    }
    if !(doubleValue = doubleValue)
        throw ValueError("floating point value is Not a Number", -1)
    return doubleValue
}

AhkStdlibTkinterGetBooleanPublic(interp, value)
{
    AhkStdlibTkinterRequireStringLikeConversionValue("getboolean", value, false)
    if AhkStdlibIsBool(value)
        return value
    if value is Integer
        return value ? stdlib.True : stdlib.False

    try {
        return AhkStdlibTkinterGetBoolean(interp, value)
    } catch as err {
        if err is AhkStdlibTkinter.TclError
            throw ValueError("invalid literal for getboolean()", -1)
        throw err
    }
}

AhkStdlibTkinterRequireStringLikeConversionValue(functionName, value, allowFloat)
{
    if AhkStdlibIsNone(value)
        throw TypeError(functionName "() argument must be str, not None", -1)
    if AhkStdlibIsBool(value) || (value is Integer) || (allowFloat && value is Float) || value is String
        return
    throw TypeError(functionName "() argument must be str, not " AhkStdlibPythonTypeName(value), -1)
}

AhkStdlibTkinterTclWord(value)
{
    text := AhkStdlibTkinterValueToString(value)
    text := StrReplace(text, "\", "\\")
    text := StrReplace(text, "{", "\{")
    text := StrReplace(text, "}", "\}")
    return "{" text "}"
}

AhkStdlibTkinterTclQuotedWord(value)
{
    text := AhkStdlibTkinterValueToString(value)
    text := StrReplace(text, "\", "\\")
    text := StrReplace(text, Chr(34), "\" Chr(34))
    text := StrReplace(text, "$", "\$")
    text := StrReplace(text, "[", "\[")
    text := StrReplace(text, "]", "\]")
    return Chr(34) text Chr(34)
}

AhkStdlibTkinterTclScriptWord(value)
{
    text := AhkStdlibTkinterValueToString(value)
    text := StrReplace(text, "\", "\\")
    return "{" text "}"
}

AhkStdlibTkinterTclListCommandWord(values)
{
    script := "[list"
    for value in values
        script .= " " AhkStdlibTkinterTclWord(value)
    return script "]"
}

AhkStdlibTkinterIntVarValueToString(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "1" : "0"
    return value ""
}

AhkStdlibTkinterGetDouble(interp, value)
{
    valueBuffer := AhkStdlibTkinterUtf8Buffer(value)
    doubleBuffer := Buffer(8, 0)
    result := DllCall("tcl86t\Tcl_GetDouble", "Ptr", interp, "Ptr", valueBuffer.Ptr, "Ptr", doubleBuffer.Ptr, "Int")
    if result != 0
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(interp), -1)
    return NumGet(doubleBuffer, 0, "Double")
}

AhkStdlibTkinterGetBoolean(interp, value)
{
    if AhkStdlibIsNone(value)
        throw TypeError("getboolean() argument must be str, not None", -1)
    if AhkStdlibIsBool(value)
        return value.Value ? stdlib.True : stdlib.False

    valueBuffer := AhkStdlibTkinterUtf8Buffer(value)
    boolBuffer := Buffer(4, 0)
    result := DllCall("tcl86t\Tcl_GetBoolean", "Ptr", interp, "Ptr", valueBuffer.Ptr, "Ptr", boolBuffer.Ptr, "Int")
    if result != 0
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(interp), -1)
    return NumGet(boolBuffer, 0, "Int") ? stdlib.True : stdlib.False
}

AhkStdlibTkinterTruncateFloat(value)
{
    return value < 0 ? Ceil(value) : Floor(value)
}

AhkStdlibTkinterRgbTuple(value)
{
    result := []
    for part in StrSplit(Trim(value), " ")
        if part != ""
            result.Push(Integer(part))
    return stdlib.tuple(result)
}

AhkStdlibTkinterIntegerTuple(value)
{
    result := []
    for part in StrSplit(Trim(value), " ")
        if part != ""
            result.Push(Integer(part))
    return stdlib.tuple(result)
}

AhkStdlibTkinterFloatTuple(value)
{
    result := []
    for part in StrSplit(Trim(value), " ")
        if part != ""
            result.Push(Float(part))
    return stdlib.tuple(result)
}

AhkStdlibTkinterSplitList(interp, value)
{
    argcBuffer := Buffer(4, 0)
    argvBuffer := Buffer(A_PtrSize, 0)
    valueBuffer := AhkStdlibTkinterUtf8Buffer(value)
    resultCode := DllCall("tcl86t\Tcl_SplitList", "Ptr", interp, "Ptr", valueBuffer.Ptr, "Ptr", argcBuffer.Ptr, "Ptr", argvBuffer.Ptr, "Int")
    if resultCode != 0
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(interp), -1)

    count := NumGet(argcBuffer, 0, "Int")
    argv := NumGet(argvBuffer, 0, "Ptr")
    result := []
    try {
        loop count
            result.Push(StrGet(NumGet(argv, A_PtrSize * (A_Index - 1), "Ptr"), "UTF-8"))
    } finally {
        if argv
            DllCall("tcl86t\Tcl_Free", "Ptr", argv)
    }
    return result
}

AhkStdlibTkinterEventTypeName(value, sequence)
{
    switch value {
        case "4":
            return "ButtonPress"
        case "5":
            return "ButtonRelease"
        case "2":
            return "KeyPress"
        case "3":
            return "KeyRelease"
    }
    if value != "" && value != "??"
        return value
    if InStr(sequence, "Button")
        return "ButtonPress"
    if InStr(sequence, "Key")
        return "KeyPress"
    return value
}

AhkStdlibTkinterEventInteger(value)
{
    if value = "" || value = "??"
        return 0
    return Integer(value)
}

AhkStdlibTkinterSimpleList(value)
{
    result := []
    value := Trim(value)
    if value = ""
        return result
    for part in StrSplit(value, " ")
        if part != ""
            result.Push(part)
    return result
}

AhkStdlibTkinterPhotoImageToOption(value)
{
    if AhkStdlibTkinterIsPlainKeywordObject(value) && value.HasOwnProp("to")
        return value.to
    return value
}

AhkStdlibTkinterAppendToOption(script, to)
{
    script .= " -to"
    if to is Array {
        index := 1
        if to.Length > 0 && to[1] = "-to"
            index := 2
        while index <= to.Length {
            script .= " " AhkStdlibTkinterTclWord(to[index])
            index += 1
        }
        return script
    }
    return script " " AhkStdlibTkinterTclWord(to)
}

AhkStdlibTkinterNextVarName()
{
    static counter := 0
    name := AhkStdlibTkinterDefaultVarName() counter
    counter += 1
    return name
}

AhkStdlibTkinterMissingValue()
{
    static value := {}
    return value
}

AhkStdlibTkinterDefaultVarName()
{
    return Chr(80) Chr(89) "_VAR"
}

AhkStdlibTkinterDefaultImageName()
{
    static counter := 0
    counter += 1
    return Chr(112) Chr(121) "image" counter
}

AhkStdlibTkinterPyWord()
{
    return Chr(80) Chr(121) "thon"
}

AhkStdlibTkinterPyCoreWord()
{
    return AhkStdlibTkinterPyWord() "Core"
}

AhkStdlibPyTypeName(value)
{
    return AhkStdlibPythonTypeName(value)
}
