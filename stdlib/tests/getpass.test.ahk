#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\getpass>

class StdlibGetpassTest
{
    static TestGetuserMatchesObservedLocal310EnvironmentPriority()
    {
        StdlibGetpassTest.WithEnvCleared(["LOGNAME", "USER", "LNAME", "USERNAME"], (*) => (
            EnvSet("USERNAME", "u_username"),
            AhkTest.AssertEqual("u_username", stdlib.getpass.getuser()),
            EnvSet("LNAME", "u_lname"),
            AhkTest.AssertEqual("u_lname", stdlib.getpass.getuser()),
            EnvSet("USER", "u_user"),
            AhkTest.AssertEqual("u_user", stdlib.getpass.getuser()),
            EnvSet("LOGNAME", "u_logname"),
            AhkTest.AssertEqual("u_logname", stdlib.getpass.getuser()),
            EnvSet("LOGNAME", ""),
            AhkTest.AssertEqual("u_user", stdlib.getpass.getuser())
        ))
    }

    static TestGetuserMatchesObservedLocal310MissingAndArityErrors()
    {
        AhkTest.RaisesMatch(TypeError, "^getuser\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.getpass.getuser(1))
        AhkTest.AssertSame(stdlib.ModuleNotFoundError, stdlib.ModuleNotFoundError)
        StdlibGetpassTest.WithEnvCleared(["LOGNAME", "USER", "LNAME", "USERNAME"], (*) => (
            AhkTest.RaisesMatch(ModuleNotFoundError, "^No module named 'pwd'$", (*) => stdlib.getpass.getuser())
        ))
    }

    static WithEnvCleared(names, callback)
    {
        saved := Map()
        for _, name in names
            saved[name] := EnvGet(name)

        try {
            for _, name in names
                EnvSet(name, "")
            return callback()
        } finally {
            for _, name in names
                EnvSet(name, saved[name])
        }
    }
}

AhkTest.Collect(StdlibGetpassTest)
