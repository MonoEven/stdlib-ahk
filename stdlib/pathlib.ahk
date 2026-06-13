#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\fnmatch>
#Include <stdlib\os>

class AhkStdlibPathlib
{
    static Path(parts*)
    {
        return AhkStdlibPathlibPath(parts*)
    }

    static cwd()
    {
        return AhkStdlibPathlibPath(A_WorkingDir)
    }

    static home()
    {
        home := EnvGet("USERPROFILE")
        if home = ""
            home := EnvGet("HOMEDRIVE") EnvGet("HOMEPATH")
        return AhkStdlibPathlibPath(home)
    }
}

class AhkStdlibPathlibPath
{
    __New(parts*)
    {
        this.Path := AhkStdlibPathlibNormalizeParts(parts)
    }

    ToString()
    {
        return this.Path
    }

    name
    {
        get {
            if this.Path = "." || AhkStdlibPathlibIsRoot(this.Path)
                return ""
            SplitPath this.Path, &name
            return name
        }
    }

    stem
    {
        get {
            name := this.name
            if name = ""
                return ""
            dot := AhkStdlibPathlibLastDot(name)
            if dot <= 1 || dot = StrLen(name)
                return name
            return SubStr(name, 1, dot - 1)
        }
    }

    suffix
    {
        get {
            name := this.name
            if name = ""
                return ""
            dot := AhkStdlibPathlibLastDot(name)
            if dot <= 1 || dot = StrLen(name)
                return ""
            return SubStr(name, dot)
        }
    }

