#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibCsvError extends Error
{
}

class AhkStdlibCsvDialect
{
    __New(options := unset)
    {
        this.delimiter := ","
        this.quotechar := "`""
        this.escapechar := ""
        this.doublequote := true
        this.skipinitialspace := false
        this.lineterminator := "`r`n"
        this.quoting := 0
        this.strict := false

        if IsSet(options)
            AhkStdlibCsvApplyOptions(this, options)
        AhkStdlibCsvValidateDialect(this)
    }

    Clone()
    {
        return AhkStdlibCsvDialect({
            delimiter: this.delimiter,
            quotechar: this.quotechar,
            escapechar: this.escapechar,
            doublequote: this.doublequote,
            skipinitialspace: this.skipinitialspace,
            lineterminator: this.lineterminator,
            quoting: this.quoting,
            strict: this.strict
        })
    }
}

class AhkStdlibCsvExcel extends AhkStdlibCsvDialect
{
}

class AhkStdlibCsvExcelTab extends AhkStdlibCsvDialect
{
    __New(options := unset)
    {
        super.__New({ delimiter: "`t" })
        if IsSet(options)
            AhkStdlibCsvApplyOptions(this, options)
        AhkStdlibCsvValidateDialect(this)
    }
}

class AhkStdlibCsvUnixDialect extends AhkStdlibCsvDialect
{
    __New(options := unset)
    {
        super.__New({ lineterminator: "`n", quoting: 1 })
        if IsSet(options)
            AhkStdlibCsvApplyOptions(this, options)
        AhkStdlibCsvValidateDialect(this)
    }
}

class AhkStdlibCsv
{
    static QUOTE_MINIMAL := 0
    static QUOTE_ALL := 1
    static QUOTE_NONNUMERIC := 2
    static QUOTE_NONE := 3
    static __version__ := "1.0"
    static Error := AhkStdlibCsvError
    static Dialect := AhkStdlibCsvDialect
    static excel := AhkStdlibCsvExcel
    static excel_tab := AhkStdlibCsvExcelTab
    static unix_dialect := AhkStdlibCsvUnixDialect

    static reader(textOrLines, dialect := "excel", options := unset)
    {
        resolved := AhkStdlibCsvResolveDialect(dialect, options?)
        return AhkStdlibCsvReader(textOrLines, resolved)
    }

    static writer(options := unset, dialect := "excel")
    {
        resolved := AhkStdlibCsvResolveDialect(dialect, options?)
        return AhkStdlibCsvWriter(resolved)
    }

    static DictReader(textOrLines, fieldnames := unset, options := unset, dialect := "excel")
    {
        resolved := AhkStdlibCsvResolveDialect(dialect, options?)
        return AhkStdlibCsvDictReader(textOrLines, IsSet(fieldnames) ? fieldnames : unset, resolved, options?)
    }

    static DictWriter(fieldnames, options := unset, dialect := "excel")
    {
        resolved := AhkStdlibCsvResolveDialect(dialect, options?)
        return AhkStdlibCsvDictWriter(fieldnames, resolved, options?)
    }

    static get_dialect(name)
    {
        return AhkStdlibCsvGetDialect(name)
    }

    static list_dialects()
    {
        return AhkStdlibCsvListDialects()
    }

    static register_dialect(name, dialect := "excel", options := unset)
    {
        AhkStdlibCsvRegisterDialect(name, AhkStdlibCsvResolveDialect(dialect, options?))
    }

    static unregister_dialect(name)
    {
        AhkStdlibCsvUnregisterDialect(name)
    }

    static Sniffer(args*)
    {
        if args.Length != 0
            throw TypeError("Sniffer() takes no arguments", -1)
        return AhkStdlibCsvSniffer()
    }

    static field_size_limit(args*)
    {
        if args.Length = 0
            return AhkStdlibCsvFieldSizeLimit()
        if args.Length = 1
            return AhkStdlibCsvFieldSizeLimit(args[1])
        throw TypeError("field_size_limit() takes at most 1 argument (" args.Length " given)", -1)
    }
}

class AhkStdlibCsvReader
{
    __New(textOrLines, dialect)
    {
        this.dialect := dialect
        source := AhkStdlibCsvInputSource(textOrLines)
        parsed := AhkStdlibCsvParse(source, dialect)
        this.Rows := parsed.Rows
        this.RowLineNums := parsed.LineNums
        this.Index := 1
        this.line_num := 0
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextRow

        NextRow(&row)
        {
            if self.Index > self.Rows.Length
                return false

            row := self.Rows[self.Index]
            self.line_num := self.RowLineNums[self.Index]
            self.Index += 1
            return true
        }
    }
}

