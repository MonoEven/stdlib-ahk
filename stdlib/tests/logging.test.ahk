#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\logging>

class StdlibLoggingTest
{
    static TestBasicConfigAndRootLoggingFollowPython310()
    {
        stdlib.logging._resetForTests()

        AhkTest.AssertEqual(10, stdlib.logging.DEBUG)
        AhkTest.AssertEqual(20, stdlib.logging.INFO)
        AhkTest.AssertEqual(30, stdlib.logging.WARN)
        AhkTest.AssertEqual(30, stdlib.logging.WARNING)
        AhkTest.AssertEqual(40, stdlib.logging.ERROR)
        AhkTest.AssertEqual(50, stdlib.logging.FATAL)
        AhkTest.AssertEqual(50, stdlib.logging.CRITICAL)

        root := stdlib.logging.getLogger()
        AhkTest.AssertEqual("root", root.name)
        AhkTest.AssertEqual(stdlib.logging.WARNING, root.level)

        stdlib.logging.basicConfig({ stream: "*" , level: stdlib.logging.INFO })
        AhkTest.AssertEqual(stdlib.logging.INFO, root.level)
        AhkTest.AssertEqual(1, root.handlers.Length)
        AhkTest.AssertEqual("%(levelname)s:%(name)s:%(message)s", root.handlers[1].formatter._fmt)
    }

    static TestNamedLoggerUsesEffectiveLevelAndRootHandler()
    {
        stdlib.logging._resetForTests()
        buffer := stdlib.io.StringIO()
        stdlib.logging.basicConfig({ stream: buffer, level: stdlib.logging.WARNING })

        logger := stdlib.logging.getLogger("demo")
        AhkTest.AssertEqual("demo", logger.name)
        AhkTest.AssertEqual(0, logger.level)
        AhkTest.AssertFalse(logger.isEnabledFor(stdlib.logging.INFO))
        AhkTest.AssertTrue(logger.isEnabledFor(stdlib.logging.WARNING))

        logger.info("hidden info")
        AhkTest.AssertEqual("", buffer.getvalue())

        logger.warning("named warning")
        AhkTest.AssertEqual("WARNING:demo:named warning`n", buffer.getvalue())

        logger.setLevel(stdlib.logging.INFO)
        logger.info("visible info")
        AhkTest.AssertEqual("WARNING:demo:named warning`nINFO:demo:visible info`n", buffer.getvalue())
    }

    static TestLoggingAcceptsPythonLevelNamesAndRejectsUnknownNames()
    {
        stdlib.logging._resetForTests()
        buffer := stdlib.io.StringIO()
        stdlib.logging.basicConfig({ stream: buffer, level: "INFO" })

        root := stdlib.logging.getLogger()
        logger := stdlib.logging.getLogger("demo")
        AhkTest.AssertEqual(stdlib.logging.INFO, root.level)

        logger.setLevel("DEBUG")
        AhkTest.AssertEqual(stdlib.logging.DEBUG, logger.level)
        logger.debug("hello")
        AhkTest.AssertEqual("DEBUG:demo:hello`n", buffer.getvalue())

        stdlib.logging.basicConfig({ stream: stdlib.io.StringIO(), level: "NOPE" })
        AhkTest.AssertEqual(stdlib.logging.INFO, root.level)

        stdlib.logging._resetForTests()
        AhkTest.RaisesMatch(ValueError, "Unknown level: 'NOPE'", (*) => stdlib.logging.basicConfig({ stream: stdlib.io.StringIO(), level: "NOPE" }))
        AhkTest.RaisesMatch(ValueError, "Unknown level: 'NOPE'", (*) => logger.setLevel("NOPE"))
    }

    static TestLoggingSupportsWarnFatalAliasesLikePython310()
    {
        stdlib.logging._resetForTests()
        buffer := stdlib.io.StringIO()
        stdlib.logging.basicConfig({ stream: buffer, level: "WARN" })

        root := stdlib.logging.getLogger()
        logger := stdlib.logging.getLogger("demo")
        AhkTest.AssertEqual(stdlib.logging.WARNING, root.level)

        logger.setLevel("FATAL")
        AhkTest.AssertEqual(stdlib.logging.CRITICAL, logger.level)

        stdlib.logging.fatal("root fatal")
        logger.fatal("named fatal")

        AhkTest.AssertEqual("CRITICAL:root:root fatal`nCRITICAL:demo:named fatal`n", buffer.getvalue())
    }

