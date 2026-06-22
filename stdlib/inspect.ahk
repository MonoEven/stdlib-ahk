#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibInspect
{
    static Parameter
    {
        get => AhkStdlibInspectParameter
    }

    static Signature
    {
        get => AhkStdlibInspectSignature
    }

    static isfunction(args*)
    {
        if args.Length = 0
            throw TypeError("isfunction() missing 1 required positional argument: 'object'", -1)
        if args.Length > 1
            throw TypeError("isfunction() takes 1 positional argument but " args.Length " were given", -1)

        value := args[1]
        if !IsObject(value)
            return false
        if !(value is Func)
            return false
        if value is BoundFunc
            return false
        if value.IsBuiltIn
            return false
        if value.Name = ""
            return true
        if InStr(value.Name, ".Prototype.")
            return false
        if InStr(value.Name, ".")
            return false
        return true
    }

    static isclass(args*)
    {
        if args.Length = 0
            throw TypeError("isclass() missing 1 required positional argument: 'object'", -1)
        if args.Length > 1
            throw TypeError("isclass() takes 1 positional argument but " args.Length " were given", -1)

        value := args[1]
        return IsObject(value) && Type(value) = "Class" && HasProp(value, "Prototype")
    }

    static ismethod(object)
    {
        return IsObject(object) && object is BoundFunc
    }

    static isbuiltin(object)
    {
        return IsObject(object) && object is Func && object.IsBuiltIn
    }

    static isroutine(object)
    {
        return IsObject(object) && (object is Func || object is BoundFunc || object is Closure)
    }

    static ismodule(object)
    {
        ; A SimpleNamespace/module-like object carries the module marker.
        return IsObject(object) && (HasProp(object, "__AhkStdlibModule") || Type(object) = "AhkStdlibTypesModuleType")
    }

    static ismethoddescriptor(object)
    {
        return IsObject(object) && object is Func && !object.IsBuiltIn && InStr(object.Name, ".Prototype.")
    }

    ; Generators require yield, which AHK lacks: no value is ever a generator,
    ; so these faithfully return false for every object (matching CPython, where
    ; only true generator/generator-function objects qualify).
    static isgenerator(object)
    {
        return false
    }

    static isgeneratorfunction(object)
    {
        return false
    }

    ; Coroutines/awaitables are modeled by stdlib.asyncio. Detect them by their
    ; structural markers (duck-typing) so inspect does not hard-require asyncio
    ; to be loaded: a coroutine exposes the asyncio step hook; a future/task is
    ; awaitable; a coroutine function returns a coroutine when called.
    static iscoroutine(object)
    {
        return AhkStdlibInspectIsCoroutine(object)
    }

    static iscoroutinefunction(object)
    {
        return AhkStdlibInspectIsCoroutineFunction(object)
    }

    static isawaitable(object)
    {
        return AhkStdlibInspectIsAwaitable(object)
    }

    static callable(object)
    {
        return IsObject(object) && HasMethod(object, "Call")
    }

    static getmro(cls)
    {
        if !AhkStdlibInspect.isclass(cls)
            throw TypeError("getmro() argument must be a class", -1)
        chain := []
        current := cls
        while IsObject(current) && Type(current) = "Class" {
            chain.Push(current)
            current := current.Base
            ; Stop at the root Class/Object base.
            if !IsObject(current) || !HasProp(current, "Prototype")
                break
        }
        return stdlib.tuple(chain)
    }

    static getsourcefile(object)
    {
        located := AhkStdlibInspectLocateSource(object)
        if located = ""
            return stdlib.None
        return located.file
    }

    static getfile(object)
    {
        if !IsObject(object)
            throw TypeError("module, class, method, function, traceback, frame, or code object was expected, got " AhkStdlibPythonTypeName(object), -1)
        located := AhkStdlibInspectLocateSource(object)
        if located = ""
            throw OSError("could not find the source file for the given object", -1)
        return located.file
    }

    static getsource(object)
    {
        lines := AhkStdlibInspect.getsourcelines(object)[1]
        text := ""
        for line in lines
            text .= line
        return text
    }

    static getsourcelines(object)
    {
        if !IsObject(object)
            throw TypeError("module, class, method, function, traceback, frame, or code object was expected, got " AhkStdlibPythonTypeName(object), -1)
        if !(object is Func) && !(object is Class)
            throw TypeError("module, class, method, function, traceback, frame, or code object was expected, got " AhkStdlibPythonTypeName(object), -1)
        located := AhkStdlibInspectLocateSource(object)
        if located = ""
            throw OSError("could not get source code", -1)
        ; CPython getsourcelines returns (list-of-lines-with-newline, startline).
        lineList := []
        for raw in StrSplit(located.source, "`n", "`r")
            lineList.Push(raw "`n")
        ; The final source line carries no trailing newline unless the file did.
        if lineList.Length > 0 && !located.trailingNewline
            lineList[lineList.Length] := RTrim(lineList[lineList.Length], "`n")
        return stdlib.tuple([lineList, located.line])
    }

    static getmembers(object, predicate := unset)
    {
        members := []
        seen := Map()
        for name in AhkStdlibInspectPropNames(object) {
            if seen.Has(name)
                continue
            seen[name] := true
            value := AhkStdlibInspectTryGet(object, name)
            if IsSet(predicate) && !AhkStdlibIsNone(predicate) {
                if !AhkStdlibTruthValue(predicate.Call(value))
                    continue
            }
            members.Push(stdlib.tuple([name, value]))
        }
        ; Python returns members sorted by name.
        AhkStdlibInspectSortPairs(members)
        return members
    }

    static getdoc(object)
    {
        if IsObject(object) && HasProp(object, "__doc__") {
            doc := object.__doc__
            if doc is String
                return doc
        }
        return stdlib.None
    }

    static signature(callable, kwargs*)
    {
        return AhkStdlibInspectSignature(callable)
    }

    static getfullargspec(func)
    {
        sig := AhkStdlibInspectSignature(func)
        args := []
        varargs := stdlib.None
        for param in sig.AhkStdlibParameters {
            if param.kind = AhkStdlibInspectParameter.VAR_POSITIONAL
                varargs := param.name
            else
                args.Push(param.name)
        }
        return AhkStdlibInspectFullArgSpec(args, varargs)
    }

    static getmodule(object, kwargs*)
    {
        ; AHK v2 has no real module objects, so unlike CPython we cannot map an
        ; arbitrary function/class back to a defining module. We honour the only
        ; introspectable case: an explicit module-like namespace (SimpleNamespace
        ; or types.ModuleType carrying the module marker). Everything else yields
        ; None, matching Python's behaviour for non-introspectable inputs
        ; (e.g. inspect.getmodule(42) -> None).
        if AhkStdlibInspect.ismodule(object)
            return object
        return stdlib.None
    }

    static currentframe(kwargs*)
    {
        ; CPython returns the caller's live frame object. AHK has no frame
        ; objects, so we reconstruct a frame-like record (.filename/.lineno/
        ; .function) for the caller by parsing a freshly thrown Error's stack.
        frames := AhkStdlibInspectCaptureFrames()
        if frames.Length = 0
            return stdlib.None
        return frames[1]
    }

    static stack(kwargs*)
    {
        ; Returns frame-like records from the caller outward (caller first),
        ; mirroring inspect.stack() ordering (innermost frame first).
        return AhkStdlibInspectCaptureFrames()
    }

    static trace(error := unset, kwargs*)
    {
        ; CPython's trace() walks the traceback of the exception currently being
        ; handled. AHK exposes no "current exception" outside a catch block, so
        ; we accept the caught Error explicitly and parse its .Stack into
        ; frame-like records (innermost/raise site first). With no Error given
        ; there is no active traceback, so we return an empty list.
        if !IsSet(error)
            return []
        if !(IsObject(error) && HasProp(error, "Stack"))
            throw TypeError("trace() argument must be an Error with a Stack", -1)
        return AhkStdlibInspectParseStack(error.Stack)
    }
}