class AhkStdlibCsvWriter
{
    __New(dialect)
    {
        this.dialect := dialect
        this.text := ""
    }

    writerow(row)
    {
        if !(row is Array)
            throw TypeError("iterable expected, not " Type(row), -1)

        fields := []
        for value in row
            fields.Push(AhkStdlibCsvFormatField(value, this.dialect))
        line := AhkStdlibCsvJoin(fields, this.dialect.delimiter) this.dialect.lineterminator
        this.text .= line
        return StrLen(line)
    }

    writerows(rows)
    {
        for row in rows
            this.writerow(row)
    }
}

class AhkStdlibCsvDictReader
{
    __New(textOrLines, fieldnames := unset, dialect := unset, options := unset)
    {
        this.reader := AhkStdlibCsvReader(textOrLines, dialect)
        this.Rows := this.reader.Rows
        this.line_num := 0
        this._fieldnames := IsSet(fieldnames) ? fieldnames : unset
        if AhkStdlibCsvHasOption(options?, "restkey", "RestKey")
            this.restkey := AhkStdlibCsvOption(options, "restkey", "RestKey")
        if AhkStdlibCsvHasOption(options?, "restval", "RestVal")
            this.restval := AhkStdlibCsvOption(options, "restval", "RestVal")
        this.BuildRows()
    }

    fieldnames {
        get {
            if !HasProp(this, "_fieldnames") {
                if this.Rows.Length >= 1 {
                    this._fieldnames := this.Rows[1]
                    this.line_num := 1
                } else {
                    missing := unset
                    return missing
                }
            }
            return this._fieldnames
        }
        set => this._fieldnames := value
    }

    __Enum(numberOfVars)
    {
        return this.DictRows.__Enum(numberOfVars)
    }

    BuildRows()
    {
        this.DictRows := []
        startIndex := 1
        fieldnames := this.fieldnames
        if this.line_num = 1
            startIndex := 2

        Loop this.Rows.Length - startIndex + 1 {
            rowIndex := startIndex + A_Index - 1
            row := this.Rows[rowIndex]
            if row.Length = 0
                continue
            this.DictRows.Push(this.RowToMap(fieldnames, row))
            this.line_num := rowIndex
        }
    }

    RowToMap(fieldnames, row)
    {
        result := Map()
        fieldCount := fieldnames.Length
        rowCount := row.Length
        sharedCount := Min(fieldCount, rowCount)

        Loop sharedCount
            result[fieldnames[A_Index]] := row[A_Index]

        if fieldCount < rowCount {
            extras := []
            Loop rowCount - fieldCount
                extras.Push(row[fieldCount + A_Index])
            result[this.restkey] := extras
        } else if fieldCount > rowCount {
            Loop fieldCount - rowCount
                result[fieldnames[rowCount + A_Index]] := this.restval
        }

        return result
    }
}

class AhkStdlibCsvDictWriter
{
    __New(fieldnames, dialect, options := unset)
    {
        this.fieldnames := fieldnames
        this.writer := AhkStdlibCsvWriter(dialect)
        this.restval := AhkStdlibCsvOption(options?, "restval", "RestVal", "")
        this.extrasaction := AhkStdlibCsvOption(options?, "extrasaction", "ExtrasAction", "raise")
        if StrLower(this.extrasaction) != "raise" && StrLower(this.extrasaction) != "ignore"
            throw ValueError("extrasaction (" this.extrasaction ") must be 'raise' or 'ignore'", -1)
    }

    text {
        get => this.writer.text
    }

    writeheader()
    {
        header := Map()
        for fieldname in this.fieldnames
            header[fieldname] := fieldname
        return this.writerow(header)
    }

    writerow(rowdict)
    {
        return this.writer.writerow(this.DictToList(rowdict))
    }

    writerows(rowdicts)
    {
        for rowdict in rowdicts
            this.writerow(rowdict)
    }

