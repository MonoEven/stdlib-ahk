#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\io>

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

    static SpooledTemporaryFile(max_size := 0, mode := "w+b", options := unset)
    {
        return AhkStdlibSpooledTemporaryFile(max_size, mode, options?)
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

; SpooledTemporaryFile keeps data in an in-memory io buffer until it exceeds
; max_size, then transparently rolls over to a real on-disk temp file. A binary
; mode (contains "b") uses io.BytesIO; otherwise io.StringIO. max_size = 0 means
; never auto-roll (rollover only on explicit .rollover()). Mirrors CPython 3.10.
class AhkStdlibSpooledTemporaryFile
{
    __New(max_size := 0, mode := "w+b", options := unset)
    {
        this.AhkStdlibMaxSize := max_size
        this.AhkStdlibMode := mode
        this.AhkStdlibBinary := InStr(mode, "b") ? true : false
        this._rolled := false
        this.AhkStdlibClosed := false
        this.AhkStdlibSuffix := ""
        this.AhkStdlibPrefix := AhkStdlibTempfile.gettempprefix()
        this.AhkStdlibDir := AhkStdlibTempfile.gettempdir()
        if IsSet(options) && IsObject(options) {
            if HasProp(options, "suffix")
                this.AhkStdlibSuffix := options.suffix
            if HasProp(options, "prefix")
                this.AhkStdlibPrefix := options.prefix
            if HasProp(options, "dir")
                this.AhkStdlibDir := options.dir
        }
        this.AhkStdlibFile := this.AhkStdlibBinary ? AhkStdlibIoBytesIO() : AhkStdlibIoStringIO()
    }

    ; .name is None until the file rolls over to disk (matches CPython).
    name {
        get => this._rolled ? this.AhkStdlibDiskName : stdlib.None
    }

    AhkStdlibCheckRollover(extra)
    {
        if this._rolled
            return
        if this.AhkStdlibMaxSize > 0 && (this.AhkStdlibFile.tell() + extra) > this.AhkStdlibMaxSize
            this.rollover()
    }

    rollover()
    {
        if this._rolled
            return stdlib.None
        ; Drain the in-memory buffer into a fresh on-disk temp file.
        memory := this.AhkStdlibFile
        pos := memory.tell()
        data := memory.getvalue()
        result := AhkStdlibTempfile.mkstemp(this.AhkStdlibSuffix, this.AhkStdlibPrefix, this.AhkStdlibDir)
        this.AhkStdlibDiskName := result[1]
        flags := this.AhkStdlibBinary ? "rw" : "rw"
        diskFile := FileOpen(this.AhkStdlibDiskName, flags, this.AhkStdlibBinary ? "" : "UTF-8-RAW")
        if this.AhkStdlibBinary {
            if data is Buffer && data.Size > 0
                diskFile.RawWrite(data, data.Size)
        } else {
            if data != ""
                diskFile.Write(data)
        }
        diskFile.Seek(pos, 0)
        this.AhkStdlibFile := AhkStdlibSpooledDiskAdapter(diskFile, this.AhkStdlibBinary)
        this._rolled := true
        return stdlib.None
    }

    write(data)
    {
        this.AhkStdlibEnsureOpen()
        extra := this.AhkStdlibBinary ? (data is Buffer ? data.Size : StrLen(data)) : StrLen(data)
        this.AhkStdlibCheckRollover(extra)
        return this.AhkStdlibFile.write(data)
    }

    read(args*)
    {
        this.AhkStdlibEnsureOpen()
        return this.AhkStdlibFile.read(args*)
    }

    seek(offset, origin := 0)
    {
        this.AhkStdlibEnsureOpen()
        return this.AhkStdlibFile.seek(offset, origin)
    }

    tell()
    {
        this.AhkStdlibEnsureOpen()
        return this.AhkStdlibFile.tell()
    }

    truncate(size := unset)
    {
        this.AhkStdlibEnsureOpen()
        if IsSet(size)
            return this.AhkStdlibFile.truncate(size)
        return this.AhkStdlibFile.truncate()
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
        if this._rolled {
            try this.AhkStdlibFile.close()
            if FileExist(this.AhkStdlibDiskName)
                try FileDelete this.AhkStdlibDiskName
        }
        return stdlib.None
    }

    AhkStdlibEnsureOpen()
    {
        if this.AhkStdlibClosed
            throw ValueError("I/O operation on closed file", -1)
    }

    __Delete()
    {
        try this.close()
    }
}

; Adapts a FileOpen handle to the StringIO/BytesIO method surface used above.
class AhkStdlibSpooledDiskAdapter
{
    __New(file, binary)
    {
        this.AhkStdlibFile := file
        this.AhkStdlibBinary := binary
    }

    write(data)
    {
        if this.AhkStdlibBinary {
            if data is Buffer
                return this.AhkStdlibFile.RawWrite(data, data.Size)
            return this.AhkStdlibFile.Write(data)
        }
        return this.AhkStdlibFile.Write(data)
    }

    read(size := -1)
    {
        if this.AhkStdlibBinary {
            remaining := this.AhkStdlibFile.Length - this.AhkStdlibFile.Pos
            count := (size < 0) ? remaining : Min(size, remaining)
            buf := Buffer(count)
            got := this.AhkStdlibFile.RawRead(buf, count)
            if got < count
                buf := AhkStdlibSpooledTrimBuffer(buf, got)
            return buf
        }
        if size < 0
            return this.AhkStdlibFile.Read()
        return this.AhkStdlibFile.Read(size)
    }

    seek(offset, origin := 0)
    {
        return this.AhkStdlibFile.Seek(offset, origin)
    }

    tell()
    {
        return this.AhkStdlibFile.Pos
    }

    getvalue()
    {
        saved := this.AhkStdlibFile.Pos
        this.AhkStdlibFile.Seek(0, 0)
        result := this.read(-1)
        this.AhkStdlibFile.Seek(saved, 0)
        return result
    }

    truncate(size := unset)
    {
        if IsSet(size) {
            saved := this.AhkStdlibFile.Pos
            this.AhkStdlibFile.Seek(size, 0)
            this.AhkStdlibFile.Length := size
            this.AhkStdlibFile.Seek(saved, 0)
            return size
        }
        this.AhkStdlibFile.Length := this.AhkStdlibFile.Pos
        return this.AhkStdlibFile.Pos
    }

    close()
    {
        try this.AhkStdlibFile.Close()
        return ""
    }
}

AhkStdlibSpooledTrimBuffer(buf, count)
{
    trimmed := Buffer(count)
    if count > 0
        DllCall("RtlMoveMemory", "Ptr", trimmed.Ptr, "Ptr", buf.Ptr, "UPtr", count)
    return trimmed
}
