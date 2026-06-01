#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibKeyword
{
    static kwlist := [
        "False", "None", "True", "and", "as", "assert", "async", "await", "break", "class",
        "continue", "def", "del", "elif", "else", "except", "finally", "for", "from", "global",
        "if", "import", "in", "is", "lambda", "nonlocal", "not", "or", "pass", "raise",
        "return", "try", "while", "with", "yield"
    ]
    static softkwlist := ["_", "case", "match"]

    static iskeyword(args*)
    {
        return AhkStdlibKeywordContains("kwlist", args*)
    }

    static issoftkeyword(args*)
    {
        return AhkStdlibKeywordContains("softkwlist", args*)
    }
}

stdlib.keyword := AhkStdlibKeyword

AhkStdlibKeywordContains(listName, args*)
{
    if args.Length = 0
        throw TypeError("frozenset.__contains__() takes exactly one argument (0 given)", -1)
    if args.Length != 1
        throw TypeError("frozenset.__contains__() takes exactly one argument (" args.Length " given)", -1)

    target := args[1]
    if !(target is String)
        return false

    haystack := AhkStdlibKeyword.%listName%
    for keywordValue in haystack {
        if keywordValue = target
            return true
    }
    return false
}