class AhkStdlibInspectFrameInfo
{
    __New(filename, lineno, functionName, code)
    {
        this.filename := filename
        this.lineno := lineno
        this.function := functionName
        this.code := code
    }

    __Repr()
    {
        return "<FrameInfo " this.filename ":" this.lineno " in " this.function ">"
    }
}

AhkStdlibInspectCaptureFrames()
{
    ; Throw+catch to obtain a stack, then drop the internal inspect frames so
    ; the first record is the genuine caller of the public API.
    try {
        throw Error("inspect-frame-probe")
    } catch as e {
        frames := AhkStdlibInspectParseStack(e.Stack)
    }
    result := []
    for frame in frames {
        ; Skip our own machinery (helper free-functions AhkStdlibInspect* and the
        ; AhkStdlibInspect.<method> public entry points all share this prefix).
        if SubStr(frame.function, 1, 16) = "AhkStdlibInspect"
            continue
        result.Push(frame)
    }
    return result
}

AhkStdlibInspectParseStack(stackText)
{
    frames := []
    if !(stackText is String) || stackText = ""
        return frames
    for line in StrSplit(stackText, "`n", "`r") {
        if line = ""
            continue
        ; AHK stack lines look like:
        ;   FILENAME (LINENO) : [FUNCNAME] SOURCETEXT
        ; The trailing "> Auto-execute" marker has no frame data.
        if !RegExMatch(line, "^(.*) \((\d+)\) : \[([^\]]*)\] (.*)$", &m)
            continue
        frames.Push(AhkStdlibInspectFrameInfo(m[1], Integer(m[2]), m[3], m[4]))
    }
    return frames
}

