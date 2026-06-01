#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibOs
{
    static system(command)
    {
        if !(command is String)
            throw TypeError("system() argument 'command' must be str, not " Type(command), -1)
        AhkStdlibOsCheckCommand(command)
        return RunWait(A_ComSpec " /c " command, , "Hide")
    }
}

stdlib.os := AhkStdlibOs

AhkStdlibOsCheckCommand(command)
{
    Loop StrLen(command) {
        if Ord(SubStr(command, A_Index, 1)) = 0
            throw ValueError("embedded null character", -1)
    }
}
