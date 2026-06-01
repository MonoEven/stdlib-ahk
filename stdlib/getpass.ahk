#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibGetpass
{
    static getuser(args*)
    {
        if args.Length > 0
            throw TypeError("getuser() takes 0 positional arguments but " args.Length " was given", -1)

        for _, name in ["LOGNAME", "USER", "LNAME", "USERNAME"] {
            user := EnvGet(name)
            if user != ""
                return user
        }

        throw ModuleNotFoundError("No module named 'pwd'", -1)
    }
}

stdlib.getpass := AhkStdlibGetpass