class AhkStdlibInspectParameter
{
    ; Kind constants mirror Python's inspect.Parameter.
    static POSITIONAL_ONLY := 0
    static POSITIONAL_OR_KEYWORD := 1
    static VAR_POSITIONAL := 2
    static KEYWORD_ONLY := 3
    static VAR_KEYWORD := 4

    static empty := AhkStdlibInspectEmptyClass

    __New(name, kind, hasDefault := false, defaultValue := unset)
    {
        this.name := name
        this.kind := kind
        if hasDefault
            this.default := defaultValue
        else
            this.default := AhkStdlibInspectEmptyClass
        this.annotation := AhkStdlibInspectEmptyClass
    }

    __Repr()
    {
        return "<Parameter " this.AhkStdlibFormat() ">"
    }

    AhkStdlibFormat()
    {
        text := this.name
        if this.kind = AhkStdlibInspectParameter.VAR_POSITIONAL
            text := "*" text
        else if this.kind = AhkStdlibInspectParameter.VAR_KEYWORD
            text := "**" text
        if !AhkStdlibInspectIsEmpty(this.default)
            text .= "=" AhkStdlibInspectValueRepr(this.default)
        return text
    }
}

class AhkStdlibInspectSignature
{
    __New(callable)
    {
        if !(IsObject(callable) && HasMethod(callable, "Call"))
            throw TypeError("'" AhkStdlibPythonTypeName(callable) "' is not a callable object", -1)

        this.AhkStdlibCallable := callable
        this.AhkStdlibParameters := AhkStdlibInspectBuildParameters(callable)

        ordered := Map()
        ordered.Default := ""
        params := this.AhkStdlibParameters
        this.parameters := AhkStdlibInspectOrderedParams(params)
    }

    parameters_list()
    {
        return this.AhkStdlibParameters
    }

    __Repr()
    {
        return "<Signature " this.AhkStdlibFormat() ">"
    }

    AhkStdlibFormat()
    {
        parts := []
        for param in this.AhkStdlibParameters
            parts.Push(param.AhkStdlibFormat())
        joined := ""
        for p in parts
            joined := joined = "" ? p : joined ", " p
        return "(" joined ")"
    }

    ToString()
    {
        return this.AhkStdlibFormat()
    }
}

stdlib.inspect := AhkStdlibInspect

; Coroutine/awaitable detection mirrors stdlib.asyncio's model without requiring
; it to be loaded: a coroutine carries the asyncio step hook (AhkStdlibAsyncioStep),
; a future/task additionally exposes add_done_callback + done.
AhkStdlibInspectIsCoroutine(object)
{
    return IsObject(object) && HasMethod(object, "AhkStdlibAsyncioStep")
}

AhkStdlibInspectIsAwaitable(object)
{
    if !IsObject(object)
        return false
    if HasMethod(object, "AhkStdlibAsyncioStep")
        return true
    ; Futures/Tasks are awaitable: they expose add_done_callback + done.
    return HasMethod(object, "add_done_callback") && HasMethod(object, "done")
}

AhkStdlibInspectIsCoroutineFunction(object)
{
    if !IsObject(object) || !HasMethod(object, "Call")
        return false
    ; A coroutine function returns a coroutine when invoked with no args. Guard
    ; the probe call so non-coroutine callables (which may need args or have
    ; side effects) never raise out of a predicate.
    try result := object.Call()
    catch
        return false
    return AhkStdlibInspectIsCoroutine(result)
}


