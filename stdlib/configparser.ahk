#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibConfigParserModule
{
    static Error := AhkStdlibConfigParserError
    static NoSectionError := AhkStdlibConfigParserNoSectionError
    static DuplicateSectionError := AhkStdlibConfigParserDuplicateSectionError
    static NoOptionError := AhkStdlibConfigParserNoOptionError
    static MissingSectionHeaderError := AhkStdlibConfigParserMissingSectionHeaderError
    static InterpolationError := AhkStdlibConfigParserInterpolationError
    static InterpolationDepthError := AhkStdlibConfigParserInterpolationDepthError
    static InterpolationMissingOptionError := AhkStdlibConfigParserInterpolationMissingOptionError
    static InterpolationSyntaxError := AhkStdlibConfigParserInterpolationSyntaxError
    static ConfigParser(options := unset)
    {
        return AhkStdlibConfigParser(options?)
    }

    static BasicInterpolation()
    {
        return AhkStdlibConfigParserBasicInterpolation()
    }

    static ExtendedInterpolation()
    {
        return AhkStdlibConfigParserExtendedInterpolation()
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

; Interpolation errors mirror CPython's hierarchy so callers can catch the
; family with a single except clause.
class AhkStdlibConfigParserInterpolationError extends AhkStdlibConfigParserError
{
}

class AhkStdlibConfigParserInterpolationDepthError extends AhkStdlibConfigParserInterpolationError
{
}

class AhkStdlibConfigParserInterpolationMissingOptionError extends AhkStdlibConfigParserInterpolationError
{
}

class AhkStdlibConfigParserInterpolationSyntaxError extends AhkStdlibConfigParserInterpolationError
{
}

class AhkStdlibConfigParser
{
    __New(options := unset)
    {
        this.AhkStdlibSections := Map()
        this.AhkStdlibSectionOrder := []
        this.AhkStdlibDefaults := AhkStdlibConfigParserSection()
        ; Default interpolation matches CPython: BasicInterpolation. Pass
        ; { interpolation: stdlib.None } to opt out, or a custom interpolation
        ; object that exposes before_get(parser, section, option, value, defaults).
        this.AhkStdlibInterpolation := AhkStdlibConfigParserBasicInterpolation()
        this.AhkStdlibConverters := Map()
        if IsSet(options) && IsObject(options) {
            if HasProp(options, "interpolation") {
                interp := options.interpolation
                if AhkStdlibIsNone(interp)
                    this.AhkStdlibInterpolation := stdlib.None
                else
                    this.AhkStdlibInterpolation := interp
            }
            if HasProp(options, "converters") && IsObject(options.converters) {
                ; converters: { name: Func } — exposes get<name>(section, option) on
                ; the parser by routing the raw value through the Func.
                if options.converters is Map {
                    for name, fn in options.converters
                        this.AhkStdlibConverters[name] := fn
                } else {
                    for name, fn in options.converters.OwnProps()
                        this.AhkStdlibConverters[name] := fn
                }
            }
        }
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
        currentOption := ""
        lineNumber := 0

        for rawLine in AhkStdlibConfigParserLines(text) {
            lineNumber += 1
            ; CPython continuation: a line that begins with whitespace is
            ; appended to the previous option's value with a "`n" separator.
            if rawLine != "" && AhkStdlibConfigParserIsContinuationLine(rawLine) && currentOption != "" && currentSection != "" {
                continuation := Trim(rawLine)
                if continuation = ""
                    continue
                AhkStdlibConfigParserAppendContinuation(this, currentSection, currentOption, continuation)
                continue
            }
            line := Trim(rawLine)
            if line = "" || SubStr(line, 1, 1) = "#" || SubStr(line, 1, 1) = ";" {
                ; Blank/comment lines reset the "still continuing" state to
                ; avoid silently absorbing later indented blocks.
                currentOption := ""
                continue
            }

            if SubStr(line, 1, 1) = "[" && SubStr(line, -1) = "]" {
                section := Trim(SubStr(line, 2, StrLen(line) - 2))
                if AhkStdlibConfigParserIsDefaultSectionName(section) {
                    currentSection := section
                    currentOption := ""
                    continue
                }
                this.add_section(section)
                currentSection := section
                currentOption := ""
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
            currentOption := AhkStdlibConfigParserNormalizeOption(option)
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
        raw := IsSet(options) && IsObject(options) && HasProp(options, "raw") && AhkStdlibTruthValue(options.raw)
        option := AhkStdlibConfigParserNormalizeOption(option)
        if AhkStdlibConfigParserIsDefaultSectionName(section) {
            if !this.AhkStdlibDefaults.Has(option) {
                if hasFallback
                    return options.fallback
                throw AhkStdlibConfigParserNoOptionError("No option '" option "' in section: '" section "'", -1)
            }
            value := this.AhkStdlibDefaults[option]
            return raw ? value : this.AhkStdlibInterpolate(section, option, value)
        }

        if !this.AhkStdlibSections.Has(section) {
            if hasFallback
                return options.fallback
            throw AhkStdlibConfigParserNoSectionError("No section: '" section "'", -1)
        }
        values := this.AhkStdlibSections[section]
        if values.Has(option)
            value := values[option]
        else if this.AhkStdlibDefaults.Has(option)
            value := this.AhkStdlibDefaults[option]
        else if hasFallback
            return options.fallback
        else
            throw AhkStdlibConfigParserNoOptionError("No option '" option "' in section: '" section "'", -1)
        return raw ? value : this.AhkStdlibInterpolate(section, option, value)
    }

    AhkStdlibInterpolate(section, option, value)
    {
        if !IsObject(this.AhkStdlibInterpolation) || AhkStdlibIsNone(this.AhkStdlibInterpolation)
            return value
        if !HasMethod(this.AhkStdlibInterpolation, "before_get")
            return value
        return this.AhkStdlibInterpolation.before_get(this, section, option, value, this.AhkStdlibDefaults)
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

    ; Dynamic dispatch for converters: parser.getlist(section, option) when the
    ; constructor was given converters={list: fn}. Mirrors CPython's behavior.
    __Call(name, args)
    {
        if SubStr(name, 1, 3) = "get" {
            converterName := SubStr(name, 4)
            if this.AhkStdlibConverters.Has(converterName) {
                converter := this.AhkStdlibConverters[converterName]
                if args.Length < 2
                    throw TypeError(name "() requires section and option arguments", -1)
                section := args[1]
                option := args[2]
                options := args.Length >= 3 ? args[3] : unset
                hasFallback := IsSet(options) && IsObject(options) && HasProp(options, "fallback")
                if hasFallback && !this.has_option(section, option)
                    return options.fallback
                return converter(this.get(section, option))
            }
        }
        throw MethodError("'" Type(this) "' object has no method '" name "'", -1)
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

; CPython BasicInterpolation: "%(option)s" references resolve from the current
; section, with DEFAULT as a fallback. Stops at depth 10 to match Python's
; MAX_INTERPOLATION_DEPTH guard against cycles.
class AhkStdlibConfigParserBasicInterpolation
{
    static MAX_DEPTH := 10

    before_get(parser, section, option, value, defaults)
    {
        return this._interpolate(parser, section, option, value, 0)
    }

    _interpolate(parser, section, option, value, depth)
    {
        if depth > AhkStdlibConfigParserBasicInterpolation.MAX_DEPTH
            throw AhkStdlibConfigParserInterpolationDepthError("Recursion limit exceeded in value '" value "' for option '" option "' in section '" section "'", -1)
        result := ""
        i := 1
        n := StrLen(value)
        while i <= n {
            ch := SubStr(value, i, 1)
            if ch != "%" {
                result .= ch
                i += 1
                continue
            }
            ; %% → literal %; %(name)s → reference; anything else is a syntax error.
            next := SubStr(value, i + 1, 1)
            if next = "%" {
                result .= "%"
                i += 2
                continue
            }
            if next != "(" {
                throw AhkStdlibConfigParserInterpolationSyntaxError("'" SubStr(value, i, 2) "' must be followed by '%' or '(', found: '" SubStr(value, i + 1) "'", -1)
            }
            closePos := InStr(value, ")", , i + 2)
            if !closePos
                throw AhkStdlibConfigParserInterpolationSyntaxError("bad interpolation variable reference '" SubStr(value, i) "'", -1)
            refName := SubStr(value, i + 2, closePos - (i + 2))
            ; CPython requires "(name)s" — the trailing 's' formats as a string.
            if SubStr(value, closePos + 1, 1) != "s"
                throw AhkStdlibConfigParserInterpolationSyntaxError("bad interpolation variable reference '" SubStr(value, i, closePos - i + 2) "' — expected 's' format", -1)
            referenced := AhkStdlibConfigParserResolveBasicReference(parser, section, refName)
            result .= this._interpolate(parser, section, refName, referenced, depth + 1)
            i := closePos + 2
        }
        return result
    }
}

; CPython ExtendedInterpolation: "${section:option}" references resolve across
; sections. "${option}" inside a section means the same as ${section:option}.
class AhkStdlibConfigParserExtendedInterpolation
{
    static MAX_DEPTH := 10

    before_get(parser, section, option, value, defaults)
    {
        return this._interpolate(parser, section, option, value, 0)
    }

    _interpolate(parser, section, option, value, depth)
    {
        if depth > AhkStdlibConfigParserExtendedInterpolation.MAX_DEPTH
            throw AhkStdlibConfigParserInterpolationDepthError("Recursion limit exceeded in value '" value "' for option '" option "' in section '" section "'", -1)
        result := ""
        i := 1
        n := StrLen(value)
        while i <= n {
            ch := SubStr(value, i, 1)
            if ch != "$" {
                result .= ch
                i += 1
                continue
            }
            next := SubStr(value, i + 1, 1)
            if next = "$" {
                result .= "$"
                i += 2
                continue
            }
            if next != "{"
                throw AhkStdlibConfigParserInterpolationSyntaxError("bad interpolation variable reference '" SubStr(value, i) "'", -1)
            closePos := InStr(value, "}", , i + 2)
            if !closePos
                throw AhkStdlibConfigParserInterpolationSyntaxError("bad interpolation variable reference '" SubStr(value, i) "'", -1)
            refSpec := SubStr(value, i + 2, closePos - (i + 2))
            ; A colon splits "section:option"; bare names default to current section.
            colon := InStr(refSpec, ":")
            if colon {
                refSection := SubStr(refSpec, 1, colon - 1)
                refOption := SubStr(refSpec, colon + 1)
            } else {
                refSection := section
                refOption := refSpec
            }
            referenced := AhkStdlibConfigParserResolveExtendedReference(parser, refSection, refOption)
            result .= this._interpolate(parser, refSection, refOption, referenced, depth + 1)
            i := closePos + 1
        }
        return result
    }
}

AhkStdlibConfigParserIsContinuationLine(rawLine)
{
    if rawLine = ""
        return false
    first := SubStr(rawLine, 1, 1)
    return first = " " || first = "`t"
}

AhkStdlibConfigParserAppendContinuation(parser, section, option, continuation)
{
    if AhkStdlibConfigParserIsDefaultSectionName(section)
        values := parser.AhkStdlibDefaults
    else if !parser.AhkStdlibSections.Has(section)
        return
    else
        values := parser.AhkStdlibSections[section]
    if !values.Values.Has(option)
        return
    values.Values[option] := values.Values[option] "`n" continuation
}

AhkStdlibConfigParserResolveBasicReference(parser, section, refName)
{
    refOpt := AhkStdlibConfigParserNormalizeOption(refName)
    if AhkStdlibConfigParserIsDefaultSectionName(section) {
        if parser.AhkStdlibDefaults.Has(refOpt)
            return parser.AhkStdlibDefaults[refOpt]
    } else if parser.AhkStdlibSections.Has(section) {
        sect := parser.AhkStdlibSections[section]
        if sect.Has(refOpt)
            return sect[refOpt]
        if parser.AhkStdlibDefaults.Has(refOpt)
            return parser.AhkStdlibDefaults[refOpt]
    } else if parser.AhkStdlibDefaults.Has(refOpt) {
        return parser.AhkStdlibDefaults[refOpt]
    }
    throw AhkStdlibConfigParserInterpolationMissingOptionError("Bad value substitution: option '" refName "' in section '" section "' contains an interpolation key '" refName "' which is not a valid option name. Raw value: ", -1)
}

AhkStdlibConfigParserResolveExtendedReference(parser, section, refOption)
{
    refOpt := AhkStdlibConfigParserNormalizeOption(refOption)
    if AhkStdlibConfigParserIsDefaultSectionName(section) {
        if parser.AhkStdlibDefaults.Has(refOpt)
            return parser.AhkStdlibDefaults[refOpt]
    } else if parser.AhkStdlibSections.Has(section) {
        sect := parser.AhkStdlibSections[section]
        if sect.Has(refOpt)
            return sect[refOpt]
        if parser.AhkStdlibDefaults.Has(refOpt)
            return parser.AhkStdlibDefaults[refOpt]
    } else if parser.AhkStdlibDefaults.Has(refOpt) {
        return parser.AhkStdlibDefaults[refOpt]
    }
    throw AhkStdlibConfigParserInterpolationMissingOptionError("Bad value substitution: option '" refOption "' in section '" section "' references missing key", -1)
}

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
