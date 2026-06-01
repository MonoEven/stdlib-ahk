#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\os>

class StdlibOsTest
{
    static TestSystemReturnsShellExitCode()
    {
        AhkTest.AssertEqual(0, stdlib.os.system("exit /b 0"))
        AhkTest.AssertEqual(7, stdlib.os.system("exit /b 7"))
    }

    static TestSystemRunsThroughShellRedirection()
    {
        root := A_Temp "\stdlib-os-system-" A_TickCount "-" Random(100000, 999999)
        DirCreate root
        outputPath := root "\result.txt"

        try {
            exitCode := stdlib.os.system("echo stdlib-ok > " stdlib_os_test_quote_cmd_arg(outputPath))

            AhkTest.AssertEqual(0, exitCode)
            AhkTest.AssertTrue(FileExist(outputPath) != "")
            AhkTest.AssertContains("stdlib-ok", FileRead(outputPath, "UTF-8"))
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestSystemRejectsNonStringAndEmbeddedNull()
    {
        AhkTest.RaisesMatch(TypeError, "system\(\) argument 'command' must be str", (*) => stdlib.os.system(123))
        AhkTest.RaisesMatch(TypeError, "system\(\) argument 'command' must be str", (*) => stdlib.os.system(Buffer(1, 0)))
        AhkTest.RaisesMatch(ValueError, "embedded null character", (*) => stdlib.os.system("echo a" Chr(0) "b"))
    }
}

stdlib_os_test_quote_cmd_arg(value)
{
    return "`"" StrReplace(value, "`"", "`"`"") "`""
}

AhkTest.Collect(StdlibOsTest)