    DictToList(rowdict)
    {
        if !(rowdict is Map)
            throw Error("'" Type(rowdict) "' object has no attribute 'keys'", -1)

        if this.extrasaction = "raise" {
            extraFields := []
            for key in rowdict {
                if !AhkStdlibCsvArrayContains(this.fieldnames, key)
                    extraFields.Push(key)
            }
            if extraFields.Length > 0
                throw ValueError("dict contains fields not in fieldnames: " AhkStdlibCsvFormatWrongFields(extraFields), -1)
        }

        row := []
        for fieldname in this.fieldnames
            row.Push(rowdict.Has(fieldname) ? rowdict[fieldname] : this.restval)
        return row
    }
}

class AhkStdlibCsvSniffer
{
    sniff(sample, delimiters := unset)
    {
        delimiter := AhkStdlibCsvSniffDelimiter(sample, delimiters?)
        return AhkStdlibCsvDialect({ delimiter: delimiter })
    }

    has_header(sample)
    {
        rows := AhkStdlibCsvParse(AhkStdlibCsvSourceFromText(sample), AhkStdlibCsvDialect()).Rows
        if rows.Length < 2
            return false

        header := rows[1]
        score := 0
        Loop header.Length {
            column := A_Index
            headerNumeric := AhkStdlibCsvSnifferIsNumber(header[column])
            dataNumeric := 0
            dataSeen := 0
            Loop Min(rows.Length - 1, 20) {
                row := rows[A_Index + 1]
                if column > row.Length || row[column] = ""
                    continue
                dataSeen += 1
                if AhkStdlibCsvSnifferIsNumber(row[column])
                    dataNumeric += 1
            }
            if dataSeen > 0 && !headerNumeric && dataNumeric > 0
                score += 1
            else if dataSeen > 0 && headerNumeric && dataNumeric = dataSeen
                score -= 1
        }

        return score > 0
    }
}

stdlib.csv := AhkStdlibCsv

AhkStdlibCsvFieldSizeLimit(value := unset)
{
    static limit := 131072
    if !IsSet(value)
        return limit
    oldLimit := limit
    limit := Integer(value)
    return oldLimit
}

AhkStdlibCsvRegistry()
{
    static registry := unset
    if !IsSet(registry) {
        registry := Map()
        registry["excel"] := AhkStdlibCsvDialect()
        registry["excel-tab"] := AhkStdlibCsvDialect({ delimiter: "`t" })
        registry["unix"] := AhkStdlibCsvDialect({ lineterminator: "`n", quoting: 1 })
    }
    return registry
}

AhkStdlibCsvGetDialect(name)
{
    registry := AhkStdlibCsvRegistry()
    if !registry.Has(name)
        throw AhkStdlibCsvError("unknown dialect", -1)
    return registry[name].Clone()
}

AhkStdlibCsvListDialects()
{
    result := []
    for name in AhkStdlibCsvRegistry()
        result.Push(name)
    return result
}

AhkStdlibCsvRegisterDialect(name, dialect)
{
    if !(name is String)
        throw TypeError("dialect name must be a string", -1)
    AhkStdlibCsvRegistry()[name] := dialect.Clone()
}

AhkStdlibCsvUnregisterDialect(name)
{
    registry := AhkStdlibCsvRegistry()
    if !registry.Has(name)
        throw AhkStdlibCsvError("unknown dialect", -1)
    registry.Delete(name)
}

AhkStdlibCsvResolveDialect(dialect := "excel", options := unset)
{
    if dialect is String
        result := AhkStdlibCsvGetDialect(dialect)
    else if dialect is AhkStdlibCsvDialect
        result := dialect.Clone()
    else if IsObject(dialect)
        result := AhkStdlibCsvDialect(dialect)
    else
        throw TypeError("dialect must be a string or dialect object", -1)

    if IsSet(options) {
        AhkStdlibCsvApplyOptions(result, options)
        AhkStdlibCsvValidateDialect(result)
    }
    return result
}

AhkStdlibCsvApplyOptions(dialect, options)
{
    for name in ["delimiter", "quotechar", "escapechar", "doublequote", "skipinitialspace", "lineterminator", "quoting", "strict"] {
        if options is Map {
            if options.Has(name)
                dialect.%name% := options[name]
        } else if IsObject(options) && HasProp(options, name) {
            dialect.%name% := options.%name%
        }
    }
}

