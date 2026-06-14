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
    static Filter := AhkStdlibLoggingFilterClass
    static NullHandler := AhkStdlibLoggingNullHandlerClass
    static LoggerAdapter := AhkStdlibLoggingLoggerAdapterClass
    static RotatingFileHandler := AhkStdlibLoggingRotatingFileHandlerClass
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
        if !this._Loggers.Has(name) {
            ; Build proper parent chain: "a.b.c" parent is the "a.b" logger, not
            ; root directly. Recursively materialize each ancestor.
            dotIdx := InStr(name, ".", , -1)
            if dotIdx > 1
                parent := this.getLogger(SubStr(name, 1, dotIdx - 1))
            else
                parent := this.Root()
            this._Loggers[name] := AhkStdlibLoggingLogger(name, 0, parent)
        }
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

class AhkStdlibLoggingFilterClass
{
    static Call(thisClass, name := "")
    {
        return AhkStdlibLoggingFilter(name)
    }
}

; Logger Filter: passes records whose .name matches the filter's name or is a
; descendant ('a.b' matches 'a.b' and 'a.b.c'). Matches CPython logging.Filter.
class AhkStdlibLoggingFilter
{
    __New(name := "")
    {
        this.name := name
        this.nlen := StrLen(name)
    }

    filter(record)
    {
        if this.nlen = 0
            return true
        if this.name = record.name
            return true
        if SubStr(record.name, 1, this.nlen) != this.name
            return false
        return SubStr(record.name, this.nlen + 1, 1) = "."
    }
}

class AhkStdlibLoggingNullHandlerClass
{
    static Call(thisClass)
    {
        return AhkStdlibLoggingNullHandler()
    }
}

; Drop-everything handler: matches CPython logging.NullHandler. handle/emit
; both return without writing anywhere.
class AhkStdlibLoggingNullHandler
{
    __New()
    {
        this.level := 0
        this.formatter := stdlib.None
        this.filters := []
    }

    setLevel(level)
    {
        this.level := level
        return ""
    }

    setFormatter(formatter)
    {
        this.formatter := formatter
        return ""
    }

    addFilter(f)
    {
        this.filters.Push(f)
        return ""
    }

    handle(record)
    {
        return ""
    }

    emit(record)
    {
        return ""
    }

    close()
    {
        return ""
    }
}

class AhkStdlibLoggingLoggerAdapterClass
{
    static Call(thisClass, logger, extra := unset)
    {
        return AhkStdlibLoggingLoggerAdapter(logger, extra?)
    }
}

; LoggerAdapter wraps a Logger and adds contextual information to every log
; call. Subclasses typically override process(msg, kwargs) to merge extra
; context. Matches CPython's logging.LoggerAdapter at the level/info/debug/...
; surface; AHK has no kwargs so 'extra' is held for the user's own logic.
class AhkStdlibLoggingLoggerAdapter
{
    __New(logger, extra := unset)
    {
        this.logger := logger
        this.extra := IsSet(extra) ? extra : Map()
    }

    setLevel(level)
    {
        this.logger.setLevel(level)
        return ""
    }

    isEnabledFor(level)
    {
        return this.logger.isEnabledFor(level)
    }

    process(msg)
    {
        ; Default: return the message unchanged. Subclasses can mix in
        ; this.extra contents (which is an arbitrary mapping).
        return msg
    }

    debug(msg)
    {
        this.logger.debug(this.process(msg))
    }

    info(msg)
    {
        this.logger.info(this.process(msg))
    }

    warning(msg)
    {
        this.logger.warning(this.process(msg))
    }

    error(msg)
    {
        this.logger.error(this.process(msg))
    }

    critical(msg)
    {
        this.logger.critical(this.process(msg))
    }

    log(level, msg)
    {
        this.logger.log(level, this.process(msg))
    }

