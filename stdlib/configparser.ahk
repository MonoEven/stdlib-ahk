#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibConfigParserModule
{
    static Error := AhkStdlibConfigParserError
    static NoSectionError := AhkStdlibConfigParserNoSectionError
    static DuplicateSectionError := AhkStdlibConfigParserDuplicateSectionError
    static NoOptionError := AhkStdlibConfigParserNoOptionError
    static MissingSectionHeaderError := AhkStdlibConfigParserMissingSectionHeaderError

    static ConfigParser()
    {
        return AhkStdlibConfigParser()
    }
}

class AhkStdlibConfigParserError extends Error
{
}

class AhkStdlibConfigParserNoSectionError extends AhkStdlibConfigParserError
{
}

class AhkStdlibConfigParserDuplicateSectionError extends AhkStdlibConfigParserError
{
}

class AhkStdlibConfigParserNoOptionError extends AhkStdlibConfigParserError
{
}

class AhkStdlibConfigParserMissingSectionHeaderError extends AhkStdlibConfigParserError
{
}

class AhkStdlibConfigParser
{
    __New()
    {
        this.AhkStdlibSections := Map()
        this.AhkStdlibSectionOrder := []
        this.AhkStdlibDefaults := AhkStdlibConfigParserSection()
    }

    __Item[section]
    {
        get {
            return AhkStdlibConfigParserSectionProxy(this, section)
        }
    }

    read_string(text)
    {
        currentSection := ""
        lineNumber := 0

        for rawLine in AhkStdlibConfigParserLines(text) {
            lineNumber += 1
            line := Trim(rawLine)
            if line = "" || SubStr(line, 1, 1) = "#" || SubStr(line, 1, 1) = ";"
                continue

            if SubStr(line, 1, 1) = "[" && SubStr(line, -1) = "]" {
                section := Trim(SubStr(line, 2, StrLen(line) - 2))
                if AhkStdlibConfigParserIsDefaultSectionName(section) {
                    currentSection := section
                    continue
                }
                this.add_section(section)
                currentSection := section
                continue
            }

            if currentSection = ""
                throw AhkStdlibConfigParserMissingSectionHeaderError("File contains no section headers.`nfile: '<string>', line: " lineNumber, -1, rawLine)

            delimiterPos := AhkStdlibConfigParserDelimiterPosition(line)
            if !delimiterPos
                throw AhkStdlibConfigParserMissingSectionHeaderError("File contains no section headers.`nfile: '<string>', line: " lineNumber, -1, rawLine)

            option := Trim(SubStr(line, 1, delimiterPos - 1))
            value := Trim(SubStr(line, delimiterPos + 1))
            this.AhkStdlibSetOption(currentSection, option, value)
        }
    }

    sections()
    {
        result := []
        for section in this.AhkStdlibSectionOrder
            result.Push(section)
        return result
    }

    has_section(section)
    {
        if AhkStdlibConfigParserIsDefaultSectionName(section)
            return false
        return this.AhkStdlibSections.Has(section)
    }

    add_section(section)
    {
        if AhkStdlibConfigParserIsDefaultSectionName(section)
            throw ValueError("Invalid section name: '" section "'", -1)
        if this.AhkStdlibSections.Has(section)
            throw AhkStdlibConfigParserDuplicateSectionError("Section '" section "' already exists", -1)

        this.AhkStdlibSections[section] := AhkStdlibConfigParserSection()
        this.AhkStdlibSectionOrder.Push(section)
    }

