#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibSocket
{
    static AF_INET := 2
    static SOCK_STREAM := 1
    static IPPROTO_TCP := 6
    static has_ipv6 := true

    static gethostname(args*)
    {
        if args.Length = 0
            return A_ComputerName
        if args.Length = 1
            throw TypeError("_socket.gethostname() takes no arguments (1 given)", -1)
        throw TypeError("_socket.gethostname() takes no arguments (" args.Length " given)", -1)
    }

    static socket(args*)
    {
        return AhkStdlibSocketValue(args*)
    }
}

class AhkStdlibSocketValue
{
    __New(args*)
    {
        family := AhkStdlibSocket.AF_INET
        sockType := AhkStdlibSocket.SOCK_STREAM
        proto := 0
        fileno := stdlib.None

        if args.Length = 1 && Type(args[1]) = "Object" {
            seen := Map()
            for key, value in args[1].OwnProps() {
                if seen.Has(key)
                    throw TypeError("socket() got multiple values for keyword argument '" key "'", -1)
                seen[key] := true
                switch key {
                    case "family":
                        family := value
                    case "type":
                        sockType := value
                    case "proto":
                        proto := value
                    case "fileno":
                        fileno := value
                    default:
                        throw TypeError("socket() got an unexpected keyword argument '" key "'", -1)
                }
            }
        } else {
            if args.Length > 4
                throw TypeError("socket() takes at most 4 arguments (" args.Length " given)", -1)
            if args.Length >= 1
                family := args[1]
            if args.Length >= 2
                sockType := args[2]
            if args.Length >= 3
                proto := args[3]
            if args.Length >= 4
                fileno := args[4]
        }

        this.family := AhkStdlibSocketNormalizeInt("family", family)
        this.type := AhkStdlibSocketNormalizeInt("type", sockType)
        if AhkStdlibIsNone(fileno)
            this.proto := AhkStdlibSocketNormalizeInt("proto", proto)
        else
            this.proto := AhkStdlibSocketNormalizeInt("proto", proto)
        this.closed := false
        this.AhkStdlibSocketHandle := AhkStdlibSocketCreateHandle(this.family, this.type, this.proto, fileno)
    }

    close()
    {
        if this.closed
            return stdlib.None
        this.closed := true
        if this.AhkStdlibSocketHandle != -1
            DllCall("Ws2_32\closesocket", "Ptr", this.AhkStdlibSocketHandle, "Int")
        this.AhkStdlibSocketHandle := -1
        return stdlib.None
    }

    fileno()
    {
        return this.closed ? -1 : this.AhkStdlibSocketHandle
    }

    __Delete()
    {
        try this.close()
    }

    __Repr()
    {
        return "<socket.socket fd=" this.fileno() ", family=" this.family ", type=" this.type ", proto=" this.proto ">"
    }
}

stdlib.socket := AhkStdlibSocket

AhkStdlibSocketNormalizeInt(name, value)
{
    if (value is Integer) || AhkStdlibIsBool(value)
        return value is Integer ? value : value.Value
    throw TypeError("'" AhkStdlibPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
}

AhkStdlibSocketCreateHandle(family, sockType, proto, fileno)
{
    AhkStdlibSocketEnsureStartup()

    if !AhkStdlibIsNone(fileno)
        throw OSError("socket(fileno=...) is not implemented in the current AHK slice", -1)

    handle := DllCall("Ws2_32\socket", "Int", family, "Int", sockType, "Int", proto, "Ptr")
    if handle = -1
        throw OSError(AhkStdlibSocketLastErrorMessage(), -1)
    return handle
}

AhkStdlibSocketEnsureStartup()
{
    static started := false
    static startupError := ""
    if started {
        if startupError != ""
            throw OSError(startupError, -1)
        return
    }

    started := true
    wsaData := Buffer(394 + A_PtrSize, 0)
    err := DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", wsaData.Ptr, "Int")
    if err {
        startupError := "WSAStartup failed with error " err
        throw OSError(startupError, -1)
    }
    if NumGet(wsaData, 2, "UShort") != 0x0202 {
        startupError := "Winsock version 2.2 not available"
        throw OSError(startupError, -1)
    }
}

AhkStdlibSocketLastErrorMessage()
{
    err := DllCall("Ws2_32\WSAGetLastError", "Int")
    if err = 0
        return "socket operation failed"
    return "[WinError " err "] socket operation failed"
}