AhkStdlibCsvValidateDialect(dialect)
{
    if !(dialect.delimiter is String) || StrLen(dialect.delimiter) != 1
        throw TypeError('"delimiter" must be a 1-character string', -1)

    if dialect.quoting != 3 {
        if dialect.quotechar = ""
            throw TypeError("quotechar must be set if quoting enabled", -1)
        if !(dialect.quotechar is String) || StrLen(dialect.quotechar) != 1
            throw TypeError('"quotechar" must be a 1-character string', -1)
    } else if dialect.quotechar != "" && (!(dialect.quotechar is String) || StrLen(dialect.quotechar) != 1) {
        throw TypeError('"quotechar" must be a 1-character string', -1)
    }

    if dialect.escapechar != "" && (!(dialect.escapechar is String) || StrLen(dialect.escapechar) != 1)
        throw TypeError('"escapechar" must be a 1-character string', -1)

    if dialect.quoting < 0 || dialect.quoting > 3
        throw TypeError('bad "quoting" value', -1)
}

AhkStdlibCsvInputSource(textOrLines)
{
    if textOrLines is String
        return AhkStdlibCsvSourceFromText(textOrLines)

    if textOrLines is Array {
        text := ""
        lineNums := []
        artificialBreaks := Map()
        physicalLine := 1

        for index, line in textOrLines {
            if !(line is String)
                throw AhkStdlibCsvError("iterator should return strings, not " Type(line), -1)
            AhkStdlibCsvAppendTextLineInfo(line, &text, lineNums, &physicalLine)
            if index < textOrLines.Length && !AhkStdlibCsvEndsWithNewline(line) {
                text .= "`n"
                lineNums.Push(physicalLine)
                artificialBreaks[StrLen(text)] := true
                physicalLine += 1
            }
        }

        return { Text: text, LineNums: lineNums, ArtificialBreaks: artificialBreaks }
    }

    throw TypeError("reader input must be a string or array of strings", -1)
}

AhkStdlibCsvSourceFromText(text)
{
    sourceText := ""
    lineNums := []
    physicalLine := 1
    AhkStdlibCsvAppendTextLineInfo(text, &sourceText, lineNums, &physicalLine)
    return { Text: sourceText, LineNums: lineNums, ArtificialBreaks: Map() }
}

AhkStdlibCsvAppendTextLineInfo(chunk, &text, lineNums, &physicalLine)
{
    pos := 1
    length := StrLen(chunk)
    while pos <= length {
        ch := SubStr(chunk, pos, 1)
        text .= ch
        lineNums.Push(physicalLine)
        if ch = "`r" {
            if pos < length && SubStr(chunk, pos + 1, 1) = "`n" {
                pos += 1
                text .= "`n"
                lineNums.Push(physicalLine)
            }
            physicalLine += 1
        } else if ch = "`n" {
            physicalLine += 1
        }
        pos += 1
    }
}

AhkStdlibCsvEndsWithNewline(text)
{
    if text = ""
        return false
    last := SubStr(text, -1)
    return last = "`r" || last = "`n"
}

