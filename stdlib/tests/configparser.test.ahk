#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\configparser>

class StdlibConfigParserTest
{
    static TestConfigParserReadsSectionsAndTypedValuesLikePython310()
    {
        parser := stdlib.configparser.ConfigParser()

        result := parser.read_string("[Server]`nHost = localhost`nPORT = 8080`nflag = yes`n`n[empty]`n")

        AhkTest.AssertEqual("", result)
        AhkTest.AssertEqual(["Server", "empty"], parser.sections())
        AhkTest.AssertTrue(parser.has_section("Server"))
        AhkTest.AssertFalse(parser.has_section("missing"))
        AhkTest.AssertEqual("localhost", parser.get("Server", "host"))
        AhkTest.AssertEqual("localhost", parser.get("Server", "HOST"))
        AhkTest.AssertEqual("8080", parser["Server"]["port"])
        AhkTest.AssertEqual("8080", parser["Server"]["PORT"])
        AhkTest.AssertEqual(8080, parser.getint("Server", "port"))
        AhkTest.AssertTrue(parser.getboolean("Server", "flag"))
        AhkTest.AssertEqual([["host", "localhost"], ["port", "8080"], ["flag", "yes"]], parser.items("Server"))
        AhkTest.AssertTrue(parser["Server"].Has("host"))
        AhkTest.AssertTrue(parser["Server"].Has("HOST"))
    }

    static TestConfigParserRaisesPythonStyleErrors()
    {
        parser := stdlib.configparser.ConfigParser()
        parser.read_string("[server]`nhost = localhost`n")

        AhkTest.RaisesMatch(stdlib.configparser.NoSectionError, "No section: 'missing'", (*) => parser.get("missing", "host"))
        AhkTest.RaisesMatch(stdlib.configparser.NoOptionError, "No option 'missing' in section: 'server'", (*) => parser.get("server", "missing"))
        AhkTest.RaisesMatch(stdlib.configparser.DuplicateSectionError, "Section 'server' already exists", (*) => parser.add_section("server"))
        AhkTest.RaisesMatch(stdlib.configparser.MissingSectionHeaderError, "File contains no section headers", (*) => stdlib.configparser.ConfigParser().read_string("host = localhost"))
        AhkTest.RaisesMatch(stdlib.configparser.MissingSectionHeaderError, "File contains no section headers", (*) => stdlib.configparser.ConfigParser().read_string("[server"))
    }

    static TestConfigParserSupportsOptionMutationLikePython310()
    {
        parser := stdlib.configparser.ConfigParser()
        parser.read_string("[Server]`nHost = localhost`nPORT = 8080`n")

        AhkTest.AssertEqual("", parser.set("Server", "User", "Ada"))
        AhkTest.AssertEqual("Ada", parser.get("Server", "user"))
        AhkTest.AssertEqual("Ada", parser["Server"]["USER"])
        AhkTest.AssertEqual([["host", "localhost"], ["port", "8080"], ["user", "Ada"]], parser.items("Server"))
        AhkTest.AssertTrue(parser.remove_option("Server", "USER"))
        AhkTest.AssertEqual([["host", "localhost"], ["port", "8080"]], parser.items("Server"))
        AhkTest.AssertFalse(parser.remove_option("Server", "USER"))
        AhkTest.AssertTrue(parser.remove_section("Server"))
        AhkTest.AssertEqual([], parser.sections())
        AhkTest.AssertFalse(parser.remove_section("Server"))
        AhkTest.RaisesMatch(stdlib.configparser.NoSectionError, "No section: 'Missing'", (*) => parser.set("Missing", "x", "1"))
    }

    static TestConfigParserOptionsAndHasOptionLikePython310()
    {
        parser := stdlib.configparser.ConfigParser()
        parser.read_string("[Server]`nHost = localhost`nPORT = 8080`n")

        AhkTest.AssertEqual(["host", "port"], parser.options("Server"))
        AhkTest.AssertTrue(parser.has_option("Server", "HOST"))
        AhkTest.AssertFalse(parser.has_option("Server", "missing"))
        AhkTest.RaisesMatch(stdlib.configparser.NoSectionError, "No section: 'missing'", (*) => parser.options("missing"))
    }

