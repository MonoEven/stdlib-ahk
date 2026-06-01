#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\io>

class AhkStdlibLogging
{
    static _Root := unset
    static _Loggers := Map()
    static Formatter := AhkStdlibLoggingFormatterClass
    static FileHandler := AhkStdlibLoggingFileHandlerClass
    static StreamHandler := AhkStdlibLoggingStreamHandlerClass
    static DEBUG {
        get => 10
    }
    static INFO {
        get => 20
    }
    static WARN {
        get => this.WARNING
    }
    static WARNING {
        get => 30
    }
    static ERROR {
        get => 40
    }
    static FATAL {
        get => this.CRITICAL
    }
    static CRITICAL {
        get => 50
    }

    static getLogger(name := unset)
    {
        if !IsSet(name) || AhkStdlibIsNone(name) || name = ""
            return this.Root()
        if !(name is String)
            throw TypeError("A logger name must be a string", -1)
        if name = "root"
            return this.Root()
        if !this._Loggers.Has(name)
            this._Loggers[name] := AhkStdlibLoggingLogger(name, 0, this.Root())
        return this._Loggers[name]
    }

    static basicConfig(options := unset)
    {
        root := this.Root()
        force := false
        if root.handlers.Length > 0 {
            if IsSet(options) && IsObject(options) && HasProp(options, "force")
                force := AhkStdlibTruthValue(options.force)
            if !force
                return ""
        }

        stream := unset
        filename := unset
        handlers := unset
        filemode := "a"
        encoding := "UTF-8"
        level := unset
        formatText := unset
        if IsSet(options) {
            if !IsObject(options)
                throw TypeError("basicConfig options must be an object", -1)
            if HasProp(options, "stream")
                stream := options.stream
            if HasProp(options, "filename")
                filename := options.filename
            if HasProp(options, "handlers")
                handlers := AhkStdlibLoggingNormalizeHandlers(options.handlers)
            if IsSet(handlers) && (IsSet(stream) || IsSet(filename))
                throw ValueError("'stream' or 'filename' should not be specified together with 'handlers'", -1)
            if IsSet(stream) && IsSet(filename)
                throw ValueError("'stream' and 'filename' should not be specified together", -1)
            if HasProp(options, "filemode")
                filemode := options.filemode
            if HasProp(options, "encoding")
                encoding := options.encoding
            if HasProp(options, "level")
                level := AhkStdlibLoggingNormalizeLevel(options.level)
            if HasProp(options, "format")
                formatText := AhkStdlibLoggingNormalizeFormat(options.format)
        }

        if force
            AhkStdlibLoggingCloseHandlers(root)
        if IsSet(handlers) {
            for handler in handlers {
                if !IsObject(handler.formatter)
                    handler.setFormatter(AhkStdlibLoggingFormatter(IsSet(formatText) ? formatText : "%(levelname)s:%(name)s:%(message)s"))
                root.addHandler(handler)
            }
        } else {
            if IsSet(filename)
                handler := AhkStdlibLoggingFileHandler(filename, filemode, encoding)
            else
                handler := AhkStdlibLoggingStreamHandler(IsSet(stream) ? AhkStdlibLoggingNormalizeStream(stream) : FileOpen("**", "w", "UTF-8"))
            if IsSet(formatText)
                handler.setFormatter(AhkStdlibLoggingFormatter(formatText))
            else
                handler.setFormatter(AhkStdlibLoggingFormatter())
            root.addHandler(handler)
        }
        if IsSet(level)
            root.setLevel(level)
        return ""
    }

    static warning(message)
    {
        this.Root().warning(message)
    }

    static debug(message)
    {
        this.Root().debug(message)
    }

    static info(message)
    {
        this.Root().info(message)
    }

    static error(message)
    {
        this.Root().error(message)
    }

    static critical(message)
    {
        this.Root().critical(message)
    }

    static fatal(message)
    {
        this.Root().critical(message)
    }

    static _resetForTests()
    {
        this._Loggers := Map()
        this._Root := AhkStdlibLoggingLogger("root", this.WARNING)
    }

