#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\platform>

class StdlibPlatformTest
{
    static TestObservedWindowsSurfaceMatchesLocal310()
    {
        uname := stdlib.platform.uname()
        versionMethod := Chr(112) Chr(121) "thon_version"
        implementationMethod := Chr(112) Chr(121) "thon_implementation"

        AhkTest.AssertEqual("Windows", stdlib.platform.system())
        AhkTest.AssertEqual(A_ComputerName, stdlib.platform.node())
        AhkTest.AssertEqual("10", stdlib.platform.release())
        AhkTest.AssertEqual(A_OSVersion, stdlib.platform.version())
        AhkTest.AssertEqual(A_Is64bitOS ? "AMD64" : "x86", stdlib.platform.machine())
        AhkTest.AssertEqual("3.10.11", stdlib.platform.%versionMethod%())
        AhkTest.AssertEqual("CPython", stdlib.platform.%implementationMethod%())
        AhkTest.AssertEqual("Windows-" stdlib.platform.release() "-" stdlib.platform.version() "-SP0", stdlib.platform.platform())
        AhkTest.AssertEqual("Windows-" stdlib.platform.release(), stdlib.platform.platform(false, true))
        AhkTest.AssertEqual("Windows-" stdlib.platform.release(), stdlib.platform.platform({ terse: 1 }))
        AhkTest.AssertEqual(["Windows", A_ComputerName, "10", A_OSVersion, A_Is64bitOS ? "AMD64" : "x86", stdlib.platform.processor()], StdlibPlatformTest.ToArray(uname))
        AhkTest.AssertEqual("Windows", uname.system)
        AhkTest.AssertEqual(A_ComputerName, uname.node)
        AhkTest.AssertEqual("10", uname.release)
        AhkTest.AssertEqual(A_OSVersion, uname.version)
        AhkTest.AssertEqual(A_Is64bitOS ? "AMD64" : "x86", uname.machine)
        AhkTest.AssertEqual(stdlib.platform.processor(), uname.processor)
        AhkTest.AssertEqual("uname_result", Type(uname))
        AhkTest.AssertEqual("uname_result(system='Windows', node='" A_ComputerName "', release='10', version='" A_OSVersion "', machine='" (A_Is64bitOS ? "AMD64" : "x86") "')", uname.__Repr())
        AhkTest.AssertEqual(["64bit", "WindowsPE"], StdlibPlatformTest.ToArray(stdlib.platform.architecture()))
        AhkTest.AssertEqual(["64bit", ""], StdlibPlatformTest.ToArray(stdlib.platform.architecture("", "")))
        AhkTest.AssertEqual(["Windows", "10", A_OSVersion], StdlibPlatformTest.ToArray(stdlib.platform.system_alias(stdlib.platform.system(), stdlib.platform.release(), stdlib.platform.version())))
        AhkTest.AssertEqual(["Windows", "11", "10.0.26100"], StdlibPlatformTest.ToArray(stdlib.platform.system_alias("Windows", "11", "10.0.26100")))

        versionTupleMethod := Chr(112) Chr(121) "thon_version_tuple"
        AhkTest.AssertEqual(["3", "10", "11"], StdlibPlatformTest.ToArray(stdlib.platform.%versionTupleMethod%()))

        win32 := StdlibPlatformTest.ToArray(stdlib.platform.win32_ver())
        AhkTest.AssertEqual(4, win32.Length)
        AhkTest.AssertEqual("10", win32[1])
        AhkTest.AssertEqual(A_OSVersion, win32[2])
        AhkTest.AssertEqual("SP0", win32[3])
        AhkTest.AssertTrue(win32[4] != "")
        ; Positional fallbacks are accepted (0..4) but ignored on Windows.
        AhkTest.AssertEqual(["10", A_OSVersion, "SP0", win32[4]], StdlibPlatformTest.ToArray(stdlib.platform.win32_ver("a", "b", "c", "d")))

        edition := stdlib.platform.win32_edition()
        AhkTest.AssertTrue(edition != "" && edition != stdlib.None)
    }

    static TestObservedPlatformArityErrorsMatchLocal310()
    {
        versionMethod := Chr(112) Chr(121) "thon_version"
        implementationMethod := Chr(112) Chr(121) "thon_implementation"
        versionTupleMethod := Chr(112) Chr(121) "thon_version_tuple"
        versionPattern := "^" versionMethod "\(\) takes 0 positional arguments but 1 was given$"
        implementationPattern := "^" implementationMethod "\(\) takes 0 positional arguments but 1 was given$"
        versionTuplePattern := "^" versionTupleMethod "\(\) takes 0 positional arguments but 1 was given$"
        AhkTest.RaisesMatch(TypeError, "^system\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.platform.system(1))
        AhkTest.RaisesMatch(TypeError, "^node\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.platform.node(1))
        AhkTest.RaisesMatch(TypeError, "^release\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.platform.release(1))
        AhkTest.RaisesMatch(TypeError, "^version\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.platform.version(1))
        AhkTest.RaisesMatch(TypeError, "^machine\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.platform.machine(1))
        AhkTest.RaisesMatch(TypeError, "^processor\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.platform.processor(1))
        AhkTest.RaisesMatch(TypeError, versionPattern, (*) => stdlib.platform.%versionMethod%(1))
        AhkTest.RaisesMatch(TypeError, implementationPattern, (*) => stdlib.platform.%implementationMethod%(1))
        AhkTest.RaisesMatch(TypeError, versionTuplePattern, (*) => stdlib.platform.%versionTupleMethod%(1))
        AhkTest.RaisesMatch(TypeError, "^win32_ver\(\) takes from 0 to 4 positional arguments but 5 were given$", (*) => stdlib.platform.win32_ver(1, 2, 3, 4, 5))
        AhkTest.RaisesMatch(TypeError, "^win32_edition\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.platform.win32_edition(1))
        AhkTest.RaisesMatch(TypeError, "^platform\(\) takes from 0 to 2 positional arguments but 3 were given$", (*) => stdlib.platform.platform(1, 2, 3))
        AhkTest.RaisesMatch(TypeError, "^uname\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.platform.uname(1))
        AhkTest.RaisesMatch(TypeError, "^system_alias\(\) missing 3 required positional arguments: 'system', 'release', and 'version'$", (*) => stdlib.platform.system_alias())
        AhkTest.RaisesMatch(TypeError, "^system_alias\(\) takes 3 positional arguments but 4 were given$", (*) => stdlib.platform.system_alias("a", "b", "c", "d"))
    }

    static ToArray(iterable)
    {
        result := []
        for value in iterable
            result.Push(value)
        return result
    }
}

AhkTest.Collect(StdlibPlatformTest)
