#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\json>

class StdlibTextJsonTest
{
    static TestLoadsParsesObjectsArraysBooleansAndNull()
    {
        source := "{`"name`":`"Ada`",`"nums`":[1,2.5,-3],`"ok`":true,`"no`":false,`"none`":null}"
        data := stdlib.json.loads(source)

        AhkTest.AssertEqual("Ada", data["name"])
        AhkTest.AssertEqual([1, 2.5, -3], data["nums"])
        AhkTest.AssertSame(stdlib.True, data["ok"])
        AhkTest.AssertSame(stdlib.False, data["no"])
        AhkTest.AssertSame(stdlib.json.Null, data["none"])
    }

    static TestDumpsRoundTripsMapsArraysNullAndEscapedStrings()
    {
        value := Map(
            "quote", "He said `"hi`"",
            "path", "C:\Temp\file.txt",
            "line", "a`nb",
            "none", stdlib.json.Null,
            "items", [1, "two"]
        )

        text := stdlib.json.dumps(value)
        parsed := stdlib.json.loads(text)

        AhkTest.AssertEqual("He said `"hi`"", parsed["quote"])
        AhkTest.AssertEqual("C:\Temp\file.txt", parsed["path"])
        AhkTest.AssertEqual("a`nb", parsed["line"])
        AhkTest.AssertSame(stdlib.json.Null, parsed["none"])
        AhkTest.AssertEqual([1, "two"], parsed["items"])
    }

    static TestLoadAndDumpUseFiles()
    {
        path := A_Temp "\stdlib-json-test-" A_TickCount "-" Random(100000, 999999) ".json"
        if FileExist(path)
            FileDelete path

        try {
            stdlib.json.dump(Map("items", [1, 2], "name", "file"), path)
            loaded := stdlib.json.load(path)

            AhkTest.AssertEqual([1, 2], loaded["items"])
            AhkTest.AssertEqual("file", loaded["name"])
        } finally {
            if FileExist(path)
                FileDelete path
        }
    }

    static TestDumpsSerializesExplicitJsonBooleansAsJsonLiterals()
    {
        AhkTest.AssertEqual("true", stdlib.json.dumps(stdlib.json.Bool(true)))
        AhkTest.AssertEqual("false", stdlib.json.dumps(stdlib.json.Bool(false)))
        AhkTest.AssertSame(stdlib.True, stdlib.json.True)
        AhkTest.AssertSame(stdlib.False, stdlib.json.False)
        AhkTest.AssertEqual("true", stdlib.json.dumps(stdlib.True))
        AhkTest.AssertEqual("false", stdlib.json.dumps(stdlib.False))
        AhkTest.AssertContains("`"ok`": true", stdlib.json.dumps(Map("ok", stdlib.True)))
        AhkTest.AssertContains("`"no`": false", stdlib.json.dumps(Map("no", stdlib.False)))
    }

    static TestDumpsUsesPythonDefaultSeparators()
    {
        AhkTest.AssertEqual("[1, `"two`", null]", stdlib.json.dumps([1, "two", stdlib.json.Null]))
        AhkTest.AssertEqual("{`"a`": 1}", stdlib.json.dumps(Map("a", 1)))
    }

    static TestDumpsEscapesNonAsciiByDefault()
    {
        AhkTest.AssertEqual("`"\u00e9`"", stdlib.json.dumps(Chr(0x00E9)))
        AhkTest.AssertEqual("`"\ud83d\ude00`"", stdlib.json.dumps(Chr(0x1F600)))
        AhkTest.AssertEqual("`"A\u00e9\ud83d\ude00`"", stdlib.json.dumps("A" Chr(0x00E9) Chr(0x1F600)))
    }

    static TestLoadsCombinesUnicodeSurrogatePairs()
    {
        value := stdlib.json.loads("`"\ud83d\ude00`"")

        AhkTest.AssertEqual(Chr(0x1F600), value)
        AhkTest.AssertEqual("`"\ud83d\ude00`"", stdlib.json.dumps(value))
    }

    static TestNullIsStableSingleton()
    {
        AhkTest.AssertSame(stdlib.json.Null, stdlib.json.loads("null"))
        AhkTest.AssertSame(stdlib.json.loads("null"), stdlib.json.loads("{`"none`":null}")["none"])
    }

    static TestLoadsRejectsInvalidJson()
    {
        AhkTest.AssertThrows(ValueError, (*) => stdlib.json.loads("{bad"))
    }

    static TestDumpsSortKeysOrdersMapKeys()
    {
        AhkTest.AssertEqual("{`"a`": 2, `"b`": 1}",
            stdlib.json.dumps(Map("b", 1, "a", 2), { sort_keys: true }))
    }

    static TestDumpsIndentProducesPrettyOutput()
    {
        value := Map("a", 1, "b", [1, 2])
        expected := "{`n  `"a`": 1,`n  `"b`": [`n    1,`n    2`n  ]`n}"
        AhkTest.AssertEqual(expected, stdlib.json.dumps(value, { indent: 2, sort_keys: true }))
    }

    static TestDumpsIndentEmptyContainersStayInline()
    {
        AhkTest.AssertEqual("[]", stdlib.json.dumps([], { indent: 2 }))
        AhkTest.AssertEqual("{}", stdlib.json.dumps(Map(), { indent: 2 }))
    }

    static TestDumpsCustomSeparators()
    {
        AhkTest.AssertEqual("{`"a`":1;`"b`":2}",
            stdlib.json.dumps(Map("a", 1, "b", 2), { sort_keys: true, separators: [";", ":"] }))
    }

    static TestDumpsDefaultCallbackConvertsUnknownTypes()
    {
        toText(value) => "converted"
        AhkTest.AssertEqual("`"converted`"",
            stdlib.json.dumps(StdlibJsonUnserializable(), { default: toText }))
    }

    static TestDumpsWithoutDefaultRaisesOnUnknownTypes()
    {
        AhkTest.AssertThrows(TypeError, (*) => stdlib.json.dumps(StdlibJsonUnserializable()))
    }

    static TestDumpsEnsureAsciiFalseEmitsRawUnicode()
    {
        ; U+00E9 is LATIN SMALL LETTER E WITH ACUTE.
        text := Chr(0x00E9)
        ; ensure_ascii=false lets the character pass through unescaped.
        AhkTest.AssertEqual("`"" text "`"", stdlib.json.dumps(text, { ensure_ascii: false }))
        ; Default escapes it as a lowercase \u sequence (like Python's json).
        AhkTest.AssertEqual(Chr(34) . "\u00e9" . Chr(34), stdlib.json.dumps(text))
    }

    static TestLoadsObjectHookTransformsObjects()
    {
        tag(obj) => (obj["seen"] := true, obj)
        result := stdlib.json.loads("{`"a`": 1}", { object_hook: tag })
        AhkTest.AssertTrue(result["seen"])
        AhkTest.AssertEqual(1, result["a"])
    }

    static TestLoadsParseFloatAndParseInt()
    {
        floats := stdlib.json.loads("[1.5, 2]", { parse_float: (s) => "F:" s, parse_int: (s) => "I:" s })
        AhkTest.AssertEqual("F:1.5", floats[1])
        AhkTest.AssertEqual("I:2", floats[2])
    }

    static TestLoadsRaisesJSONDecodeErrorWithPosition()
    {
        err := ""
        try
            stdlib.json.loads("{bad}")
        catch ValueError as e
            err := e
        AhkTest.AssertTrue(IsObject(err))
        AhkTest.AssertTrue(err is stdlib.json.JSONDecodeError)
        AhkTest.AssertEqual(1, err.pos)
        AhkTest.AssertEqual(1, err.lineno)
        AhkTest.AssertEqual(2, err.colno)
    }

    static TestJSONEncoderEncodeAndIterencode()
    {
        encoder := stdlib.json.JSONEncoder({ indent: 2, sort_keys: true })
        encoded := encoder.encode(Map("a", 1, "b", 2))
        AhkTest.AssertEqual("{`n  `"a`": 1,`n  `"b`": 2`n}", encoded)
        AhkTest.AssertEqual(2, encoder.indent)
        AhkTest.AssertTrue(encoder.sort_keys)
        chunks := encoder.iterencode([1, 2, 3])
        AhkTest.AssertEqual(1, chunks.Length)
        AhkTest.AssertEqual("[`n  1,`n  2,`n  3`n]", chunks[1])
    }

    static TestJSONEncoderDefaultRaises()
    {
        encoder := stdlib.json.JSONEncoder()
        AhkTest.AssertThrows(TypeError, (*) => encoder.default(StdlibJsonUnserializable()))
    }

    static TestJSONDecoderDecodeAndRawDecode()
    {
        decoder := stdlib.json.JSONDecoder()
        AhkTest.AssertEqual(42, decoder.decode("42"))
        result := decoder.raw_decode("  123 trailing data")
        AhkTest.AssertEqual(123, result[1])
        AhkTest.AssertTrue(result[2] >= 4)
    }

    static TestJSONDecoderObjectHook()
    {
        tag(obj) => (obj["tagged"] := true, obj)
        decoder := stdlib.json.JSONDecoder({ object_hook: tag })
        out := decoder.decode("{`"x`": 1}")
        AhkTest.AssertTrue(out["tagged"])
        AhkTest.AssertEqual(1, out["x"])
    }
}

class StdlibJsonUnserializable
{
}

AhkTest.Collect(StdlibTextJsonTest)
