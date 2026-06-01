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
        return Tk(args*)
    }

    static StringVar(args*)
    {
        return AhkStdlibTkinterStringVar(args*)
    }
}

class Tk
{
    __New(args*)
    {
        this.AhkStdlibInterp := 0
        screenName := stdlib.None
        baseName := ""
        className := "Tk"
        useTk := false

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
                    default:
                        throw TypeError("Tcl() got an unexpected keyword argument '" key "'", -1)
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
        }

        if !(AhkStdlibIsNone(screenName)) && !(screenName is String)
            throw TypeError("create() argument 1 must be str or None, not " AhkStdlibPyTypeName(screenName), -1)
        if !(baseName is String)
            throw TypeError("create() argument 2 must be str, not " AhkStdlibPyTypeName(baseName), -1)
        if !(className is String)
            throw TypeError("create() argument 3 must be str, not " AhkStdlibPyTypeName(className), -1)

        useTk := AhkStdlibTkinterNormalizeBool(useTk)
        AhkStdlibTkinterEnsureTclRuntime()
        this.AhkStdlibInterp := AhkStdlibTkinterCreateInterp()
        try {
            AhkStdlibTkinterInitInterp(this.AhkStdlibInterp)
        } catch as err {
            try AhkStdlibTkinterDeleteInterp(this.AhkStdlibInterp)
            this.AhkStdlibInterp := 0
            throw err
        }
        this.AhkStdlibScreenName := screenName
        this.AhkStdlibBaseName := baseName
        this.AhkStdlibClassName := className
        this.AhkStdlibUseTk := useTk
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

    _root()
    {
        return this
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

class AhkStdlibTkinterStringVar
{
    __New(args*)
    {
        hasMaster := false
        master := stdlib.None
        value := ""
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
                        value := optionValue
                    case "name":
                        hasName := true
                        name := optionValue
                    default:
                        throw TypeError("StringVar.__init__() got an unexpected keyword argument '" key "'", -1)
                }
            }
        } else {
            if args.Length > 3
                throw TypeError("StringVar.__init__() takes from 1 to 4 positional arguments but " args.Length + 1 " were given", -1)
            if args.Length >= 1 {
                hasMaster := true
                master := args[1]
            }
            if args.Length >= 2
                value := args[2]
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
        this._name := hasName ? AhkStdlibTkinterNormalizeVarName(name) : AhkStdlibTkinterNextVarName()
        this.set(value)
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

AhkStdlibTkinterEnsureTclRuntime()
{
    static initialized := false
    static startupError := ""
    if initialized {
        if startupError != ""
            throw RuntimeError(startupError, -1)
        return
    }

    initialized := true
    try {
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
        startupError := err.Message
        throw RuntimeError(startupError, -1)
    }
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
    if value is String
        return value
    throw TypeError("name must be a string", -1)
}

AhkStdlibTkinterValueToString(value)
{
    if AhkStdlibIsNone(value)
        return ""
    if AhkStdlibIsBool(value)
        return value.Value ? "1" : "0"
    return value ""
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
