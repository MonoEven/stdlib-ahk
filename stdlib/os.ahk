#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibOs
{
    static sep := "\"
    static altsep := "/"
    static extsep := "."
    static pathsep := ";"
    static linesep := "`r`n"
    static name := "nt"
    static curdir := "."
    static pardir := ".."
    static devnull := "nul"

    static path := AhkStdlibOsPath

    static error := OSError

    static system(command)
    {
        if !(command is String)
            throw TypeError("system() argument 'command' must be str, not " Type(command), -1)
        AhkStdlibOsCheckCommand(command)
        return RunWait(A_ComSpec " /c " command, , "Hide")
    }

    static getcwd()
    {
        return A_WorkingDir
    }

    static chdir(path)
    {
        target := AhkStdlibOsPathString(path)
        if !DirExist(target)
            throw AhkStdlibOsFileNotFoundError(target)
        try
            SetWorkingDir target
        catch as err
            throw OSError("could not change directory to '" target "': " err.Message, -1)
        return stdlib.None
    }

    static listdir(path := ".")
    {
        target := AhkStdlibOsPathString(path)
        if target = ""
            target := "."
        if !DirExist(target)
            throw AhkStdlibOsFileNotFoundError(target)
        result := []
        Loop Files, RTrim(target, "\/") "\*", "FD"
            result.Push(A_LoopFileName)
        return result
    }

    static scandir(path := ".")
    {
        target := AhkStdlibOsPathString(path)
        if target = ""
            target := "."
        if !DirExist(target)
            throw AhkStdlibOsFileNotFoundError(target)
        entries := []
        Loop Files, RTrim(target, "\/") "\*", "FD"
            entries.Push(AhkStdlibOsDirEntry(A_LoopFileName, A_LoopFileFullPath, A_LoopFileAttrib))
        return AhkStdlibOsScandirIterator(entries)
    }

    static mkdir(path, mode := 511)
    {
        target := AhkStdlibOsPathString(path)
        if DirExist(target)
            throw OSError("[WinError 183] Cannot create a file when that file already exists: '" target "'", -1)
        parent := AhkStdlibOsPathDirname(target)
        if parent != "" && !DirExist(parent)
            throw AhkStdlibOsFileNotFoundError(target)
        try
            DirCreate target
        catch as err
            throw OSError("could not create directory '" target "': " err.Message, -1)
        return stdlib.None
    }

    static makedirs(path, mode := 511, exist_ok := false)
    {
        target := AhkStdlibOsPathString(path)
        if DirExist(target) {
            if AhkStdlibTruthValue(exist_ok)
                return stdlib.None
            throw OSError("[WinError 183] Cannot create a file when that file already exists: '" target "'", -1)
        }
        try
            DirCreate target
        catch as err
            throw OSError("could not create directories '" target "': " err.Message, -1)
        return stdlib.None
    }

    static rmdir(path)
    {
        target := AhkStdlibOsPathString(path)
        if !DirExist(target)
            throw AhkStdlibOsFileNotFoundError(target)
        try
            DirDelete target, false
        catch as err
            throw OSError("could not remove directory '" target "': " err.Message, -1)
        return stdlib.None
    }

    static removedirs(path)
    {
        target := AhkStdlibOsPathString(path)
        AhkStdlibOs.rmdir(target)
        parent := AhkStdlibOsPathDirname(target)
        while parent != "" && DirExist(parent) {
            try
                DirDelete parent, false
            catch
                break
            parent := AhkStdlibOsPathDirname(parent)
        }
        return stdlib.None
    }

    static remove(path)
    {
        target := AhkStdlibOsPathString(path)
        if DirExist(target)
            throw OSError("[WinError 5] Access is denied: '" target "'", -1)
        if !FileExist(target)
            throw AhkStdlibOsFileNotFoundError(target)
        try
            FileDelete target
        catch as err
            throw OSError("could not remove file '" target "': " err.Message, -1)
        return stdlib.None
    }

    static unlink(path)
    {
        return AhkStdlibOs.remove(path)
    }

    static rename(src, dst)
    {
        source := AhkStdlibOsPathString(src)
        target := AhkStdlibOsPathString(dst)
        if !FileExist(source) && !DirExist(source)
            throw AhkStdlibOsFileNotFoundError(source)
        try {
            if DirExist(source)
                DirMove source, target, "R"
            else
                FileMove source, target, false
        } catch as err {
            throw OSError("could not rename '" source "' to '" target "': " err.Message, -1)
        }
        return stdlib.None
    }

    static replace(src, dst)
    {
        source := AhkStdlibOsPathString(src)
        target := AhkStdlibOsPathString(dst)
        if !FileExist(source) && !DirExist(source)
            throw AhkStdlibOsFileNotFoundError(source)
        try {
            if DirExist(source)
                DirMove source, target, "R"
            else
                FileMove source, target, true
        } catch as err {
            throw OSError("could not replace '" target "' with '" source "': " err.Message, -1)
        }
        return stdlib.None
    }

    static stat(path)
    {
        target := AhkStdlibOsPathString(path)
        if !FileExist(target) && !DirExist(target)
            throw AhkStdlibOsFileNotFoundError(target)
        return AhkStdlibOsStatResult(target)
    }

    static walk(top, topdown := true)
    {
        root := AhkStdlibOsPathString(top)
        results := []
        AhkStdlibOsWalkInto(root, AhkStdlibTruthValue(topdown), results)
        return AhkStdlibOsWalkIterator(results)
    }

    static getenv(key, default := "")
    {
        value := EnvGet(key)
        if value = "" && !AhkStdlibOsEnvExists(key)
            return IsSet(default) ? default : stdlib.None
        return value
    }

    static putenv(key, value)
    {
        EnvSet key, value
        return stdlib.None
    }

    static unsetenv(key)
    {
        EnvSet key, ""
        return stdlib.None
    }

    static getpid()
    {
        return DllCall("GetCurrentProcessId", "UInt")
    }

    static cpu_count()
    {
        count := EnvGet("NUMBER_OF_PROCESSORS")
        if count = ""
            return stdlib.None
        return Integer(count)
    }

    static urandom(size)
    {
        if !(size is Integer) || size < 0
            throw ValueError("negative argument not allowed", -1)
        buf := Buffer(size, 0)
        if size > 0 {
            status := DllCall("bcrypt\BCryptGenRandom", "Ptr", 0, "Ptr", buf.Ptr, "UInt", size, "UInt", 0x00000002, "UInt")
            if status != 0
                throw OSError("BCryptGenRandom failed", -1)
        }
        return buf
    }

    static startfile(path, operation := "open")
    {
        target := AhkStdlibOsPathString(path)
        Run target
        return stdlib.None
    }

    static abort()
    {
        ExitApp 3
    }
}

