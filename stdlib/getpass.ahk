#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibGetpass
{
    static GetPassWarning := AhkStdlibGetPassWarning

    static getuser(args*)
    {
        if args.Length > 0
            throw TypeError("getuser() takes 0 positional arguments but " args.Length " was given", -1)

        for _, name in ["LOGNAME", "USER", "LNAME", "USERNAME"] {
            user := EnvGet(name)
            if user != ""
                return user
        }

        throw ModuleNotFoundError("No module named 'pwd'", -1)
    }

    static getpass(prompt := "Password: ", stream := unset)
    {
        if !(prompt is String)
            prompt := String(prompt)
        return AhkStdlibGetpassReadNoEcho(prompt)
    }
}

class AhkStdlibGetPassWarning extends Error
{
}

stdlib.getpass := AhkStdlibGetpass

AhkStdlibGetpassReadNoEcho(prompt)
{
    static STD_INPUT_HANDLE := -10
    static STD_ERROR_HANDLE := -12
    static ENABLE_ECHO_INPUT := 0x0004
    static ENABLE_LINE_INPUT := 0x0002
    static ENABLE_PROCESSED_INPUT := 0x0001

    hIn := DllCall("GetStdHandle", "Int", STD_INPUT_HANDLE, "Ptr")
    hErr := DllCall("GetStdHandle", "Int", STD_ERROR_HANDLE, "Ptr")

    ; Determine whether stdin is a real console. GetConsoleMode fails on a pipe
    ; or redirected input, in which case Python falls back to a plain read.
    oldMode := 0
    isConsole := DllCall("GetConsoleMode", "Ptr", hIn, "UInt*", &oldMode, "Int")
    if !isConsole
        return AhkStdlibGetpassFallback(prompt)

    ; Write the prompt to stderr (Python writes the prompt to the tty/stderr).
    AhkStdlibGetpassWritePrompt(hErr, prompt)

    ; Disable echo but keep line + processed input so Backspace and Enter work.
    newMode := (oldMode & ~ENABLE_ECHO_INPUT) | ENABLE_LINE_INPUT | ENABLE_PROCESSED_INPUT
    DllCall("SetConsoleMode", "Ptr", hIn, "UInt", newMode)

    try {
        line := AhkStdlibGetpassReadLine(hIn)
    } finally {
        DllCall("SetConsoleMode", "Ptr", hIn, "UInt", oldMode)
        ; Echo the newline the user's hidden Enter did not show.
        AhkStdlibGetpassWritePrompt(hErr, "`r`n")
    }

    return line
}

AhkStdlibGetpassWritePrompt(handle, text)
{
    if text = ""
        return
    bytes := Buffer(StrPut(text, "UTF-8"))
    written := StrPut(text, bytes, "UTF-8") - 1
    dummy := 0
    DllCall("WriteFile", "Ptr", handle, "Ptr", bytes.Ptr, "UInt", written, "UInt*", &dummy, "Ptr", 0)
}

AhkStdlibGetpassReadLine(handle)
{
    ; ReadConsoleW returns UTF-16 units. Read up to 4096 chars per call.
    capacity := 4096
    buf := Buffer(capacity * 2, 0)
    charsRead := 0
    ok := DllCall("ReadConsoleW"
        , "Ptr", handle
        , "Ptr", buf.Ptr
        , "UInt", capacity
        , "UInt*", &charsRead
        , "Ptr", 0
        , "Int")
    if !ok || charsRead = 0
        return ""
    text := StrGet(buf.Ptr, charsRead, "UTF-16")
    ; Strip the trailing CR/LF the console leaves on the buffer.
    return RTrim(text, "`r`n")
}

AhkStdlibGetpassFallback(prompt)
{
    ; No console (redirected stdin): Python emits a GetPassWarning and reads the
    ; line without hiding it. Read from stdin via a CRT-backed FileObject.
    try {
        stdin := FileOpen("*", "r")
        if IsObject(stdin) {
            line := stdin.ReadLine()
            return RTrim(line, "`r`n")
        }
    }
    throw AhkStdlibGetPassWarning("Cannot control echo on the terminal; password input may be echoed.", -1)
}
