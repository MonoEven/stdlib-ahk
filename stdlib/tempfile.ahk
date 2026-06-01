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
            try {
                DirDelete this.name
            } catch {
                if DirExist(this.name) != ""
                    DirDelete this.name, true
            }
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

AhkStdlibTempfileRandomName()
{
    static chars := "abcdefghijklmnopqrstuvwxyz0123456789_"
    result := ""
    loop 8 {
        index := Random(1, StrLen(chars))
        result .= SubStr(chars, index, 1)
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