    static Root()
    {
        if !HasProp(this, "_Root") || !IsObject(this._Root)
            this._resetForTests()
        return this._Root
    }
}

class AhkStdlibLoggingLogger
{
    __New(name, level := 0, parent := unset)
    {
        this.name := name = "" ? "root" : name
        this.level := level
        this.parent := IsSet(parent) ? parent : ""
        this.handlers := []
        this.propagate := true
    }

    setLevel(level)
    {
        this.level := AhkStdlibLoggingNormalizeLevel(level)
    }

    getEffectiveLevel()
    {
        if this.level != 0
            return this.level
        if IsObject(this.parent)
            return this.parent.getEffectiveLevel()
        return 0
    }

    isEnabledFor(level)
    {
        level := AhkStdlibLoggingNormalizeLevel(level)
        return level >= this.getEffectiveLevel()
    }

    addHandler(handler)
    {
        this.handlers.Push(handler)
    }

    info(message)
    {
        this.log(AhkStdlibLogging.INFO, message)
    }

    debug(message)
    {
        this.log(AhkStdlibLogging.DEBUG, message)
    }

    warning(message)
    {
        this.log(AhkStdlibLogging.WARNING, message)
    }

    error(message)
    {
        this.log(AhkStdlibLogging.ERROR, message)
    }

    critical(message)
    {
        this.log(AhkStdlibLogging.CRITICAL, message)
    }

    fatal(message)
    {
        this.log(AhkStdlibLogging.CRITICAL, message)
    }

    log(level, message)
    {
        level := AhkStdlibLoggingNormalizeLevel(level)
        if !this.isEnabledFor(level)
            return ""

        targets := this.AhkStdlibCollectHandlers()
        if targets.Length = 0 {
            if this.name = "root" {
                AhkStdlibLogging.basicConfig()
                targets := this.AhkStdlibCollectHandlers()
            } else {
                if level < AhkStdlibLogging.WARNING
                    return ""
                FileAppend AhkStdlibLoggingLogRecord(this.name, level, message).message "`n", "**", "UTF-8"
                return ""
            }
        }

        for handler in targets
            handler.emit(AhkStdlibLoggingLogRecord(this.name, level, message))
        return ""
    }

    AhkStdlibCollectHandlers()
    {
        current := this
        handlers := []
        while IsObject(current) {
            for handler in current.handlers
                handlers.Push(handler)
            if current != this && current.name = "root"
                break
            if current != this && !current.propagate
                break
            if current = this && !current.propagate
                break
            current := IsObject(current.parent) ? current.parent : ""
        }
        return handlers
    }
}

class AhkStdlibLoggingStreamHandlerClass
{
    static Call(thisClass, stream := "**")
    {
        return AhkStdlibLoggingStreamHandler(AhkStdlibLoggingNormalizeStream(stream))
    }
}

class AhkStdlibLoggingStreamHandler
{
    __New(stream)
    {
        this.stream := stream
        this.level := 0
        this.formatter := ""
    }

    setFormatter(formatter)
    {
        this.formatter := formatter
    }

    setLevel(level)
    {
        this.level := AhkStdlibLoggingNormalizeLevel(level)
    }

    flush()
    {
        if IsObject(this.stream) && HasMethod(this.stream, "Read")
            this.stream.Read(0)
        return ""
    }

    close()
    {
        this.flush()
        return ""
    }

    emit(record)
    {
        if this.level != 0 && record.levelno < this.level
            return ""
        text := IsObject(this.formatter) ? this.formatter.format(record) : record.message
        text .= "`n"
        if HasMethod(this.stream, "Write")
            this.stream.Write(text)
        else
            FileAppend text, this.stream, "UTF-8"
        this.flush()
    }
}

class AhkStdlibLoggingFileHandlerClass
{
    static Call(thisClass, filename, mode := "a", encoding := "UTF-8")
    {
        return AhkStdlibLoggingFileHandler(filename, mode, encoding)
    }
}

