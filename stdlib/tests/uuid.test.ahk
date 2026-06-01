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
}

AhkTest.Collect(StdlibUuidTest)