    static TestBasicConfigAcceptsCustomFormatLikePython310()
    {
        stdlib.logging._resetForTests()
        buffer := stdlib.io.StringIO()

        stdlib.logging.basicConfig({ stream: buffer, level: "INFO", format: "%(message)s" })
        stdlib.logging.info("bare info")

        AhkTest.AssertEqual("bare info`n", buffer.getvalue())
    }

    static TestBasicConfigSupportsFilenameFilemodeAndEncodingLikePython310()
    {
        stdlib.logging._resetForTests()
        path := A_Temp "\stdlib-logging-basicconfig-file-" A_TickCount ".log"

        FileAppend "old`n", path, "UTF-8-RAW"
        try {
            stdlib.logging.basicConfig({ filename: path, filemode: "w", encoding: "UTF-8", level: "INFO", format: "%(message)s" })
            stdlib.logging.info("hello")

            root := stdlib.logging.getLogger()
            AhkTest.AssertEqual(1, root.handlers.Length)
            AhkTest.AssertEqual("AhkStdlibLoggingFileHandler", Type(root.handlers[1]))
            AhkTest.AssertEqual("%(message)s", root.handlers[1].formatter._fmt)
            AhkTest.AssertEqual(path, root.handlers[1].AhkStdlibFilename)
            AhkTest.AssertEqual("w", root.handlers[1].AhkStdlibMode)
            AhkTest.AssertEqual("UTF-8", root.handlers[1].AhkStdlibEncoding)
            AhkTest.AssertEqual("hello`n", FileRead(path, "UTF-8"))
        } finally {
            if FileExist(path)
                FileDelete path
        }
    }

    static TestBasicConfigRejectsStreamAndFilenameTogetherLikePython310()
    {
        stdlib.logging._resetForTests()
        path := A_Temp "\stdlib-logging-basicconfig-conflict-" A_TickCount ".log"

        try {
            AhkTest.RaisesMatch(ValueError, "'stream' and 'filename' should not be specified together", (*) => stdlib.logging.basicConfig({ filename: path, stream: stdlib.io.StringIO() }))
        } finally {
            if FileExist(path)
                FileDelete path
        }
    }

    static TestBasicConfigForceReplacesExistingRootStreamHandlerLikePython310()
    {
        stdlib.logging._resetForTests()
        firstBuffer := stdlib.io.StringIO()
        secondBuffer := stdlib.io.StringIO()

        stdlib.logging.basicConfig({ stream: firstBuffer, level: "WARNING", format: "%(message)s" })
        stdlib.logging.warning("old1")
        stdlib.logging.basicConfig({ stream: secondBuffer, level: "INFO", format: "%(levelname)s:%(message)s", force: true })
        stdlib.logging.info("new2")

        root := stdlib.logging.getLogger()
        AhkTest.AssertEqual("old1`n", firstBuffer.getvalue())
        AhkTest.AssertEqual("INFO:new2`n", secondBuffer.getvalue())
        AhkTest.AssertEqual(stdlib.logging.INFO, root.level)
        AhkTest.AssertEqual(1, root.handlers.Length)
        AhkTest.AssertEqual("AhkStdlibLoggingStreamHandler", Type(root.handlers[1]))
        AhkTest.AssertEqual("%(levelname)s:%(message)s", root.handlers[1].formatter._fmt)
    }

    static TestBasicConfigForceReplacesExistingRootFileHandlerLikePython310()
    {
        stdlib.logging._resetForTests()
        path := A_Temp "\stdlib-logging-basicconfig-force-file-" A_TickCount ".log"
        buffer := stdlib.io.StringIO()

        try {
            stdlib.logging.basicConfig({ filename: path, filemode: "w", encoding: "UTF-8", level: "INFO", format: "%(message)s" })
            stdlib.logging.info("file1")
            stdlib.logging.basicConfig({ stream: buffer, force: true, level: "ERROR", format: "%(message)s" })
            stdlib.logging.info("hidden")
            stdlib.logging.error("shown")

            root := stdlib.logging.getLogger()
            AhkTest.AssertEqual("file1`n", FileRead(path, "UTF-8"))
            AhkTest.AssertEqual("shown`n", buffer.getvalue())
            AhkTest.AssertEqual(stdlib.logging.ERROR, root.level)
            AhkTest.AssertEqual(1, root.handlers.Length)
            AhkTest.AssertEqual("AhkStdlibLoggingStreamHandler", Type(root.handlers[1]))
        } finally {
            if FileExist(path)
                FileDelete path
        }
    }

