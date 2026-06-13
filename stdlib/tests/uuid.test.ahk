#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\uuid>

class StdlibUuidTest
{
    static TestUuidCoveredStringParsingAndUuid4MatchObservedLocal310()
    {
        fixed := stdlib.uuid.UUID("12345678-1234-5678-1234-567812345678")
        plain := stdlib.uuid.UUID("12345678123456781234567812345678")
        braces := stdlib.uuid.UUID("{12345678-1234-5678-1234-567812345678}")
        urnValue := stdlib.uuid.UUID("urn:uuid:12345678-1234-5678-1234-567812345678")
        keyword := stdlib.uuid.UUID({ hex: "12345678-1234-5678-1234-567812345678" })
        generated := stdlib.uuid.uuid4()

        AhkTest.AssertEqual("12345678-1234-5678-1234-567812345678", String(fixed))
        AhkTest.AssertEqual("12345678123456781234567812345678", fixed.hex)
        AhkTest.AssertEqual("urn:uuid:12345678-1234-5678-1234-567812345678", fixed.urn)
        AhkTest.AssertEqual("UUID('12345678-1234-5678-1234-567812345678')", fixed.__Repr())
        AhkTest.AssertEqual("reserved for NCS compatibility", fixed.variant)
        AhkTest.AssertSame(stdlib.None, fixed.version)
        AhkTest.AssertEqual("12345678-1234-5678-1234-567812345678", String(plain))
        AhkTest.AssertEqual("12345678-1234-5678-1234-567812345678", String(braces))
        AhkTest.AssertEqual("12345678-1234-5678-1234-567812345678", String(urnValue))
        AhkTest.AssertEqual("12345678-1234-5678-1234-567812345678", String(keyword))
        AhkTest.AssertEqual(4, generated.version)
        AhkTest.AssertEqual("specified in RFC 4122", generated.variant)
        AhkTest.AssertEqual(36, StrLen(String(generated)))
        AhkTest.AssertTrue(RegExMatch(String(generated), "^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$") > 0)
    }

    static TestObservedUuidErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^one of the hex, bytes, bytes_le, fields, or int arguments must be given$", (*) => stdlib.uuid.UUID())
        AhkTest.RaisesMatch(TypeError, "^UUID\.__init__\(\) got an unexpected keyword argument 'bad'$", (*) => stdlib.uuid.UUID({ bad: "12345678-1234-5678-1234-567812345678" }))
        AhkTest.RaisesMatch(TypeError, "^UUID\.__init__\(\) got multiple values for argument 'hex'$", (*) => stdlib.uuid.UUID("12345678-1234-5678-1234-567812345678", { hex: "12345678-1234-5678-1234-567812345678" }))
        AhkTest.RaisesMatch(ValueError, "^badly formed hexadecimal UUID string$", (*) => stdlib.uuid.UUID("1234"))
        AhkTest.RaisesMatch(ValueError, "^invalid literal for int\(\) with base 16: 'zzzzzzzz123456781234567812345678'$", (*) => stdlib.uuid.UUID("zzzzzzzz-1234-5678-1234-567812345678"))
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'replace'$", (*) => stdlib.uuid.UUID(1))
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'replace'$", (*) => stdlib.uuid.UUID({ hex: 1 }))
        AhkTest.RaisesMatch(TypeError, "^uuid4\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.uuid.uuid4(1))
    }

    static TestUuidIntegerInteropAttributesMatchLocal310()
    {
        fixed := stdlib.uuid.UUID("12345678-1234-5678-1234-567812345678")

        AhkTest.AssertEqual("24197857161011715162171839636988778104", String(fixed.int))
        AhkTest.AssertEqual("12345678123456781234567812345678", AhkStdlibUuidBufferToHexForTest(fixed.bytes))
        AhkTest.AssertEqual("78563412341278561234567812345678", AhkStdlibUuidBufferToHexForTest(fixed.bytes_le))
        AhkTest.AssertEqual(16, fixed.bytes.Size)

        fields := fixed.fields
        AhkTest.AssertEqual(6, fields.Length)
        AhkTest.AssertEqual(305419896, fields[1])
        AhkTest.AssertEqual(4660, fields[2])
        AhkTest.AssertEqual(22136, fields[3])
        AhkTest.AssertEqual(18, fields[4])
        AhkTest.AssertEqual(52, fields[5])
        AhkTest.AssertEqual(95073701484152, fields[6])

        AhkTest.AssertEqual(305419896, fixed.time_low)
        AhkTest.AssertEqual(4660, fixed.time_mid)
        AhkTest.AssertEqual(22136, fixed.time_hi_version)
        AhkTest.AssertEqual(18, fixed.clock_seq_hi_variant)
        AhkTest.AssertEqual(52, fixed.clock_seq_low)
        AhkTest.AssertEqual(95073701484152, fixed.node)
    }

