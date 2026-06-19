#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\array>
#Include <stdlib\base64>
#Include <stdlib\hashlib>
#Include <stdlib\hmac>
#Include <stdlib\io>
#Include <stdlib\pathlib>
#Include <stdlib\statistics>
#Include <stdlib\tempfile>

quickstart_payload := StdlibQuickstartBytes("abc")

quickstart_encoded := stdlib.base64.b64encode(quickstart_payload)
quickstart_stream := stdlib.io.BytesIO(quickstart_encoded)
quickstart_numbers := stdlib.array.array("i", [1, 2, 3, 4])
quickstart_window := quickstart_numbers[stdlib.slice(1, 4, 2)].tolist()
quickstart_mean := stdlib.statistics.mean([2, 4, 6])
quickstart_sha256 := stdlib.hashlib.sha256(quickstart_payload).hexdigest()
quickstart_hmac := stdlib.hmac.new(StdlibQuickstartBytes("key"), quickstart_payload, "sha256").hexdigest()

quickstart_root := stdlib.tempfile.mkdtemp("", "stdlib-quickstart-", stdlib.tempfile.gettempdir())
try {
    quickstart_file := stdlib.pathlib.Path(quickstart_root, "payload.txt")
    quickstart_file.write_text("abc", "UTF-8")
    quickstart_text := quickstart_file.read_text("UTF-8")
} finally {
    if DirExist(quickstart_root)
        DirDelete quickstart_root, true
}

AhkTest.AssertEqual("YWJj", StdlibQuickstartText(quickstart_stream.read()))
AhkTest.AssertEqual([2, 4], quickstart_window)
AhkTest.AssertEqual(4, quickstart_mean)
AhkTest.AssertEqual("abc", quickstart_text)
AhkTest.AssertEqual("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", quickstart_sha256)
AhkTest.AssertEqual("9c196e32dc0175f86f4b1cb89289d6619de6bee699e4c378e68309ed97a1a6ab", quickstart_hmac)

StdlibQuickstartBytes(text)
{
    size := StrPut(text, "UTF-8") - 1
    bytes := Buffer(size, 0)
    if size > 0
        StrPut(text, bytes, "UTF-8")
    return bytes
}

StdlibQuickstartText(bytes)
{
    if IsObject(bytes) && HasProp(bytes, "Ptr")
        return StrGet(bytes, "UTF-8")

    text := ""
    for value in bytes
        text .= Chr(value)
    return text
}