    static TestBasicConfigSupportsHandlersOptionLikePython310()
    {
        stdlib.logging._resetForTests()
        buffer := stdlib.io.StringIO()
        handler := stdlib.logging.StreamHandler(buffer)

        stdlib.logging.basicConfig({ handlers: [handler], level: "INFO" })
        stdlib.logging.info("hello")

        root := stdlib.logging.getLogger()
        AhkTest.AssertEqual("INFO:root:hello`n", buffer.getvalue())
        AhkTest.AssertEqual(stdlib.logging.INFO, root.level)
        AhkTest.AssertEqual(1, root.handlers.Length)
        AhkTest.AssertSame(handler, root.handlers[1])
        AhkTest.AssertEqual("%(levelname)s:%(name)s:%(message)s", root.handlers[1].formatter._fmt)
    }

    static TestBasicConfigHandlersKeepsExistingFormatterLikePython310()
    {
        stdlib.logging._resetForTests()
        buffer := stdlib.io.StringIO()
        handler := stdlib.logging.StreamHandler(buffer)
        handler.setFormatter(stdlib.logging.Formatter("%(message)s"))

        stdlib.logging.basicConfig({ handlers: [handler], level: "INFO" })
        stdlib.logging.info("plain")

        root := stdlib.logging.getLogger()
        AhkTest.AssertEqual("plain`n", buffer.getvalue())
        AhkTest.AssertSame(handler, root.handlers[1])
        AhkTest.AssertEqual("%(message)s", root.handlers[1].formatter._fmt)
    }

    static TestBasicConfigRejectsHandlersWithStreamOrFilenameLikePython310()
    {
        stdlib.logging._resetForTests()
        path := A_Temp "\stdlib-logging-basicconfig-handlers-conflict-" A_TickCount ".log"
        handler := stdlib.logging.StreamHandler(stdlib.io.StringIO())

        try {
            AhkTest.RaisesMatch(ValueError, "'stream' or 'filename' should not be specified together with 'handlers'", (*) => stdlib.logging.basicConfig({ handlers: [handler], stream: stdlib.io.StringIO() }))
            AhkTest.RaisesMatch(ValueError, "'stream' or 'filename' should not be specified together with 'handlers'", (*) => stdlib.logging.basicConfig({ handlers: [handler], filename: path }))
        } finally {
            if FileExist(path)
                FileDelete path
        }
    }

    static TestBasicConfigAcceptsTupleHandlersIterableLikePython310()
    {
        stdlib.logging._resetForTests()
        buffer := stdlib.io.StringIO()
        handler := stdlib.logging.StreamHandler(buffer)

        stdlib.logging.basicConfig({ handlers: stdlib.tuple([handler]), level: "INFO" })
        stdlib.logging.info("tuple hello")

        root := stdlib.logging.getLogger()
        AhkTest.AssertEqual("INFO:root:tuple hello`n", buffer.getvalue())
        AhkTest.AssertSame(handler, root.handlers[1])
        AhkTest.AssertEqual("%(levelname)s:%(name)s:%(message)s", root.handlers[1].formatter._fmt)
    }

    static TestBasicConfigAcceptsCustomIterableHandlersLikePython310()
    {
        stdlib.logging._resetForTests()
        buffer := stdlib.io.StringIO()
        handler := stdlib.logging.StreamHandler(buffer)

        stdlib.logging.basicConfig({ handlers: StdlibLoggingTestHandlersIterable([handler]), level: "INFO" })
        stdlib.logging.info("iter hello")

        root := stdlib.logging.getLogger()
        AhkTest.AssertEqual("INFO:root:iter hello`n", buffer.getvalue())
        AhkTest.AssertSame(handler, root.handlers[1])
        AhkTest.AssertEqual(1, root.handlers.Length)
    }