    static TestUuidNamespaceConstantsMatchLocal310()
    {
        AhkTest.AssertEqual("6ba7b810-9dad-11d1-80b4-00c04fd430c8", String(stdlib.uuid.NAMESPACE_DNS))
        AhkTest.AssertEqual("6ba7b811-9dad-11d1-80b4-00c04fd430c8", String(stdlib.uuid.NAMESPACE_URL))
        AhkTest.AssertEqual("6ba7b812-9dad-11d1-80b4-00c04fd430c8", String(stdlib.uuid.NAMESPACE_OID))
        AhkTest.AssertEqual("6ba7b814-9dad-11d1-80b4-00c04fd430c8", String(stdlib.uuid.NAMESPACE_X500))
    }

    static TestUuid3AndUuid5MatchLocal310()
    {
        three := stdlib.uuid.uuid3(stdlib.uuid.NAMESPACE_DNS, "python.org")
        five := stdlib.uuid.uuid5(stdlib.uuid.NAMESPACE_DNS, "python.org")

        AhkTest.AssertEqual("6fa459ea-ee8a-3ca4-894e-db77e160355e", String(three))
        AhkTest.AssertEqual(3, three.version)
        AhkTest.AssertEqual("886313e1-3b8a-5372-9b90-0c9aee199e5d", String(five))
        AhkTest.AssertEqual(5, five.version)
    }

    static TestUuid3And5RejectBadArityLikeLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^uuid3\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.uuid.uuid3(stdlib.uuid.NAMESPACE_DNS, "a", "b"))
        AhkTest.RaisesMatch(TypeError, "^uuid5\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.uuid.uuid5(stdlib.uuid.NAMESPACE_DNS, "a", "b"))
    }

    static TestGetNodeReturns48BitIntegerLikeLocal310()
    {
        node := stdlib.uuid.getnode()
        AhkTest.AssertTrue(node is Integer)
        AhkTest.AssertTrue(node >= 0)
        AhkTest.AssertTrue(node < 0x1000000000000)
    }

    static TestGetNodeRejectsArgsLikeLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^getnode\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.uuid.getnode(1))
    }

    static TestUuid1VersionAndVariantBitsMatchLocal310()
    {
        value := stdlib.uuid.uuid1()
        AhkTest.AssertEqual(1, value.version)
        AhkTest.AssertEqual("specified in RFC 4122", value.variant)
        AhkTest.AssertEqual(32, StrLen(value.hex))
        AhkTest.AssertTrue(RegExMatch(value.hex, "^[0-9a-f]{32}$") > 0)
        AhkTest.AssertTrue(RegExMatch(String(value), "^[0-9a-f]{8}-[0-9a-f]{4}-1[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$") > 0)
    }

    static TestUuid1HonorsExplicitNodeAndClockSeqLikeLocal310()
    {
        value := stdlib.uuid.uuid1(0x123456789abc, 0x1234)
        AhkTest.AssertEqual(0x123456789abc, value.node)
        AhkTest.AssertEqual(1, value.version)
        ; clock_seq_hi_variant = ((0x1234 >> 8) & 0x3f) | 0x80 = 0x92, clock_seq_low = 0x34
        AhkTest.AssertEqual(0x92, value.clock_seq_hi_variant)
        AhkTest.AssertEqual(0x34, value.clock_seq_low)
    }

    static TestUuid1TwoCallsDifferLikeLocal310()
    {
        first := stdlib.uuid.uuid1(0x123456789abc, 0x1234)
        second := stdlib.uuid.uuid1(0x123456789abc, 0x1234)
        AhkTest.AssertTrue(String(first) != String(second))
    }

    static TestUuid1RejectsOutOfRangeNodeAndArityLikeLocal310()
    {
        AhkTest.RaisesMatch(ValueError, "^field 6 out of range \(need a 48-bit value\)$", (*) => stdlib.uuid.uuid1(0x1000000000000))
        AhkTest.RaisesMatch(ValueError, "^field 6 out of range \(need a 48-bit value\)$", (*) => stdlib.uuid.uuid1(-1))
        AhkTest.RaisesMatch(TypeError, "^uuid1\(\) takes from 0 to 2 positional arguments but 3 were given$", (*) => stdlib.uuid.uuid1(1, 2, 3))
    }
}

AhkStdlibUuidBufferToHexForTest(buffer)
{
    text := ""
    loop buffer.Size
        text .= Format("{:02x}", NumGet(buffer, A_Index - 1, "UChar"))
    return text
}

AhkTest.Collect(StdlibUuidTest)