    static TestConfigParserGetfloatLikePython310()
    {
        parser := stdlib.configparser.ConfigParser()
        parser.read_string("[Server]`nratio = 0.5`ninvalid = nope`n")

        AhkTest.AssertEqual(0.5, parser.getfloat("Server", "ratio"))
        AhkTest.RaisesMatch(stdlib.configparser.NoOptionError, "No option 'missing' in section: 'Server'", (*) => parser.getfloat("Server", "missing"))
        AhkTest.RaisesMatch(stdlib.configparser.NoSectionError, "No section: 'missing'", (*) => parser.getfloat("missing", "ratio"))
        AhkTest.RaisesMatch(ValueError, "could not convert string to float: 'nope'", (*) => parser.getfloat("Server", "invalid"))
    }

    static TestConfigParserGetintUsesPythonValueErrorLikePython310()
    {
        parser := stdlib.configparser.ConfigParser()
        parser.read_string("[Server]`nport = 8080`ninvalid = nope`n")

        AhkTest.AssertEqual(8080, parser.getint("Server", "port"))
        AhkTest.RaisesMatch(stdlib.configparser.NoOptionError, "No option 'missing' in section: 'Server'", (*) => parser.getint("Server", "missing"))
        AhkTest.RaisesMatch(stdlib.configparser.NoSectionError, "No section: 'missing'", (*) => parser.getint("missing", "port"))
        AhkTest.RaisesMatch(ValueError, "invalid literal for int\(\) with base 10: 'nope'", (*) => parser.getint("Server", "invalid"))
    }

    static TestConfigParserSetRejectsNonStringValuesLikePython310()
    {
        parser := stdlib.configparser.ConfigParser()
        parser.read_string("[Server]`nhost = localhost`n")

        AhkTest.AssertEqual("", parser.set("Server", "port", "8080"))
        AhkTest.AssertEqual("8080", parser.get("Server", "port"))
        AhkTest.RaisesMatch(TypeError, "option values must be strings", (*) => parser.set("Server", "port", 8080))
        AhkTest.RaisesMatch(TypeError, "option values must be strings", (*) => parser.set("Missing", "port", 8080))
        AhkTest.RaisesMatch(stdlib.configparser.NoSectionError, "No section: 'missing'", (*) => parser.set("missing", "port", "8080"))
    }

    static TestConfigParserHasOptionMissingSectionReturnsFalseLikePython310()
    {
        parser := stdlib.configparser.ConfigParser()
        parser.read_string("[Server]`nhost = localhost`n")

        AhkTest.AssertFalse(parser.has_option("missing", "host"))
    }

    static TestConfigParserSupportsBasicDefaultSectionLookupLikePython310()
    {
        parser := stdlib.configparser.ConfigParser()
        parser.read_string("[DEFAULT]`nhost = localhost`nport = 80`n[Server]`nport = 8080`nuser = Ada`n")

        AhkTest.AssertEqual(["Server"], parser.sections())
        AhkTest.AssertFalse(parser.has_section("DEFAULT"))
        AhkTest.AssertEqual("localhost", parser.get("Server", "host"))
        AhkTest.AssertEqual("localhost", parser.get("DEFAULT", "host"))
        AhkTest.AssertTrue(parser.has_option("Server", "host"))
        AhkTest.RaisesMatch(ValueError, "Invalid section name: 'DEFAULT'", (*) => parser.add_section("DEFAULT"))
    }

    static TestConfigParserItemsAndOptionsMergeDefaultsLikePython310()
    {
        parser := stdlib.configparser.ConfigParser()
        parser.read_string("[DEFAULT]`nhost = localhost`nport = 80`n[Server]`nport = 8080`nuser = Ada`n")

        AhkTest.AssertEqual([["host", "localhost"], ["port", "8080"], ["user", "Ada"]], parser.items("Server"))
        AhkTest.AssertEqual(["port", "user", "host"], parser.options("Server"))
        AhkTest.AssertEqual([["host", "localhost"], ["port", "80"]], parser.items("DEFAULT"))
        AhkTest.RaisesMatch(stdlib.configparser.NoSectionError, "No section: 'DEFAULT'", (*) => parser.options("DEFAULT"))
    }

