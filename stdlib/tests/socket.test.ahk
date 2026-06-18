#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\socket>

class StdlibSocketTest
{
    static SocketExposesModuleConstants()
    {
        AhkTest.AssertEqual(2, stdlib.socket.AF_INET)
        AhkTest.AssertEqual(1, stdlib.socket.SOCK_STREAM)
        AhkTest.AssertEqual(6, stdlib.socket.IPPROTO_TCP)
        AhkTest.AssertEqual(true, stdlib.socket.has_ipv6)
    }

    static GetHostnameMatchesLocalProbe()
    {
        hostname := stdlib.socket.gethostname()

        AhkTest.AssertEqual(A_ComputerName, hostname)
    }

    static GetHostnameRejectsArgumentsLikePython()
    {
        err := AhkTest.Raises(TypeError, (*) => stdlib.socket.gethostname(1))

        AhkTest.AssertEqual("_socket.gethostname() takes no arguments (1 given)", err.Message)
    }

    static SocketFactoryBuildsClosableDefaultSocket()
    {
        sock := stdlib.socket.socket()
        try {
            AhkTest.AssertEqual(stdlib.socket.AF_INET, sock.family)
            AhkTest.AssertEqual(stdlib.socket.SOCK_STREAM, sock.type)
            AhkTest.AssertEqual(0, sock.proto)
            AhkTest.AssertTrue(sock.fileno() is Integer)
            AhkTest.AssertEqual(false, sock.closed)
            AhkTest.AssertContains("<socket.socket", sock.__Repr())
        } finally {
            sock.close()
        }

        AhkTest.AssertEqual(true, sock.closed)
        AhkTest.AssertEqual(-1, sock.fileno())
    }

    static SocketFactoryAcceptsCoveredKeywordObject()
    {
        sock := stdlib.socket.socket({ family: stdlib.socket.AF_INET, type: stdlib.socket.SOCK_STREAM, proto: stdlib.socket.IPPROTO_TCP, fileno: stdlib.None })
        try {
            AhkTest.AssertEqual(stdlib.socket.AF_INET, sock.family)
            AhkTest.AssertEqual(stdlib.socket.SOCK_STREAM, sock.type)
            AhkTest.AssertEqual(stdlib.socket.IPPROTO_TCP, sock.proto)
        } finally {
            sock.close()
        }
    }

    static SocketFactoryRejectsUnexpectedKeyword()
    {
        err := AhkTest.Raises(TypeError, (*) => stdlib.socket.socket({ extra: 1 }))

        AhkTest.AssertEqual("socket() got an unexpected keyword argument 'extra'", err.Message)
    }

    static ByteOrderHelpersRoundTrip()
    {
        AhkTest.AssertEqual(0x3412, stdlib.socket.htons(0x1234))
        AhkTest.AssertEqual(0x1234, stdlib.socket.ntohs(stdlib.socket.htons(0x1234)))
    }

    static GetHostByNameResolvesLoopback()
    {
        AhkTest.AssertEqual("127.0.0.1", stdlib.socket.gethostbyname("127.0.0.1"))
        AhkTest.AssertEqual("127.0.0.1", stdlib.socket.gethostbyname("localhost"))
    }

    static LoopbackSendRecvRoundTrips()
    {
        ; Single-threaded TCP loopback: the kernel completes the handshake from
        ; the listen backlog, so connect() returns before accept() is called.
        server := stdlib.socket.socket()
        client := ""
        conn := ""
        try {
            server.setsockopt(stdlib.socket.SOL_SOCKET, stdlib.socket.SO_REUSEADDR, 1)
            server.bind(["127.0.0.1", 0])
            server.listen(1)
            addr := server.getsockname()
            port := addr[2]
            AhkTest.AssertTrue(port > 0)

            client := stdlib.socket.socket()
            client.connect(["127.0.0.1", port])

            accepted := server.accept()
            conn := accepted[1]
            AhkTest.AssertEqual("127.0.0.1", accepted[2][1])

            client.sendall("ping")
            data := conn.recv(16)
            AhkTest.AssertEqual(4, data.Size)
            AhkTest.AssertEqual(112, NumGet(data, 0, "UChar"))   ; 'p'

            conn.sendall("pong")
            back := client.recv(16)
            AhkTest.AssertEqual(4, back.Size)
            AhkTest.AssertEqual(111, NumGet(back, 1, "UChar"))   ; 'o'
        } finally {
            if IsObject(conn)
                conn.close()
            if IsObject(client)
                client.close()
            server.close()
        }
    }
}

AhkTest.Test("socket exposes module constants", (*) => StdlibSocketTest.SocketExposesModuleConstants())
AhkTest.Test("socket.gethostname matches local host baseline", (*) => StdlibSocketTest.GetHostnameMatchesLocalProbe())
AhkTest.Test("socket.gethostname rejects positional arguments", (*) => StdlibSocketTest.GetHostnameRejectsArgumentsLikePython())
AhkTest.Test("socket.socket builds closable default sockets", (*) => StdlibSocketTest.SocketFactoryBuildsClosableDefaultSocket())
AhkTest.Test("socket.socket accepts covered keyword object", (*) => StdlibSocketTest.SocketFactoryAcceptsCoveredKeywordObject())
AhkTest.Test("socket.socket rejects unexpected keyword objects", (*) => StdlibSocketTest.SocketFactoryRejectsUnexpectedKeyword())
AhkTest.Test("socket byte-order helpers round-trip", (*) => StdlibSocketTest.ByteOrderHelpersRoundTrip())
AhkTest.Test("socket.gethostbyname resolves loopback", (*) => StdlibSocketTest.GetHostByNameResolvesLoopback())
AhkTest.Test("socket loopback send/recv round-trips", (*) => StdlibSocketTest.LoopbackSendRecvRoundTrips())