class AhkStdlibLoggingFileHandler extends AhkStdlibLoggingStreamHandler
{
    __New(filename, mode := "a", encoding := "UTF-8")
    {
        file := FileOpen(filename, AhkStdlibLoggingNormalizeFileMode(mode), encoding)
        super.__New(file)
        this.AhkStdlibFilename := filename
        this.AhkStdlibMode := mode
        this.AhkStdlibEncoding := encoding
    }

    close()
    {
        this.flush()
        if IsObject(this.stream) && HasMethod(this.stream, "Close")
            this.stream.Close()
        return ""
    }
}

class AhkStdlibLoggingFormatterClass
{
    static Call(thisClass, fmt := "%(levelname)s:%(name)s:%(message)s")
    {
        return AhkStdlibLoggingFormatter(AhkStdlibLoggingNormalizeFormat(fmt))
    }
}

class AhkStdlibLoggingFormatter
{
    __New(fmt := "%(levelname)s:%(name)s:%(message)s")
    {
        this._fmt := fmt
    }

    format(record)
    {
        text := this._fmt
        text := StrReplace(text, "%(levelname)s", record.levelname)
        text := StrReplace(text, "%(levelno)s", String(record.levelno))
        text := StrReplace(text, "%(name)s", record.name)
        text := StrReplace(text, "%(message)s", record.message)
        return text
    }
}

class AhkStdlibLoggingLogRecord
{
    __New(name, level, message)
    {
        this.name := name
        this.levelno := level
        this.levelname := AhkStdlibLoggingLevelName(level)
        this.message := message is String ? message : String(message)
    }
}

stdlib.logging := AhkStdlibLogging

AhkStdlibLoggingNormalizeLevel(level)
{
    if level is Integer
        return level
    if level is String {
        normalized := StrUpper(Trim(level))
        switch normalized {
            case "DEBUG":
                return AhkStdlibLogging.DEBUG
            case "INFO":
                return AhkStdlibLogging.INFO
            case "WARN":
                return AhkStdlibLogging.WARNING
            case "WARNING":
                return AhkStdlibLogging.WARNING
            case "ERROR":
                return AhkStdlibLogging.ERROR
            case "FATAL":
                return AhkStdlibLogging.CRITICAL
            case "CRITICAL":
                return AhkStdlibLogging.CRITICAL
        }
        throw ValueError("Unknown level: '" level "'", -1)
    }
    throw TypeError("level must be an integer", -1)
}

AhkStdlibLoggingLevelName(level)
{
    switch level {
        case AhkStdlibLogging.DEBUG:
            return "DEBUG"
        case AhkStdlibLogging.INFO:
            return "INFO"
        case AhkStdlibLogging.WARNING:
            return "WARNING"
        case AhkStdlibLogging.ERROR:
            return "ERROR"
        case AhkStdlibLogging.CRITICAL:
            return "CRITICAL"
    }
    return String(level)
}

AhkStdlibLoggingNormalizeStream(stream)
{
    if stream = "*"
        return FileOpen("*", "w", "UTF-8")
    if stream = "**"
        return FileOpen("**", "w", "UTF-8")
    if IsObject(stream) && HasMethod(stream, "Write")
        return stream
    throw TypeError("stream must be writable", -1)
}

AhkStdlibLoggingNormalizeFormat(formatText)
{
    if formatText is String
        return formatText
    throw TypeError("format must be a string", -1)
}

AhkStdlibLoggingNormalizeFileMode(mode)
{
    if !(mode is String)
        throw TypeError("mode must be a string", -1)
    normalized := Trim(mode)
    if normalized = "a"
        return "a"
    if normalized = "w"
        return "w"
    throw ValueError("unsupported file mode: '" mode "'", -1)
}

AhkStdlibLoggingNormalizeHandlers(handlers)
{
    if handlers is Array
        return handlers
    if IsObject(handlers) && HasMethod(handlers, "__Enum") {
        values := []
        for handler in handlers
            values.Push(handler)
        return values
    }
    throw TypeError("handlers must be iterable", -1)
}

AhkStdlibLoggingCloseHandlers(logger)
{
    for handler in logger.handlers {
        if IsObject(handler) && HasMethod(handler, "close")
            handler.close()
    }
    logger.handlers := []
}
