#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibPathlib
{
    static Path(parts*)
    {
        return AhkStdlibPathlibPath(parts*)
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
