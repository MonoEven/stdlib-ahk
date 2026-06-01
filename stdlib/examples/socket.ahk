#Requires AutoHotkey v2.0

#Include <stdlib\socket>

socket_example_af_inet := stdlib.socket.AF_INET
socket_example_sock_stream := stdlib.socket.SOCK_STREAM
socket_example_ipproto_tcp := stdlib.socket.IPPROTO_TCP
socket_example_has_ipv6 := stdlib.socket.has_ipv6
socket_example_hostname := stdlib.socket.gethostname()

socket_example_default := stdlib.socket.socket()
socket_example_default_family := socket_example_default.family
socket_example_default_type := socket_example_default.type
socket_example_default_proto := socket_example_default.proto
socket_example_default_repr := socket_example_default.__Repr()
socket_example_default_fileno := socket_example_default.fileno()
socket_example_default_close_return := socket_example_default.close()
socket_example_default_closed := socket_example_default.closed
socket_example_default_fileno_after_close := socket_example_default.fileno()

socket_example_keyword := stdlib.socket.socket({ family: stdlib.socket.AF_INET, type: stdlib.socket.SOCK_STREAM, proto: stdlib.socket.IPPROTO_TCP, fileno: stdlib.None })
socket_example_keyword_proto := socket_example_keyword.proto
socket_example_keyword.close()

socket_example_bad_hostname_error := ""
try {
    stdlib.socket.gethostname(1)
} catch TypeError as err {
    socket_example_bad_hostname_error := err.Message
}