AhkStdlibCsvParse(source, dialect)
{
    text := source.Text
    lineNums := source.LineNums
    artificialBreaks := source.ArtificialBreaks
    rows := []
    rowLineNums := []
    row := []
    field := ""
    inQuotes := false
    quotedField := false
    atFieldStart := true
    afterDelimiter := false
    haveData := false
    pos := 1
    length := StrLen(text)

    while pos <= length {
        ch := SubStr(text, pos, 1)

        if inQuotes {
            if AhkStdlibCsvIsArtificialBreak(artificialBreaks, pos) {
                pos += 1
                continue
            }

            if dialect.escapechar != "" && ch = dialect.escapechar {
                if pos < length {
                    AhkStdlibCsvAppendField(&field, SubStr(text, pos + 1, 1))
                    pos += 2
                } else {
                    AhkStdlibCsvAppendField(&field, ch)
                    pos += 1
                }
                continue
            }

            if ch = dialect.quotechar {
                nextCh := pos < length ? SubStr(text, pos + 1, 1) : ""
                if dialect.doublequote && nextCh = dialect.quotechar {
                    AhkStdlibCsvAppendField(&field, dialect.quotechar)
                    pos += 2
                    continue
                }
                inQuotes := false
                pos += 1
                continue
            }

            AhkStdlibCsvAppendField(&field, ch)
            pos += 1
            continue
        }

        if atFieldStart && afterDelimiter && dialect.skipinitialspace && ch = " " {
            pos += 1
            continue
        }

        if dialect.escapechar != "" && ch = dialect.escapechar {
            if pos < length {
                AhkStdlibCsvAppendField(&field, SubStr(text, pos + 1, 1))
                pos += 2
            } else {
                AhkStdlibCsvAppendField(&field, ch)
                pos += 1
            }
            atFieldStart := false
            afterDelimiter := false
            haveData := true
            continue
        }

        if atFieldStart && dialect.quotechar != "" && ch = dialect.quotechar {
            inQuotes := true
            quotedField := true
            haveData := true
            atFieldStart := false
            afterDelimiter := false
            pos += 1
            continue
        }

        if ch = dialect.delimiter {
            row.Push(AhkStdlibCsvConvertReadField(field, quotedField, dialect))
            field := ""
            atFieldStart := true
            afterDelimiter := true
            quotedField := false
            haveData := true
            pos += 1
            continue
        }

        if ch = "`r" || ch = "`n" {
            if !haveData && field = "" && row.Length = 0 && !quotedField
                rows.Push([]), rowLineNums.Push(AhkStdlibCsvLineNumberAt(lineNums, pos))
            else {
                row.Push(AhkStdlibCsvConvertReadField(field, quotedField, dialect))
                rows.Push(row)
                rowLineNums.Push(AhkStdlibCsvLineNumberAt(lineNums, pos))
            }
            row := []
            field := ""
            atFieldStart := true
            afterDelimiter := false
            quotedField := false
            haveData := false
            if ch = "`r" && pos < length && SubStr(text, pos + 1, 1) = "`n"
                pos += 2
            else
                pos += 1
            continue
        }

        AhkStdlibCsvAppendField(&field, ch)
        atFieldStart := false
        afterDelimiter := false
        haveData := true
        pos += 1
    }

    if inQuotes && dialect.strict
        throw AhkStdlibCsvError("unexpected end of data", -1)

    if inQuotes && !dialect.strict
        quotedField := true

    if haveData || field != "" || row.Length > 0 || quotedField {
        row.Push(AhkStdlibCsvConvertReadField(field, quotedField, dialect))
        rows.Push(row)
        rowLineNums.Push(AhkStdlibCsvLineNumberAt(lineNums, length))
    }

    return { Rows: rows, LineNums: rowLineNums }
}

AhkStdlibCsvAppendField(&field, text)
{
    field .= text
    limit := AhkStdlibCsvFieldSizeLimit()
    if StrLen(field) > limit
        throw AhkStdlibCsvError("field larger than field limit (" limit ")", -1)
}

AhkStdlibCsvIsArtificialBreak(artificialBreaks, pos)
{
    return artificialBreaks.Has(pos)
}

AhkStdlibCsvLineNumberAt(lineNums, pos)
{
    if pos < 1
        return 0
    if pos > lineNums.Length
        return lineNums.Length > 0 ? lineNums[lineNums.Length] : 0
    return lineNums[pos]
}

AhkStdlibCsvConvertReadField(field, quotedField, dialect)
{
    if dialect.quoting != 2 || quotedField || field = ""
        return field

    try {
        return Float(field)
    } catch {
        throw ValueError("could not convert string to float: '" field "'", -1)
    }
}

AhkStdlibCsvFormatField(value, dialect)
{
    text := value ""
    if dialect.quoting = 1
        return AhkStdlibCsvQuoteField(text, dialect)

    if dialect.quoting = 2 {
        if AhkStdlibCsvIsNativeNumber(value)
            return text
        return AhkStdlibCsvQuoteField(text, dialect)
    }

    if dialect.quoting = 3
        return AhkStdlibCsvEscapeField(text, dialect)

    if AhkStdlibCsvNeedsQuote(text, dialect)
        return AhkStdlibCsvQuoteField(text, dialect)
    return text
}

AhkStdlibCsvNeedsQuote(text, dialect)
{
    if InStr(text, dialect.delimiter)
        return true
    if dialect.quotechar != "" && InStr(text, dialect.quotechar)
        return true
    if InStr(text, "`r") || InStr(text, "`n")
        return true
    Loop Parse, dialect.lineterminator {
        if A_LoopField != "" && InStr(text, A_LoopField)
            return true
    }
    return false
}

AhkStdlibCsvIsNativeNumber(value)
{
    return (value is Integer) || (value is Float)
}

AhkStdlibCsvQuoteField(text, dialect)
{
    if dialect.quotechar = ""
        throw AhkStdlibCsvError("quotechar must be set", -1)

    if InStr(text, dialect.quotechar) {
        if dialect.doublequote
            text := StrReplace(text, dialect.quotechar, dialect.quotechar dialect.quotechar)
        else if dialect.escapechar != ""
            text := StrReplace(text, dialect.quotechar, dialect.escapechar dialect.quotechar)
        else
            throw AhkStdlibCsvError("need to escape, but no escapechar set", -1)
    }

    return dialect.quotechar text dialect.quotechar
}

