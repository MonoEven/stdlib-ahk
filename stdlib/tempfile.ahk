#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibTempfile
{
    static TMP_MAX := 10000
    static tempdir := ""

    static gettempdir()
    {
        if this.tempdir != ""
            return AhkStdlibTempfileNormalizeSeparators(this.tempdir)
        return AhkStdlibTempfileNormalizeSeparators(A_Temp)
    }

    static gettempprefix()
    {
        return "tmp"
    }

    static mkdtemp(suffix := unset, prefix := unset, dir := unset)
    {
        suffixValue := IsSet(suffix) ? suffix : ""
        prefixValue := IsSet(prefix) ? prefix : this.gettempprefix()
        dirValue := IsSet(dir) ? dir : this.gettempdir()

        if !(suffixValue is String)
            throw TypeError("suffix must be str", -1)
        if !(prefixValue is String)
            throw TypeError("prefix must be str", -1)
        if !(dirValue is String)
            throw TypeError("dir must be str", -1)

        dirValue := AhkStdlibTempfileNormalizeSeparators(dirValue)
        if DirExist(dirValue) = ""
            throw OSError("No such file or directory: " dirValue, -1)

        loop this.TMP_MAX {
            path := AhkStdlibTempfileJoin(dirValue, prefixValue AhkStdlibTempfileRandomName() suffixValue)
            if DirExist(path) != "" || FileExist(path) != ""
                continue
            try {
                DirCreate path
                return path
            } catch as err {
                if DirExist(path) != "" || FileExist(path) != ""
                    continue
                throw err
            }
        }

        throw OSError("No usable temporary directory name found", -1)
    }

    static mkstemp(suffix := unset, prefix := unset, dir := unset, text := false)
    {
        suffixValue := IsSet(suffix) && !AhkStdlibIsNone(suffix) ? suffix : ""
        prefixValue := IsSet(prefix) && !AhkStdlibIsNone(prefix) ? prefix : this.gettempprefix()
        dirValue := IsSet(dir) && !AhkStdlibIsNone(dir) ? dir : this.gettempdir()

        if !(suffixValue is String)
            throw TypeError("suffix must be str", -1)
        if !(prefixValue is String)
            throw TypeError("prefix must be str", -1)
        if !(dirValue is String)
            throw TypeError("dir must be str", -1)

        dirValue := AhkStdlibTempfileNormalizeSeparators(dirValue)
        if DirExist(dirValue) = ""
            throw OSError("No such file or directory: " dirValue, -1)

        loop this.TMP_MAX {
            path := AhkStdlibTempfileJoin(dirValue, prefixValue AhkStdlibTempfileRandomName() suffixValue)
            if DirExist(path) != "" || FileExist(path) != ""
                continue
            ; AHK FileOpen has no exclusive ("x") mode, but the FileExist check
            ; above is race-free under AHK's single thread, so "w" creates it.
            handle := ""
            try
                handle := FileOpen(path, "w")
            catch
                continue
            if !IsObject(handle)
                continue
            ; mkstemp returns (fd, absolute_path). AHK has no integer fds, so the
            ; first tuple element mirrors the path (callers reopen via os/io).
            handle.Close()
            return stdlib.tuple([path, path])
        }

        throw OSError("No usable temporary file name found", -1)
    }

    static NamedTemporaryFile(options := unset)
    {
        return AhkStdlibTempfileNamedFile(options?)
    }

    static TemporaryFile(options := unset)
    {
        return AhkStdlibTempfileNamedFile(options?)
    }

    static TemporaryDirectory(suffix := unset, prefix := unset, dir := unset, ignore_cleanup_errors := false)
    {
        return AhkStdlibTemporaryDirectory(suffix?, prefix?, dir?, ignore_cleanup_errors)
    }
}

class AhkStdlibTemporaryDirectory
{
    __New(suffix := unset, prefix := unset, dir := unset, ignore_cleanup_errors := false)
    {
        this.name := AhkStdlibTempfile.mkdtemp(suffix?, prefix?, dir?)
        this._ignore_cleanup_errors := ignore_cleanup_errors
        this._closed := false
    }