class AhkStdlibOsEnviron
{
    static __Get(key, params)
    {
        return AhkStdlibOs.getenv(key)
    }
}

stdlib.os := AhkStdlibOs

; ---------------------------------------------------------------------------
; os.path submodule
; ---------------------------------------------------------------------------

class AhkStdlibOsPath
{
    static sep := "\"
    static altsep := "/"
    static extsep := "."
    static pathsep := ";"

    static join(first, parts*)
    {
        return AhkStdlibOsPathJoin(first, parts*)
    }

    static split(path)
    {
        return AhkStdlibOsPathSplit(path)
    }

    static splitext(path)
    {
        return AhkStdlibOsPathSplitext(path)
    }

    static splitdrive(path)
    {
        return AhkStdlibOsPathSplitdrive(path)
    }

    static basename(path)
    {
        parts := AhkStdlibOsPathSplit(path)
        return parts[2]
    }

    static dirname(path)
    {
        parts := AhkStdlibOsPathSplit(path)
        return parts[1]
    }

    static exists(path)
    {
        target := AhkStdlibOsPathString(path)
        return AhkStdlibBool(FileExist(target) != "" || DirExist(target) != "")
    }

    static lexists(path)
    {
        return AhkStdlibOsPath.exists(path)
    }

    static isfile(path)
    {
        target := AhkStdlibOsPathString(path)
        return AhkStdlibBool(FileExist(target) != "" && DirExist(target) = "")
    }