    static TestLoggingExposesFormatterAndStreamHandlerClassesLikePython310()
    {
        stdlib.logging._resetForTests()
        buffer := stdlib.io.StringIO()
        logger := stdlib.logging.getLogger("demo")
        handler := stdlib.logging.StreamHandler(buffer)
        formatter := stdlib.logging.Formatter("%(message)s")

        logger.setLevel("INFO")
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        logger.info("custom text")

        AhkTest.AssertEqual("%(message)s", formatter._fmt)
        AhkTest.AssertEqual("custom text`n", buffer.getvalue())
        AhkTest.AssertEqual(0, stdlib.logging.getLogger().handlers.Length)
    }

    static TestStreamHandlerFiltersByLevelAndFormatsLevelnoLikePython310()
    {
        stdlib.logging._resetForTests()
        buffer := stdlib.io.StringIO()
        logger := stdlib.logging.getLogger("demo")
        handler := stdlib.logging.StreamHandler(buffer)

        logger.setLevel("DEBUG")
        handler.setLevel("ERROR")
        handler.setFormatter(stdlib.logging.Formatter("%(levelno)s:%(message)s"))
        logger.addHandler(handler)

        logger.warning("hidden")
        logger.error("shown")

        AhkTest.AssertEqual(stdlib.logging.ERROR, handler.level)
        AhkTest.AssertEqual("40:shown`n", buffer.getvalue())
    }

    static TestFileHandlerAppendsAndWritesToDiskLikePython310()
    {
        stdlib.logging._resetForTests()
        path := A_Temp "\stdlib-logging-filehandler-append-" A_TickCount ".log"
        logger := stdlib.logging.getLogger("fileappend")
        handler := ""

        FileAppend "old`n", path, "UTF-8-RAW"
        try {
            handler := stdlib.logging.FileHandler(path)
            handler.setFormatter(stdlib.logging.Formatter("%(message)s"))
            logger.setLevel("INFO")
            logger.addHandler(handler)
            logger.info("new")

            AhkTest.AssertEqual("old`nnew`n", FileRead(path, "UTF-8"))
        } finally {
            if IsObject(handler)
                handler.close()
            if FileExist(path)
                FileDelete path
        }
    }

    static TestFileHandlerSupportsWriteModeAndCloseLikePython310()
    {
        stdlib.logging._resetForTests()
        path := A_Temp "\stdlib-logging-filehandler-write-" A_TickCount ".log"
        logger := stdlib.logging.getLogger("filewrite")
        handler := ""

        FileAppend "old`n", path, "UTF-8-RAW"
        try {
            handler := stdlib.logging.FileHandler(path, "w", "UTF-8")
            handler.setLevel("ERROR")
            handler.setFormatter(stdlib.logging.Formatter("%(levelno)s:%(message)s"))
            logger.setLevel("DEBUG")
            logger.addHandler(handler)
            logger.warning("hidden")
            logger.error("shown")

            AhkTest.AssertEqual("40:shown`n", FileRead(path, "UTF-8"))
        } finally {
            if IsObject(handler)
                handler.close()
            if FileExist(path)
                FileDelete path
        }
    }

    static TestNamedLoggerPropagatesToOwnAndAncestorHandlersByDefaultLikePython310()
    {
        stdlib.logging._resetForTests()
        rootBuffer := stdlib.io.StringIO()
        childBuffer := stdlib.io.StringIO()
        root := stdlib.logging.getLogger()
        logger := stdlib.logging.getLogger("pkg.child")
        rootHandler := stdlib.logging.StreamHandler(rootBuffer)
        childHandler := stdlib.logging.StreamHandler(childBuffer)

        root.setLevel("DEBUG")
        logger.setLevel("DEBUG")
        rootHandler.setFormatter(stdlib.logging.Formatter("%(name)s:%(message)s"))
        childHandler.setFormatter(stdlib.logging.Formatter("child:%(message)s"))
        root.addHandler(rootHandler)
        logger.addHandler(childHandler)

        AhkTest.AssertTrue(logger.propagate)

        logger.warning("x")

        AhkTest.AssertEqual("pkg.child:x`n", rootBuffer.getvalue())
        AhkTest.AssertEqual("child:x`n", childBuffer.getvalue())
    }

