#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibShutil
{
    static Error := AhkStdlibShutilError
    static SameFileError := AhkStdlibShutilSameFileError

    static copyfile(src, dst)
    {
        return AhkStdlibShutilCopyfile(src, dst)
    }

    static copy(src, dst)
    {
        return AhkStdlibShutilCopy(src, dst)
    }

    static copy2(src, dst)
    {
        return AhkStdlibShutilCopy2(src, dst)
    }

    static copyfileobj(fsrc, fdst, length := 65536)
    {
        return AhkStdlibShutilCopyfileobj(fsrc, fdst, length)
    }

    static copytree(src, dst, options := unset)
    {
        return AhkStdlibShutilCopytree(src, dst, options?)
    }

    static move(src, dst)
    {
        return AhkStdlibShutilMove(src, dst)
    }

    static rmtree(path)
    {
        return AhkStdlibShutilRmtree(path)
    }

    static disk_usage(path)
    {
        return AhkStdlibShutilDiskUsage(path)
    }

    static which(cmd, path := unset)
    {
        return AhkStdlibShutilWhich(cmd, path?)
    }

    static get_terminal_size(fallback := unset)
    {
        return AhkStdlibShutilGetTerminalSize(fallback?)
    }

    static ignore_patterns(patterns*)
    {
        return AhkStdlibShutilIgnorePatterns(patterns)
    }

    static copymode(src, dst)
    {
        return AhkStdlibShutilCopymode(src, dst)
    }

    static copystat(src, dst)
    {
        return AhkStdlibShutilCopystat(src, dst)
    }

    static make_archive(base_name, format, root_dir := unset, base_dir := unset)
    {
        return AhkStdlibShutilMakeArchive(base_name, format, root_dir?, base_dir?)
    }

    static unpack_archive(filename, extract_dir := unset, format := unset)
    {
        return AhkStdlibShutilUnpackArchive(filename, extract_dir?, format?)
    }

    static get_archive_formats()
    {
        return AhkStdlibShutilGetArchiveFormats()
    }

    static get_unpack_formats()
    {
        return AhkStdlibShutilGetUnpackFormats()
    }
}

class AhkStdlibShutilError extends Error
{
}

class AhkStdlibShutilSameFileError extends OSError
{
}

stdlib.shutil := AhkStdlibShutil

AhkStdlibShutilCopyfile(src, dst)
{
    sourcePath := AhkStdlibShutilPathString(src)
    targetPath := AhkStdlibShutilPathString(dst)

    if !FileExist(sourcePath)
        throw OSError("No such file or directory: '" sourcePath "'", -1)
    if DirExist(sourcePath)
        throw OSError("Permission denied: '" sourcePath "'", -1)

    sourceFull := AhkStdlibShutilFullPath(sourcePath)
    targetFull := AhkStdlibShutilFullPath(targetPath)
    if sourceFull = targetFull
        throw AhkStdlibShutilSameFileError("'" sourceFull "' and '" targetFull "' are the same file", -1)

    if DirExist(targetPath)
        throw OSError("Permission denied: '" targetPath "'", -1)

    parent := AhkStdlibShutilParent(targetPath)
    if parent != "" && !DirExist(parent)
        throw OSError("No such file or directory: '" parent "'", -1)

    if FileExist(targetPath) && !DirExist(targetPath)
        FileDelete targetPath

    FileCopy sourcePath, targetPath, 1
    return AhkStdlibShutilFullPath(targetPath)
}