    get(section, option, options := unset)
    {
        hasFallback := IsSet(options) && IsObject(options) && HasProp(options, "fallback")
        option := AhkStdlibConfigParserNormalizeOption(option)
        if AhkStdlibConfigParserIsDefaultSectionName(section) {
            if !this.AhkStdlibDefaults.Has(option) {
                if hasFallback
                    return options.fallback
                throw AhkStdlibConfigParserNoOptionError("No option '" option "' in section: '" section "'", -1)
            }
            return this.AhkStdlibDefaults[option]
        }

        if !this.AhkStdlibSections.Has(section) {
            if hasFallback
                return options.fallback
            throw AhkStdlibConfigParserNoSectionError("No section: '" section "'", -1)
        }
        values := this.AhkStdlibSections[section]
        if values.Has(option)
            return values[option]
        if this.AhkStdlibDefaults.Has(option)
            return this.AhkStdlibDefaults[option]
        if hasFallback
            return options.fallback
        throw AhkStdlibConfigParserNoOptionError("No option '" option "' in section: '" section "'", -1)
    }

    getint(section, option, options := unset)
    {
        if IsSet(options) && IsObject(options) && HasProp(options, "fallback") && !this.has_option(section, option)
            return options.fallback
        value := this.get(section, option)
        try {
            return Integer(value)
        } catch {
            throw ValueError("invalid literal for int() with base 10: '" value "'", -1)
        }
    }

    getfloat(section, option, options := unset)
    {
        if IsSet(options) && IsObject(options) && HasProp(options, "fallback") && !this.has_option(section, option)
            return options.fallback
        value := this.get(section, option)
        try {
            return Float(value)
        } catch {
            throw ValueError("could not convert string to float: '" value "'", -1)
        }
    }

    getboolean(section, option, options := unset)
    {
        if IsSet(options) && IsObject(options) && HasProp(options, "fallback") && !this.has_option(section, option)
            return options.fallback
        value := StrLower(this.get(section, option))
        switch value {
            case "1", "yes", "true", "on":
                return true
            case "0", "no", "false", "off":
                return false
        }
        throw ValueError("Not a boolean: " this.get(section, option), -1)
    }

    items(section)
    {
        if AhkStdlibConfigParserIsDefaultSectionName(section)
            values := this.AhkStdlibDefaults
        else
            values := this.AhkStdlibRequireSection(section)
        result := []
        if !AhkStdlibConfigParserIsDefaultSectionName(section) {
            for option in this.AhkStdlibDefaults.Order {
                if values.Values.Has(option)
                    result.Push([option, values.Values[option]])
                else
                    result.Push([option, this.AhkStdlibDefaults.Values[option]])
            }
        }
        for option in values.Order
            if AhkStdlibConfigParserIsDefaultSectionName(section) || !this.AhkStdlibDefaults.Values.Has(option)
                result.Push([option, values.Values[option]])
        return result
    }

    options(section)
    {
        values := this.AhkStdlibRequireSection(section)
        result := []
        for option in values.Order
            result.Push(option)
        for option in this.AhkStdlibDefaults.Order
            if !values.Values.Has(option)
                result.Push(option)
        return result
    }

    has_option(section, option)
    {
        if AhkStdlibConfigParserIsDefaultSectionName(section) {
            option := AhkStdlibConfigParserNormalizeOption(option)
            return this.AhkStdlibDefaults.Has(option)
        }
        if !this.AhkStdlibSections.Has(section)
            return false
        option := AhkStdlibConfigParserNormalizeOption(option)
        values := this.AhkStdlibSections[section]
        return values.Values.Has(option) || this.AhkStdlibDefaults.Has(option)
    }

    set(section, option, value)
    {
        this.AhkStdlibSetOption(section, option, value)
    }

    remove_option(section, option)
    {
        if AhkStdlibConfigParserIsDefaultSectionName(section)
            values := this.AhkStdlibDefaults
        else
            values := this.AhkStdlibRequireSection(section)
        option := AhkStdlibConfigParserNormalizeOption(option)
        if !values.Values.Has(option)
            return false

        values.Values.Delete(option)
        AhkStdlibConfigParserDeleteFromArray(values.Order, option)
        return true
    }

    remove_section(section)
    {
        if !this.AhkStdlibSections.Has(section)
            return false

        this.AhkStdlibSections.Delete(section)
        AhkStdlibConfigParserDeleteFromArray(this.AhkStdlibSectionOrder, section)
        return true
    }