; ---------------------------------------------------------------------------
; Sentinel for "no value" (Python's inspect._empty).
; ---------------------------------------------------------------------------

class AhkStdlibInspectEmptyClass
{
}

AhkStdlibInspectIsEmpty(value)
{
    return IsObject(value) && value == AhkStdlibInspectEmptyClass
}

AhkStdlibInspectBuildParameters(callable)
{
    ; Note: AHK identifiers are case-insensitive, so a local named `func` would
    ; shadow the built-in `Func` class and break `is Func` checks. Use `routine`.
    routine := callable
    ; Bound methods drop the implicit `this`/first parameter.
    boundOffset := 0
    if callable is BoundFunc {
        boundOffset := 1
    }

    if !(routine is Func) && !(routine is BoundFunc) {
        ; Callable object with a Call method.
        if HasMethod(callable, "Call") {
            routine := callable.Call
            ; Calling through .Call adds an implicit `this`.
            boundOffset := 1
        }
    }

    minParams := AhkStdlibInspectFuncProp(routine, "MinParams", 0)
    maxParams := AhkStdlibInspectFuncProp(routine, "MaxParams", minParams)
    isVariadic := AhkStdlibInspectFuncProp(routine, "IsVariadic", false)

    params := []
    index := 1
    total := maxParams
    while index <= total {
        if index <= boundOffset {
            index += 1
            continue
        }
        paramName := "arg" (index - boundOffset)
        hasDefault := index > minParams
        param := AhkStdlibInspectParameter(paramName, AhkStdlibInspectParameter.POSITIONAL_OR_KEYWORD, hasDefault, hasDefault ? stdlib.None : unset)
        params.Push(param)
        index += 1
    }

    if isVariadic {
        params.Push(AhkStdlibInspectParameter("args", AhkStdlibInspectParameter.VAR_POSITIONAL))
    }

    return params
}

AhkStdlibInspectFuncProp(func, propName, defaultValue)
{
    if IsObject(func) && HasProp(func, propName) {
        try
            return func.%propName%
    }
    return defaultValue
}

AhkStdlibInspectOrderedParams(params)
{
    ordered := Map()
    for param in params
        ordered[param.name] := param
    return ordered
}

class AhkStdlibInspectFullArgSpec
{
    __New(args, varargs)
    {
        this.args := args
        this.varargs := varargs
        this.varkw := stdlib.None
        this.defaults := stdlib.None
        this.kwonlyargs := []
        this.kwonlydefaults := stdlib.None
        this.annotations := Map()
    }
}

AhkStdlibInspectPropNames(object)
{
    names := []
    if !IsObject(object)
        return names
    try {
        for name in object.OwnProps()
            names.Push(name)
    }
    ; Include prototype methods for class instances.
    return names
}

AhkStdlibInspectTryGet(object, name)
{
    try
        return object.%name%
    catch
        return stdlib.None
}

AhkStdlibInspectSortPairs(pairs)
{
    n := pairs.Length
    Loop n {
        i := A_Index
        Loop n - i {
            j := i + A_Index
            if StrCompare(pairs[j][1], pairs[i][1]) < 0 {
                tmp := pairs[i]
                pairs[i] := pairs[j]
                pairs[j] := tmp
            }
        }
    }
}

AhkStdlibInspectValueRepr(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if value is String
        return "'" value "'"
    if IsObject(value)
        return "<object>"
    return String(value)
}

; ---------------------------------------------------------------------------
; Source location (getsource/getsourcelines/getsourcefile/getfile)
;
; AHK exposes no file/line metadata on a Func/Class, but a named function or
; class is locatable by scanning the source roots (the stdlib directory and
; the running script's directory) for its definition. This mirrors CPython's
; contract: return the source when it can be found, raise OSError otherwise
; (CPython's getsource raises OSError for C builtins / REPL-defined objects
; that have no retrievable source). Closures/bound methods carry no name and
; are reported unavailable, exactly as CPython reports lambdas it cannot find.
; ---------------------------------------------------------------------------
AhkStdlibInspectLocateSource(object)
{
    if !IsObject(object)
        return ""

    if object is Class {
        name := ""
        try name := object.Prototype.__Class
        if name = ""
            return ""
        ; A nested name like "Outer.Inner" is located by its final segment.
        if InStr(name, ".") {
            parts := StrSplit(name, ".")
            name := parts[parts.Length]
        }
        return AhkStdlibInspectScanForDefinition(name, "class")
    }

    if object is Func {
        if object is BoundFunc
            return ""
        name := ""
        try name := object.Name
        if name = "" || InStr(name, ">")   ; fat-arrow funcs report a "...=>..." synthetic name
            return ""
        return AhkStdlibInspectScanForDefinition(name, "func")
    }

    return ""
}

AhkStdlibInspectSourceRoots()
{
    static roots := ""
    if roots != ""
        return roots
    list := []
    ; The stdlib directory is the directory holding this file (lexical A_LineFile).
    SplitPath(A_LineFile, , &stdlibDir)
    if stdlibDir != ""
        list.Push(stdlibDir)
    ; The running script's directory (user code).
    if A_ScriptDir != "" && A_ScriptDir != stdlibDir
        list.Push(A_ScriptDir)
    roots := list
    return roots
}

AhkStdlibInspectScanForDefinition(name, kind)
{
    found := ""
    matchCount := 0
    seen := Map()
    for root in AhkStdlibInspectSourceRoots() {
        loop files root "\*.ahk", "FR" {
            ; The roots can overlap (A_ScriptDir may sit under the stdlib dir),
            ; so dedupe by canonical full path before counting a match.
            key := StrLower(A_LoopFileFullPath)
            if seen.Has(key)
                continue
            seen[key] := true
            try content := FileRead(A_LoopFileFullPath, "UTF-8")
            catch
                continue
            hit := AhkStdlibInspectFindInFile(content, name, kind)
            if hit != "" {
                matchCount += 1
                if found = "" {
                    found := hit
                    found.file := A_LoopFileFullPath
                }
            }
        }
    }
    ; A unique definition is safe to return; an ambiguous name (same identifier
    ; defined in multiple files) cannot be resolved without real metadata, so
    ; report it unavailable rather than guess wrong.
    if matchCount != 1
        return ""
    return found
}

AhkStdlibInspectFindInFile(content, name, kind)
{
    lines := StrSplit(content, "`n", "`r")
    if kind = "class"
        pattern := "^\s*class\s+\Q" name "\E\b"
    else
        pattern := "^\s*\Q" name "\E\s*\("
    for index, line in lines {
        if !RegExMatch(line, pattern)
            continue
        block := AhkStdlibInspectExtractBlock(lines, index)
        if block = ""
            continue
        return {line: index, source: block.text, trailingNewline: block.trailingNewline}
    }
    return ""
}

; From a definition's first line, accumulate the full block. A brace block
; runs until brace depth returns to zero; a fat-arrow (=>) single-statement
; body with no opening brace is just its own line(s) up to balanced parens.
AhkStdlibInspectExtractBlock(lines, startIndex)
{
    depth := 0
    sawBrace := false
    collected := []
    i := startIndex
    while i <= lines.Length {
        line := lines[i]
        collected.Push(line)
        scan := AhkStdlibInspectScanBraces(line)
        depth += scan.delta
        if scan.hadBrace
            sawBrace := true
        ; Fat-arrow body on the very first line with no brace -> single line.
        if i = startIndex && !sawBrace && InStr(AhkStdlibInspectStripCommentsAndStrings(line), "=>")
            return {text: line, trailingNewline: true}
        if sawBrace && depth <= 0
            return {text: AhkStdlibInspectJoinLines(collected), trailingNewline: true}
        i += 1
    }
    ; Unterminated (should not happen on valid source).
    if sawBrace
        return ""
    return ""
}

AhkStdlibInspectJoinLines(lines)
{
    text := ""
    for idx, line in lines {
        if idx > 1
            text .= "`n"
        text .= line
    }
    return text
}

; Count net brace depth change on a line, ignoring braces inside double-quoted
; strings (with `" escapes) and after an unquoted line comment (;).
AhkStdlibInspectScanBraces(line)
{
    delta := 0
    hadBrace := false
    inString := false
    i := 1
    n := StrLen(line)
    while i <= n {
        ch := SubStr(line, i, 1)
        if inString {
            if ch = "``" {
                i += 2          ; skip escaped char
                continue
            }
            if ch = '"'
                inString := false
            i += 1
            continue
        }
        if ch = '"' {
            inString := true
            i += 1
            continue
        }
        if ch = ";" {
            ; Line comment: only when preceded by whitespace or at column 1.
            prev := i > 1 ? SubStr(line, i - 1, 1) : " "
            if prev = " " || prev = "`t" || i = 1
                break
        }
        if ch = "{" {
            delta += 1
            hadBrace := true
        } else if ch = "}" {
            delta -= 1
            hadBrace := true
        }
        i += 1
    }
    return {delta: delta, hadBrace: hadBrace}
}

AhkStdlibInspectStripCommentsAndStrings(line)
{
    out := ""
    inString := false
    i := 1
    n := StrLen(line)
    while i <= n {
        ch := SubStr(line, i, 1)
        if inString {
            if ch = "``" {
                i += 2
                continue
            }
            if ch = '"'
                inString := false
            i += 1
            continue
        }
        if ch = '"' {
            inString := true
            i += 1
            continue
        }
        if ch = ";" {
            prev := i > 1 ? SubStr(line, i - 1, 1) : " "
            if prev = " " || prev = "`t" || i = 1
                break
        }
        out .= ch
        i += 1
    }
    return out
}
