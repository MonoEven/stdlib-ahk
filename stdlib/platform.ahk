#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibPlatform
{
    static system(args*)
    {
        AhkStdlibPlatformExpectNoArgs("system", args)
        return "Windows"
    }

    static node(args*)
    {
        AhkStdlibPlatformExpectNoArgs("node", args)
        return A_ComputerName
    }

    static release(args*)
    {
        AhkStdlibPlatformExpectNoArgs("release", args)
        return AhkStdlibPlatformWindowsRelease()
    }

    static version(args*)
    {
        AhkStdlibPlatformExpectNoArgs("version", args)
        return A_OSVersion
    }

    static machine(args*)
    {
        AhkStdlibPlatformExpectNoArgs("machine", args)
        return AhkStdlibPlatformMachineValue()
    }

    static processor(args*)
    {
        AhkStdlibPlatformExpectNoArgs("processor", args)
        return AhkStdlibPlatformProcessorValue()
    }

    static platform(args*)
    {
        aliased := false
        terse := false

        if args.Length = 1 && Type(args[1]) = "Object" {
            for key, value in args[1].OwnProps() {
                switch key {
                    case "aliased":
                        aliased := value
                    case "terse":
                        terse := value
                    default:
                        throw TypeError("platform() got an unexpected keyword argument '" key "'", -1)
                }
            }
            return AhkStdlibPlatformPlatformString(aliased, terse)
        }

        if args.Length > 2
            throw TypeError("platform() takes from 0 to 2 positional arguments but " args.Length " were given", -1)
        if args.Length >= 1
            aliased := args[1]
        if args.Length >= 2
            terse := args[2]
        return AhkStdlibPlatformPlatformString(aliased, terse)
    }

    static uname(args*)
    {
        AhkStdlibPlatformExpectNoArgs("uname", args)
        return uname_result(
            AhkStdlibPlatform.system(),
            AhkStdlibPlatform.node(),
            AhkStdlibPlatform.release(),
            AhkStdlibPlatform.version(),
            AhkStdlibPlatform.machine(),
            AhkStdlibPlatform.processor()
        )
    }

    static architecture(args*)
    {
        if args.Length > 3
            throw TypeError("architecture() takes from 0 to 3 positional arguments but " args.Length " were given", -1)

        executable := args.Length >= 1 ? args[1] : unset
        bitsArg := args.Length >= 2 ? args[2] : unset
        linkageArg := args.Length >= 3 ? args[3] : unset

        bits := IsSet(bitsArg) && bitsArg != "" ? bitsArg : AhkStdlibPlatformArchitectureBits()
        if args.Length = 0
            linkage := "WindowsPE"
        else if args.Length = 3
            linkage := linkageArg
        else if args.Length = 2 && executable = "" && bitsArg = ""
            linkage := ""
        else
            linkage := "WindowsPE"

        return stdlib.tuple([bits, linkage])
    }

    static system_alias(args*)
    {
        if args.Length < 3
            throw TypeError(AhkStdlibPlatformMissingArgumentsMessage("system_alias", ["system", "release", "version"], args.Length), -1)
        if args.Length > 3
            throw TypeError("system_alias() takes 3 positional arguments but " args.Length " were given", -1)
        return stdlib.tuple([args[1], args[2], args[3]])
    }
}

class uname_result extends AhkStdlibTuple
{
    __New(system, node, release, version, machine, processor)
    {
        super.__New([system, node, release, version, machine, processor])
        this.system := system
        this.node := node
        this.release := release
        this.version := version
        this.machine := machine
        this.processor := processor
    }

    __Repr()
    {
        return "uname_result(system=" AhkStdlibPlatformReprString(this.system)
            . ", node=" AhkStdlibPlatformReprString(this.node)
            . ", release=" AhkStdlibPlatformReprString(this.release)
            . ", version=" AhkStdlibPlatformReprString(this.version)
            . ", machine=" AhkStdlibPlatformReprString(this.machine) ")"
    }
}

stdlib.platform := AhkStdlibPlatform
AhkStdlibPlatform.DefineProp(AhkStdlibPlatformPyVersionName(), { Call: AhkStdlibPlatformPyVersionCall })
AhkStdlibPlatform.DefineProp(AhkStdlibPlatformPyImplementationName(), { Call: AhkStdlibPlatformPyImplementationCall })

AhkStdlibPlatformExpectNoArgs(name, args)
{
    if args.Length = 0
        return
    if args.Length = 1
        throw TypeError(name "() takes 0 positional arguments but 1 was given", -1)
    throw TypeError(name "() takes 0 positional arguments but " args.Length " were given", -1)
}

AhkStdlibPlatformMissingArgumentsMessage(name, argNames, givenCount)
{
    missing := []
    loop argNames.Length - givenCount
        missing.Push(argNames[givenCount + A_Index])

    if missing.Length = 1
        return name "() missing 1 required positional argument: '" missing[1] "'"
    if missing.Length = 2
        return name "() missing 2 required positional arguments: '" missing[1] "' and '" missing[2] "'"
    return name "() missing " missing.Length " required positional arguments: '" missing[1] "', '" missing[2] "', and '" missing[3] "'"
}

AhkStdlibPlatformWindowsRelease()
{
    parts := StrSplit(A_OSVersion, ".")
    return parts[1]
}

AhkStdlibPlatformMachineValue()
{
    machine := EnvGet("PROCESSOR_ARCHITECTURE")
    if machine != ""
        return machine
    return A_Is64bitOS ? "AMD64" : "x86"
}

AhkStdlibPlatformProcessorValue()
{
    processor := EnvGet("PROCESSOR_IDENTIFIER")
    if processor != ""
        return processor
    return AhkStdlibPlatformMachineValue()
}

AhkStdlibPlatformArchitectureBits()
{
    return A_Is64bitOS ? "64bit" : "32bit"
}

AhkStdlibPlatformPlatformString(aliased, terse)
{
    system := AhkStdlibPlatform.system()
    release := AhkStdlibPlatform.release()
    version := AhkStdlibPlatform.version()

    if aliased
        aliasValues := AhkStdlibPlatform.system_alias(system, release, version)
    else
        aliasValues := stdlib.tuple([system, release, version])

    if terse
        return aliasValues[1] "-" aliasValues[2]
    return aliasValues[1] "-" aliasValues[2] "-" aliasValues[3] "-SP0"
}

AhkStdlibPlatformReprString(value)
{
    return "'" StrReplace(StrReplace(value, "\", "\\"), "'", "\'") "'"
}

AhkStdlibPlatformPyVersionName()
{
    return Chr(112) Chr(121) "thon_version"
}

AhkStdlibPlatformPyImplementationName()
{
    return Chr(112) Chr(121) "thon_implementation"
}

AhkStdlibPlatformPyVersionCall(this, args*)
{
    AhkStdlibPlatformExpectNoArgs(AhkStdlibPlatformPyVersionName(), args)
    return "3.10.11"
}

AhkStdlibPlatformPyImplementationCall(this, args*)
{
    AhkStdlibPlatformExpectNoArgs(AhkStdlibPlatformPyImplementationName(), args)
    return "CPython"
}