    read(filenames, encoding := "UTF-8")
    {
        ; Accept a single path or a list; silently skip files that don't exist
        ; (Python returns the list of successfully-read filenames).
        paths := filenames is Array ? filenames : [filenames]
        readOk := []
        for path in paths {
            pathStr := AhkStdlibConfigParserPathString(path)
            if !FileExist(pathStr) || DirExist(pathStr)
                continue
            this.read_string(FileRead(pathStr, encoding))
            readOk.Push(pathStr)
        }
        return readOk
    }

    read_file(fileObject, source := unset)
    {
        ; Accept an AHK FileObject, a StringIO-like object, or raw text.
        text := AhkStdlibConfigParserReadAll(fileObject)
        this.read_string(text)
        return stdlib.None
    }

    read_dict(dictionary, source := "<dict>")
    {
        ; dictionary: Map of section -> (Map|Object) of option -> value.
        ; DictPairs returns an Array of [key, value] pairs; iterate single-var.
        for sectionPair in AhkStdlibConfigParserDictPairs(dictionary) {
            section := sectionPair[1]
            options := sectionPair[2]
            if !AhkStdlibConfigParserIsDefaultSectionName(section) && !this.has_section(section)
                this.add_section(section)
            for optionPair in AhkStdlibConfigParserDictPairs(options)
                this.AhkStdlibSetOption(section, optionPair[1], AhkStdlibConfigParserDictValueToString(optionPair[2]))
        }
        return stdlib.None
    }

    write(fileObject, space_around_delimiters := true)
    {
        delimiter := space_around_delimiters ? " = " : "="
        text := this.AhkStdlibRender(delimiter)
        if IsObject(fileObject) && HasMethod(fileObject, "Write")
            fileObject.Write(text)
        else if IsObject(fileObject) && HasMethod(fileObject, "write")
            fileObject.write(text)
        else
            throw TypeError("write() requires a writable file object", -1)
        return stdlib.None
    }

    write_string(space_around_delimiters := true)
    {
        delimiter := space_around_delimiters ? " = " : "="
        return this.AhkStdlibRender(delimiter)
    }

    defaults()
    {
        result := Map()
        for option in this.AhkStdlibDefaults.Order
            result[option] := this.AhkStdlibDefaults.Values[option]
        return result
    }

    AhkStdlibRender(delimiter)
    {
        out := ""
        if this.AhkStdlibDefaults.Order.Length > 0 {
            out .= "[DEFAULT]`n"
            for option in this.AhkStdlibDefaults.Order
                out .= option delimiter this.AhkStdlibDefaults.Values[option] "`n"
            out .= "`n"
        }
        for section in this.AhkStdlibSectionOrder {
            out .= "[" section "]`n"
            values := this.AhkStdlibSections[section]
            for option in values.Order
                out .= option delimiter values.Values[option] "`n"
            out .= "`n"
        }
        return out
    }

    AhkStdlibSetOption(section, option, value)
    {
        AhkStdlibConfigParserValidateOptionValue(value)
        if AhkStdlibConfigParserIsDefaultSectionName(section)
            values := this.AhkStdlibDefaults
        else
            values := this.AhkStdlibRequireSection(section)
        option := AhkStdlibConfigParserNormalizeOption(option)
        if !values.Values.Has(option)
            values.Order.Push(option)
        values.Values[option] := value
    }

    AhkStdlibRequireSection(section)
    {
        if !this.AhkStdlibSections.Has(section)
            throw AhkStdlibConfigParserNoSectionError("No section: '" section "'", -1)
        return this.AhkStdlibSections[section]
    }
}

class AhkStdlibConfigParserSectionProxy
{
    __New(parser, section)
    {
        this.AhkStdlibParser := parser
        this.AhkStdlibSection := section
    }