    static TestNamedLoggerCanDisablePropagationLikePython310()
    {
        stdlib.logging._resetForTests()
        rootBuffer := stdlib.io.StringIO()
        childBuffer := stdlib.io.StringIO()
        root := stdlib.logging.getLogger()
        logger := stdlib.logging.getLogger("pkg.child")
        rootHandler := stdlib.logging.StreamHandler(rootBuffer)
        childHandler := stdlib.logging.StreamHandler(childBuffer)

        root.setLevel("DEBUG")
        logger.setLevel("DEBUG")
        rootHandler.setFormatter(stdlib.logging.Formatter("%(message)s"))
        childHandler.setFormatter(stdlib.logging.Formatter("%(message)s"))
        root.addHandler(rootHandler)
        logger.addHandler(childHandler)

        logger.propagate := false
        logger.warning("y")

        AhkTest.AssertFalse(logger.propagate)
        AhkTest.AssertEqual("", rootBuffer.getvalue())
        AhkTest.AssertEqual("y`n", childBuffer.getvalue())
    }

    static TestModuleWarningUsesRootLoggerAndRejectsBadLoggerName()
    {
        stdlib.logging._resetForTests()
        buffer := stdlib.io.StringIO()
        stdlib.logging.basicConfig({ stream: buffer, level: stdlib.logging.WARNING })

        root := stdlib.logging.getLogger()
        AhkTest.AssertSame(root, stdlib.logging.getLogger(""))
        AhkTest.AssertSame(root, stdlib.logging.getLogger(stdlib.None))
        AhkTest.AssertSame(root, stdlib.logging.getLogger("root"))

        stdlib.logging.warning("root warning")
        AhkTest.AssertEqual("WARNING:root:root warning`n", buffer.getvalue())

        stdlib.logging.basicConfig({ stream: stdlib.io.StringIO(), level: stdlib.logging.ERROR })
        AhkTest.AssertEqual(stdlib.logging.WARNING, root.level)
        AhkTest.AssertEqual(1, root.handlers.Length)
        AhkTest.RaisesMatch(TypeError, "A logger name must be a string", (*) => stdlib.logging.getLogger(1))
    }