AhkStdlibShutilCopy(src, dst)
{
    sourcePath := AhkStdlibShutilPathString(src)
    targetPath := AhkStdlibShutilPathString(dst)

    if DirExist(targetPath) {
        SplitPath sourcePath, &name
        targetPath := RTrim(targetPath, "\") "\" name
    }
    return AhkStdlibShutilCopyfile(sourcePath, targetPath)
}

AhkStdlibShutilMove(src, dst)
{
    sourcePath := AhkStdlibShutilPathString(src)
    targetPath := AhkStdlibShutilPathString(dst)

    if !FileExist(sourcePath)
        throw OSError("No such file or directory: '" sourcePath "'", -1)

    if DirExist(targetPath) {
        SplitPath sourcePath, &name
        targetPath := RTrim(targetPath, "\") "\" name
    }

    sourceFull := AhkStdlibShutilFullPath(sourcePath)
    targetFull := AhkStdlibShutilFullPath(targetPath)
    if sourceFull = targetFull
        return targetFull

    parent := AhkStdlibShutilParent(targetPath)
    if parent != "" && !DirExist(parent)
        throw OSError("No such file or directory: '" parent "'", -1)

    if DirExist(sourcePath)
        DirMove sourcePath, targetPath, 2
    else
        FileMove sourcePath, targetPath, 1

    return targetFull
}

AhkStdlibShutilRmtree(path)
{
    targetPath := AhkStdlibShutilPathString(path)
    if !DirExist(targetPath)
        throw OSError("No such file or directory: '" targetPath "'", -1)

    DirDelete targetPath, true
}

AhkStdlibShutilPathString(path)
{
    if IsObject(path) && HasProp(path, "Path")
        return path.Path
    if IsObject(path)
        return String(path)
    return path ""
}

AhkStdlibShutilFullPath(path)
{
    path := AhkStdlibShutilPathString(path)
    if RegExMatch(path, "i)^[a-z]:\\") || SubStr(path, 1, 2) = "\\"
        return path
    return A_WorkingDir "\" path
}

AhkStdlibShutilParent(path)
{
    path := AhkStdlibShutilPathString(path)
    SplitPath path, , &dir
    return dir
}

AhkStdlibShutilCopy2(src, dst)
{
    sourcePath := AhkStdlibShutilPathString(src)
    targetPath := AhkStdlibShutilPathString(dst)

    if DirExist(targetPath) {
        SplitPath sourcePath, &name
        targetPath := RTrim(targetPath, "\") "\" name
    }

    result := AhkStdlibShutilCopyfile(sourcePath, targetPath)

    modified := FileGetTime(sourcePath, "M")
    created := FileGetTime(sourcePath, "C")
    accessed := FileGetTime(sourcePath, "A")
    FileSetTime modified, result, "M"
    FileSetTime created, result, "C"
    FileSetTime accessed, result, "A"
    return result
}

AhkStdlibShutilCopyfileobj(fsrc, fdst, length := 65536)
{
    if !(length is Integer) || length <= 0
        length := 65536

    while true {
        chunk := AhkStdlibShutilFileObjRead(fsrc, length)
        if !IsObject(chunk) && chunk = ""
            break
        if IsObject(chunk) && chunk is Buffer && chunk.Size = 0
            break
        AhkStdlibShutilFileObjWrite(fdst, chunk)
    }
    return stdlib.None
}

AhkStdlibShutilFileObjRead(obj, length)
{
    if IsObject(obj) && HasMethod(obj, "Read")
        return obj.Read(length)
    if IsObject(obj) && HasMethod(obj, "read")
        return obj.read(length)
    throw TypeError("file-like object has no Read/read method", -1)
}

AhkStdlibShutilFileObjWrite(obj, data)
{
    if IsObject(obj) && HasMethod(obj, "Write")
        return obj.Write(data)
    if IsObject(obj) && HasMethod(obj, "write")
        return obj.write(data)
    throw TypeError("file-like object has no Write/write method", -1)
}

AhkStdlibShutilCopytree(src, dst, options := unset)
{
    sourcePath := AhkStdlibShutilPathString(src)
    targetPath := AhkStdlibShutilPathString(dst)

    if !DirExist(sourcePath)
        throw OSError("No such file or directory: '" sourcePath "'", -1)

    dirsExistOk := false
    ignore := ""
    if IsSet(options) && IsObject(options) {
        if HasProp(options, "dirs_exist_ok")
            dirsExistOk := AhkStdlibTruthValue(options.dirs_exist_ok)
        if HasProp(options, "ignore") && !AhkStdlibIsNone(options.ignore)
            ignore := options.ignore
    }

    if DirExist(targetPath) && !dirsExistOk
        throw OSError("Cannot create a file when that file already exists: '" targetPath "'", -1)

    if !DirExist(targetPath)
        DirCreate targetPath

    AhkStdlibShutilCopytreeWalk(sourcePath, targetPath, ignore)
    return AhkStdlibShutilFullPath(targetPath)
}

AhkStdlibShutilCopytreeWalk(sourceDir, targetDir, ignore)
{
    names := []
    Loop Files, RTrim(sourceDir, "\") "\*", "FD"
        names.Push(A_LoopFileName)

    ignored := Map()
    if ignore != "" && IsObject(ignore) && HasMethod(ignore, "Call") {
        result := ignore.Call(sourceDir, AhkStdlibShutilNamesArray(names))
        for name in AhkStdlibShutilIterable(result)
            ignored[name] := true
    }

    for name in names {
        if ignored.Has(name)
            continue
        sourceEntry := RTrim(sourceDir, "\") "\" name
        targetEntry := RTrim(targetDir, "\") "\" name
        if DirExist(sourceEntry) {
            if !DirExist(targetEntry)
                DirCreate targetEntry
            AhkStdlibShutilCopytreeWalk(sourceEntry, targetEntry, ignore)
        } else {
            AhkStdlibShutilCopy2(sourceEntry, targetEntry)
        }
    }
}

AhkStdlibShutilNamesArray(names)
{
    result := []
    for name in names
        result.Push(name)
    return result
}

AhkStdlibShutilIterable(value)
{
    if IsObject(value) && HasMethod(value, "__Enum")
        return value
    return []
}

AhkStdlibShutilDiskUsage(path)
{
    target := AhkStdlibShutilPathString(path)

    freeBytesAvailable := Buffer(8, 0)
    totalBytes := Buffer(8, 0)
    totalFreeBytes := Buffer(8, 0)

    if !DllCall("GetDiskFreeSpaceExW", "WStr", target, "Ptr", freeBytesAvailable.Ptr, "Ptr", totalBytes.Ptr, "Ptr", totalFreeBytes.Ptr, "Int")
        throw OSError("No such file or directory: '" target "'", -1)

    total := NumGet(totalBytes, 0, "UInt64")
    free := NumGet(totalFreeBytes, 0, "UInt64")
    used := total - free
    return stdlib.tuple([total, used, free])
}

AhkStdlibShutilWhich(cmd, path := unset)
{
    cmdStr := AhkStdlibShutilPathString(cmd)

    if InStr(cmdStr, "\") || InStr(cmdStr, "/") {
        if AhkStdlibShutilIsExecutableFile(cmdStr)
            return cmdStr
    }

    searchPath := IsSet(path) && !AhkStdlibIsNone(path) ? AhkStdlibShutilPathString(path) : EnvGet("PATH")
    if searchPath = ""
        return stdlib.None

    pathext := EnvGet("PATHEXT")
    exts := []
    if pathext != "" {
        loop parse pathext, ";"
            if A_LoopField != ""
                exts.Push(A_LoopField)
    }

    hasExt := false
    for ext in exts {
        if StrLen(cmdStr) >= StrLen(ext) && SubStr(cmdStr, -StrLen(ext) + 1) = ext {
            hasExt := true
            break
        }
    }

    dirs := [""]
    loop parse searchPath, ";"
        if A_LoopField != ""
            dirs.Push(A_LoopField)

    seen := Map()
    for dir in dirs {
        normDir := dir = "" ? A_WorkingDir : RTrim(dir, "\")
        if seen.Has(normDir)
            continue
        seen[normDir] := true
        base := normDir "\" cmdStr

        if hasExt {
            if AhkStdlibShutilIsExecutableFile(base)
                return base
        } else {
            for ext in exts {
                candidate := base ext
                if AhkStdlibShutilIsExecutableFile(candidate)
                    return candidate
            }
        }
    }
    return stdlib.None
}

AhkStdlibShutilIsExecutableFile(path)
{
    return FileExist(path) && !DirExist(path)
}

AhkStdlibShutilGetTerminalSize(fallback := unset)
{
    fbColumns := 80
    fbLines := 24
    if IsSet(fallback) && IsObject(fallback) {
        if fallback is Array && fallback.Length >= 2 {
            fbColumns := fallback[1]
            fbLines := fallback[2]
        }
    }

    columns := 0
    lines := 0

    envColumns := EnvGet("COLUMNS")
    if envColumns != "" && IsInteger(envColumns)
        columns := Integer(envColumns)
    envLines := EnvGet("LINES")
    if envLines != "" && IsInteger(envLines)
        lines := Integer(envLines)

    if columns <= 0 || lines <= 0 {
        info := AhkStdlibShutilQueryConsoleSize()
        if IsObject(info) {
            if columns <= 0
                columns := info.columns
            if lines <= 0
                lines := info.lines
        }
    }

    if columns <= 0
        columns := fbColumns
    if lines <= 0
        lines := fbLines

    return stdlib.tuple([columns, lines])
}

AhkStdlibShutilQueryConsoleSize()
{
    STD_OUTPUT_HANDLE := -11
    handle := DllCall("GetStdHandle", "Int", STD_OUTPUT_HANDLE, "Ptr")
    if !handle || handle = -1
        return ""

    ; CONSOLE_SCREEN_BUFFER_INFO is 22 bytes
    info := Buffer(22, 0)
    if !DllCall("GetConsoleScreenBufferInfo", "Ptr", handle, "Ptr", info.Ptr, "Int")
        return ""

    ; srWindow: Left,Top,Right,Bottom each SHORT, starting at offset 10
    left := NumGet(info, 10, "Short")
    top := NumGet(info, 12, "Short")
    right := NumGet(info, 14, "Short")
    bottom := NumGet(info, 16, "Short")
    return { columns: right - left + 1, lines: bottom - top + 1 }
}

AhkStdlibShutilIgnorePatterns(patterns)
{
    patList := []
    for pattern in patterns
        patList.Push(AhkStdlibShutilPathString(pattern))
    return AhkStdlibShutilIgnoreCallable(patList)
}

class AhkStdlibShutilIgnoreCallable
{
    __New(patterns)
    {
        this.patterns := patterns
    }

    Call(dir, names)
    {
        ignored := []
        for name in AhkStdlibShutilIterable(names) {
            for pattern in this.patterns {
                if AhkStdlibShutilFnmatch(name, pattern) {
                    ignored.Push(name)
                    break
                }
            }
        }
        return ignored
    }
}

AhkStdlibShutilFnmatch(name, pattern)
{
    regex := AhkStdlibShutilTranslate(pattern)
    return RegExMatch(name, regex) > 0
}

AhkStdlibShutilTranslate(pattern)
{
    result := "i)^"
    chars := StrSplit(pattern)
    index := 1
    total := chars.Length
    while index <= total {
        ch := chars[index]
        if ch = "*" {
            result .= ".*"
        } else if ch = "?" {
            result .= "."
        } else if ch = "[" {
            j := index + 1
            if j <= total && (chars[j] = "!" || chars[j] = "^")
                j += 1
            if j <= total && chars[j] = "]"
                j += 1
            while j <= total && chars[j] != "]"
                j += 1
            if j > total {
                result .= "\["
            } else {
                seg := ""
                k := index + 1
                while k < j {
                    seg .= chars[k]
                    k += 1
                }
                if SubStr(seg, 1, 1) = "!"
                    seg := "^" SubStr(seg, 2)
                seg := StrReplace(seg, "\", "\\")
                result .= "[" seg "]"
                index := j
            }
        } else {
            ; escape regex special chars
            if InStr(".\+^$|()", ch)
                result .= "\" ch
            else
                result .= ch
        }
        index += 1
    }
    result .= "$"
    return result
}

; ---- copymode / copystat ----
; Windows has no POSIX mode bits; the closest analog is the read-only (R)
; attribute, so copymode mirrors that. copystat additionally copies the
; modification/access/creation timestamps (like copy2 does).
AhkStdlibShutilCopymode(src, dst)
{
    sourcePath := AhkStdlibShutilPathString(src)
    targetPath := AhkStdlibShutilPathString(dst)
    if !FileExist(sourcePath)
        throw OSError("No such file or directory: '" sourcePath "'", -1)
    if !FileExist(targetPath)
        throw OSError("No such file or directory: '" targetPath "'", -1)
    attrs := FileGetAttrib(sourcePath)
    if InStr(attrs, "R")
        FileSetAttrib "+R", targetPath
    else
        FileSetAttrib "-R", targetPath
    return ""
}

AhkStdlibShutilCopystat(src, dst)
{
    sourcePath := AhkStdlibShutilPathString(src)
    targetPath := AhkStdlibShutilPathString(dst)
    if !FileExist(sourcePath)
        throw OSError("No such file or directory: '" sourcePath "'", -1)
    if !FileExist(targetPath)
        throw OSError("No such file or directory: '" targetPath "'", -1)
    FileSetTime FileGetTime(sourcePath, "M"), targetPath, "M"
    FileSetTime FileGetTime(sourcePath, "C"), targetPath, "C"
    FileSetTime FileGetTime(sourcePath, "A"), targetPath, "A"
    AhkStdlibShutilCopymode(sourcePath, targetPath)
    return ""
}

; ---- archives ----
; Supported formats mirror CPython's built-ins. 'zip' uses PowerShell
; Compress-Archive; 'tar'/'gztar'/'bztar'/'xztar' shell out to the bundled
; bsdtar (tar.exe on Windows 10+).
AhkStdlibShutilArchiveFormatTable()
{
    return Map(
        "zip", { ext: ".zip", desc: "ZIP file" },
        "tar", { ext: ".tar", desc: "uncompressed tar file" },
        "gztar", { ext: ".tar.gz", desc: "gzip'ed tar-file" },
        "bztar", { ext: ".tar.bz2", desc: "bzip2'ed tar-file" },
        "xztar", { ext: ".tar.xz", desc: "xz'ed tar-file" })
}

AhkStdlibShutilGetArchiveFormats()
{
    table := AhkStdlibShutilArchiveFormatTable()
    ; CPython returns the list sorted by format name.
    names := []
    for name, info in table
        names.Push(name)
    AhkStdlibShutilSortStrings(names)
    result := []
    for name in names
        result.Push([name, table[name].desc])
    return result
}

AhkStdlibShutilGetUnpackFormats()
{
    ; (name, extensions, description)
    return [
        ["bztar", [".tar.bz2", ".tbz2"], "bzip2'ed tar-file"],
        ["gztar", [".tar.gz", ".tgz"], "gzip'ed tar-file"],
        ["tar", [".tar"], "uncompressed tar file"],
        ["xztar", [".tar.xz", ".txz"], "xz'ed tar-file"],
        ["zip", [".zip"], "ZIP file"]]
}

AhkStdlibShutilSortStrings(arr)
{
    ; Simple insertion sort; format tables are tiny.
    i := 2
    while i <= arr.Length {
        key := arr[i]
        j := i - 1
        while j >= 1 && StrCompare(arr[j], key) > 0 {
            arr[j + 1] := arr[j]
            j -= 1
        }
        arr[j + 1] := key
        i += 1
    }
    return arr
}

AhkStdlibShutilMakeArchive(base_name, format, root_dir := unset, base_dir := unset)
{
    table := AhkStdlibShutilArchiveFormatTable()
    if !table.Has(format)
        throw ValueError("unknown archive format '" format "'", -1)
    info := table[format]
    archivePath := base_name . info.ext

    ; The directory whose CONTENTS get archived.
    srcDir := IsSet(root_dir) ? AhkStdlibShutilPathString(root_dir) : A_WorkingDir
    srcDir := AhkStdlibShutilFullPath(srcDir)
    inner := IsSet(base_dir) ? AhkStdlibShutilPathString(base_dir) : "."

    ; Ensure the destination directory exists.
    SplitPath archivePath, , &archiveDir
    if archiveDir != "" && !DirExist(archiveDir)
        DirCreate archiveDir
    if FileExist(archivePath)
        FileDelete archivePath

    if format = "zip" {
        ; Compress-Archive zips the directory contents (use \* to avoid nesting).
        target := inner = "." ? srcDir "\*" : srcDir "\" inner
        cmd := 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path ' AhkStdlibShutilQuotePS(target) ' -DestinationPath ' AhkStdlibShutilQuotePS(archivePath) ' -Force"'
        AhkStdlibShutilRunWaitChecked(cmd, srcDir)
    } else {
        flag := (format = "gztar") ? "z" : (format = "bztar") ? "j" : (format = "xztar") ? "J" : ""
        ; tar -c[flag]f <archive> -C <srcDir> <inner>
        cmd := AhkStdlibShutilTarExe() ' -c' flag 'f ' AhkStdlibShutilQuoteArg(archivePath) ' -C ' AhkStdlibShutilQuoteArg(srcDir) ' ' AhkStdlibShutilQuoteArg(inner)
        AhkStdlibShutilRunWaitChecked(cmd, srcDir)
    }
    if !FileExist(archivePath)
        throw AhkStdlibShutilError("archive creation failed: '" archivePath "'", -1)
    return archivePath
}

AhkStdlibShutilUnpackArchive(filename, extract_dir := unset, format := unset)
{
    archivePath := AhkStdlibShutilFullPath(AhkStdlibShutilPathString(filename))
    if !FileExist(archivePath)
        throw OSError("No such file or directory: '" archivePath "'", -1)
    destDir := IsSet(extract_dir) ? AhkStdlibShutilPathString(extract_dir) : A_WorkingDir
    destDir := AhkStdlibShutilFullPath(destDir)
    if !DirExist(destDir)
        DirCreate destDir

    resolved := IsSet(format) ? format : AhkStdlibShutilInferArchiveFormat(archivePath)
    if resolved = "" || resolved = "zip" && !IsSet(format) && AhkStdlibShutilHasExt(archivePath, ".zip")
        resolved := "zip"

    if resolved = "zip" {
        cmd := 'powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path ' AhkStdlibShutilQuotePS(archivePath) ' -DestinationPath ' AhkStdlibShutilQuotePS(destDir) ' -Force"'
        AhkStdlibShutilRunWaitChecked(cmd, destDir)
    } else {
        cmd := AhkStdlibShutilTarExe() ' -xf ' AhkStdlibShutilQuoteArg(archivePath) ' -C ' AhkStdlibShutilQuoteArg(destDir)
        AhkStdlibShutilRunWaitChecked(cmd, destDir)
    }
    return destDir
}

AhkStdlibShutilInferArchiveFormat(path)
{
    lower := StrLower(path)
    for entry in AhkStdlibShutilGetUnpackFormats() {
        for ext in entry[2] {
            if SubStr(lower, -StrLen(ext)) = ext
                return entry[1]
        }
    }
    throw AhkStdlibShutilError("Unknown archive format '" path "'", -1)
}

AhkStdlibShutilHasExt(path, ext)
{
    return SubStr(StrLower(path), -StrLen(ext)) = StrLower(ext)
}

AhkStdlibShutilQuotePS(value)
{
    ; PowerShell single-quoted literal: double internal single quotes.
    return "'" StrReplace(value, "'", "''") "'"
}

; Prefer the Windows-native bsdtar in System32 over any MSYS/Git tar that may
; precede it on PATH; the MSYS build mangles Windows-style paths.
AhkStdlibShutilTarExe()
{
    native := A_WinDir "\System32\tar.exe"
    if FileExist(native)
        return AhkStdlibShutilQuoteArg(native)
    return "tar"
}

AhkStdlibShutilQuoteArg(value)
{
    return '"' StrReplace(value, '"', '\"') '"'
}

AhkStdlibShutilRunWaitChecked(cmd, workingDir := "")
{
    ; Run the executable directly (no cmd /c): cmd.exe's /c quote-stripping rule
    ; mangles a command that both starts and ends with a double quote.
    exitCode := RunWait(cmd, workingDir, "Hide")
    if exitCode != 0
        throw AhkStdlibShutilError("archive command failed (exit " exitCode "): " cmd, -1)
    return exitCode
}