    cleanup()
    {
        if this._closed
            return
        this._closed := true

        if DirExist(this.name) = ""
            return

        try {
            DirDelete this.name, true
        } catch as err {
            if !this._ignore_cleanup_errors
                throw err
        }
    }

    ToString()
    {
        return this.name
    }
}

stdlib.tempfile := AhkStdlibTempfile

; NamedTemporaryFile / TemporaryFile wrapper. Python returns a file object whose
; .name is accessible and which deletes on close (delete=True default). AHK has
; no context-manager protocol, so callers use the I/O methods and .close().
AhkStdlibTempfileNamedFile(options := unset)
{
    suffix := ""
    prefix := AhkStdlibTempfile.gettempprefix()
    dir := AhkStdlibTempfile.gettempdir()
    delete := true
    mode := "w+"

    if IsSet(options) && IsObject(options) {
        if HasProp(options, "suffix") && !AhkStdlibIsNone(options.suffix)
            suffix := options.suffix
        if HasProp(options, "prefix") && !AhkStdlibIsNone(options.prefix)
            prefix := options.prefix
        if HasProp(options, "dir") && !AhkStdlibIsNone(options.dir)
            dir := options.dir
        if HasProp(options, "delete")
            delete := AhkStdlibTruthValue(options.delete)
        if HasProp(options, "mode")
            mode := options.mode
    }

    return AhkStdlibTemporaryFileObject(suffix, prefix, dir, delete, mode)
}

class AhkStdlibTemporaryFileObject
{
    __New(suffix, prefix, dir, delete, mode)
    {
        result := AhkStdlibTempfile.mkstemp(suffix, prefix, dir)
        this.name := result[1]
        this.AhkStdlibDelete := delete
        this.AhkStdlibClosed := false
        ; Reopen with the requested mode (mkstemp closed its exclusive handle).
        this.file := FileOpen(this.name, AhkStdlibTempfileTranslateMode(mode))
    }

    write(data)
    {
        return this.file.Write(data)
    }

    read(args*)
    {
        return this.file.Read(args*)
    }

    seek(offset, origin := 0)
    {
        return this.file.Seek(offset, origin)
    }

    tell()
    {
        return this.file.Pos
    }

    flush()
    {
        return stdlib.None
    }

    close()
    {
        if this.AhkStdlibClosed
            return stdlib.None
        this.AhkStdlibClosed := true
        try this.file.Close()
        if this.AhkStdlibDelete && FileExist(this.name)
            try FileDelete this.name
        return stdlib.None
    }

    __Delete()
    {
        try this.close()
    }

    ToString()
    {
        return this.name
    }
}

AhkStdlibTempfileTranslateMode(mode)
{
    ; Map Python file modes to AHK FileOpen flags (best-effort, text default).
    switch mode {
        case "w+", "w+b", "wb+", "r+", "r+b", "rb+":
            return "rw"
        case "w", "wb":
            return "w"
        case "r", "rb":
            return "r"
        case "a", "ab":
            return "a"
        default:
            return "rw"
    }
}

AhkStdlibTempfileRandomName()
{
    ; Python's tempfile uses _RandomNameSequence backed by the OS CSPRNG. Mirror
    ; that with BCryptGenRandom so temp names are not predictable; fall back to
    ; Random() only if the CSPRNG call fails.
    static chars := "abcdefghijklmnopqrstuvwxyz0123456789_"
    count := StrLen(chars)
    buf := Buffer(8, 0)
    status := DllCall("bcrypt\BCryptGenRandom", "Ptr", 0, "Ptr", buf.Ptr, "UInt", 8, "UInt", 0x00000002, "UInt")
    result := ""
    if status != 0 {
        loop 8
            result .= SubStr(chars, Random(1, count), 1)
        return result
    }
    loop 8 {
        byte := NumGet(buf, A_Index - 1, "UChar")
        result .= SubStr(chars, Mod(byte, count) + 1, 1)
    }
    return result
}

AhkStdlibTempfileNormalizeSeparators(path)
{
    return StrReplace(path, "/", "\")
}

AhkStdlibTempfileJoin(dir, name)
{
    if dir = ""
        return name
    return RTrim(dir, "\") "\" name
}
