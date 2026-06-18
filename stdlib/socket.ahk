#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibSocket
{
    static AF_INET := 2
    static SOCK_STREAM := 1
    static SOCK_DGRAM := 2
    static IPPROTO_TCP := 6
    static SOL_SOCKET := 0xFFFF
    static SO_REUSEADDR := 0x0004
    static SO_RCVTIMEO := 0x1006
    static SO_SNDTIMEO := 0x1005
    static INADDR_ANY := 0
    static SHUT_RD := 0
    static SHUT_WR := 1
    static SHUT_RDWR := 2
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

    static htons(value)
    {
        return AhkStdlibSocketHtons(value)
    }

    static ntohs(value)
    {
        return AhkStdlibSocketHtons(value)   ; byte-swap is its own inverse for 16-bit
    }

    static htonl(value)
    {
        return AhkStdlibSocketHtonl(value)
    }

    static ntohl(value)
    {
        return AhkStdlibSocketHtonl(value)
    }

    static inet_aton(ip)
    {
        return AhkStdlibSocketInetAddr(ip)
    }

    static inet_addr(ip)
    {
        return AhkStdlibSocketInetAddr(ip)
    }

    static gethostbyname(name)
    {
        return AhkStdlibSocketGetHostByName(name)
    }

    static getaddrinfo(host, port, family := 0, type := 0, proto := 0, flags := 0)
    {
        return AhkStdlibSocketGetAddrInfo(host, port)
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

    bind(address, port := unset)
    {
        this.AhkStdlibEnsureOpen()
        parsed := AhkStdlibSocketParseAddress(address, port?)
        sa := AhkStdlibSocketMakeSockaddr(parsed.host, parsed.port)
        if DllCall("Ws2_32\bind", "Ptr", this.AhkStdlibSocketHandle, "Ptr", sa.Ptr, "Int", sa.Size, "Int") != 0
            throw OSError(AhkStdlibSocketLastErrorMessage(), -1)
        return stdlib.None
    }

    listen(backlog := 128)
    {
        this.AhkStdlibEnsureOpen()
        if DllCall("Ws2_32\listen", "Ptr", this.AhkStdlibSocketHandle, "Int", backlog, "Int") != 0
            throw OSError(AhkStdlibSocketLastErrorMessage(), -1)
        return stdlib.None
    }

    accept()
    {
        this.AhkStdlibEnsureOpen()
        addr := Buffer(16, 0)
        addrLen := Buffer(4, 0)
        NumPut("Int", 16, addrLen)
        conn := DllCall("Ws2_32\accept", "Ptr", this.AhkStdlibSocketHandle, "Ptr", addr.Ptr, "Ptr", addrLen.Ptr, "Ptr")
        if conn = -1
            throw OSError(AhkStdlibSocketLastErrorMessage(), -1)
        peer := AhkStdlibSocketParseSockaddr(addr)
        ; Wrap the accepted handle in a fresh socket object without re-creating
        ; an OS handle.
        sock := AhkStdlibSocketFromHandle(conn, this.family, this.type, this.proto)
        return [sock, [peer.host, peer.port]]
    }

    connect(address, port := unset)
    {
        this.AhkStdlibEnsureOpen()
        parsed := AhkStdlibSocketParseAddress(address, port?)
        sa := AhkStdlibSocketMakeSockaddr(parsed.host, parsed.port)
        if DllCall("Ws2_32\connect", "Ptr", this.AhkStdlibSocketHandle, "Ptr", sa.Ptr, "Int", sa.Size, "Int") != 0
            throw OSError(AhkStdlibSocketLastErrorMessage(), -1)
        return stdlib.None
    }

    send(data, flags := 0)
    {
        this.AhkStdlibEnsureOpen()
        buf := (data is Buffer) ? data : AhkStdlibSocketBytesToBuffer(data)
        sent := DllCall("Ws2_32\send", "Ptr", this.AhkStdlibSocketHandle, "Ptr", buf.Ptr, "Int", buf.Size, "Int", flags, "Int")
        if sent = -1
            throw OSError(AhkStdlibSocketLastErrorMessage(), -1)
        return sent
    }

    sendall(data, flags := 0)
    {
        this.AhkStdlibEnsureOpen()
        buf := (data is Buffer) ? data : AhkStdlibSocketBytesToBuffer(data)
        total := 0
        while total < buf.Size {
            sent := DllCall("Ws2_32\send", "Ptr", this.AhkStdlibSocketHandle, "Ptr", buf.Ptr + total, "Int", buf.Size - total, "Int", flags, "Int")
            if sent = -1
                throw OSError(AhkStdlibSocketLastErrorMessage(), -1)
            total += sent
        }
        return stdlib.None
    }

    recv(bufsize, flags := 0)
    {
        this.AhkStdlibEnsureOpen()
        buf := Buffer(bufsize)
        got := DllCall("Ws2_32\recv", "Ptr", this.AhkStdlibSocketHandle, "Ptr", buf.Ptr, "Int", bufsize, "Int", flags, "Int")
        if got = -1
            throw OSError(AhkStdlibSocketLastErrorMessage(), -1)
        if got = 0
            return Buffer(0)
        return AhkStdlibSocketTrimBuffer(buf, got)
    }

    getsockname()
    {
        this.AhkStdlibEnsureOpen()
        addr := Buffer(16, 0)
        addrLen := Buffer(4, 0)
        NumPut("Int", 16, addrLen)
        if DllCall("Ws2_32\getsockname", "Ptr", this.AhkStdlibSocketHandle, "Ptr", addr.Ptr, "Ptr", addrLen.Ptr, "Int") != 0
            throw OSError(AhkStdlibSocketLastErrorMessage(), -1)
        parsed := AhkStdlibSocketParseSockaddr(addr)
        return [parsed.host, parsed.port]
    }

    getpeername()
    {
        this.AhkStdlibEnsureOpen()
        addr := Buffer(16, 0)
        addrLen := Buffer(4, 0)
        NumPut("Int", 16, addrLen)
        if DllCall("Ws2_32\getpeername", "Ptr", this.AhkStdlibSocketHandle, "Ptr", addr.Ptr, "Ptr", addrLen.Ptr, "Int") != 0
            throw OSError(AhkStdlibSocketLastErrorMessage(), -1)
        parsed := AhkStdlibSocketParseSockaddr(addr)
        return [parsed.host, parsed.port]
    }

    setsockopt(level, optname, value)
    {
        this.AhkStdlibEnsureOpen()
        optval := Buffer(4, 0)
        NumPut("Int", value, optval)
        if DllCall("Ws2_32\setsockopt", "Ptr", this.AhkStdlibSocketHandle, "Int", level, "Int", optname, "Ptr", optval.Ptr, "Int", 4, "Int") != 0
            throw OSError(AhkStdlibSocketLastErrorMessage(), -1)
        return stdlib.None
    }

    getsockopt(level, optname, buflen := 0)
    {
        this.AhkStdlibEnsureOpen()
        optval := Buffer(4, 0)
        optlen := Buffer(4, 0)
        NumPut("Int", 4, optlen)
        if DllCall("Ws2_32\getsockopt", "Ptr", this.AhkStdlibSocketHandle, "Int", level, "Int", optname, "Ptr", optval.Ptr, "Ptr", optlen.Ptr, "Int") != 0
            throw OSError(AhkStdlibSocketLastErrorMessage(), -1)
        return NumGet(optval, 0, "Int")
    }

    settimeout(seconds)
    {
        this.AhkStdlibEnsureOpen()
        ; Windows SO_RCVTIMEO/SO_SNDTIMEO take a DWORD of milliseconds.
        ms := AhkStdlibIsNone(seconds) ? 0 : Integer(seconds * 1000)
        this.AhkStdlibTimeoutMs := ms
        optval := Buffer(4, 0)
        NumPut("UInt", ms, optval)
        DllCall("Ws2_32\setsockopt", "Ptr", this.AhkStdlibSocketHandle, "Int", AhkStdlibSocket.SOL_SOCKET, "Int", AhkStdlibSocket.SO_RCVTIMEO, "Ptr", optval.Ptr, "Int", 4, "Int")
        DllCall("Ws2_32\setsockopt", "Ptr", this.AhkStdlibSocketHandle, "Int", AhkStdlibSocket.SOL_SOCKET, "Int", AhkStdlibSocket.SO_SNDTIMEO, "Ptr", optval.Ptr, "Int", 4, "Int")
        return stdlib.None
    }

    gettimeout()
    {
        return HasProp(this, "AhkStdlibTimeoutMs") && this.AhkStdlibTimeoutMs > 0 ? this.AhkStdlibTimeoutMs / 1000.0 : stdlib.None
    }

    shutdown(how)
    {
        this.AhkStdlibEnsureOpen()
        DllCall("Ws2_32\shutdown", "Ptr", this.AhkStdlibSocketHandle, "Int", how, "Int")
        return stdlib.None
    }

    AhkStdlibEnsureOpen()
    {
        if this.closed
            throw OSError("[WinError 10038] An operation was attempted on something that is not a socket", -1)
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

; ---- socket helpers (real TCP I/O via ws2_32) ----
; Wrap an already-connected OS handle (from accept) in a socket object without
; calling socket() again.
AhkStdlibSocketFromHandle(handle, family, type, proto)
{
    ; Build an instance whose methods resolve, without running __New (which
    ; would allocate a brand-new OS handle); we already own `handle`.
    sock := Object()
    ObjSetBase(sock, AhkStdlibSocketValue.Prototype)
    sock.family := family
    sock.type := type
    sock.proto := proto
    sock.closed := false
    sock.AhkStdlibSocketHandle := handle
    return sock
}

; Normalize an address argument: either ("host", port) or [host, port].
AhkStdlibSocketParseAddress(address, port := unset)
{
    if IsSet(port)
        return { host: address, port: port }
    if address is Array && address.Length >= 2
        return { host: address[1], port: address[2] }
    throw TypeError("address must be a (host, port) pair", -1)
}

; Build a sockaddr_in: family(2) + port(2, network order) + addr(4) + zero(8).
AhkStdlibSocketMakeSockaddr(host, port)
{
    sa := Buffer(16, 0)
    NumPut("UShort", AhkStdlibSocket.AF_INET, sa, 0)
    NumPut("UShort", AhkStdlibSocketHtons(port), sa, 2)
    NumPut("UInt", AhkStdlibSocketInetAddr(host), sa, 4)
    return sa
}

; Parse a sockaddr_in back into { host, port }.
AhkStdlibSocketParseSockaddr(sa)
{
    portNet := NumGet(sa, 2, "UShort")
    addr := NumGet(sa, 4, "UInt")
    return { host: AhkStdlibSocketInetNtoa(addr), port: AhkStdlibSocketHtons(portNet) }
}

; 16-bit host<->network byte swap.
AhkStdlibSocketHtons(value)
{
    value &= 0xFFFF
    return ((value & 0xFF) << 8) | ((value >> 8) & 0xFF)
}

; 32-bit host<->network byte swap.
AhkStdlibSocketHtonl(value)
{
    value &= 0xFFFFFFFF
    return ((value & 0xFF) << 24) | ((value & 0xFF00) << 8) | ((value >> 8) & 0xFF00) | ((value >> 24) & 0xFF)
}

; Dotted-quad string -> 32-bit address in NETWORK byte order (as inet_addr).
AhkStdlibSocketInetAddr(ip)
{
    if ip is Integer
        return ip & 0xFFFFFFFF
    parts := StrSplit(ip, ".")
    if parts.Length != 4
        return AhkStdlibSocketResolveToInetAddr(ip)
    result := 0
    for index, octet in parts {
        n := Integer(octet)
        if n < 0 || n > 255
            throw OSError("illegal IP address string passed to inet_addr", -1)
        ; Network byte order: first octet is the low byte.
        result |= (n & 0xFF) << (8 * (index - 1))
    }
    return result & 0xFFFFFFFF
}

; 32-bit network-order address -> dotted-quad string.
AhkStdlibSocketInetNtoa(addr)
{
    a := addr & 0xFF
    b := (addr >> 8) & 0xFF
    c := (addr >> 16) & 0xFF
    d := (addr >> 24) & 0xFF
    return a "." b "." c "." d
}

; Resolve a hostname to a network-order address via getaddrinfo.
AhkStdlibSocketResolveToInetAddr(host)
{
    info := AhkStdlibSocketGetAddrInfo(host, 0)
    return AhkStdlibSocketInetAddr(info[1][5][1])
}

AhkStdlibSocketGetHostByName(name)
{
    info := AhkStdlibSocketGetAddrInfo(name, 0)
    ; CPython returns the resolved dotted-quad string.
    return info[1][5][1]
}

; Minimal IPv4 getaddrinfo: returns [[family,type,proto,canonname,[ip,port]], ...].
AhkStdlibSocketGetAddrInfo(host, port)
{
    AhkStdlibSocketEnsureStartup()
    if AhkStdlibIsNone(host) || host = ""
        host := "127.0.0.1"
    resultPtr := Buffer(A_PtrSize, 0)
    ; AF_INET hint so we only get IPv4.
    hints := Buffer(48, 0)
    NumPut("Int", AhkStdlibSocket.AF_INET, hints, 4)   ; ai_family at offset 4
    portStr := port = 0 ? "" : String(port)
    rc := DllCall("Ws2_32\getaddrinfo", "AStr", host, "AStr", portStr, "Ptr", hints.Ptr, "Ptr", resultPtr.Ptr, "Int")
    if rc != 0
        throw OSError(AhkStdlibSocketLastErrorMessage(), -1)
    addrinfo := NumGet(resultPtr, 0, "Ptr")
    results := []
    cur := addrinfo
    while cur {
        ; x64 ADDRINFOA layout: ai_family@4, ai_addr ptr@32, ai_next ptr@40
        ; (ai_addrlen is a size_t at 16, ai_canonname ptr at 24).
        ai_addr := NumGet(cur + 32, "Ptr")
        if ai_addr {
            saPort := AhkStdlibSocketHtons(NumGet(ai_addr + 2, "UShort"))
            saAddr := NumGet(ai_addr + 4, "UInt")
            results.Push([AhkStdlibSocket.AF_INET, AhkStdlibSocket.SOCK_STREAM, AhkStdlibSocket.IPPROTO_TCP, "", [AhkStdlibSocketInetNtoa(saAddr), saPort]])
        }
        cur := NumGet(cur + 40, "Ptr")   ; ai_next
    }
    DllCall("Ws2_32\freeaddrinfo", "Ptr", addrinfo)
    if results.Length = 0
        throw OSError("getaddrinfo returned no results", -1)
    return results
}

AhkStdlibSocketBytesToBuffer(data)
{
    if data is Buffer
        return data
    n := StrLen(data)
    buf := Buffer(n)
    i := 1
    while i <= n {
        NumPut("UChar", Ord(SubStr(data, i, 1)) & 0xFF, buf, i - 1)
        i += 1
    }
    return buf
}

AhkStdlibSocketTrimBuffer(buf, count)
{
    out := Buffer(count)
    if count > 0
        DllCall("RtlMoveMemory", "Ptr", out.Ptr, "Ptr", buf.Ptr, "UPtr", count)
    return out
}