    static isdir(path)
    {
        target := AhkStdlibOsPathString(path)
        return AhkStdlibBool(DirExist(target) != "")
    }

    static islink(path)
    {
        target := AhkStdlibOsPathString(path)
        attrib := FileExist(target)
        return AhkStdlibBool(attrib != "" && InStr(attrib, "L"))
    }

    static isabs(path)
    {
        target := AhkStdlibOsPathString(path)
        return AhkStdlibBool(AhkStdlibOsPathIsAbs(target))
    }

    static normpath(path)
    {
        return AhkStdlibOsPathNormpath(path)
    }

    static abspath(path)
    {
        return AhkStdlibOsPathAbspath(path)
    }

    static realpath(path, args*)
    {
        return AhkStdlibOsPathAbspath(path)
    }

    static normcase(path)
    {
        target := AhkStdlibOsPathString(path)
        return StrLower(StrReplace(target, "/", "\"))
    }

    static getsize(path)
    {
        target := AhkStdlibOsPathString(path)
        if !FileExist(target) && !DirExist(target)
            throw AhkStdlibOsFileNotFoundError(target)
        return FileGetSize(target)
    }

    static getmtime(path)
    {
        return AhkStdlibOsPathTimestamp(path, "M")
    }

    static getatime(path)
    {
        return AhkStdlibOsPathTimestamp(path, "A")
    }

    static getctime(path)
    {
        return AhkStdlibOsPathTimestamp(path, "C")
    }

    static expanduser(path)
    {
        return AhkStdlibOsPathExpanduser(path)
    }

    static expandvars(path)
    {
        return AhkStdlibOsPathExpandvars(path)
    }

    static commonprefix(paths)
    {
        return AhkStdlibOsPathCommonprefix(paths)
    }

    static commonpath(paths)
    {
        return AhkStdlibOsPathCommonpath(paths)
    }

    static relpath(path, start := ".")
    {
        return AhkStdlibOsPathRelpath(path, start)
    }

    static samefile(path1, path2)
    {
        a := AhkStdlibOsPathAbspath(path1)
        b := AhkStdlibOsPathAbspath(path2)
        return AhkStdlibBool(StrLower(a) = StrLower(b))
    }
}

; ---------------------------------------------------------------------------
; Helper functions
; ---------------------------------------------------------------------------

AhkStdlibOsCheckCommand(command)
{
    Loop StrLen(command) {
        if Ord(SubStr(command, A_Index, 1)) = 0
            throw ValueError("embedded null character", -1)
    }
}

AhkStdlibOsPathString(path)
{
    if IsObject(path) {
        if HasProp(path, "Path")
            return path.Path
        if HasMethod(path, "__fspath__")
            return path.__fspath__()
        return String(path)
    }
    return path ""
}

AhkStdlibOsFileNotFoundError(path)
{
    return OSError("[WinError 2] The system cannot find the file specified: '" path "'", -1)
}

AhkStdlibOsEnvExists(key)
{
    ; EnvGet returns "" for both empty and missing; probe the process block.
    size := DllCall("GetEnvironmentVariable", "Str", key, "Ptr", 0, "UInt", 0, "UInt")
    return size != 0
}

AhkStdlibOsPathIsAbs(path)
{
    path := StrReplace(path, "/", "\")
    if SubStr(path, 1, 2) = "\\"
        return true
    if RegExMatch(path, "i)^[a-z]:\\")
        return true
    if SubStr(path, 1, 1) = "\"
        return true
    return false
}

AhkStdlibOsPathJoin(first, parts*)
{
    result := AhkStdlibOsPathString(first)
    for part in parts {
        component := AhkStdlibOsPathString(part)
        if component = ""
            continue
        ; Drive-rooted or absolute component resets per Windows os.path.join.
        if RegExMatch(component, "i)^[a-z]:") {
            ; Has a drive letter.
            resultDrive := AhkStdlibOsPathSplitdriveRaw(result)[1]
            compDrive := AhkStdlibOsPathSplitdriveRaw(component)[1]
            compRest := AhkStdlibOsPathSplitdriveRaw(component)[2]
            if AhkStdlibOsPathIsRooted(compRest) {
                result := component
                continue
            }
            if compDrive != "" && StrLower(compDrive) != StrLower(resultDrive) {
                result := component
                continue
            }
            ; Same drive, relative rest: append onto current.
            result := AhkStdlibOsPathJoinTwo(result, compRest)
            continue
        }
        if AhkStdlibOsPathIsRooted(component) {
            ; Rooted but no drive: keep current drive prefix.
            drive := AhkStdlibOsPathSplitdriveRaw(result)[1]
            result := drive component
            continue
        }
        result := AhkStdlibOsPathJoinTwo(result, component)
    }
    return result
}

AhkStdlibOsPathJoinTwo(left, right)
{
    if left = ""
        return right
    last := SubStr(left, -1)
    if last = "\" || last = "/" || last = ":"
        return left right
    return left "\" right
}

AhkStdlibOsPathIsRooted(path)
{
    first := SubStr(path, 1, 1)
    return first = "\" || first = "/"
}

AhkStdlibOsPathSplitdriveRaw(path)
{
    path := AhkStdlibOsPathString(path)
    ; UNC path \\host\share
    if RegExMatch(path, "^[\\/]{2}[^\\/]+[\\/][^\\/]+", &m) {
        return [m[0], SubStr(path, StrLen(m[0]) + 1)]
    }
    if RegExMatch(path, "i)^[a-z]:") {
        return [SubStr(path, 1, 2), SubStr(path, 3)]
    }
    return ["", path]
}

AhkStdlibOsPathSplitdrive(path)
{
    parts := AhkStdlibOsPathSplitdriveRaw(path)
    return stdlib.tuple([parts[1], parts[2]])
}

AhkStdlibOsPathSplit(path)
{
    target := AhkStdlibOsPathString(path)
    driveParts := AhkStdlibOsPathSplitdriveRaw(target)
    drive := driveParts[1]
    rest := driveParts[2]

    ; Find last separator in rest.
    lastSep := 0
    Loop StrLen(rest) {
        ch := SubStr(rest, A_Index, 1)
        if ch = "\" || ch = "/"
            lastSep := A_Index
    }

    if lastSep = 0 {
        return stdlib.tuple([drive, rest])
    }

    head := SubStr(rest, 1, lastSep)
    tail := SubStr(rest, lastSep + 1)
    ; Strip trailing slashes from head unless it is all slashes (root).
    headStripped := RegExReplace(head, "[\\/]+$")
    if headStripped = ""
        headStripped := head  ; root like "\"
    else
        head := headStripped
    return stdlib.tuple([drive head, tail])
}

AhkStdlibOsPathSplitext(path)
{
    target := AhkStdlibOsPathString(path)
    ; Find basename start.
    baseStart := 0
    Loop StrLen(target) {
        ch := SubStr(target, A_Index, 1)
        if ch = "\" || ch = "/"
            baseStart := A_Index
    }
    base := SubStr(target, baseStart + 1)
    ; Leading dots are part of name, not extension.
    leadingDots := 0
    Loop StrLen(base) {
        if SubStr(base, A_Index, 1) = "."
            leadingDots := A_Index
        else
            break
    }
    dotPos := 0
    Loop StrLen(base) {
        if A_Index <= leadingDots
            continue
        if SubStr(base, A_Index, 1) = "."
            dotPos := A_Index
    }
    if dotPos = 0
        return stdlib.tuple([target, ""])
    splitAt := baseStart + dotPos
    return stdlib.tuple([SubStr(target, 1, splitAt - 1), SubStr(target, splitAt)])
}

AhkStdlibOsPathDirname(path)
{
    return AhkStdlibOsPathSplit(path)[1]
}

AhkStdlibOsPathNormpath(path)
{
    target := AhkStdlibOsPathString(path)
    if target = ""
        return "."

    target := StrReplace(target, "/", "\")
    driveParts := AhkStdlibOsPathSplitdriveRaw(target)
    drive := driveParts[1]
    rest := driveParts[2]

    isAbsolute := SubStr(rest, 1, 1) = "\"
    rest := RegExReplace(rest, "^\\+")

    components := StrSplit(rest, "\")
    stack := []
    for comp in components {
        if comp = "" || comp = "."
            continue
        if comp = ".." {
            if stack.Length > 0 && stack[stack.Length] != ".." {
                stack.Pop()
            } else if !isAbsolute {
                stack.Push("..")
            }
            ; If absolute and stack empty, .. at root is dropped.
            continue
        }
        stack.Push(comp)
    }

    joined := ""
    for comp in stack
        joined := joined = "" ? comp : joined "\" comp

    prefix := drive
    if isAbsolute
        prefix .= "\"

    result := prefix joined
    if result = ""
        return "."
    return result
}

AhkStdlibOsPathAbspath(path)
{
    target := AhkStdlibOsPathString(path)
    if target = ""
        target := "."
    if !AhkStdlibOsPathIsAbs(target) {
        target := A_WorkingDir "\" target
    } else {
        ; Rooted without drive: prepend current drive.
        driveParts := AhkStdlibOsPathSplitdriveRaw(target)
        if driveParts[1] = "" && AhkStdlibOsPathIsRooted(StrReplace(target, "/", "\")) {
            curDrive := AhkStdlibOsPathSplitdriveRaw(A_WorkingDir)[1]
            target := curDrive target
        }
    }
    return AhkStdlibOsPathNormpath(target)
}

AhkStdlibOsPathTimestamp(path, which)
{
    target := AhkStdlibOsPathString(path)
    if !FileExist(target) && !DirExist(target)
        throw AhkStdlibOsFileNotFoundError(target)
    stamp := FileGetTime(target, which)
    return AhkStdlibOsTimestampToEpoch(stamp)
}

AhkStdlibOsTimestampToEpoch(stamp)
{
    ; stamp is YYYYMMDDHH24MISS in local time.
    epochDiff := DateDiff(stamp, "19700101000000", "Seconds")
    return epochDiff
}

AhkStdlibOsPathExpanduser(path)
{
    target := AhkStdlibOsPathString(path)
    if SubStr(target, 1, 1) != "~"
        return target
    rest := SubStr(target, 2)
    if rest != "" && SubStr(rest, 1, 1) != "\" && SubStr(rest, 1, 1) != "/"
        return target  ; ~user form not supported
    home := EnvGet("USERPROFILE")
    if home = "" {
        drive := EnvGet("HOMEDRIVE")
        path2 := EnvGet("HOMEPATH")
        home := drive path2
    }
    if home = ""
        return target
    if rest = ""
        return home
    return RTrim(home, "\/") rest
}

AhkStdlibOsPathExpandvars(path)
{
    target := AhkStdlibOsPathString(path)
    ; %VAR% form
    result := RegExReplace(target, "%([^%]+)%", "$1")  ; placeholder, replaced below
    out := ""
    i := 1
    n := StrLen(target)
    while i <= n {
        ch := SubStr(target, i, 1)
        if ch = "%" {
            closing := InStr(target, "%", , i + 1)
            if closing {
                varName := SubStr(target, i + 1, closing - i - 1)
                value := EnvGet(varName)
                if value != "" || AhkStdlibOsEnvExists(varName)
                    out .= value
                else
                    out .= "%" varName "%"
                i := closing + 1
                continue
            }
        }
        if ch = "$" {
            if SubStr(target, i + 1, 1) = "{" {
                closing := InStr(target, "}", , i + 2)
                if closing {
                    varName := SubStr(target, i + 2, closing - i - 2)
                    value := EnvGet(varName)
                    if value != "" || AhkStdlibOsEnvExists(varName)
                        out .= value
                    else
                        out .= "${" varName "}"
                    i := closing + 1
                    continue
                }
            } else if RegExMatch(SubStr(target, i + 1), "^([A-Za-z_][A-Za-z0-9_]*)", &m) {
                varName := m[1]
                value := EnvGet(varName)
                if value != "" || AhkStdlibOsEnvExists(varName)
                    out .= value
                else
                    out .= "$" varName
                i += 1 + StrLen(varName)
                continue
            }
        }
        out .= ch
        i += 1
    }
    return out
}

AhkStdlibOsPathCommonprefix(paths)
{
    items := []
    for p in paths
        items.Push(AhkStdlibOsPathString(p))
    if items.Length = 0
        return ""
    shortest := items[1]
    for item in items {
        if StrLen(item) < StrLen(shortest)
            shortest := item
    }
    Loop StrLen(shortest) {
        pos := A_Index
        ch := SubStr(shortest, pos, 1)
        for item in items {
            if SubStr(item, pos, 1) != ch
                return SubStr(shortest, 1, pos - 1)
        }
    }
    return shortest
}

AhkStdlibOsPathCommonpath(paths)
{
    items := []
    for p in paths
        items.Push(StrReplace(AhkStdlibOsPathString(p), "/", "\"))
    if items.Length = 0
        throw ValueError("commonpath() arg is an empty sequence", -1)

    ; Split into drive + components.
    firstDrive := AhkStdlibOsPathSplitdriveRaw(items[1])[1]
    splitComponents := []
    for item in items {
        dp := AhkStdlibOsPathSplitdriveRaw(item)
        if StrLower(dp[1]) != StrLower(firstDrive)
            throw ValueError("Paths don't have the same drive", -1)
        rest := dp[2]
        comps := []
        for c in StrSplit(rest, "\") {
            if c != ""
                comps.Push(c)
        }
        splitComponents.Push(comps)
    }

    common := []
    minLen := splitComponents[1].Length
    for comps in splitComponents
        minLen := Min(minLen, comps.Length)

    Loop minLen {
        idx := A_Index
        candidate := splitComponents[1][idx]
        same := true
        for comps in splitComponents {
            if comps[idx] != candidate {
                same := false
                break
            }
        }
        if !same
            break
        common.Push(candidate)
    }

    firstRest := AhkStdlibOsPathSplitdriveRaw(items[1])[2]
    isAbsolute := SubStr(firstRest, 1, 1) = "\"
    joined := ""
    for c in common
        joined := joined = "" ? c : joined "\" c
    prefix := firstDrive
    if isAbsolute
        prefix .= "\"
    result := prefix joined
    if result = ""
        return "."
    return result
}

AhkStdlibOsPathRelpath(path, start)
{
    target := AhkStdlibOsPathAbspath(path)
    base := AhkStdlibOsPathAbspath(start = "" ? "." : start)

    targetDrive := AhkStdlibOsPathSplitdriveRaw(target)[1]
    baseDrive := AhkStdlibOsPathSplitdriveRaw(base)[1]
    if StrLower(targetDrive) != StrLower(baseDrive)
        throw ValueError("path is on mount '" targetDrive "', start on mount '" baseDrive "'", -1)

    targetComps := AhkStdlibOsPathComponents(target)
    baseComps := AhkStdlibOsPathComponents(base)

    i := 1
    while i <= targetComps.Length && i <= baseComps.Length {
        if StrLower(targetComps[i]) != StrLower(baseComps[i])
            break
        i += 1
    }

    rel := []
    Loop baseComps.Length - (i - 1)
        rel.Push("..")
    j := i
    while j <= targetComps.Length {
        rel.Push(targetComps[j])
        j += 1
    }

    if rel.Length = 0
        return "."
    result := ""
    for c in rel
        result := result = "" ? c : result "\" c
    return result
}

AhkStdlibOsPathComponents(path)
{
    rest := AhkStdlibOsPathSplitdriveRaw(path)[2]
    rest := RegExReplace(rest, "^\\+")
    comps := []
    for c in StrSplit(rest, "\") {
        if c != ""
            comps.Push(c)
    }
    return comps
}

; ---------------------------------------------------------------------------
; stat result
; ---------------------------------------------------------------------------

class AhkStdlibOsStatResult
{
    __New(path)
    {
        this.AhkStdlibPath := path
        isDir := DirExist(path) != ""
        this.st_size := isDir ? 0 : FileGetSize(path)
        this.st_mtime := AhkStdlibOsTimestampToEpoch(FileGetTime(path, "M"))
        this.st_atime := AhkStdlibOsTimestampToEpoch(FileGetTime(path, "A"))
        this.st_ctime := AhkStdlibOsTimestampToEpoch(FileGetTime(path, "C"))
        this.st_mode := isDir ? 0x4000 : 0x8000
    }
}

; ---------------------------------------------------------------------------
; scandir / DirEntry
; ---------------------------------------------------------------------------

class AhkStdlibOsDirEntry
{
    __New(name, fullPath, attrib)
    {
        this.name := name
        this.path := fullPath
        this.AhkStdlibAttrib := attrib
    }

    is_dir(args*)
    {
        return AhkStdlibBool(InStr(this.AhkStdlibAttrib, "D") != 0)
    }

    is_file(args*)
    {
        return AhkStdlibBool(InStr(this.AhkStdlibAttrib, "D") = 0)
    }

    is_symlink()
    {
        return AhkStdlibBool(InStr(this.AhkStdlibAttrib, "L") != 0)
    }

    stat(args*)
    {
        return AhkStdlibOsStatResult(this.path)
    }

    __fspath__()
    {
        return this.path
    }

    __Repr()
    {
        return "<DirEntry '" this.name "'>"
    }
}

class AhkStdlibOsScandirIterator
{
    __New(entries)
    {
        this.AhkStdlibEntries := entries
        this.AhkStdlibIndex := 0
    }

    __Enum(numberOfVars)
    {
        entries := this.AhkStdlibEntries
        index := 0
        return (&value) => index < entries.Length ? (value := entries[++index], true) : false
    }

    close()
    {
        return stdlib.None
    }
}

; ---------------------------------------------------------------------------
; walk
; ---------------------------------------------------------------------------

AhkStdlibOsWalkInto(root, topdown, results)
{
    if !DirExist(root)
        return

    dirs := []
    files := []
    Loop Files, RTrim(root, "\/") "\*", "FD" {
        if InStr(A_LoopFileAttrib, "D")
            dirs.Push(A_LoopFileName)
        else
            files.Push(A_LoopFileName)
    }

    entry := stdlib.tuple([root, dirs, files])
    if topdown
        results.Push(entry)

    for d in dirs
        AhkStdlibOsWalkInto(RTrim(root, "\/") "\" d, topdown, results)

    if !topdown
        results.Push(entry)
}

class AhkStdlibOsWalkIterator
{
    __New(results)
    {
        this.AhkStdlibResults := results
    }

    __Enum(numberOfVars)
    {
        results := this.AhkStdlibResults
        index := 0
        return (&value) => index < results.Length ? (value := results[++index], true) : false
    }
}