    __Item[option]
    {
        get {
            return this.AhkStdlibParser.get(this.AhkStdlibSection, option)
        }
        set {
            this.AhkStdlibParser.set(this.AhkStdlibSection, option, value)
        }
    }

    Has(option)
    {
        return this.AhkStdlibParser.has_option(this.AhkStdlibSection, option)
    }

    items()
    {
        values := this.AhkStdlibParser.AhkStdlibRequireSection(this.AhkStdlibSection)
        result := []
        for option in values.Order
            result.Push([option, values.Values[option]])
        for option in this.AhkStdlibParser.AhkStdlibDefaults.Order {
            if values.Values.Has(option)
                continue
            result.Push([option, this.AhkStdlibParser.AhkStdlibDefaults.Values[option]])
        }
        return result
    }

    keys()
    {
        result := []
        for item in this.items()
            result.Push(item[1])
        return result
    }

    values()
    {
        result := []
        for item in this.items()
            result.Push(item[2])
        return result
    }
}

class AhkStdlibConfigParserSection
{
    __New()
    {
        this.Values := Map()
        this.Order := []
    }

    __Item[option]
    {
        get {
            option := AhkStdlibConfigParserNormalizeOption(option)
            return this.Values[option]
        }
        set {
            AhkStdlibConfigParserValidateOptionValue(value)
            option := AhkStdlibConfigParserNormalizeOption(option)
            if !this.Values.Has(option)
                this.Order.Push(option)
            this.Values[option] := value
        }
    }

    Has(option)
    {
        option := AhkStdlibConfigParserNormalizeOption(option)
        return this.Values.Has(option)
    }
}

stdlib.configparser := AhkStdlibConfigParserModule

AhkStdlibConfigParserLines(text)
{
    return StrSplit(StrReplace(StrReplace(text, "`r`n", "`n"), "`r", "`n"), "`n")
}

AhkStdlibConfigParserDelimiterPosition(line)
{
    equalsPos := InStr(line, "=")
    colonPos := InStr(line, ":")
    if equalsPos && colonPos
        return Min(equalsPos, colonPos)
    if equalsPos
        return equalsPos
    return colonPos
}

AhkStdlibConfigParserNormalizeOption(option)
{
    return StrLower(option)
}

AhkStdlibConfigParserIsDefaultSectionName(section)
{
    return section = "DEFAULT"
}

AhkStdlibConfigParserValidateOptionValue(value)
{
    if Type(value) != "String"
        throw TypeError("option values must be strings", -1)
}

AhkStdlibConfigParserDeleteFromArray(items, value)
{
    index := 1
    while index <= items.Length {
        if items[index] = value {
            items.RemoveAt(index)
            return
        }
        index += 1
    }
}

AhkStdlibConfigParserPathString(path)
{
    if IsObject(path) {
        if HasProp(path, "Path")
            return path.Path
        return String(path)
    }
    return path ""
}

AhkStdlibConfigParserReadAll(fileObject)
{
    if fileObject is String
        return fileObject
    if IsObject(fileObject) {
        ; StringIO-like (getvalue) or AHK FileObject (Read).
        if HasMethod(fileObject, "getvalue")
            return fileObject.getvalue()
        if HasMethod(fileObject, "Read")
            return fileObject.Read()
        if HasMethod(fileObject, "read")
            return fileObject.read()
    }
    throw TypeError("read_file() requires a readable file object or string", -1)
}

AhkStdlibConfigParserDictPairs(value)
{
    pairs := []
    if value is Map {
        for k, v in value
            pairs.Push([k, v])
        return pairs
    }
    if IsObject(value) {
        for k, v in value.OwnProps()
            pairs.Push([k, v])
        return pairs
    }
    throw TypeError("read_dict() expects a mapping of sections", -1)
}

AhkStdlibConfigParserDictValueToString(value)
{
    if value is String
        return value
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if AhkStdlibIsNone(value)
        return ""
    return String(value)
}