    parent
    {
        get {
            if this.Path = "."
                return AhkStdlibPathlibPath(".")
            if AhkStdlibPathlibIsRoot(this.Path)
                return AhkStdlibPathlibPath(this.Path)

            trimmed := RTrim(this.Path, "\")
            SplitPath trimmed, , &dir
            if dir = ""
                return AhkStdlibPathlibPath(".")
            ; SplitPath drops the trailing slash on a bare drive ("C:\a" -> "C:");
            ; the parent of a drive-rooted path is the drive root ("C:\").
            if RegExMatch(dir, "i)^[a-z]:$")
                return AhkStdlibPathlibPath(dir "\")
            return AhkStdlibPathlibPath(dir)
        }
    }

    joinpath(parts*)
    {
        path := this.Path
        for part in parts
            path := AhkStdlibPathlibJoin(path, part)
        return AhkStdlibPathlibPath(path)
    }

    Join(parts*)
    {
        return this.joinpath(parts*)
    }

    exists()
    {
        return FileExist(this.Path) != ""
    }

    is_dir()
    {
        return DirExist(this.Path) != ""
    }

    is_file()
    {
        return FileExist(this.Path) != "" && DirExist(this.Path) = ""
    }

    stat()
    {
        if !FileExist(this.Path) && !DirExist(this.Path)
            throw OSError("[WinError 2] The system cannot find the file specified: '" this.Path "'", -1)
        return AhkStdlibOsStatResult(this.Path)
    }

    lstat()
    {
        return this.stat()
    }

    read_text(encoding := "UTF-8")
    {
        return FileRead(this.Path, encoding)
    }

    write_text(text, encoding := "UTF-8")
    {
        if !(text is String)
            throw TypeError("data must be str", -1)

        if this.exists() && !this.is_dir()
            FileDelete this.Path
        FileAppend text, this.Path, encoding
        return StrLen(text)
    }

    mkdir(options := unset)
    {
        parents := AhkStdlibPathlibOption(options?, "parents", "Parents", false)
        existOk := AhkStdlibPathlibOption(options?, "exist_ok", "ExistOk", false)

        if this.is_dir() {
            if existOk
                return
            throw OSError("directory already exists: " this.Path, -1)
        }

        parent := this.parent
        if String(parent) != "." && !parent.is_dir() && !parents
            throw OSError("parent directory does not exist: " String(parent), -1)

        DirCreate this.Path
    }

    unlink(options := unset)
    {
        missingOk := AhkStdlibPathlibOption(options?, "missing_ok", "MissingOk", false)

        if !this.exists() {
            if missingOk
                return
            FileDelete this.Path
            return
        }

        FileDelete this.Path
    }

    rmdir()
    {
        DirDelete this.Path
    }

    rename(target)
    {
        dest := AhkStdlibPathlibPartToString(target)
        FileMove this.Path, dest, false
        return AhkStdlibPathlibPath(dest)
    }

    replace(target)
    {
        dest := AhkStdlibPathlibPartToString(target)
        if FileExist(dest) && !DirExist(dest)
            FileDelete dest
        FileMove this.Path, dest, true
        return AhkStdlibPathlibPath(dest)
    }

    read_bytes()
    {
        return FileRead(this.Path, "RAW")
    }

    write_bytes(data)
    {
        if !(IsObject(data) && HasProp(data, "Ptr") && HasProp(data, "Size"))
            throw TypeError("a bytes-like object is required", -1)
        if this.exists() && !this.is_dir()
            FileDelete this.Path
        file := FileOpen(this.Path, "w")
        try {
            file.RawWrite(data)
        } finally {
            file.Close()
        }
        return data.Size
    }

    touch(options := unset)
    {
        existOk := AhkStdlibPathlibOption(options?, "exist_ok", "ExistOk", true)
        if this.exists() {
            if !existOk
                throw OSError("file already exists: " this.Path, -1)
            FileSetTime , this.Path
            return stdlib.None
        }
        FileAppend "", this.Path
        return stdlib.None
    }

    iterdir()
    {
        if !this.is_dir()
            throw OSError("Not a directory: '" this.Path "'", -1)
        entries := []
        Loop Files, RTrim(this.Path, "\/") "\*", "FD"
            entries.Push(AhkStdlibPathlibPath(A_LoopFileFullPath))
        return AhkStdlibPathlibIterator(entries)
    }

    glob(pattern)
    {
        return AhkStdlibPathlibGlob(this.Path, pattern, false)
    }

    rglob(pattern)
    {
        return AhkStdlibPathlibGlob(this.Path, pattern, true)
    }

    match(pattern)
    {
        return AhkStdlibPathlibMatch(this.Path, AhkStdlibPathlibPartToString(pattern))
    }

    with_name(name)
    {
        newName := AhkStdlibPathlibPartToString(name)
        if newName = "" || InStr(newName, "\") || InStr(newName, "/")
            throw ValueError("Invalid name '" newName "'", -1)
        if this.name = ""
            throw ValueError(String(this) " has an empty name", -1)
        parentStr := String(this.parent)
        if parentStr = "." && !InStr(this.Path, "\") && !InStr(this.Path, "/")
            return AhkStdlibPathlibPath(newName)
        return AhkStdlibPathlibPath(parentStr).joinpath(newName)
    }

    with_stem(stem)
    {
        return this.with_name(AhkStdlibPathlibPartToString(stem) this.suffix)
    }

    with_suffix(suffix)
    {
        suffixStr := AhkStdlibPathlibPartToString(suffix)
        if suffixStr != "" && SubStr(suffixStr, 1, 1) != "."
            throw ValueError("Invalid suffix '" suffixStr "'", -1)
        if InStr(suffixStr, "/") || InStr(suffixStr, "\") || suffixStr = "."
            throw ValueError("Invalid suffix '" suffixStr "'", -1)
        if this.name = ""
            throw ValueError(String(this) " has an empty name", -1)
        return this.with_name(this.stem suffixStr)
    }

    relative_to(other)
    {
        otherStr := AhkStdlibPathlibPartToString(other)
        return AhkStdlibPathlibPath(AhkStdlibPathlibRelativeTo(this.Path, otherStr))
    }

    is_absolute()
    {
        return AhkStdlibPathlibHasDrive(this.Path) && AhkStdlibPathlibIsRooted(SubStr(this.Path, 3))
    }

    absolute()
    {
        if this.is_absolute()
            return AhkStdlibPathlibPath(this.Path)
        return AhkStdlibPathlibPath(A_WorkingDir, this.Path)
    }

    resolve(args*)
    {
        return AhkStdlibPathlibPath(AhkStdlibPathlibResolve(this.Path))
    }

    samefile(other)
    {
        otherStr := AhkStdlibPathlibPartToString(other)
        a := AhkStdlibPathlibResolve(this.Path)
        b := AhkStdlibPathlibResolve(otherStr)
        return StrLower(a) = StrLower(b)
    }

    open(mode := "r", args*)
    {
        return FileOpen(this.Path, mode)
    }

    parts
    {
        get => stdlib.tuple(AhkStdlibPathlibParts(this.Path))
    }

    parents
    {
        get => AhkStdlibPathlibParents(this)
    }

    suffixes
    {
        get => AhkStdlibPathlibSuffixes(this.name)
    }

    anchor
    {
        get {
            driveParts := AhkStdlibPathlibSplitDrive(this.Path)
            root := AhkStdlibPathlibIsRooted(driveParts[2]) ? "\" : ""
            return driveParts[1] root
        }
    }

    drive
    {
        get => AhkStdlibPathlibSplitDrive(this.Path)[1]
    }

    root
    {
        get => AhkStdlibPathlibIsRooted(AhkStdlibPathlibSplitDrive(this.Path)[2]) ? "\" : ""
    }
}

class AhkStdlibPathlibIterator
{
    __New(entries)
    {
        this.AhkStdlibEntries := entries
    }

    __Enum(numberOfVars)
    {
        entries := this.AhkStdlibEntries
        index := 0
        return (&value) => index < entries.Length ? (value := entries[++index], true) : false
    }
}

stdlib.pathlib := AhkStdlibPathlib

AhkStdlibPathlibNormalizeParts(parts)
{
    path := ""
    for part in parts {
        partText := AhkStdlibPathlibPartToString(part)
        if partText = "" || partText = "."
            continue
        path := path = "" ? AhkStdlibPathlibNormalizeSeparators(partText) : AhkStdlibPathlibJoin(path, partText)
    }

    if path = ""
        return "."
    return path
}

AhkStdlibPathlibPartToString(part)
{
    if part is AhkStdlibPathlibPath
        return part.Path
    if IsObject(part)
        return String(part)
    return part ""
}

AhkStdlibPathlibNormalizeSeparators(path)
{
    return StrReplace(path, "/", "\")
}

AhkStdlibPathlibJoin(left, right)
{
    left := AhkStdlibPathlibNormalizeSeparators(AhkStdlibPathlibPartToString(left))
    right := AhkStdlibPathlibNormalizeSeparators(AhkStdlibPathlibPartToString(right))

    if right = "" || right = "."
        return left = "" ? "." : left

    if AhkStdlibPathlibHasDrive(right)
        return right

    if AhkStdlibPathlibIsRooted(right)
        return AhkStdlibPathlibHasDrive(left) ? SubStr(left, 1, 2) right : right

    if left = "" || left = "."
        return right

    return RTrim(left, "\") "\" RegExReplace(right, "^\\+")
}

AhkStdlibPathlibHasDrive(path)
{
    return RegExMatch(path, "i)^[a-z]:")
}

AhkStdlibPathlibIsRooted(path)
{
    return SubStr(path, 1, 1) = "\"
}

AhkStdlibPathlibIsRoot(path)
{
    return path = "\" || RegExMatch(path, "i)^[a-z]:\\?$")
}

AhkStdlibPathlibLastDot(name)
{
    dot := 0
    pos := 1
    loop {
        found := InStr(name, ".", , pos)
        if !found
            break
        dot := found
        pos := found + 1
    }
    return dot
}

AhkStdlibPathlibOption(options := unset, snakeName := "", pascalName := "", defaultValue := false)
{
    if !IsSet(options)
        return defaultValue
    if HasProp(options, snakeName)
        return options.%snakeName%
    if HasProp(options, pascalName)
        return options.%pascalName%
    return defaultValue
}

AhkStdlibPathlibSplitDrive(path)
{
    path := AhkStdlibPathlibNormalizeSeparators(path)
    ; UNC \\host\share
    if RegExMatch(path, "^\\\\[^\\]+\\[^\\]+", &m)
        return [m[0], SubStr(path, StrLen(m[0]) + 1)]
    if RegExMatch(path, "i)^[a-z]:")
        return [SubStr(path, 1, 2), SubStr(path, 3)]
    return ["", path]
}

AhkStdlibPathlibParts(path)
{
    path := AhkStdlibPathlibNormalizeSeparators(path)
    if path = "" || path = "."
        return []
    driveParts := AhkStdlibPathlibSplitDrive(path)
    drive := driveParts[1]
    rest := driveParts[2]
    rooted := AhkStdlibPathlibIsRooted(rest)
    rest := RegExReplace(rest, "^\\+")

    result := []
    anchor := drive (rooted ? "\" : "")
    if anchor != ""
        result.Push(anchor)
    for comp in StrSplit(rest, "\") {
        if comp != ""
            result.Push(comp)
    }
    return result
}

AhkStdlibPathlibParents(pathObj)
{
    entries := []
    current := pathObj.parent
    last := String(pathObj)
    loop {
        currentStr := String(current)
        if currentStr = last
            break
        entries.Push(current)
        last := currentStr
        if AhkStdlibPathlibIsRoot(currentStr) || currentStr = "."
            break
        current := current.parent
    }
    return AhkStdlibPathlibIterator(entries)
}

AhkStdlibPathlibSuffixes(name)
{
    if name = ""
        return []
    ; Strip leading dots (hidden files have no suffix from those).
    trimmed := RegExReplace(name, "^\.+")
    result := []
    for piece in StrSplit(trimmed, ".") {
        if A_Index = 1
            continue
        result.Push("." piece)
    }
    return result
}

AhkStdlibPathlibResolve(path)
{
    path := AhkStdlibPathlibNormalizeSeparators(path)
    if path = ""
        path := "."
    if !(AhkStdlibPathlibHasDrive(path) && AhkStdlibPathlibIsRooted(SubStr(path, 3))) {
        if AhkStdlibPathlibIsRooted(path) {
            curDrive := AhkStdlibPathlibSplitDrive(A_WorkingDir)[1]
            path := curDrive path
        } else {
            path := RTrim(A_WorkingDir, "\") "\" path
        }
    }
    return AhkStdlibPathlibNormpath(path)
}

AhkStdlibPathlibNormpath(path)
{
    path := AhkStdlibPathlibNormalizeSeparators(path)
    driveParts := AhkStdlibPathlibSplitDrive(path)
    drive := driveParts[1]
    rest := driveParts[2]
    isAbsolute := AhkStdlibPathlibIsRooted(rest)
    rest := RegExReplace(rest, "^\\+")

    stack := []
    for comp in StrSplit(rest, "\") {
        if comp = "" || comp = "."
            continue
        if comp = ".." {
            if stack.Length > 0 && stack[stack.Length] != ".."
                stack.Pop()
            else if !isAbsolute
                stack.Push("..")
            continue
        }
        stack.Push(comp)
    }

    joined := ""
    for comp in stack
        joined := joined = "" ? comp : joined "\" comp

    prefix := drive (isAbsolute ? "\" : "")
    result := prefix joined
    if result = ""
        return "."
    return result
}

AhkStdlibPathlibRelativeTo(path, other)
{
    a := AhkStdlibPathlibNormalizeSeparators(path)
    b := AhkStdlibPathlibNormalizeSeparators(other)
    aParts := AhkStdlibPathlibParts(a)
    bParts := AhkStdlibPathlibParts(b)

    if bParts.Length > aParts.Length
        throw ValueError("'" path "' is not in the subpath of '" other "'", -1)
    Loop bParts.Length {
        if StrLower(aParts[A_Index]) != StrLower(bParts[A_Index])
            throw ValueError("'" path "' is not in the subpath of '" other "'", -1)
    }
    rest := []
    i := bParts.Length + 1
    while i <= aParts.Length {
        rest.Push(aParts[i])
        i += 1
    }
    if rest.Length = 0
        return "."
    joined := ""
    for comp in rest
        joined := joined = "" ? comp : joined "\" comp
    return joined
}

AhkStdlibPathlibMatch(path, pattern)
{
    pattern := AhkStdlibPathlibNormalizeSeparators(pattern)
    name := AhkStdlibPathlibNormalizeSeparators(path)
    ; A pattern with no separator matches against the final component only.
    if !InStr(pattern, "\") {
        SplitPath name, &leaf
        return stdlib.fnmatch.fnmatch(leaf, pattern)
    }
    ; Otherwise match the tail of the path with the same number of components.
    patParts := AhkStdlibPathlibParts(pattern)
    nameParts := AhkStdlibPathlibParts(name)
    if patParts.Length > nameParts.Length
        return AhkStdlibBool(false)
    offset := nameParts.Length - patParts.Length
    Loop patParts.Length {
        if !AhkStdlibTruthValue(stdlib.fnmatch.fnmatch(nameParts[offset + A_Index], patParts[A_Index]))
            return AhkStdlibBool(false)
    }
    return AhkStdlibBool(true)
}

AhkStdlibPathlibGlob(base, pattern, recursive)
{
    patternStr := AhkStdlibPathlibNormalizeSeparators(AhkStdlibPathlibPartToString(pattern))
    baseDir := RTrim(base, "\/")
    entries := []
    if recursive {
        AhkStdlibPathlibGlobRecursive(baseDir, patternStr, entries)
    } else {
        AhkStdlibPathlibGlobOne(baseDir, patternStr, entries)
    }
    return AhkStdlibPathlibIterator(entries)
}

AhkStdlibPathlibGlobOne(baseDir, pattern, entries)
{
    ; Split pattern into components and walk them.
    parts := []
    for comp in StrSplit(pattern, "\") {
        if comp != ""
            parts.Push(comp)
    }
    AhkStdlibPathlibGlobWalk(baseDir, parts, 1, entries)
}

AhkStdlibPathlibGlobWalk(dir, parts, index, entries)
{
    if index > parts.Length
        return
    comp := parts[index]
    isLast := index = parts.Length
    if !DirExist(dir)
        return
    Loop Files, dir "\*", "FD" {
        if !AhkStdlibTruthValue(stdlib.fnmatch.fnmatch(A_LoopFileName, comp))
            continue
        full := A_LoopFileFullPath
        if isLast {
            entries.Push(AhkStdlibPathlibPath(full))
        } else if InStr(A_LoopFileAttrib, "D") {
            AhkStdlibPathlibGlobWalk(full, parts, index + 1, entries)
        }
    }
}

AhkStdlibPathlibGlobRecursive(baseDir, pattern, entries)
{
    ; Strip a leading "**\" if present; rglob matches at any depth.
    leafPattern := RegExReplace(pattern, "^\*\*\\")
    AhkStdlibPathlibGlobRecursiveInto(baseDir, leafPattern, entries)
}

AhkStdlibPathlibGlobRecursiveInto(dir, pattern, entries)
{
    if !DirExist(dir)
        return
    Loop Files, dir "\*", "FD" {
        if AhkStdlibTruthValue(stdlib.fnmatch.fnmatch(A_LoopFileName, pattern))
            entries.Push(AhkStdlibPathlibPath(A_LoopFileFullPath))
    }
    Loop Files, dir "\*", "D"
        AhkStdlibPathlibGlobRecursiveInto(A_LoopFileFullPath, pattern, entries)
}