    static TestConfigParserSectionProxyReadsDefaultsLikePython310()
    {
        parser := stdlib.configparser.ConfigParser()
        parser.read_string("[DEFAULT]`nhost = localhost`nport = 80`n[Server]`nport = 8080`nuser = Ada`n")
        section := parser["Server"]

        AhkTest.AssertEqual("localhost", section["host"])
        AhkTest.AssertEqual("8080", section["port"])
        AhkTest.AssertTrue(section.Has("host"))
        AhkTest.AssertFalse(section.Has("missing"))
        AhkTest.AssertEqual([["port", "8080"], ["user", "Ada"], ["host", "localhost"]], section.items())
        AhkTest.AssertEqual(["port", "user", "host"], section.keys())
        AhkTest.AssertEqual(["8080", "Ada", "localhost"], section.values())
    }

    static TestConfigParserRemoveOptionDefaultSectionLikePython310()
    {
        parser := stdlib.configparser.ConfigParser()
        parser.read_string("[DEFAULT]`nhost = localhost`nport = 80`n[Server]`nport = 8080`nuser = Ada`n")

        AhkTest.AssertFalse(parser.remove_option("Server", "host"))
        AhkTest.AssertTrue(parser.has_option("Server", "host"))
        AhkTest.AssertTrue(parser.remove_option("DEFAULT", "host"))
        AhkTest.AssertFalse(parser.has_option("Server", "host"))
        AhkTest.RaisesMatch(stdlib.configparser.NoOptionError, "No option 'host' in section: 'Server'", (*) => parser.get("Server", "host"))
        AhkTest.AssertFalse(parser.remove_option("DEFAULT", "host"))
        AhkTest.AssertEqual([["port", "8080"], ["user", "Ada"]], parser["Server"].items())
    }

    static TestConfigParserReadAndWriteRoundTripThroughFile()
    {
        root := A_Temp "\stdlib-configparser-" A_TickCount "-" Random(100000, 999999)
        DirCreate root
        path := root "\config.ini"
        try {
            parser := stdlib.configparser.ConfigParser()
            parser.read_string("[Server]`nhost = localhost`nport = 8080`n")

            sink := FileOpen(path, "w", "UTF-8")
            parser.write(sink)
            sink.Close()

            roundtrip := stdlib.configparser.ConfigParser()
            roundtrip.read(path)
            AhkTest.AssertEqual("localhost", roundtrip.get("Server", "host"))
            AhkTest.AssertEqual(8080, roundtrip.getint("Server", "port"))
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestConfigParserReadMissingFileIsSkipped()
    {
        parser := stdlib.configparser.ConfigParser()
        result := parser.read("Z:\definitely\missing\file.ini")
        AhkTest.AssertEqual([], result)
    }

    static TestConfigParserReadDictPopulatesSections()
    {
        parser := stdlib.configparser.ConfigParser()
        data := Map("Server", Map("host", "localhost", "port", "9000"))
        parser.read_dict(data)
        AhkTest.AssertEqual("localhost", parser.get("Server", "host"))
        AhkTest.AssertEqual("9000", parser.get("Server", "port"))
    }

    static TestConfigParserGetFallbackReturnsDefault()
    {
        parser := stdlib.configparser.ConfigParser()
        parser.read_string("[Server]`nhost = localhost`n")
        AhkTest.AssertEqual("none", parser.get("Server", "missing", { fallback: "none" }))
        AhkTest.AssertEqual(42, parser.getint("Server", "missing", { fallback: 42 }))
        AhkTest.AssertEqual("fb", parser.get("Nope", "x", { fallback: "fb" }))
    }

    static TestConfigParserWriteStringRendersSections()
    {
        parser := stdlib.configparser.ConfigParser()
        parser.read_string("[DEFAULT]`nbase = 1`n[A]`nx = 2`n")
        text := parser.write_string()
        AhkTest.AssertContains("[DEFAULT]", text)
        AhkTest.AssertContains("base = 1", text)
        AhkTest.AssertContains("[A]", text)
        AhkTest.AssertContains("x = 2", text)
    }
}

AhkTest.Collect(StdlibConfigParserTest)
