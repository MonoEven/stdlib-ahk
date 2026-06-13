#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\fnmatch>

class AhkStdlibGlob
{
    static glob(args*)
    {
        if args.Length = 0
            throw TypeError("glob() missing 1 required positional argument: 'pathname'", -1)
        if args.Length > 2
            throw TypeError("glob() takes 1 positional argument but " args.Length " were given", -1)

        pathname := AhkStdlibGlobRequireStringLike(args[1], "pathname")
        options := { recursive: false, root_dir: "" }
        if args.Length = 2
            options := AhkStdlibGlobParseOptions(args[2])

        return AhkStdlibGlobCollectWithRoot(pathname, options.recursive, options.root_dir)
    }

    static iglob(args*)
    {
        if args.Length = 0
            throw TypeError("iglob() missing 1 required positional argument: 'pathname'", -1)
        if args.Length > 2
            throw TypeError("iglob() takes 1 positional argument but " args.Length " were given", -1)

        pathname := AhkStdlibGlobRequireStringLike(args[1], "pathname")
        options := { recursive: false, root_dir: "" }
        if args.Length = 2
            options := AhkStdlibGlobParseOptions(args[2])

        return AhkStdlibGlobCollectWithRoot(pathname, options.recursive, options.root_dir).__Enum(1)
    }

    static has_magic(args*)
    {
        if args.Length = 0
            throw TypeError("has_magic() missing 1 required positional argument: 's'", -1)
        if args.Length > 1
            throw TypeError("has_magic() takes 1 positional argument but " args.Length " were given", -1)

        value := args[1]
        if value is Buffer
            value := AhkStdlibFnmatchBufferToLatin1(value)
        else if !(value is String)
            throw TypeError("expected string or bytes-like object", -1)
        return InStr(value, "*") || InStr(value, "?") || InStr(value, "[")
    }

    static escape(args*)
    {
        if args.Length = 0
            throw TypeError("escape() missing 1 required positional argument: 'pathname'", -1)
        if args.Length > 1
            throw TypeError("escape() takes 1 positional argument but " args.Length " were given", -1)

        pathname := args[1]
        if pathname is Buffer
            pathname := AhkStdlibFnmatchBufferToLatin1(pathname)
        else if !(pathname is String)
            throw TypeError("expected str, bytes or os.PathLike object, not " AhkStdlibPythonTypeName(pathname), -1)

        escaped := ""
        loop parse pathname {
            ch := A_LoopField
            if InStr("*?[", ch)
                escaped .= "[" ch "]"
            else
                escaped .= ch
        }
        return escaped
    }
}

stdlib.glob := AhkStdlibGlob

AhkStdlibGlobParseOptions(options)
{
    if !(IsObject(options))
        throw TypeError("glob() takes 1 positional argument but 2 were given", -1)

    allowed := Map("recursive", true, "root_dir", true, "dir_fd", true)
    result := { recursive: false, root_dir: "" }

    for key, value in options.OwnProps() {
        if !allowed.Has(key)
            throw TypeError("glob() got an unexpected keyword argument '" key "'", -1)
        if key = "recursive"
            result.recursive := AhkStdlibTruthValue(value)
        else if key = "root_dir" {
            if IsObject(value) {
                if value == stdlib.None
                    result.root_dir := ""
                else
                    result.root_dir := AhkStdlibGlobRequireStringLike(value, "root_dir")
            } else if value = "" {
                result.root_dir := ""
            } else {
                result.root_dir := AhkStdlibGlobRequireStringLike(value, "root_dir")
            }
        }
    }

    return result
}

AhkStdlibGlobCollectWithRoot(pathname, recursive, root_dir)
{
    if root_dir = ""
        return AhkStdlibGlobCollect(pathname, recursive)

    previousWorkingDir := A_WorkingDir
    SetWorkingDir StrReplace(root_dir, "/", "\")
    try {
        return AhkStdlibGlobCollect(pathname, recursive)
    } finally {
        SetWorkingDir previousWorkingDir
    }
}

AhkStdlibGlobRequireStringLike(value, paramName)
{
    if value is Buffer
        return AhkStdlibFnmatchBufferToLatin1(value)
    if value is String
        return value
    throw TypeError("expected str, bytes or os.PathLike object, not " AhkStdlibPythonTypeName(value), -1)
}

AhkStdlibGlobCollect(pathname, recursive)
{
    normalized := StrReplace(pathname, "/", "\")
    if !AhkStdlibGlobHasMagic(normalized) {
        if FileExist(normalized) = ""
            return []
        return [normalized]
    }

    if recursive && InStr(normalized, "**") {
        return AhkStdlibGlobCollectRecursive(normalized)
    }

    split := AhkStdlibGlobSplitPattern(normalized)
    if split.Dir = ""
        loopPattern := split.File
    else
        loopPattern := split.Dir "\" split.File

    results := []
    Loop Files, loopPattern, "FD"
    {
        path := split.Dir = "" ? A_LoopFileName : A_LoopFilePath
        if A_LoopFileName = "." || A_LoopFileName = ".."
            continue
        results.Push(path)
    }
    return results
}

AhkStdlibGlobNormalizeRelativeResult(path)
{
    if SubStr(path, 1, 2) = ".\"
        return SubStr(path, 3)
    return path
}

AhkStdlibGlobCollectRecursive(pathname)
{
    marker := "\**\"
    markerPos := InStr(pathname, marker)
    if !markerPos {
        marker := "**\"
        markerPos := InStr(pathname, marker)
    }
    if !markerPos {
        marker := "\**"
        markerPos := InStr(pathname, marker)
    }

    if !markerPos
        return AhkStdlibGlobCollect(pathname, false)

    prefix := SubStr(pathname, 1, markerPos - 1)
    remainder := SubStr(pathname, markerPos + StrLen(marker))
    if prefix = ""
        prefix := "."

    results := []
    if remainder != "" {
        direct := AhkStdlibGlobCollect((prefix = "." ? remainder : prefix "\" remainder), false)
        for item in direct
            results.Push(AhkStdlibGlobNormalizeRelativeResult(item))
    }

    Loop Files, prefix "\*", "DR"
    {
        relativeDir := A_LoopFilePath
        if remainder = "" {
            results.Push(relativeDir)
            continue
        }
        nestedPattern := relativeDir "\" remainder
        nested := AhkStdlibGlobCollect(nestedPattern, false)
        for item in nested
            results.Push(AhkStdlibGlobNormalizeRelativeResult(item))
    }

    return results
}

AhkStdlibGlobSplitPattern(pathname)
{
    lastSlash := 0
    pos := 1
    loop {
        found := InStr(pathname, "\", , pos)
        if !found
            break
        lastSlash := found
        pos := found + 1
    }

    if !lastSlash
        return { Dir: "", File: pathname }
    return {
        Dir: SubStr(pathname, 1, lastSlash - 1),
        File: SubStr(pathname, lastSlash + 1)
    }
}

AhkStdlibGlobHasMagic(pathname)
{
    return InStr(pathname, "*") || InStr(pathname, "?") || InStr(pathname, "[")
}