AhkStdlibCsvEscapeField(text, dialect)
{
    result := ""
    Loop Parse, text {
        ch := A_LoopField
        if AhkStdlibCsvNeedsEscapeChar(ch, dialect) {
            if dialect.escapechar = ""
                throw AhkStdlibCsvError("need to escape, but no escapechar set", -1)
            result .= dialect.escapechar
        }
        result .= ch
    }
    return result
}

AhkStdlibCsvNeedsEscapeChar(ch, dialect)
{
    if ch = dialect.delimiter
        return true
    if dialect.quotechar != "" && ch = dialect.quotechar
        return true
    if ch = "`r" || ch = "`n"
        return true
    return false
}

AhkStdlibCsvJoin(values, delimiter := "")
{
    result := ""
    for index, value in values {
        if index > 1
            result .= delimiter
        result .= value
    }
    return result
}

AhkStdlibCsvOption(options := unset, snakeName := "", pascalName := "", defaultValue := unset)
{
    if !IsSet(options) {
        if IsSet(defaultValue)
            return defaultValue
        missing := unset
        return missing
    }

    if options is Map {
        if options.Has(snakeName)
            return options[snakeName]
        if options.Has(pascalName)
            return options[pascalName]
    } else if IsObject(options) {
        if HasProp(options, snakeName)
            return options.%snakeName%
        if HasProp(options, pascalName)
            return options.%pascalName%
    }

    if IsSet(defaultValue)
        return defaultValue
    missing := unset
    return missing
}

AhkStdlibCsvHasOption(options := unset, snakeName := "", pascalName := "")
{
    if !IsSet(options)
        return false
    if options is Map
        return options.Has(snakeName) || options.Has(pascalName)
    if IsObject(options)
        return HasProp(options, snakeName) || HasProp(options, pascalName)
    return false
}

AhkStdlibCsvArrayContains(values, needle)
{
    for value in values {
        if value = needle
            return true
    }
    return false
}

AhkStdlibCsvSniffDelimiter(sample, delimiters := unset)
{
    candidates := AhkStdlibCsvSnifferCandidates(delimiters?)
    best := ""
    bestScore := -1
    lines := AhkStdlibCsvSnifferLines(sample)
    for candidate in candidates {
        counts := []
        for line in lines {
            count := AhkStdlibCsvCountChar(line, candidate)
            if count > 0
                counts.Push(count)
        }
        if counts.Length = 0
            continue
        score := counts.Length * 100 - AhkStdlibCsvCountVariance(counts)
        if score > bestScore {
            bestScore := score
            best := candidate
        }
    }
    if best = ""
        throw AhkStdlibCsvError("Could not determine delimiter", -1)
    return best
}

AhkStdlibCsvSnifferCandidates(delimiters := unset)
{
    source := IsSet(delimiters) ? delimiters : ",`t; :|"
    result := []
    Loop Parse, source {
        if A_LoopField != "" && !AhkStdlibCsvArrayContains(result, A_LoopField)
            result.Push(A_LoopField)
    }
    return result
}

AhkStdlibCsvSnifferLines(sample)
{
    lines := []
    current := ""
    Loop Parse, sample {
        ch := A_LoopField
        if ch = "`r"
            continue
        if ch = "`n" {
            if current != ""
                lines.Push(current)
            current := ""
            continue
        }
        current .= ch
    }
    if current != ""
        lines.Push(current)
    return lines
}

AhkStdlibCsvCountChar(text, needle)
{
    count := 0
    Loop Parse, text {
        if A_LoopField = needle
            count += 1
    }
    return count
}

AhkStdlibCsvCountVariance(values)
{
    if values.Length <= 1
        return 0
    minValue := values[1]
    maxValue := values[1]
    for value in values {
        if value < minValue
            minValue := value
        if value > maxValue
            maxValue := value
    }
    return maxValue - minValue
}

AhkStdlibCsvSnifferIsNumber(value)
{
    if value = ""
        return false
    try {
        Float(value)
        return true
    } catch {
        return false
    }
}

AhkStdlibCsvFormatWrongFields(fields)
{
    parts := []
    for field in fields
        parts.Push("'" field "'")
    return AhkStdlibCsvJoin(parts, ", ")
}
