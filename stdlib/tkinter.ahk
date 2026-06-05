#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibTkinter
{
    class TclError extends Error
    {
        __New(args*)
        {
            if args.Length = 0
                message := ""
            else if args.Length = 1
                message := AhkStdlibTkinterExceptionArgToString(args[1])
            else
                message := AhkStdlibTkinterExceptionArgsTupleString(args)
            super.__New(message, -1)
            this.args := stdlib.tuple(args)
        }
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

    static ACTIVE := "active"
    static ALL := "all"
    static ANCHOR := "anchor"
    static ARC := "arc"
    static BASELINE := "baseline"
    static BEVEL := "bevel"
    static BOTH := "both"
    static BOTTOM := "bottom"
    static BROWSE := "browse"
    static BUTT := "butt"
    static CASCADE := "cascade"
    static CENTER := "center"
    static CHAR := "char"
    static CHORD := "chord"
    static COMMAND := "command"
    static CURRENT := "current"
    static DISABLED := "disabled"
    static DOTBOX := "dotbox"
    static E := "e"
    static END := "end"
    static EW := "ew"
    static EXTENDED := "extended"
    static FALSE := 0
    static FIRST := "first"
    static FLAT := "flat"
    static GROOVE := "groove"
    static HIDDEN := "hidden"
    static HORIZONTAL := "horizontal"
    static INSERT := "insert"
    static INSIDE := "inside"
    static LAST := "last"
    static LEFT := "left"
    static MITER := "miter"
    static MOVETO := "moveto"
    static MULTIPLE := "multiple"
    static N := "n"
    static NE := "ne"
    static NO := 0
    static NONE := "none"
    static NORMAL := "normal"
    static NS := "ns"
    static NSEW := "nsew"
    static NUMERIC := "numeric"
    static NW := "nw"
    static OFF := 0
    static ON := 1
    static OUTSIDE := "outside"
    static PAGES := "pages"
    static PIESLICE := "pieslice"
    static PROJECTING := "projecting"
    static RAISED := "raised"
    static RIDGE := "ridge"
    static RIGHT := "right"
    static ROUND := "round"
    static S := "s"
    static SCROLL := "scroll"
    static SE := "se"
    static SEL := "sel"
    static SEL_FIRST := "sel.first"
    static SEL_LAST := "sel.last"
    static SEPARATOR := "separator"
    static SINGLE := "single"
    static SOLID := "solid"
    static SUNKEN := "sunken"
    static SW := "sw"
    static TOP := "top"
    static TRUE := 1
    static UNDERLINE := "underline"
    static UNITS := "units"
    static VERTICAL := "vertical"
    static W := "w"
    static WORD := "word"
    static X := "x"
    static Y := "y"
    static YES := 1
    static wantobjects := 1

    static ttk {
        get => AhkStdlibTkinterTtk
    }

    static NoDefaultRoot(args*)
    {
        if args.Length != 0
            throw TypeError("NoDefaultRoot() takes 0 positional arguments but " args.Length " " (args.Length = 1 ? "was" : "were") " given", -1)
        return AhkStdlibTkinterDefaultRootState("disable")
    }

    static getint(args*)
    {
        return AhkStdlibTkinterModuleGetInt(args*)
    }

    static getdouble(args*)
    {
        return AhkStdlibTkinterModuleGetDouble(args*)
    }

    static getboolean(args*)
    {
        if args.Length = 0
            throw TypeError("getboolean() missing 1 required positional argument: 's'", -1)
        if args.Length > 1
            throw TypeError("getboolean() takes 1 positional argument but " args.Length " were given", -1)
        root := AhkStdlibTkinterGetDefaultRoot("use getboolean()")
        return AhkStdlibTkinterGetBooleanPublic(root.AhkStdlibInterp, args[1])
    }

    static image_names(args*)
    {
        if args.Length != 0
            throw TypeError("image_names() takes 0 positional arguments but " args.Length " " (args.Length = 1 ? "was" : "were") " given", -1)
        return AhkStdlibTkinterGetDefaultRoot("use image_names()").image_names()
    }

    static image_types(args*)
    {
        if args.Length != 0
            throw TypeError("image_types() takes 0 positional arguments but " args.Length " " (args.Length = 1 ? "was" : "were") " given", -1)
        return AhkStdlibTkinterGetDefaultRoot("use image_types()").image_types()
    }

    static mainloop(args*)
    {
        if args.Length > 1
            throw TypeError("mainloop() takes from 0 to 1 positional arguments but " args.Length " were given", -1)
        return AhkStdlibTkinterGetDefaultRoot("run the main loop").mainloop(args*)
    }

    static Event(args*)
    {
        if args.Length != 0
            throw TypeError("Event() takes no arguments", -1)
        return AhkStdlibTkinterEvent()
    }

    static EventType(args*)
    {
        if args.Length = 0
            throw TypeError("EnumMeta.__call__() missing 1 required positional argument: 'value'", -1)
        if args.Length > 1
            throw TypeError("Cannot extend enumerations", -1)
        return AhkStdlibTkinterEventType(args[1])
    }

    static CallWrapper(args*)
    {
        return AhkStdlibTkinterCallWrapper(args*)
    }

    static Pack(args*)
    {
        return AhkStdlibTkinterPack(args*)
    }

    static Place(args*)
    {
        return AhkStdlibTkinterPlace(args*)
    }

    static Grid(args*)
    {
        return AhkStdlibTkinterGrid(args*)
    }

    static XView(args*)
    {
        return AhkStdlibTkinterXView(args*)
    }

    static YView(args*)
    {
        return AhkStdlibTkinterYView(args*)
    }

    static Misc(args*)
    {
        return AhkStdlibTkinterMisc(args*)
    }

    static Wm(args*)
    {
        return AhkStdlibTkinterWm(args*)
    }

    static Tcl(args*)
    {
        if args.Length > 4
            throw TypeError("Tcl() takes from 0 to 4 positional arguments but " args.Length " were given", -1)
        return AhkStdlibTkinterTk(false, "Tcl", args*)
    }

    static Tk(args*)
    {
        if args.Length > 6
            throw TypeError("Tk.__init__() takes from 1 to 7 positional arguments but " args.Length + 1 " were given", -1)
        return AhkStdlibTkinterTk(true, "Tk", args*)
    }

    static Variable(args*)
    {
        return AhkStdlibTkinterPublicVariable(args*)
    }

    static Frame(args*)
    {
        return AhkStdlibTkinterFrame(args*)
    }

    static Label(args*)
    {
        return AhkStdlibTkinterLabel(args*)
    }

    static LabelFrame(args*)
    {
        return AhkStdlibTkinterLabelFrame(args*)
    }

    static Toplevel(args*)
    {
        return AhkStdlibTkinterToplevel(args*)
    }

    static Button(args*)
    {
        return AhkStdlibTkinterButton(args*)
    }

    static Checkbutton(args*)
    {
        return AhkStdlibTkinterCheckbutton(args*)
    }

    static Radiobutton(args*)
    {
        return AhkStdlibTkinterRadiobutton(args*)
    }

    static Scale(args*)
    {
        return AhkStdlibTkinterScale(args*)
    }

    static Scrollbar(args*)
    {
        return AhkStdlibTkinterScrollbar(args*)
    }

    static Menu(args*)
    {
        return AhkStdlibTkinterMenu(args*)
    }

    static Menubutton(args*)
    {
        return AhkStdlibTkinterMenubutton(args*)
    }

    static Message(args*)
    {
        return AhkStdlibTkinterMessage(args*)
    }

    static OptionMenu(args*)
    {
        return AhkStdlibTkinterOptionMenu(args*)
    }

    static PanedWindow(args*)
    {
        return AhkStdlibTkinterPanedWindow(args*)
    }

    static Canvas(args*)
    {
        return AhkStdlibTkinterCanvas(args*)
    }

    static Entry(args*)
    {
        return AhkStdlibTkinterEntry(args*)
    }

    static Spinbox(args*)
    {
        return AhkStdlibTkinterSpinbox(args*)
    }

    static Listbox(args*)
    {
        return AhkStdlibTkinterListbox(args*)
    }

    static Text(args*)
    {
        return AhkStdlibTkinterText(args*)
    }

    static BaseWidget(args*)
    {
        return AhkStdlibTkinterBaseWidget(args*)
    }

    static Widget(args*)
    {
        return AhkStdlibTkinterPublicWidget(args*)
    }

    static Image(args*)
    {
        return AhkStdlibTkinterPublicImage(args*)
    }

    static BitmapImage(args*)
    {
        return AhkStdlibTkinterBitmapImage(args*)
    }

    static PhotoImage(args*)
    {
        return AhkStdlibTkinterPhotoImage(args*)
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

class AhkStdlibTkinterTk
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
        if useTk {
            AhkStdlibTkinterSetDefaultRootCloseProtocol(this)
            AhkStdlibTkinterRegisterDefaultRoot(this)
        }
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
            throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(this.AhkStdlibInterp))
        return AhkStdlibTkinterGetStringResult(this.AhkStdlibInterp)
    }

    loadtk(args*)
    {
        if args.Length != 0
            throw TypeError("Tk.loadtk() takes 1 positional argument but " args.Length + 1 " were given", -1)
        if !this.AhkStdlibUseTk {
            AhkStdlibTkinterEnsureTclRuntime(true)
            AhkStdlibTkinterInitTk(this.AhkStdlibInterp)
            this.AhkStdlibUseTk := true
            AhkStdlibTkinterSetDefaultRootCloseProtocol(this)
            AhkStdlibTkinterRegisterDefaultRoot(this)
        }
        return stdlib.None
    }

    readprofile(args*)
    {
        if args.Length = 0
            throw TypeError("Tk.readprofile() missing 2 required positional arguments: 'baseName' and 'className'", -1)
        if args.Length = 1
            throw TypeError("Tk.readprofile() missing 1 required positional argument: 'className'", -1)
        if args.Length > 2
            throw TypeError("Tk.readprofile() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        AhkStdlibTkinterReadprofileTcl(this, args[2])
        AhkStdlibTkinterReadprofileTcl(this, args[1])
        return stdlib.None
    }

    report_callback_exception(args*)
    {
        if args.Length = 0
            throw TypeError("Tk.report_callback_exception() missing 3 required positional arguments: 'exc', 'val', and 'tb'", -1)
        if args.Length = 1
            throw TypeError("Tk.report_callback_exception() missing 2 required positional arguments: 'val' and 'tb'", -1)
        if args.Length = 2
            throw TypeError("Tk.report_callback_exception() missing 1 required positional argument: 'tb'", -1)
        if args.Length > 3
            throw TypeError("Tk.report_callback_exception() takes 4 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibLastCallbackException := { Exc: args[1], Value: args[2], Traceback: args[3] }
        return stdlib.None
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
            throw AhkStdlibTkinter.TclError("can't read " Chr(34) name Chr(34) ": no such variable")
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

    tk_bisque(args*)
    {
        return AhkStdlibTkinterBisque(this, args*)
    }

    tk_setPalette(args*)
    {
        return AhkStdlibTkinterSetPalette(this, args*)
    }

    tk_strictMotif(args*)
    {
        return AhkStdlibTkinterStrictMotif(this, args*)
    }

    register(args*)
    {
        return AhkStdlibTkinterRegisterPublic(this, args*)
    }

    deletecommand(args*)
    {
        return AhkStdlibTkinterDeleteCommandPublic(this, args*)
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
        optionWord := AhkStdlibTkinterTclWord(AhkStdlibTkinterWidgetDashOption(args[1]))
        value := this.eval(". cget " optionWord)
        return AhkStdlibTkinterCgetValue(args[1], value, this)
    }

    keys(args*)
    {
        return AhkStdlibTkinterKeys(this, ".", args*)
    }

    configure(args*)
    {
        if args.Length > 1
            throw TypeError("Misc.configure() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return AhkStdlibTkinterWidgetConfigureDict(this, ".")
        if args[1] is String
            return AhkStdlibTkinterWidgetConfigureOption(this, ".", args[1])
        if args[1] is Array || args[1] is AhkStdlibTuple {
            if args[1].Length = 0
                return stdlib.None
            throw ValueError("dictionary update sequence element #0 has length 1; 2 is required", -1)
        }
        if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
            throw TypeError("object of type '" AhkStdlibPyTypeName(args[1]) "' has no len()", -1)
        this.eval(". configure" AhkStdlibTkinterOptionsToScriptSkipNone(args[1], false, this))
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
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.eval("wm title .")
        return this.eval("wm title . " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_title(args*)
    {
        return this.title(args*)
    }

    geometry(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_geometry() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.eval("wm geometry .")
        return this.eval("wm geometry . " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_geometry(args*)
    {
        return this.geometry(args*)
    }

    attributes(args*)
    {
        return AhkStdlibTkinterWmAttributes(this, ".", args*)
    }

    wm_attributes(args*)
    {
        return this.attributes(args*)
    }

    aspect(args*)
    {
        return AhkStdlibTkinterWmAspect(this, ".", args*)
    }

    wm_aspect(args*)
    {
        return this.aspect(args*)
    }

    grid(args*)
    {
        return AhkStdlibTkinterWmGrid(this, ".", args*)
    }

    wm_grid(args*)
    {
        return this.grid(args*)
    }

    group(args*)
    {
        return AhkStdlibTkinterWmGroup(this, ".", args*)
    }

    wm_group(args*)
    {
        return this.group(args*)
    }

    command(args*)
    {
        return AhkStdlibTkinterWmCommand(this, ".", args*)
    }

    wm_command(args*)
    {
        return this.command(args*)
    }

    manage(args*)
    {
        return AhkStdlibTkinterWmManage(this, args*)
    }

    wm_manage(args*)
    {
        return this.manage(args*)
    }

    forget(args*)
    {
        return AhkStdlibTkinterWmForget(this, args*)
    }

    wm_forget(args*)
    {
        return this.forget(args*)
    }

    colormapwindows(args*)
    {
        return AhkStdlibTkinterWmColormapwindows(this, ".", args*)
    }

    wm_colormapwindows(args*)
    {
        return this.colormapwindows(args*)
    }

    iconposition(args*)
    {
        return AhkStdlibTkinterWmIconposition(this, ".", args*)
    }

    wm_iconposition(args*)
    {
        return this.iconposition(args*)
    }

    iconwindow(args*)
    {
        return AhkStdlibTkinterWmIconwindow(this, ".", args*)
    }

    wm_iconwindow(args*)
    {
        return this.iconwindow(args*)
    }

    iconmask(args*)
    {
        return AhkStdlibTkinterWmIconmask(this, ".", args*)
    }

    wm_iconmask(args*)
    {
        return this.iconmask(args*)
    }

    iconbitmap(args*)
    {
        return AhkStdlibTkinterWmIconbitmap(this, ".", args*)
    }

    wm_iconbitmap(args*)
    {
        return this.iconbitmap(args*)
    }

    iconphoto(args*)
    {
        return AhkStdlibTkinterWmIconphoto(this, ".", args*)
    }

    wm_iconphoto(args*)
    {
        return this.iconphoto(args*)
    }

    resizable(args*)
    {
        return AhkStdlibTkinterWmResizable(this, ".", args*)
    }

    wm_resizable(args*)
    {
        return this.resizable(args*)
    }

    minsize(args*)
    {
        return AhkStdlibTkinterWmSize(this, ".", "minsize", args*)
    }

    wm_minsize(args*)
    {
        return this.minsize(args*)
    }

    maxsize(args*)
    {
        return AhkStdlibTkinterWmSize(this, ".", "maxsize", args*)
    }

    wm_maxsize(args*)
    {
        return this.maxsize(args*)
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

    frame(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_frame() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.eval("wm frame .")
    }

    wm_frame(args*)
    {
        return this.frame(args*)
    }

    focusmodel(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_focusmodel() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.eval("wm focusmodel .")
        return this.eval("wm focusmodel . " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_focusmodel(args*)
    {
        return this.focusmodel(args*)
    }

    positionfrom(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_positionfrom() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.eval("wm positionfrom .")
        return this.eval("wm positionfrom . " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_positionfrom(args*)
    {
        return this.positionfrom(args*)
    }

    sizefrom(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_sizefrom() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.eval("wm sizefrom .")
        return this.eval("wm sizefrom . " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_sizefrom(args*)
    {
        return this.sizefrom(args*)
    }

    iconname(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_iconname() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.eval("wm iconname .")
        return this.eval("wm iconname . " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_iconname(args*)
    {
        return this.iconname(args*)
    }

    client(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_client() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.eval("wm client .")
        return this.eval("wm client . " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_client(args*)
    {
        return this.client(args*)
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

    grab_set_global(args*)
    {
        return AhkStdlibTkinterGrabSetGlobal(this, ".", args*)
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

    focus(args*)
    {
        return this.focus_set(args*)
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

    focus_lastfor(args*)
    {
        return AhkStdlibTkinterFocusLastfor(this, ".", args*)
    }

    tk_focusNext(args*)
    {
        return AhkStdlibTkinterFocusTraversal(this, ".", "tk_focusNext", args*)
    }

    tk_focusPrev(args*)
    {
        return AhkStdlibTkinterFocusTraversal(this, ".", "tk_focusPrev", args*)
    }

    tk_focusFollowsMouse(args*)
    {
        return AhkStdlibTkinterFocusFollowsMouse(this, args*)
    }

    bell(args*)
    {
        return AhkStdlibTkinterBell(this, ".", args*)
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

    selection_get(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.selection_get() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.eval("selection get")
    }

    selection_handle(args*)
    {
        return AhkStdlibTkinterSelectionHandle(this, ".", args*)
    }

    selection_clear(args*)
    {
        return AhkStdlibTkinterSelectionClear(this, args*)
    }

    selection_own(args*)
    {
        return AhkStdlibTkinterSelectionOwn(this, ".", args*)
    }

    selection_own_get(args*)
    {
        return AhkStdlibTkinterSelectionOwnGet(this, args*)
    }

    send(args*)
    {
        return AhkStdlibTkinterSend(this, args*)
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

    wm_state(args*)
    {
        return this.state(args*)
    }

    withdraw(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_withdraw() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.eval("wm withdraw .")
    }

    wm_withdraw(args*)
    {
        return this.withdraw(args*)
    }

    iconify(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_iconify() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.eval("wm iconify .")
    }

    wm_iconify(args*)
    {
        return this.iconify(args*)
    }

    deiconify(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_deiconify() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.eval("wm deiconify .")
    }

    wm_deiconify(args*)
    {
        return this.deiconify(args*)
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
        while !this.AhkStdlibQuitMainLoop {
            try {
                if this.eval("winfo exists .") != "1"
                    break
                this.update()
            } catch as err {
                if AhkStdlibTkinterIsApplicationDestroyedError(err) {
                    AhkStdlibTkinterForgetDefaultRoot(this)
                    break
                }
                throw err
            }
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
        AhkStdlibTkinterCancelPendingThemeChanged(this.AhkStdlibInterp)
        AhkStdlibTkinterSilenceDestroyBackgroundErrors(this.AhkStdlibInterp)
        resultCode := DllCall("tcl86t\Tcl_Eval", "Ptr", this.AhkStdlibInterp, "Ptr", AhkStdlibTkinterUtf8Buffer("destroy .").Ptr, "Int")
        if resultCode != 0
            throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(this.AhkStdlibInterp))
        AhkStdlibTkinterForgetDefaultRoot(this)
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
            master := AhkStdlibTkinterGetDefaultRoot("create widget")
        if !IsObject(master) || !HasProp(master, "tk")
            throw AttributeError("'" AhkStdlibPyTypeName(master) "' object has no attribute 'tk'", -1)

        this.master := master
        this.tk := master.tk
        this.AhkStdlibRoot := master._root()
        this.AhkStdlibTkCommand := tkCommand
        this._w := AhkStdlibTkinterResolveWidgetPath(this.AhkStdlibRoot, String(master), tkCommand, options)

        script := tkCommand " " this._w AhkStdlibTkinterOptionsToScriptSkipNone(options, false, this.AhkStdlibRoot)
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
        optionWord := AhkStdlibTkinterTclWord(AhkStdlibTkinterWidgetDashOption(args[1]))
        value := this.AhkStdlibRoot.eval(this._w " cget " optionWord)
        return AhkStdlibTkinterCgetValue(args[1], value, this.AhkStdlibRoot)
    }

    keys(args*)
    {
        return AhkStdlibTkinterKeys(this.AhkStdlibRoot, this._w, args*)
    }

    configure(args*)
    {
        if args.Length > 1
            throw TypeError("Misc.configure() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return AhkStdlibTkinterWidgetConfigureDict(this.AhkStdlibRoot, this._w)
        if args[1] is String
            return AhkStdlibTkinterWidgetConfigureOption(this.AhkStdlibRoot, this._w, args[1])
        if args[1] is Array || args[1] is AhkStdlibTuple {
            if args[1].Length = 0
                return stdlib.None
            throw ValueError("dictionary update sequence element #0 has length 1; 2 is required", -1)
        }
        if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
            throw TypeError("cnf must be a dictionary", -1)
        this.AhkStdlibRoot.eval(this._w " configure" AhkStdlibTkinterOptionsToScriptSkipNone(args[1], false, this.AhkStdlibRoot))
        return stdlib.None
    }

    config(args*)
    {
        return this.configure(args*)
    }

    state(args*)
    {
        if args.Length > 1
            throw TypeError("Widget.state() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(this._w " state")))

        statespec := AhkStdlibTkinterStateSpecWord(args[1])
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(this._w " state " statespec)))
    }

    instate(args*)
    {
        if args.Length = 0
            throw TypeError("Widget.instate() missing 1 required positional argument: 'statespec'", -1)

        statespec := AhkStdlibTkinterStateSpecWord(args[1])
        matched := AhkStdlibTkinterGetBoolean(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(this._w " instate " statespec))
        if AhkStdlibTruthValue(matched) && args.Length >= 2 {
            callback := args[2]
            if AhkStdlibIsNone(callback)
                return matched
            callbackArgs := []
            index := 3
            while index <= args.Length {
                callbackArgs.Push(args[index])
                index += 1
            }
            return callback.Call(callbackArgs*)
        }
        return matched
    }

    pack(args*)
    {
        if args.Length > 1
            throw TypeError("pack_configure() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        script := "pack " this._w
        if args.Length = 1 {
            if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
                throw TypeError("object of type '" AhkStdlibPyTypeName(args[1]) "' has no len()", -1)
            script .= AhkStdlibTkinterOptionsToScriptSkipNone(args[1], true)
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
            script .= AhkStdlibTkinterOptionsToScriptSkipNone(args[1], true)
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
            script .= AhkStdlibTkinterOptionsToScriptSkipNone(args[1], true)
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

    update(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.update() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval("update")
        return stdlib.None
    }

    update_idletasks(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.update_idletasks() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval("update idletasks")
        return stdlib.None
    }

    after(args*)
    {
        if args.Length = 0
            throw TypeError("Misc.after() missing 1 required positional argument: 'ms'", -1)
        return AhkStdlibTkinterAfter(this.AhkStdlibRoot, args*)
    }

    after_idle(args*)
    {
        if args.Length = 0
            throw TypeError("Misc.after_idle() missing 1 required positional argument: 'func'", -1)
        return AhkStdlibTkinterAfter(this.AhkStdlibRoot, "idle", args*)
    }

    after_cancel(args*)
    {
        if args.Length = 0
            throw TypeError("Misc.after_cancel() missing 1 required positional argument: 'id'", -1)
        if args.Length > 1
            throw TypeError("Misc.after_cancel() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval("after cancel " AhkStdlibTkinterTclWord(args[1]))
        return stdlib.None
    }

    image_names(args*)
    {
        return AhkStdlibTkinterImageNames(this.AhkStdlibRoot, args*)
    }

    image_types(args*)
    {
        return AhkStdlibTkinterImageTypes(this.AhkStdlibRoot, args*)
    }

    mainloop(args*)
    {
        return this.AhkStdlibRoot.mainloop(args*)
    }

    quit(args*)
    {
        return this.AhkStdlibRoot.quit(args*)
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

    grab_set_global(args*)
    {
        return AhkStdlibTkinterGrabSetGlobal(this.AhkStdlibRoot, this._w, args*)
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

    focus(args*)
    {
        return this.focus_set(args*)
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

    focus_lastfor(args*)
    {
        return AhkStdlibTkinterFocusLastfor(this.AhkStdlibRoot, this._w, args*)
    }

    tk_focusNext(args*)
    {
        return AhkStdlibTkinterFocusTraversal(this.AhkStdlibRoot, this._w, "tk_focusNext", args*)
    }

    tk_focusPrev(args*)
    {
        return AhkStdlibTkinterFocusTraversal(this.AhkStdlibRoot, this._w, "tk_focusPrev", args*)
    }

    tk_focusFollowsMouse(args*)
    {
        return AhkStdlibTkinterFocusFollowsMouse(this.AhkStdlibRoot, args*)
    }

    bell(args*)
    {
        return AhkStdlibTkinterBell(this.AhkStdlibRoot, this._w, args*)
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

    selection_handle(args*)
    {
        return AhkStdlibTkinterSelectionHandle(this.AhkStdlibRoot, this._w, args*)
    }

    selection_clear(args*)
    {
        return AhkStdlibTkinterSelectionClear(this.AhkStdlibRoot, args*)
    }

    selection_own(args*)
    {
        return AhkStdlibTkinterSelectionOwn(this.AhkStdlibRoot, this._w, args*)
    }

    selection_own_get(args*)
    {
        return AhkStdlibTkinterSelectionOwnGet(this.AhkStdlibRoot, args*)
    }

    send(args*)
    {
        return AhkStdlibTkinterSend(this.AhkStdlibRoot, args*)
    }

    setvar(args*)
    {
        return this.AhkStdlibRoot.setvar(args*)
    }

    getvar(args*)
    {
        return this.AhkStdlibRoot.getvar(args*)
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

    tk_bisque(args*)
    {
        return AhkStdlibTkinterBisque(this.AhkStdlibRoot, args*)
    }

    tk_setPalette(args*)
    {
        return AhkStdlibTkinterSetPalette(this.AhkStdlibRoot, args*)
    }

    tk_strictMotif(args*)
    {
        return AhkStdlibTkinterStrictMotif(this.AhkStdlibRoot, args*)
    }

    register(args*)
    {
        return AhkStdlibTkinterRegisterPublic(this.AhkStdlibRoot, args*)
    }

    deletecommand(args*)
    {
        return AhkStdlibTkinterDeleteCommandPublic(this.AhkStdlibRoot, args*)
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

class AhkStdlibTkinterBaseWidget
{
    __New(args*)
    {
        AhkStdlibTkinterPublicWidgetNew(this, "BaseWidget", args*)
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
        optionWord := AhkStdlibTkinterTclWord(AhkStdlibTkinterWidgetDashOption(args[1]))
        value := this.AhkStdlibRoot.eval(this._w " cget " optionWord)
        return AhkStdlibTkinterCgetValue(args[1], value, this.AhkStdlibRoot)
    }

    keys(args*)
    {
        return AhkStdlibTkinterKeys(this.AhkStdlibRoot, this._w, args*)
    }

    configure(args*)
    {
        if args.Length > 1
            throw TypeError("Misc.configure() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return AhkStdlibTkinterWidgetConfigureDict(this.AhkStdlibRoot, this._w)
        if args[1] is String
            return AhkStdlibTkinterWidgetConfigureOption(this.AhkStdlibRoot, this._w, args[1])
        if args[1] is Array || args[1] is AhkStdlibTuple {
            if args[1].Length = 0
                return stdlib.None
            throw ValueError("dictionary update sequence element #0 has length 1; 2 is required", -1)
        }
        if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
            throw TypeError("cnf must be a dictionary", -1)
        this.AhkStdlibRoot.eval(this._w " configure" AhkStdlibTkinterOptionsToScriptSkipNone(args[1], false, this.AhkStdlibRoot))
        return stdlib.None
    }

    config(args*)
    {
        return this.configure(args*)
    }

    winfo_class(args*)
    {
        return AhkStdlibTkinterWinfoString(this.AhkStdlibRoot, this._w, "class", "winfo_class", args*)
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

    __Call(name, args*)
    {
        throw AttributeError("'BaseWidget' object has no attribute '" name "'", -1)
    }
}

class AhkStdlibTkinterPublicWidget extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        AhkStdlibTkinterPublicWidgetNew(this, "Widget", args*)
    }
}

class AhkStdlibTkinterTtk
{
    static setup_master(args*)
    {
        if args.Length > 1
            throw TypeError("setup_master() takes from 0 to 1 positional arguments but " args.Length " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return AhkStdlibTkinterTtkSetupMasterDefaultRoot()
        return args[1]
    }

    static tclobjs_to_py(args*)
    {
        if args.Length = 0
            throw TypeError("tclobjs_to_py() missing 1 required positional argument: 'adict'", -1)
        if args.Length > 1
            throw TypeError("tclobjs_to_py() takes 1 positional argument but " args.Length " were given", -1)
        return AhkStdlibTkinterTtkTclobjsToPy(args[1])
    }

    class AhkStdlibTkinterTtkWidget extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            if args.Length = 0
                throw TypeError("Widget.__init__() missing 2 required positional arguments: 'master' and 'widgetname'", -1)
            if args.Length = 1
                throw TypeError("Widget.__init__() missing 1 required positional argument: 'widgetname'", -1)
            if args.Length > 3
                throw TypeError("Widget.__init__() takes from 3 to 4 positional arguments but " args.Length + 1 " were given", -1)

            master := args[1]
            widgetName := args[2]
            options := {}
            if args.Length = 3 {
                if !AhkStdlibTkinterIsPlainKeywordObject(args[3]) {
                    if args[3] is String
                        throw ValueError("dictionary update sequence element #0 has length 1; 2 is required", -1)
                    throw AttributeError("'" AhkStdlibPyTypeName(args[3]) "' object has no attribute 'items'", -1)
                }
                options := args[3]
            }

            if AhkStdlibIsNone(master)
                master := AhkStdlibTkinterGetOrCreateDefaultRoot()
            if !IsObject(master) || !HasProp(master, "tk")
                throw AttributeError("'" AhkStdlibPyTypeName(master) "' object has no attribute 'tk'", -1)

            this.master := master
            this.tk := master.tk
            this.AhkStdlibRoot := master._root()
            this.AhkStdlibTkCommand := widgetName
            this.widgetName := widgetName
            this._w := AhkStdlibTkinterResolveWidgetPath(this.AhkStdlibRoot, String(master), "widget", options)

            script := widgetName " " this._w AhkStdlibTkinterOptionsToScript(options, false, this.AhkStdlibRoot)
            this.AhkStdlibRoot.eval(script)
            this.AhkStdlibRoot.AhkStdlibWidgetsByPath[this._w] := this
        }

        identify(args*)
        {
            return AhkStdlibTkinterTtkWidgetIdentify(this, args*)
        }
    }

    class AhkStdlibTkinterCombobox extends AhkStdlibTkinterTtk.AhkStdlibTkinterEntry
    {
        __New(args*)
        {
            AhkStdlibTkinterWidget.Prototype.__New.Call(this, "Combobox", "ttk::combobox", args*)
            this.widgetName := "ttk::combobox"
            this.AhkStdlibTkCommand := "ttk::combobox"
        }

        current(args*)
        {
            if args.Length > 1
                throw TypeError("Combobox.current() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
            if args.Length = 0 || AhkStdlibIsNone(args[1])
                return Integer(this.AhkStdlibRoot.eval(this._w " current"))
            this.AhkStdlibRoot.eval(this._w " current " AhkStdlibTkinterTtkComboboxCurrentWord(args[1]))
            return stdlib.None
        }

        get(args*)
        {
            if args.Length != 0
                throw TypeError("Entry.get() takes 1 positional argument but " args.Length + 1 " were given", -1)
            return this.AhkStdlibRoot.eval(this._w " get")
        }

        set(args*)
        {
            if args.Length = 0
                throw TypeError("Combobox.set() missing 1 required positional argument: 'value'", -1)
            if args.Length > 1
                throw TypeError("Combobox.set() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " set"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkComboboxSetValueWord(args[1])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        configure(args*)
        {
            if args.Length = 1 && args[1] is String {
                optionName := AhkStdlibTkinterWidgetOptionName(args[1])
                value := AhkStdlibTkinterWidgetConfigureOption(this.AhkStdlibRoot, this._w, args[1])
                if optionName = "width"
                    return stdlib.tuple([value[1], value[2], value[3], Integer(value[4]), value[5]])
                return value
            }
            return super.configure(args*)
        }

        config(args*)
        {
            return this.configure(args*)
        }

        identify(args*)
        {
            return AhkStdlibTkinterTtkWidgetIdentify(this, args*)
        }
    }

    class AhkStdlibTkinterEntry extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Entry", "ttk::entry", args*)
            this.widgetName := "ttk::entry"
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
            script := this._w " insert"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkEntryIndexWord(args[1])
            if !AhkStdlibIsNone(args[2])
                script .= " " AhkStdlibTkinterTtkEntryStringWord(args[2])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        delete(args*)
        {
            if args.Length = 0
                throw TypeError("Entry.delete() missing 1 required positional argument: 'first'", -1)
            if args.Length > 2
                throw TypeError("Entry.delete() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " delete"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkEntryIndexWord(args[1])
            if args.Length = 2 && !AhkStdlibIsNone(args[2])
                script .= " " AhkStdlibTkinterTtkEntryIndexWord(args[2])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        bbox(args*)
        {
            if args.Length = 0
                throw TypeError("Entry.bbox() missing 1 required positional argument: 'index'", -1)
            if args.Length > 1
                throw TypeError("Entry.bbox() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " bbox"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkEntryIndexWord(args[1])
            return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(script))
        }

        identify(args*)
        {
            if args.Length = 0
                throw TypeError("Entry.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
            if args.Length = 1
                throw TypeError("Entry.identify() missing 1 required positional argument: 'y'", -1)
            if args.Length > 2
                throw TypeError("Entry.identify() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " identify"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkEntryIndexWord(args[1])
            if !AhkStdlibIsNone(args[2])
                script .= " " AhkStdlibTkinterTtkEntryIndexWord(args[2])
            return this.AhkStdlibRoot.eval(script)
        }

        validate(args*)
        {
            if args.Length != 0
                throw TypeError("Entry.validate() takes 1 positional argument but " args.Length + 1 " were given", -1)
            return AhkStdlibTkinterGetBoolean(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(this._w " validate"))
        }

        index(args*)
        {
            if args.Length = 0
                throw TypeError("Entry.index() missing 1 required positional argument: 'index'", -1)
            if args.Length > 1
                throw TypeError("Entry.index() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " index"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkEntryIndexWord(args[1])
            return Integer(this.AhkStdlibRoot.eval(script))
        }

        icursor(args*)
        {
            if args.Length = 0
                throw TypeError("Entry.icursor() missing 1 required positional argument: 'index'", -1)
            if args.Length > 1
                throw TypeError("Entry.icursor() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " icursor"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkEntryIndexWord(args[1])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
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

        scan_mark(args*)
        {
            if args.Length = 0
                throw TypeError("Entry.scan_mark() missing 1 required positional argument: 'x'", -1)
            if args.Length > 1
                throw TypeError("Entry.scan_mark() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            this.AhkStdlibRoot.eval(this._w " scan mark " AhkStdlibTkinterTclWord(args[1]))
            return stdlib.None
        }

        scan_dragto(args*)
        {
            if args.Length = 0
                throw TypeError("Entry.scan_dragto() missing 1 required positional argument: 'x'", -1)
            if args.Length > 1
                throw TypeError("Entry.scan_dragto() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            this.AhkStdlibRoot.eval(this._w " scan dragto " AhkStdlibTkinterTclWord(args[1]))
            return stdlib.None
        }

        xview(args*)
        {
            script := this._w " xview"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkEntryIndexWord(value)
            }
            value := this.AhkStdlibRoot.eval(script)
            return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
        }

        xview_moveto(args*)
        {
            if args.Length = 0
                throw TypeError("XView.xview_moveto() missing 1 required positional argument: 'fraction'", -1)
            if args.Length > 1
                throw TypeError("XView.xview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " xview moveto"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkFloatValueWord(args[1])
            this.AhkStdlibRoot.eval(script)
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
            script := this._w " xview scroll"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkFloatValueWord(value)
            }
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }
    }

    class AhkStdlibTkinterSpinbox extends AhkStdlibTkinterTtk.AhkStdlibTkinterEntry
    {
        __New(args*)
        {
            if args.Length > 2
                throw TypeError("Spinbox.__init__() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
            AhkStdlibTkinterWidget.Prototype.__New.Call(this, "Spinbox", "ttk::spinbox", args*)
            this.widgetName := "ttk::spinbox"
            this.AhkStdlibTkCommand := "ttk::spinbox"
        }

        cget(args*)
        {
            if args.Length = 0
                throw TypeError("Misc.cget() missing 1 required positional argument: 'key'", -1)
            if args.Length > 1
                throw TypeError("Misc.cget() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            optionWord := AhkStdlibTkinterTclWord(AhkStdlibTkinterWidgetDashOption(args[1]))
            optionName := AhkStdlibTkinterWidgetOptionName(args[1])
            value := this.AhkStdlibRoot.eval(this._w " cget " optionWord)
            return AhkStdlibTkinterTtkSpinboxValue(this.AhkStdlibRoot, optionName, value)
        }

        configure(args*)
        {
            if args.Length = 1 && args[1] is String {
                optionName := AhkStdlibTkinterWidgetOptionName(args[1])
                return AhkStdlibTkinterTtkSpinboxConfigureOption(this.AhkStdlibRoot, this._w, args[1])
            }
            return super.configure(args*)
        }

        config(args*)
        {
            return this.configure(args*)
        }

        set(args*)
        {
            if args.Length = 0
                throw TypeError("Spinbox.set() missing 1 required positional argument: 'value'", -1)
            if args.Length > 1
                throw TypeError("Spinbox.set() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " set"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkSpinboxSetValueWord(args[1])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }
    }

    class AhkStdlibTkinterTtkMenubutton extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            if args.Length > 2
                throw TypeError("Menubutton.__init__() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
            super.__New("Menubutton", "ttk::menubutton", args*)
            this.widgetName := "ttk::menubutton"
        }

        cget(args*)
        {
            if args.Length = 0
                throw TypeError("Misc.cget() missing 1 required positional argument: 'key'", -1)
            if args.Length > 1
                throw TypeError("Misc.cget() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            optionWord := AhkStdlibTkinterTclWord(AhkStdlibTkinterWidgetDashOption(args[1]))
            optionName := AhkStdlibTkinterWidgetOptionName(args[1])
            value := this.AhkStdlibRoot.eval(this._w " cget " optionWord)
            return AhkStdlibTkinterTtkMenubuttonValue(optionName, value)
        }

        configure(args*)
        {
            if args.Length = 1 && args[1] is String {
                optionName := AhkStdlibTkinterWidgetOptionName(args[1])
                return AhkStdlibTkinterTtkMenubuttonConfigureOption(this.AhkStdlibRoot, this._w, args[1])
            }
            return super.configure(args*)
        }

        config(args*)
        {
            return this.configure(args*)
        }

        identify(args*)
        {
            return AhkStdlibTkinterTtkWidgetIdentify(this, args*)
        }
    }

    class AhkStdlibTkinterTtkOptionMenu extends AhkStdlibTkinterTtk.AhkStdlibTkinterTtkMenubutton
    {
        __New(args*)
        {
            if args.Length = 0
                throw TypeError("OptionMenu.__init__() missing 2 required positional arguments: 'master' and 'variable'", -1)
            if args.Length = 1
                throw TypeError("OptionMenu.__init__() missing 1 required positional argument: 'variable'", -1)

            master := args[1]
            variable := args[2]
            defaultValue := args.Length >= 3 ? args[3] : stdlib.None
            values := []
            options := {}
            lastIsOptions := args.Length > 3 && AhkStdlibTkinterIsPlainKeywordObject(args[args.Length])
            lastValueIndex := lastIsOptions ? args.Length - 1 : args.Length
            index := 4
            while index <= lastValueIndex {
                values.Push(args[index])
                index += 1
            }
            if lastIsOptions
                options := args[args.Length]
            for key, value in options.OwnProps() {
                if key != "command"
                    throw AhkStdlibTkinter.TclError("unknown option -" key)
            }

            if !IsObject(master) || !HasProp(master, "tk")
                throw AttributeError("'" AhkStdlibPyTypeName(master) "' object has no attribute 'tk'", -1)

            callback := options.HasOwnProp("command") ? options.command : stdlib.None
            this.AhkStdlibOptionVariable := variable
            this.AhkStdlibOptionCallback := callback

            widgetOptions := { textvariable: variable, direction: "below" }
            if AhkStdlibTruthValue(defaultValue) {
                variable.set(defaultValue)
                widgetOptions.text := defaultValue
            }
            AhkStdlibTkinterWidget.Prototype.__New.Call(this, "OptionMenu", "ttk::menubutton", master, widgetOptions)
            this.widgetName := "ttk::menubutton"
            this.AhkStdlibMenu := AhkStdlibTkinterMenu(this, { tearoff: 0 })
            this.menuname := String(this.AhkStdlibMenu)
            this.configure({ menu: this.AhkStdlibMenu })
            AhkStdlibTkinterTtkOptionMenuPopulate(this, values*)
        }

        __Item[name]
        {
            get {
                if name = "menu"
                    return this.AhkStdlibMenu
                return this.cget(name)
            }
        }

        set_menu(args*)
        {
            defaultValue := args.Length >= 1 ? args[1] : stdlib.None
            values := []
            index := 2
            while index <= args.Length {
                values.Push(args[index])
                index += 1
            }
            if AhkStdlibTruthValue(defaultValue) {
                this.AhkStdlibOptionVariable.set(defaultValue)
                this.configure({ text: defaultValue })
            }
            AhkStdlibTkinterTtkOptionMenuPopulate(this, values*)
            return stdlib.None
        }
    }

    class AhkStdlibTkinterFrame extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Frame", "ttk::frame", args*)
            this.widgetName := "ttk::frame"
        }

        identify(args*)
        {
            return AhkStdlibTkinterTtkWidgetIdentify(this, args*)
        }
    }

    class AhkStdlibTkinterLabel extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Label", "ttk::label", args*)
            this.widgetName := "ttk::label"
        }

        identify(args*)
        {
            return AhkStdlibTkinterTtkWidgetIdentify(this, args*)
        }
    }

    class AhkStdlibTkinterButton extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Button", "ttk::button", args*)
            this.widgetName := "ttk::button"
        }

        identify(args*)
        {
            return AhkStdlibTkinterTtkWidgetIdentify(this, args*)
        }

        invoke(args*)
        {
            if args.Length != 0
                throw TypeError("Button.invoke() takes 1 positional argument but " args.Length + 1 " were given", -1)
            return this.AhkStdlibRoot.eval(this._w " invoke")
        }
    }

    class AhkStdlibTkinterCheckbutton extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Checkbutton", "ttk::checkbutton", args*)
            this.widgetName := "ttk::checkbutton"
        }

        identify(args*)
        {
            return AhkStdlibTkinterTtkWidgetIdentify(this, args*)
        }

        invoke(args*)
        {
            if args.Length != 0
                throw TypeError("Checkbutton.invoke() takes 1 positional argument but " args.Length + 1 " were given", -1)
            return this.AhkStdlibRoot.eval(this._w " invoke")
        }
    }

    class AhkStdlibTkinterRadiobutton extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Radiobutton", "ttk::radiobutton", args*)
            this.widgetName := "ttk::radiobutton"
        }

        identify(args*)
        {
            return AhkStdlibTkinterTtkWidgetIdentify(this, args*)
        }

        invoke(args*)
        {
            if args.Length != 0
                throw TypeError("Radiobutton.invoke() takes 1 positional argument but " args.Length + 1 " were given", -1)
            return this.AhkStdlibRoot.eval(this._w " invoke")
        }
    }

    class AhkStdlibTkinterScale extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Scale", "ttk::scale", args*)
            this.widgetName := "ttk::scale"
        }

        get(args*)
        {
            script := this._w " get"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkScaleValueWord(value)
            }
            value := this.AhkStdlibRoot.eval(script)
            return args.Length = 0 ? AhkStdlibTkinterIntOrFloatValue(value) : value
        }

        coords(args*)
        {
            if args.Length > 1
                throw TypeError("Scale.coords() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " coords"
            if args.Length = 1 && !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkScaleValueWord(args[1])
            return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(script))
        }

        identify(args*)
        {
            if args.Length = 0
                throw TypeError("Widget.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
            if args.Length = 1
                throw TypeError("Widget.identify() missing 1 required positional argument: 'y'", -1)
            if args.Length > 2
                throw TypeError("Widget.identify() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " identify"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkScaleValueWord(value)
            }
            return this.AhkStdlibRoot.eval(script)
        }

        set(args*)
        {
            if args.Length = 0
                throw TypeError("Scale.set() missing 1 required positional argument: 'value'", -1)
            if args.Length > 1
                throw TypeError("Scale.set() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " set"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkScaleValueWord(args[1])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        configure(args*)
        {
            shouldGenerateRangeChanged := false
            if args.Length = 1 && AhkStdlibTkinterIsPlainKeywordObject(args[1]) {
                for key, value in args[1].OwnProps() {
                    optionName := AhkStdlibTkinterWidgetOptionName(key)
                    if optionName = "from" || optionName = "to" {
                        shouldGenerateRangeChanged := true
                        break
                    }
                }
            }

            result := super.configure(args*)
            if shouldGenerateRangeChanged
                this.event_generate("<<RangeChanged>>")
            return result
        }
    }

    class AhkStdlibTkinterTtkLabeledScale extends AhkStdlibTkinterTtk.AhkStdlibTkinterFrame
    {
        __New(args*)
        {
            if args.Length > 2
                throw TypeError("LabeledScale.__init__() takes from 1 to 3 positional arguments but " args.Length + 1 " were given", -1)

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
                master := AhkStdlibTkinterGetDefaultRoot("create widget")
            if !IsObject(master) || !HasProp(master, "tk")
                throw AttributeError("'" AhkStdlibPyTypeName(master) "' object has no attribute 'tk'", -1)

            variable := stdlib.None
            fromValue := 0
            toValue := 10
            compound := "top"
            frameOptions := {}
            for key, value in options.OwnProps() {
                switch key {
                    case "master":
                        continue
                    case "variable":
                        variable := value
                    case "from_":
                        fromValue := value
                    case "from":
                        fromValue := value
                    case "to":
                        toValue := value
                    case "compound":
                        compound := value
                    default:
                        frameOptions.%key% := value
                }
            }

            AhkStdlibTkinterWidget.Prototype.__New.Call(this, "LabeledScale", "ttk::frame", master, frameOptions)
            this.widgetName := "ttk::frame"
            this.AhkStdlibTkCommand := "ttk::frame"
            this.AhkStdlibTtkLabeledLabelTop := compound = "top"
            this.AhkStdlibTtkLabeledLastValid := fromValue
            this.AhkStdlibTtkLabeledAdjusting := false
            this._variable := AhkStdlibIsNone(variable) ? AhkStdlibTkinterIntVar(master) : variable
            this._variable.set(fromValue)

            this.label := AhkStdlibTkinterTtk.AhkStdlibTkinterLabel(this)
            this.scale := AhkStdlibTkinterTtk.AhkStdlibTkinterScale(this, { variable: this._variable, from_: fromValue, to: toValue })
            scaleSide := this.AhkStdlibTtkLabeledLabelTop ? "bottom" : "top"
            labelSide := scaleSide = "bottom" ? "top" : "bottom"
            this.scale.pack({ side: scaleSide, fill: "x" })
            this.AhkStdlibTtkLabeledDummy := AhkStdlibTkinterTtk.AhkStdlibTkinterLabel(this)
            this.AhkStdlibTtkLabeledDummy.pack({ side: labelSide })
            this.AhkStdlibTtkLabeledDummy.lower()
            this.label.place({ anchor: labelSide = "top" ? "n" : "s" })
            this.AhkStdlibTtkLabeledTraceCallback := this._variable.trace_variable("w", ObjBindMethod(this, "AhkStdlibTtkLabeledAdjust"))
            this.scale.bind("<<RangeChanged>>", ObjBindMethod(this, "AhkStdlibTtkLabeledAdjust"))
            this.bind("<Configure>", ObjBindMethod(this, "AhkStdlibTtkLabeledAdjust"))
            this.bind("<Map>", ObjBindMethod(this, "AhkStdlibTtkLabeledAdjust"))
        }

        value
        {
            get {
                if !this.HasOwnProp("_variable")
                    throw AttributeError("'LabeledScale' object has no attribute '_variable'", -1)
                return this._variable.get()
            }
            set {
                if !this.HasOwnProp("_variable")
                    throw AttributeError("'LabeledScale' object has no attribute '_variable'", -1)
                this._variable.set(value)
                this.AhkStdlibTtkLabeledAdjust()
            }
        }

        destroy()
        {
            if this.HasOwnProp("_variable") && this.HasOwnProp("AhkStdlibTtkLabeledTraceCallback")
                try this._variable.trace_vdelete("w", this.AhkStdlibTtkLabeledTraceCallback)
            this.DeleteProp("_variable")
            super.destroy()
            this.label := stdlib.None
            this.scale := stdlib.None
            return stdlib.None
        }

        identify(args*)
        {
            if args.Length = 0
                throw TypeError("Widget.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
            if args.Length = 1
                throw TypeError("Widget.identify() missing 1 required positional argument: 'y'", -1)
            if args.Length > 2
                throw TypeError("Widget.identify() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " identify"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkFloatValueWord(value)
            }
            return this.AhkStdlibRoot.eval(script)
        }

        AhkStdlibTtkLabeledAdjust(args*)
        {
            if this.AhkStdlibTtkLabeledAdjusting || !this.HasOwnProp("_variable") || AhkStdlibIsNone(this.label) || AhkStdlibIsNone(this.scale)
                return stdlib.None
            this.AhkStdlibTtkLabeledAdjusting := true
            try {
                fromValue := AhkStdlibTkinterIntOrFloatValue(this.scale.cget("from"))
                toValue := AhkStdlibTkinterIntOrFloatValue(this.scale.cget("to"))
                low := fromValue <= toValue ? fromValue : toValue
                high := fromValue <= toValue ? toValue : fromValue
                newValue := this._variable.get()
                if newValue < low || newValue > high {
                    this._variable.set(this.AhkStdlibTtkLabeledLastValid)
                    return stdlib.None
                }
                this.AhkStdlibTtkLabeledLastValid := newValue
                this.label.configure({ text: newValue })
                return stdlib.None
            } finally {
                this.AhkStdlibTtkLabeledAdjusting := false
            }
        }
    }

    class AhkStdlibTkinterScrollbar extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Scrollbar", "ttk::scrollbar", args*)
            this.widgetName := "ttk::scrollbar"
        }

        activate(args*)
        {
            if args.Length > 1
                throw TypeError("Scrollbar.activate() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " activate"
            if args.Length = 1 && !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkInheritedCommandWord(args[1])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
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
            script := this._w " delta"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkFloatValueWord(args[1])
            if !AhkStdlibIsNone(args[2])
                script .= " " AhkStdlibTkinterTtkFloatValueWord(args[2])
            return Float(this.AhkStdlibRoot.eval(script))
        }

        fraction(args*)
        {
            if args.Length = 0
                throw TypeError("Scrollbar.fraction() missing 2 required positional arguments: 'x' and 'y'", -1)
            if args.Length = 1
                throw TypeError("Scrollbar.fraction() missing 1 required positional argument: 'y'", -1)
            if args.Length > 2
                throw TypeError("Scrollbar.fraction() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " fraction"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkFloatValueWord(args[1])
            if !AhkStdlibIsNone(args[2])
                script .= " " AhkStdlibTkinterTtkFloatValueWord(args[2])
            return Float(this.AhkStdlibRoot.eval(script))
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
                throw TypeError("Widget.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
            if args.Length = 1
                throw TypeError("Widget.identify() missing 1 required positional argument: 'y'", -1)
            if args.Length > 2
                throw TypeError("Widget.identify() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " identify"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkFloatValueWord(value)
            }
            return this.AhkStdlibRoot.eval(script)
        }

        set(args*)
        {
            if args.Length = 0
                throw TypeError("Scrollbar.set() missing 2 required positional arguments: 'first' and 'last'", -1)
            if args.Length = 1
                throw TypeError("Scrollbar.set() missing 1 required positional argument: 'last'", -1)
            if args.Length > 2
                throw TypeError("Scrollbar.set() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " set"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkFloatValueWord(args[1])
            if !AhkStdlibIsNone(args[2])
                script .= " " AhkStdlibTkinterTtkFloatValueWord(args[2])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }
    }

    class AhkStdlibTkinterSeparator extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Separator", "ttk::separator", args*)
            this.widgetName := "ttk::separator"
        }

        identify(args*)
        {
            return AhkStdlibTkinterTtkWidgetIdentify(this, args*)
        }
    }

    class AhkStdlibTkinterProgressbar extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Progressbar", "ttk::progressbar", args*)
            this.widgetName := "ttk::progressbar"
        }

        identify(args*)
        {
            return AhkStdlibTkinterTtkWidgetIdentify(this, args*)
        }

        start(args*)
        {
            if args.Length > 1
                throw TypeError("Progressbar.start() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " start"
            if args.Length = 1 && !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkProgressbarIntervalWord(args[1])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        step(args*)
        {
            if args.Length > 1
                throw TypeError("Progressbar.step() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " step"
            if args.Length = 1 && !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkFloatValueWord(args[1])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        stop(args*)
        {
            if args.Length != 0
                throw TypeError("Progressbar.stop() takes 1 positional argument but " args.Length + 1 " were given", -1)
            this.AhkStdlibRoot.eval(this._w " stop")
            return stdlib.None
        }

        cget(args*)
        {
            if args.Length = 0
                throw TypeError("Misc.cget() missing 1 required positional argument: 'key'", -1)
            if args.Length > 1
                throw TypeError("Misc.cget() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            optionWord := AhkStdlibTkinterTclWord(AhkStdlibTkinterWidgetDashOption(args[1]))
            optionName := AhkStdlibTkinterWidgetOptionName(args[1])
            value := this.AhkStdlibRoot.eval(this._w " cget " optionWord)
            if optionName = "maximum"
                return AhkStdlibTkinterIntOrFloatValue(value)
            if optionName = "value"
                return Float(value)
            return AhkStdlibTkinterCgetValue(optionName, value, this.AhkStdlibRoot)
        }

        configure(args*)
        {
            if args.Length = 1 && args[1] is String {
                optionName := AhkStdlibTkinterWidgetOptionName(args[1])
                value := AhkStdlibTkinterWidgetConfigureOption(this.AhkStdlibRoot, this._w, args[1])
                if optionName = "maximum"
                    return stdlib.tuple([value[1], value[2], value[3], AhkStdlibTkinterIntOrFloatValue(value[4]), AhkStdlibTkinterIntOrFloatValue(value[5])])
                if optionName = "value"
                    return stdlib.tuple([value[1], value[2], value[3], Float(value[4]), Float(value[5])])
                return value
            }
            return super.configure(args*)
        }

        config(args*)
        {
            return this.configure(args*)
        }
    }

    class AhkStdlibTkinterNotebook extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Notebook", "ttk::notebook", args*)
            this.widgetName := "ttk::notebook"
        }

        cget(args*)
        {
            if args.Length = 0
                throw TypeError("Misc.cget() missing 1 required positional argument: 'key'", -1)
            if args.Length > 1
                throw TypeError("Misc.cget() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            optionWord := AhkStdlibTkinterTclWord(AhkStdlibTkinterWidgetDashOption(args[1]))
            optionName := AhkStdlibTkinterWidgetOptionName(args[1])
            value := this.AhkStdlibRoot.eval(this._w " cget " optionWord)
            if optionName = "padding"
                return value = "" ? "" : stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, value))
            return AhkStdlibTkinterCgetValue(optionName, value, this.AhkStdlibRoot)
        }

        configure(args*)
        {
            if args.Length = 1 && args[1] is String {
                optionName := AhkStdlibTkinterWidgetOptionName(args[1])
                if optionName = "padding"
                    return AhkStdlibTkinterNotebookConfigureOption(this.AhkStdlibRoot, this._w, args[1])
                return AhkStdlibTkinterWidgetConfigureOption(this.AhkStdlibRoot, this._w, args[1])
            }
            return super.configure(args*)
        }

        config(args*)
        {
            return this.configure(args*)
        }

        add(args*)
        {
            if args.Length = 0
                throw TypeError("Notebook.add() missing 1 required positional argument: 'child'", -1)
            if args.Length > 2
                throw TypeError("Notebook.add() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            options := args.Length = 2 ? args[2] : {}
            if !AhkStdlibTkinterIsPlainKeywordObject(options)
                throw TypeError("object of type '" AhkStdlibPyTypeName(options) "' has no len()", -1)
            script := this._w " add"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkNotebookTabWord(args[1]) AhkStdlibTkinterOptionsToScript(options, false, this.AhkStdlibRoot)
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        forget(args*)
        {
            if args.Length = 0
                throw TypeError("Notebook.forget() missing 1 required positional argument: 'tab_id'", -1)
            if args.Length > 1
                throw TypeError("Notebook.forget() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " forget"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkNotebookTabWord(args[1])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        hide(args*)
        {
            if args.Length = 0
                throw TypeError("Notebook.hide() missing 1 required positional argument: 'tab_id'", -1)
            if args.Length > 1
                throw TypeError("Notebook.hide() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " hide"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkNotebookTabWord(args[1])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        identify(args*)
        {
            if args.Length = 0
                throw TypeError("Notebook.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
            if args.Length = 1
                throw TypeError("Notebook.identify() missing 1 required positional argument: 'y'", -1)
            if args.Length > 2
                throw TypeError("Notebook.identify() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " identify"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkFloatValueWord(value)
            }
            return this.AhkStdlibRoot.eval(script)
        }

        index(args*)
        {
            if args.Length = 0
                throw TypeError("Notebook.index() missing 1 required positional argument: 'tab_id'", -1)
            if args.Length > 1
                throw TypeError("Notebook.index() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " index"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkNotebookTabWord(args[1])
            return Integer(this.AhkStdlibRoot.eval(script))
        }

        insert(args*)
        {
            if args.Length = 0
                throw TypeError("Notebook.insert() missing 2 required positional arguments: 'pos' and 'child'", -1)
            if args.Length = 1
                throw TypeError("Notebook.insert() missing 1 required positional argument: 'child'", -1)
            if args.Length > 3
                throw TypeError("Notebook.insert() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            options := args.Length = 3 ? args[3] : {}
            if !AhkStdlibTkinterIsPlainKeywordObject(options)
                throw TypeError("object of type '" AhkStdlibPyTypeName(options) "' has no len()", -1)
            script := this._w " insert"
            if !AhkStdlibIsNone(args[1]) {
                script .= " " AhkStdlibTkinterTtkNotebookIndexWord(args[1])
                if !AhkStdlibIsNone(args[2])
                    script .= " " AhkStdlibTkinterTtkNotebookTabWord(args[2]) AhkStdlibTkinterOptionsToScript(options, false, this.AhkStdlibRoot)
            }
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        select(args*)
        {
            if args.Length > 1
                throw TypeError("Notebook.select() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " select"
            if args.Length = 1 && !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkNotebookTabWord(args[1])
            return this.AhkStdlibRoot.eval(script)
        }

        tab(args*)
        {
            if args.Length = 0
                throw TypeError("Notebook.tab() missing 1 required positional argument: 'tab_id'", -1)
            if args.Length > 2
                throw TypeError("Notebook.tab() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " tab"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkNotebookTabWord(args[1])
            if AhkStdlibIsNone(args[1])
                return this.AhkStdlibRoot.eval(script)
            if args.Length = 1 || AhkStdlibIsNone(args[2])
                return AhkStdlibTkinterNotebookTabDict(this.AhkStdlibRoot, script)
            if AhkStdlibTkinterIsPlainKeywordObject(args[2]) {
                queryInfo := AhkStdlibTkinterSingleNoneKeywordQueryOption(args[2])
                value := this.AhkStdlibRoot.eval(script AhkStdlibTkinterOptionsToScript(args[2], false, this.AhkStdlibRoot))
                if queryInfo["found"]
                    return AhkStdlibTkinterNotebookTabValue(this.AhkStdlibRoot, queryInfo["option"], value, false)
                return Map()
            }
            option := AhkStdlibTkinterTtkSubcommandQueryOption(args[2])
            value := this.AhkStdlibRoot.eval(script " " option["word"])
            return AhkStdlibTkinterNotebookTabValue(this.AhkStdlibRoot, option["name"], value, false)
        }

        tabs(args*)
        {
            if args.Length != 0
                throw TypeError("Notebook.tabs() takes 1 positional argument but " args.Length + 1 " were given", -1)
            return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(this._w " tabs")))
        }

        enable_traversal(args*)
        {
            if args.Length != 0
                throw TypeError("Notebook.enable_traversal() takes 1 positional argument but " args.Length + 1 " were given", -1)
            this.AhkStdlibRoot.eval("ttk::notebook::enableTraversal " AhkStdlibTkinterTclWord(this._w))
            return stdlib.None
        }
    }

    class AhkStdlibTkinterTreeview extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Treeview", "ttk::treeview", args*)
            this.widgetName := "ttk::treeview"
        }

        __Item[name]
        {
            get {
                return this.cget(name)
            }
        }

        cget(args*)
        {
            if args.Length = 0
                throw TypeError("Misc.cget() missing 1 required positional argument: 'key'", -1)
            if args.Length > 1
                throw TypeError("Misc.cget() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            optionWord := AhkStdlibTkinterTclWord(AhkStdlibTkinterWidgetDashOption(args[1]))
            optionName := AhkStdlibTkinterWidgetOptionName(args[1])
            value := this.AhkStdlibRoot.eval(this._w " cget " optionWord)
            return AhkStdlibTkinterTtkTreeviewWidgetValue(this.AhkStdlibRoot, optionName, value)
        }

        configure(args*)
        {
            if args.Length = 1 && args[1] is String
                return AhkStdlibTkinterTtkTreeviewConfigureOption(this.AhkStdlibRoot, this._w, args[1])
            return super.configure(args*)
        }

        config(args*)
        {
            return this.configure(args*)
        }

        bbox(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.bbox() missing 1 required positional argument: 'item'", -1)
            if args.Length > 2
                throw TypeError("Treeview.bbox() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " bbox"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            if args.Length = 2 && !AhkStdlibIsNone(args[2])
                script .= " " AhkStdlibTkinterTtkTreeviewColumnWord(args[2])
            value := this.AhkStdlibRoot.eval(script)
            return value = "" ? "" : AhkStdlibTkinterIntegerTuple(value)
        }

        column(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.column() missing 1 required positional argument: 'column'", -1)
            if args.Length > 2
                throw TypeError("Treeview.column() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " column"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewColumnWord(args[1])
            if AhkStdlibIsNone(args[1])
                return this.AhkStdlibRoot.eval(script)
            if args.Length = 1 || AhkStdlibIsNone(args[2])
                return AhkStdlibTkinterTtkTreeviewColumnDict(this.AhkStdlibRoot, this._w, args[1])
            if AhkStdlibTkinterIsPlainKeywordObject(args[2]) {
                queryInfo := AhkStdlibTkinterSingleNoneKeywordQueryOption(args[2])
                value := this.AhkStdlibRoot.eval(script AhkStdlibTkinterOptionsToScript(args[2], false, this.AhkStdlibRoot))
                if queryInfo["found"]
                    return AhkStdlibTkinterTtkTreeviewColumnValue(this.AhkStdlibRoot, queryInfo["option"], value)
                return Map()
            }
            option := AhkStdlibTkinterTtkSubcommandQueryOption(args[2])
            value := this.AhkStdlibRoot.eval(script " " option["word"])
            return AhkStdlibTkinterTtkTreeviewColumnValue(this.AhkStdlibRoot, option["name"], value)
        }

        delete(args*)
        {
            if args.Length = 0
                return stdlib.None
            this.AhkStdlibRoot.eval(this._w " delete " AhkStdlibTkinterTtkTreeviewItemsOperand(args))
            return stdlib.None
        }

        detach(args*)
        {
            if args.Length = 0
                return stdlib.None
            this.AhkStdlibRoot.eval(this._w " detach " AhkStdlibTkinterTtkTreeviewItemsOperand(args))
            return stdlib.None
        }

        exists(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.exists() missing 1 required positional argument: 'item'", -1)
            if args.Length > 1
                throw TypeError("Treeview.exists() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " exists"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            return this.AhkStdlibRoot.eval(script) = "1" ? stdlib.True : stdlib.False
        }

        focus(args*)
        {
            if args.Length > 1
                throw TypeError("Treeview.focus() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " focus"
            if args.Length = 1 && !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            return this.AhkStdlibRoot.eval(script)
        }

        get_children(args*)
        {
            if args.Length > 1
                throw TypeError("Treeview.get_children() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " children "
            script .= args.Length = 1 && !AhkStdlibIsNone(args[1]) ? AhkStdlibTkinterTtkTreeviewItemWord(args[1]) : AhkStdlibTkinterTclWord("")
            return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(script)))
        }

        set_children(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.set_children() missing 1 required positional argument: 'item'", -1)
            newchildren := []
            index := 2
            while index <= args.Length {
                newchildren.Push(args[index])
                index += 1
            }
            script := this._w " children"
            if AhkStdlibIsNone(args[1]) {
                this.AhkStdlibRoot.eval(script)
                return stdlib.None
            }
            script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            script .= " " AhkStdlibTkinterTtkTreeviewChildrenOperand(newchildren)
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        heading(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.heading() missing 1 required positional argument: 'column'", -1)
            if args.Length > 2
                throw TypeError("Treeview.heading() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " heading"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewColumnWord(args[1])
            if AhkStdlibIsNone(args[1])
                return this.AhkStdlibRoot.eval(script)
            if args.Length = 1 || AhkStdlibIsNone(args[2])
                return AhkStdlibTkinterTtkTreeviewHeadingDict(this.AhkStdlibRoot, this._w, args[1])
            if AhkStdlibTkinterIsPlainKeywordObject(args[2]) {
                queryInfo := AhkStdlibTkinterSingleNoneKeywordQueryOption(args[2])
                value := this.AhkStdlibRoot.eval(script AhkStdlibTkinterOptionsToScript(args[2], false, this.AhkStdlibRoot))
                if queryInfo["found"]
                    return AhkStdlibTkinterTtkTreeviewHeadingValue(this.AhkStdlibRoot, queryInfo["option"], value)
                return Map()
            }
            option := AhkStdlibTkinterTtkSubcommandQueryOption(args[2])
            value := this.AhkStdlibRoot.eval(script " " option["word"])
            return AhkStdlibTkinterTtkTreeviewHeadingValue(this.AhkStdlibRoot, option["name"], value)
        }

        identify(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.identify() missing 3 required positional arguments: 'component', 'x', and 'y'", -1)
            if args.Length = 1
                throw TypeError("Treeview.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
            if args.Length = 2
                throw TypeError("Treeview.identify() missing 1 required positional argument: 'y'", -1)
            if args.Length > 3
                throw TypeError("Treeview.identify() takes 4 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " identify"
            for index, value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " (index = 1 ? AhkStdlibTkinterTtkTreeviewIdentifyComponentWord(value) : AhkStdlibTkinterTtkFloatValueWord(value))
            }
            return this.AhkStdlibRoot.eval(script)
        }

        identify_column(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.identify_column() missing 1 required positional argument: 'x'", -1)
            if args.Length > 1
                throw TypeError("Treeview.identify_column() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            return this.identify("column", args[1], 0)
        }

        identify_element(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.identify_element() missing 2 required positional arguments: 'x' and 'y'", -1)
            if args.Length = 1
                throw TypeError("Treeview.identify_element() missing 1 required positional argument: 'y'", -1)
            if args.Length > 2
                throw TypeError("Treeview.identify_element() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            return this.identify("element", args[1], args[2])
        }

        identify_region(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.identify_region() missing 2 required positional arguments: 'x' and 'y'", -1)
            if args.Length = 1
                throw TypeError("Treeview.identify_region() missing 1 required positional argument: 'y'", -1)
            if args.Length > 2
                throw TypeError("Treeview.identify_region() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            return this.identify("region", args[1], args[2])
        }

        identify_row(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.identify_row() missing 1 required positional argument: 'y'", -1)
            if args.Length > 1
                throw TypeError("Treeview.identify_row() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            return this.identify("row", 0, args[1])
        }

        index(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.index() missing 1 required positional argument: 'item'", -1)
            if args.Length > 1
                throw TypeError("Treeview.index() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " index"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            return Integer(this.AhkStdlibRoot.eval(script))
        }

        insert(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.insert() missing 2 required positional arguments: 'parent' and 'index'", -1)
            if args.Length = 1
                throw TypeError("Treeview.insert() missing 1 required positional argument: 'index'", -1)
            if args.Length > 4
                throw TypeError("Treeview.insert() takes from 3 to 4 positional arguments but " args.Length + 1 " were given", -1)

            script := this._w " insert"
            if AhkStdlibIsNone(args[1])
                return this.AhkStdlibRoot.eval(script)
            script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            script .= " " AhkStdlibTkinterTclWord(args[2])
            options := {}
            if args.Length >= 3 {
                if AhkStdlibTkinterIsPlainKeywordObject(args[3])
                    options := args[3]
                else if !AhkStdlibIsNone(args[3])
                    script .= " -id " AhkStdlibTkinterTtkTreeviewItemWord(args[3])
            }
            if args.Length = 4 {
                if !AhkStdlibTkinterIsPlainKeywordObject(args[4])
                    throw TypeError("object of type '" AhkStdlibPyTypeName(args[4]) "' has no len()", -1)
                options := args[4]
            }
            return this.AhkStdlibRoot.eval(script AhkStdlibTkinterOptionsToScript(options, false, this.AhkStdlibRoot))
        }

        item(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.item() missing 1 required positional argument: 'item'", -1)
            if args.Length > 2
                throw TypeError("Treeview.item() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " item"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            if AhkStdlibIsNone(args[1])
                return this.AhkStdlibRoot.eval(script)
            if args.Length = 1 || AhkStdlibIsNone(args[2])
                return AhkStdlibTkinterTtkTreeviewItemDict(this.AhkStdlibRoot, this._w, args[1])
            if AhkStdlibTkinterIsPlainKeywordObject(args[2]) {
                queryInfo := AhkStdlibTkinterSingleNoneKeywordQueryOption(args[2])
                value := this.AhkStdlibRoot.eval(script AhkStdlibTkinterOptionsToScript(args[2], false, this.AhkStdlibRoot))
                if queryInfo["found"]
                    return AhkStdlibTkinterTtkTreeviewItemValue(this.AhkStdlibRoot, queryInfo["option"], value, false)
                return Map()
            }
            option := AhkStdlibTkinterTtkSubcommandQueryOption(args[2])
            value := this.AhkStdlibRoot.eval(script " " option["word"])
            return AhkStdlibTkinterTtkTreeviewItemValue(this.AhkStdlibRoot, option["name"], value, false)
        }

        move(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.move() missing 3 required positional arguments: 'item', 'parent', and 'index'", -1)
            if args.Length = 1
                throw TypeError("Treeview.move() missing 2 required positional arguments: 'parent' and 'index'", -1)
            if args.Length = 2
                throw TypeError("Treeview.move() missing 1 required positional argument: 'index'", -1)
            if args.Length > 3
                throw TypeError("Treeview.move() takes 4 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " move"
            if AhkStdlibIsNone(args[1]) || AhkStdlibIsNone(args[2]) {
                this.AhkStdlibRoot.eval(script)
                return stdlib.None
            }
            script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[2])
            script .= " " AhkStdlibTkinterTclWord(args[3])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        reattach(args*)
        {
            return this.move(args*)
        }

        next(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.next() missing 1 required positional argument: 'item'", -1)
            if args.Length > 1
                throw TypeError("Treeview.next() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " next"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            return this.AhkStdlibRoot.eval(script)
        }

        parent(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.parent() missing 1 required positional argument: 'item'", -1)
            if args.Length > 1
                throw TypeError("Treeview.parent() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " parent"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            return this.AhkStdlibRoot.eval(script)
        }

        prev(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.prev() missing 1 required positional argument: 'item'", -1)
            if args.Length > 1
                throw TypeError("Treeview.prev() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " prev"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            return this.AhkStdlibRoot.eval(script)
        }

        selection(args*)
        {
            if args.Length != 0
                throw TypeError("Treeview.selection() takes 1 positional argument but " args.Length + 1 " were given", -1)
            return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(this._w " selection")))
        }

        selection_add(args*)
        {
            return AhkStdlibTkinterTtkTreeviewSelectionCommand(this, "add", args*)
        }

        selection_remove(args*)
        {
            return AhkStdlibTkinterTtkTreeviewSelectionCommand(this, "remove", args*)
        }

        selection_set(args*)
        {
            return AhkStdlibTkinterTtkTreeviewSelectionCommand(this, "set", args*)
        }

        selection_toggle(args*)
        {
            return AhkStdlibTkinterTtkTreeviewSelectionCommand(this, "toggle", args*)
        }

        see(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.see() missing 1 required positional argument: 'item'", -1)
            if args.Length > 1
                throw TypeError("Treeview.see() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " see"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        set(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.set() missing 1 required positional argument: 'item'", -1)
            if args.Length > 3
                throw TypeError("Treeview.set() takes from 2 to 4 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " set"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            if AhkStdlibIsNone(args[1])
                return this.AhkStdlibRoot.eval(script)
            if args.Length = 1 || (args.Length = 2 && AhkStdlibIsNone(args[2]))
                return AhkStdlibTkinterTtkTreeviewSetDict(this.AhkStdlibRoot, this._w, args[1])
            if AhkStdlibIsNone(args[2])
                return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(script)))
            script .= " " AhkStdlibTkinterTtkTreeviewColumnWord(args[2])
            if args.Length = 2 || AhkStdlibIsNone(args[3])
                return this.AhkStdlibRoot.eval(script)
            return this.AhkStdlibRoot.eval(script " " AhkStdlibTkinterTtkTreeviewSetValueWord(args[3]))
        }

        tag_has(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.tag_has() missing 1 required positional argument: 'tagname'", -1)
            if args.Length > 2
                throw TypeError("Treeview.tag_has() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " tag has"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewItemWord(args[1])
            if args.Length = 1 || AhkStdlibIsNone(args[2])
                return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(script)))
            return this.AhkStdlibRoot.eval(script " " AhkStdlibTkinterTtkTreeviewItemWord(args[2])) = "1" ? stdlib.True : stdlib.False
        }

        tag_configure(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.tag_configure() missing 1 required positional argument: 'tagname'", -1)
            if args.Length > 2
                throw TypeError("Treeview.tag_configure() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

            script := this._w " tag configure"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewTagWord(args[1])
            if AhkStdlibIsNone(args[1])
                return this.AhkStdlibRoot.eval(script)
            if args.Length = 1 || AhkStdlibIsNone(args[2])
                return AhkStdlibTkinterTtkTreeviewTagConfigureDict(this.AhkStdlibRoot, this._w, args[1])
            if AhkStdlibTkinterIsPlainKeywordObject(args[2]) {
                queryInfo := AhkStdlibTkinterSingleNoneKeywordQueryOption(args[2])
                value := this.AhkStdlibRoot.eval(script AhkStdlibTkinterOptionsToScript(args[2], false, this.AhkStdlibRoot))
                if queryInfo["found"]
                    return AhkStdlibTkinterCgetValue(queryInfo["option"], value, this.AhkStdlibRoot)
                return Map()
            }
            option := AhkStdlibTkinterTtkSubcommandQueryOption(args[2])
            return this.AhkStdlibRoot.eval(script " " option["word"])
        }

        tag_bind(args*)
        {
            if args.Length = 0
                throw TypeError("Treeview.tag_bind() missing 1 required positional argument: 'tagname'", -1)
            if args.Length > 3
                throw TypeError("Treeview.tag_bind() takes from 2 to 4 positional arguments but " args.Length + 1 " were given", -1)

            script := this._w " tag bind"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkTreeviewTagWord(args[1])
            if AhkStdlibIsNone(args[1]) {
                this.AhkStdlibRoot.eval(script)
                return stdlib.None
            }
            if args.Length = 1 || AhkStdlibIsNone(args[2]) {
                this.AhkStdlibRoot.eval(script)
                return stdlib.None
            }

            sequence := args[2]
            if args.Length = 2 || AhkStdlibIsNone(args[3]) {
                this.AhkStdlibRoot.eval(script " " AhkStdlibTkinterTtkTreeviewTagBindSequenceWord(sequence))
                return stdlib.None
            }

            func := args[3]
            if func is String {
                this.AhkStdlibRoot.eval(script " " AhkStdlibTkinterTtkTreeviewTagBindSequenceWord(sequence) " " AhkStdlibTkinterTclScriptWord(func))
                return stdlib.None
            }

            commandName := AhkStdlibTkinterRegisterEventCommand(this.AhkStdlibRoot, this, func, sequence)
            bindingScript := "if {`"[" commandName " %W %T %x %y %b]`" == `"break`"} break"
            this.AhkStdlibRoot.eval(script " " AhkStdlibTkinterTtkTreeviewTagBindSequenceWord(sequence) " " AhkStdlibTkinterTclScriptWord(bindingScript))
            return stdlib.None
        }

        xview(args*)
        {
            script := this._w " xview"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkFloatValueWord(value)
            }
            value := this.AhkStdlibRoot.eval(script)
            return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
        }

        xview_moveto(args*)
        {
            if args.Length = 0
                throw TypeError("XView.xview_moveto() missing 1 required positional argument: 'fraction'", -1)
            if args.Length > 1
                throw TypeError("XView.xview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " xview moveto"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkFloatValueWord(args[1])
            this.AhkStdlibRoot.eval(script)
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
            script := this._w " xview scroll"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkFloatValueWord(value)
            }
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        yview(args*)
        {
            script := this._w " yview"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkFloatValueWord(value)
            }
            value := this.AhkStdlibRoot.eval(script)
            return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
        }

        yview_moveto(args*)
        {
            if args.Length = 0
                throw TypeError("YView.yview_moveto() missing 1 required positional argument: 'fraction'", -1)
            if args.Length > 1
                throw TypeError("YView.yview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " yview moveto"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkFloatValueWord(args[1])
            this.AhkStdlibRoot.eval(script)
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
            script := this._w " yview scroll"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkFloatValueWord(value)
            }
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }
    }

    class AhkStdlibTkinterStyle
    {
        __New(args*)
        {
            if args.Length > 1
                throw TypeError("Style.__init__() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
            master := args.Length = 0 || AhkStdlibIsNone(args[1]) ? AhkStdlibTkinterGetOrCreateDefaultRoot() : args[1]
            if !IsObject(master) || !HasProp(master, "tk")
                throw AttributeError("'" AhkStdlibPyTypeName(master) "' object has no attribute 'tk'", -1)
            this.master := master
            this.tk := master.tk
            this.AhkStdlibRoot := master._root()
        }

        configure(args*)
        {
            if args.Length = 0
                throw TypeError("Style.configure() missing 1 required positional argument: 'style'", -1)
            if args.Length > 2
                throw TypeError("Style.configure() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
            styleName := AhkStdlibTkinterTtkStyleNameWord(args[1])
            if args.Length = 1
                return AhkStdlibTkinterTtkStyleConfigureDict(this.AhkStdlibRoot, styleName)
            if AhkStdlibIsNone(args[2]) {
                config := AhkStdlibTkinterTtkStyleConfigureDict(this.AhkStdlibRoot, styleName)
                return config.Count = 0 ? stdlib.None : config
            }
            if AhkStdlibTkinterTtkStyleConfigureFalsyQueryOption(args[2])
                return stdlib.None
            if AhkStdlibTkinterIsPlainKeywordObject(args[2]) {
                queryInfo := AhkStdlibTkinterSingleNoneKeywordQueryOption(args[2])
                value := this.AhkStdlibRoot.eval("ttk::style configure" styleName AhkStdlibTkinterOptionsToScript(args[2], false, this.AhkStdlibRoot))
                if queryInfo["found"] {
                    if value = ""
                        return stdlib.None
                    return AhkStdlibTkinterTtkStyleValue(this.AhkStdlibRoot, queryInfo["option"], value)
                }
                return stdlib.None
            }
            optionName := AhkStdlibTkinterTtkStyleConfigureQueryOption(args[2])
            return AhkStdlibTkinterTtkStyleValue(this.AhkStdlibRoot, optionName, this.AhkStdlibRoot.eval("ttk::style configure" styleName " -" optionName))
        }

        element_names(args*)
        {
            if args.Length != 0
                throw TypeError("Style.element_names() takes 1 positional argument but " args.Length + 1 " were given", -1)
            return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval("ttk::style element names")))
        }

        element_options(args*)
        {
            if args.Length = 0
                throw TypeError("Style.element_options() missing 1 required positional argument: 'elementname'", -1)
            if args.Length > 1
                throw TypeError("Style.element_options() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval("ttk::style element options" AhkStdlibTkinterTtkStyleElementOptionsNameWord(args[1]))))
        }

        element_create(args*)
        {
            if args.Length = 0
                throw TypeError("Style.element_create() missing 2 required positional arguments: 'elementname' and 'etype'", -1)
            if args.Length = 1
                throw TypeError("Style.element_create() missing 1 required positional argument: 'etype'", -1)
            positional := []
            options := {}
            index := 3
            while index <= args.Length {
                if index = args.Length && !AhkStdlibIsNone(args[index]) && AhkStdlibTkinterIsPlainKeywordObject(args[index]) {
                    options := args[index]
                    break
                }
                positional.Push(args[index])
                index += 1
            }
            script := "ttk::style element create"
            if !AhkStdlibTkinterTtkElementCreateAppendCallWord(&script, args[1]) {
                this.AhkStdlibRoot.eval(script)
                return stdlib.None
            }
            if !AhkStdlibTkinterTtkElementCreateAppendCallWord(&script, args[2]) {
                this.AhkStdlibRoot.eval(script)
                return stdlib.None
            }
            spec := AhkStdlibTkinterTtkElementCreateSpec(args[2], positional)
            if spec != ""
                script .= " " spec
            script .= AhkStdlibTkinterTtkElementCreateOptions(options)
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        layout(args*)
        {
            if args.Length = 0
                throw TypeError("Style.layout() missing 1 required positional argument: 'style'", -1)
            if args.Length > 2
                throw TypeError("Style.layout() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
            styleName := AhkStdlibTkinterTtkStyleNameWord(args[1])
            if args.Length = 1 || AhkStdlibIsNone(args[2])
                return AhkStdlibTkinterTtkStyleLayoutList(this.AhkStdlibRoot, this.AhkStdlibRoot.eval("ttk::style layout" styleName))
            if IsObject(args[2]) && HasMethod(args[2], "__Enum") {
                this.AhkStdlibRoot.eval("ttk::style layout" styleName " " AhkStdlibTkinterTtkStyleLayoutSpec(args[2]))
                return []
            }
            if args[2] is String && args[2] != "" {
                this.AhkStdlibRoot.eval("ttk::style layout" styleName " " AhkStdlibTkinterTtkStyleLayoutSpec(args[2], 0, true))
                return []
            }
            if AhkStdlibTruthValue(args[2])
                throw TypeError("'" AhkStdlibPyTypeName(args[2]) "' object is not iterable", -1)
            this.AhkStdlibRoot.eval("ttk::style layout" styleName " null")
            return []
        }

        lookup(args*)
        {
            if args.Length = 0
                throw TypeError("Style.lookup() missing 2 required positional arguments: 'style' and 'option'", -1)
            if args.Length = 1
                throw TypeError("Style.lookup() missing 1 required positional argument: 'option'", -1)
            if args.Length > 4
                throw TypeError("Style.lookup() takes from 3 to 5 positional arguments but " args.Length + 1 " were given", -1)
            if AhkStdlibIsNone(args[1]) {
                this.AhkStdlibRoot.eval("ttk::style lookup")
                return ""
            }
            styleName := AhkStdlibTkinterTtkStyleNameWord(args[1])
            optionName := AhkStdlibTkinterTtkStyleLookupOption(args[2])
            state := args.Length >= 3 && AhkStdlibTruthValue(args[3]) ? AhkStdlibTkinterTtkStyleStateSpec(args[3]) : ""
            defaultValue := args.Length >= 4 && !AhkStdlibIsNone(args[4]) ? args[4] : ""
            raw := this.AhkStdlibRoot.eval("ttk::style lookup" styleName " " AhkStdlibTkinterTclWord("-" optionName) " " AhkStdlibTkinterTclWord(state) " " AhkStdlibTkinterTtkStyleLookupDefaultWord(defaultValue))
            return args.Length >= 4 && AhkStdlibTkinterTtkStyleLookupDefaultIsSequence(args[4]) ? stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, raw)) : raw
        }

        map(args*)
        {
            if args.Length = 0
                throw TypeError("Style.map() missing 1 required positional argument: 'style'", -1)
            if args.Length > 2
                throw TypeError("Style.map() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
            styleName := AhkStdlibTkinterTtkStyleNameWord(args[1])
            if args.Length = 1 || AhkStdlibIsNone(args[2])
                return AhkStdlibTkinterTtkStyleMapDict(this.AhkStdlibRoot, this.AhkStdlibRoot.eval("ttk::style map" styleName))
            if AhkStdlibTkinterIsPlainKeywordObject(args[2]) || args[2] is Map {
                AhkStdlibTkinterTtkStyleMapValidateOptions(args[2])
                this.AhkStdlibRoot.eval("ttk::style map" styleName AhkStdlibTkinterTtkStyleMapOptions(args[2]))
                return Map()
            }
            optionName := AhkStdlibTkinterTtkStyleMapQueryOption(args[2])
            if optionName = ""
                return []
            return AhkStdlibTkinterTtkStyleStateMap(this.AhkStdlibRoot, this.AhkStdlibRoot.eval("ttk::style map" styleName " -" optionName))
        }

        theme_names(args*)
        {
            if args.Length != 0
                throw TypeError("Style.theme_names() takes 1 positional argument but " args.Length + 1 " were given", -1)
            return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval("ttk::style theme names")))
        }

        theme_settings(args*)
        {
            if args.Length = 0
                throw TypeError("Style.theme_settings() missing 2 required positional arguments: 'themename' and 'settings'", -1)
            if args.Length = 1
                throw TypeError("Style.theme_settings() missing 1 required positional argument: 'settings'", -1)
            if args.Length > 2
                throw TypeError("Style.theme_settings() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            this.AhkStdlibRoot.eval("ttk::style theme settings " AhkStdlibTkinterTtkStyleThemeWord(args[1]) " " AhkStdlibTkinterTclScriptWord(AhkStdlibTkinterTtkStyleSettingsScript(args[2])))
            return stdlib.None
        }

        theme_create(args*)
        {
            if args.Length = 0
                throw TypeError("Style.theme_create() missing 1 required positional argument: 'themename'", -1)
            if args.Length > 3
                throw TypeError("Style.theme_create() takes from 2 to 4 positional arguments but " args.Length + 1 " were given", -1)
            script := "ttk::style theme create " AhkStdlibTkinterTtkStyleThemeWord(args[1])
            if args.Length >= 2 && AhkStdlibTruthValue(args[2])
                script .= " -parent " AhkStdlibTkinterTtkStyleThemeWord(args[2])
            settingsScript := ""
            if args.Length >= 3 && AhkStdlibTruthValue(args[3])
                settingsScript := AhkStdlibTkinterTtkStyleSettingsScript(args[3])
            script .= " -settings " AhkStdlibTkinterTclScriptWord(settingsScript)
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        theme_use(args*)
        {
            if args.Length > 1
                throw TypeError("Style.theme_use() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
            if args.Length = 0 || AhkStdlibIsNone(args[1])
                return this.AhkStdlibRoot.eval("return $ttk::currentTheme")
            this.AhkStdlibRoot.eval("ttk::setTheme " AhkStdlibTkinterTtkStyleThemeWord(args[1]))
            return stdlib.None
        }
    }

    class AhkStdlibTkinterPanedwindow extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Panedwindow", "ttk::panedwindow", args*)
            this.widgetName := "ttk::panedwindow"
        }

        add(args*)
        {
            if args.Length = 0
                throw TypeError("PanedWindow.add() missing 1 required positional argument: 'child'", -1)
            if args.Length > 2
                throw TypeError("PanedWindow.add() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            options := args.Length = 2 ? args[2] : {}
            if !AhkStdlibTkinterIsPlainKeywordObject(options)
                throw TypeError("object of type '" AhkStdlibPyTypeName(options) "' has no len()", -1)
            childPath := AhkStdlibTkinterPaneChildPath(args[1])
            this.AhkStdlibRoot.eval(this._w " add " AhkStdlibTkinterTclWord(childPath) AhkStdlibTkinterOptionsToScript(options, false, this.AhkStdlibRoot))
            return stdlib.None
        }

        forget(args*)
        {
            if args.Length = 0
                throw TypeError("PanedWindow.remove() missing 1 required positional argument: 'child'", -1)
            if args.Length > 1
                throw TypeError("PanedWindow.remove() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " forget"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkPanedwindowPaneWord(args[1])
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        remove(args*)
        {
            return this.forget(args*)
        }

        identify(args*)
        {
            if args.Length = 0
                throw TypeError("Widget.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
            if args.Length = 1
                throw TypeError("Widget.identify() missing 1 required positional argument: 'y'", -1)
            if args.Length > 2
                throw TypeError("Widget.identify() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " identify"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkFloatValueWord(value)
            }
            return this.AhkStdlibRoot.eval(script)
        }

        insert(args*)
        {
            if args.Length = 0
                throw TypeError("Panedwindow.insert() missing 2 required positional arguments: 'pos' and 'child'", -1)
            if args.Length = 1
                throw TypeError("Panedwindow.insert() missing 1 required positional argument: 'child'", -1)
            if args.Length > 3
                throw TypeError("Panedwindow.insert() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            options := args.Length = 3 ? args[3] : {}
            if !AhkStdlibTkinterIsPlainKeywordObject(options)
                throw TypeError("object of type '" AhkStdlibPyTypeName(options) "' has no len()", -1)
            script := this._w " insert"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkPanedwindowPaneWord(args[1])
            if !AhkStdlibIsNone(args[2])
                script .= " " AhkStdlibTkinterTtkPanedwindowPaneWord(args[2])
            this.AhkStdlibRoot.eval(script AhkStdlibTkinterOptionsToScript(options, false, this.AhkStdlibRoot))
            return stdlib.None
        }

        pane(args*)
        {
            if args.Length = 0
                throw TypeError("Panedwindow.pane() missing 1 required positional argument: 'pane'", -1)
            if args.Length > 2
                throw TypeError("Panedwindow.pane() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " pane"
            if !AhkStdlibIsNone(args[1])
                script .= " " AhkStdlibTkinterTtkPanedwindowPaneWord(args[1])
            if AhkStdlibIsNone(args[1])
                return this.AhkStdlibRoot.eval(script)
            if args.Length = 1 || AhkStdlibIsNone(args[2])
                return AhkStdlibTkinterTtkPanedwindowPaneDict(this.AhkStdlibRoot, script)
            if AhkStdlibTkinterIsPlainKeywordObject(args[2]) {
                queryInfo := AhkStdlibTkinterSingleNoneKeywordQueryOption(args[2])
                value := this.AhkStdlibRoot.eval(script AhkStdlibTkinterOptionsToScript(args[2], false, this.AhkStdlibRoot))
                if queryInfo["found"]
                    return AhkStdlibTkinterTtkPanedwindowPaneValue(this.AhkStdlibRoot, queryInfo["option"], value)
                return Map()
            }
            option := AhkStdlibTkinterTtkSubcommandQueryOption(args[2])
            value := this.AhkStdlibRoot.eval(script " " option["word"])
            return AhkStdlibTkinterTtkPanedwindowPaneValue(this.AhkStdlibRoot, option["name"], value)
        }

        panes(args*)
        {
            if args.Length != 0
                throw TypeError("PanedWindow.panes() takes 1 positional argument but " args.Length + 1 " were given", -1)
            return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(this._w " panes")))
        }

        panecget(args*)
        {
            if args.Length = 0
                throw TypeError("PanedWindow.panecget() missing 2 required positional arguments: 'child' and 'option'", -1)
            if args.Length = 1
                throw TypeError("PanedWindow.panecget() missing 1 required positional argument: 'option'", -1)
            if args.Length > 2
                throw TypeError("PanedWindow.panecget() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            option := AhkStdlibTkinterPanedWindowDashOption(args[2])
            value := this.AhkStdlibRoot.eval(this._w " panecget " AhkStdlibTkinterPanedWindowChildWord(args[1]) " " option)
            return AhkStdlibTkinterCgetValue(args[2], value)
        }

        paneconfigure(args*)
        {
            if args.Length = 0
                throw TypeError("PanedWindow.paneconfigure() missing 1 required positional argument: 'tagOrId'", -1)
            if args.Length > 2
                throw TypeError("PanedWindow.paneconfigure() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

            childWord := AhkStdlibTkinterPanedWindowChildWord(args[1])
            if args.Length = 1 || AhkStdlibIsNone(args[2])
                return AhkStdlibTkinterPaneConfigureDict(this.AhkStdlibRoot, this._w, childWord, true)
            if args[2] is String
                return AhkStdlibTkinterPaneConfigureOption(this.AhkStdlibRoot, this._w, childWord, args[2], true)
            if AhkStdlibTkinterIsPlainKeywordObject(args[2]) {
                this.AhkStdlibRoot.eval(this._w " paneconfigure " childWord AhkStdlibTkinterOptionsToScript(args[2], false, this.AhkStdlibRoot))
                return stdlib.None
            }
            if (args[2] is Array || args[2] is AhkStdlibTuple) && args[2].Length = 0 {
                this.AhkStdlibRoot.eval(this._w " paneconfigure " childWord)
                return stdlib.None
            }
            if args[2] is Array || args[2] is AhkStdlibTuple
                throw ValueError("dictionary update sequence element #0 has length 1; 2 is required", -1)
            throw AttributeError("'" AhkStdlibPyTypeName(args[2]) "' object has no attribute 'items'", -1)
        }

        paneconfig(args*)
        {
            return this.paneconfigure(args*)
        }

        proxy(args*)
        {
            script := this._w " proxy"
            for value in args {
                if AhkStdlibIsNone(value)
                    continue
                script .= " " AhkStdlibTkinterTtkInheritedCommandWord(value)
            }
            return AhkStdlibTkinterIntegerTupleOrEmpty(this.AhkStdlibRoot, this.AhkStdlibRoot.eval(script))
        }

        proxy_coord(args*)
        {
            if args.Length != 0
                throw TypeError("PanedWindow.proxy_coord() takes 1 positional argument but " args.Length + 1 " were given", -1)
            return this.proxy("coord")
        }

        proxy_forget(args*)
        {
            if args.Length != 0
                throw TypeError("PanedWindow.proxy_forget() takes 1 positional argument but " args.Length + 1 " were given", -1)
            return this.proxy("forget")
        }

        proxy_place(args*)
        {
            if args.Length = 0
                throw TypeError("PanedWindow.proxy_place() missing 2 required positional arguments: 'x' and 'y'", -1)
            if args.Length = 1
                throw TypeError("PanedWindow.proxy_place() missing 1 required positional argument: 'y'", -1)
            if args.Length > 2
                throw TypeError("PanedWindow.proxy_place() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            return this.proxy("place", args[1], args[2])
        }

        sash(args*)
        {
            script := this._w " sash"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkInheritedCommandWord(value)
            }
            return AhkStdlibTkinterIntegerTupleOrEmpty(this.AhkStdlibRoot, this.AhkStdlibRoot.eval(script))
        }

        sash_coord(args*)
        {
            if args.Length = 0
                throw TypeError("PanedWindow.sash_coord() missing 1 required positional argument: 'index'", -1)
            if args.Length > 1
                throw TypeError("PanedWindow.sash_coord() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            return this.sash("coord", args[1])
        }

        sash_mark(args*)
        {
            if args.Length = 0
                throw TypeError("PanedWindow.sash_mark() missing 1 required positional argument: 'index'", -1)
            if args.Length > 1
                throw TypeError("PanedWindow.sash_mark() takes 2 positional arguments but " args.Length + 1 " were given", -1)
            return this.sash("mark", args[1])
        }

        sash_place(args*)
        {
            if args.Length = 0
                throw TypeError("PanedWindow.sash_place() missing 3 required positional arguments: 'index', 'x', and 'y'", -1)
            if args.Length = 1 || args.Length = 2
                throw TypeError("PanedWindow.sash_place() missing 1 required positional argument: 'y'", -1)
            if args.Length > 3
                throw TypeError("PanedWindow.sash_place() takes 4 positional arguments but " args.Length + 1 " were given", -1)
            return this.sash("place", args[1], args[2], args[3])
        }

        sashpos(args*)
        {
            if args.Length = 0
                throw TypeError("Panedwindow.sashpos() missing 1 required positional argument: 'index'", -1)
            if args.Length > 2
                throw TypeError("Panedwindow.sashpos() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " sashpos"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkInheritedCommandWord(value)
            }
            return Integer(this.AhkStdlibRoot.eval(script))
        }
    }

    class AhkStdlibTkinterSizegrip extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("Sizegrip", "ttk::sizegrip", args*)
            this.widgetName := "ttk::sizegrip"
        }

        identify(args*)
        {
            if args.Length = 0
                throw TypeError("Widget.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
            if args.Length = 1
                throw TypeError("Widget.identify() missing 1 required positional argument: 'y'", -1)
            if args.Length > 2
                throw TypeError("Widget.identify() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " identify"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkFloatValueWord(value)
            }
            return this.AhkStdlibRoot.eval(script)
        }
    }

    class AhkStdlibTkinterLabelFrame extends AhkStdlibTkinterWidget
    {
        __New(args*)
        {
            super.__New("LabelFrame", "ttk::labelframe", args*)
            this.widgetName := "ttk::labelframe"
        }

        identify(args*)
        {
            if args.Length = 0
                throw TypeError("Widget.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
            if args.Length = 1
                throw TypeError("Widget.identify() missing 1 required positional argument: 'y'", -1)
            if args.Length > 2
                throw TypeError("Widget.identify() takes 3 positional arguments but " args.Length + 1 " were given", -1)
            script := this._w " identify"
            for value in args {
                if AhkStdlibIsNone(value)
                    break
                script .= " " AhkStdlibTkinterTtkFloatValueWord(value)
            }
            return this.AhkStdlibRoot.eval(script)
        }
    }
}

class AhkStdlibTkinterFrame extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Frame", "frame", args*)
    }
}

class AhkStdlibTkinterLabel extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Label", "label", args*)
    }
}

class AhkStdlibTkinterLabelFrame extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("LabelFrame", "labelframe", args*)
    }
}

class AhkStdlibTkinterToplevel extends AhkStdlibTkinterWidget
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

    wm_geometry(args*)
    {
        return this.geometry(args*)
    }

    attributes(args*)
    {
        return AhkStdlibTkinterWmAttributes(this.AhkStdlibRoot, this._w, args*)
    }

    wm_attributes(args*)
    {
        return this.attributes(args*)
    }

    aspect(args*)
    {
        return AhkStdlibTkinterWmAspect(this.AhkStdlibRoot, this._w, args*)
    }

    wm_aspect(args*)
    {
        return this.aspect(args*)
    }

    grid(args*)
    {
        return AhkStdlibTkinterWmGrid(this.AhkStdlibRoot, this._w, args*)
    }

    wm_grid(args*)
    {
        return this.grid(args*)
    }

    group(args*)
    {
        return AhkStdlibTkinterWmGroup(this.AhkStdlibRoot, this._w, args*)
    }

    wm_group(args*)
    {
        return this.group(args*)
    }

    command(args*)
    {
        return AhkStdlibTkinterWmCommand(this.AhkStdlibRoot, this._w, args*)
    }

    wm_command(args*)
    {
        return this.command(args*)
    }

    manage(args*)
    {
        return AhkStdlibTkinterWmManage(this.AhkStdlibRoot, args*)
    }

    wm_manage(args*)
    {
        return this.manage(args*)
    }

    forget(args*)
    {
        return AhkStdlibTkinterWmForget(this.AhkStdlibRoot, args*)
    }

    wm_forget(args*)
    {
        return this.forget(args*)
    }

    colormapwindows(args*)
    {
        return AhkStdlibTkinterWmColormapwindows(this.AhkStdlibRoot, this._w, args*)
    }

    wm_colormapwindows(args*)
    {
        return this.colormapwindows(args*)
    }

    iconposition(args*)
    {
        return AhkStdlibTkinterWmIconposition(this.AhkStdlibRoot, this._w, args*)
    }

    wm_iconposition(args*)
    {
        return this.iconposition(args*)
    }

    iconwindow(args*)
    {
        return AhkStdlibTkinterWmIconwindow(this.AhkStdlibRoot, this._w, args*)
    }

    wm_iconwindow(args*)
    {
        return this.iconwindow(args*)
    }

    iconmask(args*)
    {
        return AhkStdlibTkinterWmIconmask(this.AhkStdlibRoot, this._w, args*)
    }

    wm_iconmask(args*)
    {
        return this.iconmask(args*)
    }

    iconbitmap(args*)
    {
        return AhkStdlibTkinterWmIconbitmap(this.AhkStdlibRoot, this._w, args*)
    }

    wm_iconbitmap(args*)
    {
        return this.iconbitmap(args*)
    }

    iconphoto(args*)
    {
        return AhkStdlibTkinterWmIconphoto(this.AhkStdlibRoot, this._w, args*)
    }

    wm_iconphoto(args*)
    {
        return this.iconphoto(args*)
    }

    resizable(args*)
    {
        return AhkStdlibTkinterWmResizable(this.AhkStdlibRoot, this._w, args*)
    }

    wm_resizable(args*)
    {
        return this.resizable(args*)
    }

    minsize(args*)
    {
        return AhkStdlibTkinterWmSize(this.AhkStdlibRoot, this._w, "minsize", args*)
    }

    wm_minsize(args*)
    {
        return this.minsize(args*)
    }

    maxsize(args*)
    {
        return AhkStdlibTkinterWmSize(this.AhkStdlibRoot, this._w, "maxsize", args*)
    }

    wm_maxsize(args*)
    {
        return this.maxsize(args*)
    }

    title(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_title() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.AhkStdlibRoot.eval("wm title " this._w)
        return this.AhkStdlibRoot.eval("wm title " this._w " " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_title(args*)
    {
        return this.title(args*)
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

    frame(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_frame() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval("wm frame " this._w)
    }

    wm_frame(args*)
    {
        return this.frame(args*)
    }

    focusmodel(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_focusmodel() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.AhkStdlibRoot.eval("wm focusmodel " this._w)
        return this.AhkStdlibRoot.eval("wm focusmodel " this._w " " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_focusmodel(args*)
    {
        return this.focusmodel(args*)
    }

    positionfrom(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_positionfrom() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.AhkStdlibRoot.eval("wm positionfrom " this._w)
        return this.AhkStdlibRoot.eval("wm positionfrom " this._w " " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_positionfrom(args*)
    {
        return this.positionfrom(args*)
    }

    sizefrom(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_sizefrom() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.AhkStdlibRoot.eval("wm sizefrom " this._w)
        return this.AhkStdlibRoot.eval("wm sizefrom " this._w " " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_sizefrom(args*)
    {
        return this.sizefrom(args*)
    }

    iconname(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_iconname() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.AhkStdlibRoot.eval("wm iconname " this._w)
        return this.AhkStdlibRoot.eval("wm iconname " this._w " " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_iconname(args*)
    {
        return this.iconname(args*)
    }

    client(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_client() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.AhkStdlibRoot.eval("wm client " this._w)
        return this.AhkStdlibRoot.eval("wm client " this._w " " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_client(args*)
    {
        return this.client(args*)
    }

    state(args*)
    {
        if args.Length > 1
            throw TypeError("Wm.wm_state() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return this.AhkStdlibRoot.eval("wm state " this._w)
        return this.AhkStdlibRoot.eval("wm state " this._w " " AhkStdlibTkinterTclWord(args[1]))
    }

    wm_state(args*)
    {
        return this.state(args*)
    }

    withdraw(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_withdraw() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval("wm withdraw " this._w)
    }

    wm_withdraw(args*)
    {
        return this.withdraw(args*)
    }

    iconify(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_iconify() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval("wm iconify " this._w)
    }

    wm_iconify(args*)
    {
        return this.iconify(args*)
    }

    deiconify(args*)
    {
        if args.Length != 0
            throw TypeError("Wm.wm_deiconify() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval("wm deiconify " this._w)
    }

    wm_deiconify(args*)
    {
        return this.deiconify(args*)
    }
}

class AhkStdlibTkinterEvent
{
    __New(args*)
    {
        if args.Length = 0
            return
        widget := args[1]
        rawArgs := args[2]
        sequence := args.Length >= 3 ? args[3] : ""
        eventTypeRaw := rawArgs.Length >= 2 ? rawArgs[2] : ""
        eventTypeName := AhkStdlibTkinterEventTypeName(eventTypeRaw, sequence)
        this.widget := widget
        this.type := AhkStdlibTkinterEventType(AhkStdlibTkinterEventTypeInternalValue(eventTypeRaw, eventTypeName), eventTypeName)
        this.x := AhkStdlibTkinterEventInteger(rawArgs.Length >= 3 ? rawArgs[3] : "0")
        this.y := AhkStdlibTkinterEventInteger(rawArgs.Length >= 4 ? rawArgs[4] : "0")
        this.num := AhkStdlibTkinterEventInteger(rawArgs.Length >= 5 ? rawArgs[5] : "0")
    }
}

class AhkStdlibTkinterEventType
{
    __New(args*)
    {
        if args.Length = 0
            throw TypeError("EnumMeta.__call__() missing 1 required positional argument: 'value'", -1)
        if args.Length > 2
            throw TypeError("Cannot extend enumerations", -1)
        value := args[1]
        name := args.Length = 2 ? args[2] : AhkStdlibTkinterEventTypeValueToName(value)
        this.name := name
        this.value := value ""
    }

    ToString()
    {
        return this.value
    }
}

class AhkStdlibTkinterCallWrapper
{
    __New(args*)
    {
        if args.Length = 0
            throw TypeError("CallWrapper.__init__() missing 3 required positional arguments: 'func', 'subst', and 'widget'", -1)
        if args.Length = 1
            throw TypeError("CallWrapper.__init__() missing 2 required positional arguments: 'subst' and 'widget'", -1)
        if args.Length = 2
            throw TypeError("CallWrapper.__init__() missing 1 required positional argument: 'widget'", -1)
        if args.Length > 3
            throw TypeError("CallWrapper.__init__() takes 4 positional arguments but " args.Length + 1 " were given", -1)
        this.func := args[1]
        this.subst := args[2]
        this.widget := args[3]
    }

    Call(args*)
    {
        try {
            if !AhkStdlibIsNone(this.subst)
                args := AhkStdlibTkinterCallWrapperArgs(this.subst.Call(args*))
            return this.func.Call(args*)
        } catch as err {
            this.widget._report_exception()
            return stdlib.None
        }
    }
}

class AhkStdlibTkinterBareMixin
{
    __New(className, args*)
    {
        if args.Length != 0
            throw TypeError(className "() takes no arguments", -1)
        this.AhkStdlibClassName := className
    }

    _missingTk()
    {
        throw AttributeError("'" this.AhkStdlibClassName "' object has no attribute 'tk'", -1)
    }
}

class AhkStdlibTkinterPack extends AhkStdlibTkinterBareMixin
{
    __New(args*)
    {
        super.__New("Pack", args*)
    }

    pack(args*)
    {
        return this._missingTk()
    }
}

class AhkStdlibTkinterPlace extends AhkStdlibTkinterBareMixin
{
    __New(args*)
    {
        super.__New("Place", args*)
    }

    place(args*)
    {
        return this._missingTk()
    }
}

class AhkStdlibTkinterGrid extends AhkStdlibTkinterBareMixin
{
    __New(args*)
    {
        super.__New("Grid", args*)
    }

    grid(args*)
    {
        return this._missingTk()
    }
}

class AhkStdlibTkinterXView extends AhkStdlibTkinterBareMixin
{
    __New(args*)
    {
        super.__New("XView", args*)
    }

    xview(args*)
    {
        return this._missingTk()
    }
}

class AhkStdlibTkinterYView extends AhkStdlibTkinterBareMixin
{
    __New(args*)
    {
        super.__New("YView", args*)
    }

    yview(args*)
    {
        return this._missingTk()
    }
}

class AhkStdlibTkinterMisc extends AhkStdlibTkinterBareMixin
{
    __New(args*)
    {
        super.__New("Misc", args*)
    }

    destroy(args*)
    {
        if args.Length != 0
            throw TypeError("Misc.destroy() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return stdlib.None
    }
}

class AhkStdlibTkinterWm extends AhkStdlibTkinterBareMixin
{
    __New(args*)
    {
        super.__New("Wm", args*)
    }

    wm_title(args*)
    {
        return this._missingTk()
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
            master := AhkStdlibTkinterGetDefaultRoot("create image")

        tk := IsObject(master) && HasProp(master, "tk") ? master.tk : master
        if !IsObject(tk) || !HasMethod(tk, "eval")
            throw AttributeError("'" AhkStdlibPyTypeName(master) "' object has no attribute 'call'", -1)

        if AhkStdlibIsNone(name) || name = ""
            name := AhkStdlibTkinterDefaultImageName()
        this.name := name
        this.tk := tk
        this.AhkStdlibRoot := tk._root()
        this.AhkStdlibImageType := imageType
        AhkStdlibTkinterImageCreateRaiseCoveredNoneErrors(imageType, options)
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
        this.tk.eval(this.name " config" AhkStdlibTkinterOptionsToScriptSkipNone(args[1], false, this.AhkStdlibRoot))
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

class AhkStdlibTkinterPublicImage extends AhkStdlibTkinterImage
{
    __New(args*)
    {
        if args.Length = 0
            throw TypeError("Image.__init__() missing 1 required positional argument: 'imgtype'", -1)
        if args.Length > 4
            throw TypeError("Image.__init__() takes from 2 to 5 positional arguments but " args.Length + 1 " were given", -1)

        imageArgs := []
        loop args.Length - 1
            imageArgs.Push(args[A_Index + 1])
        super.__New("Image", args[1], imageArgs*)
    }
}

class AhkStdlibTkinterPhotoImage extends AhkStdlibTkinterImage
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
        destImage := AhkStdlibTkinterPhotoImage({ master: this.tk })
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
        return AhkStdlibTkinterRgbTuple(this.tk.eval(AhkStdlibTkinterPhotoImageScript(this.name " get", args)))
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
        destImage := AhkStdlibTkinterPhotoImage({ master: this.tk })
        this.tk.eval(AhkStdlibTkinterTclWord(destImage.name) " copy " AhkStdlibTkinterTclWord(this.name) AhkStdlibTkinterPhotoImageTransformOptionScript("-subsample", args))
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
        value := this.tk.eval(AhkStdlibTkinterPhotoImageScript(AhkStdlibTkinterTclWord(this.name) " transparency get", args))
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
        this.tk.eval(AhkStdlibTkinterPhotoImageScript(AhkStdlibTkinterTclWord(this.name) " transparency set", args))
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
        destImage := AhkStdlibTkinterPhotoImage({ master: this.tk })
        this.tk.eval(AhkStdlibTkinterTclWord(destImage.name) " copy " AhkStdlibTkinterTclWord(this.name) AhkStdlibTkinterPhotoImageTransformOptionScript("-zoom", args))
        return destImage
    }
}

class AhkStdlibTkinterBitmapImage extends AhkStdlibTkinterImage
{
    __New(args*)
    {
        super.__New("BitmapImage", "bitmap", args*)
    }
}

class AhkStdlibTkinterButton extends AhkStdlibTkinterWidget
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

    flash(args*)
    {
        if args.Length != 0
            throw TypeError("Button.flash() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " flash")
        return stdlib.None
    }
}

class AhkStdlibTkinterCheckbutton extends AhkStdlibTkinterWidget
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

    flash(args*)
    {
        if args.Length != 0
            throw TypeError("Checkbutton.flash() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " flash")
        return stdlib.None
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

class AhkStdlibTkinterRadiobutton extends AhkStdlibTkinterWidget
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

class AhkStdlibTkinterScale extends AhkStdlibTkinterWidget
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
        if args.Length = 1 && !AhkStdlibIsNone(args[1])
            script .= " " AhkStdlibTkinterScaleValueWord(args[1])
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
        return this.AhkStdlibRoot.eval(AhkStdlibTkinterScaleScript(this._w " identify", args))
    }

    set(args*)
    {
        if args.Length = 0
            throw TypeError("Scale.set() missing 1 required positional argument: 'value'", -1)
        if args.Length > 1
            throw TypeError("Scale.set() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterScaleScript(this._w " set", args))
        return stdlib.None
    }
}

class AhkStdlibTkinterScrollbar extends AhkStdlibTkinterWidget
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
            if !AhkStdlibIsNone(args[1])
                this.AhkStdlibRoot.eval(script " " AhkStdlibTkinterScrollbarValueWord(args[1]))
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
        return Float(this.AhkStdlibRoot.eval(AhkStdlibTkinterScrollbarScript(this._w " delta", args)))
    }

    fraction(args*)
    {
        if args.Length = 0
            throw TypeError("Scrollbar.fraction() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("Scrollbar.fraction() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("Scrollbar.fraction() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        return Float(this.AhkStdlibRoot.eval(AhkStdlibTkinterScrollbarScript(this._w " fraction", args)))
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
        return this.AhkStdlibRoot.eval(AhkStdlibTkinterScrollbarScript(this._w " identify", args))
    }

    set(args*)
    {
        if args.Length = 0
            throw TypeError("Scrollbar.set() missing 2 required positional arguments: 'first' and 'last'", -1)
        if args.Length = 1
            throw TypeError("Scrollbar.set() missing 1 required positional argument: 'last'", -1)
        if args.Length > 2
            throw TypeError("Scrollbar.set() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterScrollbarScript(this._w " set", args))
        return stdlib.None
    }
}

class AhkStdlibTkinterMenu extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Menu", "menu", args*)
    }

    add(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.add() missing 1 required positional argument: 'itemType'", -1)
        if args.Length > 2
            throw TypeError("Menu.add() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        script := AhkStdlibTkinterMenuScript(this._w " add", [args[1]])
        if args.Length = 2 && !AhkStdlibIsNone(args[1]) {
            if !AhkStdlibTkinterIsPlainKeywordObject(args[2])
                throw TypeError("object of type '" AhkStdlibPyTypeName(args[2]) "' has no len()", -1)
            script .= AhkStdlibTkinterOptionsToScriptSkipNone(args[2], false, this.AhkStdlibRoot)
        }
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
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
        this.AhkStdlibRoot.eval(this._w " add command" AhkStdlibTkinterOptionsToScriptSkipNone(args[1], false, this.AhkStdlibRoot))
        return stdlib.None
    }

    add_cascade(args*)
    {
        if args.Length > 1
            throw TypeError("Menu.add_cascade() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 {
            this.AhkStdlibRoot.eval(this._w " add cascade")
            return stdlib.None
        }
        if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
            throw TypeError("object of type '" AhkStdlibPyTypeName(args[1]) "' has no len()", -1)
        this.AhkStdlibRoot.eval(this._w " add cascade" AhkStdlibTkinterOptionsToScriptSkipNone(args[1], false, this.AhkStdlibRoot))
        return stdlib.None
    }

    add_checkbutton(args*)
    {
        if args.Length > 1
            throw TypeError("Menu.add_checkbutton() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 {
            this.AhkStdlibRoot.eval(this._w " add checkbutton")
            return stdlib.None
        }
        if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
            throw TypeError("object of type '" AhkStdlibPyTypeName(args[1]) "' has no len()", -1)
        this.AhkStdlibRoot.eval(this._w " add checkbutton" AhkStdlibTkinterOptionsToScriptSkipNone(args[1], false, this.AhkStdlibRoot))
        return stdlib.None
    }

    add_radiobutton(args*)
    {
        if args.Length > 1
            throw TypeError("Menu.add_radiobutton() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 {
            this.AhkStdlibRoot.eval(this._w " add radiobutton")
            return stdlib.None
        }
        if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
            throw TypeError("object of type '" AhkStdlibPyTypeName(args[1]) "' has no len()", -1)
        this.AhkStdlibRoot.eval(this._w " add radiobutton" AhkStdlibTkinterOptionsToScriptSkipNone(args[1], false, this.AhkStdlibRoot))
        return stdlib.None
    }

    add_separator(args*)
    {
        if args.Length > 1
            throw TypeError("Menu.add_separator() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 {
            this.AhkStdlibRoot.eval(this._w " add separator")
            return stdlib.None
        }
        if !AhkStdlibTkinterIsPlainKeywordObject(args[1])
            throw TypeError("object of type '" AhkStdlibPyTypeName(args[1]) "' has no len()", -1)
        this.AhkStdlibRoot.eval(this._w " add separator" AhkStdlibTkinterOptionsToScriptSkipNone(args[1], false, this.AhkStdlibRoot))
        return stdlib.None
    }

    insert(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.insert() missing 2 required positional arguments: 'index' and 'itemType'", -1)
        if args.Length = 1
            throw TypeError("Menu.insert() missing 1 required positional argument: 'itemType'", -1)
        if args.Length > 3
            throw TypeError("Menu.insert() takes from 3 to 4 positional arguments but " args.Length + 1 " were given", -1)
        script := AhkStdlibTkinterMenuScript(this._w " insert", [args[1], args[2]])
        if args.Length = 3 && AhkStdlibTkinterEffectiveTclArgCount([args[1], args[2]]) = 2 {
            if !AhkStdlibTkinterIsPlainKeywordObject(args[3])
                throw TypeError("object of type '" AhkStdlibPyTypeName(args[3]) "' has no len()", -1)
            script .= AhkStdlibTkinterOptionsToScriptSkipNone(args[3], false, this.AhkStdlibRoot)
        }
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    insert_cascade(args*)
    {
        return this.AhkStdlibInsertMenuEntry("insert_cascade", "cascade", args*)
    }

    insert_checkbutton(args*)
    {
        return this.AhkStdlibInsertMenuEntry("insert_checkbutton", "checkbutton", args*)
    }

    insert_command(args*)
    {
        return this.AhkStdlibInsertMenuEntry("insert_command", "command", args*)
    }

    insert_radiobutton(args*)
    {
        return this.AhkStdlibInsertMenuEntry("insert_radiobutton", "radiobutton", args*)
    }

    insert_separator(args*)
    {
        return this.AhkStdlibInsertMenuEntry("insert_separator", "separator", args*)
    }

    AhkStdlibInsertMenuEntry(methodName, itemType, args*)
    {
        if args.Length = 0
            throw TypeError("Menu." methodName "() missing 1 required positional argument: 'index'", -1)
        if args.Length > 2
            throw TypeError("Menu." methodName "() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        script := AhkStdlibTkinterMenuScript(this._w " insert", [args[1]])
        if !AhkStdlibIsNone(args[1])
            script .= " " itemType
        if args.Length = 2 && !AhkStdlibIsNone(args[1]) {
            if !AhkStdlibTkinterIsPlainKeywordObject(args[2])
                throw TypeError("object of type '" AhkStdlibPyTypeName(args[2]) "' has no len()", -1)
            script .= AhkStdlibTkinterOptionsToScriptSkipNone(args[2], false, this.AhkStdlibRoot)
        }
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    post(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.post() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("Menu.post() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("Menu.post() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterMenuScript(this._w " post", args))
        return stdlib.None
    }

    tk_popup(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.tk_popup() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("Menu.tk_popup() missing 1 required positional argument: 'y'", -1)
        if args.Length > 3
            throw TypeError("Menu.tk_popup() takes from 3 to 4 positional arguments but " args.Length + 1 " were given", -1)
        entry := args.Length = 3 ? args[3] : ""
        this.AhkStdlibRoot.eval(AhkStdlibTkinterMenuScript("tk_popup " this._w, [args[1], args[2], entry]))
        return stdlib.None
    }

    unpost(args*)
    {
        if args.Length != 0
            throw TypeError("Menu.unpost() takes 1 positional argument but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(this._w " unpost")
        return stdlib.None
    }

    xposition(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.xposition() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Menu.xposition() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval(AhkStdlibTkinterMenuScript(this._w " xposition", args)))
    }

    yposition(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.yposition() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Menu.yposition() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval(AhkStdlibTkinterMenuScript(this._w " yposition", args)))
    }

    activate(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.activate() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Menu.activate() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterMenuScript(this._w " activate", args))
        return stdlib.None
    }

    delete(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.delete() missing 1 required positional argument: 'index1'", -1)
        if args.Length > 2
            throw TypeError("Menu.delete() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        index2 := args.Length = 2 && !AhkStdlibIsNone(args[2]) ? args[2] : args[1]
        this.index(args[1])
        this.index(index2)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterMenuScript(this._w " delete", [args[1], index2]))
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
        if AhkStdlibIsNone(args[2])
            throw TypeError('can only concatenate str (not "NoneType") to str', -1)
        script := AhkStdlibTkinterMenuScript(this._w " entrycget", [args[1]])
        if !AhkStdlibIsNone(args[1])
            script .= " -" args[2]
        return this.AhkStdlibRoot.eval(script)
    }

    entryconfigure(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.entryconfigure() missing 1 required positional argument: 'index'", -1)
        if args.Length > 2
            throw TypeError("Menu.entryconfigure() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 1
            return AhkStdlibTkinterMenuEntryConfigureDict(this.AhkStdlibRoot, this._w, args[1])
        if AhkStdlibIsNone(args[2])
            return AhkStdlibTkinterMenuEntryConfigureDict(this.AhkStdlibRoot, this._w, args[1])
        if Type(args[2]) = "String"
            return AhkStdlibTkinterMenuEntryConfigureOption(this.AhkStdlibRoot, this._w, args[1], args[2])
        if !AhkStdlibTkinterIsPlainKeywordObject(args[2])
            throw TypeError("object of type '" AhkStdlibPyTypeName(args[2]) "' has no len()", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterMenuScript(this._w " entryconfigure", [args[1]]) AhkStdlibTkinterOptionsToScriptSkipNone(args[2], false, this.AhkStdlibRoot))
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
        value := this.AhkStdlibRoot.eval(AhkStdlibTkinterMenuScript(this._w " index", args))
        if value = "none"
            return stdlib.None
        return Integer(value)
    }

    type(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.type() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Menu.type() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(AhkStdlibTkinterMenuScript(this._w " type", args))
    }

    invoke(args*)
    {
        if args.Length = 0
            throw TypeError("Menu.invoke() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Menu.invoke() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(AhkStdlibTkinterMenuScript(this._w " invoke", args))
    }
}

class AhkStdlibTkinterMenubutton extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Menubutton", "menubutton", args*)
    }
}

class AhkStdlibTkinterMessage extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        super.__New("Message", "message", args*)
    }
}

class AhkStdlibTkinterOptionMenu extends AhkStdlibTkinterMenubutton
{
    __New(args*)
    {
        if args.Length = 0
            throw TypeError("OptionMenu.__init__() missing 3 required positional arguments: 'master', 'variable', and 'value'", -1)
        if args.Length = 1
            throw TypeError("OptionMenu.__init__() missing 2 required positional arguments: 'variable' and 'value'", -1)
        if args.Length = 2
            throw TypeError("OptionMenu.__init__() missing 1 required positional argument: 'value'", -1)

        master := args[1]
        variable := args[2]
        values := []
        options := {}
        lastIsOptions := args.Length > 3 && AhkStdlibTkinterIsPlainKeywordObject(args[args.Length])
        lastValueIndex := lastIsOptions ? args.Length - 1 : args.Length
        index := 3
        while index <= lastValueIndex {
            values.Push(args[index])
            index += 1
        }
        if lastIsOptions
            options := args[args.Length]
        for key, value in options.OwnProps() {
            if key != "command"
                throw AhkStdlibTkinter.TclError("unknown option -" key)
        }

        if !IsObject(master) || !HasProp(master, "tk")
            throw AttributeError("'" AhkStdlibPyTypeName(master) "' object has no attribute 'tk'", -1)

        this.master := master
        this.tk := master.tk
        this.AhkStdlibRoot := master._root()
        this.AhkStdlibTkCommand := "menubutton"
        pathOptions := {}
        this._w := AhkStdlibTkinterResolveWidgetPath(this.AhkStdlibRoot, String(master), "optionmenu", pathOptions)

        widgetOptions := { borderwidth: 2, textvariable: variable, indicatoron: 1, relief: "raised", anchor: "c", highlightthickness: 2 }
        this.AhkStdlibRoot.eval("menubutton " this._w AhkStdlibTkinterOptionsToScript(widgetOptions, false, this.AhkStdlibRoot))
        this.AhkStdlibRoot.AhkStdlibWidgetsByPath[this._w] := this
        this.AhkStdlibMenu := AhkStdlibTkinterMenu(this, { name: "menu", tearoff: 0 })
        this.menuname := String(this.AhkStdlibMenu)

        callback := options.HasOwnProp("command") ? options.command : stdlib.None
        for value in values
            this.AhkStdlibMenu.add_command({ label: value, command: AhkStdlibTkinterOptionMenuCommand(variable, value, callback) })
        this.configure({ menu: this.AhkStdlibMenu })
    }

    __Item[name]
    {
        get {
            if name = "menu"
                return this.AhkStdlibMenu
            return this.cget(name)
        }
    }

    destroy()
    {
        super.destroy()
        this.AhkStdlibMenu := stdlib.None
        return stdlib.None
    }
}

class AhkStdlibTkinterPanedWindow extends AhkStdlibTkinterWidget
{
    __New(args*)
    {
        if args.Length >= 2 && !AhkStdlibTkinterIsPlainKeywordObject(args[2])
            throw TypeError("argument of type '" AhkStdlibPyTypeName(args[2]) "' is not iterable", -1)
        super.__New("PanedWindow", "panedwindow", args*)
    }

    add(args*)
    {
        if args.Length = 0
            throw TypeError("PanedWindow.add() missing 1 required positional argument: 'child'", -1)
        if args.Length > 2
            throw TypeError("PanedWindow.add() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        options := args.Length = 2 ? args[2] : {}
        if !AhkStdlibTkinterIsPlainKeywordObject(options)
            throw TypeError("object of type '" AhkStdlibPyTypeName(options) "' has no len()", -1)
        script := AhkStdlibTkinterPanedWindowScript(this._w " add", [args[1]])
        if !AhkStdlibIsNone(args[1])
            script .= AhkStdlibTkinterOptionsToScriptSkipNone(options, false, this.AhkStdlibRoot)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    remove(args*)
    {
        if args.Length = 0
            throw TypeError("PanedWindow.remove() missing 1 required positional argument: 'child'", -1)
        if args.Length > 1
            throw TypeError("PanedWindow.remove() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterPanedWindowScript(this._w " forget", args))
        return stdlib.None
    }

    forget(args*)
    {
        return this.remove(args*)
    }

    identify(args*)
    {
        if args.Length = 0
            throw TypeError("PanedWindow.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("PanedWindow.identify() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("PanedWindow.identify() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(AhkStdlibTkinterPanedWindowScript(this._w " identify", args))
    }

    panecget(args*)
    {
        if args.Length = 0
            throw TypeError("PanedWindow.panecget() missing 2 required positional arguments: 'child' and 'option'", -1)
        if args.Length = 1
            throw TypeError("PanedWindow.panecget() missing 1 required positional argument: 'option'", -1)
        if args.Length > 2
            throw TypeError("PanedWindow.panecget() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        option := AhkStdlibTkinterPanedWindowDashOption(args[2])
        script := AhkStdlibTkinterPanedWindowScript(this._w " panecget", [args[1]])
        if !AhkStdlibIsNone(args[1])
            script .= " " option
        value := this.AhkStdlibRoot.eval(script)
        return AhkStdlibTkinterCgetValue(args[2], value)
    }

    paneconfigure(args*)
    {
        if args.Length = 0
            throw TypeError("PanedWindow.paneconfigure() missing 1 required positional argument: 'tagOrId'", -1)
        if args.Length > 2
            throw TypeError("PanedWindow.paneconfigure() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

        childWord := AhkStdlibTkinterPanedWindowChildWord(args[1])
        if AhkStdlibIsNone(args[1]) {
            this.AhkStdlibRoot.eval(this._w " paneconfigure")
            return stdlib.None
        }
        if args.Length = 1 || AhkStdlibIsNone(args[2])
            return AhkStdlibTkinterPaneConfigureDict(this.AhkStdlibRoot, this._w, childWord, true)
        if AhkStdlibTkinterIsPlainKeywordObject(args[2]) {
            this.AhkStdlibRoot.eval(this._w " paneconfigure " childWord AhkStdlibTkinterOptionsToScriptSkipNone(args[2], false, this.AhkStdlibRoot))
            return stdlib.None
        }
        return AhkStdlibTkinterPaneConfigureOption(this.AhkStdlibRoot, this._w, childWord, args[2], true)
    }

    paneconfig(args*)
    {
        return this.paneconfigure(args*)
    }

    panes(args*)
    {
        if args.Length != 0
            throw TypeError("PanedWindow.panes() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(this._w " panes")))
    }

    proxy(args*)
    {
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(AhkStdlibTkinterPanedWindowScript(this._w " proxy", args))))
    }

    proxy_coord(args*)
    {
        if args.Length != 0
            throw TypeError("PanedWindow.proxy_coord() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(this._w " proxy coord"))
    }

    proxy_forget(args*)
    {
        if args.Length != 0
            throw TypeError("PanedWindow.proxy_forget() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(this._w " proxy forget")))
    }

    proxy_place(args*)
    {
        if args.Length = 0
            throw TypeError("PanedWindow.proxy_place() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("PanedWindow.proxy_place() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("PanedWindow.proxy_place() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(AhkStdlibTkinterPanedWindowScript(this._w " proxy place", args))))
    }

    sash(args*)
    {
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(AhkStdlibTkinterPanedWindowScript(this._w " sash", args))))
    }

    sash_coord(args*)
    {
        if args.Length = 0
            throw TypeError("PanedWindow.sash_coord() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("PanedWindow.sash_coord() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(AhkStdlibTkinterPanedWindowScript(this._w " sash coord", args)))
    }

    sash_mark(args*)
    {
        if args.Length = 0
            throw TypeError("PanedWindow.sash_mark() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("PanedWindow.sash_mark() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(AhkStdlibTkinterPanedWindowScript(this._w " sash mark", args)))
    }

    sash_place(args*)
    {
        if args.Length = 0
            throw TypeError("PanedWindow.sash_place() missing 3 required positional arguments: 'index', 'x', and 'y'", -1)
        if args.Length = 1 || args.Length = 2
            throw TypeError("PanedWindow.sash_place() missing 1 required positional argument: 'y'", -1)
        if args.Length > 3
            throw TypeError("PanedWindow.sash_place() takes 4 positional arguments but " args.Length + 1 " were given", -1)
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(AhkStdlibTkinterPanedWindowScript(this._w " sash place", args))))
    }
}

class AhkStdlibTkinterOptionMenuCommand
{
    __New(variable, value, callback)
    {
        this.Variable := variable
        this.Value := value
        this.OptionCallback := callback
    }

    Call(args*)
    {
        return AhkStdlibTkinterOptionMenuSetit(this.Variable, this.Value, this.OptionCallback)
    }
}

class AhkStdlibTkinterCanvas extends AhkStdlibTkinterWidget
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " dchars", args))
        return stdlib.None
    }

    focus(args*)
    {
        value := this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " focus", args))
        if args.Length = 0 && value != ""
            return Integer(value)
        return value
    }

    icursor(args*)
    {
        this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " icursor", args))
        return stdlib.None
    }

    index(args*)
    {
        return Integer(this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " index", args)))
    }

    insert(args*)
    {
        this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " insert", args))
        return stdlib.None
    }

    coords(args*)
    {
        return AhkStdlibTkinterCanvasCoordList(this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " coords", args)))
    }

    find(args*)
    {
        return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " find", args)))
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
        return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " find closest", args)))
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
        value := this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " bbox", args))
        if Trim(value) = ""
            return stdlib.None
        return AhkStdlibTkinterIntegerTuple(value)
    }

    move(args*)
    {
        this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " move", args))
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
        this.AhkStdlibRoot.eval(this._w " itemconfigure " AhkStdlibTkinterTclWord(args[1]) AhkStdlibTkinterOptionsToScriptSkipNone(args[2], false, this.AhkStdlibRoot))
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " addtag", args))
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
        values := [args[1], "closest", args[2], args[3]]
        if args.Length >= 4
            values.Push(args[4])
        if args.Length >= 5
            values.Push(args[5])
        this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " addtag", values))
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " dtag", args))
        return stdlib.None
    }

    gettags(args*)
    {
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " gettags", args))))
    }

    select_adjust(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.select_adjust", args.Length, 2, 2, ["tagOrId", "index"])
        this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " select adjust", args))
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " select from", args))
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " select to", args))
        return stdlib.None
    }

    scale(args*)
    {
        this.AhkStdlibRoot.eval(AhkStdlibTkinterCanvasScript(this._w " scale", args))
        return stdlib.None
    }

    scan_mark(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.scan_mark", args.Length, 2, 2, ["x", "y"])
        this.AhkStdlibRoot.eval(AhkStdlibTkinterScanScript(this._w " scan mark", args))
        return stdlib.None
    }

    scan_dragto(args*)
    {
        AhkStdlibTkinterCanvasRequireArgs("Canvas.scan_dragto", args.Length, 2, 3, ["x", "y"])
        scanArgs := args.Clone()
        if scanArgs.Length = 2
            scanArgs.Push(10)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterScanScript(this._w " scan dragto", scanArgs))
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
        script := AhkStdlibTkinterViewScript(this._w " xview", args)
        value := this.AhkStdlibRoot.eval(script)
        return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
    }

    xview_moveto(args*)
    {
        if args.Length = 0
            throw TypeError("XView.xview_moveto() missing 1 required positional argument: 'fraction'", -1)
        if args.Length > 1
            throw TypeError("XView.xview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)

        script := this._w " xview moveto"
        if !AhkStdlibIsNone(args[1])
            script .= " " AhkStdlibTkinterViewValueWord(args[1])
        this.AhkStdlibRoot.eval(script)
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

        this.AhkStdlibRoot.eval(AhkStdlibTkinterViewScript(this._w " xview scroll", args))
        return stdlib.None
    }

    yview(args*)
    {
        script := AhkStdlibTkinterViewScript(this._w " yview", args)
        value := this.AhkStdlibRoot.eval(script)
        return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
    }

    yview_moveto(args*)
    {
        if args.Length = 0
            throw TypeError("YView.yview_moveto() missing 1 required positional argument: 'fraction'", -1)
        if args.Length > 1
            throw TypeError("YView.yview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)

        script := this._w " yview moveto"
        if !AhkStdlibIsNone(args[1])
            script .= " " AhkStdlibTkinterViewValueWord(args[1])
        this.AhkStdlibRoot.eval(script)
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

        this.AhkStdlibRoot.eval(AhkStdlibTkinterViewScript(this._w " yview scroll", args))
        return stdlib.None
    }

}

class AhkStdlibTkinterText extends AhkStdlibTkinterWidget
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " insert", args))
        return stdlib.None
    }

    get(args*)
    {
        if args.Length = 0
            throw TypeError("Text.get() missing 1 required positional argument: 'index1'", -1)
        if args.Length > 2
            throw TypeError("Text.get() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " get", args))
    }

    delete(args*)
    {
        if args.Length = 0
            throw TypeError("Text.delete() missing 1 required positional argument: 'index1'", -1)
        if args.Length > 2
            throw TypeError("Text.delete() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " delete", args))
        return stdlib.None
    }

    replace(args*)
    {
        if args.Length = 0
            throw TypeError("Text.replace() missing 3 required positional arguments: 'index1', 'index2', and 'chars'", -1)
        if args.Length = 1
            throw TypeError("Text.replace() missing 2 required positional arguments: 'index2' and 'chars'", -1)
        if args.Length = 2
            throw TypeError("Text.replace() missing 1 required positional argument: 'chars'", -1)

        this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " replace", args))
        return stdlib.None
    }

    peer_create(args*)
    {
        if args.Length = 0
            throw TypeError("Text.peer_create() missing 1 required positional argument: 'newPathName'", -1)
        if args.Length > 2
            throw TypeError("Text.peer_create() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

        script := AhkStdlibTkinterTextScript(this._w " peer create", [args[1]])
        if args.Length = 2 && !AhkStdlibIsNone(args[1]) {
            if AhkStdlibIsNone(args[2])
                throw AttributeError("'NoneType' object has no attribute 'items'", -1)
            if !AhkStdlibTkinterIsPlainKeywordObject(args[2])
                throw TypeError("object of type '" AhkStdlibPyTypeName(args[2]) "' has no len()", -1)
            script .= AhkStdlibTkinterOptionsToScriptSkipNone(args[2], false, this.AhkStdlibRoot)
        }
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    peer_names(args*)
    {
        if args.Length != 0
            throw TypeError("Text.peer_names() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(this._w " peer names")))
    }

    index(args*)
    {
        if args.Length = 0
            throw TypeError("Text.index() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Text.index() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " index", args))
    }

    compare(args*)
    {
        if args.Length = 0
            throw TypeError("Text.compare() missing 3 required positional arguments: 'index1', 'op', and 'index2'", -1)
        if args.Length = 1
            throw TypeError("Text.compare() missing 2 required positional arguments: 'op' and 'index2'", -1)
        if args.Length = 2
            throw TypeError("Text.compare() missing 1 required positional argument: 'index2'", -1)
        if args.Length > 3
            throw TypeError("Text.compare() takes 4 positional arguments but " args.Length + 1 " were given", -1)
        value := this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " compare", args))
        return value = "1" ? stdlib.True : stdlib.False
    }

    count(args*)
    {
        if args.Length = 0
            throw TypeError("Text.count() missing 2 required positional arguments: 'index1' and 'index2'", -1)
        if args.Length = 1
            throw TypeError("Text.count() missing 1 required positional argument: 'index2'", -1)

        script := this._w " count"
        index := 3
        while index <= args.Length {
            script .= " " AhkStdlibTkinterTclWord("-" AhkStdlibTkinterTextCountOptionName(args[index]))
            index += 1
        }
        value := this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(script, [args[1], args[2]]))
        if value = ""
            return stdlib.None

        values := AhkStdlibTkinterIntegerTuple(value)
        if args.Length <= 3 || values.Length != 1
            return values
        return values[1]
    }

    search(args*)
    {
        if args.Length = 0
            throw TypeError("Text.search() missing 2 required positional arguments: 'pattern' and 'index'", -1)
        if args.Length = 1
            throw TypeError("Text.search() missing 1 required positional argument: 'index'", -1)

        positionalLength := args.Length
        keywordOptions := unset
        if args.Length >= 3 && !AhkStdlibIsNone(args[args.Length]) && AhkStdlibTkinterIsPlainKeywordObject(args[args.Length]) {
            keywordOptions := args[args.Length]
            positionalLength -= 1
        }
        if positionalLength > 10
            throw TypeError("Text.search() takes from 3 to 11 positional arguments but " positionalLength + 1 " were given", -1)

        stopindex := positionalLength >= 3 ? args[3] : stdlib.None
        forwards := positionalLength >= 4 ? args[4] : stdlib.None
        backwards := positionalLength >= 5 ? args[5] : stdlib.None
        exact := positionalLength >= 6 ? args[6] : stdlib.None
        regexp := positionalLength >= 7 ? args[7] : stdlib.None
        nocase := positionalLength >= 8 ? args[8] : stdlib.None
        count := positionalLength >= 9 ? args[9] : stdlib.None
        elide := positionalLength >= 10 ? args[10] : stdlib.None

        if IsSet(keywordOptions) {
            for key, value in keywordOptions.OwnProps() {
                switch key {
                    case "stopindex":
                        if positionalLength >= 3
                            throw TypeError("Text.search() got multiple values for argument 'stopindex'", -1)
                        stopindex := value
                    case "forwards":
                        if positionalLength >= 4
                            throw TypeError("Text.search() got multiple values for argument 'forwards'", -1)
                        forwards := value
                    case "backwards":
                        if positionalLength >= 5
                            throw TypeError("Text.search() got multiple values for argument 'backwards'", -1)
                        backwards := value
                    case "exact":
                        if positionalLength >= 6
                            throw TypeError("Text.search() got multiple values for argument 'exact'", -1)
                        exact := value
                    case "regexp":
                        if positionalLength >= 7
                            throw TypeError("Text.search() got multiple values for argument 'regexp'", -1)
                        regexp := value
                    case "nocase":
                        if positionalLength >= 8
                            throw TypeError("Text.search() got multiple values for argument 'nocase'", -1)
                        nocase := value
                    case "count":
                        if positionalLength >= 9
                            throw TypeError("Text.search() got multiple values for argument 'count'", -1)
                        count := value
                    case "elide":
                        if positionalLength >= 10
                            throw TypeError("Text.search() got multiple values for argument 'elide'", -1)
                        elide := value
                    default:
                        throw TypeError("Text.search() got an unexpected keyword argument '" key "'", -1)
                }
            }
        }

        script := this._w " search"
        if AhkStdlibTruthValue(forwards)
            script .= " -forwards"
        if AhkStdlibTruthValue(backwards)
            script .= " -backwards"
        if AhkStdlibTruthValue(exact)
            script .= " -exact"
        if AhkStdlibTruthValue(regexp)
            script .= " -regexp"
        if AhkStdlibTruthValue(nocase)
            script .= " -nocase"
        if AhkStdlibTruthValue(elide)
            script .= " -elide"
        if AhkStdlibTruthValue(count)
            script .= " -count " AhkStdlibTkinterTextValueWord(count)

        pattern := args[1]
        if AhkStdlibTruthValue(pattern) && AhkStdlibTkinterTextSearchPatternStartsDash(pattern)
            script .= " --"
        searchValues := [pattern, args[2]]
        if AhkStdlibTruthValue(stopindex)
            searchValues.Push(stopindex)
        return this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(script, searchValues))
    }

    debug(args*)
    {
        if args.Length > 1
            throw TypeError("Text.debug() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 0 || AhkStdlibIsNone(args[1])
            return AhkStdlibTkinterGetBooleanPublic(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(this._w " debug"))

        this.AhkStdlibRoot.eval(this._w " debug " AhkStdlibTkinterTextValueWord(args[1]))
        return stdlib.None
    }

    edit(args*)
    {
        script := AhkStdlibTkinterTextScript(this._w " edit", args)
        effectiveLength := 0
        for value in args {
            if AhkStdlibIsNone(value)
                break
            effectiveLength += 1
        }
        value := this.AhkStdlibRoot.eval(script)
        if args.Length >= 1 && effectiveLength = 1 {
            option := AhkStdlibTkinterTextValueText(args[1])
            if option = "canundo" || option = "canredo" || option = "modified"
                return Integer(value)
        }
        return value
    }

    edit_modified(args*)
    {
        if args.Length > 1
            throw TypeError("Text.edit_modified() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        return args.Length = 0 ? this.edit("modified", stdlib.None) : this.edit("modified", args[1])
    }

    edit_redo(args*)
    {
        if args.Length != 0
            throw TypeError("Text.edit_redo() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.edit("redo")
    }

    edit_reset(args*)
    {
        if args.Length != 0
            throw TypeError("Text.edit_reset() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.edit("reset")
    }

    edit_separator(args*)
    {
        if args.Length != 0
            throw TypeError("Text.edit_separator() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.edit("separator")
    }

    edit_undo(args*)
    {
        if args.Length != 0
            throw TypeError("Text.edit_undo() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return this.edit("undo")
    }

    dump(args*)
    {
        if args.Length = 0
            throw TypeError("Text.dump() missing 1 required positional argument: 'index1'", -1)

        positionalLength := args.Length
        keywordOptions := unset
        if args.Length >= 2 && !AhkStdlibIsNone(args[args.Length]) && AhkStdlibTkinterIsPlainKeywordObject(args[args.Length]) {
            keywordOptions := args[args.Length]
            positionalLength -= 1
        }
        if positionalLength > 3
            throw TypeError("Text.dump() takes from 2 to 4 positional arguments but " positionalLength + 1 " were given", -1)

        index1 := args[1]
        index2 := positionalLength >= 2 ? args[2] : stdlib.None
        command := positionalLength >= 3 ? args[3] : stdlib.None
        if IsSet(keywordOptions) {
            if keywordOptions.HasOwnProp("index2") {
                if positionalLength >= 2
                    throw TypeError("Text.dump() got multiple values for argument 'index2'", -1)
                index2 := keywordOptions.index2
            }
            if keywordOptions.HasOwnProp("command") {
                if positionalLength >= 3
                    throw TypeError("Text.dump() got multiple values for argument 'command'", -1)
                command := keywordOptions.command
            }
        }

        result := stdlib.None
        registeredCommand := ""
        if !AhkStdlibTruthValue(command) {
            result := []
            command := (key, value, index) => result.Push(stdlib.tuple([key, value, index]))
        }
        commandName := command
        if IsObject(command) && HasMethod(command, "Call") {
            commandName := AhkStdlibTkinterRegisterCommand(this.AhkStdlibRoot, command)
            registeredCommand := commandName
        }

        script := this._w " dump -command " AhkStdlibTkinterTclWord(commandName)
        if IsSet(keywordOptions) {
            for key, value in keywordOptions.OwnProps() {
                if key = "index2" || key = "command"
                    continue
                if AhkStdlibTruthValue(value)
                    script .= " -" key
            }
        }
        dumpValues := [index1]
        if AhkStdlibTruthValue(index2)
            dumpValues.Push(index2)
        script := AhkStdlibTkinterTextScript(script, dumpValues)

        try {
            this.AhkStdlibRoot.eval(script)
        } finally {
            if registeredCommand != ""
                AhkStdlibTkinterDeleteCommand(this.AhkStdlibRoot, registeredCommand)
        }
        return result
    }

    mark_set(args*)
    {
        if args.Length = 0
            throw TypeError("Text.mark_set() missing 2 required positional arguments: 'markName' and 'index'", -1)
        if args.Length = 1
            throw TypeError("Text.mark_set() missing 1 required positional argument: 'index'", -1)
        if args.Length > 2
            throw TypeError("Text.mark_set() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " mark set", args))
        return stdlib.None
    }

    mark_unset(args*)
    {
        if args.Length = 0
            return stdlib.None
        this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " mark unset", args))
        return stdlib.None
    }

    mark_gravity(args*)
    {
        if args.Length = 0
            throw TypeError("Text.mark_gravity() missing 1 required positional argument: 'markName'", -1)
        if args.Length > 2
            throw TypeError("Text.mark_gravity() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " mark gravity", args))
    }

    mark_names(args*)
    {
        if args.Length != 0
            throw TypeError("Text.mark_names() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(this._w " mark names")))
    }

    mark_next(args*)
    {
        if args.Length = 0
            throw TypeError("Text.mark_next() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Text.mark_next() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        value := this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " mark next", args))
        return value = "" ? stdlib.None : value
    }

    mark_previous(args*)
    {
        if args.Length = 0
            throw TypeError("Text.mark_previous() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Text.mark_previous() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        value := this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " mark previous", args))
        return value = "" ? stdlib.None : value
    }

    tag_add(args*)
    {
        if args.Length = 0
            throw TypeError("Text.tag_add() missing 2 required positional arguments: 'tagName' and 'index1'", -1)
        if args.Length = 1
            throw TypeError("Text.tag_add() missing 1 required positional argument: 'index1'", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " tag add", args))
        return stdlib.None
    }

    tag_cget(args*)
    {
        if args.Length = 0
            throw TypeError("Text.tag_cget() missing 2 required positional arguments: 'tagName' and 'option'", -1)
        if args.Length = 1
            throw TypeError("Text.tag_cget() missing 1 required positional argument: 'option'", -1)
        if args.Length > 2
            throw TypeError("Text.tag_cget() takes 3 positional arguments but " args.Length + 1 " were given", -1)

        optionName := AhkStdlibTkinterTagOptionName(args[2])
        return this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " tag cget", [args[1], "-" optionName]))
    }

    tag_configure(args*)
    {
        if args.Length = 0
            throw TypeError("Text.tag_configure() missing 1 required positional argument: 'tagName'", -1)
        if args.Length > 2
            throw TypeError("Text.tag_configure() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

        if args.Length = 1 || AhkStdlibIsNone(args[2])
            return AhkStdlibTkinterTextTagConfigureDict(this.AhkStdlibRoot, this._w, args[1])
        if args[2] is String
            return AhkStdlibTkinterTextTagConfigureOption(this.AhkStdlibRoot, this._w, args[1], args[2])
        if !AhkStdlibTkinterIsPlainKeywordObject(args[2])
            throw TypeError("object of type '" AhkStdlibPyTypeName(args[2]) "' has no len()", -1)

        script := AhkStdlibTkinterTextScript(this._w " tag configure", [args[1]])
        if !AhkStdlibIsNone(args[1])
            script .= AhkStdlibTkinterOptionsToScriptSkipNone(args[2], false, this.AhkStdlibRoot)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    tag_config(args*)
    {
        return this.tag_configure(args*)
    }

    tag_bind(args*)
    {
        if args.Length = 0
            throw TypeError("Text.tag_bind() missing 3 required positional arguments: 'tagName', 'sequence', and 'func'", -1)
        if args.Length = 1
            throw TypeError("Text.tag_bind() missing 2 required positional arguments: 'sequence' and 'func'", -1)
        if args.Length = 2
            throw TypeError("Text.tag_bind() missing 1 required positional argument: 'func'", -1)
        if args.Length > 4
            throw TypeError("Text.tag_bind() takes from 4 to 5 positional arguments but " args.Length + 1 " were given", -1)

        tagWord := AhkStdlibTkinterTextValueWord(args[1])
        sequence := args[2]
        func := args[3]
        if !AhkStdlibTruthValue(func) {
            if AhkStdlibTruthValue(sequence) {
                script := AhkStdlibTkinterTextScript(this._w " tag bind", [args[1], sequence])
                return this.AhkStdlibRoot.eval(script)
            }
            return stdlib.tuple(AhkStdlibTkinterSimpleList(this.AhkStdlibRoot.eval(this._w " tag bind " tagWord)))
        }

        if func is String {
            script := AhkStdlibTkinterTextScript(this._w " tag bind", [args[1], sequence])
            script .= " " AhkStdlibTkinterTclScriptWord(func)
            this.AhkStdlibRoot.eval(script)
            return stdlib.None
        }

        commandName := AhkStdlibTkinterRegisterEventCommand(this.AhkStdlibRoot, this, func, sequence)
        addPrefix := args.Length >= 4 && args[4] = "+" ? "+" : ""
        script := addPrefix "if {`"[" commandName " %W %T %x %y %b]`" == `"break`"} break"
        bindScript := AhkStdlibTkinterTextScript(this._w " tag bind", [args[1], sequence])
        bindScript .= " " AhkStdlibTkinterTclScriptWord(script)
        this.AhkStdlibRoot.eval(bindScript)
        return commandName
    }

    tag_unbind(args*)
    {
        if args.Length = 0
            throw TypeError("Text.tag_unbind() missing 2 required positional arguments: 'tagName' and 'sequence'", -1)
        if args.Length = 1
            throw TypeError("Text.tag_unbind() missing 1 required positional argument: 'sequence'", -1)
        if args.Length > 3
            throw TypeError("Text.tag_unbind() takes from 3 to 4 positional arguments but " args.Length + 1 " were given", -1)

        script := AhkStdlibTkinterTextScript(this._w " tag bind", [args[1], args[2]])
        if !AhkStdlibIsNone(args[1]) && !AhkStdlibIsNone(args[2])
            script .= " {}"
        this.AhkStdlibRoot.eval(script)
        if args.Length = 3 && AhkStdlibTruthValue(args[3])
            AhkStdlibTkinterDeleteCommand(this.AhkStdlibRoot, args[3], "can't delete Tcl command")
        return stdlib.None
    }

    image_create(args*)
    {
        if args.Length = 0
            throw TypeError("Text.image_create() missing 1 required positional argument: 'index'", -1)
        if args.Length > 2
            throw TypeError("Text.image_create() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

        script := AhkStdlibTkinterTextScript(this._w " image create", [args[1]])
        if args.Length = 2 && !AhkStdlibIsNone(args[2]) {
            if !AhkStdlibTkinterIsPlainKeywordObject(args[2])
                throw TypeError("object of type '" AhkStdlibPyTypeName(args[2]) "' has no len()", -1)
            if !AhkStdlibIsNone(args[1])
            script .= AhkStdlibTkinterOptionsToScriptSkipNone(args[2], false, this.AhkStdlibRoot)
        }
        return this.AhkStdlibRoot.eval(script)
    }

    image_names(args*)
    {
        if args.Length != 0
            throw TypeError("Text.image_names() takes 1 positional argument but " args.Length + 1 " were given", -1)
        raw := this.AhkStdlibRoot.eval(this._w " image names")
        if raw = ""
            return ""
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, raw))
    }

    image_cget(args*)
    {
        if args.Length = 0
            throw TypeError("Text.image_cget() missing 2 required positional arguments: 'index' and 'option'", -1)
        if args.Length = 1
            throw TypeError("Text.image_cget() missing 1 required positional argument: 'option'", -1)
        if args.Length > 2
            throw TypeError("Text.image_cget() takes 3 positional arguments but " args.Length + 1 " were given", -1)

        optionName := AhkStdlibTkinterTextImageOptionName(args[2])
        value := this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " image cget", [args[1], "-" optionName]))
        return AhkStdlibTkinterCgetValue(optionName, value)
    }

    image_configure(args*)
    {
        if args.Length = 0
            throw TypeError("Text.image_configure() missing 1 required positional argument: 'index'", -1)
        if args.Length > 2
            throw TypeError("Text.image_configure() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

        if args.Length = 1 || AhkStdlibIsNone(args[2])
            return AhkStdlibTkinterTextImageConfigureDict(this.AhkStdlibRoot, this._w, args[1])
        if args[2] is String
            return AhkStdlibTkinterTextImageConfigureOption(this.AhkStdlibRoot, this._w, args[1], args[2])
        if !AhkStdlibTkinterIsPlainKeywordObject(args[2])
            throw TypeError("object of type '" AhkStdlibPyTypeName(args[2]) "' has no len()", -1)

        script := AhkStdlibTkinterTextScript(this._w " image configure", [args[1]])
        if !AhkStdlibIsNone(args[1])
            script .= AhkStdlibTkinterOptionsToScriptSkipNone(args[2], false, this.AhkStdlibRoot)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    window_create(args*)
    {
        if args.Length = 0
            throw TypeError("Text.window_create() missing 1 required positional argument: 'index'", -1)
        if args.Length > 2
            throw TypeError("Text.window_create() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

        script := AhkStdlibTkinterTextScript(this._w " window create", [args[1]])
        if args.Length = 2 && !AhkStdlibIsNone(args[2]) {
            if !AhkStdlibTkinterIsPlainKeywordObject(args[2])
                throw TypeError("object of type '" AhkStdlibPyTypeName(args[2]) "' has no len()", -1)
            if !AhkStdlibIsNone(args[1])
                script .= AhkStdlibTkinterOptionsToScriptSkipNone(args[2], false, this.AhkStdlibRoot)
        }
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    window_names(args*)
    {
        if args.Length != 0
            throw TypeError("Text.window_names() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(this._w " window names")))
    }

    window_cget(args*)
    {
        if args.Length = 0
            throw TypeError("Text.window_cget() missing 2 required positional arguments: 'index' and 'option'", -1)
        if args.Length = 1
            throw TypeError("Text.window_cget() missing 1 required positional argument: 'option'", -1)
        if args.Length > 2
            throw TypeError("Text.window_cget() takes 3 positional arguments but " args.Length + 1 " were given", -1)

        optionName := AhkStdlibTkinterTextWindowOptionName(args[2])
        value := this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " window cget", [args[1], "-" optionName]))
        return AhkStdlibTkinterCgetValue(optionName, value)
    }

    window_configure(args*)
    {
        if args.Length = 0
            throw TypeError("Text.window_configure() missing 1 required positional argument: 'index'", -1)
        if args.Length > 2
            throw TypeError("Text.window_configure() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)

        if args.Length = 1 || AhkStdlibIsNone(args[2])
            return AhkStdlibTkinterTextWindowConfigureDict(this.AhkStdlibRoot, this._w, args[1])
        if args[2] is String
            return AhkStdlibTkinterTextWindowConfigureOption(this.AhkStdlibRoot, this._w, args[1], args[2])
        if !AhkStdlibTkinterIsPlainKeywordObject(args[2])
            throw TypeError("object of type '" AhkStdlibPyTypeName(args[2]) "' has no len()", -1)

        script := AhkStdlibTkinterTextScript(this._w " window configure", [args[1]])
        if !AhkStdlibIsNone(args[1])
            script .= AhkStdlibTkinterOptionsToScriptSkipNone(args[2], false, this.AhkStdlibRoot)
        this.AhkStdlibRoot.eval(script)
        return stdlib.None
    }

    window_config(args*)
    {
        return this.window_configure(args*)
    }

    tag_remove(args*)
    {
        if args.Length = 0
            throw TypeError("Text.tag_remove() missing 2 required positional arguments: 'tagName' and 'index1'", -1)
        if args.Length = 1
            throw TypeError("Text.tag_remove() missing 1 required positional argument: 'index1'", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " tag remove", args))
        return stdlib.None
    }

    tag_ranges(args*)
    {
        if args.Length = 0
            throw TypeError("Text.tag_ranges() missing 1 required positional argument: 'tagName'", -1)
        if args.Length > 1
            throw TypeError("Text.tag_ranges() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " tag ranges", args))))
    }

    tag_names(args*)
    {
        if args.Length > 1
            throw TypeError("Text.tag_names() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " tag names"
        if args.Length = 1
            script := AhkStdlibTkinterTextScript(script, args)
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(script)))
    }

    tag_nextrange(args*)
    {
        if args.Length = 0
            throw TypeError("Text.tag_nextrange() missing 2 required positional arguments: 'tagName' and 'index1'", -1)
        if args.Length = 1
            throw TypeError("Text.tag_nextrange() missing 1 required positional argument: 'index1'", -1)
        if args.Length > 3
            throw TypeError("Text.tag_nextrange() takes from 3 to 4 positional arguments but " args.Length + 1 " were given", -1)
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " tag nextrange", args))))
    }

    tag_prevrange(args*)
    {
        if args.Length = 0
            throw TypeError("Text.tag_prevrange() missing 2 required positional arguments: 'tagName' and 'index1'", -1)
        if args.Length = 1
            throw TypeError("Text.tag_prevrange() missing 1 required positional argument: 'index1'", -1)
        if args.Length > 3
            throw TypeError("Text.tag_prevrange() takes from 3 to 4 positional arguments but " args.Length + 1 " were given", -1)
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " tag prevrange", args))))
    }

    tag_raise(args*)
    {
        if args.Length = 0
            throw TypeError("Text.tag_raise() missing 1 required positional argument: 'tagName'", -1)
        if args.Length > 2
            throw TypeError("Text.tag_raise() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " tag raise", args))
        return stdlib.None
    }

    tag_lower(args*)
    {
        if args.Length = 0
            throw TypeError("Text.tag_lower() missing 1 required positional argument: 'tagName'", -1)
        if args.Length > 2
            throw TypeError("Text.tag_lower() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " tag lower", args))
        return stdlib.None
    }

    tag_delete(args*)
    {
        if args.Length = 0
            return stdlib.None
        this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " tag delete", args))
        return stdlib.None
    }

    bbox(args*)
    {
        if args.Length = 0
            throw TypeError("Text.bbox() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Text.bbox() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        value := this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " bbox", args))
        return value = "" ? stdlib.None : AhkStdlibTkinterIntegerTuple(value)
    }

    dlineinfo(args*)
    {
        if args.Length = 0
            throw TypeError("Text.dlineinfo() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Text.dlineinfo() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        value := this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " dlineinfo", args))
        return value = "" ? stdlib.None : AhkStdlibTkinterIntegerTuple(value)
    }

    see(args*)
    {
        if args.Length = 0
            throw TypeError("Text.see() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Text.see() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " see", args))
        return stdlib.None
    }

    scan_mark(args*)
    {
        if args.Length = 0
            throw TypeError("Text.scan_mark() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("Text.scan_mark() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("Text.scan_mark() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterScanScript(this._w " scan mark", args))
        return stdlib.None
    }

    scan_dragto(args*)
    {
        if args.Length = 0
            throw TypeError("Text.scan_dragto() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("Text.scan_dragto() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("Text.scan_dragto() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterScanScript(this._w " scan dragto", args))
        return stdlib.None
    }

    xview(args*)
    {
        script := AhkStdlibTkinterViewScript(this._w " xview", args)
        value := this.AhkStdlibRoot.eval(script)
        return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
    }

    xview_moveto(args*)
    {
        if args.Length = 0
            throw TypeError("XView.xview_moveto() missing 1 required positional argument: 'fraction'", -1)
        if args.Length > 1
            throw TypeError("XView.xview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " xview moveto"
        if !AhkStdlibIsNone(args[1])
            script .= " " AhkStdlibTkinterViewValueWord(args[1])
        this.AhkStdlibRoot.eval(script)
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterViewScript(this._w " xview scroll", args))
        return stdlib.None
    }

    yview(args*)
    {
        script := AhkStdlibTkinterViewScript(this._w " yview", args)
        value := this.AhkStdlibRoot.eval(script)
        return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
    }

    yview_moveto(args*)
    {
        if args.Length = 0
            throw TypeError("YView.yview_moveto() missing 1 required positional argument: 'fraction'", -1)
        if args.Length > 1
            throw TypeError("YView.yview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " yview moveto"
        if !AhkStdlibIsNone(args[1])
            script .= " " AhkStdlibTkinterViewValueWord(args[1])
        this.AhkStdlibRoot.eval(script)
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterViewScript(this._w " yview scroll", args))
        return stdlib.None
    }

    yview_pickplace(args*)
    {
        this.AhkStdlibRoot.eval(AhkStdlibTkinterTextScript(this._w " yview -pickplace", args))
        return stdlib.None
    }
}

class AhkStdlibTkinterEntry extends AhkStdlibTkinterWidget
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterEntryScript(this._w " insert", args))
        return stdlib.None
    }

    delete(args*)
    {
        if args.Length = 0
            throw TypeError("Entry.delete() missing 1 required positional argument: 'first'", -1)
        if args.Length > 2
            throw TypeError("Entry.delete() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterEntryScript(this._w " delete", args))
        return stdlib.None
    }

    icursor(args*)
    {
        if args.Length = 0
            throw TypeError("Entry.icursor() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Entry.icursor() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterEntryScript(this._w " icursor", args))
        return stdlib.None
    }

    index(args*)
    {
        if args.Length = 0
            throw TypeError("Entry.index() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Entry.index() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval(AhkStdlibTkinterEntryScript(this._w " index", args)))
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

    scan_mark(args*)
    {
        if args.Length = 0
            throw TypeError("Entry.scan_mark() missing 1 required positional argument: 'x'", -1)
        if args.Length > 1
            throw TypeError("Entry.scan_mark() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterScanScript(this._w " scan mark", args))
        return stdlib.None
    }

    scan_dragto(args*)
    {
        if args.Length = 0
            throw TypeError("Entry.scan_dragto() missing 1 required positional argument: 'x'", -1)
        if args.Length > 1
            throw TypeError("Entry.scan_dragto() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterScanScript(this._w " scan dragto", args))
        return stdlib.None
    }

    xview(args*)
    {
        script := AhkStdlibTkinterViewScript(this._w " xview", args)
        value := this.AhkStdlibRoot.eval(script)
        return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
    }

    xview_moveto(args*)
    {
        if args.Length = 0
            throw TypeError("XView.xview_moveto() missing 1 required positional argument: 'fraction'", -1)
        if args.Length > 1
            throw TypeError("XView.xview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " xview moveto"
        if !AhkStdlibIsNone(args[1])
            script .= " " AhkStdlibTkinterViewValueWord(args[1])
        this.AhkStdlibRoot.eval(script)
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterViewScript(this._w " xview scroll", args))
        return stdlib.None
    }
}

class AhkStdlibTkinterSpinbox extends AhkStdlibTkinterWidget
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
        return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(AhkStdlibTkinterEntryScript(this._w " bbox", args)))
    }

    delete(args*)
    {
        if args.Length = 0
            throw TypeError("Spinbox.delete() missing 1 required positional argument: 'first'", -1)
        if args.Length > 2
            throw TypeError("Spinbox.delete() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterEntryScript(this._w " delete", args))
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterEntryScript(this._w " icursor", args))
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
        return this.AhkStdlibRoot.eval(AhkStdlibTkinterEntryScript(this._w " identify", args))
    }

    index(args*)
    {
        if args.Length = 0
            throw TypeError("Spinbox.index() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Spinbox.index() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval(AhkStdlibTkinterEntryScript(this._w " index", args)))
    }

    insert(args*)
    {
        if args.Length = 0
            throw TypeError("Spinbox.insert() missing 2 required positional arguments: 'index' and 's'", -1)
        if args.Length = 1
            throw TypeError("Spinbox.insert() missing 1 required positional argument: 's'", -1)
        if args.Length > 2
            throw TypeError("Spinbox.insert() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterEntryScript(this._w " insert", args))
        return stdlib.None
    }

    invoke(args*)
    {
        if args.Length = 0
            throw TypeError("Spinbox.invoke() missing 1 required positional argument: 'element'", -1)
        if args.Length > 1
            throw TypeError("Spinbox.invoke() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterEntryScript(this._w " invoke", args))
        return stdlib.None
    }

    scan(args*)
    {
        script := this._w " scan"
        script := AhkStdlibTkinterScanScript(script, args)
        return AhkStdlibTkinterIntegerTuple(this.AhkStdlibRoot.eval(script))
    }

    scan_mark(args*)
    {
        if args.Length = 0
            throw TypeError("Spinbox.scan_mark() missing 1 required positional argument: 'x'", -1)
        if args.Length > 1
            throw TypeError("Spinbox.scan_mark() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.scan("mark", args[1])
    }

    scan_dragto(args*)
    {
        if args.Length = 0
            throw TypeError("Spinbox.scan_dragto() missing 1 required positional argument: 'x'", -1)
        if args.Length > 1
            throw TypeError("Spinbox.scan_dragto() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.scan("dragto", args[1])
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterEntryScript(this._w " selection element", args))
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
        script := AhkStdlibTkinterViewScript(this._w " xview", args)
        value := this.AhkStdlibRoot.eval(script)
        return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
    }

    xview_moveto(args*)
    {
        if args.Length = 0
            throw TypeError("XView.xview_moveto() missing 1 required positional argument: 'fraction'", -1)
        if args.Length > 1
            throw TypeError("XView.xview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " xview moveto"
        if !AhkStdlibIsNone(args[1])
            script .= " " AhkStdlibTkinterViewValueWord(args[1])
        this.AhkStdlibRoot.eval(script)
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterViewScript(this._w " xview scroll", args))
        return stdlib.None
    }
}

class AhkStdlibTkinterListbox extends AhkStdlibTkinterWidget
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterListboxScript(this._w " delete", args))
        return stdlib.None
    }

    get(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.get() missing 1 required positional argument: 'first'", -1)
        if args.Length > 2
            throw TypeError("Listbox.get() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        script := AhkStdlibTkinterListboxScript(this._w " get", args)
        if AhkStdlibTkinterEffectiveTclArgCount(args) <= 1
            return this.AhkStdlibRoot.eval(script)
        return stdlib.tuple(AhkStdlibTkinterSplitList(this.AhkStdlibRoot.AhkStdlibInterp, this.AhkStdlibRoot.eval(script)))
    }

    index(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.index() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Listbox.index() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        value := this.AhkStdlibRoot.eval(AhkStdlibTkinterListboxScript(this._w " index", args))
        if value = "none"
            return stdlib.None
        return Integer(value)
    }

    activate(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.activate() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Listbox.activate() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterListboxScript(this._w " activate", args))
        return stdlib.None
    }

    bbox(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.bbox() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Listbox.bbox() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        value := this.AhkStdlibRoot.eval(AhkStdlibTkinterListboxScript(this._w " bbox", args))
        return value = "" ? stdlib.None : AhkStdlibTkinterIntegerTuple(value)
    }

    insert(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.insert() missing 1 required positional argument: 'index'", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterListboxScript(this._w " insert", args))
        return stdlib.None
    }

    selection_clear(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.selection_clear() missing 1 required positional argument: 'first'", -1)
        if args.Length > 2
            throw TypeError("Listbox.selection_clear() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterListboxScript(this._w " selection clear", args))
        return stdlib.None
    }

    selection_includes(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.selection_includes() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Listbox.selection_includes() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return this.AhkStdlibRoot.eval(AhkStdlibTkinterListboxScript(this._w " selection includes", args)) = "1" ? stdlib.True : stdlib.False
    }

    select_includes(args*)
    {
        return this.selection_includes(args*)
    }

    selection_anchor(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.selection_anchor() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Listbox.selection_anchor() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterListboxScript(this._w " selection anchor", args))
        return stdlib.None
    }

    select_anchor(args*)
    {
        return this.selection_anchor(args*)
    }

    selection_set(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.selection_set() missing 1 required positional argument: 'first'", -1)
        if args.Length > 2
            throw TypeError("Listbox.selection_set() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterListboxScript(this._w " selection set", args))
        return stdlib.None
    }

    select_set(args*)
    {
        return this.selection_set(args*)
    }

    select_clear(args*)
    {
        return this.selection_clear(args*)
    }

    size(args*)
    {
        if args.Length != 0
            throw TypeError("Listbox.size() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval(this._w " size"))
    }

    nearest(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.nearest() missing 1 required positional argument: 'y'", -1)
        if args.Length > 1
            throw TypeError("Listbox.nearest() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        return Integer(this.AhkStdlibRoot.eval(AhkStdlibTkinterListboxScript(this._w " nearest", args)))
    }

    see(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.see() missing 1 required positional argument: 'index'", -1)
        if args.Length > 1
            throw TypeError("Listbox.see() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterListboxScript(this._w " see", args))
        return stdlib.None
    }

    scan_mark(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.scan_mark() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("Listbox.scan_mark() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("Listbox.scan_mark() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterScanScript(this._w " scan mark", args))
        return stdlib.None
    }

    scan_dragto(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.scan_dragto() missing 2 required positional arguments: 'x' and 'y'", -1)
        if args.Length = 1
            throw TypeError("Listbox.scan_dragto() missing 1 required positional argument: 'y'", -1)
        if args.Length > 2
            throw TypeError("Listbox.scan_dragto() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        this.AhkStdlibRoot.eval(AhkStdlibTkinterScanScript(this._w " scan dragto", args))
        return stdlib.None
    }

    itemcget(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.itemcget() missing 2 required positional arguments: 'index' and 'option'", -1)
        if args.Length = 1
            throw TypeError("Listbox.itemcget() missing 1 required positional argument: 'option'", -1)
        if args.Length > 2
            throw TypeError("Listbox.itemcget() takes 3 positional arguments but " args.Length + 1 " were given", -1)
        option := AhkStdlibTkinterValueToString(args[2])
        if SubStr(option, 1, 1) = "-"
            option := SubStr(option, 2)
        script := AhkStdlibTkinterListboxScript(this._w " itemcget", [args[1]])
        if !AhkStdlibIsNone(args[1])
            script .= " -" option
        value := this.AhkStdlibRoot.eval(script)
        return AhkStdlibTkinterCgetValue(option, value)
    }

    itemconfigure(args*)
    {
        if args.Length = 0
            throw TypeError("Listbox.itemconfigure() missing 1 required positional argument: 'index'", -1)
        if args.Length > 2
            throw TypeError("Listbox.itemconfigure() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length = 1
            return AhkStdlibTkinterListboxItemConfigureDict(this.AhkStdlibRoot, this._w, args[1])
        if AhkStdlibTkinterIsPlainKeywordObject(args[2]) {
            this.AhkStdlibRoot.eval(AhkStdlibTkinterListboxScript(this._w " itemconfigure", [args[1]]) AhkStdlibTkinterOptionsToScriptSkipNone(args[2], false, this.AhkStdlibRoot))
            return stdlib.None
        }
        if args[2] is String
            return AhkStdlibTkinterListboxItemConfigureOption(this.AhkStdlibRoot, this._w, args[1], args[2])
        throw TypeError("object of type '" AhkStdlibPyTypeName(args[2]) "' has no len()", -1)
    }

    itemconfig(args*)
    {
        return this.itemconfigure(args*)
    }

    xview(args*)
    {
        script := AhkStdlibTkinterViewScript(this._w " xview", args)
        value := this.AhkStdlibRoot.eval(script)
        return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
    }

    xview_moveto(args*)
    {
        if args.Length = 0
            throw TypeError("XView.xview_moveto() missing 1 required positional argument: 'fraction'", -1)
        if args.Length > 1
            throw TypeError("XView.xview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " xview moveto"
        if !AhkStdlibIsNone(args[1])
            script .= " " AhkStdlibTkinterViewValueWord(args[1])
        this.AhkStdlibRoot.eval(script)
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterViewScript(this._w " xview scroll", args))
        return stdlib.None
    }

    yview(args*)
    {
        script := AhkStdlibTkinterViewScript(this._w " yview", args)
        value := this.AhkStdlibRoot.eval(script)
        return args.Length = 0 ? AhkStdlibTkinterFloatTuple(value) : stdlib.None
    }

    yview_moveto(args*)
    {
        if args.Length = 0
            throw TypeError("YView.yview_moveto() missing 1 required positional argument: 'fraction'", -1)
        if args.Length > 1
            throw TypeError("YView.yview_moveto() takes 2 positional arguments but " args.Length + 1 " were given", -1)
        script := this._w " yview moveto"
        if !AhkStdlibIsNone(args[1])
            script .= " " AhkStdlibTkinterViewValueWord(args[1])
        this.AhkStdlibRoot.eval(script)
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
        this.AhkStdlibRoot.eval(AhkStdlibTkinterViewScript(this._w " yview scroll", args))
        return stdlib.None
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
            master := AhkStdlibTkinterGetDefaultRoot("create variable")
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
AhkStdlibTkinterBindPublicClasses()
AhkStdlibTkinterTtkBindPublicClasses()

AhkStdlibTkinterBindPublicClasses()
{
    classMap := Map(
        "Event", AhkStdlibTkinterEvent,
        "EventType", AhkStdlibTkinterEventType,
        "CallWrapper", AhkStdlibTkinterCallWrapper,
        "Pack", AhkStdlibTkinterPack,
        "Place", AhkStdlibTkinterPlace,
        "Grid", AhkStdlibTkinterGrid,
        "XView", AhkStdlibTkinterXView,
        "YView", AhkStdlibTkinterYView,
        "Misc", AhkStdlibTkinterMisc,
        "Wm", AhkStdlibTkinterWm,
        "Tk", AhkStdlibTkinterTk,
        "Frame", AhkStdlibTkinterFrame,
        "Label", AhkStdlibTkinterLabel,
        "LabelFrame", AhkStdlibTkinterLabelFrame,
        "Toplevel", AhkStdlibTkinterToplevel,
        "Button", AhkStdlibTkinterButton,
        "Checkbutton", AhkStdlibTkinterCheckbutton,
        "Radiobutton", AhkStdlibTkinterRadiobutton,
        "Scale", AhkStdlibTkinterScale,
        "Scrollbar", AhkStdlibTkinterScrollbar,
        "Menu", AhkStdlibTkinterMenu,
        "Menubutton", AhkStdlibTkinterMenubutton,
        "Message", AhkStdlibTkinterMessage,
        "OptionMenu", AhkStdlibTkinterOptionMenu,
        "PanedWindow", AhkStdlibTkinterPanedWindow,
        "Canvas", AhkStdlibTkinterCanvas,
        "Entry", AhkStdlibTkinterEntry,
        "Spinbox", AhkStdlibTkinterSpinbox,
        "Listbox", AhkStdlibTkinterListbox,
        "Text", AhkStdlibTkinterText,
        "BaseWidget", AhkStdlibTkinterBaseWidget,
        "Widget", AhkStdlibTkinterPublicWidget,
        "Image", AhkStdlibTkinterPublicImage,
        "BitmapImage", AhkStdlibTkinterBitmapImage,
        "PhotoImage", AhkStdlibTkinterPhotoImage,
        "Variable", AhkStdlibTkinterPublicVariable,
        "StringVar", AhkStdlibTkinterStringVar,
        "IntVar", AhkStdlibTkinterIntVar,
        "DoubleVar", AhkStdlibTkinterDoubleVar,
        "BooleanVar", AhkStdlibTkinterBooleanVar
    )
    for publicName, classObject in classMap
        AhkStdlibTkinter.DefineProp(publicName, {
            Get: ((cls, *) => cls).Bind(classObject),
            Call: ((cls, this, args*) => cls(args*)).Bind(classObject)
        })
    AhkStdlibTkinter.DefineProp("Tk", {
        Get: ((cls, *) => cls).Bind(AhkStdlibTkinterTk),
        Call: AhkStdlibTkinterPublicTkCall.Bind(AhkStdlibTkinterTk)
    })
    AhkStdlibTkinter.DefineProp("Event", {
        Get: ((cls, *) => cls).Bind(AhkStdlibTkinterEvent),
        Call: AhkStdlibTkinterPublicEventCall.Bind(AhkStdlibTkinterEvent)
    })
    AhkStdlibTkinter.DefineProp("EventType", {
        Get: ((cls, *) => cls).Bind(AhkStdlibTkinterEventType),
        Call: AhkStdlibTkinterPublicEventTypeCall.Bind(AhkStdlibTkinterEventType)
    })
}

AhkStdlibTkinterPublicTkCall(cls, this, args*)
{
    if args.Length > 6
        throw TypeError("Tk.__init__() takes from 1 to 7 positional arguments but " args.Length + 1 " were given", -1)
    return cls(true, "Tk", args*)
}

AhkStdlibTkinterPublicEventCall(cls, this, args*)
{
    if args.Length != 0
        throw TypeError("Event() takes no arguments", -1)
    return cls()
}

AhkStdlibTkinterPublicEventTypeCall(cls, this, args*)
{
    if args.Length = 0
        throw TypeError("EnumMeta.__call__() missing 1 required positional argument: 'value'", -1)
    if args.Length > 1
        throw TypeError("Cannot extend enumerations", -1)
    return cls(args[1])
}

AhkStdlibTkinterTtkBindPublicClasses()
{
    classMap := Map(
        "Widget", AhkStdlibTkinterTtk.AhkStdlibTkinterTtkWidget,
        "Combobox", AhkStdlibTkinterTtk.AhkStdlibTkinterCombobox,
        "Entry", AhkStdlibTkinterTtk.AhkStdlibTkinterEntry,
        "Frame", AhkStdlibTkinterTtk.AhkStdlibTkinterFrame,
        "Label", AhkStdlibTkinterTtk.AhkStdlibTkinterLabel,
        "Spinbox", AhkStdlibTkinterTtk.AhkStdlibTkinterSpinbox,
        "Menubutton", AhkStdlibTkinterTtk.AhkStdlibTkinterTtkMenubutton,
        "OptionMenu", AhkStdlibTkinterTtk.AhkStdlibTkinterTtkOptionMenu,
        "Button", AhkStdlibTkinterTtk.AhkStdlibTkinterButton,
        "Checkbutton", AhkStdlibTkinterTtk.AhkStdlibTkinterCheckbutton,
        "Radiobutton", AhkStdlibTkinterTtk.AhkStdlibTkinterRadiobutton,
        "Scale", AhkStdlibTkinterTtk.AhkStdlibTkinterScale,
        "LabeledScale", AhkStdlibTkinterTtk.AhkStdlibTkinterTtkLabeledScale,
        "Scrollbar", AhkStdlibTkinterTtk.AhkStdlibTkinterScrollbar,
        "Separator", AhkStdlibTkinterTtk.AhkStdlibTkinterSeparator,
        "Progressbar", AhkStdlibTkinterTtk.AhkStdlibTkinterProgressbar,
        "Notebook", AhkStdlibTkinterTtk.AhkStdlibTkinterNotebook,
        "Treeview", AhkStdlibTkinterTtk.AhkStdlibTkinterTreeview,
        "Style", AhkStdlibTkinterTtk.AhkStdlibTkinterStyle,
        "Panedwindow", AhkStdlibTkinterTtk.AhkStdlibTkinterPanedwindow,
        "Sizegrip", AhkStdlibTkinterTtk.AhkStdlibTkinterSizegrip,
        "LabelFrame", AhkStdlibTkinterTtk.AhkStdlibTkinterLabelFrame
    )
    for publicName, classObject in classMap
        AhkStdlibTkinterTtk.DefineProp(publicName, {
            Get: ((cls, *) => cls).Bind(classObject),
            Call: ((cls, this, args*) => cls(args*)).Bind(classObject)
        })
}

AhkStdlibTkinterIsPlainKeywordObject(value)
{
    return IsObject(value) && Type(value) = "Object"
}

AhkStdlibTkinterPublicWidgetNew(instance, className, args*)
{
    if args.Length = 0
        throw TypeError("BaseWidget.__init__() missing 2 required positional arguments: 'master' and 'widgetName'", -1)
    if args.Length = 1
        throw TypeError("BaseWidget.__init__() missing 1 required positional argument: 'widgetName'", -1)
    if args.Length > 5
        throw TypeError("BaseWidget.__init__() takes from 3 to 6 positional arguments but " args.Length + 1 " were given", -1)

    master := args[1]
    widgetName := args[2]
    cnf := {}
    kw := {}
    extra := []
    if args.Length >= 3 {
        if !AhkStdlibTkinterIsPlainKeywordObject(args[3])
            throw AttributeError("'" AhkStdlibPyTypeName(args[3]) "' object has no attribute 'items'", -1)
        cnf := args[3]
    }
    if args.Length >= 4 {
        if !AhkStdlibTkinterIsPlainKeywordObject(args[4]) {
            if args[4] is String
                throw ValueError("dictionary update sequence element #0 has length 1; 2 is required", -1)
            throw AttributeError("'" AhkStdlibPyTypeName(args[4]) "' object has no attribute 'items'", -1)
        }
        kw := args[4]
    }
    if args.Length >= 5
        extra := args[5]

    if !IsObject(master) || !HasProp(master, "tk")
        throw AttributeError("'" AhkStdlibPyTypeName(master) "' object has no attribute 'tk'", -1)

    options := AhkStdlibTkinterMergeKeywordObjects(cnf, kw)
    instance.master := master
    instance.tk := master.tk
    instance.AhkStdlibRoot := master._root()
    instance.widgetName := widgetName
    instance.AhkStdlibTkCommand := widgetName
    instance._w := AhkStdlibTkinterResolveWidgetPath(instance.AhkStdlibRoot, String(master), StrLower(className), options)

    script := AhkStdlibTkinterValueToString(widgetName) " " instance._w
    script .= AhkStdlibTkinterWidgetExtraToScript(extra)
    script .= AhkStdlibTkinterOptionsToScriptSkipNone(options, false, instance.AhkStdlibRoot)
    instance.AhkStdlibRoot.eval(script)
    instance.AhkStdlibRoot.AhkStdlibWidgetsByPath[instance._w] := instance
}

AhkStdlibTkinterMergeKeywordObjects(cnf, kw)
{
    options := {}
    for key, value in cnf.OwnProps()
        options.%key% := value
    for key, value in kw.OwnProps()
        options.%key% := value
    return options
}

AhkStdlibTkinterWidgetExtraToScript(extra)
{
    if extra is Array {
        script := ""
        for value in extra
            script .= " " AhkStdlibTkinterTclWord(value)
        return script
    }
    if extra is String
        throw TypeError("can only concatenate tuple (not " Chr(34) "str" Chr(34) ") to tuple", -1)
    return ""
}

AhkStdlibTkinterRegisterDefaultRoot(root)
{
    return AhkStdlibTkinterDefaultRootState("register", root)
}

AhkStdlibTkinterForgetDefaultRoot(root)
{
    return AhkStdlibTkinterDefaultRootState("forget", root)
}

AhkStdlibTkinterSetDefaultRootCloseProtocol(root)
{
    commandName := AhkStdlibTkinterRegisterCommand(root, (*) => root.destroy())
    root.eval("wm protocol . WM_DELETE_WINDOW " AhkStdlibTkinterTclWord(commandName))
    return stdlib.None
}

AhkStdlibTkinterIsApplicationDestroyedError(err)
{
    return (err is AhkStdlibTkinter.TclError) && InStr(err.Message, "application has been destroyed") > 0
}

AhkStdlibTkinterGetDefaultRoot(what)
{
    return AhkStdlibTkinterDefaultRootState("get", what)
}

AhkStdlibTkinterGetOrCreateDefaultRoot()
{
    try return AhkStdlibTkinterDefaultRootState("get", "create style")
    return AhkStdlibTkinterTk(true, "Tk")
}

AhkStdlibTkinterTtkSetupMasterDefaultRoot()
{
    try return AhkStdlibTkinterDefaultRootState("get", "create style")
    catch as err {
        if (err is RuntimeError) && err.Message = "No master specified and tkinter is configured to not support default root"
            throw
    }
    return AhkStdlibTkinterTk(true, "Tk")
}

AhkStdlibTkinterTtkTclobjsToPy(adict)
{
    if !(adict is Map)
        throw AttributeError("'" AhkStdlibPythonTypeName(adict) "' object has no attribute 'items'", -1)

    for key, value in adict
        adict[key] := AhkStdlibTkinterTtkTclobjToPy(value)
    return adict
}

AhkStdlibTkinterTtkTclobjToPy(value)
{
    if value is String
        return value
    if (value is Integer) || (value is Float) || AhkStdlibIsNone(value) || AhkStdlibIsBool(value)
        return value
    if IsObject(value) && HasMethod(value, "__Enum") {
        result := []
        for item in value
            result.Push(AhkStdlibTkinterTtkConvertStringValue(item))
        return result
    }
    return value
}

AhkStdlibTkinterTtkConvertStringValue(value)
{
    text := AhkStdlibTkinterTtkPythonStringValue(value)
    try {
        if RegExMatch(text, "^[+-]?\d+$")
            return Integer(text)
    }
    return text
}

AhkStdlibTkinterTtkPythonStringValue(value)
{
    if value is Array
        return AhkStdlibTkinterPythonTupleString(value)
    return AhkStdlibTkinterValueToString(value)
}

AhkStdlibTkinterPythonTupleString(values)
{
    text := "("
    for index, value in values {
        if index > 1
            text .= ", "
        text .= AhkStdlibTkinterExceptionArgRepr(value)
    }
    if values.Length = 1
        text .= ","
    return text ")"
}

AhkStdlibTkinterReadprofileTcl(root, name)
{
    home := EnvGet("HOME")
    if home = ""
        home := "."
    path := RTrim(home, "\/") "\." AhkStdlibTkinterValueToString(name) ".tcl"
    if FileExist(path)
        root.eval("source " AhkStdlibTkinterTclWord(path))
}

AhkStdlibTkinterCancelPendingThemeChanged(interp)
{
    script := "if {[info commands after] ne {}} {foreach id [after info] {if {[catch {after info $id} info] == 0 && [lindex $info 0] eq {ttk::ThemeChanged}} {after cancel $id}}}"
    DllCall("tcl86t\Tcl_Eval", "Ptr", interp, "Ptr", AhkStdlibTkinterUtf8Buffer(script).Ptr, "Int")
}

AhkStdlibTkinterSilenceDestroyBackgroundErrors(interp)
{
    script := "if {[info commands ahkstdlib_tkinter_bgerror] eq {} && [info commands bgerror] ne {}} {rename bgerror ahkstdlib_tkinter_bgerror}; proc bgerror {msg} {}"
    DllCall("tcl86t\Tcl_Eval", "Ptr", interp, "Ptr", AhkStdlibTkinterUtf8Buffer(script).Ptr, "Int")
}

AhkStdlibTkinterDefaultRootState(action, value := unset)
{
    static defaultRoot := stdlib.None
    static supportDefaultRoot := true

    switch action {
        case "disable":
            supportDefaultRoot := false
            defaultRoot := stdlib.None
            return stdlib.None
        case "register":
            if !supportDefaultRoot
                return stdlib.None
            if AhkStdlibIsNone(defaultRoot)
                defaultRoot := value
            return stdlib.None
        case "forget":
            if IsObject(defaultRoot) && IsSet(value) && ObjPtr(defaultRoot) = ObjPtr(value)
                defaultRoot := stdlib.None
            return stdlib.None
        case "get":
            if !supportDefaultRoot
                throw RuntimeError("No master specified and tkinter is configured to not support default root", -1)
            if AhkStdlibIsNone(defaultRoot)
                throw RuntimeError("Too early to " value ": no default root window", -1)
            return defaultRoot
    }
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
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(interp))
}

AhkStdlibTkinterInitTk(interp)
{
    result := DllCall("tk86t\Tk_Init", "Ptr", interp, "Int")
    if result != 0
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(interp))
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
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(interp))
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

    childName := AhkStdlibTkinterWidgetChildName(tkCommand)
    key := parentPath "|" childName
    counter := root.AhkStdlibChildCounters.Has(key) ? root.AhkStdlibChildCounters[key] : 0
    index := counter + 1
    root.AhkStdlibChildCounters[key] := index
    name := "!" childName (index = 1 ? "" : index)
    return AhkStdlibTkinterJoinWidgetPath(parentPath, name)
}

AhkStdlibTkinterWidgetChildName(tkCommand)
{
    delimiter := InStr(tkCommand, "::", false, -1)
    if delimiter
        return SubStr(tkCommand, delimiter + 2)
    return tkCommand
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
        if current is AhkStdlibTkinterTk || current is AhkStdlibTkinterToplevel
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
        if AhkStdlibIsNone(value)
            continue
        if key = "displayof"
            hasDisplayof := true
        script .= " -" key " " AhkStdlibTkinterTclWord(value)
    }
    if includeDefaultDisplayof && !hasDisplayof
        script .= " -displayof " AhkStdlibTkinterTclWord(window)
    return script
}

AhkStdlibTkinterSelectionClear(root, args*)
{
    if args.Length != 0
        throw TypeError("Misc.selection_clear() takes 1 positional argument but " args.Length + 1 " were given", -1)
    root.eval("selection clear")
    return stdlib.None
}

AhkStdlibTkinterSelectionOwn(root, window, args*)
{
    if args.Length != 0
        throw TypeError("Misc.selection_own() takes 1 positional argument but " args.Length + 1 " were given", -1)
    root.eval("selection own " AhkStdlibTkinterTclWord(window))
    return stdlib.None
}

AhkStdlibTkinterSelectionOwnGet(root, args*)
{
    if args.Length != 0
        throw TypeError("Misc.selection_own_get() takes 1 positional argument but " args.Length + 1 " were given", -1)
    path := root.eval("selection own")
    if path = ""
        return stdlib.None
    return AhkStdlibTkinterWidgetFromPath(root, path)
}

AhkStdlibTkinterSelectionHandle(root, window, args*)
{
    if args.Length = 0
        throw TypeError("Misc.selection_handle() missing 1 required positional argument: 'command'", -1)
    if args.Length > 2 || (args.Length = 2 && !AhkStdlibTkinterIsPlainKeywordObject(args[2]))
        throw TypeError("Misc.selection_handle() takes 2 positional arguments but " args.Length + 1 " were given", -1)

    options := args.Length = 2 ? args[2] : {}
    commandName := AhkStdlibTkinterMaybeRegisterCommand(root, args[1])
    root.eval("selection handle" AhkStdlibTkinterOptionsToScriptSkipNone(options, false, root) " " AhkStdlibTkinterTclWord(window) " " AhkStdlibTkinterTclWord(commandName))
    return stdlib.None
}

AhkStdlibTkinterSend(root, args*)
{
    if args.Length = 0
        throw TypeError("Misc.send() missing 2 required positional arguments: 'interp' and 'cmd'", -1)
    if args.Length = 1
        throw TypeError("Misc.send() missing 1 required positional argument: 'cmd'", -1)

    script := "send"
    for value in args
        script .= " " AhkStdlibTkinterTclWord(value)
    return root.eval(script)
}

AhkStdlibTkinterOptionAdd(root, args*)
{
    if args.Length = 0
        throw TypeError("Misc.option_add() missing 2 required positional arguments: 'pattern' and 'value'", -1)
    if args.Length = 1
        throw TypeError("Misc.option_add() missing 1 required positional argument: 'value'", -1)
    if args.Length > 3
        throw TypeError("Misc.option_add() takes from 3 to 4 positional arguments but " args.Length + 1 " were given", -1)

    if AhkStdlibIsNone(args[1]) || AhkStdlibIsNone(args[2])
        throw AhkStdlibTkinter.TclError('wrong # args: should be "option add pattern value ?priority?"')

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
    if args.Length = 0 || AhkStdlibIsNone(args[1])
        return AhkStdlibTkinterIntegerTuple(root.eval(script))
    script .= " " AhkStdlibTkinterTclWord(args[1])
    if args.Length = 2 && !AhkStdlibIsNone(args[2])
        script .= " " AhkStdlibTkinterTclWord(args[2])
    return root.eval(script)
}

AhkStdlibTkinterWmAspect(root, window, args*)
{
    if args.Length > 4
        throw TypeError("Wm.wm_aspect() takes from 1 to 5 positional arguments but " args.Length + 1 " were given", -1)

    script := "wm aspect " window
    index := 1
    while index <= args.Length {
        if AhkStdlibIsNone(args[index])
            break
        script .= " " AhkStdlibTkinterTclWord(args[index])
        index += 1
    }
    value := root.eval(script)
    return value = "" ? stdlib.None : AhkStdlibTkinterIntegerTuple(value)
}

AhkStdlibTkinterWmGrid(root, window, args*)
{
    if args.Length > 4
        throw TypeError("Wm.wm_grid() takes from 1 to 5 positional arguments but " args.Length + 1 " were given", -1)

    script := "wm grid " window
    index := 1
    while index <= args.Length {
        if AhkStdlibIsNone(args[index])
            break
        script .= " " AhkStdlibTkinterTclWord(args[index])
        index += 1
    }
    value := root.eval(script)
    return value = "" ? stdlib.None : AhkStdlibTkinterIntegerTuple(value)
}

AhkStdlibTkinterWmGroup(root, window, args*)
{
    if args.Length > 1
        throw TypeError("Wm.wm_group() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
    script := "wm group " window
    if args.Length = 0 || AhkStdlibIsNone(args[1])
        return root.eval(script)
    return root.eval(script " " AhkStdlibTkinterTclWord(args[1]))
}

AhkStdlibTkinterWmCommand(root, window, args*)
{
    if args.Length > 1
        throw TypeError("Wm.wm_command() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
    script := "wm command " window
    if args.Length = 0 || AhkStdlibIsNone(args[1])
        return root.eval(script)
    return root.eval(script " " AhkStdlibTkinterWmCommandValue(args[1]))
}

AhkStdlibTkinterWmCommandValue(value)
{
    if value is Array
        return AhkStdlibTkinterTclListCommandWord(value)
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterWmAttributes(root, window, args*)
{
    script := "wm attributes " window
    for value in args
        script .= " " AhkStdlibTkinterTclWord(value)
    result := root.eval(script)
    if args.Length = 0
        return AhkStdlibTkinterWmAttributesTuple(root, result)
    if args.Length = 1
        return AhkStdlibTkinterWmAttributeValue(args[1], result)
    return result
}

AhkStdlibTkinterWmAttributesTuple(root, value)
{
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, value)
    result := []
    index := 1
    while index <= parts.Length {
        option := parts[index]
        result.Push(option)
        if index < parts.Length
            result.Push(AhkStdlibTkinterWmAttributeValue(option, parts[index + 1]))
        index += 2
    }
    return stdlib.tuple(result)
}

AhkStdlibTkinterWmAttributeValue(option, value)
{
    optionName := AhkStdlibTkinterValueToString(option)
    switch optionName {
        case "-alpha":
            return Float(value)
        case "-disabled", "-fullscreen", "-toolwindow", "-topmost":
            return Integer(value)
        default:
            return value
    }
}

AhkStdlibTkinterWmManage(root, args*)
{
    if args.Length = 0
        throw TypeError("Wm.wm_manage() missing 1 required positional argument: 'widget'", -1)
    if args.Length > 1
        throw TypeError("Wm.wm_manage() takes 2 positional arguments but " args.Length + 1 " were given", -1)
    root.eval("wm manage " AhkStdlibTkinterTclWord(args[1]))
    return stdlib.None
}

AhkStdlibTkinterWmForget(root, args*)
{
    if args.Length = 0
        throw TypeError("Wm.wm_forget() missing 1 required positional argument: 'window'", -1)
    if args.Length > 1
        throw TypeError("Wm.wm_forget() takes 2 positional arguments but " args.Length + 1 " were given", -1)
    root.eval("wm forget " AhkStdlibTkinterTclWord(args[1]))
    return stdlib.None
}

AhkStdlibTkinterWmColormapwindows(root, window, args*)
{
    script := "wm colormapwindows " window
    if args.Length = 0
        return AhkStdlibTkinterWidgetListFromPathList(root, root.eval(script))

    root.eval(script " " AhkStdlibTkinterWmColormapwindowsValue(args*))
    return stdlib.None
}

AhkStdlibTkinterWmColormapwindowsValue(args*)
{
    if args.Length = 1 {
        if AhkStdlibIsNone(args[1])
            return AhkStdlibTkinterTclWord("")
        if args[1] is Array
            return AhkStdlibTkinterTclListCommandWord(args[1])
        return AhkStdlibTkinterTclWord(args[1])
    }
    return AhkStdlibTkinterTclListCommandWord(args)
}

AhkStdlibTkinterWmIconposition(root, window, args*)
{
    if args.Length > 2
        throw TypeError("Wm.wm_iconposition() takes from 1 to 3 positional arguments but " args.Length + 1 " were given", -1)

    script := "wm iconposition " window
    if args.Length > 0 && !AhkStdlibIsNone(args[1]) {
        script .= " " AhkStdlibTkinterTclWord(args[1])
        if args.Length = 2 && !AhkStdlibIsNone(args[2])
            script .= " " AhkStdlibTkinterTclWord(args[2])
    }
    value := root.eval(script)
    return value = "" ? stdlib.None : AhkStdlibTkinterIntegerTuple(value)
}

AhkStdlibTkinterWmIconwindow(root, window, args*)
{
    if args.Length > 1
        throw TypeError("Wm.wm_iconwindow() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
    script := "wm iconwindow " window
    if args.Length = 0 || AhkStdlibIsNone(args[1])
        return root.eval(script)
    return root.eval(script " " AhkStdlibTkinterTclWord(args[1]))
}

AhkStdlibTkinterWmIconmask(root, window, args*)
{
    if args.Length > 1
        throw TypeError("Wm.wm_iconmask() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
    script := "wm iconmask " window
    if args.Length = 0 || AhkStdlibIsNone(args[1])
        return root.eval(script)
    return root.eval(script " " AhkStdlibTkinterTclWord(args[1]))
}

AhkStdlibTkinterWmIconbitmap(root, window, args*)
{
    if args.Length > 2
        throw TypeError("Wm.wm_iconbitmap() takes from 1 to 3 positional arguments but " args.Length + 1 " were given", -1)
    script := "wm iconbitmap " window
    if args.Length = 2 && AhkStdlibTruthValue(args[2])
        return root.eval(script " -default " AhkStdlibTkinterTclWord(args[2]))
    if args.Length = 0 || AhkStdlibIsNone(args[1])
        return root.eval(script)
    return root.eval(script " " AhkStdlibTkinterTclWord(args[1]))
}

AhkStdlibTkinterWmIconphoto(root, window, args*)
{
    script := "wm iconphoto " window
    if args.Length >= 1 && AhkStdlibTruthValue(args[1])
        script .= " -default"
    index := 2
    while index <= args.Length {
        if AhkStdlibIsNone(args[index])
            break
        script .= " " AhkStdlibTkinterWmIconphotoImageWord(args[index])
        index += 1
    }
    root.eval(script)
    return stdlib.None
}

AhkStdlibTkinterWmIconphotoImageWord(value)
{
    if value is Array
        return AhkStdlibTkinterTclListCommandWord(value)
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterWmSize(root, window, command, args*)
{
    if args.Length > 2
        throw TypeError("Wm.wm_" command "() takes from 1 to 3 positional arguments but " args.Length + 1 " were given", -1)
    script := "wm " command " " window
    if args.Length = 0 || AhkStdlibIsNone(args[1])
        return AhkStdlibTkinterIntegerTuple(root.eval(script))
    script .= " " AhkStdlibTkinterTclWord(args[1])
    if args.Length = 2 && !AhkStdlibIsNone(args[2])
        script .= " " AhkStdlibTkinterTclWord(args[2])
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

AhkStdlibTkinterGrabSetGlobal(root, window, args*)
{
    if args.Length != 0
        throw TypeError("Misc.grab_set_global() takes 1 positional argument but " args.Length + 1 " were given", -1)
    root.eval("grab set -global " window)
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
    if value is AhkStdlibTkinterTk
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

AhkStdlibTkinterFocusLastfor(root, window, args*)
{
    if args.Length != 0
        throw TypeError("Misc.focus_lastfor() takes 1 positional argument but " args.Length + 1 " were given", -1)
    lastWindow := root.eval("focus -lastfor " AhkStdlibTkinterTclWord(window))
    if lastWindow = ""
        return stdlib.None
    return AhkStdlibTkinterWidgetFromPath(root, lastWindow)
}

AhkStdlibTkinterFocusTraversal(root, window, methodName, args*)
{
    if args.Length != 0
        throw TypeError("Misc." methodName "() takes 1 positional argument but " args.Length + 1 " were given", -1)
    nextWindow := root.eval(methodName " " AhkStdlibTkinterTclWord(window))
    if nextWindow = ""
        return stdlib.None
    return AhkStdlibTkinterWidgetFromPath(root, nextWindow)
}

AhkStdlibTkinterFocusFollowsMouse(root, args*)
{
    if args.Length != 0
        throw TypeError("Misc.tk_focusFollowsMouse() takes 1 positional argument but " args.Length + 1 " were given", -1)
    root.eval("tk_focusFollowsMouse")
    return stdlib.None
}

AhkStdlibTkinterBell(root, window, args*)
{
    if args.Length > 1
        throw TypeError("Misc.bell() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
    root.eval("bell" AhkStdlibTkinterWinfoDisplayScript(window, args.Length = 1, args.Length = 1 ? args[1] : 0))
    return stdlib.None
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
    entry.AhkStdlibRoot.eval(AhkStdlibTkinterEntryScript(entry._w " selection " command, args))
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
    script := entry._w " selection range"
    if !AhkStdlibIsNone(args[1])
        script .= " " AhkStdlibTkinterTtkEntryIndexWord(args[1])
    if !AhkStdlibIsNone(args[2])
        script .= " " AhkStdlibTkinterTtkEntryIndexWord(args[2])
    entry.AhkStdlibRoot.eval(script)
    return stdlib.None
}

AhkStdlibTkinterEntryScript(baseScript, values)
{
    script := baseScript
    for value in values {
        if AhkStdlibIsNone(value)
            break
        script .= " " AhkStdlibTkinterTtkEntryIndexWord(value)
    }
    return script
}

AhkStdlibTkinterListboxScript(baseScript, values)
{
    script := baseScript
    for value in values {
        if AhkStdlibIsNone(value)
            break
        script .= " " AhkStdlibTkinterListboxValueWord(value)
    }
    return script
}

AhkStdlibTkinterListboxValueWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterMenuScript(baseScript, values)
{
    script := baseScript
    for value in values {
        if AhkStdlibIsNone(value)
            break
        script .= " " AhkStdlibTkinterMenuValueWord(value)
    }
    return script
}

AhkStdlibTkinterMenuValueWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterScaleScript(baseScript, values)
{
    script := baseScript
    for value in values {
        if AhkStdlibIsNone(value)
            break
        script .= " " AhkStdlibTkinterScaleValueWord(value)
    }
    return script
}

AhkStdlibTkinterScaleValueWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterScrollbarScript(baseScript, values)
{
    script := baseScript
    for value in values {
        if AhkStdlibIsNone(value)
            break
        script .= " " AhkStdlibTkinterScrollbarValueWord(value)
    }
    return script
}

AhkStdlibTkinterScrollbarValueWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterPhotoImageScript(baseScript, values)
{
    script := baseScript
    for value in values {
        if AhkStdlibIsNone(value)
            break
        script .= " " AhkStdlibTkinterPhotoImageValueWord(value)
    }
    return script
}

AhkStdlibTkinterPhotoImageTransformOptionScript(optionName, values)
{
    script := " " optionName
    for value in values {
        if AhkStdlibIsNone(value)
            continue
        script .= " " AhkStdlibTkinterPhotoImageValueWord(value)
    }
    return script
}

AhkStdlibTkinterPhotoImageValueWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterEffectiveTclArgCount(values)
{
    count := 0
    for value in values {
        if AhkStdlibIsNone(value)
            break
        count += 1
    }
    return count
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
        if AhkStdlibIsNone(value) {
            script .= " -" optionName
            continue
        }
        if IsSet(root)
            value := AhkStdlibTkinterMaybeRegisterCommand(root, value)
        optionValue := AhkStdlibTkinterOptionValueToScript(optionName, value)
        script .= " -" optionName " " optionValue
    }
    return script
}

AhkStdlibTkinterOptionsToScriptSkipNone(options, includeName, root := unset)
{
    script := ""
    for key, value in options.OwnProps() {
        if AhkStdlibIsNone(value)
            continue
        if key = "master"
            continue
        if key = "name" && !includeName
            continue
        optionName := key = "from_" ? "from" : key
        if IsSet(root)
            value := AhkStdlibTkinterMaybeRegisterCommand(root, value)
        optionValue := AhkStdlibTkinterOptionValueToScript(optionName, value)
        script .= " -" optionName " " optionValue
    }
    return script
}

AhkStdlibTkinterImageCreateRaiseCoveredNoneErrors(imageType, options)
{
    if imageType != "photo"
        return
    if options.HasOwnProp("width") && AhkStdlibIsNone(options.width)
        throw AhkStdlibTkinter.TclError('value for "-width" missing')
    if options.HasOwnProp("height") && AhkStdlibIsNone(options.height)
        throw AhkStdlibTkinter.TclError('value for "-height" missing')
}

AhkStdlibTkinterSingleNoneKeywordQueryOption(options)
{
    queryOption := unset
    queryCount := 0
    optionCount := 0
    for key, value in options.OwnProps() {
        if key = "master" || key = "name"
            continue
        optionCount += 1
        if AhkStdlibIsNone(value) {
            queryCount += 1
            queryOption := key
        }
    }
    if queryCount = 1 && optionCount = 1
        return Map("found", true, "option", queryOption)
    return Map("found", false, "option", "")
}

AhkStdlibTkinterOptionValueToScript(optionName, value)
{
    if optionName = "values" && IsObject(value) && HasMethod(value, "__Enum")
        return AhkStdlibTkinterTclListCommandWord(value)
    if optionName = "padding" && IsObject(value) && HasMethod(value, "__Enum")
        return AhkStdlibTkinterTclListCommandWord(value)
    if (optionName = "columns" || optionName = "displaycolumns" || optionName = "show" || optionName = "tags") && IsObject(value) && HasMethod(value, "__Enum")
        return AhkStdlibTkinterTclListCommandWord(value)
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return (optionName = "data" || optionName = "maskdata") ? AhkStdlibTkinterTclQuotedWord(value) : AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterMaybeRegisterCommand(root, value)
{
    if !IsObject(value) || !HasMethod(value, "Call")
        return value

    return AhkStdlibTkinterRegisterCommand(root, value)
}

AhkStdlibTkinterRegisterPublic(root, args*)
{
    if args.Length = 0
        throw TypeError("Misc._register() missing 1 required positional argument: 'func'", -1)
    if args.Length > 3
        throw TypeError("Misc._register() takes from 2 to 4 positional arguments but " args.Length + 1 " were given", -1)

    if args.Length >= 2 && !AhkStdlibIsNone(args[2])
        return AhkStdlibTkinterCreateCommand(root, { Kind: "Register", Callback: args[1], Subst: args[2] })
    return AhkStdlibTkinterCreateCommand(root, { Kind: "Register", Callback: args[1] })
}

AhkStdlibTkinterDeleteCommandPublic(root, args*)
{
    if args.Length = 0
        throw TypeError("Misc.deletecommand() missing 1 required positional argument: 'name'", -1)
    if args.Length > 1
        throw TypeError("Misc.deletecommand() takes 2 positional arguments but " args.Length + 1 " were given", -1)
    AhkStdlibTkinterDeleteCommand(root, args[1], "can't delete Tcl command")
    return stdlib.None
}

AhkStdlibTkinterCreateCommand(root, entry)
{
    entry := AhkStdlibTkinterRootedCommandEntry(root, entry)
    id := AhkStdlibTkinterRegisterCommandCallback(entry)
    commandName := "ahkstdlib_tkinter_command_" id
    nameBuffer := AhkStdlibTkinterUtf8Buffer(commandName)
    result := DllCall("tcl86t\Tcl_CreateCommand", "Ptr", root.AhkStdlibInterp, "Ptr", nameBuffer.Ptr, "Ptr", AhkStdlibTkinterCommandProcPtr(), "Ptr", id, "Ptr", 0, "Ptr")
    if !result
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(root.AhkStdlibInterp))
    root.AhkStdlibCommandCallbacks[commandName] := entry
    return commandName
}

AhkStdlibTkinterRegisterCommand(root, callback, callbackArgs := unset)
{
    if !IsObject(callback) || !HasMethod(callback, "Call")
        return callback

    entry := IsSet(callbackArgs) ? { Kind: "Command", Root: root, Callback: callback, Args: callbackArgs } : { Kind: "Command", Root: root, Callback: callback }
    id := AhkStdlibTkinterRegisterCommandCallback(entry)
    commandName := "ahkstdlib_tkinter_command_" id
    nameBuffer := AhkStdlibTkinterUtf8Buffer(commandName)
    result := DllCall("tcl86t\Tcl_CreateCommand", "Ptr", root.AhkStdlibInterp, "Ptr", nameBuffer.Ptr, "Ptr", AhkStdlibTkinterCommandProcPtr(), "Ptr", id, "Ptr", 0, "Ptr")
    if !result
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(root.AhkStdlibInterp))
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
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(root.AhkStdlibInterp))
    root.AhkStdlibCommandCallbacks[commandName] := entry
    return commandName
}

AhkStdlibTkinterRegisterTraceCommand(root, callback)
{
    entry := { Kind: "Command", Root: root, Callback: callback }
    id := AhkStdlibTkinterRegisterCommandCallback(entry)
    commandName := "ahkstdlib_tkinter_command_" id
    nameBuffer := AhkStdlibTkinterUtf8Buffer(commandName)
    result := DllCall("tcl86t\Tcl_CreateCommand", "Ptr", root.AhkStdlibInterp, "Ptr", nameBuffer.Ptr, "Ptr", AhkStdlibTkinterCommandProcPtr(), "Ptr", id, "Ptr", 0, "Ptr")
    if !result
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(root.AhkStdlibInterp))
    root.AhkStdlibCommandCallbacks[commandName] := entry
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
            throw AhkStdlibTkinter.TclError(missingMessage)
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
        if IsSet(entry) && AhkStdlibTkinterReportCommandException(entry, err) {
            AhkStdlibTkinterSetResult(interp, "None")
            return 0
        }
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
        return entry.Callback.Call(AhkStdlibTkinterEvent(eventWidget, args, entry.Sequence))
    }
    if IsObject(entry) && entry.HasOwnProp("Kind") && entry.Kind = "Register" {
        callbackArgs := args
        if entry.HasOwnProp("Subst") {
            transformed := entry.Subst.Call(args*)
            callbackArgs := transformed is Array ? transformed : [transformed]
        }
        return entry.Callback.Call(callbackArgs*)
    }
    if IsObject(entry) && entry.HasOwnProp("Kind") && entry.Kind = "Command" {
        if entry.HasOwnProp("Args")
            return entry.Callback.Call(entry.Args*)
        return entry.Callback.Call(args*)
    }
    if IsObject(entry) && entry.HasOwnProp("Callback")
        return entry.Callback.Call(entry.Args*)
    return entry.Call(args*)
}

AhkStdlibTkinterRootedCommandEntry(root, entry)
{
    if IsObject(entry) {
        if !entry.HasOwnProp("Root")
            entry.Root := root
        return entry
    }
    return { Kind: "Command", Root: root, Callback: entry }
}

AhkStdlibTkinterReportCommandException(entry, err)
{
    if !IsObject(entry) || !entry.HasOwnProp("Root")
        return false
    entry.Root.report_callback_exception(Type(err), err, err.Stack)
    return true
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
        script .= AhkStdlibTkinterOptionsToScriptSkipNone(options, false, canvas.AhkStdlibRoot)
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

AhkStdlibTkinterCgetValue(key, value, root := unset)
{
    optionName := AhkStdlibTkinterWidgetOptionName(key)
    switch optionName {
        case "values":
            if IsSet(root) && value != ""
                return stdlib.tuple(AhkStdlibTkinterSplitList(root.AhkStdlibInterp, value))
            return value
        case "padding":
            if IsSet(root) && value != ""
                return stdlib.tuple(AhkStdlibTkinterSplitList(root.AhkStdlibInterp, value))
            return value
        case "width", "height", "length", "tearoff", "aspect", "borderwidth", "bd", "highlightthickness", "indicatoron", "sashwidth", "showhandle", "minsize", "padx", "pady", "handlepad", "handlesize", "sashpad", "opaqueresize", "stretch", "takefocus":
            try return Integer(value)
        case "underline", "columnbreak", "hidemargin":
            try return Integer(value)
        case "from", "to", "resolution":
            try return Float(value)
    }
    return value
}

AhkStdlibTkinterIntOrFloatValue(value)
{
    if value is Integer || value is Float
        return value
    try {
        text := value ""
        if RegExMatch(text, "^[+-]?\d+$")
            return Integer(text)
        return Float(text)
    }
    return value
}

AhkStdlibTkinterWidgetOptionName(option)
{
    optionName := AhkStdlibTkinterValueToString(option)
    if SubStr(optionName, 1, 1) = "-"
        optionName := SubStr(optionName, 2)
    if SubStr(optionName, -1) = "_"
        optionName := SubStr(optionName, 1, StrLen(optionName) - 1)
    return optionName
}

AhkStdlibTkinterWidgetDashOption(option)
{
    if !(option is String)
        throw TypeError('can only concatenate str (not "' AhkStdlibTkinterSequenceAwareTypeName(option) '") to str', -1)
    return "-" option
}

AhkStdlibTkinterWidgetConfigureOption(root, window, option)
{
    optionWord := AhkStdlibTkinterTclWord(AhkStdlibTkinterWidgetDashOption(option))
    optionName := SubStr(option, 1, 1) = "-" ? SubStr(option, 2) : option
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, root.eval(window " configure " optionWord))
    return AhkStdlibTkinterWidgetConfigureTuple(optionName, parts, root)
}

AhkStdlibTkinterWidgetConfigureDict(root, window)
{
    result := Map()
    raw := root.eval(window " configure")
    for entryText in AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw) {
        parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, entryText)
        if parts.Length = 0
            continue
        optionName := parts[1]
        if SubStr(optionName, 1, 1) = "-"
            optionName := SubStr(optionName, 2)
        result[optionName] := AhkStdlibTkinterWidgetConfigureTuple(optionName, parts, root)
    }
    return result
}

AhkStdlibTkinterWidgetConfigureTuple(optionName, parts, root := unset)
{
    result := []
    for index, value in parts {
        if index = 1 && SubStr(value, 1, 1) = "-"
            value := SubStr(value, 2)
        else if index = parts.Length
            value := IsSet(root) ? AhkStdlibTkinterCgetValue(optionName, value, root) : AhkStdlibTkinterCgetValue(optionName, value)
        result.Push(value)
    }
    return stdlib.tuple(result)
}

AhkStdlibTkinterPaneChildPath(value)
{
    if IsObject(value) && HasProp(value, "_w")
        return value._w
    return AhkStdlibTkinterValueToString(value)
}

AhkStdlibTkinterPanedWindowScript(baseScript, values)
{
    script := baseScript
    for value in values {
        if AhkStdlibIsNone(value)
            break
        script .= " " AhkStdlibTkinterPanedWindowChildWord(value)
    }
    return script
}

AhkStdlibTkinterPanedWindowChildWord(value)
{
    if value is Array || value is AhkStdlibTuple {
        parts := []
        for item in value
            parts.Push(AhkStdlibTkinterPaneChildPath(item))
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(parts))
    }
    return AhkStdlibTkinterTclWord(AhkStdlibTkinterPaneChildPath(value))
}

AhkStdlibTkinterPanedWindowDashOption(option)
{
    if !(option is String)
        throw TypeError('can only concatenate str (not "' AhkStdlibTkinterSequenceAwareTypeName(option) '") to str', -1)
    return "-" option
}

AhkStdlibTkinterIntegerTupleOrEmpty(root, raw)
{
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw)
    if parts.Length = 0
        return stdlib.tuple()
    result := []
    for value in parts
        result.Push(Integer(value))
    return stdlib.tuple(result)
}

AhkStdlibTkinterTagOptionName(option)
{
    optionName := AhkStdlibTkinterValueToString(option)
    if SubStr(optionName, 1, 1) = "-"
        optionName := SubStr(optionName, 2)
    if SubStr(optionName, -1) = "_"
        optionName := SubStr(optionName, 1, StrLen(optionName) - 1)
    return optionName
}

AhkStdlibTkinterTextTagConfigureOption(root, window, tagName, option)
{
    optionName := AhkStdlibTkinterTagOptionName(option)
    script := AhkStdlibTkinterTextScript(window " tag configure", [tagName])
    if !AhkStdlibIsNone(tagName)
        script .= " -" optionName
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, root.eval(script))
    return AhkStdlibTkinterTextTagConfigureTuple(optionName, parts)
}

AhkStdlibTkinterTextTagConfigureDict(root, window, tagName)
{
    result := Map()
    raw := root.eval(AhkStdlibTkinterTextScript(window " tag configure", [tagName]))
    for entryText in AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw) {
        parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, entryText)
        if parts.Length = 0
            continue
        optionName := AhkStdlibTkinterTagOptionName(parts[1])
        result[optionName] := AhkStdlibTkinterTextTagConfigureTuple(optionName, parts)
    }
    return result
}

AhkStdlibTkinterTextTagConfigureTuple(optionName, parts)
{
    result := []
    for index, value in parts {
        if index = 1 && SubStr(value, 1, 1) = "-"
            value := SubStr(value, 2)
        result.Push(value)
    }
    return stdlib.tuple(result)
}

AhkStdlibTkinterTextImageOptionName(option)
{
    optionName := AhkStdlibTkinterValueToString(option)
    if SubStr(optionName, 1, 1) = "-"
        optionName := SubStr(optionName, 2)
    if SubStr(optionName, -1) = "_"
        optionName := SubStr(optionName, 1, StrLen(optionName) - 1)
    return optionName
}

AhkStdlibTkinterTextImageConfigureOption(root, window, index, option)
{
    optionName := AhkStdlibTkinterTextImageOptionName(option)
    script := AhkStdlibTkinterTextScript(window " image configure", [index])
    if !AhkStdlibIsNone(index)
        script .= " -" optionName
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, root.eval(script))
    return AhkStdlibTkinterTextImageConfigureTuple(optionName, parts)
}

AhkStdlibTkinterTextImageConfigureDict(root, window, index)
{
    result := Map()
    raw := root.eval(AhkStdlibTkinterTextScript(window " image configure", [index]))
    for entryText in AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw) {
        parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, entryText)
        if parts.Length = 0
            continue
        optionName := AhkStdlibTkinterTextImageOptionName(parts[1])
        result[optionName] := AhkStdlibTkinterTextImageConfigureTuple(optionName, parts)
    }
    return result
}

AhkStdlibTkinterTextImageConfigureTuple(optionName, parts)
{
    result := []
    for index, value in parts {
        if index = 1 && SubStr(value, 1, 1) = "-"
            value := SubStr(value, 2)
        else if index = parts.Length
            value := AhkStdlibTkinterCgetValue(optionName, value)
        result.Push(value)
    }
    return stdlib.tuple(result)
}

AhkStdlibTkinterTextWindowOptionName(option)
{
    optionName := AhkStdlibTkinterValueToString(option)
    if SubStr(optionName, 1, 1) = "-"
        optionName := SubStr(optionName, 2)
    if SubStr(optionName, -1) = "_"
        optionName := SubStr(optionName, 1, StrLen(optionName) - 1)
    return optionName
}

AhkStdlibTkinterTextWindowConfigureOption(root, window, index, option)
{
    optionName := AhkStdlibTkinterTextWindowOptionName(option)
    script := AhkStdlibTkinterTextScript(window " window configure", [index])
    if !AhkStdlibIsNone(index)
        script .= " -" optionName
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, root.eval(script))
    return AhkStdlibTkinterTextWindowConfigureTuple(optionName, parts)
}

AhkStdlibTkinterTextWindowConfigureDict(root, window, index)
{
    result := Map()
    raw := root.eval(AhkStdlibTkinterTextScript(window " window configure", [index]))
    for entryText in AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw) {
        parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, entryText)
        if parts.Length = 0
            continue
        optionName := AhkStdlibTkinterTextWindowOptionName(parts[1])
        result[optionName] := AhkStdlibTkinterTextWindowConfigureTuple(optionName, parts)
    }
    return result
}

AhkStdlibTkinterTextWindowConfigureTuple(optionName, parts)
{
    result := []
    for index, value in parts {
        if index = 1 && SubStr(value, 1, 1) = "-"
            value := SubStr(value, 2)
        else if index = parts.Length
            value := AhkStdlibTkinterCgetValue(optionName, value)
        result.Push(value)
    }
    return stdlib.tuple(result)
}

AhkStdlibTkinterListboxItemConfigureOption(root, window, index, option)
{
    optionName := AhkStdlibTkinterValueToString(option)
    if SubStr(optionName, 1, 1) = "-"
        optionName := SubStr(optionName, 2)
    script := AhkStdlibTkinterListboxScript(window " itemconfigure", [index])
    if !AhkStdlibIsNone(index)
        script .= " -" optionName
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, root.eval(script))
    return AhkStdlibTkinterListboxItemConfigureTuple(optionName, parts)
}

AhkStdlibTkinterListboxItemConfigureDict(root, window, index)
{
    result := Map()
    raw := root.eval(AhkStdlibTkinterListboxScript(window " itemconfigure", [index]))
    for entryText in AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw) {
        parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, entryText)
        if parts.Length = 0
            continue
        optionName := parts[1]
        if SubStr(optionName, 1, 1) = "-"
            optionName := SubStr(optionName, 2)
        result[optionName] := AhkStdlibTkinterListboxItemConfigureTuple(optionName, parts)
    }
    return result
}

AhkStdlibTkinterListboxItemConfigureTuple(optionName, parts)
{
    result := []
    for index, value in parts {
        if index = 1 && SubStr(value, 1, 1) = "-"
            value := SubStr(value, 2)
        else if index = parts.Length
            value := AhkStdlibTkinterCgetValue(optionName, value)
        result.Push(value)
    }
    return stdlib.tuple(result)
}

AhkStdlibTkinterMenuEntryConfigureOption(root, window, index, option)
{
    optionName := AhkStdlibTkinterValueToString(option)
    script := AhkStdlibTkinterMenuScript(window " entryconfigure", [index])
    if !AhkStdlibIsNone(index)
        script .= " -" optionName
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, root.eval(script))
    return AhkStdlibTkinterMenuEntryConfigureTuple(optionName, parts)
}

AhkStdlibTkinterMenuEntryConfigureDict(root, window, index)
{
    result := Map()
    raw := root.eval(AhkStdlibTkinterMenuScript(window " entryconfigure", [index]))
    for entryText in AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw) {
        parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, entryText)
        if parts.Length = 0
            continue
        optionName := parts[1]
        if SubStr(optionName, 1, 1) = "-"
            optionName := SubStr(optionName, 2)
        result[optionName] := AhkStdlibTkinterMenuEntryConfigureTuple(optionName, parts)
    }
    return result
}

AhkStdlibTkinterMenuEntryConfigureTuple(optionName, parts)
{
    result := []
    for index, value in parts {
        if index = 1 && SubStr(value, 1, 1) = "-"
            value := SubStr(value, 2)
        else if index >= 4
            value := AhkStdlibTkinterCgetValue(optionName, value)
        result.Push(value)
    }
    return stdlib.tuple(result)
}

AhkStdlibTkinterPaneConfigureOption(root, window, childPath, option, childPathIsWord := false)
{
    optionName := AhkStdlibTkinterValueToString(option)
    childWord := childPathIsWord ? childPath : AhkStdlibTkinterTclWord(childPath)
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, root.eval(window " paneconfigure " childWord " -" optionName))
    return AhkStdlibTkinterPaneConfigureTuple(optionName, parts)
}

AhkStdlibTkinterPaneConfigureDict(root, window, childPath, childPathIsWord := false)
{
    result := Map()
    childWord := childPathIsWord ? childPath : AhkStdlibTkinterTclWord(childPath)
    raw := root.eval(window " paneconfigure " childWord)
    for entryText in AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw) {
        parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, entryText)
        if parts.Length = 0
            continue
        optionName := parts[1]
        if SubStr(optionName, 1, 1) = "-"
            optionName := SubStr(optionName, 2)
        result[optionName] := AhkStdlibTkinterPaneConfigureTuple(optionName, parts)
    }
    return result
}

AhkStdlibTkinterPaneConfigureTuple(optionName, parts)
{
    result := []
    for index, value in parts {
        if index = 1 && SubStr(value, 1, 1) = "-"
            value := SubStr(value, 2)
        else if index = parts.Length
            value := AhkStdlibTkinterCgetValue(optionName, value)
        result.Push(value)
    }
    return stdlib.tuple(result)
}

AhkStdlibTkinterNotebookConfigureOption(root, window, option)
{
    optionWord := AhkStdlibTkinterTclWord(AhkStdlibTkinterWidgetDashOption(option))
    optionName := AhkStdlibTkinterWidgetOptionName(option)
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, root.eval(window " configure " optionWord))
    result := []
    for index, value in parts {
        if index = 1 && SubStr(value, 1, 1) = "-"
            value := SubStr(value, 2)
        else if optionName = "padding" && index = parts.Length
            value := value = "" ? "" : stdlib.tuple(AhkStdlibTkinterSplitList(root.AhkStdlibInterp, value))
        else if index = parts.Length
            value := AhkStdlibTkinterCgetValue(optionName, value, root)
        result.Push(value)
    }
    return stdlib.tuple(result)
}

AhkStdlibTkinterTtkNotebookTabWord(value)
{
    if value is Array || value is AhkStdlibTuple {
        parts := []
        for item in value
            parts.Push(AhkStdlibTkinterPaneChildPath(item))
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(parts))
    }
    return AhkStdlibTkinterTclWord(AhkStdlibTkinterPaneChildPath(value))
}

AhkStdlibTkinterTtkNotebookIndexWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterNotebookTabDict(root, script)
{
    result := Map()
    raw := root.eval(script)
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw)
    index := 1
    while index <= parts.Length {
        optionName := parts[index]
        if SubStr(optionName, 1, 1) = "-"
            optionName := SubStr(optionName, 2)
        value := index + 1 <= parts.Length ? parts[index + 1] : ""
        result[optionName] := AhkStdlibTkinterNotebookTabValue(root, optionName, value, true)
        index += 2
    }
    return result
}

AhkStdlibTkinterNotebookTabValue(root, optionName, value, asDict)
{
    optionName := AhkStdlibTkinterWidgetOptionName(optionName)
    switch optionName {
        case "padding":
            if value = ""
                return ""
            values := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, value)
            if !asDict
                return stdlib.tuple(values)
            result := []
            for item in values
                result.Push(AhkStdlibTkinterIntOrFloatValue(item))
            return result
        case "underline":
            try return Integer(value)
    }
    return AhkStdlibTkinterCgetValue(optionName, value, root)
}

AhkStdlibTkinterNotebookTabOptionName(option)
{
    if AhkStdlibIsBool(option)
        return option.Value ? "True" : "False"
    return AhkStdlibTkinterWidgetOptionName(option)
}

AhkStdlibTkinterTtkComboboxCurrentWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkComboboxSetValueWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclListCommandWord(value)
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkEntryIndexWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkEntryStringWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTtkSpinboxSetListWord(value)
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkScaleValueWord(value)
{
    return AhkStdlibTkinterTtkFloatValueWord(value)
}

AhkStdlibTkinterTtkSpinboxSetValueWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTtkSpinboxSetListWord(value)
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkSpinboxSetListWord(values)
{
    script := "[list"
    for value in values
        script .= " " AhkStdlibTkinterTtkSpinboxSetListItemWord(value)
    return script "]"
}

AhkStdlibTkinterTtkSpinboxSetListItemWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTtkSpinboxSetListWord(value)
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkProgressbarIntervalWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkFloatValueWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkInheritedCommandWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterViewScript(baseScript, values)
{
    script := baseScript
    for value in values {
        if AhkStdlibIsNone(value)
            break
        script .= " " AhkStdlibTkinterViewValueWord(value)
    }
    return script
}

AhkStdlibTkinterViewValueWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterScanScript(baseScript, values)
{
    script := baseScript
    for value in values {
        if AhkStdlibIsNone(value)
            break
        script .= " " AhkStdlibTkinterScanValueWord(value)
    }
    return script
}

AhkStdlibTkinterScanValueWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterCanvasScript(baseScript, values)
{
    script := baseScript
    for value in values {
        if AhkStdlibIsNone(value)
            break
        script .= " " AhkStdlibTkinterCanvasValueWord(value)
    }
    return script
}

AhkStdlibTkinterCanvasValueWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTextScript(baseScript, values)
{
    script := baseScript
    for value in values {
        if AhkStdlibIsNone(value)
            break
        script .= " " AhkStdlibTkinterTextValueWord(value)
    }
    return script
}

AhkStdlibTkinterTextValueWord(value)
{
    return AhkStdlibTkinterTclWord(AhkStdlibTkinterTextValueText(value))
}

AhkStdlibTkinterTextValueText(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTextJoinValue(value)
    return AhkStdlibTkinterValueToString(value)
}

AhkStdlibTkinterTextJoinValue(values)
{
    text := ""
    first := true
    for value in values {
        if !first
            text .= " "
        first := false
        text .= AhkStdlibTkinterValueToString(value)
    }
    return text
}

AhkStdlibTkinterTextCountOptionName(value)
{
    if value is AhkStdlibTuple {
        if value.Length = 1
            return AhkStdlibTkinterValueToString(value[1])
        throw TypeError("not all arguments converted during string formatting", -1)
    }
    return AhkStdlibTkinterValueToString(value)
}

AhkStdlibTkinterTextSearchPatternStartsDash(pattern)
{
    if pattern is String
        return SubStr(pattern, 1, 1) = "-"
    if pattern is Array || pattern is AhkStdlibTuple {
        if pattern.Length = 0
            return false
        return AhkStdlibTkinterValueToString(pattern[1]) = "-"
    }
    patternText := AhkStdlibTkinterValueToString(pattern)
    return SubStr(patternText, 1, 1) = "-"
}

AhkStdlibTkinterTtkWidgetIdentify(widget, args*)
{
    if args.Length = 0
        throw TypeError("Widget.identify() missing 2 required positional arguments: 'x' and 'y'", -1)
    if args.Length = 1
        throw TypeError("Widget.identify() missing 1 required positional argument: 'y'", -1)
    if args.Length > 2
        throw TypeError("Widget.identify() takes 3 positional arguments but " args.Length + 1 " were given", -1)
    script := widget._w " identify"
    for value in args {
        if AhkStdlibIsNone(value)
            break
        script .= " " AhkStdlibTkinterTtkFloatValueWord(value)
    }
    return widget.AhkStdlibRoot.eval(script)
}

AhkStdlibTkinterTtkTreeviewOptionName(option)
{
    if AhkStdlibIsBool(option)
        return option.Value ? "True" : "False"
    return AhkStdlibTkinterWidgetOptionName(option)
}

AhkStdlibTkinterTtkSubcommandQueryOptionRaw(value)
{
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if value is AhkStdlibTuple {
        if value.Length = 0
            throw TypeError("not enough arguments for format string", -1)
        if value.Length > 1
            throw TypeError("not all arguments converted during string formatting", -1)
        return AhkStdlibTkinterValueToString(value[1])
    }
    if value is Array
        throw TypeError("unhashable type: 'list'", -1)
    return AhkStdlibTkinterValueToString(value)
}

AhkStdlibTkinterTtkSubcommandQueryOptionName(value)
{
    raw := AhkStdlibTkinterTtkSubcommandQueryOptionRaw(value)
    return raw
}

AhkStdlibTkinterTtkSubcommandQueryOptionWord(value)
{
    return AhkStdlibTkinterTclWord("-" AhkStdlibTkinterTtkSubcommandQueryOptionRaw(value))
}

AhkStdlibTkinterTtkSubcommandQueryOption(value)
{
    raw := AhkStdlibTkinterTtkSubcommandQueryOptionRaw(value)
    return Map("name", raw, "word", AhkStdlibTkinterTclWord("-" raw))
}

AhkStdlibTkinterTtkPanedwindowPaneWord(value)
{
    if value is Array || value is AhkStdlibTuple {
        parts := []
        for item in value
            parts.Push(AhkStdlibTkinterPaneChildPath(item))
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(parts))
    }
    return AhkStdlibTkinterTclWord(AhkStdlibTkinterPaneChildPath(value))
}

AhkStdlibTkinterTtkPanedwindowPaneDict(root, script)
{
    result := Map()
    raw := root.eval(script)
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw)
    index := 1
    while index <= parts.Length {
        optionName := parts[index]
        if SubStr(optionName, 1, 1) = "-"
            optionName := SubStr(optionName, 2)
        value := index + 1 <= parts.Length ? parts[index + 1] : ""
        result[optionName] := AhkStdlibTkinterTtkPanedwindowPaneValue(root, optionName, value)
        index += 2
    }
    return result
}

AhkStdlibTkinterTtkPanedwindowPaneValue(root, optionName, value)
{
    optionName := AhkStdlibTkinterWidgetOptionName(optionName)
    if optionName = "weight"
        try return Integer(value)
    return AhkStdlibTkinterCgetValue(optionName, value, root)
}

AhkStdlibTkinterTtkSpinboxConfigureOption(root, window, option)
{
    optionWord := AhkStdlibTkinterTclWord(AhkStdlibTkinterWidgetDashOption(option))
    optionName := AhkStdlibTkinterWidgetOptionName(option)
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, root.eval(window " configure " optionWord))
    result := []
    for index, value in parts {
        if index = 1 && SubStr(value, 1, 1) = "-"
            value := SubStr(value, 2)
        else if index = parts.Length
            value := AhkStdlibTkinterTtkSpinboxValue(root, optionName, value)
        else if optionName = "width" && index = 4
            value := Integer(value)
        result.Push(value)
    }
    return stdlib.tuple(result)
}

AhkStdlibTkinterTtkSpinboxValue(root, optionName, value)
{
    optionName := AhkStdlibTkinterWidgetOptionName(optionName)
    switch optionName {
        case "from", "to", "increment":
            return AhkStdlibTkinterIntOrFloatValue(value)
        case "wrap":
            try return Integer(value)
        case "values":
            return value = "" ? "" : stdlib.tuple(AhkStdlibTkinterSplitList(root.AhkStdlibInterp, value))
    }
    return AhkStdlibTkinterCgetValue(optionName, value, root)
}

AhkStdlibTkinterTtkMenubuttonConfigureOption(root, window, option)
{
    optionWord := AhkStdlibTkinterTclWord(AhkStdlibTkinterWidgetDashOption(option))
    optionName := AhkStdlibTkinterWidgetOptionName(option)
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, root.eval(window " configure " optionWord))
    result := []
    for index, value in parts {
        if index = 1 && SubStr(value, 1, 1) = "-"
            value := SubStr(value, 2)
        else if index = parts.Length
            value := AhkStdlibTkinterTtkMenubuttonValue(optionName, value)
        else if index = 4
            value := AhkStdlibTkinterTtkMenubuttonDefaultValue(optionName, value)
        result.Push(value)
    }
    return stdlib.tuple(result)
}

AhkStdlibTkinterTtkMenubuttonValue(optionName, value)
{
    optionName := AhkStdlibTkinterWidgetOptionName(optionName)
    switch optionName {
        case "underline", "width", "takefocus":
            try return Integer(value)
    }
    return value
}

AhkStdlibTkinterTtkMenubuttonDefaultValue(optionName, value)
{
    optionName := AhkStdlibTkinterWidgetOptionName(optionName)
    switch optionName {
        case "underline", "width", "takefocus":
            try return Integer(value)
    }
    return value
}

AhkStdlibTkinterTtkTreeviewSelectionCommand(tree, command, args*)
{
    script := tree._w " selection " command
    items := []
    if args.Length = 1 && IsObject(args[1]) && HasMethod(args[1], "__Enum") {
        for item in args[1]
            items.Push(item)
    } else {
        for item in args
            items.Push(item)
    }
    script .= " " AhkStdlibTkinterTtkTreeviewSelectionItemsOperand(items)
    tree.AhkStdlibRoot.eval(script)
    return stdlib.None
}

AhkStdlibTkinterTtkTreeviewSelectionItemsOperand(items)
{
    script := "[list"
    for item in items
        script .= " " AhkStdlibTkinterTtkTreeviewItemWord(item)
    return script "]"
}

AhkStdlibTkinterTtkTreeviewItemWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkTreeviewItemsOperand(args)
{
    script := "[list"
    for item in args {
        if IsObject(item) && HasMethod(item, "__Enum")
            script .= " " AhkStdlibTkinterTclListCommandWord(item)
        else
            script .= " " AhkStdlibTkinterTclWord(item)
    }
    return script "]"
}

AhkStdlibTkinterTtkTreeviewChildrenOperand(items)
{
    script := "[list"
    for item in items
        script .= " " AhkStdlibTkinterTtkTreeviewChildWord(item)
    return script "]"
}

AhkStdlibTkinterTtkTreeviewChildWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkTreeviewColumnWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkTreeviewSetValueWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkTreeviewTagWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkTreeviewTagBindSequenceWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkTreeviewIdentifyComponentWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkTreeviewConfigureOption(root, window, option)
{
    optionWord := AhkStdlibTkinterTclWord(AhkStdlibTkinterWidgetDashOption(option))
    optionName := AhkStdlibTkinterWidgetOptionName(option)
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, root.eval(window " configure " optionWord))
    result := []
    for index, value in parts {
        if index = 1 && SubStr(value, 1, 1) = "-"
            value := SubStr(value, 2)
        else if index = parts.Length
            value := AhkStdlibTkinterTtkTreeviewWidgetValue(root, optionName, value)
        result.Push(value)
    }
    return stdlib.tuple(result)
}

AhkStdlibTkinterTtkTreeviewWidgetValue(root, optionName, value)
{
    optionName := AhkStdlibTkinterWidgetOptionName(optionName)
    switch optionName {
        case "columns", "displaycolumns", "padding", "show":
            return value = "" ? "" : stdlib.tuple(AhkStdlibTkinterSplitList(root.AhkStdlibInterp, value))
    }
    return AhkStdlibTkinterCgetValue(optionName, value, root)
}

AhkStdlibTkinterTtkTreeviewColumnDict(root, window, columnId)
{
    result := Map()
    raw := root.eval(window " column " AhkStdlibTkinterTtkTreeviewColumnWord(columnId))
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw)
    index := 1
    while index <= parts.Length {
        optionName := AhkStdlibTkinterWidgetOptionName(parts[index])
        value := index + 1 <= parts.Length ? parts[index + 1] : ""
        result[optionName] := AhkStdlibTkinterTtkTreeviewColumnValue(root, optionName, value)
        index += 2
    }
    return result
}

AhkStdlibTkinterTtkTreeviewColumnValue(root, optionName, value)
{
    optionName := AhkStdlibTkinterWidgetOptionName(optionName)
    switch optionName {
        case "width", "minwidth", "stretch":
            try return Integer(value)
    }
    return AhkStdlibTkinterCgetValue(optionName, value, root)
}

AhkStdlibTkinterTtkTreeviewHeadingDict(root, window, columnId)
{
    result := Map()
    raw := root.eval(window " heading " AhkStdlibTkinterTtkTreeviewColumnWord(columnId))
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw)
    index := 1
    while index <= parts.Length {
        optionName := AhkStdlibTkinterWidgetOptionName(parts[index])
        value := index + 1 <= parts.Length ? parts[index + 1] : ""
        result[optionName] := AhkStdlibTkinterTtkTreeviewHeadingValue(root, optionName, value)
        index += 2
    }
    return result
}

AhkStdlibTkinterTtkTreeviewHeadingValue(root, optionName, value)
{
    return AhkStdlibTkinterCgetValue(optionName, value, root)
}

AhkStdlibTkinterTtkTreeviewItemDict(root, window, itemId)
{
    result := Map()
    raw := root.eval(window " item " AhkStdlibTkinterTtkTreeviewItemWord(itemId))
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw)
    index := 1
    while index <= parts.Length {
        optionName := AhkStdlibTkinterWidgetOptionName(parts[index])
        value := index + 1 <= parts.Length ? parts[index + 1] : ""
        result[optionName] := AhkStdlibTkinterTtkTreeviewItemValue(root, optionName, value, true)
        index += 2
    }
    return result
}

AhkStdlibTkinterTtkTreeviewItemValue(root, optionName, value, asDict)
{
    optionName := AhkStdlibTkinterWidgetOptionName(optionName)
    switch optionName {
        case "values":
            if asDict && value = ""
                return ""
            values := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, value)
            if !asDict
                return stdlib.tuple(values)
            result := []
            for item in values
                result.Push(AhkStdlibTkinterIntOrFloatValue(item))
            return result
        case "tags":
            if asDict && value = ""
                return ""
            values := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, value)
            if !asDict
                return stdlib.tuple(values)
            return values
        case "open":
            try return Integer(value)
    }
    return AhkStdlibTkinterCgetValue(optionName, value, root)
}

AhkStdlibTkinterTtkTreeviewSetDict(root, window, itemId)
{
    result := Map()
    raw := root.eval(window " set " AhkStdlibTkinterTtkTreeviewItemWord(itemId))
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw)
    index := 1
    while index <= parts.Length {
        columnName := parts[index]
        value := index + 1 <= parts.Length ? parts[index + 1] : ""
        result[columnName] := value
        index += 2
    }
    return result
}

AhkStdlibTkinterTtkTreeviewTagConfigureDict(root, window, tagName)
{
    result := Map()
    raw := root.eval(window " tag configure " AhkStdlibTkinterTtkTreeviewTagWord(tagName))
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw)
    index := 1
    while index <= parts.Length {
        optionName := parts[index]
        if SubStr(optionName, 1, 1) = "-"
            optionName := SubStr(optionName, 2)
        value := index + 1 <= parts.Length ? parts[index + 1] : ""
        result[optionName] := AhkStdlibTkinterCgetValue(optionName, value, root)
        index += 2
    }
    return result
}

AhkStdlibTkinterTtkStyleConfigureDict(root, styleName)
{
    result := Map()
    raw := root.eval("ttk::style configure" styleName)
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw)
    index := 1
    while index <= parts.Length {
        optionName := AhkStdlibTkinterWidgetOptionName(parts[index])
        value := index + 1 <= parts.Length ? parts[index + 1] : ""
        result[optionName] := AhkStdlibTkinterTtkStyleValue(root, optionName, value)
        index += 2
    }
    return result
}

AhkStdlibTkinterTtkStyleConfigureFalsyQueryOption(value)
{
    if AhkStdlibIsBool(value)
        return !value.Value
    if (value is Integer) || (value is Float) || (value is String)
        return !AhkStdlibTruthValue(value)
    return false
}

AhkStdlibTkinterTtkStyleConfigureQueryOption(value)
{
    if value is AhkStdlibTuple {
        if value.Length = 0
            throw TypeError("not enough arguments for format string", -1)
        if value.Length > 1
            throw TypeError("not all arguments converted during string formatting", -1)
        return AhkStdlibTkinterWidgetOptionName(value[1])
    }
    if value is Array
        throw TypeError("unhashable type: 'list'", -1)
    return AhkStdlibTkinterWidgetOptionName(value)
}

AhkStdlibTkinterTtkStyleValue(root, optionName, value)
{
    optionName := AhkStdlibTkinterWidgetOptionName(optionName)
    switch optionName {
        case "padding":
            if value = ""
                return ""
            values := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, value)
            if values.Length = 1
                return AhkStdlibTkinterIntOrFloatValue(values[1])
            result := []
            for item in values
                result.Push(AhkStdlibTkinterIntOrFloatValue(item))
            return stdlib.tuple(result)
    }
    return value
}

AhkStdlibTkinterTtkStyleStateSpec(states)
{
    if states is String
        return states
    if !IsObject(states) || !HasMethod(states, "__Enum")
        throw TypeError("can only join an iterable", -1)
    parts := []
    for state in states
        parts.Push(state)
    return AhkStdlibTkinterJoinStateSpec(parts)
}

AhkStdlibTkinterTtkStyleLookupOption(value)
{
    if value is AhkStdlibTuple {
        if value.Length = 0
            throw TypeError("not enough arguments for format string", -1)
        if value.Length > 1
            throw TypeError("not all arguments converted during string formatting", -1)
        return AhkStdlibTkinterWidgetOptionName(value[1])
    }
    if value is Array
        return AhkStdlibTkinterTtkStyleSettingsName(value)
    return AhkStdlibTkinterWidgetOptionName(value)
}

AhkStdlibTkinterTtkStyleLookupDefaultWord(value)
{
    if AhkStdlibTkinterTtkStyleLookupDefaultIsSequence(value)
        return AhkStdlibTkinterTclListCommandWord(value)
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkStyleLookupDefaultIsSequence(value)
{
    return (value is Array || value is AhkStdlibTuple) && !AhkStdlibIsNone(value)
}

AhkStdlibTkinterTtkStyleNameWord(value)
{
    if AhkStdlibIsNone(value)
        return ""
    if value is Array || value is AhkStdlibTuple
        return " " AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return " " AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkStyleElementOptionsNameWord(value)
{
    if AhkStdlibIsNone(value)
        return ""
    if value is Array || value is AhkStdlibTuple
        return " " AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkJoinValue(value))
    return " " AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkElementCreateAppendCallWord(&script, value)
{
    if AhkStdlibIsNone(value)
        return false
    script .= " " AhkStdlibTkinterTtkElementCreateCallWord(value)
    return true
}

AhkStdlibTkinterTtkElementCreateCallWord(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTclListCommandWord(value)
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkElementCreateTypeKey(value)
{
    if value is String
        return value
    return ""
}

AhkStdlibTkinterTtkStyleMapOptions(options)
{
    script := ""
    AhkStdlibTkinterTtkForEachSetting(options, (key, value) => script .= " -" AhkStdlibTkinterWidgetOptionName(key) " " AhkStdlibTkinterTtkStyleStateMapSpec(value))
    return script
}

AhkStdlibTkinterTtkStyleMapValidateOptions(options)
{
    if options is Map {
        for key, value in options {
            AhkStdlibTkinterTtkStyleMapValidateValue(value)
        }
        return
    }
    if AhkStdlibTkinterIsPlainKeywordObject(options) {
        for key, value in options.OwnProps() {
            AhkStdlibTkinterTtkStyleMapValidateValue(value)
        }
    }
}

AhkStdlibTkinterTtkStyleMapValidateValue(value)
{
    if value is String
        return
    if IsObject(value) && HasMethod(value, "__Enum")
        return
    throw TypeError("'" AhkStdlibPyTypeName(value) "' object is not iterable", -1)
}

AhkStdlibTkinterTtkStyleMapQueryOption(value)
{
    if value is AhkStdlibTuple {
        if value.Length = 0
            throw TypeError("not enough arguments for format string", -1)
        if value.Length > 1
            throw TypeError("not all arguments converted during string formatting", -1)
        return AhkStdlibTkinterWidgetOptionName(value[1])
    }
    if value is Array
        return ""
    return AhkStdlibTkinterWidgetOptionName(value)
}

AhkStdlibTkinterTtkStyleThemeWord(value)
{
    if value is Array {
        script := "[list"
        for item in value
            script .= " " AhkStdlibTkinterTtkStyleThemeWord(item)
        return script "]"
    }
    return AhkStdlibTkinterTclWord(value)
}

AhkStdlibTkinterTtkStyleStateMapSpec(entries)
{
    values := []
    if entries is String {
        loop parse entries {
            values.Push("")
            values.Push(A_LoopField)
        }
        return AhkStdlibTkinterTclListCommandWord(values)
    }
    if !IsObject(entries) || !HasMethod(entries, "__Enum")
        return AhkStdlibTkinterTclListCommandWord(values)
    for entry in entries {
        if !IsObject(entry) || !HasMethod(entry, "__Enum") {
            throw TypeError("cannot unpack non-iterable " AhkStdlibPyTypeName(entry) " object", -1)
        }
        parts := []
        for item in entry
            parts.Push(item)
        if parts.Length = 0
            throw ValueError("not enough values to unpack (expected at least 1, got 0)", -1)
        stateParts := []
        loop parts.Length - 1
            stateParts.Push(parts[A_Index])
        values.Push(AhkStdlibTkinterJoinStateSpec(stateParts))
        if !AhkStdlibIsNone(parts[parts.Length])
            values.Push(AhkStdlibTkinterTtkStyleStateMapValue(parts[parts.Length]))
    }
    return AhkStdlibTkinterTclListCommandWord(values)
}

AhkStdlibTkinterTtkStyleStateMapValue(value)
{
    if value is Array || value is AhkStdlibTuple
        return AhkStdlibTkinterTtkJoinValue(value)
    return value
}

AhkStdlibTkinterTtkStyleStateMap(root, raw)
{
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw)
    result := []
    index := 1
    while index <= parts.Length {
        state := parts[index]
        value := index + 1 <= parts.Length ? parts[index + 1] : ""
        entry := []
        if state != "" {
            for item in StrSplit(state, " ")
                if item != ""
                    entry.Push(item)
        }
        entry.Push(value)
        result.Push(stdlib.tuple(entry))
        index += 2
    }
    return result
}

AhkStdlibTkinterTtkStyleMapDict(root, raw)
{
    result := Map()
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw)
    index := 1
    while index <= parts.Length {
        optionName := AhkStdlibTkinterWidgetOptionName(parts[index])
        value := index + 1 <= parts.Length ? parts[index + 1] : ""
        result[optionName] := AhkStdlibTkinterTtkStyleStateMap(root, value)
        index += 2
    }
    return result
}

AhkStdlibTkinterTtkElementCreateSpec(elementType, args)
{
    switch AhkStdlibTkinterTtkElementCreateTypeKey(elementType) {
        case "image":
            if args.Length = 0
                throw IndexError("tuple index out of range", -1)
            imageParts := [args[1]]
            index := 2
            while index <= args.Length {
                AhkStdlibTkinterTtkElementCreateMapValues(args[index], &imageParts)
                index += 1
            }
            return AhkStdlibTkinterTclListCommandWord(imageParts)
        case "vsapi":
            if args.Length < 2
                throw ValueError("not enough values to unpack (expected 2, got " args.Length ")", -1)
            parts := [args[1], args[2]]
            index := 3
            while index <= args.Length {
                AhkStdlibTkinterTtkElementCreateMapValues(args[index], &parts)
                index += 1
            }
            return AhkStdlibTkinterTclListCommandWord(parts)
        case "from":
            if args.Length = 0
                throw IndexError("tuple index out of range", -1)
            if AhkStdlibIsNone(args[1])
                return ""
            if args.Length = 1
                return AhkStdlibTkinterTtkElementCreateCallWord(args[1])
            if AhkStdlibIsNone(args[2])
                return AhkStdlibTkinterTtkElementCreateCallWord(args[1])
            return AhkStdlibTkinterTtkElementCreateCallWord(args[1]) " " AhkStdlibTkinterTtkElementCreateCallWord(AhkStdlibTkinterTtkElementCreateOptionValue(args[2]))
    }
    return ""
}

AhkStdlibTkinterTtkElementCreateMapValues(entry, &values)
{
    parts := []
    if entry is String {
        loop parse entry
            parts.Push(A_LoopField)
    } else if !IsObject(entry) || !HasMethod(entry, "__Enum") {
        throw TypeError("cannot unpack non-iterable " AhkStdlibPyTypeName(entry) " object", -1)
    } else {
        for item in entry
            parts.Push(item)
    }
    if parts.Length = 0
        throw ValueError("not enough values to unpack (expected at least 1, got 0)", -1)
    stateParts := []
    loop parts.Length - 1
        stateParts.Push(parts[A_Index])
    if stateParts.Length = 0
        state := ""
    else if stateParts.Length = 1
        state := AhkStdlibTkinterTtkElementCreateStateValue(stateParts[1])
    else
        state := AhkStdlibTkinterJoinStateSpec(stateParts)
    values.Push(state)
    if !AhkStdlibIsNone(parts[parts.Length])
        values.Push(AhkStdlibTkinterTtkElementCreateOptionValue(parts[parts.Length]))
}

AhkStdlibTkinterTtkElementCreateStateValue(value)
{
    if AhkStdlibIsNone(value)
        return ""
    if AhkStdlibIsBool(value)
        return value.Value ? "1" : ""
    text := AhkStdlibTkinterValueToString(value)
    return text != "" ? text : ""
}

AhkStdlibTkinterTtkElementCreateOptionValue(value)
{
    if IsObject(value) && HasMethod(value, "__Enum")
        return AhkStdlibTkinterTtkJoinValue(value)
    return value
}

AhkStdlibTkinterTtkElementCreateOptions(options)
{
    script := ""
    if !AhkStdlibTkinterIsPlainKeywordObject(options)
        return script
    for key, value in options.OwnProps() {
        optionName := AhkStdlibTkinterWidgetOptionName(key)
        script .= " -" optionName
        if !AhkStdlibIsNone(value)
            script .= " " AhkStdlibTkinterTclWord(AhkStdlibTkinterTtkElementCreateOptionValue(value))
    }
    return script
}

AhkStdlibTkinterTtkStyleLayoutList(root, raw)
{
    parts := AhkStdlibTkinterSplitList(root.AhkStdlibInterp, raw)
    return AhkStdlibTkinterTtkStyleLayoutParts(root, parts)
}

AhkStdlibTkinterTtkStyleLayoutParts(root, parts)
{
    result := []
    index := 1
    while index <= parts.Length {
        elementName := parts[index]
        if SubStr(elementName, 1, 1) = "-" {
            index += 1
            continue
        }
        options := Map()
        index += 1
        while index <= parts.Length && SubStr(parts[index], 1, 1) = "-" {
            optionName := AhkStdlibTkinterWidgetOptionName(parts[index])
            value := index + 1 <= parts.Length ? parts[index + 1] : ""
            options[optionName] := optionName = "children" ? AhkStdlibTkinterTtkStyleLayoutList(root, value) : value
            index += 2
        }
        result.Push(stdlib.tuple([elementName, options]))
    }
    return result
}

AhkStdlibTkinterTtkStyleLayoutSpec(layout, indent := 0, topLevelString := false)
{
    script := ""
    found := false
    if topLevelString && layout is String {
        if layout = ""
            return AhkStdlibTkinterTclScriptWord("`n" Format("{: " indent "}", "") "null -sticky nswe`n")
        throw ValueError("not enough values to unpack (expected 2, got 1)", -1)
    }
    for entry in layout {
        found := true
        if script != ""
            script .= "`n"
        entryParts := AhkStdlibTkinterTtkStyleLayoutEntryParts(entry)
        elementName := entryParts[1]
        options := entryParts[2]
        script .= Format("{: " indent "}", "") AhkStdlibTkinterValueToString(elementName)
        optionScript := AhkStdlibTkinterTtkStyleLayoutOptions(options)
        if optionScript != ""
            script .= " " optionScript
        if IsObject(options) && AhkStdlibTkinterTtkSettingHas(options, "children") {
            script .= " -children {`n"
            script .= AhkStdlibTkinterTtkStyleLayoutSpec(AhkStdlibTkinterTtkSettingGet(options, "children"), indent + 2)
            script .= "`n" Format("{: " indent "}", "") "}"
        }
    }
    if !found
        return AhkStdlibTkinterTclScriptWord("`n" Format("{: " indent "}", "") "null -sticky nswe`n")
    return AhkStdlibTkinterTclScriptWord("`n" script "`n")
}

AhkStdlibTkinterTtkStyleLayoutOptions(options)
{
    if !IsObject(options)
        return ""
    script := ""
    AhkStdlibTkinterTtkForEachSetting(options, (key, value) => (
        AhkStdlibTkinterWidgetOptionName(key) = "children"
            ? ""
            : script .= (script = "" ? "" : " ") "-" AhkStdlibTkinterWidgetOptionName(key) " " AhkStdlibTkinterTclScriptOptionWord(value)
    ))
    return script
}

AhkStdlibTkinterTtkStyleLayoutEntryParts(entry)
{
    if entry is String
        throw ValueError("too many values to unpack (expected 2)", -1)
    parts := []
    for value in entry
        parts.Push(value)
    if parts.Length < 2
        throw ValueError("not enough values to unpack (expected 2, got " parts.Length ")", -1)
    if parts.Length > 2
        throw ValueError("too many values to unpack (expected 2)", -1)
    options := parts.Length >= 2 && IsObject(parts[2]) ? parts[2] : Map()
    return [parts[1], options]
}

AhkStdlibTkinterTtkStyleSettingsScript(settings)
{
    if !(settings is Map) && !AhkStdlibTkinterIsPlainKeywordObject(settings)
        throw AttributeError("'" AhkStdlibPyTypeName(settings) "' object has no attribute 'items'", -1)
    script := ""
    AhkStdlibTkinterTtkForEachSetting(settings, (styleName, options) => script .= AhkStdlibTkinterTtkStyleSettingScript(styleName, options))
    return script
}

AhkStdlibTkinterTtkStyleSettingScript(styleName, options)
{
    if !(options is Map) && !AhkStdlibTkinterIsPlainKeywordObject(options)
        throw AttributeError("'" AhkStdlibPyTypeName(options) "' object has no attribute 'get'", -1)
    script := ""
    if AhkStdlibTkinterTtkSettingHas(options, "configure") {
        configureOptions := AhkStdlibTkinterTtkSettingGet(options, "configure")
        if AhkStdlibTkinterTtkSettingsHasAny(configureOptions)
            script .= "ttk::style configure " AhkStdlibTkinterTtkStyleSettingsName(styleName) AhkStdlibTkinterTtkStyleConfigureOptions(configureOptions) ";`n"
    }
    if AhkStdlibTkinterTtkSettingHas(options, "map") {
        mapOptions := AhkStdlibTkinterTtkSettingGet(options, "map")
        if AhkStdlibTkinterTtkSettingsHasAny(mapOptions)
            script .= "ttk::style map " AhkStdlibTkinterTtkStyleSettingsName(styleName) AhkStdlibTkinterTtkStyleMapOptions(mapOptions) ";`n"
    }
    if AhkStdlibTkinterTtkSettingHas(options, "layout") {
        layout := AhkStdlibTkinterTtkSettingGet(options, "layout")
        if !layout || (IsObject(layout) && HasProp(layout, "Length") && layout.Length = 0)
            script .= "ttk::style layout " AhkStdlibTkinterTtkStyleSettingsName(styleName) " null;`n"
        else
            script .= "ttk::style layout " AhkStdlibTkinterTtkStyleSettingsName(styleName) " " AhkStdlibTkinterTtkStyleLayoutSpec(layout) ";`n"
    }
    if AhkStdlibTkinterTtkSettingHas(options, "element create") {
        elementCreate := AhkStdlibTkinterTtkSettingGet(options, "element create")
        if AhkStdlibTruthValue(elementCreate)
            script .= AhkStdlibTkinterTtkStyleElementCreateSettingScript(styleName, elementCreate) "`n"
    }
    return script
}

AhkStdlibTkinterTtkStyleElementCreateSettingScript(elementName, elementCreate)
{
    parts := AhkStdlibTkinterTtkStyleElementCreateSettingParts(elementCreate)
    elementType := parts[1]
    args := []
    options := {}
    index := 2
    while index <= parts.Length {
        if !AhkStdlibIsNone(parts[index]) && AhkStdlibTkinterIsPlainKeywordObject(parts[index]) {
            options := parts[index]
            break
        }
        args.Push(parts[index])
        index += 1
    }
    return "ttk::style element create " AhkStdlibTkinterTtkStyleSettingsName(elementName) " " AhkStdlibTkinterTtkStyleSettingsName(elementType) " " AhkStdlibTkinterTtkElementCreateScriptSpec(elementType, args) AhkStdlibTkinterTtkElementCreateScriptOptions(options)
}

AhkStdlibTkinterTtkStyleElementCreateSettingParts(elementCreate)
{
    parts := []
    if elementCreate is String {
        loop parse elementCreate
            parts.Push(A_LoopField)
        return parts
    }
    if !IsObject(elementCreate) || !HasMethod(elementCreate, "__Enum")
        throw TypeError("'" AhkStdlibPyTypeName(elementCreate) "' object is not subscriptable", -1)
    for value in elementCreate
        parts.Push(value)
    return parts
}

AhkStdlibTkinterTtkStyleSettingsName(value)
{
    if value is AhkStdlibTuple {
        parts := []
        for item in value
            parts.Push(AhkStdlibTkinterTtkStyleSettingsRepr(item))
        if parts.Length = 1
            return "(" parts[1] ",)"
        return "(" AhkStdlibTkinterTtkJoinSettingParts(parts) ")"
    }
    if value is Array {
        parts := []
        for item in value
            parts.Push(AhkStdlibTkinterTtkStyleSettingsRepr(item))
        return "[" AhkStdlibTkinterTtkJoinSettingParts(parts) "]"
    }
    return AhkStdlibTkinterValueToString(value)
}

AhkStdlibTkinterTtkStyleSettingsRepr(value)
{
    if value is String
        return "'" value "'"
    if value is AhkStdlibTuple || value is Array
        return AhkStdlibTkinterTtkStyleSettingsName(value)
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    return AhkStdlibTkinterValueToString(value)
}

AhkStdlibTkinterTtkJoinSettingParts(parts)
{
    text := ""
    for part in parts {
        if A_Index > 1
            text .= ", "
        text .= part
    }
    return text
}

AhkStdlibTkinterTtkElementCreateScriptSpec(elementType, args)
{
    switch AhkStdlibTkinterValueToString(elementType) {
        case "image":
            return AhkStdlibTkinterTclScriptWord(AhkStdlibTkinterTtkElementCreateScriptListSpec("image", args))
        case "vsapi":
            return AhkStdlibTkinterTclScriptWord(AhkStdlibTkinterTtkElementCreateScriptListSpec("vsapi", args))
        case "from":
            if args.Length = 0
                throw IndexError("tuple index out of range", -1)
            if args.Length = 1
                return AhkStdlibTkinterTclScriptWord(args[1])
            return AhkStdlibTkinterTclScriptWord(args[1]) " " AhkStdlibTkinterTclScriptWord(AhkStdlibTkinterTtkElementCreateOptionValue(args[2]))
    }
    return ""
}

AhkStdlibTkinterTtkElementCreateScriptListSpec(elementType, args)
{
    switch AhkStdlibTkinterValueToString(elementType) {
        case "image":
            if args.Length = 0
                throw IndexError("tuple index out of range", -1)
            parts := [args[1]]
            index := 2
            while index <= args.Length {
                AhkStdlibTkinterTtkElementCreateMapValues(args[index], &parts)
                index += 1
            }
            return AhkStdlibTkinterTtkElementCreateScriptJoin(parts)
        case "vsapi":
            if args.Length < 2
                throw ValueError("not enough values to unpack (expected 2, got " args.Length ")", -1)
            parts := [args[1], args[2]]
            index := 3
            while index <= args.Length {
                AhkStdlibTkinterTtkElementCreateMapValues(args[index], &parts)
                index += 1
            }
            return AhkStdlibTkinterTtkElementCreateScriptJoin(parts)
    }
    return ""
}

AhkStdlibTkinterTtkElementCreateScriptJoin(parts)
{
    text := ""
    for part in parts {
        if A_Index > 1
            text .= " "
        text .= AhkStdlibTkinterTtkElementCreateScriptPart(part)
    }
    return text
}

AhkStdlibTkinterTtkElementCreateScriptPart(value)
{
    text := AhkStdlibTkinterValueToString(value)
    return InStr(text, " ") ? AhkStdlibTkinterTclScriptWord(text) : text
}

AhkStdlibTkinterTtkElementCreateScriptOptions(options)
{
    script := ""
    if !AhkStdlibTkinterIsPlainKeywordObject(options)
        return script
    for key, value in options.OwnProps() {
        optionName := AhkStdlibTkinterWidgetOptionName(key)
        script .= " -" optionName
        if !AhkStdlibIsNone(value)
            script .= " " AhkStdlibTkinterTclScriptWord(AhkStdlibTkinterTtkElementCreateOptionValue(value))
    }
    return script
}

AhkStdlibTkinterTtkStyleConfigureOptions(options)
{
    script := ""
    AhkStdlibTkinterTtkForEachSetting(options, (key, value) => script .= " -" AhkStdlibTkinterWidgetOptionName(key) " " AhkStdlibTkinterTclScriptOptionWord(value))
    return script
}

AhkStdlibTkinterTclScriptOptionWord(value)
{
    if IsObject(value) && HasMethod(value, "__Enum")
        return AhkStdlibTkinterTclScriptWord(AhkStdlibTkinterTtkJoinValue(value))
    return AhkStdlibTkinterTclScriptWord(value)
}

AhkStdlibTkinterTtkJoinValue(values)
{
    text := ""
    first := true
    for value in values {
        if !first
            text .= " "
        first := false
        text .= value ""
    }
    return text
}

AhkStdlibTkinterTtkSettingsHasAny(settings)
{
    found := false
    AhkStdlibTkinterTtkForEachSetting(settings, (key, value) => found := true)
    return found
}

AhkStdlibTkinterTtkForEachSetting(settings, callback)
{
    if settings is Map {
        for key, value in settings
            callback.Call(key, value)
        return
    }
    if AhkStdlibTkinterIsPlainKeywordObject(settings) {
        for key, value in settings.OwnProps()
            callback.Call(key, value)
    }
}

AhkStdlibTkinterTtkSettingHas(settings, key)
{
    if settings is Map
        return settings.Has(key)
    return AhkStdlibTkinterIsPlainKeywordObject(settings) && settings.HasOwnProp(key)
}

AhkStdlibTkinterTtkSettingGet(settings, key)
{
    if settings is Map
        return settings[key]
    return settings.%key%
}

AhkStdlibTkinterOptionMenuSetit(variable, value, callback)
{
    variable.set(value)
    if !AhkStdlibIsNone(callback)
        callback.Call(value)
    return stdlib.None
}

AhkStdlibTkinterTtkOptionMenuPopulate(option, values*)
{
    try option.AhkStdlibMenu.delete(0, "end")
    for value in values
        option.AhkStdlibMenu.add_radiobutton({ label: value, command: AhkStdlibTkinterOptionMenuCommand(option.AhkStdlibOptionVariable, value, option.AhkStdlibOptionCallback), variable: option.AhkStdlibOptionVariable, value: value })
    return stdlib.None
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

AhkStdlibTkinterExceptionArgToString(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    return String(value)
}

AhkStdlibTkinterExceptionArgsTupleString(values)
{
    text := "("
    for index, value in values {
        if index > 1
            text .= ", "
        text .= AhkStdlibTkinterExceptionArgRepr(value)
    }
    if values.Length = 1
        text .= ","
    return text ")"
}

AhkStdlibTkinterExceptionArgRepr(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if value is String {
        text := StrReplace(value, "\", "\\")
        text := StrReplace(text, "'", "\'")
        text := StrReplace(text, "`r", "\r")
        text := StrReplace(text, "`n", "\n")
        text := StrReplace(text, "`t", "\t")
        return "'" text "'"
    }
    return String(value)
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

AhkStdlibTkinterModuleGetInt(args*)
{
    if args.Length = 0
        return 0
    if args.Length > 1
        throw TypeError("int() takes at most 1 argument (" args.Length " given)", -1)
    value := args[1]
    if AhkStdlibIsBool(value)
        return value.Value ? 1 : 0
    if AhkStdlibIsNone(value) || IsObject(value)
        throw TypeError("int() argument must be a string, a bytes-like object or a real number, not '" AhkStdlibPythonTypeName(value) "'", -1)
    if value is Integer
        return value
    if value is Float
        return Integer(value)
    if value is String {
        text := Trim(value)
        if RegExMatch(text, "^[+-]?\d+$")
            return Integer(text)
        throw ValueError("invalid literal for int() with base 10: '" value "'", -1)
    }
    throw TypeError("int() argument must be a string, a bytes-like object or a real number, not '" AhkStdlibPythonTypeName(value) "'", -1)
}

AhkStdlibTkinterModuleGetDouble(args*)
{
    if args.Length = 0
        return 0.0
    if args.Length > 1
        throw TypeError("float expected at most 1 argument, got " args.Length, -1)
    value := args[1]
    if AhkStdlibIsBool(value)
        return value.Value ? 1.0 : 0.0
    if AhkStdlibIsNone(value) || IsObject(value)
        throw TypeError("float() argument must be a string or a real number, not '" AhkStdlibPythonTypeName(value) "'", -1)
    if (value is Integer) || (value is Float)
        return Float(value)
    if value is String
        return Float(Trim(value))
    throw TypeError("float() argument must be a string or a real number, not '" AhkStdlibPythonTypeName(value) "'", -1)
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

AhkStdlibTkinterStrictMotif(root, args*)
{
    if args.Length > 1
        throw TypeError("Misc.tk_strictMotif() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
    if args.Length = 0 || AhkStdlibIsNone(args[1])
        return AhkStdlibTkinterGetBoolean(root.AhkStdlibInterp, root.eval("set tk_strictMotif"))
    return AhkStdlibTkinterGetBoolean(root.AhkStdlibInterp, root.eval("set tk_strictMotif " AhkStdlibTkinterTclWord(args[1])))
}

AhkStdlibTkinterBisque(root, args*)
{
    if args.Length != 0
        throw TypeError("Misc.tk_bisque() takes 1 positional argument but " args.Length + 1 " were given", -1)
    root.eval("tk_bisque")
    return stdlib.None
}

AhkStdlibTkinterSetPalette(root, args*)
{
    script := "tk_setPalette"
    for value in args {
        if AhkStdlibTkinterIsPlainKeywordObject(value)
            script .= AhkStdlibTkinterPaletteOptionsToScript(value)
        else
            script .= " " AhkStdlibTkinterTclWord(value)
    }
    root.eval(script)
    return stdlib.None
}

AhkStdlibTkinterPaletteOptionsToScript(options)
{
    script := ""
    for key, value in options.OwnProps()
        script .= " " AhkStdlibTkinterTclWord(key) " " AhkStdlibTkinterTclWord(value)
    return script
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

AhkStdlibTkinterStateSpecWord(statespec)
{
    if statespec is String {
        parts := []
        Loop Parse, statespec
            parts.Push(A_LoopField)
        return AhkStdlibTkinterTclWord(AhkStdlibTkinterJoinStateSpec(parts))
    }

    if !IsObject(statespec) || !HasMethod(statespec, "__Enum")
        throw TypeError("can only join an iterable", -1)

    parts := []
    for value in statespec
        parts.Push(value)
    return AhkStdlibTkinterTclWord(AhkStdlibTkinterJoinStateSpec(parts))
}

AhkStdlibTkinterJoinStateSpec(parts)
{
    text := ""
    for part in parts {
        if !(part is String)
            throw TypeError("sequence item " A_Index - 1 ": expected str instance, " AhkStdlibTkinterStateSpecPartTypeName(part) " found", -1)
        if A_Index > 1
            text .= " "
        text .= part ""
    }
    return text
}

AhkStdlibTkinterStateSpecPartTypeName(value)
{
    return AhkStdlibTkinterSequenceAwareTypeName(value)
}

AhkStdlibTkinterSequenceAwareTypeName(value)
{
    if AhkStdlibIsNone(value)
        return "NoneType"
    if value is AhkStdlibTuple
        return "tuple"
    if value is Array
        return "list"
    return AhkStdlibPyTypeName(value)
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
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(interp))
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
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(interp))
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
        throw AhkStdlibTkinter.TclError(AhkStdlibTkinterGetStringResult(interp))

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
    try return AhkStdlibTkinterEventTypeValueToName(value)
    if value != "" && value != "??"
        return value
    if InStr(sequence, "Button")
        return "ButtonPress"
    if InStr(sequence, "Key")
        return "KeyPress"
    return value
}

AhkStdlibTkinterEventTypeInternalValue(value, name)
{
    if value != "" && value != "??"
        return value
    nameValue := AhkStdlibTkinterEventTypeNameToValue(name)
    if nameValue != ""
        return nameValue
    return value
}

AhkStdlibTkinterEventTypeValueToName(value)
{
    if !(value is String)
        throw ValueError(AhkStdlibTkinterEventTypeInvalidMessage(value), -1)
    switch value {
        case "2":
            return "KeyPress"
        case "3":
            return "KeyRelease"
        case "4":
            return "ButtonPress"
        case "5":
            return "ButtonRelease"
        case "6":
            return "Motion"
        case "7":
            return "Enter"
        case "8":
            return "Leave"
        case "9":
            return "FocusIn"
        case "10":
            return "FocusOut"
        case "11":
            return "Keymap"
        case "12":
            return "Expose"
        case "13":
            return "GraphicsExpose"
        case "14":
            return "NoExpose"
        case "15":
            return "Visibility"
        case "16":
            return "Create"
        case "17":
            return "Destroy"
        case "18":
            return "Unmap"
        case "19":
            return "Map"
        case "20":
            return "MapRequest"
        case "21":
            return "Reparent"
        case "22":
            return "Configure"
        case "23":
            return "ConfigureRequest"
        case "24":
            return "Gravity"
        case "25":
            return "ResizeRequest"
        case "26":
            return "Circulate"
        case "27":
            return "CirculateRequest"
        case "28":
            return "Property"
        case "29":
            return "SelectionClear"
        case "30":
            return "SelectionRequest"
        case "31":
            return "Selection"
        case "32":
            return "Colormap"
        case "33":
            return "ClientMessage"
        case "34":
            return "Mapping"
        case "35":
            return "VirtualEvent"
        case "36":
            return "Activate"
        case "37":
            return "Deactivate"
        case "38":
            return "MouseWheel"
    }
    throw ValueError(AhkStdlibTkinterEventTypeInvalidMessage(value), -1)
}

AhkStdlibTkinterEventTypeNameToValue(name)
{
    switch name {
        case "KeyPress", "Key":
            return "2"
        case "KeyRelease":
            return "3"
        case "ButtonPress", "Button":
            return "4"
        case "ButtonRelease":
            return "5"
        case "Motion":
            return "6"
        case "Enter":
            return "7"
        case "Leave":
            return "8"
        case "FocusIn":
            return "9"
        case "FocusOut":
            return "10"
        case "Keymap":
            return "11"
        case "Expose":
            return "12"
        case "GraphicsExpose":
            return "13"
        case "NoExpose":
            return "14"
        case "Visibility":
            return "15"
        case "Create":
            return "16"
        case "Destroy":
            return "17"
        case "Unmap":
            return "18"
        case "Map":
            return "19"
        case "MapRequest":
            return "20"
        case "Reparent":
            return "21"
        case "Configure":
            return "22"
        case "ConfigureRequest":
            return "23"
        case "Gravity":
            return "24"
        case "ResizeRequest":
            return "25"
        case "Circulate":
            return "26"
        case "CirculateRequest":
            return "27"
        case "Property":
            return "28"
        case "SelectionClear":
            return "29"
        case "SelectionRequest":
            return "30"
        case "Selection":
            return "31"
        case "Colormap":
            return "32"
        case "ClientMessage":
            return "33"
        case "Mapping":
            return "34"
        case "VirtualEvent":
            return "35"
        case "Activate":
            return "36"
        case "Deactivate":
            return "37"
        case "MouseWheel":
            return "38"
    }
    return ""
}

AhkStdlibTkinterEventTypeInvalidMessage(value)
{
    if value is String
        return "'" value "' is not a valid EventType"
    if AhkStdlibIsNone(value)
        return "None is not a valid EventType"
    if AhkStdlibIsBool(value)
        return (value.Value ? "True" : "False") " is not a valid EventType"
    return AhkStdlibTkinterValueToString(value) " is not a valid EventType"
}

AhkStdlibTkinterCallWrapperArgs(value)
{
    if value is Array
        return value
    if value is String {
        args := []
        loop parse value
            args.Push(A_LoopField)
        return args
    }
    return [value]
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