    name
    {
        get => this.logger.name
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

class AhkStdlibLoggingRotatingFileHandlerClass
{
    static Call(thisClass, filename, mode := "a", maxBytes := 0, backupCount := 0, encoding := "UTF-8")
    {
        return AhkStdlibLoggingRotatingFileHandler(filename, mode, maxBytes, backupCount, encoding)
    }
}

; Rotating-file handler matching CPython logging.handlers.RotatingFileHandler.
; When a write would push the active log past maxBytes, the file is closed,
; renamed to "<name>.1", existing "<name>.<i>" files shift up, and the oldest
; (>backupCount) is dropped. maxBytes=0 disables rotation. Single-threaded AHK
; means we never race the rotation, but we still re-check size after each write
; so the handler behaves like Python's per-emit shouldRollover().
class AhkStdlibLoggingRotatingFileHandler extends AhkStdlibLoggingFileHandler
{
    __New(filename, mode := "a", maxBytes := 0, backupCount := 0, encoding := "UTF-8")
    {
        ; If a rollover ever happens we need append semantics so re-opens append
        ; rather than truncate the freshly-rotated active file.
        if maxBytes > 0 && mode = "w"
            mode := "a"
        super.__New(filename, mode, encoding)
        this.maxBytes := maxBytes
        this.backupCount := backupCount
    }

    emit(record)
    {
        if this.shouldRollover(record)
            this.doRollover()
        super.emit(record)
    }

    shouldRollover(record)
    {
        if this.maxBytes <= 0
            return false
        if !IsObject(this.stream)
            return false
        currentSize := this.stream.Pos
        text := IsObject(this.formatter) ? this.formatter.format(record) : record.message
        addLen := StrPut(text "`n", this.AhkStdlibEncoding) - 1
        return (currentSize + addLen) >= this.maxBytes
    }

    doRollover()
    {
        if IsObject(this.stream) && HasMethod(this.stream, "Close")
            this.stream.Close()
        this.stream := ""

        if this.backupCount > 0 {
            i := this.backupCount - 1
            while i >= 1 {
                src := this.AhkStdlibFilename "." i
                dst := this.AhkStdlibFilename "." (i + 1)
                if FileExist(src) {
                    if FileExist(dst)
                        FileDelete dst
                    FileMove src, dst, 1
                }
                i -= 1
            }
            firstBackup := this.AhkStdlibFilename ".1"
            if FileExist(this.AhkStdlibFilename) {
                if FileExist(firstBackup)
                    FileDelete firstBackup
                FileMove this.AhkStdlibFilename, firstBackup, 1
            }
        } else if FileExist(this.AhkStdlibFilename) {
            FileDelete this.AhkStdlibFilename
        }

        this.stream := FileOpen(this.AhkStdlibFilename, "w", this.AhkStdlibEncoding)
    }
}

class AhkStdlibLoggingFormatterClass
{
    static Call(thisClass, fmt := "%(levelname)s:%(name)s:%(message)s", datefmt := unset)
    {
        return AhkStdlibLoggingFormatter(AhkStdlibLoggingNormalizeFormat(fmt), datefmt?)
    }
}

class AhkStdlibLoggingFormatter
{
    __New(fmt := "%(levelname)s:%(name)s:%(message)s", datefmt := unset)
    {
        this._fmt := fmt
        this._datefmt := IsSet(datefmt) ? datefmt : ""
    }

    formatTime(record, datefmt := unset)
    {
        ; Default ISO-style: 2024-01-02 03:04:05,007 (Python's default)
        ts := record.created
        df := IsSet(datefmt) ? datefmt : (this._datefmt = "" ? "" : this._datefmt)
        if df = "" {
            ; Default: yyyy-MM-dd HH:mm:ss,msec
            base := FormatTime(ts, "yyyy-MM-dd HH:mm:ss")
            return base "," Format("{:03}", record.msecs)
        }
        return FormatTime(ts, df)
    }

    format(record)
    {
        text := this._fmt
        text := StrReplace(text, "%(levelname)s", record.levelname)
        text := StrReplace(text, "%(levelno)s", String(record.levelno))
        text := StrReplace(text, "%(name)s", record.name)
        text := StrReplace(text, "%(message)s", record.message)
        text := StrReplace(text, "%(filename)s", record.filename)
        text := StrReplace(text, "%(module)s", record.module)
        text := StrReplace(text, "%(funcName)s", record.funcName)
        text := StrReplace(text, "%(lineno)d", String(record.lineno))
        text := StrReplace(text, "%(lineno)s", String(record.lineno))
        if InStr(text, "%(asctime)s")
            text := StrReplace(text, "%(asctime)s", this.formatTime(record))
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
        this.created := A_Now
        ; AHK A_Now has no millisecond resolution; use 0 placeholder.
        this.msecs := 0
        this.filename := ""   ; AHK has no traceback at log site; left blank.
        this.module := ""
        this.funcName := ""
        this.lineno := 0
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