    static TestNamedLoggerWarningWithoutHandlersUsesRawStderrLikePython310()
    {
        suite := AhkTest.CreateSuite("logging named fallback")
        suite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        suite.Test("captures named warning fallback", (capture) => stdlib_logging_test_run_named_warning_without_handlers(capture), { Fixtures: ["capture"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertContains("named warning no handlers", result.Entries[1].Captured.Err)
        AhkTest.AssertNotContains("WARNING:demo:named warning no handlers", result.Entries[1].Captured.Err)
    }

    static TestModuleLoggingExposesPythonLevelHelpers()
    {
        stdlib.logging._resetForTests()
        buffer := stdlib.io.StringIO()
        stdlib.logging.basicConfig({ stream: buffer, level: stdlib.logging.WARNING })

        stdlib.logging.debug("hidden debug")
        stdlib.logging.info("hidden info")
        stdlib.logging.error("visible error")
        stdlib.logging.critical("visible critical")

        AhkTest.AssertEqual("ERROR:root:visible error`nCRITICAL:root:visible critical`n", buffer.getvalue())
    }

    static TestNamedLoggerFallbackOnlyPrintsWarningAndAboveLikePython310()
    {
        suite := AhkTest.CreateSuite("logging named fallback levels")
        suite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        suite.Test("captures named fallback levels", (capture) => stdlib_logging_test_run_named_fallback_levels(capture), { Fixtures: ["capture"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertNotContains("debug fallback", result.Entries[1].Captured.Err)
        AhkTest.AssertNotContains("info fallback", result.Entries[1].Captured.Err)
        AhkTest.AssertContains("error fallback", result.Entries[1].Captured.Err)
        AhkTest.AssertContains("critical fallback", result.Entries[1].Captured.Err)
    }

    static TestNamedHierarchyParentChainMatchesPython310()
    {
        ; getLogger("a.b.c").parent should be the "a.b" logger, not jump to root.
        stdlib.logging._resetForTests()
        c := stdlib.logging.getLogger("a.b.c")
        b := stdlib.logging.getLogger("a.b")
        a := stdlib.logging.getLogger("a")
        AhkTest.AssertSame(b, c.parent)
        AhkTest.AssertSame(a, b.parent)
        AhkTest.AssertSame(stdlib.logging.getLogger(), a.parent)
    }

    static TestFilterMatchesNameAndDescendants()
    {
        f := stdlib.logging.Filter("a.b")
        rec1 := stdlib.logging.LogRecord := unset  ; placeholder
        ; Build records by hand using the public Logger; we test the filter
        ; predicate directly.
        rec := { name: "a.b", message: "x", levelno: 20, levelname: "INFO" }
        AhkTest.AssertTrue(f.filter(rec))
        rec.name := "a.b.c"
        AhkTest.AssertTrue(f.filter(rec))
        rec.name := "a"
        AhkTest.AssertFalse(f.filter(rec))
        rec.name := "a.bc"
        AhkTest.AssertFalse(f.filter(rec))

        ; Empty filter passes everything.
        f0 := stdlib.logging.Filter()
        AhkTest.AssertTrue(f0.filter(rec))
    }

    static TestNullHandlerDropsEverything()
    {
        h := stdlib.logging.NullHandler()
        ; Should not throw on any handle/emit/close call regardless of input.
        h.handle({ name: "x", message: "y", levelno: 20, levelname: "INFO" })
        h.emit({ name: "x", message: "y", levelno: 20, levelname: "INFO" })
        h.setLevel(50)
        h.close()
        AhkTest.AssertEqual(50, h.level)
    }
}

AhkTest.Collect(StdlibLoggingTest)

stdlib_logging_test_run_named_warning_without_handlers(capture)
{
    rootDir := StrReplace(A_LineFile, "\stdlib\tests\logging.test.ahk", "")
    loggingPath := rootDir "\stdlib\logging.ahk"
    scriptPath := A_Temp "\stdlib-logging-named-fallback-" A_TickCount ".ahk"
    script :=
    (
    "#Requires AutoHotkey v2.0`n"
    "#ErrorStdOut `"UTF-8`"`n"
    "#Include `"" loggingPath "`"`n"
    "stdlib.logging._resetForTests()`n"
    "logger := stdlib.logging.getLogger(`"demo`")`n"
    "logger.warning(`"named warning no handlers`")`n"
    "FileAppend `"root-handlers:`" stdlib.logging.getLogger().handlers.Length, `"*`", `"UTF-8`"`n"
    )
    FileAppend script, scriptPath, "UTF-8"
    try {
        processResult := capture.RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", scriptPath], { Encoding: "UTF-8" })
    } finally {
        if FileExist(scriptPath)
            FileDelete scriptPath
    }

    AhkTest.AssertEqual(0, processResult.ExitCode)
    AhkTest.AssertContains("named warning no handlers", processResult.Err)
    AhkTest.AssertContains("root-handlers:0", processResult.Out)
}

stdlib_logging_test_run_named_fallback_levels(capture)
{
    rootDir := StrReplace(A_LineFile, "\stdlib\tests\logging.test.ahk", "")
    loggingPath := rootDir "\stdlib\logging.ahk"
    scriptPath := A_Temp "\stdlib-logging-fallback-levels-" A_TickCount ".ahk"
    script :=
    (
    "#Requires AutoHotkey v2.0`n"
    "#ErrorStdOut `"UTF-8`"`n"
    "#Include `"" loggingPath "`"`n"
    "stdlib.logging._resetForTests()`n"
    "logger := stdlib.logging.getLogger(`"demo`")`n"
    "logger.debug(`"debug fallback`")`n"
    "logger.info(`"info fallback`")`n"
    "logger.error(`"error fallback`")`n"
    "logger.critical(`"critical fallback`")`n"
    "FileAppend `"root-handlers:`" stdlib.logging.getLogger().handlers.Length, `"*`", `"UTF-8`"`n"
    )
    FileAppend script, scriptPath, "UTF-8"
    try {
        processResult := capture.RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", scriptPath], { Encoding: "UTF-8" })
    } finally {
        if FileExist(scriptPath)
            FileDelete scriptPath
    }

    AhkTest.AssertEqual(0, processResult.ExitCode)
    AhkTest.AssertNotContains("debug fallback", processResult.Err)
    AhkTest.AssertNotContains("info fallback", processResult.Err)
    AhkTest.AssertContains("error fallback", processResult.Err)
    AhkTest.AssertContains("critical fallback", processResult.Err)
    AhkTest.AssertContains("root-handlers:0", processResult.Out)
}

class StdlibLoggingTestHandlersIterable
{
    __New(values)
    {
        this.Values := values
    }

    __Enum(count)
    {
        return this.Values.__Enum(count)
    }
}
