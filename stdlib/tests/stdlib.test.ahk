#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\abc>
#Include <stdlib\assert>
#Include <stdlib\base64>
#Include <stdlib\base>
#Include <stdlib\types>
#Include <stdlib\operator>
#Include <stdlib\getpass>
#Include <stdlib\binascii>
#Include <stdlib\quopri>
#Include <stdlib\html>
#Include <stdlib\bisect>
#Include <stdlib\heapq>
#Include <stdlib\collections>
#Include <stdlib\itertools>
#Include <stdlib\functools>
#Include <stdlib\decimal>
#Include <stdlib\fractions>
#Include <stdlib\calendar>
#Include <stdlib\datetime>
#Include <stdlib\warnings>
#Include <stdlib\init>
#Include <stdlib\math>
#Include <stdlib\random>
#Include <stdlib\array>
#Include <stdlib\hashlib>
#Include <stdlib\hmac>
#Include <stdlib\statistics>
#Include <stdlib\comparser>
#Include <stdlib\json>
#Include <stdlib\keyword>
#Include <stdlib\fnmatch>
#Include <stdlib\glob>
#Include <stdlib\csv>
#Include <stdlib\configparser>
#Include <stdlib\io>
#Include <stdlib\logging>
#Include <stdlib\pprint>
#Include <stdlib\re>
#Include <stdlib\toml>
#Include <stdlib\os>
#Include <stdlib\platform>
#Include <stdlib\socket>
#Include <stdlib\pathlib>
#Include <stdlib\queue>
#Include <stdlib\shutil>
#Include <stdlib\tempfile>
#Include <stdlib\time>
#Include <stdlib\thread>
#Include <stdlib\asyncio>
#Include <stdlib\enum>
#Include <stdlib\copy>
#Include <stdlib\contextlib>
#Include <stdlib\uuid>
#Include <stdlib\inspect>
#Include <stdlib\secrets>
#Include <stdlib\string>
#Include <stdlib\textwrap>
#Include <stdlib\tkinter>
#Include <stdlib\pillow>

class StdlibBootstrapCounterSubclass extends AhkStdlibCollectionsCounter
{
}

class StdlibBootstrapTest
{
    static FrameworkStartsFromStdlibHarness()
    {
        AhkTest.AssertTrue(HasMethod(AhkTest, "Run"))
        AhkTest.AssertTrue(HasMethod(AhkTest, "AssertEqual"))
        AhkTest.AssertTrue(HasMethod(stdlib.base64, "b64encode"))
        AhkTest.AssertTrue(HasMethod(stdlib.getpass, "getuser"))
        AhkTest.AssertTrue(HasMethod(stdlib.binascii, "hexlify"))
        AhkTest.AssertTrue(HasMethod(stdlib.quopri, "encodestring"))
        AhkTest.AssertTrue(HasMethod(stdlib.html, "escape"))
        AhkTest.AssertTrue(HasMethod(stdlib.inspect, "isfunction"))
        AhkTest.AssertTrue(HasMethod(stdlib.inspect, "isclass"))
        AhkTest.AssertTrue(HasMethod(stdlib.secrets, "token_hex"))
        AhkTest.AssertTrue(HasMethod(stdlib.keyword, "iskeyword"))
        AhkTest.AssertTrue(HasMethod(stdlib.fnmatch, "fnmatch"))
        AhkTest.AssertTrue(HasMethod(stdlib.glob, "glob"))
        AhkTest.AssertTrue(HasMethod(stdlib.string, "capwords"))
        AhkTest.AssertTrue(HasMethod(stdlib.textwrap, "dedent"))
        AhkTest.AssertTrue(HasMethod(stdlib.thread, "Thread"))
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "Image"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.Image, "new"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.Image, "open"))
    }

    static PillowUsesStdlibNamespace()
    {
        AhkTest.AssertTrue(HasProp(stdlib, "pillow"))
        AhkTest.AssertTrue(HasProp(stdlib.pillow, "Image"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.Image, "new"))
        AhkTest.AssertTrue(HasMethod(stdlib.pillow.Image, "open"))
    }

    static AhkTestRaisesUsesAhkNaming()
    {
        err := AhkTest.Raises(ValueError, (*) => stdlib_test_raise_value_error())

        AhkTest.AssertEqual("raised for test", err.Message)
    }

    static AhkTestCreatesIsolatedSuites()
    {
        suite := AhkTest.CreateSuite("stdlib nested suite")

        suite.Test("first nested test", (*) => AhkTest.AssertEqual(3, 1 + 2))
        suite.Skip("documented missing case", "not implemented yet")
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Skipped)
        AhkTest.AssertEqual(0, result.Failed)
        AhkTest.AssertEqual(0, result.Errors)
        AhkTest.AssertEqual(0, result.ExitCode)
    }

    static AhkTestCollectsStaticTestMethods()
    {
        suite := AhkTest.CreateSuite("collector")

        suite.Collect(StdlibAhkTestCollectedCase)
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual(0, result.ExitCode)
    }

    static AhkTestRecordsManualSourceMetadata()
    {
        suite := AhkTest.CreateSuite("source metadata")
        source := { File: "manual.test.ahk", Line: 42, Kind: "function" }

        suite.Test("with explicit source", (*) => AhkTest.AssertTrue(true), { Source: source })
        result := suite.Run({ Quiet: true })
        data := result.ToMap()

        AhkTest.AssertEqual("manual.test.ahk", result.Entries[1].Source.File)
        AhkTest.AssertEqual(42, result.Entries[1].Source.Line)
        AhkTest.AssertEqual("function", data["Entries"][1]["Source"]["Kind"])
    }

    static AhkTestSourceHereRecordsFileAndLine()
    {
        suite := AhkTest.CreateSuite("source here")
        before := A_LineNumber
        source := AhkTest.SourceHere("manual")
        after := A_LineNumber

        suite.Test("with source here", (*) => AhkTest.AssertTrue(true), { Source: source })
        result := suite.Run({ Quiet: true })
        data := result.ToMap()

        AhkTest.AssertEqual(A_LineFile, result.Entries[1].Source.File)
        AhkTest.AssertTrue(result.Entries[1].Source.Line >= before)
        AhkTest.AssertTrue(result.Entries[1].Source.Line <= after)
        AhkTest.AssertEqual("manual", data["Entries"][1]["Source"]["Kind"])
        AhkTest.AssertEqual(A_LineFile, data["Entries"][1]["Source"]["File"])
    }

    static AhkTestAutoSourceRecordsSuiteTestRegistration()
    {
        suite := AhkTest.CreateSuite("auto source suite")
        before := A_LineNumber + 1
        suite.Test("with auto source", (*) => AhkTest.AssertTrue(true))
        after := A_LineNumber

        result := suite.Run({ Quiet: true })
        data := result.ToMap()

        AhkTest.AssertEqual(A_LineFile, result.Entries[1].Source.File)
        AhkTest.AssertTrue(result.Entries[1].Source.Line >= before)
        AhkTest.AssertTrue(result.Entries[1].Source.Line <= after)
        AhkTest.AssertEqual("test", result.Entries[1].Source.Kind)
        AhkTest.AssertEqual(A_LineFile, data["Entries"][1]["Source"]["File"])
        AhkTest.AssertEqual("test", data["Entries"][1]["Source"]["Kind"])
    }

    static AhkTestAutoSourceRecordsDefaultSuiteRegistration()
    {
        previousSuite := AhkTest.DefaultSuite
        AhkTest.DefaultSuite := AhkTestSuite("auto source default")
        try {
            before := A_LineNumber + 1
            AhkTest.Test("with auto source", (*) => AhkTest.AssertTrue(true))
            after := A_LineNumber

            result := AhkTest.Run({ Quiet: true })
        } finally {
            AhkTest.DefaultSuite := previousSuite
        }

        AhkTest.AssertEqual(A_LineFile, result.Entries[1].Source.File)
        AhkTest.AssertTrue(result.Entries[1].Source.Line >= before)
        AhkTest.AssertTrue(result.Entries[1].Source.Line <= after)
        AhkTest.AssertEqual("test", result.Entries[1].Source.Kind)
    }

    static AhkTestAutoSourceRecordsSkipXFailAndParametrize()
    {
        suite := AhkTest.CreateSuite("auto source outcomes")
        skipBefore := A_LineNumber + 1
        suite.Skip("skipped auto source", "not ready")
        skipAfter := A_LineNumber
        xfailBefore := A_LineNumber + 1
        suite.XFail("xfail auto source", (*) => AhkTest.Fail("known gap"), "known gap")
        xfailAfter := A_LineNumber
        paramBefore := A_LineNumber + 1
        suite.Parametrize("param auto source {1}", [[1], [2]], (value) => AhkTest.AssertTrue(value > 0))
        paramAfter := A_LineNumber

        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(4, result.Total)
        AhkTest.AssertEqual("skip", result.Entries[1].Status)
        AhkTest.AssertEqual(A_LineFile, result.Entries[1].Source.File)
        AhkTest.AssertTrue(result.Entries[1].Source.Line >= skipBefore)
        AhkTest.AssertTrue(result.Entries[1].Source.Line <= skipAfter)
        AhkTest.AssertEqual("skip", result.Entries[1].Source.Kind)
        AhkTest.AssertEqual("xfail", result.Entries[2].Status)
        AhkTest.AssertTrue(result.Entries[2].Source.Line >= xfailBefore)
        AhkTest.AssertTrue(result.Entries[2].Source.Line <= xfailAfter)
        AhkTest.AssertEqual("xfail", result.Entries[2].Source.Kind)
        AhkTest.AssertEqual("pass", result.Entries[3].Status)
        AhkTest.AssertTrue(result.Entries[3].Source.Line >= paramBefore)
        AhkTest.AssertTrue(result.Entries[3].Source.Line <= paramAfter)
        AhkTest.AssertEqual("parametrize", result.Entries[3].Source.Kind)
        AhkTest.AssertTrue(result.Entries[4].Source.Line >= paramBefore)
        AhkTest.AssertTrue(result.Entries[4].Source.Line <= paramAfter)
    }

    static AhkTestCollectRecordsClassMethodSourceMetadata()
    {
        suite := AhkTest.CreateSuite("collector source")

        suite.Collect(StdlibAhkTestCollectedCase)
        result := suite.Run({ Quiet: true })
        data := result.ToMap()

        AhkTest.AssertEqual("StdlibAhkTestCollectedCase", result.Entries[1].Source.Class)
        AhkTest.AssertEqual("TestAddsNumbers", result.Entries[1].Source.Method)
        AhkTest.AssertEqual("class", data["Entries"][1]["Source"]["Kind"])
        AhkTest.AssertEqual("TestMatchesStrings", data["Entries"][2]["Source"]["Method"])
    }

    static AhkTestReportsCollectionErrors()
    {
        suite := AhkTest.CreateSuite("collection errors")
        report := A_Temp "\ahktest-collection-errors-" A_TickCount ".txt"

        suite.Collect(StdlibAhkTestBrokenCollectedCase)
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual(2, result.ExitCode)
        AhkTest.AssertEqual("StdlibAhkTestBrokenCollectedCase.TestBroken", result.Entries[1].Name)
        AhkTest.AssertEqual("error", result.Entries[1].Status)
        AhkTest.AssertEqual("collection failure", result.Entries[1].Error.Message)
        AhkTest.AssertContains("collected test is not callable", result.Entries[1].Error.Extra)
    }

    static AhkTestCollectionErrorsUseDedicatedCollectionFailureType()
    {
        suite := AhkTest.CreateSuite("collection error type")

        suite.Collect(StdlibAhkTestBrokenCollectedCase)
        result := suite.Run({ Quiet: true })
        data := result.ToMap()
        xml := result.ToJUnitXml()

        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual(2, result.ExitCode)
        AhkTest.AssertEqual("AhkTestCollectionError", Type(result.Entries[1].Error))
        AhkTest.AssertEqual("AhkTestCollectionError", data["Entries"][1]["ErrorType"])
        AhkTest.AssertEqual("collection failure", data["Entries"][1]["ErrorMessage"])
        AhkTest.AssertContains("collected test is not callable", data["Entries"][1]["ErrorExtra"])
        AhkTest.AssertContains("<error", xml)
        AhkTest.AssertContains("message=`"collection failure`"", xml)
    }

    static AhkTestParametrizeExpandsRows()
    {
        suite := AhkTest.CreateSuite("parametrize")

        suite.Parametrize("stdlib addition case {1}", [[1, 2, 3], [5, 8, 13]], (args*) => stdlib_test_param_add(args*))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual("stdlib addition case 1", result.Entries[1].Name)
        AhkTest.AssertEqual("stdlib addition case 5", result.Entries[2].Name)
    }

    static AhkTestRaisesMatchChecksMessages()
    {
        err := AhkTest.RaisesMatch(ValueError, "raised .* test", (*) => stdlib_test_raise_value_error())

        AhkTest.AssertEqual("raised for test", err.Message)
        AhkTest.AssertThrows(AhkTestFailure, (*) => AhkTest.RaisesMatch(ValueError, "other", (*) => stdlib_test_raise_value_error()))
    }

    static AhkTestCapturesWarnings()
    {
        warnings := AhkTest.Warns("deprecated", (*) => AhkTest.Warn("deprecated path"))

        AhkTest.AssertEqual(1, warnings.Length)
        AhkTest.AssertEqual("deprecated path", warnings[1].Message)
        AhkTest.AssertThrows(AhkTestFailure, (*) => AhkTest.Warns("missing", (*) => 0))
        AhkTest.AssertThrows(AhkTestFailure, (*) => AhkTest.Warns("other", (*) => AhkTest.Warn("deprecated path")))
    }

    static AhkTestFiltersWarningsByCategory()
    {
        warnings := AhkTest.Warns("deprecated", (*) => AhkTest.Warn("deprecated path", "DeprecationWarning"), { Category: "DeprecationWarning" })

        AhkTest.AssertEqual(1, warnings.Length)
        AhkTest.AssertEqual("DeprecationWarning", warnings[1].Category)
        AhkTest.AssertThrows(AhkTestFailure, (*) => AhkTest.Warns("deprecated", (*) => AhkTest.Warn("deprecated path", "UserWarning"), { Category: "DeprecationWarning" }))
    }

    static AhkTestStoresWarningsOnResultEntries()
    {
        suite := AhkTest.CreateSuite("warning result entries")

        suite.Test("warns", (*) => AhkTest.Warn("deprecated path", "DeprecationWarning"))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Entries[1].Warnings.Length)
        AhkTest.AssertEqual("deprecated path", result.Entries[1].Warnings[1].Message)
        AhkTest.AssertEqual("DeprecationWarning", result.Entries[1].Warnings[1].Category)
        data := result.ToMap()
        AhkTest.AssertEqual("deprecated path", data["Entries"][1]["Warnings"][1]["Message"])
        AhkTest.AssertEqual("DeprecationWarning", data["Entries"][1]["Warnings"][1]["Category"])
    }

    static AhkTestWarningsRecordSourceMetadata()
    {
        callFile := A_LineFile
        callLine := A_LineNumber + 1
        warnings := AhkTest.Warns("deprecated", (*) => AhkTest.Warn("deprecated path", "DeprecationWarning"))
        warning := warnings[1]

        AhkTest.AssertEqual(callFile, warning.File)
        AhkTest.AssertTrue(warning.Line >= callLine)
        AhkTest.AssertTrue(warning.What != "")
        AhkTest.AssertTrue(warning.Stack != "")

        suite := AhkTest.CreateSuite("warning source metadata")
        suite.Test("warns", (*) => AhkTest.Warn("deprecated path", "DeprecationWarning"))
        data := suite.Run({ Quiet: true }).ToMap()
        serialized := data["Entries"][1]["Warnings"][1]

        AhkTest.AssertEqual(callFile, serialized["File"])
        AhkTest.AssertTrue(serialized["Line"] > 0)
        AhkTest.AssertTrue(serialized["What"] != "")
        AhkTest.AssertTrue(serialized["Stack"] != "")
    }

    static AhkTestResultGroupsWarningSummary()
    {
        suite := AhkTest.CreateSuite("warning summary")

        suite.Test("first warning", (*) => AhkTest.Warn("deprecated path", "DeprecationWarning"))
        suite.Test("second warning", (*) => AhkTest.Warn("deprecated path", "DeprecationWarning"))
        suite.Test("generic warning", (*) => AhkTest.Warn("check this"))
        result := suite.Run({ Quiet: true })
        summary := result.WarningSummary()

        AhkTest.AssertEqual(2, summary.Length)
        AhkTest.AssertEqual("DeprecationWarning", summary[1]["Category"])
        AhkTest.AssertEqual("deprecated path", summary[1]["Message"])
        AhkTest.AssertEqual(2, summary[1]["Count"])
        AhkTest.AssertEqual("warning", summary[2]["Category"])
        AhkTest.AssertEqual("check this", summary[2]["Message"])
        AhkTest.AssertEqual(1, summary[2]["Count"])
    }

    static AhkTestTextReportCanShowWarningSummary()
    {
        suite := AhkTest.CreateSuite("warning report")
        defaultReport := A_Temp "\ahktest-warning-default-" A_TickCount ".txt"
        summaryReport := A_Temp "\ahktest-warning-summary-" A_TickCount ".txt"

        suite.Test("first warning", (*) => AhkTest.Warn("deprecated path", "DeprecationWarning"))
        suite.Test("second warning", (*) => AhkTest.Warn("deprecated path", "DeprecationWarning"))
        try {
            suite.SetOutputFile(defaultReport)
            defaultResult := suite.Run()
            defaultOutput := FileRead(defaultReport, "UTF-8")

            suite.SetOutputFile(summaryReport)
            summaryResult := suite.Run({ WarningSummary: true })
            summaryOutput := FileRead(summaryReport, "UTF-8")
        } finally {
            if FileExist(defaultReport)
                FileDelete defaultReport
            if FileExist(summaryReport)
                FileDelete summaryReport
        }

        AhkTest.AssertEqual(2, defaultResult.Passed)
        AhkTest.AssertNotContains("Warnings:", defaultOutput)
        AhkTest.AssertEqual(2, summaryResult.Passed)
        AhkTest.AssertContains("Warnings:", summaryOutput)
        AhkTest.AssertContains("DeprecationWarning [2] deprecated path", summaryOutput)
    }

    static AhkTestWarningFiltersIgnoreMatchingWarnings()
    {
        suite := AhkTest.CreateSuite("warning filters ignore")
        suite.Configure({ WarningFilters: [{ Action: "ignore", Message: "deprecated", Category: "DeprecationWarning" }] })

        suite.Test("ignored warning", (*) => AhkTest.Warn("deprecated path", "DeprecationWarning"))
        suite.Test("kept warning", (*) => AhkTest.Warn("other path", "DeprecationWarning"))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertFalse(HasProp(result.Entries[1], "Warnings"))
        AhkTest.AssertEqual(1, result.Entries[2].Warnings.Length)
        AhkTest.AssertEqual("other path", result.Entries[2].Warnings[1].Message)
    }

    static AhkTestWarningFiltersErrorMatchingWarnings()
    {
        suite := AhkTest.CreateSuite("warning filters error")

        suite.Test("warning as error", (*) => AhkTest.Warn("deprecated path", "DeprecationWarning"))
        result := suite.Run({ Quiet: true, WarningFilters: [{ Action: "error", Category: "DeprecationWarning" }] })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual("error", result.Entries[1].Status)
        AhkTest.AssertContains("deprecated path", result.Entries[1].Error.Message)
    }

    static AhkTestWarnsCapturesDespiteErrorFilters()
    {
        suite := AhkTest.CreateSuite("warning filters nested capture")
        suite.Configure({ WarningFilters: [{ Action: "error", Category: "DeprecationWarning" }] })

        suite.Test("local warning capture", (*) => StdlibBootstrapTest.WarningFilterLocalWarnsCapture())
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(0, result.Errors)
    }

    static AhkTestWarningFilterRunOptionsOverrideConfig()
    {
        suite := AhkTest.CreateSuite("warning filter override")
        suite.Configure({ WarningFilters: [{ Action: "ignore", Category: "DeprecationWarning" }] })
        suite.Test("configured warning", (*) => AhkTest.Warn("deprecated path", "DeprecationWarning"))

        overrideResult := suite.Run({ Quiet: true, WarningFilters: [{ Action: "error", Category: "DeprecationWarning" }] })
        configuredResult := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, overrideResult.Errors)
        AhkTest.AssertEqual("error", overrideResult.Entries[1].Status)
        AhkTest.AssertEqual(1, configuredResult.Passed)
        AhkTest.AssertFalse(HasProp(configuredResult.Entries[1], "Warnings"))
    }

    static AhkTestWarningFilterLastMatchWins()
    {
        suite := AhkTest.CreateSuite("warning filter last match")
        filters := [
            { Action: "ignore", Category: "DeprecationWarning" },
            { Action: "error", Message: "critical", Category: "DeprecationWarning" },
            { Action: "default", Message: "ordinary", Category: "DeprecationWarning" }
        ]

        suite.Test("ignored warning", (*) => AhkTest.Warn("legacy path", "DeprecationWarning"))
        suite.Test("critical warning", (*) => AhkTest.Warn("critical path", "DeprecationWarning"))
        suite.Test("ordinary warning", (*) => AhkTest.Warn("ordinary path", "DeprecationWarning"))
        result := suite.Run({ Quiet: true, WarningFilters: filters })

        AhkTest.AssertEqual(3, result.Total)
        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual("pass", result.Entries[1].Status)
        AhkTest.AssertFalse(HasProp(result.Entries[1], "Warnings"))
        AhkTest.AssertEqual("error", result.Entries[2].Status)
        AhkTest.AssertEqual("pass", result.Entries[3].Status)
        AhkTest.AssertEqual(1, result.Entries[3].Warnings.Length)
        AhkTest.AssertEqual("ordinary path", result.Entries[3].Warnings[1].Message)
    }

    static AhkTestWarningFilterValidatesShape()
    {
        suite := AhkTest.CreateSuite("warning filter validation")

        AhkTest.AssertThrows(TypeError, (*) => suite.Configure({ WarningFilters: "ignore" }))
        AhkTest.AssertThrows(ValueError, (*) => suite.Configure({ WarningFilters: [{ Category: "DeprecationWarning" }] }))
        AhkTest.AssertThrows(ValueError, (*) => suite.Configure({ WarningFilters: [{ Action: "explode" }] }))
        AhkTest.AssertThrows(ValueError, (*) => suite.Run({ Quiet: true, WarningFilters: [{ Action: "ignore", Line: -1 }] }))
    }

    static AhkTestWarningFilterDefaultDeduplicatesExactLocation()
    {
        suite := AhkTest.CreateSuite("warning filter default duplicate")

        suite.Test("same warning site", (*) => StdlibBootstrapTest.WarningFilterRepeatSameSite())
        result := suite.Run({ Quiet: true, WarningFilters: [{ Action: "default", Category: "DeprecationWarning" }] })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Entries[1].Warnings.Length)
    }

    static AhkTestWarningFilterAlwaysKeepsDuplicates()
    {
        suite := AhkTest.CreateSuite("warning filter always duplicate")

        suite.Test("same warning site", (*) => StdlibBootstrapTest.WarningFilterRepeatSameSite())
        result := suite.Run({ Quiet: true, WarningFilters: [{ Action: "always", Category: "DeprecationWarning" }] })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(2, result.Entries[1].Warnings.Length)
    }

    static AhkTestWarningFilterOnceDeduplicatesAcrossLocations()
    {
        suite := AhkTest.CreateSuite("warning filter once duplicate")

        suite.Test("two warning sites", (*) => StdlibBootstrapTest.WarningFilterTwoSites())
        result := suite.Run({ Quiet: true, WarningFilters: [{ Action: "once", Category: "DeprecationWarning" }] })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Entries[1].Warnings.Length)
    }

    static AhkTestWarningFilterSourceDeduplicatesAcrossLines()
    {
        suite := AhkTest.CreateSuite("warning filter source duplicate")

        suite.Test("two warning sites", (*) => StdlibBootstrapTest.WarningFilterTwoSites())
        result := suite.Run({ Quiet: true, WarningFilters: [{ Action: "source", Category: "DeprecationWarning" }] })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Entries[1].Warnings.Length)
    }

    static WarningFilterRepeatSameSite()
    {
        Loop 2
            AhkTest.Warn("repeat path", "DeprecationWarning")
    }

    static WarningFilterTwoSites()
    {
        AhkTest.Warn("repeat path", "DeprecationWarning")
        AhkTest.Warn("repeat path", "DeprecationWarning")
    }

    static WarningFilterLocalWarnsCapture()
    {
        warnings := AhkTest.Warns("deprecated", (*) => AhkTest.Warn("deprecated path", "DeprecationWarning"), { Category: "DeprecationWarning" })
        AhkTest.AssertEqual(1, warnings.Length)
        AhkTest.AssertEqual("deprecated path", warnings[1].Message)
    }

    static AhkTestCapturesCooperativeStdoutAndStderr()
    {
        suite := AhkTest.CreateSuite("capture output")

        suite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        suite.Test("captures output", (capture) => stdlib_test_write_captured_output(capture), { Fixtures: ["capture"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
    }

    static AhkTestStoresCapturedOutputOnResultEntries()
    {
        suite := AhkTest.CreateSuite("capture result entries")

        suite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        suite.Test("captures output on entry", (capture) => stdlib_test_write_unread_captured_output(capture), { Fixtures: ["capture"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual("stdout text", result.Entries[1].Captured.Out)
        AhkTest.AssertEqual("stderr text", result.Entries[1].Captured.Err)
        data := result.ToMap()
        AhkTest.AssertEqual("stdout text", data["Entries"][1]["Captured"]["Out"])
        AhkTest.AssertEqual("stderr text", data["Entries"][1]["Captured"]["Err"])
    }

    static AhkTestReportsCapturedOutputForFailures()
    {
        suite := AhkTest.CreateSuite("capture report")
        report := A_Temp "\ahktest-capture-report-" A_TickCount ".txt"

        suite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        suite.Test("fails with captured output", (capture) => stdlib_test_fail_with_captured_output(capture), { Fixtures: ["capture"] })
        suite.SetOutputFile(report)
        try {
            result := suite.Run()
            text := FileRead(report, "UTF-8")
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertContains("captured stdout", text)
        AhkTest.AssertContains("stdout before failure", text)
        AhkTest.AssertContains("captured stderr", text)
        AhkTest.AssertContains("stderr before failure", text)
    }

    static AhkTestCanSuppressCapturedOutputReports()
    {
        suite := AhkTest.CreateSuite("capture report policy")
        report := A_Temp "\ahktest-capture-report-none-" A_TickCount ".txt"

        suite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        suite.Test("fails with captured output", (capture) => stdlib_test_fail_with_captured_output(capture), { Fixtures: ["capture"] })
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ CaptureReport: "none" })
            text := FileRead(report, "UTF-8")
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual("stdout before failure", result.Entries[1].Captured.Out)
        AhkTest.AssertEqual("stderr before failure", result.Entries[1].Captured.Err)
        AhkTest.AssertContains("captured failure", text)
        AhkTest.AssertNotContains("captured stdout", text)
        AhkTest.AssertNotContains("stdout before failure", text)
        AhkTest.AssertNotContains("captured stderr", text)
        AhkTest.AssertNotContains("stderr before failure", text)
    }

    static AhkTestCanSelectCapturedOutputReportStreams()
    {
        stdoutSuite := AhkTest.CreateSuite("capture stdout report policy")
        stdoutReport := A_Temp "\ahktest-capture-report-stdout-" A_TickCount ".txt"
        stderrSuite := AhkTest.CreateSuite("capture stderr report policy")
        stderrReport := A_Temp "\ahktest-capture-report-stderr-" A_TickCount ".txt"

        stdoutSuite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        stdoutSuite.Test("fails with captured output", (capture) => stdlib_test_fail_with_captured_output(capture), { Fixtures: ["capture"] })
        stdoutSuite.SetOutputFile(stdoutReport)
        stderrSuite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        stderrSuite.Test("fails with captured output", (capture) => stdlib_test_fail_with_captured_output(capture), { Fixtures: ["capture"] })
        stderrSuite.SetOutputFile(stderrReport)
        try {
            stdoutResult := stdoutSuite.Run({ CaptureReport: "stdout" })
            stdoutText := FileRead(stdoutReport, "UTF-8")
            stderrResult := stderrSuite.Run({ CaptureReport: "stderr" })
            stderrText := FileRead(stderrReport, "UTF-8")
        } finally {
            if FileExist(stdoutReport)
                FileDelete stdoutReport
            if FileExist(stderrReport)
                FileDelete stderrReport
        }

        AhkTest.AssertEqual(1, stdoutResult.Failed)
        AhkTest.AssertEqual("stdout before failure", stdoutResult.Entries[1].Captured.Out)
        AhkTest.AssertEqual("stderr before failure", stdoutResult.Entries[1].Captured.Err)
        AhkTest.AssertContains("captured stdout", stdoutText)
        AhkTest.AssertContains("stdout before failure", stdoutText)
        AhkTest.AssertNotContains("captured stderr", stdoutText)
        AhkTest.AssertNotContains("stderr before failure", stdoutText)

        AhkTest.AssertEqual(1, stderrResult.Failed)
        AhkTest.AssertEqual("stdout before failure", stderrResult.Entries[1].Captured.Out)
        AhkTest.AssertEqual("stderr before failure", stderrResult.Entries[1].Captured.Err)
        AhkTest.AssertNotContains("captured stdout", stderrText)
        AhkTest.AssertNotContains("stdout before failure", stderrText)
        AhkTest.AssertContains("captured stderr", stderrText)
        AhkTest.AssertContains("stderr before failure", stderrText)
    }

    static AhkTestCanReportAllCapturedOutput()
    {
        suite := AhkTest.CreateSuite("capture all report policy")
        report := A_Temp "\ahktest-capture-report-all-" A_TickCount ".txt"

        suite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        suite.Test("fails with captured output", (capture) => stdlib_test_fail_with_captured_output(capture), { Fixtures: ["capture"] })
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ CaptureReport: "all" })
            text := FileRead(report, "UTF-8")
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual("stdout before failure", result.Entries[1].Captured.Out)
        AhkTest.AssertEqual("stderr before failure", result.Entries[1].Captured.Err)
        AhkTest.AssertContains("captured stdout", text)
        AhkTest.AssertContains("stdout before failure", text)
        AhkTest.AssertContains("captured stderr", text)
        AhkTest.AssertContains("stderr before failure", text)
    }

    static AhkTestValidatesReportRunOptionValues()
    {
        tracebackSuite := AhkTest.CreateSuite("invalid traceback option")
        captureSuite := AhkTest.CreateSuite("invalid capture report option")
        defaultsSuite := AhkTest.CreateSuite("invalid report defaults")

        tracebackSuite.Test("passes", (*) => AhkTest.AssertTrue(true))
        captureSuite.Test("passes", (*) => AhkTest.AssertTrue(true))

        tracebackError := AhkTest.Raises(ValueError, (*) => tracebackSuite.Run({ Quiet: true, Traceback: "verbose" }))
        captureError := AhkTest.Raises(ValueError, (*) => captureSuite.Run({ Quiet: true, CaptureReport: "combined" }))
        defaultTracebackError := AhkTest.Raises(ValueError, (*) => defaultsSuite.Configure({ AhkRunDefaults: { Traceback: "verbose" } }))
        defaultCaptureError := AhkTest.Raises(ValueError, (*) => defaultsSuite.Configure({ AhkRunDefaults: { CaptureReport: "combined" } }))
        defaultWarningFilterError := AhkTest.Raises(ValueError, (*) => defaultsSuite.Configure({ AhkRunDefaults: { WarningFilters: [{ Category: "DeprecationWarning" }] } }))

        AhkTest.AssertContains("invalid Traceback option: verbose", tracebackError.Message)
        AhkTest.AssertContains("invalid CaptureReport option: combined", captureError.Message)
        AhkTest.AssertContains("invalid AhkRunDefaults Traceback option: verbose", defaultTracebackError.Message)
        AhkTest.AssertContains("invalid AhkRunDefaults CaptureReport option: combined", defaultCaptureError.Message)
        AhkTest.AssertContains("warning filter action is required", defaultWarningFilterError.Message)
    }

    static AhkTestCapturesChildProcessStdoutAndStderr()
    {
        suite := AhkTest.CreateSuite("capture child process")

        suite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        suite.Test("captures child process output", (capture) => stdlib_test_capture_child_process_output(capture), { Fixtures: ["capture"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertContains("child stdout", result.Entries[1].Captured.Out)
        AhkTest.AssertContains("child stderr", result.Entries[1].Captured.Err)
    }

    static AhkTestCapturesChildProcessArgsSafely()
    {
        suite := AhkTest.CreateSuite("capture child process args")

        suite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        suite.Test("captures child process args", (capture) => stdlib_test_capture_child_process_args(capture), { Fixtures: ["capture"] })
        result := suite.Run({ Quiet: true })
        diagnostic := result.Entries.Length > 0 && HasProp(result.Entries[1], "Error") ? result.Entries[1].Error.Message : ""

        AhkTest.AssertEqual(0, result.Errors, diagnostic)
        AhkTest.AssertEqual(0, result.Failed, diagnostic)
        AhkTest.AssertEqual(1, result.Passed, diagnostic)
        AhkTest.AssertContains("alpha beta", result.Entries[1].Captured.Out)
        AhkTest.AssertContains("literal & value", result.Entries[1].Captured.Out)
        AhkTest.AssertContains("literal %PATH% value", result.Entries[1].Captured.Out)
        AhkTest.AssertContains("stderr:literal & value", result.Entries[1].Captured.Err)
    }

    static AhkTestCaptureRunArgsTimesOutChildProcesses()
    {
        suite := AhkTest.CreateSuite("capture child process timeout")

        suite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        suite.Test("times out child process", (capture) => stdlib_test_capture_child_process_timeout(capture), { Fixtures: ["capture"] })
        result := suite.Run({ Quiet: true })
        diagnostic := result.Entries.Length > 0 && HasProp(result.Entries[1], "Error") ? result.Entries[1].Error.Message : ""

        AhkTest.AssertEqual(0, result.Errors, diagnostic)
        AhkTest.AssertEqual(0, result.Failed, diagnostic)
        AhkTest.AssertEqual(1, result.Passed, diagnostic)
        AhkTest.AssertContains("capture process timed out after 0.05s", result.Entries[1].Captured.Err)
    }

    static AhkTestCaptureRunArgsWaitsForGuiChildProcess()
    {
        suite := AhkTest.CreateSuite("capture child process wait")

        suite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        suite.Test("waits for child process", (capture) => stdlib_test_capture_child_process_waits(capture), { Fixtures: ["capture"] })
        result := suite.Run({ Quiet: true })
        diagnostic := result.Entries.Length > 0 && HasProp(result.Entries[1], "Error") ? result.Entries[1].Error.Message : ""

        AhkTest.AssertEqual(0, result.Errors, diagnostic)
        AhkTest.AssertEqual(0, result.Failed, diagnostic)
        AhkTest.AssertEqual(1, result.Passed, diagnostic)
        AhkTest.AssertContains("stdout:waited", result.Entries[1].Captured.Out)
    }

    static AhkTestCaptureRunArgsDrainsLargeOutput()
    {
        suite := AhkTest.CreateSuite("capture child process large output")

        suite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        suite.Test("drains large child process output", (capture) => stdlib_test_capture_child_process_large_output(capture), { Fixtures: ["capture"] })
        result := suite.Run({ Quiet: true })
        diagnostic := result.Entries.Length > 0 && HasProp(result.Entries[1], "Error") ? result.Entries[1].Error.Message : ""

        AhkTest.AssertEqual(0, result.Errors, diagnostic)
        AhkTest.AssertEqual(0, result.Failed, diagnostic)
        AhkTest.AssertEqual(1, result.Passed, diagnostic)
        AhkTest.AssertContains("stdout-2048:", result.Entries[1].Captured.Out)
        AhkTest.AssertContains("stderr-2048:", result.Entries[1].Captured.Err)
    }

    static AhkTestCaptureRunArgsDecodesConfiguredEncoding()
    {
        suite := AhkTest.CreateSuite("capture child process encoding")

        suite.Fixture("capture", (*) => AhkTest.CaptureFixture())
        suite.Test("decodes child process output encoding", (capture) => stdlib_test_capture_child_process_encoding(capture), { Fixtures: ["capture"] })
        result := suite.Run({ Quiet: true })
        diagnostic := result.Entries.Length > 0 && HasProp(result.Entries[1], "Error") ? result.Entries[1].Error.Message : ""

        AhkTest.AssertEqual(0, result.Errors, diagnostic)
        AhkTest.AssertEqual(0, result.Failed, diagnostic)
        AhkTest.AssertEqual(1, result.Passed, diagnostic)
        AhkTest.AssertContains("stdout:utf16-output", result.Entries[1].Captured.Out)
        AhkTest.AssertContains("stderr:utf16-error", result.Entries[1].Captured.Err)
    }

    static AhkTestSkipNowSkipsRunningTest()
    {
        suite := AhkTest.CreateSuite("skip now")

        suite.Test("runtime skip", (*) => AhkTest.SkipNow("not available on this platform"))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Skipped)
        AhkTest.AssertEqual("skip", result.Entries[1].Status)
        AhkTest.AssertEqual("not available on this platform", result.Entries[1].Reason)
    }

    static AhkTestTempDirCreatesAndCleansFiles()
    {
        temp := AhkTest.TempDir("stdlib-ahktest")
        try {
            filePath := temp.File("data.txt", "payload")
            nestedPath := temp.PathJoin("nested", "child.txt")

            AhkTest.AssertTrue(DirExist(temp.Path))
            AhkTest.AssertEqual("payload", FileRead(filePath, "UTF-8"))
            AhkTest.AssertEqual(temp.Path "\nested\child.txt", nestedPath)
        } finally {
            temp.Cleanup()
        }

        AhkTest.AssertFalse(DirExist(temp.Path))
    }

    static AhkTestTempPathObjectSupportsPathlibStyleOperations()
    {
        temp := AhkTest.TempDir("stdlib-ahktest-path-object")
        try {
            child := temp.Join("nested", "child.txt")

            AhkTest.AssertEqual("AhkTestPath", Type(child))
            AhkTest.AssertEqual(temp.Path "\nested\child.txt", child.Path)
            AhkTest.AssertFalse(child.Exists())

            child.WriteText("payload")

            AhkTest.AssertTrue(child.Exists())
            AhkTest.AssertFalse(child.IsDir())
            AhkTest.AssertEqual("payload", child.ReadText())
            AhkTest.AssertTrue(child.Parent().IsDir())
        } finally {
            temp.Cleanup()
        }

        AhkTest.AssertFalse(DirExist(temp.Path))
    }

    static AhkTestPathObjectExposesPathPartsAndRemovesEntries()
    {
        temp := AhkTest.TempDir("stdlib-ahktest-path-parts")
        try {
            file := temp.Join("nested", "archive.tar.gz")
            hidden := temp.Join(".env")
            directory := temp.Join("empty-dir")

            AhkTest.AssertEqual("archive.tar.gz", file.Name)
            AhkTest.AssertEqual("archive.tar", file.Stem)
            AhkTest.AssertEqual(".gz", file.Suffix)
            AhkTest.AssertEqual(".env", hidden.Name)
            AhkTest.AssertEqual(".env", hidden.Stem)
            AhkTest.AssertEqual("", hidden.Suffix)

            directory.Mkdir()
            AhkTest.AssertTrue(directory.Exists())
            AhkTest.AssertTrue(directory.IsDir())

            file.WriteText("payload")
            AhkTest.AssertTrue(file.Exists())
            file.Unlink()
            AhkTest.AssertFalse(file.Exists())

            directory.Rmdir()
            AhkTest.AssertFalse(directory.Exists())
        } finally {
            temp.Cleanup()
        }

        AhkTest.AssertFalse(DirExist(temp.Path))
    }

    static AhkTestPathMkdirAndUnlinkSupportPathlibOptions()
    {
        temp := AhkTest.TempDir("stdlib-ahktest-path-options")
        try {
            nested := temp.Join("parents", "child")
            existing := temp.Join("existing")
            missing := temp.Join("missing.txt")

            AhkTest.AssertThrows(OSError, (*) => nested.Mkdir())

            nested.Mkdir({ Parents: true })
            AhkTest.AssertTrue(nested.IsDir())

            AhkTest.AssertThrows(OSError, (*) => nested.Mkdir())
            nested.Mkdir({ ExistOk: true })
            AhkTest.AssertTrue(nested.IsDir())

            existing.Mkdir()
            existing.Mkdir({ ExistOk: true })
            AhkTest.AssertTrue(existing.IsDir())

            AhkTest.AssertThrows(Error, (*) => missing.Unlink())
            missing.Unlink({ MissingOk: true })
            AhkTest.AssertFalse(missing.Exists())
        } finally {
            temp.Cleanup()
        }

        AhkTest.AssertFalse(DirExist(temp.Path))
    }

    static AhkTestTempPathFixtureIsolatesAndCleansPerTest()
    {
        suite := AhkTest.CreateSuite("temp path fixture")
        paths := []

        suite.Fixture("tmp", (*) => AhkTest.TempPathFixture("stdlib-temp-path"))
        suite.Test("first temp path", (tmp) => stdlib_test_write_temp_path(tmp, paths, "first"), { Fixtures: ["tmp"] })
        suite.Test("second temp path", (tmp) => stdlib_test_write_temp_path(tmp, paths, "second"), { Fixtures: ["tmp"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual(2, paths.Length)
        AhkTest.AssertNotEqual(paths[1], paths[2])
        AhkTest.AssertFalse(DirExist(paths[1]))
        AhkTest.AssertFalse(DirExist(paths[2]))
    }

    static AhkTestTempPathFactoryCreatesNumberedDirectories()
    {
        suite := AhkTest.CreateSuite("temp path factory")
        captured := []

        suite.Fixture("tmp_factory", (*) => AhkTest.TempPathFactoryFixture("stdlib-temp-factory"), { Scope: "suite" })
        suite.Test("factory first use", (factory) => stdlib_test_make_temp_paths(factory, captured, "first"), { Fixtures: ["tmp_factory"] })
        suite.Test("factory second use", (factory) => stdlib_test_make_temp_paths(factory, captured, "second"), { Fixtures: ["tmp_factory"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual(4, captured.Length)
        AhkTest.AssertNotEqual(captured[1], captured[3])
        for path in captured
            AhkTest.AssertFalse(DirExist(path))
    }

    static AhkTestAssertionHelpersMirrorStdlibStyle()
    {
        AhkTest.AssertFalse(AhkTest.AreEqual(Map("a", 1), Map("a", 2)))
        AhkTest.AssertContains("stdlib", "hello stdlib")
        AhkTest.AssertContains("name", Map("name", "ahk"))
        AhkTest.AssertNotContains("missing", ["core", "text"])
        AhkTest.AssertRegex("stdlib", "^std")

        AhkTest.AssertThrows(AhkTestFailure, (*) => AhkTest.AssertContains("x", "abc"))
        AhkTest.AssertThrows(AhkTestFailure, (*) => AhkTest.AssertRegex("stdlib", "\d+"))
    }

    static AhkTestSkipIfRegistersConditionalSkips()
    {
        suite := AhkTest.CreateSuite("skip if")

        suite.SkipIf(true, "conditional skip", "condition was true")
        suite.SkipIf(false, "conditional run", (*) => AhkTest.AssertTrue(true))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Skipped)
        AhkTest.AssertEqual("condition was true", result.Entries[1].Reason)
    }

    static AhkTestExpectedFailuresAreTracked()
    {
        suite := AhkTest.CreateSuite("expected failure")

        suite.XFail("known gap", (*) => AhkTest.Fail("not implemented"), "pending stdlib behavior")
        suite.XFail("unexpected pass", (*) => AhkTest.AssertTrue(true), "should still be reported")
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(1, result.ExpectedFailures)
        AhkTest.AssertEqual(1, result.UnexpectedPasses)
        AhkTest.AssertEqual(0, result.ExitCode)
        AhkTest.AssertEqual("xfail", result.Entries[1].Status)
        AhkTest.AssertEqual("xpass", result.Entries[2].Status)
    }

    static AhkTestStrictExpectedFailuresFailOnUnexpectedPass()
    {
        suite := AhkTest.CreateSuite("strict expected failure")

        suite.XFail("strict unexpected pass", (*) => AhkTest.AssertTrue(true), "must fail until fixed", { Strict: true })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual(1, result.UnexpectedPasses)
        AhkTest.AssertEqual(1, result.ExitCode)
        AhkTest.AssertEqual("xpass", result.Entries[1].Status)
        AhkTest.AssertTrue(result.Entries[1].Strict)
    }

    static AhkTestRunXFailTreatsExpectedFailuresAsNormalTests()
    {
        suite := AhkTest.CreateSuite("run xfail")

        suite.XFail("xfail failure runs normally", (*) => AhkTest.Fail("ordinary failure"), "known issue")
        suite.XFail("xfail pass runs normally", (*) => AhkTest.AssertTrue(true), "fixed issue", { Strict: true })
        result := suite.Run({ Quiet: true, RunXFail: true })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual(0, result.ExpectedFailures)
        AhkTest.AssertEqual(0, result.UnexpectedPasses)
        AhkTest.AssertEqual("fail", result.Entries[1].Status)
        AhkTest.AssertEqual("pass", result.Entries[2].Status)
    }

    static AhkTestTextReportGroupsOutcomeReasons()
    {
        suite := AhkTest.CreateSuite("outcome reasons")
        report := A_Temp "\ahktest-outcome-reasons-" A_TickCount ".txt"

        suite.Skip("skip one", "not ready")
        suite.Skip("skip two", "not ready")
        suite.XFail("xfail known gap", (*) => AhkTest.Fail("known gap"), "known gap")
        suite.XFail("xpass known gap", (*) => AhkTest.AssertTrue(true), "known gap")
        suite.SetOutputFile(report)
        try {
            result := suite.Run()
            output := FileRead(report, "UTF-8")
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(2, result.Skipped)
        AhkTest.AssertEqual(1, result.ExpectedFailures)
        AhkTest.AssertEqual(1, result.UnexpectedPasses)
        AhkTest.AssertContains("SKIP [2] not ready", output)
        AhkTest.AssertContains("XFAIL [1] known gap", output)
        AhkTest.AssertContains("XPASS [1] known gap", output)
        AhkTest.AssertEqual("not ready", result.Entries[1].Reason)
        AhkTest.AssertEqual("known gap", result.Entries[3].Reason)
        data := result.ToMap()
        AhkTest.AssertEqual("skip", data["OutcomeReasons"][1]["Status"])
        AhkTest.AssertEqual("not ready", data["OutcomeReasons"][1]["Reason"])
        AhkTest.AssertEqual(2, data["OutcomeReasons"][1]["Count"])
        AhkTest.AssertEqual("xfail", data["OutcomeReasons"][2]["Status"])
        AhkTest.AssertEqual(1, data["OutcomeReasons"][2]["Count"])
        AhkTest.AssertEqual("xpass", data["OutcomeReasons"][3]["Status"])
        AhkTest.AssertEqual(1, data["OutcomeReasons"][3]["Count"])
    }

    static AhkTestRunSummarySelectsReportedReasons()
    {
        suite := AhkTest.CreateSuite("summary selector")
        report := A_Temp "\ahktest-summary-selector-" A_TickCount ".txt"

        suite.Skip("skip one", "not ready")
        suite.Skip("skip two", "not ready")
        suite.XFail("xfail known gap", (*) => AhkTest.Fail("known gap"), "known gap")
        suite.XFail("xpass known gap", (*) => AhkTest.AssertTrue(true), "known gap")
        suite.Test("warns", (*) => AhkTest.Warn("summary warning"))
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Summary: "s" })
            output := FileRead(report, "UTF-8")
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(2, result.Skipped)
        AhkTest.AssertEqual(1, result.ExpectedFailures)
        AhkTest.AssertEqual(1, result.UnexpectedPasses)
        AhkTest.AssertContains("SKIP [2] not ready", output)
        AhkTest.AssertNotContains("XFAIL [1] known gap", output)
        AhkTest.AssertNotContains("XPASS [1] known gap", output)
        AhkTest.AssertNotContains("Warnings:", output)
    }

    static AhkTestParametrizeAcceptsCustomIds()
    {
        suite := AhkTest.CreateSuite("parametrize ids")

        suite.Parametrize("case {id}", [
            { Id: "small", Args: [1, 2, 3] },
            { Id: "large", Args: [10, 20, 30] }
        ], (args*) => stdlib_test_param_add(args*))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual("case small", result.Entries[1].Name)
        AhkTest.AssertEqual("case large", result.Entries[2].Name)
        AhkTest.AssertEqual(2, result.Passed)
    }

    static AhkTestParametrizeStacksRows()
    {
        suite := AhkTest.CreateSuite("stacked parametrize")
        seen := []

        suite.Parametrize("pair {id}", [
            [
                { Id: "one", Args: [1] },
                { Id: "two", Args: [2] }
            ],
            [
                { Id: "ten", Args: [10] },
                { Id: "twenty", Args: [20] }
            ]
        ], (args*) => seen.Push(args[1] ":" args[2]), { Stack: true })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(4, result.Total)
        AhkTest.AssertEqual(4, result.Passed)
        AhkTest.AssertEqual(["1:10", "1:20", "2:10", "2:20"], seen)
        AhkTest.AssertEqual("pair one-ten", result.Entries[1].Name)
        AhkTest.AssertEqual("pair two-twenty", result.Entries[4].Name)
        AhkTest.AssertEqual("one-ten", result.Entries[1].ParamId)
        AhkTest.AssertEqual([1, 10], result.Entries[1].Params)
        AhkTest.AssertEqual("stacked parametrize::pair one-ten[one-ten]", result.Entries[1].NodeId)
    }

    static AhkTestParametrizeSkipsEmptyRows()
    {
        suite := AhkTest.CreateSuite("empty parametrize")

        suite.Parametrize("empty case {id}", [], (*) => AhkTest.Fail("empty parametrize should not call callback"))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Skipped)
        AhkTest.AssertEqual("empty case {id}", result.Entries[1].Name)
        AhkTest.AssertEqual("empty parameter set", result.Entries[1].Reason)
    }

    static AhkTestRunFilterAndListKeepResultsStructured()
    {
        suite := AhkTest.CreateSuite("filter")
        report := A_Temp "\ahktest-list-" A_TickCount ".txt"

        suite.Test("alpha selected", (*) => AhkTest.AssertTrue(true))
        suite.Test("beta ignored", (*) => AhkTest.Fail("filter should not run this"))
        suite.SetOutputFile(report)
        try {
            listed := suite.Run({ Filter: "alpha", List: true, Quiet: true })
            result := suite.Run({ Filter: "alpha", Quiet: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(0, listed.Total)
        AhkTest.AssertEqual(1, listed.Deselected)
        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Deselected)
        AhkTest.AssertEqual("alpha selected", result.Entries[1].Name)
        AhkTest.AssertEqual("pass", result.Entries[1].Status)
    }

    static AhkTestQuietRunSuppressesFailureOutput()
    {
        suite := AhkTest.CreateSuite("quiet failure output")
        report := A_Temp "\ahktest-quiet-failure-" A_TickCount ".txt"

        suite.Test("failing test", (*) => AhkTest.Fail("structured only"))
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
            output := FileExist(report) ? FileRead(report, "UTF-8") : ""
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual("", output)
    }

    static AhkTestResultExportsStructuredMap()
    {
        suite := AhkTest.CreateSuite("result map")
        report := A_Temp "\ahktest-result-map-" A_TickCount ".txt"

        suite.Test("passes", (*) => AhkTest.AssertTrue(true), { Marks: ["fast"] })
        suite.Test("fails", (*) => AhkTest.Fail("expected failure"))
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        data := result.ToMap()
        AhkTest.AssertEqual(2, data["Total"])
        AhkTest.AssertEqual(1, data["Passed"])
        AhkTest.AssertEqual(1, data["Failed"])
        AhkTest.AssertEqual("passes", data["Entries"][1]["Name"])
        AhkTest.AssertEqual(["fast"], data["Entries"][1]["Marks"])
        AhkTest.AssertEqual("AhkTestFailure", data["Entries"][2]["ErrorType"])
        AhkTest.AssertEqual("expected failure", data["Entries"][2]["ErrorMessage"])
    }

    static AhkTestResultExportsErrorLocationMetadata()
    {
        suite := AhkTest.CreateSuite("error metadata")
        report := A_Temp "\ahktest-error-metadata-" A_TickCount ".txt"

        suite.Test("errors", (*) => stdlib_test_raise_diagnostic_error())
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        data := result.ToMap()
        entry := data["Entries"][1]
        AhkTest.AssertEqual("ValueError", entry["ErrorType"])
        AhkTest.AssertEqual("diagnostic error", entry["ErrorMessage"])
        AhkTest.AssertContains("stdlib.test.ahk", entry["ErrorFile"])
        AhkTest.AssertTrue(entry["ErrorLine"] > 0)
        AhkTest.AssertContains("stdlib_test_raise_diagnostic_error", entry["ErrorWhat"])
        AhkTest.AssertEqual("diagnostic-extra", entry["ErrorExtra"])
        AhkTest.AssertContains("stdlib_test_raise_diagnostic_error", entry["ErrorStack"])
    }

    static AhkTestTextReportSupportsLongTraceback()
    {
        suite := AhkTest.CreateSuite("long traceback")
        report := A_Temp "\ahktest-long-traceback-" A_TickCount ".txt"

        suite.Test("errors", (*) => stdlib_test_raise_diagnostic_error())
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Traceback: "long" })
            output := FileRead(report, "UTF-8")
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertContains("Stack:", output)
        AhkTest.AssertContains("stdlib_test_raise_diagnostic_error", output)
    }

    static AhkTestTextReportSupportsNativeTraceback()
    {
        suite := AhkTest.CreateSuite("native traceback")
        report := A_Temp "\ahktest-native-traceback-" A_TickCount ".txt"

        suite.Test("errors", (*) => stdlib_test_raise_diagnostic_error())
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Traceback: "native" })
            output := FileRead(report, "UTF-8")
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertContains("diagnostic error", output)
        AhkTest.AssertContains("diagnostic-extra", output)
        AhkTest.AssertContains("Stack:", output)
        AhkTest.AssertContains("stdlib_test_raise_diagnostic_error", output)
    }

    static AhkTestTextReportSupportsAutoTraceback()
    {
        suite := AhkTest.CreateSuite("auto traceback")
        report := A_Temp "\ahktest-auto-traceback-" A_TickCount ".txt"

        suite.Test("errors", (*) => stdlib_test_raise_diagnostic_error())
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Traceback: "auto" })
            output := FileRead(report, "UTF-8")
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertContains("diagnostic error", output)
        AhkTest.AssertContains("  at ", output)
        AhkTest.AssertContains("diagnostic-extra", output)
        AhkTest.AssertNotContains("Stack:", output)
    }

    static AhkTestTextReportCanSuppressTraceback()
    {
        suite := AhkTest.CreateSuite("no traceback")
        report := A_Temp "\ahktest-no-traceback-" A_TickCount ".txt"

        suite.Test("errors", (*) => stdlib_test_raise_diagnostic_error())
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Traceback: "no" })
            output := FileRead(report, "UTF-8")
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertContains("diagnostic error", output)
        AhkTest.AssertContains("diagnostic-extra", output)
        AhkTest.AssertNotContains("  at ", output)
        AhkTest.AssertNotContains("Stack:", output)
        AhkTest.AssertNotContains("stdlib_test_raise_diagnostic_error", output)
    }

    static AhkTestTextReportSupportsLineTraceback()
    {
        suite := AhkTest.CreateSuite("line traceback")
        report := A_Temp "\ahktest-line-traceback-" A_TickCount ".txt"

        suite.Test("errors", (*) => stdlib_test_raise_diagnostic_error())
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Traceback: "line" })
            output := FileRead(report, "UTF-8")
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertRegex(output, "stdlib\.test\.ahk:\d+: ValueError: diagnostic error - diagnostic-extra")
        AhkTest.AssertNotContains("  at ", output)
        AhkTest.AssertNotContains("Stack:", output)
        AhkTest.AssertNotContains("stdlib_test_raise_diagnostic_error", output)
    }

    static AhkTestResultExportsJUnitXml()
    {
        suite := AhkTest.CreateSuite("xml & report")
        report := A_Temp "\ahktest-junit-xml-" A_TickCount ".txt"

        suite.Test("passes <one>", (*) => AhkTest.AssertTrue(true))
        suite.Test("fails", (*) => AhkTest.Fail("bad <value>"))
        suite.Skip("skipped", "not now")
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
            xml := result.ToJUnitXml()
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertContains("<testsuite", xml)
        AhkTest.AssertContains("name=`"xml &amp; report`"", xml)
        AhkTest.AssertContains("tests=`"3`"", xml)
        AhkTest.AssertContains("failures=`"1`"", xml)
        AhkTest.AssertContains("errors=`"0`"", xml)
        AhkTest.AssertContains("skipped=`"1`"", xml)
        AhkTest.AssertContains("<testcase name=`"passes &lt;one&gt;`"", xml)
        AhkTest.AssertContains("<failure type=`"AhkTestFailure`" message=`"bad &lt;value&gt;`"", xml)
        AhkTest.AssertContains("<skipped message=`"not now`"", xml)
    }

    static AhkTestResultExportsJson()
    {
        suite := AhkTest.CreateSuite("json report")
        report := A_Temp "\ahktest-json-report-" A_TickCount ".txt"

        suite.Test("passes `"quoted`"", (*) => AhkTest.AssertTrue(true), { Marks: ["fast"] })
        suite.Test("fails", (*) => AhkTest.Fail("bad \ value"))
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
            json := result.ToJson()
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertContains('"' 'Total' '":2', json)
        AhkTest.AssertContains('"' 'Passed' '":1', json)
        AhkTest.AssertContains('"' 'Failed' '":1', json)
        AhkTest.AssertContains('"' 'Name' '":"' 'passes \"quoted\"' '"', json)
        AhkTest.AssertContains('"' 'Marks' '":["fast"]', json)
        AhkTest.AssertContains('"' 'ErrorMessage' '":"' 'bad \\ value' '"', json)
    }

    static AhkTestResultWritesJsonAndJUnitFiles()
    {
        suite := AhkTest.CreateSuite("result file writers")
        report := A_Temp "\ahktest-result-files-" A_TickCount ".txt"
        dir := A_Temp "\ahktest-result-files-" A_TickCount
        jsonPath := dir "\result.json"
        xmlPath := dir "\nested\result.xml"

        suite.Test("passes", (*) => AhkTest.AssertTrue(true))
        suite.Skip("skipped", "not now")
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
            result.WriteJson(jsonPath)
            result.WriteJUnitXml(xmlPath, "custom suite")
            json := FileRead(jsonPath, "UTF-8")
            xml := FileRead(xmlPath, "UTF-8")
        } finally {
            if FileExist(report)
                FileDelete report
            if DirExist(dir)
                DirDelete dir, true
        }

        AhkTest.AssertEqual(result.ToJson(), json)
        AhkTest.AssertContains("name=`"custom suite`"", xml)
        AhkTest.AssertContains("<skipped message=`"not now`"", xml)
    }

    static AhkTestReportsDeselectedTests()
    {
        suite := AhkTest.CreateSuite("deselected")

        suite.Test("alpha fast", (*) => AhkTest.AssertTrue(true), { Marks: ["fast"] })
        suite.Test("beta slow", (*) => AhkTest.Fail("deselected test should not run"), { Marks: ["slow"] })
        suite.Test("gamma fast", (*) => AhkTest.AssertTrue(true), { Marks: ["fast"] })
        result := suite.Run({ Quiet: true, MarkFilter: "fast" })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(1, result.Deselected)
        AhkTest.AssertEqual(2, result.Passed)
    }

    static AhkTestNodeFilterSelectsExactParametrizedNodeIds()
    {
        suite := AhkTest.CreateSuite("node filter")

        suite.Parametrize("case {id}", [
            { Id: "small", Args: [1, 2, 3] },
            { Id: "large", Args: [10, 20, 30] }
        ], (args*) => stdlib_test_param_add(args*))

        result := suite.Run({ Quiet: true, NodeFilter: "node filter::case small[small]" })
        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Deselected)
        AhkTest.AssertEqual("case small", result.Entries[1].Name)
        AhkTest.AssertEqual("node filter::case small[small]", result.Entries[1].NodeId)

        both := suite.Run({ Quiet: true, NodeFilter: ["node filter::case small[small]", "node filter::case large[large]"] })
        AhkTest.AssertEqual(2, both.Total)
        AhkTest.AssertEqual(0, both.Deselected)
        AhkTest.AssertEqual("node filter::case large[large]", both.Entries[2].NodeId)
    }

    static AhkTestSupportsBooleanNameFilters()
    {
        suite := AhkTest.CreateSuite("filter expr")

        suite.Test("alpha fast", (*) => AhkTest.AssertTrue(true))
        suite.Test("alpha slow", (*) => AhkTest.Fail("filter expression should exclude slow"))
        suite.Test("beta fast", (*) => AhkTest.Fail("filter expression should exclude beta"))
        result := suite.Run({ Quiet: true, FilterExpr: "alpha and not slow" })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual("alpha fast", result.Entries[1].Name)
    }

    static AhkTestBooleanNameFiltersSupportOrAndParentheses()
    {
        suite := AhkTest.CreateSuite("filter expr grouping")

        suite.Test("alpha linux", (*) => AhkTest.AssertTrue(true))
        suite.Test("beta linux", (*) => AhkTest.AssertTrue(true))
        suite.Test("beta windows", (*) => AhkTest.Fail("grouped filter should exclude windows"))
        result := suite.Run({ Quiet: true, FilterExpr: "( alpha or beta ) and linux" })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual("alpha linux", result.Entries[1].Name)
        AhkTest.AssertEqual("beta linux", result.Entries[2].Name)
    }

    static AhkTestBooleanNameFiltersSupportQuotedPhrases()
    {
        suite := AhkTest.CreateSuite("filter quoted phrases")

        suite.Test("alpha fast path", (*) => AhkTest.AssertTrue(true))
        suite.Test("alpha slow path", (*) => AhkTest.Fail("quoted filter should exclude slow"))
        suite.Test("beta fast path", (*) => AhkTest.Fail("quoted filter should exclude beta"))
        result := suite.Run({ Quiet: true, FilterExpr: "`"alpha fast`" and not slow" })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual("alpha fast path", result.Entries[1].Name)
    }

    static AhkTestInvalidFilterExpressionsRaise()
    {
        suite := AhkTest.CreateSuite("invalid filter expr")

        suite.Test("alpha fast", (*) => AhkTest.AssertTrue(true))
        err := AhkTest.Raises(ValueError, (*) => suite.Run({ Quiet: true, FilterExpr: "alpha and" }))

        AhkTest.AssertContains("invalid filter expression", err.Message)
    }

    static AhkTestStoresAndFiltersMarkers()
    {
        suite := AhkTest.CreateSuite("markers")

        suite.Test("fast selected", (*) => AhkTest.AssertTrue(true), { Marks: ["fast", "core"] })
        suite.Test("slow ignored", (*) => AhkTest.Fail("marker filter should not run this"), { Marks: ["slow"] })
        result := suite.Run({ Quiet: true, MarkFilter: "fast" })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual("fast selected", result.Entries[1].Name)
        AhkTest.AssertEqual(["fast", "core"], result.Entries[1].Marks)
    }

    static AhkTestStoresMarkerMetadata()
    {
        suite := AhkTest.CreateSuite("marker metadata")
        data := Map("level", "smoke", "owner", "stdlib")

        suite.RegisterMark("tier", "metadata marker")
        suite.RegisterMark("fast", "plain marker")
        suite.Test("metadata selected", (*) => AhkTest.AssertTrue(true), { Marks: [AhkTest.Mark("tier", data), "fast"] })
        result := suite.Run({ Quiet: true, MarkFilter: "tier", StrictMarkers: true })
        mapped := result.ToMap()

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(["tier", "fast"], result.Entries[1].Marks)
        AhkTest.AssertEqual("tier", result.Entries[1].MarkDetails[1].Name)
        AhkTest.AssertEqual(data, result.Entries[1].MarkDetails[1].Data)
        AhkTest.AssertEqual("smoke", mapped["Entries"][1]["MarkDetails"][1]["Data"]["level"])
    }

    static AhkTestSupportsBooleanMarkerFilters()
    {
        suite := AhkTest.CreateSuite("marker expr")

        suite.Test("fast selected", (*) => AhkTest.AssertTrue(true), { Marks: ["fast"] })
        suite.Test("core selected", (*) => AhkTest.AssertTrue(true), { Marks: ["core"] })
        suite.Test("slow ignored", (*) => AhkTest.Fail("marker expression should exclude slow"), { Marks: ["fast", "slow"] })
        result := suite.Run({ Quiet: true, MarkExpr: "( fast or core ) and not slow" })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual("fast selected", result.Entries[1].Name)
        AhkTest.AssertEqual("core selected", result.Entries[2].Name)
    }

    static AhkTestParametrizeKeepsRowMarkers()
    {
        suite := AhkTest.CreateSuite("parametrize markers")

        suite.Parametrize("marked case {id}", [
            { Id: "selected", Args: [1, 1, 2], Marks: ["fast"] },
            { Id: "ignored", Args: [1, 1, 3], Marks: ["slow"] }
        ], (args*) => stdlib_test_param_add(args*))
        result := suite.Run({ Quiet: true, MarkFilter: "fast" })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual("marked case selected", result.Entries[1].Name)
        AhkTest.AssertEqual(["fast"], result.Entries[1].Marks)
    }

    static AhkTestParametrizeMergesOptionAndRowMarkers()
    {
        suite := AhkTest.CreateSuite("parametrize mark inheritance")
        data := Map("level", "core")

        suite.Parametrize("case {id}", [
            { Id: "selected", Args: [1, 1, 2], Marks: ["row"] },
            { Id: "skipped", Args: [1, 1, 3], Marks: [AhkTest.SkipMark("row skipped"), "slow"] }
        ], (args*) => stdlib_test_param_add(args*), { Marks: [AhkTest.Mark("tier", data), "base"] })
        result := suite.Run({ Quiet: true })
        mapped := result.ToMap()

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Skipped)
        AhkTest.AssertEqual(["tier", "base", "row"], result.Entries[1].Marks)
        AhkTest.AssertEqual("tier", result.Entries[1].MarkDetails[1].Name)
        AhkTest.AssertEqual("core", mapped["Entries"][1]["MarkDetails"][1]["Data"]["level"])
        AhkTest.AssertEqual("skip", result.Entries[2].Status)
        AhkTest.AssertEqual("row skipped", result.Entries[2].Reason)
        AhkTest.AssertEqual(["tier", "base", "slow"], result.Entries[2].Marks)

        stacked := AhkTest.CreateSuite("stacked mark inheritance")
        stacked.Parametrize("pair {id}", [
            [{ Id: "one", Args: [1], Marks: ["left"] }],
            [{ Id: "two", Args: [2], Marks: ["right"] }]
        ], (args*) => AhkTest.AssertEqual(3, args[1] + args[2]), { Stack: true, Marks: ["base"] })
        stackedResult := stacked.Run({ Quiet: true })

        AhkTest.AssertEqual(1, stackedResult.Passed)
        AhkTest.AssertEqual(["base", "left", "right"], stackedResult.Entries[1].Marks)
    }

    static AhkTestParametrizeExportsParameterMetadata()
    {
        suite := AhkTest.CreateSuite("param metadata")

        suite.Parametrize("case {1}", [
            { Id: "small", Args: [1, 2, 3], Marks: ["fast"] },
            [5, 8, 13]
        ], (args*) => stdlib_test_param_add(args*))
        result := suite.Run({ Quiet: true })
        data := result.ToMap()

        AhkTest.AssertEqual("small", result.Entries[1].ParamId)
        AhkTest.AssertEqual([1, 2, 3], result.Entries[1].Params)
        AhkTest.AssertEqual("param metadata::case 1[small]", result.Entries[1].NodeId)
        AhkTest.AssertEqual("5-8-13", result.Entries[2].ParamId)
        AhkTest.AssertEqual([5, 8, 13], data["Entries"][2]["Params"])
        AhkTest.AssertEqual("param metadata::case 5[5-8-13]", data["Entries"][2]["NodeId"])
    }

    static AhkTestParametrizePassesFixtureParams()
    {
        suite := AhkTest.CreateSuite("fixture parametrize")
        seen := []

        suite.Fixture("config", (ctx) => stdlib_test_fixture_from_param(ctx), { Fixtures: ["ahk_context"] })
        suite.Parametrize("case {id}", [
            { Id: "dev", Args: ["dev"], FixtureParams: Map("config", Map("mode", "dev", "port", 8080)) },
            { Id: "prod", Args: ["prod"], FixtureParams: Map("config", Map("mode", "prod", "port", 80)) }
        ], (label, config) => stdlib_test_param_fixture(label, config, seen), { Fixtures: ["config"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual(["dev:8080", "prod:80"], seen)
        AhkTest.AssertEqual("fixture parametrize::case dev[dev]", result.Entries[1].NodeId)
        AhkTest.AssertEqual("dev", result.Entries[1].ParamId)
        AhkTest.AssertEqual(["dev"], result.Entries[1].Params)
    }

    static AhkTestParametrizeStacksFixtureParams()
    {
        suite := AhkTest.CreateSuite("stacked fixture parametrize")
        seen := []

        suite.Fixture("left_config", (ctx) => stdlib_test_fixture_from_param(ctx), { Fixtures: ["ahk_context"] })
        suite.Fixture("right_config", (ctx) => stdlib_test_fixture_from_param(ctx), { Fixtures: ["ahk_context"] })
        suite.Parametrize("case {id}", [
            [
                { Id: "dev", Args: ["dev"], FixtureParams: Map("left_config", Map("mode", "dev")) }
            ],
            [
                { Id: "small", Args: ["small"], FixtureParams: Map("right_config", Map("size", "small")) }
            ]
        ], (leftLabel, rightLabel, leftConfig, rightConfig) => stdlib_test_stacked_param_fixture(leftLabel, rightLabel, leftConfig, rightConfig, seen), { Stack: true, Fixtures: ["left_config", "right_config"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(["dev:small"], seen)
        AhkTest.AssertEqual("stacked fixture parametrize::case dev-small[dev-small]", result.Entries[1].NodeId)
        AhkTest.AssertEqual(["dev", "small"], result.Entries[1].Params)
    }

    static AhkTestSkipMarksSkipDeclaredTests()
    {
        suite := AhkTest.CreateSuite("skip marks")
        ran := false

        suite.Test("skipped by mark", (*) => stdlib_test_set_flag(&ran), { Marks: [AhkTest.SkipMark("not ready"), "slow"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertFalse(ran)
        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Skipped)
        AhkTest.AssertEqual("skip", result.Entries[1].Status)
        AhkTest.AssertEqual("not ready", result.Entries[1].Reason)
        AhkTest.AssertEqual(["slow"], result.Entries[1].Marks)
    }

    static AhkTestXFailMarksTrackExpectedFailures()
    {
        suite := AhkTest.CreateSuite("xfail marks")

        suite.Test("xfails by mark", (*) => AhkTest.Fail("known issue"), { Marks: [AhkTest.XFailMark("known issue"), "core"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.ExpectedFailures)
        AhkTest.AssertEqual("xfail", result.Entries[1].Status)
        AhkTest.AssertEqual("known issue", result.Entries[1].Reason)
        AhkTest.AssertEqual(["core"], result.Entries[1].Marks)
    }

    static AhkTestStrictXFailMarksFailUnexpectedPasses()
    {
        suite := AhkTest.CreateSuite("strict xfail marks")

        suite.Test("strict xpass by mark", (*) => AhkTest.AssertTrue(true), { Marks: [AhkTest.XFailMark("must fail", { Strict: true })] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual(1, result.UnexpectedPasses)
        AhkTest.AssertEqual("xpass", result.Entries[1].Status)
        AhkTest.AssertTrue(result.Entries[1].Strict)
        AhkTest.AssertEqual("must fail", result.Entries[1].Reason)
    }

    static AhkTestStrictMarkersRequireRegistration()
    {
        suite := AhkTest.CreateSuite("strict markers")
        ran := false

        suite.RegisterMark("fast", "quick stdlib gate")
        suite.Test("known mark runs", (*) => stdlib_test_set_flag(&ran), { Marks: ["fast"] })
        suite.Test("unknown mark errors", (*) => AhkTest.Fail("unknown marked test should not run"), { Marks: ["slow"] })
        result := suite.Run({ Quiet: true, StrictMarkers: true })

        AhkTest.AssertTrue(ran)
        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual("unknown mark errors", result.Entries[2].Name)
        AhkTest.AssertEqual("error", result.Entries[2].Status)
        AhkTest.AssertEqual("unknown mark: slow", result.Entries[2].Error.Message)
    }

    static AhkTestConfigRegistersMarkers()
    {
        suite := AhkTest.CreateSuite("configured markers")
        suite.Configure({ Marks: Map("fast", "quick stdlib gate", "slow", "slow stdlib gate") })

        suite.Test("configured fast", (*) => AhkTest.AssertTrue(true), { Marks: ["fast"] })
        suite.Test("configured slow", (*) => AhkTest.AssertTrue(true), { Marks: ["slow"] })
        result := suite.Run({ Quiet: true, StrictMarkers: true })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual(0, result.Errors)
    }

    static AhkTestConfigRunDefaultsSelectByFilterExpr()
    {
        suite := AhkTest.CreateSuite("configured run defaults")
        suite.Configure({ AhkRunDefaults: { FilterExpr: "alpha" } })

        suite.Test("alpha selected", (*) => AhkTest.AssertTrue(true))
        suite.Test("beta rejected", (*) => AhkTest.Fail("run default should deselect beta"))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Deselected)
        AhkTest.AssertEqual("alpha selected", result.Entries[1].Name)
    }

    static AhkTestRunOptionsOverrideConfiguredRunDefaults()
    {
        suite := AhkTest.CreateSuite("override run defaults")
        suite.Configure({ AhkRunDefaults: { FilterExpr: "alpha" } })

        suite.Test("alpha rejected", (*) => AhkTest.Fail("explicit run option should override default"))
        suite.Test("beta selected", (*) => AhkTest.AssertTrue(true))
        result := suite.Run({ Quiet: true, FilterExpr: "beta" })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Deselected)
        AhkTest.AssertEqual("beta selected", result.Entries[1].Name)
    }

    static AhkTestConfigRunDefaultsDisableHooksById()
    {
        suite := AhkTest.CreateSuite("configured hook disable ids")
        events := []

        suite.Configure({ AhkRunDefaults: { DisableHookIds: ["disabled-hook"] } })
        suite.On("run_start", (*) => events.Push("enabled"), { Id: "enabled-hook" })
        suite.On("run_start", (*) => events.Push("disabled"), { Id: "disabled-hook" })
        suite.Test("passes", (*) => AhkTest.AssertTrue(true))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(["enabled"], events)
    }

    static AhkTestConfigRunDefaultsValidateShape()
    {
        suite := AhkTest.CreateSuite("run default validation")

        AhkTest.AssertThrows(TypeError, (*) => suite.Configure({ AhkRunDefaults: "alpha" }))
        AhkTest.AssertThrows(ValueError, (*) => suite.Configure({ AhkRunDefaults: { UnknownOption: true } }))
    }

    static AhkTestConfigRunDefaultsAcceptAutoTraceback()
    {
        suite := AhkTest.CreateSuite("configured auto traceback")
        report := A_Temp "\ahktest-config-auto-traceback-" A_TickCount ".txt"

        suite.Configure({ AhkRunDefaults: { Traceback: "auto" } })
        suite.Test("errors", (*) => stdlib_test_raise_diagnostic_error())
        suite.SetOutputFile(report)
        try {
            result := suite.Run()
            output := FileRead(report, "UTF-8")
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertContains("diagnostic error", output)
        AhkTest.AssertContains("  at ", output)
        AhkTest.AssertContains("diagnostic-extra", output)
        AhkTest.AssertNotContains("Stack:", output)
    }

    static AhkTestConfigRunDefaultsAcceptNativeTraceback()
    {
        suite := AhkTest.CreateSuite("configured native traceback")
        report := A_Temp "\ahktest-config-native-traceback-" A_TickCount ".txt"

        suite.Configure({ AhkRunDefaults: { Traceback: "native" } })
        suite.Test("errors", (*) => stdlib_test_raise_diagnostic_error())
        suite.SetOutputFile(report)
        try {
            result := suite.Run()
            output := FileRead(report, "UTF-8")
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertContains("diagnostic error", output)
        AhkTest.AssertContains("diagnostic-extra", output)
        AhkTest.AssertContains("Stack:", output)
        AhkTest.AssertContains("stdlib_test_raise_diagnostic_error", output)
    }

    static AhkTestConfigManifestRunDefaultsSelectByFilterExpr()
    {
        suite := AhkTest.CreateSuite("configured manifest run defaults")
        manifest := A_Temp "\ahktest-config-manifest-" A_TickCount ".json"

        try {
            stdlib_test_write_utf8_raw(manifest, '{`"AhkTest`":{`"AhkRunDefaults`":{`"FilterExpr`":`"alpha`"}}}')
            suite.ConfigureManifest(manifest)

            suite.Test("alpha selected", (*) => AhkTest.AssertTrue(true))
            suite.Test("beta rejected", (*) => AhkTest.Fail("manifest default should deselect beta"))
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(manifest)
                FileDelete manifest
        }

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Deselected)
        AhkTest.AssertEqual("alpha selected", result.Entries[1].Name)
    }

    static AhkTestConfigManifestNormalizesJsonBoolRunDefaults()
    {
        suite := AhkTest.CreateSuite("configured manifest bool run defaults")
        manifest := A_Temp "\ahktest-config-manifest-bool-" A_TickCount ".json"

        try {
            stdlib_test_write_utf8_raw(manifest, '{`"AhkTest`":{`"AhkRunDefaults`":{`"FilterExpr`":`"selected`",`"List`":false}}}')
            suite.ConfigureManifest(manifest)

            suite.Test("selected executes", (*) => AhkTest.AssertTrue(true))
            suite.Test("rejected default", (*) => AhkTest.Fail("manifest bool should not force list-only"))
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(manifest)
                FileDelete manifest
        }

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Deselected)
        AhkTest.AssertEqual("selected executes", result.Entries[1].Name)
    }

    static AhkTestDefaultSuiteRegistersMarkers()
    {
        name := "stdlib_default_" A_TickCount
        AhkTest.RegisterMark(name, "default suite marker")
        AhkTest.AssertEqual(name, AhkTest.RegisterMark(name, "can be re-registered"))
    }

    static AhkTestApproxMatchesReferenceToleranceRules()
    {
        AhkTest.AssertApprox(0.3, 0.1 + 0.2)
        AhkTest.AssertApprox([0.3, 1.0], [0.1 + 0.2, 1.0000001])
        AhkTest.AssertApprox(Map("a", 0.3, "b", 1.0), Map("a", 0.1 + 0.2, "b", 1.0000001))
        AhkTest.AssertApprox(1000000.0, 1000000.5)
        AhkTest.AssertApprox(1000000.0, 1000000.05, { Abs: 0.1 })

        AhkTest.AssertThrows(AhkTestFailure, (*) => AhkTest.AssertApprox(0.0, 0.00000000001))
        AhkTest.AssertThrows(AhkTestFailure, (*) => AhkTest.AssertApprox(1000000.0, 1000000.5, { Abs: 0.1 }))
    }

    static AhkTestApproxSupportsNanOk()
    {
        nan := stdlib_test_nan()

        AhkTest.AssertThrows(AhkTestFailure, (*) => AhkTest.AssertApprox(nan, nan))
        AhkTest.AssertApprox(nan, nan, { NanOk: true })
        AhkTest.AssertApprox([nan], [nan], { NanOk: true })
    }

    static AhkTestRunStopsAfterMaxFail()
    {
        suite := AhkTest.CreateSuite("max fail")
        report := A_Temp "\ahktest-maxfail-" A_TickCount ".txt"

        suite.Test("first failure", (*) => AhkTest.Fail("stop here"))
        suite.Test("second failure should not run", (*) => AhkTest.Fail("runner ignored max fail"))
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true, MaxFail: 1 })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual(1, result.Entries.Length)
        AhkTest.AssertEqual("first failure", result.Entries[1].Name)
        AhkTest.AssertEqual("fail", result.Entries[1].Status)
        AhkTest.AssertEqual(1, result.ExitCode)
    }

    static AhkTestRunExitFirstStopsAfterFirstFailure()
    {
        suite := AhkTest.CreateSuite("exit first")
        report := A_Temp "\ahktest-exit-first-" A_TickCount ".txt"

        suite.Test("first failure", (*) => AhkTest.Fail("stop here"))
        suite.Test("second failure", (*) => AhkTest.Fail("should not run"))
        suite.Test("third failure", (*) => AhkTest.Fail("should not run"))
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true, ExitFirst: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual("first failure", result.Entries[1].Name)
    }

    static AhkTestMaxFailIgnoresNonStrictUnexpectedPass()
    {
        suite := AhkTest.CreateSuite("max fail xpass")
        report := A_Temp "\ahktest-maxfail-xpass-" A_TickCount ".txt"

        suite.XFail("non strict xpass", (*) => AhkTest.AssertTrue(true), "reported only")
        suite.Test("real failure", (*) => AhkTest.Fail("stop here"))
        suite.Test("after failure", (*) => AhkTest.Fail("should not run"))
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true, MaxFail: 1 })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(1, result.UnexpectedPasses)
        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual("real failure", result.Entries[2].Name)
    }

    static AhkTestRerunsLastFailedTests()
    {
        suite := AhkTest.CreateSuite("last failed")
        report := A_Temp "\ahktest-last-failed-" A_TickCount ".txt"
        shouldFail := true

        suite.Test("passes", (*) => AhkTest.AssertTrue(true))
        suite.Test("fails once", (*) => stdlib_test_fail_until_cleared(&shouldFail))
        suite.SetOutputFile(report)
        try {
            first := suite.Run({ Quiet: true })
            shouldFail := false
            second := suite.Run({ Quiet: true, LastFailed: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual(1, second.Total)
        AhkTest.AssertEqual(1, second.Passed)
        AhkTest.AssertEqual("fails once", second.Entries[1].Name)
    }

    static AhkTestPersistsLastFailedCache()
    {
        firstSuite := AhkTest.CreateSuite("last failed cache")
        secondSuite := AhkTest.CreateSuite("last failed cache")
        report := A_Temp "\ahktest-last-failed-cache-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-last-failed-cache-" A_TickCount ".txt"

        firstSuite.Test("passes", (*) => AhkTest.AssertTrue(true))
        firstSuite.Test("fails cached", (*) => AhkTest.Fail("cached failure"))
        secondSuite.Test("passes", (*) => AhkTest.Fail("cache should deselect passing test"))
        secondSuite.Test("fails cached", (*) => AhkTest.AssertTrue(true))
        firstSuite.SetOutputFile(report)
        secondSuite.SetOutputFile(report)
        try {
            first := firstSuite.Run({ Quiet: true, LastFailedCache: cache })
            second := secondSuite.Run({ Quiet: true, LastFailed: true, LastFailedCache: cache })
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual(1, second.Total)
        AhkTest.AssertEqual(1, second.Passed)
        AhkTest.AssertEqual("fails cached", second.Entries[1].Name)
    }

    static AhkTestLastFailedCacheUsesStableNodeIds()
    {
        firstSuite := AhkTest.CreateSuite("node cache first")
        secondSuite := AhkTest.CreateSuite("node cache second")
        report := A_Temp "\ahktest-node-cache-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-node-cache-" A_TickCount ".txt"

        firstSuite.Test("same name", (*) => AhkTest.Fail("first suite failure"))
        secondSuite.Test("same name", (*) => AhkTest.Fail("same name should not match different suite"))
        firstSuite.SetOutputFile(report)
        secondSuite.SetOutputFile(report)
        try {
            first := firstSuite.Run({ Quiet: true, LastFailedCache: cache })
            second := secondSuite.Run({ Quiet: true, LastFailed: true, LastFailedCache: cache })
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual("node cache first::same name", first.Entries[1].NodeId)
        AhkTest.AssertEqual(1, second.Total)
        AhkTest.AssertEqual(1, second.Failed)
        AhkTest.AssertEqual("same name", second.Entries[1].Name)
    }

    static AhkTestLastFailedCacheDistinguishesDuplicateNamesAcrossSources()
    {
        firstSuite := AhkTest.CreateSuite()
        secondSuite := AhkTest.CreateSuite()
        report := A_Temp "\ahktest-duplicate-source-last-failed-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-duplicate-source-last-failed-cache-" A_TickCount ".txt"
        firstSource := { Kind: "test", File: "a_duplicate.test.ahk", Line: 1 }
        secondSource := { Kind: "test", File: "b_duplicate.test.ahk", Line: 1 }

        firstSuite.Test("duplicate test", (*) => AhkTest.Fail("first source failure"), { Source: firstSource })
        firstSuite.Test("duplicate test", (*) => AhkTest.AssertTrue(true), { Source: secondSource })
        secondSuite.Test("duplicate test", (*) => AhkTest.AssertTrue(true), { Source: firstSource })
        secondSuite.Test("duplicate test", (*) => AhkTest.Fail("second source should stay deselected"), { Source: secondSource })
        firstSuite.SetOutputFile(report)
        secondSuite.SetOutputFile(report)
        try {
            first := firstSuite.Run({ Quiet: true, LastFailedCache: cache })
            second := secondSuite.Run({ Quiet: true, LastFailed: true, LastFailedCache: cache })
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual(1, second.Total)
        AhkTest.AssertEqual(1, second.Passed)
        AhkTest.AssertEqual(1, second.Deselected)
        AhkTest.AssertEqual("duplicate test", second.Entries[1].Name)
        AhkTest.AssertEqual("a_duplicate.test.ahk", second.Entries[1].Source.File)
    }

    static AhkTestLastFailedCacheFallsBackToFullRunWhenCachedNodeIdsAreStale()
    {
        firstSuite := AhkTest.CreateSuite("stale last failed first")
        secondSuite := AhkTest.CreateSuite("stale last failed second")
        report := A_Temp "\ahktest-stale-last-failed-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-stale-last-failed-cache-" A_TickCount ".txt"

        firstSuite.Test("old failing name", (*) => AhkTest.Fail("cached failure"))
        secondSuite.Test("new passing name", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("other passing name", (*) => AhkTest.AssertTrue(true))
        firstSuite.SetOutputFile(report)
        secondSuite.SetOutputFile(report)
        try {
            first := firstSuite.Run({ Quiet: true, LastFailedCache: cache })
            second := secondSuite.Run({ Quiet: true, LastFailed: true, LastFailedCache: cache })
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual(2, second.Total)
        AhkTest.AssertEqual(2, second.Passed)
        AhkTest.AssertEqual(0, second.Deselected)
        AhkTest.AssertEqual("new passing name", second.Entries[1].Name)
        AhkTest.AssertEqual("other passing name", second.Entries[2].Name)
    }

    static AhkTestLastFailedNodeFilterRunsSelectedNodeOutsideCacheAndPreservesPriorCache()
    {
        firstSuite := AhkTest.CreateSuite("last failed node filter")
        secondSuite := AhkTest.CreateSuite("last failed node filter")
        report := A_Temp "\ahktest-last-failed-node-filter-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-last-failed-node-filter-cache-" A_TickCount ".txt"
        selectedNodeId := "last failed node filter::selected pass"

        firstSuite.Test("old cached failure", (*) => AhkTest.Fail("cached failure"))
        firstSuite.Test("selected pass", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("old cached failure", (*) => AhkTest.Fail("node filter should bypass cached-only selection"))
        secondSuite.Test("selected pass", (*) => AhkTest.AssertTrue(true))
        firstSuite.SetOutputFile(report)
        secondSuite.SetOutputFile(report)
        try {
            first := firstSuite.Run({ Quiet: true, LastFailedCache: cache })
            second := secondSuite.Run({ Quiet: true, LastFailed: true, LastFailedCache: cache, NodeFilter: selectedNodeId })
            secondCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual(1, second.Total)
        AhkTest.AssertEqual(1, second.Passed)
        AhkTest.AssertEqual(1, second.Deselected)
        AhkTest.AssertEqual("selected pass", second.Entries[1].Name)
        AhkTest.AssertContains("last failed node filter::old cached failure", secondCache)
    }

    static AhkTestLastFailedFilterExprRunsSelectedTestsOutsideCacheAndPreservesPriorCache()
    {
        firstSuite := AhkTest.CreateSuite("last failed filter expr")
        secondSuite := AhkTest.CreateSuite("last failed filter expr")
        report := A_Temp "\ahktest-last-failed-filter-expr-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-last-failed-filter-expr-cache-" A_TickCount ".txt"

        firstSuite.Test("old cached failure", (*) => AhkTest.Fail("cached failure"))
        firstSuite.Test("selected pass", (*) => AhkTest.AssertTrue(true))
        firstSuite.Test("other pass", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("old cached failure", (*) => AhkTest.Fail("filter expr should bypass cached-only selection"))
        secondSuite.Test("selected pass", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("other pass", (*) => AhkTest.AssertTrue(true))
        firstSuite.SetOutputFile(report)
        secondSuite.SetOutputFile(report)
        try {
            first := firstSuite.Run({ Quiet: true, LastFailedCache: cache })
            second := secondSuite.Run({ Quiet: true, LastFailed: true, LastFailedCache: cache, FilterExpr: "selected" })
            secondCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual(1, second.Total)
        AhkTest.AssertEqual(1, second.Passed)
        AhkTest.AssertEqual(2, second.Deselected)
        AhkTest.AssertEqual("selected pass", second.Entries[1].Name)
        AhkTest.AssertContains("last failed filter expr::old cached failure", secondCache)
    }

    static AhkTestLastFailedNodeFilterAddsNewFailingSelectionToExistingCache()
    {
        firstSuite := AhkTest.CreateSuite("last failed node filter update")
        secondSuite := AhkTest.CreateSuite("last failed node filter update")
        report := A_Temp "\ahktest-last-failed-node-filter-update-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-last-failed-node-filter-update-cache-" A_TickCount ".txt"
        selectedNodeId := "last failed node filter update::selected failure"

        firstSuite.Test("old cached failure", (*) => AhkTest.Fail("cached failure"))
        firstSuite.Test("selected failure", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("old cached failure", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("selected failure", (*) => AhkTest.Fail("new selected failure"))
        firstSuite.SetOutputFile(report)
        secondSuite.SetOutputFile(report)
        try {
            first := firstSuite.Run({ Quiet: true, LastFailedCache: cache })
            second := secondSuite.Run({ Quiet: true, LastFailed: true, LastFailedCache: cache, NodeFilter: selectedNodeId })
            secondCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual(1, second.Total)
        AhkTest.AssertEqual(1, second.Failed)
        AhkTest.AssertEqual(1, second.Deselected)
        AhkTest.AssertEqual("selected failure", second.Entries[1].Name)
        AhkTest.AssertContains("last failed node filter update::old cached failure", secondCache)
        AhkTest.AssertContains("last failed node filter update::selected failure", secondCache)
    }

    static AhkTestLastFailedNodeFilterArrayRunsSelectedNodesOutsideCacheAndPreservesPriorCache()
    {
        firstSuite := AhkTest.CreateSuite("last failed node filter array")
        secondSuite := AhkTest.CreateSuite("last failed node filter array")
        report := A_Temp "\ahktest-last-failed-node-filter-array-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-last-failed-node-filter-array-cache-" A_TickCount ".txt"
        selectedNodeIds := [
            "last failed node filter array::selected pass one",
            "last failed node filter array::selected pass two"
        ]

        firstSuite.Test("old cached failure", (*) => AhkTest.Fail("cached failure"))
        firstSuite.Test("selected pass one", (*) => AhkTest.AssertTrue(true))
        firstSuite.Test("selected pass two", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("old cached failure", (*) => AhkTest.Fail("node filter array should bypass cached-only selection"))
        secondSuite.Test("selected pass one", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("selected pass two", (*) => AhkTest.AssertTrue(true))
        firstSuite.SetOutputFile(report)
        secondSuite.SetOutputFile(report)
        try {
            first := firstSuite.Run({ Quiet: true, LastFailedCache: cache })
            second := secondSuite.Run({ Quiet: true, LastFailed: true, LastFailedCache: cache, NodeFilter: selectedNodeIds })
            secondCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual(2, second.Total)
        AhkTest.AssertEqual(2, second.Passed)
        AhkTest.AssertEqual(1, second.Deselected)
        AhkTest.AssertEqual("selected pass one", second.Entries[1].Name)
        AhkTest.AssertEqual("selected pass two", second.Entries[2].Name)
        AhkTest.AssertContains("last failed node filter array::old cached failure", secondCache)
    }

    static AhkTestLastFailedNodeFilterArrayAddsNewFailingSelectionToExistingCache()
    {
        firstSuite := AhkTest.CreateSuite("last failed node filter array update")
        secondSuite := AhkTest.CreateSuite("last failed node filter array update")
        report := A_Temp "\ahktest-last-failed-node-filter-array-update-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-last-failed-node-filter-array-update-cache-" A_TickCount ".txt"
        selectedNodeIds := [
            "last failed node filter array update::selected pass",
            "last failed node filter array update::selected failure"
        ]

        firstSuite.Test("old cached failure", (*) => AhkTest.Fail("cached failure"))
        firstSuite.Test("selected pass", (*) => AhkTest.AssertTrue(true))
        firstSuite.Test("selected failure", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("old cached failure", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("selected pass", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("selected failure", (*) => AhkTest.Fail("new selected failure"))
        firstSuite.SetOutputFile(report)
        secondSuite.SetOutputFile(report)
        try {
            first := firstSuite.Run({ Quiet: true, LastFailedCache: cache })
            second := secondSuite.Run({ Quiet: true, LastFailed: true, LastFailedCache: cache, NodeFilter: selectedNodeIds })
            secondCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual(2, second.Total)
        AhkTest.AssertEqual(1, second.Passed)
        AhkTest.AssertEqual(1, second.Failed)
        AhkTest.AssertEqual(1, second.Deselected)
        AhkTest.AssertEqual("selected pass", second.Entries[1].Name)
        AhkTest.AssertEqual("selected failure", second.Entries[2].Name)
        AhkTest.AssertContains("last failed node filter array update::old cached failure", secondCache)
        AhkTest.AssertContains("last failed node filter array update::selected failure", secondCache)
    }

    static AhkTestLastFailedNodeFilterArrayKeepsCachedIntersectionWhenMixedSelectionIncludesCachedNode()
    {
        firstSuite := AhkTest.CreateSuite("last failed node filter array mixed")
        secondSuite := AhkTest.CreateSuite("last failed node filter array mixed")
        report := A_Temp "\ahktest-last-failed-node-filter-array-mixed-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-last-failed-node-filter-array-mixed-cache-" A_TickCount ".txt"
        selectedNodeIds := [
            "last failed node filter array mixed::old cached failure",
            "last failed node filter array mixed::selected failure"
        ]

        firstSuite.Test("old cached failure", (*) => AhkTest.Fail("cached failure"))
        firstSuite.Test("selected failure", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("old cached failure", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("selected failure", (*) => AhkTest.Fail("mixed array should keep cached intersection"))
        firstSuite.SetOutputFile(report)
        secondSuite.SetOutputFile(report)
        try {
            first := firstSuite.Run({ Quiet: true, LastFailedCache: cache })
            second := secondSuite.Run({ Quiet: true, LastFailed: true, LastFailedCache: cache, NodeFilter: selectedNodeIds })
            secondCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual(1, second.Total)
        AhkTest.AssertEqual(1, second.Passed)
        AhkTest.AssertEqual(1, second.Deselected)
        AhkTest.AssertEqual("old cached failure", second.Entries[1].Name)
        AhkTest.AssertEqual("", secondCache)
    }

    static AhkTestStepwiseResumesFromCachedFailure()
    {
        suite := AhkTest.CreateSuite("stepwise")
        report := A_Temp "\ahktest-stepwise-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-stepwise-cache-" A_TickCount ".txt"
        failMiddle := true
        failAfter := true

        suite.Test("before failure", (*) => AhkTest.AssertTrue(true))
        suite.Test("middle failure", (*) => stdlib_test_stepwise_maybe_fail(&failMiddle, "middle"))
        suite.Test("after failure", (*) => stdlib_test_stepwise_maybe_fail(&failAfter, "after"))
        suite.SetOutputFile(report)
        try {
            first := suite.Run({ Quiet: true, Stepwise: true, StepwiseCache: cache })
            firstCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
            failMiddle := false
            second := suite.Run({ Quiet: true, Stepwise: true, StepwiseCache: cache })
            secondCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
            failAfter := false
            third := suite.Run({ Quiet: true, Stepwise: true, StepwiseCache: cache })
            thirdCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(2, first.Total)
        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual("middle failure", first.Entries[2].Name)
        AhkTest.AssertContains("stepwise::middle failure", firstCache)

        AhkTest.AssertEqual(1, second.Deselected)
        AhkTest.AssertEqual(2, second.Total)
        AhkTest.AssertEqual("middle failure", second.Entries[1].Name)
        AhkTest.AssertEqual("after failure", second.Entries[2].Name)
        AhkTest.AssertContains("stepwise::after failure", secondCache)

        AhkTest.AssertEqual(2, third.Deselected)
        AhkTest.AssertEqual(1, third.Total)
        AhkTest.AssertEqual(1, third.Passed)
        AhkTest.AssertEqual("", thirdCache)
    }

    static AhkTestStepwiseFallsBackToFullRunWhenCachedNodeIdIsStale()
    {
        firstSuite := AhkTest.CreateSuite("stale stepwise first")
        secondSuite := AhkTest.CreateSuite("stale stepwise second")
        report := A_Temp "\ahktest-stale-stepwise-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-stale-stepwise-cache-" A_TickCount ".txt"

        firstSuite.Test("old failing name", (*) => AhkTest.Fail("cached failure"))
        secondSuite.Test("new passing name", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("other passing name", (*) => AhkTest.AssertTrue(true))
        firstSuite.SetOutputFile(report)
        secondSuite.SetOutputFile(report)
        try {
            first := firstSuite.Run({ Quiet: true, Stepwise: true, StepwiseCache: cache })
            firstCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
            second := secondSuite.Run({ Quiet: true, Stepwise: true, StepwiseCache: cache })
            secondCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertContains("stale stepwise first::old failing name", firstCache)
        AhkTest.AssertEqual(2, second.Total)
        AhkTest.AssertEqual(2, second.Passed)
        AhkTest.AssertEqual(0, second.Deselected)
        AhkTest.AssertEqual("new passing name", second.Entries[1].Name)
        AhkTest.AssertEqual("other passing name", second.Entries[2].Name)
        AhkTest.AssertContains("stale stepwise first::old failing name", secondCache)
    }

    static AhkTestStepwiseStaleCacheUpdatesToNewFailureAfterFallbackRun()
    {
        firstSuite := AhkTest.CreateSuite("stale stepwise update first")
        secondSuite := AhkTest.CreateSuite("stale stepwise update second")
        report := A_Temp "\ahktest-stale-stepwise-update-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-stale-stepwise-update-cache-" A_TickCount ".txt"

        firstSuite.Test("old failing name", (*) => AhkTest.Fail("cached failure"))
        secondSuite.Test("new passing name", (*) => AhkTest.AssertTrue(true))
        secondSuite.Test("new failing name", (*) => AhkTest.Fail("new cached failure"))
        firstSuite.SetOutputFile(report)
        secondSuite.SetOutputFile(report)
        try {
            first := firstSuite.Run({ Quiet: true, Stepwise: true, StepwiseCache: cache })
            second := secondSuite.Run({ Quiet: true, Stepwise: true, StepwiseCache: cache })
            secondCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual(2, second.Total)
        AhkTest.AssertEqual(1, second.Passed)
        AhkTest.AssertEqual(1, second.Failed)
        AhkTest.AssertEqual(0, second.Deselected)
        AhkTest.AssertEqual("new passing name", second.Entries[1].Name)
        AhkTest.AssertEqual("new failing name", second.Entries[2].Name)
        AhkTest.AssertContains("stale stepwise update second::new failing name", secondCache)
    }

    static AhkTestStepwiseFallsBackToCurrentNodeFilterSelectionWhenCachedNodeIsExcluded()
    {
        suite := AhkTest.CreateSuite("stepwise node filter fallback")
        report := A_Temp "\ahktest-stepwise-node-filter-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-stepwise-node-filter-cache-" A_TickCount ".txt"
        failMiddle := true
        selectedNodeId := "stepwise node filter fallback::after pass"

        suite.Test("before pass", (*) => AhkTest.AssertTrue(true))
        suite.Test("middle failure", (*) => stdlib_test_stepwise_maybe_fail(&failMiddle, "middle"))
        suite.Test("after pass", (*) => AhkTest.AssertTrue(true))
        suite.SetOutputFile(report)
        try {
            first := suite.Run({ Quiet: true, Stepwise: true, StepwiseCache: cache })
            firstCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
            second := suite.Run({ Quiet: true, Stepwise: true, StepwiseCache: cache, NodeFilter: selectedNodeId })
            secondCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertContains("stepwise node filter fallback::middle failure", firstCache)
        AhkTest.AssertEqual(2, second.Deselected)
        AhkTest.AssertEqual(1, second.Total)
        AhkTest.AssertEqual(1, second.Passed)
        AhkTest.AssertEqual("after pass", second.Entries[1].Name)
        AhkTest.AssertContains("stepwise node filter fallback::middle failure", secondCache)
    }

    static AhkTestStepwiseFilteredSelectionUpdatesCacheWhenNewFailureAppears()
    {
        suite := AhkTest.CreateSuite("stepwise filter update")
        report := A_Temp "\ahktest-stepwise-filter-update-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-stepwise-filter-update-cache-" A_TickCount ".txt"
        failMiddle := true
        failSelected := false

        suite.Test("before pass", (*) => AhkTest.AssertTrue(true))
        suite.Test("middle failure", (*) => stdlib_test_stepwise_maybe_fail(&failMiddle, "middle"))
        suite.Test("selected failure", (*) => stdlib_test_stepwise_maybe_fail(&failSelected, "selected"))
        suite.SetOutputFile(report)
        try {
            first := suite.Run({ Quiet: true, Stepwise: true, StepwiseCache: cache })
            failSelected := true
            second := suite.Run({ Quiet: true, Stepwise: true, StepwiseCache: cache, FilterExpr: "selected" })
            secondCache := FileExist(cache) ? FileRead(cache, "UTF-8") : ""
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual(2, second.Deselected)
        AhkTest.AssertEqual(1, second.Total)
        AhkTest.AssertEqual(1, second.Failed)
        AhkTest.AssertEqual("selected failure", second.Entries[1].Name)
        AhkTest.AssertContains("stepwise filter update::selected failure", secondCache)
    }

    static AhkTestStepwiseCacheDistinguishesDuplicateNamesAcrossSources()
    {
        firstSuite := AhkTest.CreateSuite()
        secondSuite := AhkTest.CreateSuite()
        report := A_Temp "\ahktest-stepwise-duplicate-source-" A_TickCount ".txt"
        cache := A_Temp "\ahktest-stepwise-duplicate-source-cache-" A_TickCount ".txt"
        firstSource := { Kind: "test", File: "a_duplicate.test.ahk", Line: 1 }
        secondSource := { Kind: "test", File: "b_duplicate.test.ahk", Line: 1 }
        thirdSource := { Kind: "test", File: "c_after.test.ahk", Line: 1 }

        firstSuite.Test("duplicate test", (*) => AhkTest.AssertTrue(true), { Source: firstSource })
        firstSuite.Test("duplicate test", (*) => AhkTest.Fail("second source failure"), { Source: secondSource })
        firstSuite.Test("after test", (*) => AhkTest.AssertTrue(true), { Source: thirdSource })
        secondSuite.Test("duplicate test", (*) => AhkTest.Fail("first source should stay deselected"), { Source: firstSource })
        secondSuite.Test("duplicate test", (*) => AhkTest.AssertTrue(true), { Source: secondSource })
        secondSuite.Test("after test", (*) => AhkTest.Fail("after resumed failure"), { Source: thirdSource })
        firstSuite.SetOutputFile(report)
        secondSuite.SetOutputFile(report)
        try {
            first := firstSuite.Run({ Quiet: true, Stepwise: true, StepwiseCache: cache })
            second := secondSuite.Run({ Quiet: true, Stepwise: true, StepwiseCache: cache })
        } finally {
            if FileExist(report)
                FileDelete report
            if FileExist(cache)
                FileDelete cache
        }

        AhkTest.AssertEqual(2, first.Total)
        AhkTest.AssertEqual(1, first.Passed)
        AhkTest.AssertEqual(1, first.Failed)
        AhkTest.AssertEqual(2, second.Total)
        AhkTest.AssertEqual(1, second.Passed)
        AhkTest.AssertEqual(1, second.Failed)
        AhkTest.AssertEqual(1, second.Deselected)
        AhkTest.AssertEqual("b_duplicate.test.ahk", second.Entries[1].Source.File)
        AhkTest.AssertEqual("c_after.test.ahk", second.Entries[2].Source.File)
    }

    static AhkTestRunsLifecycleHooks()
    {
        suite := AhkTest.CreateSuite("hooks")
        report := A_Temp "\ahktest-hooks-" A_TickCount ".txt"
        events := []

        suite.On("test_start", (test) => events.Push("start:" test.Name))
        suite.On("test_finish", (entry) => events.Push("finish:" entry.Name ":" entry.Status))
        suite.Test("passes", (*) => AhkTest.AssertTrue(true))
        suite.Test("fails", (*) => AhkTest.Fail("expected failure"))
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual(["start:passes", "finish:passes:pass", "start:fails", "finish:fails:fail"], events)
    }

    static AhkTestHooksRespectPriorityOrder()
    {
        suite := AhkTest.CreateSuite("hook priority")
        events := []

        suite.On("run_start", (*) => events.Push("default-a"))
        suite.On("run_start", (*) => events.Push("late"), { Priority: 50 })
        suite.On("run_start", (*) => events.Push("early"), { Priority: -10 })
        suite.On("run_start", (*) => events.Push("default-b"))
        suite.Test("passes", (*) => AhkTest.AssertTrue(true))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(["early", "default-a", "default-b", "late"], events)
    }

    static AhkTestRunCanDisableHooksById()
    {
        suite := AhkTest.CreateSuite("hook disable ids")
        events := []

        suite.On("run_start", (*) => events.Push("enabled"), { Id: "enabled-hook" })
        suite.On("run_start", (*) => events.Push("disabled"), { Id: "disabled-hook" })
        suite.Test("passes", (*) => AhkTest.AssertTrue(true))
        result := suite.Run({ Quiet: true, DisableHookIds: ["disabled-hook"] })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(["enabled"], events)
    }

    static AhkTestRunsSuiteLifecycleHooks()
    {
        suite := AhkTest.CreateSuite("suite hooks")
        events := []

        suite.On("run_start", (context) => events.Push("run_start:" context.Suite.Name ":" context.Tests.Length))
        suite.On("run_finish", (result) => events.Push("run_finish:" result.Total ":" result.Passed ":" result.Failed))
        suite.Test("passes", (*) => AhkTest.AssertTrue(true))
        suite.Test("fails", (*) => AhkTest.Fail("expected failure"))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual(["run_start:suite hooks:2", "run_finish:2:1:1"], events)
    }

    static AhkTestCollectionHooksCanModifyItems()
    {
        suite := AhkTest.CreateSuite("collection hooks")
        events := []

        suite.On("collect_finish", (context) => (
            events.Push("collect:" context.Suite.Name ":" context.Items.Length),
            context.Items.RemoveAt(1)
        ))
        suite.On("run_start", (context) => events.Push("run_start:" context.Tests.Length ":" context.Tests[1].Name))
        suite.Test("drop me", (*) => AhkTest.Fail("collection hook should deselect this item"))
        suite.Test("keep me", (*) => AhkTest.AssertTrue(true))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(0, result.Failed)
        AhkTest.AssertEqual("keep me", result.Entries[1].Name)
        AhkTest.AssertEqual(["collect:collection hooks:2", "run_start:1:keep me"], events)
    }

    static AhkTestReportsCollectionHookErrors()
    {
        suite := AhkTest.CreateSuite("collection hook errors")

        suite.On("collect_finish", (*) => stdlib_test_raise_value_error())
        suite.Test("should not run", (*) => AhkTest.Fail("collection hook errors stop execution"))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(0, result.Total)
        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual(2, result.ExitCode)
        AhkTest.AssertEqual(1, result.Entries.Length)
        AhkTest.AssertEqual("error", result.Entries[1].Status)
        AhkTest.AssertEqual("collection hook errors collect_finish hook", result.Entries[1].Name)
        AhkTest.AssertEqual("collection failure", result.Entries[1].Error.Message)
        AhkTest.AssertContains("raised for test", result.Entries[1].Error.Extra)
    }

    static AhkTestCollectionHookErrorsUseDedicatedCollectionFailureType()
    {
        suite := AhkTest.CreateSuite("collection hook error type")

        suite.On("collect_finish", (*) => stdlib_test_raise_value_error())
        suite.Test("should not run", (*) => AhkTest.Fail("collection hook errors stop execution"))
        result := suite.Run({ Quiet: true })
        data := result.ToMap()
        xml := result.ToJUnitXml()

        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual(2, result.ExitCode)
        AhkTest.AssertEqual("AhkTestCollectionError", Type(result.Entries[1].Error))
        AhkTest.AssertEqual("AhkTestCollectionError", data["Entries"][1]["ErrorType"])
        AhkTest.AssertEqual("collection failure", data["Entries"][1]["ErrorMessage"])
        AhkTest.AssertContains("raised for test", data["Entries"][1]["ErrorExtra"])
        AhkTest.AssertContains("<error", xml)
        AhkTest.AssertContains("message=`"collection failure`"", xml)
    }

    static AhkTestReportsRunStartHookErrors()
    {
        suite := AhkTest.CreateSuite("run start hook errors")

        suite.On("run_start", (*) => stdlib_test_raise_value_error())
        suite.Test("should not run", (*) => AhkTest.Fail("run_start hook errors stop execution"))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(0, result.Total)
        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual(1, result.Entries.Length)
        AhkTest.AssertEqual("error", result.Entries[1].Status)
        AhkTest.AssertEqual("run start hook errors run_start hook", result.Entries[1].Name)
        AhkTest.AssertEqual("raised for test", result.Entries[1].Error.Message)
    }

    static AhkTestReportsRunFinishHookErrors()
    {
        suite := AhkTest.CreateSuite("run finish hook errors")

        suite.On("run_finish", (*) => stdlib_test_raise_value_error())
        suite.Test("passes first", (*) => AhkTest.AssertTrue(true))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual(2, result.Entries.Length)
        AhkTest.AssertEqual("pass", result.Entries[1].Status)
        AhkTest.AssertEqual("passes first", result.Entries[1].Name)
        AhkTest.AssertEqual("error", result.Entries[2].Status)
        AhkTest.AssertEqual("run finish hook errors run_finish hook", result.Entries[2].Name)
        AhkTest.AssertEqual("raised for test", result.Entries[2].Error.Message)
        AhkTest.AssertEqual(1, result.ExitCode)
    }

    static AhkTestRunsReportFinishHooks()
    {
        suite := AhkTest.CreateSuite("report hooks")
        events := []

        suite.On("report_finish", (context) => events.Push("report:" context.Suite.Name ":" context.Result.Total ":" context.Result.Passed ":" context.Result.Failed ":" context.Result.Errors))
        suite.Test("passes", (*) => AhkTest.AssertTrue(true))
        suite.Test("fails", (*) => AhkTest.Fail("expected failure"))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual(0, result.Errors)
        AhkTest.AssertEqual(["report:report hooks:2:1:1:0"], events)
    }

    static AhkTestReportsReportFinishHookErrors()
    {
        suite := AhkTest.CreateSuite("report finish hook errors")

        suite.On("report_finish", (*) => stdlib_test_raise_value_error())
        suite.Test("passes first", (*) => AhkTest.AssertTrue(true))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual(2, result.Entries.Length)
        AhkTest.AssertEqual("pass", result.Entries[1].Status)
        AhkTest.AssertEqual("passes first", result.Entries[1].Name)
        AhkTest.AssertEqual("error", result.Entries[2].Status)
        AhkTest.AssertEqual("report finish hook errors report_finish hook", result.Entries[2].Name)
        AhkTest.AssertEqual("raised for test", result.Entries[2].Error.Message)
        AhkTest.AssertEqual(1, result.ExitCode)
    }

    static AhkTestReportsLifecycleHookErrors()
    {
        suite := AhkTest.CreateSuite("hook errors")
        report := A_Temp "\ahktest-hook-errors-" A_TickCount ".txt"

        suite.On("test_start", (*) => stdlib_test_raise_value_error())
        suite.Test("hook fails test", (*) => AhkTest.AssertTrue(true))
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual("error", result.Entries[1].Status)
        AhkTest.AssertEqual("raised for test", result.Entries[1].Error.Message)
    }

    static AhkTestAggregatesFinishHookErrors()
    {
        suite := AhkTest.CreateSuite("finish hook errors")
        report := A_Temp "\ahktest-finish-hook-errors-" A_TickCount ".txt"

        suite.On("test_finish", (*) => stdlib_test_raise_value_error())
        suite.Test("finish hook fails test", (*) => AhkTest.AssertTrue(true))
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(0, result.Passed)
        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual(1, result.Entries.Length)
        AhkTest.AssertEqual("error", result.Entries[1].Status)
        AhkTest.AssertEqual("raised for test", result.Entries[1].Error.Message)
    }

    static AhkTestInjectsExplicitFixtures()
    {
        suite := AhkTest.CreateSuite("fixtures")
        calls := 0

        suite.Fixture("counter", (*) => stdlib_test_fixture_counter(&calls))
        suite.Test("fixture first use", (value) => AhkTest.AssertEqual(1, value), { Fixtures: ["counter"] })
        suite.Test("fixture second use", (value) => AhkTest.AssertEqual(2, value), { Fixtures: ["counter"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual(2, calls)
    }

    static AhkTestTestFixtureOverrideShadowsSuiteFixture()
    {
        suite := AhkTest.CreateSuite("fixture override")
        seen := []

        suite.Fixture("config", (*) => "base")
        suite.Test("uses override", (config) => seen.Push(config), { Fixtures: ["config"], AhkFixtureOverrides: Map("config", (*) => "override") })
        suite.Test("uses base", (config) => seen.Push(config), { Fixtures: ["config"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual(["override", "base"], seen)
    }

    static AhkTestReportsUnknownFixtures()
    {
        suite := AhkTest.CreateSuite("missing fixture")
        report := A_Temp "\ahktest-missing-fixture-" A_TickCount ".txt"

        suite.Test("uses missing fixture", (value) => value, { Fixtures: ["missing_value"] })
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual("error", result.Entries[1].Status)
        AhkTest.AssertEqual("unknown fixture: missing_value", result.Entries[1].Error.Message)
    }

    static AhkTestResolvesFixtureDependencies()
    {
        suite := AhkTest.CreateSuite("fixture dependencies")

        suite.Fixture("base", (*) => "root")
        suite.Fixture("child", (baseValue) => baseValue "-child", { Fixtures: ["base"] })
        suite.Test("uses dependent fixture", (value) => AhkTest.AssertEqual("root-child", value), { Fixtures: ["child"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
    }

    static AhkTestCleansFixturesAfterPass()
    {
        suite := AhkTest.CreateSuite("fixture cleanup pass")
        cleaned := []

        suite.Fixture("resource", (*) => AhkTest.FixtureResult("payload", (*) => cleaned.Push("cleaned")))
        suite.Test("uses resource", (value) => AhkTest.AssertEqual("payload", value), { Fixtures: ["resource"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(["cleaned"], cleaned)
    }

    static AhkTestFixtureContextAddsCleanupAfterFixtureSetup()
    {
        suite := AhkTest.CreateSuite("fixture context cleanup")
        events := []

        suite.Fixture("resource", (ctx) => stdlib_test_fixture_context_resource(ctx, events), { Fixtures: ["ahk_context"] })
        suite.Test("uses context cleanup", (value) => events.Push("test:" value), { Fixtures: ["resource"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(["test:payload", "result cleanup", "context cleanup"], events)
    }

    static AhkTestFixtureContextCleansSetupFailures()
    {
        suite := AhkTest.CreateSuite("fixture setup cleanup")
        events := []

        suite.Fixture("resource", (ctx) => stdlib_test_fixture_context_setup_fails(ctx, events), { Fixtures: ["ahk_context"] })
        suite.Test("uses failing setup", (value) => AhkTest.Fail("fixture setup should fail before test callback"), { Fixtures: ["resource"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual("setup failed", result.Entries[1].Error.Message)
        AhkTest.AssertEqual(["setup", "context cleanup"], events)
    }

    static AhkTestFixtureContextNameIsReserved()
    {
        suite := AhkTest.CreateSuite("fixture context reserved name")

        err := AhkTest.Raises(ValueError, (*) => suite.Fixture("ahk_context", (*) => "shadowed"))

        AhkTest.AssertEqual("reserved fixture name: ahk_context", err.Message)
    }

    static AhkTestFixtureContextGetsFixtureValueOnce()
    {
        suite := AhkTest.CreateSuite("fixture context get fixture")
        calls := 0
        cleaned := []

        suite.Fixture("base", (*) => stdlib_test_named_scoped_fixture(&calls, cleaned, "base", "root"))
        suite.Fixture("child", (ctx) => stdlib_test_fixture_context_get_base(ctx), { Fixtures: ["ahk_context"] })
        suite.Test("uses dynamic and explicit fixture", (child, base) => stdlib_test_assert_same_fixture_value(child, base), { Fixtures: ["child", "base"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, calls)
        AhkTest.AssertEqual(["base"], cleaned)
    }

    static AhkTestFixtureContextGetFixtureUpdatesFixtureNamesForDynamicFixtures()
    {
        suite := AhkTest.CreateSuite("fixture context dynamic fixture names")

        suite.Fixture("base", (*) => "base")
        suite.Fixture("dynamic", (base) => base "-dyn", { Fixtures: ["base"] })
        suite.Test("loads dynamic fixture", (ctx) => stdlib_test_assert_dynamic_fixture_names(ctx), { Fixtures: ["ahk_context"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
    }

    static AhkTestFixtureContextGetFixtureDoesNotDuplicateDeclaredFixtureNames()
    {
        suite := AhkTest.CreateSuite("fixture context declared fixture names")

        suite.Fixture("base", (*) => "base")
        suite.Test("reuses declared fixture", (ctx, base) => stdlib_test_assert_declared_fixture_names(ctx, base), { Fixtures: ["ahk_context", "base"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
    }

    static AhkTestFixtureContextExposesTestMetadata()
    {
        suite := AhkTest.CreateSuite("fixture context metadata")

        suite.Fixture("meta", (ctx) => stdlib_test_fixture_context_metadata(ctx), { Fixtures: ["ahk_context"] })
        suite.Parametrize("case {id}", [
            { Id: "small", Args: ["payload"], Marks: ["row"] }
        ], (label, meta) => stdlib_test_assert_fixture_context_metadata(label, meta), { Fixtures: ["meta"], Marks: ["suite"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
    }

    static AhkTestFixtureContextExposesFixtureNamesLikePytestRequest()
    {
        suite := AhkTest.CreateSuite("fixture context fixture names")

        suite.Fixture("auto", (*) => "auto", { Autouse: true })
        suite.Fixture("dep", (ctx) => stdlib_test_fixture_context_fixture_names(ctx), { Fixtures: ["ahk_context"] })
        suite.Fixture("meta", (ctx, depNames) => stdlib_test_fixture_context_fixture_name_bundle(ctx, depNames), { Fixtures: ["ahk_context", "dep"] })
        suite.Test("uses meta", (meta) => stdlib_test_assert_fixture_context_fixture_names(meta), { Fixtures: ["meta"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
    }

    static AhkTestFixtureContextGetsParamValue()
    {
        suite := AhkTest.CreateSuite("fixture context get param")
        seen := []

        suite.Fixture("config", (ctx) => ctx.GetParam(), { Fixtures: ["ahk_context"], Params: [
            { Id: "dev", Value: Map("mode", "dev", "port", 8080) },
            { Id: "prod", Value: Map("mode", "prod", "port", 80) }
        ] })
        suite.Test("uses context param", (config) => stdlib_test_fixture_param_value(config, seen), { Fixtures: ["config"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual(["dev:8080", "prod:80"], seen)
    }

    static AhkTestFixtureContextExposesFixtureParamId()
    {
        suite := AhkTest.CreateSuite("fixture context fixture param id")
        seen := []

        suite.Fixture("config", (ctx) => stdlib_test_fixture_context_param_identity(ctx), { Fixtures: ["ahk_context"], Params: [
            { Id: "dev", Value: "config-dev" }
        ] })
        suite.Parametrize("case {id}", [
            { Id: "row", Args: ["label"] }
        ], (label, config) => seen.Push(label ":" config["Value"] ":" config["FixtureName"] ":" config["FixtureParamId"] ":" config["ParamId"]), { Fixtures: ["config"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(["label:config-dev:config:dev:row-dev"], seen)
    }

    static AhkTestFixtureContextGetParamReportsMissing()
    {
        suite := AhkTest.CreateSuite("fixture context missing param")

        suite.Fixture("plain", (ctx) => ctx.GetParam(), { Fixtures: ["ahk_context"] })
        suite.Test("uses plain fixture", (value) => AhkTest.Fail("missing param should fail during fixture setup"), { Fixtures: ["plain"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual("fixture has no parameter: plain", result.Entries[1].Error.Message)
    }

    static AhkTestFixtureParamsExpandTests()
    {
        suite := AhkTest.CreateSuite("fixture params")
        seen := []

        suite.Fixture("config", (ctx) => stdlib_test_fixture_from_param(ctx), { Fixtures: ["ahk_context"], Params: [
            { Id: "dev", Value: Map("mode", "dev", "port", 8080) },
            { Id: "prod", Value: Map("mode", "prod", "port", 80) }
        ] })
        suite.Test("uses config", (config) => stdlib_test_fixture_param_value(config, seen), { Fixtures: ["config"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual(["dev:8080", "prod:80"], seen)
        AhkTest.AssertEqual("fixture params::uses config[dev]", result.Entries[1].NodeId)
        AhkTest.AssertEqual("dev", result.Entries[1].ParamId)
        AhkTest.AssertEqual("fixture params::uses config[prod]", result.Entries[2].NodeId)
        AhkTest.AssertEqual("prod", result.Entries[2].ParamId)
    }

    static AhkTestFixtureParamsApplyRowMarks()
    {
        suite := AhkTest.CreateSuite("fixture param marks")
        seen := []

        suite.Fixture("config", (ctx) => stdlib_test_fixture_from_param(ctx), { Fixtures: ["ahk_context"], Params: [
            { Id: "dev", Value: Map("mode", "dev", "port", 8080), Marks: ["fast"] },
            { Id: "skip", Value: Map("mode", "skip", "port", 0), Marks: [AhkTest.SkipMark("fixture param skipped"), "slow"] }
        ] })
        suite.Test("uses config", (config) => stdlib_test_fixture_param_value(config, seen), { Fixtures: ["config"], Marks: ["base"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Total)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Skipped)
        AhkTest.AssertEqual(["dev:8080"], seen)
        AhkTest.AssertEqual(["base", "fast"], result.Entries[1].Marks)
        AhkTest.AssertEqual("skip", result.Entries[2].Status)
        AhkTest.AssertEqual("fixture param skipped", result.Entries[2].Reason)
        AhkTest.AssertEqual(["base", "slow"], result.Entries[2].Marks)
        AhkTest.AssertEqual("fixture param marks::uses config[skip]", result.Entries[2].NodeId)
    }

    static AhkTestCleansFixturesAfterFailure()
    {
        suite := AhkTest.CreateSuite("fixture cleanup failure")
        report := A_Temp "\ahktest-fixture-cleanup-" A_TickCount ".txt"
        cleaned := []

        suite.Fixture("resource", (*) => AhkTest.FixtureResult("payload", (*) => cleaned.Push("cleaned")))
        suite.Test("fails after resource", (value) => AhkTest.Fail("expected failure"), { Fixtures: ["resource"] })
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual(["cleaned"], cleaned)
    }

    static AhkTestCleansDependentFixturesInReverseOrder()
    {
        suite := AhkTest.CreateSuite("fixture cleanup order")
        cleaned := []

        suite.Fixture("base", (*) => AhkTest.FixtureResult("root", (*) => cleaned.Push("base")))
        suite.Fixture("child", (baseValue) => AhkTest.FixtureResult(baseValue "-child", (*) => cleaned.Push("child")), { Fixtures: ["base"] })
        suite.Test("uses child", (value) => AhkTest.AssertEqual("root-child", value), { Fixtures: ["child"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(["child", "base"], cleaned)
    }

    static AhkTestReportsFixtureDependencyCycles()
    {
        suite := AhkTest.CreateSuite("fixture cycle")
        report := A_Temp "\ahktest-fixture-cycle-" A_TickCount ".txt"

        suite.Fixture("left", (rightValue) => rightValue, { Fixtures: ["right"] })
        suite.Fixture("right", (leftValue) => leftValue, { Fixtures: ["left"] })
        suite.Test("uses cyclic fixture", (value) => value, { Fixtures: ["left"] })
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual("fixture dependency cycle: left -> right -> left", result.Entries[1].Error.Message)
    }

    static AhkTestAggregatesFixtureCleanupErrors()
    {
        suite := AhkTest.CreateSuite("fixture cleanup errors")
        report := A_Temp "\ahktest-fixture-cleanup-errors-" A_TickCount ".txt"
        cleaned := []

        suite.Fixture("first", (*) => AhkTest.FixtureResult("a", (*) => stdlib_test_cleanup_record_and_throw(cleaned, "first")))
        suite.Fixture("second", (*) => AhkTest.FixtureResult("b", (*) => stdlib_test_cleanup_record(cleaned, "second")))
        suite.Test("uses cleanup fixtures", (first, second) => 0, { Fixtures: ["first", "second"] })
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(["second", "first"], cleaned)
        AhkTest.AssertEqual(1, result.Total)
        AhkTest.AssertEqual(0, result.Passed)
        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual("AhkTestCleanupFailure", Type(result.Entries[1].Error))
        AhkTest.AssertEqual(1, result.Entries[1].Error.Errors.Length)
        AhkTest.AssertEqual("cleanup first failed", result.Entries[1].Error.Errors[1].Message)
    }

    static AhkTestCachesSuiteScopedFixturesUntilSuiteEnd()
    {
        suite := AhkTest.CreateSuite("suite fixture scope")
        report := A_Temp "\ahktest-suite-fixture-" A_TickCount ".txt"
        calls := 0
        cleaned := []

        suite.Fixture("shared", (*) => stdlib_test_scoped_fixture(&calls, cleaned, "shared"), { Scope: "suite" })
        suite.Test("first use", (value) => AhkTest.AssertEqual(1, value.Id), { Fixtures: ["shared"] })
        suite.Test("second use", (value) => stdlib_test_assert_suite_scoped_fixture(value, cleaned), { Fixtures: ["shared"] })
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual(1, calls)
        AhkTest.AssertEqual(["shared"], cleaned)
    }

    static AhkTestSuiteScopedFixtureParamsUseSeparateCacheEntries()
    {
        suite := AhkTest.CreateSuite("suite fixture param cache")
        calls := 0
        cleaned := []
        seen := []

        suite.Fixture("shared", (ctx) => stdlib_test_scoped_param_fixture(ctx, &calls, cleaned, "shared"), { Scope: "suite", Fixtures: ["ahk_context"], Params: [
            { Id: "dev", Value: "dev" },
            { Id: "prod", Value: "prod" }
        ] })
        suite.Test("first use", (value) => stdlib_test_record_scoped_param("first", value, seen), { Fixtures: ["shared"] })
        suite.Test("second use", (value) => stdlib_test_record_scoped_param("second", value, seen), { Fixtures: ["shared"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(4, result.Passed)
        AhkTest.AssertEqual(2, calls)
        AhkTest.AssertEqual(["first:dev:1", "first:prod:2", "second:dev:1", "second:prod:2"], seen)
        AhkTest.AssertEqual(["shared:prod", "shared:dev"], cleaned)
        AhkTest.AssertEqual("suite fixture param cache::first use[dev]", result.Entries[1].NodeId)
        AhkTest.AssertEqual("suite fixture param cache::second use[prod]", result.Entries[4].NodeId)
    }

    static AhkTestCachesSuiteScopedFixtureSetupErrors()
    {
        suite := AhkTest.CreateSuite("suite fixture setup error cache")
        calls := 0
        cleaned := []

        suite.Fixture("shared", (ctx) => stdlib_test_scoped_setup_fails(ctx, &calls, cleaned, "suite"), { Scope: "suite", Fixtures: ["ahk_context"] })
        suite.Test("first use", (value) => AhkTest.Fail("fixture setup should fail"), { Fixtures: ["shared"] })
        suite.Test("second use", (value) => AhkTest.Fail("cached fixture setup error should fail before callback"), { Fixtures: ["shared"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Errors)
        AhkTest.AssertEqual(1, calls)
        AhkTest.AssertEqual(["suite"], cleaned)
        AhkTest.AssertEqual("suite setup failed", result.Entries[1].Error.Message)
        AhkTest.AssertEqual("suite setup failed", result.Entries[2].Error.Message)
    }

    static AhkTestReportsSuiteScopedCleanupErrors()
    {
        suite := AhkTest.CreateSuite("suite cleanup failure")
        report := A_Temp "\ahktest-suite-cleanup-error-" A_TickCount ".txt"
        cleaned := []

        suite.Fixture("shared", (*) => AhkTest.FixtureResult("value", (*) => stdlib_test_cleanup_record_and_throw(cleaned, "suite")), { Scope: "suite" })
        suite.Test("uses shared value", (value) => AhkTest.AssertEqual("value", value), { Fixtures: ["shared"] })
        suite.SetOutputFile(report)
        try {
            result := suite.Run({ Quiet: true })
        } finally {
            if FileExist(report)
                FileDelete report
        }

        AhkTest.AssertEqual(["suite"], cleaned)
        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(1, result.Errors)
        AhkTest.AssertEqual(2, result.Entries.Length)
        AhkTest.AssertEqual("suite cleanup failure suite cleanup", result.Entries[2].Name)
        AhkTest.AssertEqual("AhkTestCleanupFailure", Type(result.Entries[2].Error))
    }

    static AhkTestCachesSessionScopedFixturesUntilExplicitCleanup()
    {
        suite := AhkTest.CreateSuite("session fixture cache")
        calls := 0
        cleaned := []

        suite.Fixture("shared", (*) => stdlib_test_scoped_fixture(&calls, cleaned, "session"), { Scope: "session" })
        suite.Test("uses session value", (value) => AhkTest.AssertEqual(1, value.Id), { Fixtures: ["shared"] })

        firstResult := suite.Run({ Quiet: true })
        secondResult := suite.Run({ Quiet: true })
        cleanupResult := AhkTest.CleanupSessionFixtures({ Quiet: true })

        AhkTest.AssertEqual(1, firstResult.Passed)
        AhkTest.AssertEqual(1, secondResult.Passed)
        AhkTest.AssertEqual(1, calls)
        AhkTest.AssertEqual(["session"], cleaned)
        AhkTest.AssertEqual(0, cleanupResult.Errors)
    }

    static AhkTestSessionScopedFixturesDoNotCollideAcrossSuites()
    {
        firstSuite := AhkTest.CreateSuite("session fixture isolated first suite")
        secondSuite := AhkTest.CreateSuite("session fixture isolated second suite")
        firstCalls := 0
        secondCalls := 0
        cleaned := []

        firstSuite.Fixture("shared", (*) => stdlib_test_named_scoped_fixture(&firstCalls, cleaned, "first", "first"), { Scope: "session" })
        secondSuite.Fixture("shared", (*) => stdlib_test_named_scoped_fixture(&secondCalls, cleaned, "second", "second"), { Scope: "session" })
        firstSuite.Test("first suite use", (value) => AhkTest.AssertEqual("first", value.Name), { Fixtures: ["shared"] })
        secondSuite.Test("second suite use", (value) => AhkTest.AssertEqual("second", value.Name), { Fixtures: ["shared"] })

        firstResult := firstSuite.Run({ Quiet: true })
        secondResult := secondSuite.Run({ Quiet: true })
        cleanupResult := AhkTest.CleanupSessionFixtures({ Quiet: true })

        AhkTest.AssertEqual(1, firstResult.Passed)
        AhkTest.AssertEqual(1, secondResult.Passed)
        AhkTest.AssertEqual(1, firstCalls)
        AhkTest.AssertEqual(1, secondCalls)
        AhkTest.AssertEqual(["second", "first"], cleaned)
        AhkTest.AssertEqual(0, cleanupResult.Errors)
    }

    static AhkTestSessionScopedFixtureParamsUseSeparateCacheEntries()
    {
        suite := AhkTest.CreateSuite("session fixture param cache")
        calls := 0
        cleaned := []
        seen := []

        suite.Fixture("shared", (ctx) => stdlib_test_scoped_param_fixture(ctx, &calls, cleaned, "session"), { Scope: "session", Fixtures: ["ahk_context"], Params: [
            { Id: "dev", Value: "dev" },
            { Id: "prod", Value: "prod" }
        ] })
        suite.Test("first use", (value) => stdlib_test_record_scoped_param("first", value, seen), { Fixtures: ["shared"] })
        suite.Test("second use", (value) => stdlib_test_record_scoped_param("second", value, seen), { Fixtures: ["shared"] })

        firstResult := suite.Run({ Quiet: true })
        secondResult := suite.Run({ Quiet: true })
        cleanupResult := AhkTest.CleanupSessionFixtures({ Quiet: true })

        AhkTest.AssertEqual(4, firstResult.Passed)
        AhkTest.AssertEqual(4, secondResult.Passed)
        AhkTest.AssertEqual(2, calls)
        AhkTest.AssertEqual(["first:dev:1", "first:prod:2", "second:dev:1", "second:prod:2", "first:dev:1", "first:prod:2", "second:dev:1", "second:prod:2"], seen)
        AhkTest.AssertEqual(["session:prod", "session:dev"], cleaned)
        AhkTest.AssertEqual(0, cleanupResult.Errors)
    }

    static AhkTestCachesSessionScopedFixtureSetupErrors()
    {
        suite := AhkTest.CreateSuite("session fixture setup error cache")
        calls := 0
        cleaned := []

        suite.Fixture("shared", (ctx) => stdlib_test_scoped_setup_fails(ctx, &calls, cleaned, "session"), { Scope: "session", Fixtures: ["ahk_context"] })
        suite.Test("first use", (value) => AhkTest.Fail("fixture setup should fail"), { Fixtures: ["shared"] })
        suite.Test("second use", (value) => AhkTest.Fail("cached fixture setup error should fail before callback"), { Fixtures: ["shared"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Errors)
        AhkTest.AssertEqual(1, calls)
        AhkTest.AssertEqual([], cleaned)
        AhkTest.AssertEqual("session setup failed", result.Entries[1].Error.Message)
        AhkTest.AssertEqual("session setup failed", result.Entries[2].Error.Message)

        cleanupResult := AhkTest.CleanupSessionFixtures({ Quiet: true })
        AhkTest.AssertEqual(["session"], cleaned)
        AhkTest.AssertEqual(0, cleanupResult.Errors)
    }

    static AhkTestRunsAutouseFixturesForEveryTest()
    {
        suite := AhkTest.CreateSuite("autouse fixture")
        events := []

        suite.Fixture("auto_setup", (*) => stdlib_test_autouse_fixture(events), { Autouse: true })
        suite.Test("first test", (*) => events.Push("first"))
        suite.Test("second test", (*) => events.Push("second"))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(2, result.Passed)
        AhkTest.AssertEqual(["setup", "first", "cleanup", "setup", "second", "cleanup"], events)
    }

    static AhkTestAutouseFixturesRequestedExplicitlyRunOnce()
    {
        suite := AhkTest.CreateSuite("autouse explicit fixture")
        events := []

        suite.Fixture("auto_setup", (*) => stdlib_test_autouse_fixture(events), { Autouse: true })
        suite.Test("explicit request", (value) => events.Push("test:" value), { Fixtures: ["auto_setup"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(["setup", "test:", "cleanup"], events)
    }

    static AhkTestAutouseFixturesResolveDependencies()
    {
        suite := AhkTest.CreateSuite("autouse fixture dependencies")
        events := []

        suite.Fixture("base", (*) => stdlib_test_autouse_base(events))
        suite.Fixture("auto_setup", (base) => stdlib_test_autouse_dependent(events, base), { Autouse: true, Fixtures: ["base"] })
        suite.Test("uses autouse dependency", (*) => events.Push("test"))
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual(["base", "auto:root", "test", "auto cleanup", "base cleanup"], events)
    }

    static AhkTestMonkeyPatchRestoresEnvironmentVariables()
    {
        suite := AhkTest.CreateSuite("monkey patch env")
        existingName := "AHKTEST_EXISTING_ENV_" A_TickCount
        missingName := "AHKTEST_MISSING_ENV_" A_TickCount

        EnvSet existingName, "before"
        EnvSet missingName
        suite.Fixture("patch", (*) => AhkTest.MonkeyPatchFixture())
        suite.Test("patches environment", (patch) => stdlib_test_patch_env(patch, existingName, missingName), { Fixtures: ["patch"] })
        try {
            result := suite.Run({ Quiet: true })
            AhkTest.AssertEqual(1, result.Passed)
            AhkTest.AssertEqual("before", EnvGet(existingName))
            AhkTest.AssertEqual("", EnvGet(missingName))
        } finally {
            EnvSet existingName
            EnvSet missingName
        }
    }

    static AhkTestMonkeyPatchRestoresDeletedEnvironmentVariables()
    {
        suite := AhkTest.CreateSuite("monkey patch deleted env")
        name := "AHKTEST_DELETE_ENV_" A_TickCount

        EnvSet name, "kept"
        suite.Fixture("patch", (*) => AhkTest.MonkeyPatchFixture())
        suite.Test("deletes environment", (patch) => stdlib_test_delete_env(patch, name), { Fixtures: ["patch"] })
        try {
            result := suite.Run({ Quiet: true })
            AhkTest.AssertEqual(1, result.Passed)
            AhkTest.AssertEqual("kept", EnvGet(name))
        } finally {
            EnvSet name
        }
    }

    static AhkTestMonkeyPatchPrependsPathEnvironmentVariables()
    {
        suite := AhkTest.CreateSuite("monkey patch env path")
        name := "AHKTEST_PATH_ENV_" A_TickCount

        EnvSet name, "tail"
        suite.Fixture("patch", (*) => AhkTest.MonkeyPatchFixture())
        suite.Test("prepends path env", (patch) => stdlib_test_prepend_env_path(patch, name), { Fixtures: ["patch"] })
        try {
            result := suite.Run({ Quiet: true })
            AhkTest.AssertEqual(1, result.Passed)
            AhkTest.AssertEqual("tail", EnvGet(name))
        } finally {
            EnvSet name
        }
    }

    static AhkTestMonkeyPatchRestoresMapValues()
    {
        suite := AhkTest.CreateSuite("monkey patch map")
        target := Map("existing", "before", "deleted", "kept")

        suite.Fixture("patch", (*) => AhkTest.MonkeyPatchFixture())
        suite.Test("patches map", (patch) => stdlib_test_patch_map(patch, target), { Fixtures: ["patch"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual("before", target["existing"])
        AhkTest.AssertFalse(target.Has("created"))
        AhkTest.AssertEqual("kept", target["deleted"])
    }

    static AhkTestMonkeyPatchRestoresObjectProperties()
    {
        suite := AhkTest.CreateSuite("monkey patch object props")
        target := { Existing: "before", Deleted: "kept" }

        suite.Fixture("patch", (*) => AhkTest.MonkeyPatchFixture())
        suite.Test("patches object props", (patch) => stdlib_test_patch_object_props(patch, target), { Fixtures: ["patch"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Passed)
        AhkTest.AssertEqual("before", target.Existing)
        AhkTest.AssertFalse(target.HasOwnProp("Created"))
        AhkTest.AssertEqual("kept", target.Deleted)
    }

    static AhkTestMonkeyPatchRestoresObjectMethodsAfterFailure()
    {
        suite := AhkTest.CreateSuite("monkey patch object methods")
        target := { Existing: stdlib_test_original_method }

        suite.Fixture("patch", (*) => AhkTest.MonkeyPatchFixture())
        suite.Test("patches object methods", (patch) => stdlib_test_patch_object_methods(patch, target), { Fixtures: ["patch"] })
        result := suite.Run({ Quiet: true })

        AhkTest.AssertEqual(1, result.Failed)
        AhkTest.AssertEqual("original:value", target.Existing("value"))
        AhkTest.AssertFalse(target.HasOwnProp("Created"))
    }

    static AhkTestMonkeyPatchRestoresWorkingDirectory()
    {
        suite := AhkTest.CreateSuite("monkey patch cwd")
        temp := AhkTest.TempDir("stdlib-cwd")
        original := A_WorkingDir

        suite.Fixture("patch", (*) => AhkTest.MonkeyPatchFixture())
        suite.Test("changes cwd", (patch) => stdlib_test_patch_cwd(patch, temp.Path), { Fixtures: ["patch"] })
        try {
            result := suite.Run({ Quiet: true })
            AhkTest.AssertEqual(1, result.Passed)
            AhkTest.AssertEqual(original, A_WorkingDir)
        } finally {
            if A_WorkingDir != original
                SetWorkingDir original
            temp.Cleanup()
        }
    }

    static AssertUsesDirectStdlibApi()
    {
        value := { Name: "kept" }
        AhkTest.AssertSame(value, stdlib.assert.assert(value))

        err := AhkTest.AssertThrows(stdlib.assert.AssertionError, (*) => stdlib.assert.assert(false, "stdlib assertion failed"))
        AhkTest.AssertEqual("stdlib assertion failed", err.Message)
    }

    static CoreBaseCheckTypeUsesStdlibNamespace()
    {
        value := StdlibCoreBaseSmokeSubject()

        stdlib.base.checkType(StdlibCoreBaseSmokeSubject, value)

        AhkTest.AssertThrows(TypeError, (*) => stdlib.base.checkType(StdlibCoreBaseSmokeSubject, {}))
        stdlib.base.delattr(value, "name")
        AhkTest.AssertFalse(HasProp(value, "name"))
        AhkTest.RaisesMatch(PropertyError, "'int' object has no attribute 'name'", (*) => stdlib.base.delattr(1, "name"))
    }

    static AbcUsesStdlibNamespace()
    {
        marker := stdlib.abc.abstractmethod((value) => value)
        baseBefore := StdlibBootstrapAbcForeign.Prototype.Base

        AhkTest.AssertEqual(true, marker.__isabstractmethod)
        AhkTest.AssertEqual(5, marker.Call(5))

        stdlib.abc.ABC.register(StdlibBootstrapAbcForeign)
        AhkTest.AssertFalse(stdlib.abc.isabstract(StdlibBootstrapAbcForeign))
        AhkTest.AssertSame(baseBefore, StdlibBootstrapAbcForeign.Prototype.Base)
        AhkTest.AssertTrue(stdlib.abc.issubclass(StdlibBootstrapAbcForeign, stdlib.abc.ABC))
        AhkTest.AssertTrue(stdlib.abc.isinstance(StdlibBootstrapAbcForeign(), stdlib.abc.ABC))
    }

    static CoreTypesUsesStdlibNamespace()
    {
        namespace := stdlib.types.SimpleNamespace(Map("name", "stdlib"))

        AhkTest.AssertSame(stdlib.types.FunctionType, stdlib.types.LambdaType)
        AhkTest.AssertEqual("stdlib", namespace.name)
        AhkTest.AssertEqual("stdlib", stdlib.types.ModuleType("stdlib").__name)
    }

    static OperatorUsesStdlibNamespace()
    {
        values := ["a", "b", "c"]

        AhkTest.AssertEqual(5, stdlib.operator.add(2, 3))
        AhkTest.AssertEqual("ab", stdlib.operator.add("a", "b"))
        AhkTest.AssertEqual([1, 2, 1, 2], stdlib.operator.mul([1, 2], 2))
        AhkTest.AssertTrue(stdlib.operator.contains(values, "b"))
        AhkTest.AssertEqual("a", stdlib.operator.getitem(values, 0))
        AhkTest.AssertEqual(["c", "a"], stdlib.operator.itemgetter(-1, 0).Call(values))
        repeatHintValues := stdlib.itertools.repeat("x", 3)
        AhkTest.AssertEqual(3, stdlib.operator.length_hint(repeatHintValues))
        AhkTest.AssertEqual(["x", "x"], stdlib_bootstrap_array(stdlib.itertools.islice(repeatHintValues, 2)))
        AhkTest.AssertEqual(1, stdlib.operator.length_hint(repeatHintValues))
        AhkTest.AssertEqual(0, stdlib.operator.length_hint(stdlib.itertools.repeat("x")))
        AhkTest.AssertEqual(9, stdlib.operator.length_hint(stdlib.itertools.repeat("x"), 9))
        AhkTest.AssertEqual(-1, stdlib.operator.length_hint({ value: 1 }, -1))
        AhkTest.AssertEqual(1, stdlib.operator.length_hint({ value: 1 }, stdlib.True))
        AhkTest.RaisesMatch(TypeError, "'NoneType' object cannot be interpreted as an integer", (*) => stdlib.operator.length_hint(values, stdlib.None))
        AhkTest.RaisesMatch(TypeError, "'tuple' object cannot be interpreted as an integer", (*) => stdlib.operator.length_hint(values, stdlib.tuple()))
        AhkTest.RaisesMatch(TypeError, "'NotImplementedType' object cannot be interpreted as an integer", (*) => stdlib.operator.length_hint(values, stdlib.NotImplemented))
        AhkTest.AssertEqual(1, stdlib.operator.length_hint(StdlibBootstrapLengthHintValue(stdlib.True), 9))
        AhkTest.AssertEqual(9, stdlib.operator.length_hint(StdlibBootstrapLengthHintValue(stdlib.NotImplemented), 9))
        AhkTest.AssertEqual(9, stdlib.operator.length_hint(StdlibBootstrapLengthHintTypeError(), 9))
        AhkTest.RaisesMatch(TypeError, "__length_hint__ must be an integer, not NoneType", (*) => stdlib.operator.length_hint(StdlibBootstrapLengthHintValue(stdlib.None), 9))
        AhkTest.RaisesMatch(ValueError, "bad hint", (*) => stdlib.operator.length_hint(StdlibBootstrapLengthHintValueError(), 9))
    }

    static HeapqUsesStdlibNamespace()
    {
        heap := []

        stdlib.heapq.heappush(heap, 3)
        stdlib.heapq.heappush(heap, 1)
        stdlib.heapq.heappush(heap, 2)

        AhkTest.AssertEqual(1, stdlib.heapq.heappop(heap))
        AhkTest.AssertEqual(2, stdlib.heapq.heappop(heap))
        AhkTest.AssertEqual(3, stdlib.heapq.heappop(heap))
    }

    static QueueUsesStdlibNamespace()
    {
        q := stdlib.queue.Queue(1)

        AhkTest.AssertTrue(q.empty())
        AhkTest.AssertFalse(q.full())
        AhkTest.AssertEqual(0, q.qsize())
        q.put_nowait(1)
        AhkTest.AssertTrue(q.full())
        AhkTest.AssertEqual(1, q.get_nowait())
        q.task_done()
        AhkTest.AssertEqual("", q.join())
        AhkTest.AssertEqual("", q.put("none-timeout", true, stdlib.None))
        AhkTest.AssertEqual("none-timeout", q.get(true, stdlib.None))
        q.task_done()
        AhkTest.AssertEqual("", q.join())
        AhkTest.Raises(stdlib.queue.Empty, (*) => stdlib.queue.Queue().get_nowait())
    }

    static SimpleQueueUsesStdlibNamespace()
    {
        q := stdlib.queue.SimpleQueue()

        AhkTest.AssertTrue(q.empty())
        AhkTest.AssertEqual(0, q.qsize())
        q.put_nowait(1)
        AhkTest.AssertEqual("", q.put("ignored-timeout", true, -1))
        AhkTest.AssertEqual(2, q.qsize())
        AhkTest.AssertEqual(1, q.get_nowait())
        AhkTest.AssertEqual("ignored-timeout", q.get(true, stdlib.None))
        AhkTest.Raises(stdlib.queue.Empty, (*) => stdlib.queue.SimpleQueue().get_nowait())
    }

    static LifoQueueUsesStdlibNamespace()
    {
        q := stdlib.queue.LifoQueue()

        AhkTest.AssertTrue(q.empty())
        q.put_nowait(1)
        q.put_nowait(2)
        AhkTest.AssertEqual(2, q.get_nowait())
        AhkTest.AssertEqual(1, q.get_nowait())
        q.task_done()
        q.task_done()
        AhkTest.AssertEqual("", q.join())
        AhkTest.AssertEqual("", q.put("none-timeout", true, stdlib.None))
        AhkTest.AssertEqual("none-timeout", q.get(true, stdlib.None))
        q.task_done()
        AhkTest.AssertEqual("", q.join())
        AhkTest.Raises(stdlib.queue.Empty, (*) => stdlib.queue.LifoQueue().get_nowait())
    }

    static PriorityQueueUsesStdlibNamespace()
    {
        q := stdlib.queue.PriorityQueue()

        AhkTest.AssertTrue(q.empty())
        q.put_nowait([2, "b"])
        q.put_nowait([1, "a"])
        AhkTest.AssertEqual([1, "a"], q.get_nowait())
        AhkTest.AssertEqual([2, "b"], q.get_nowait())
        q.task_done()
        q.task_done()
        AhkTest.AssertEqual("", q.join())
        AhkTest.AssertEqual("", q.put([0, "none-timeout"], true, stdlib.None))
        AhkTest.AssertEqual([0, "none-timeout"], q.get(true, stdlib.None))
        q.task_done()
        AhkTest.AssertEqual("", q.join())
        AhkTest.Raises(stdlib.queue.Empty, (*) => stdlib.queue.PriorityQueue().get_nowait())
    }

    static MathUsesStdlibNamespace()
    {
        AhkTest.AssertEqual(120, stdlib.math.factorial(5))
        AhkTest.AssertEqual(6, stdlib.math.gcd(48, -18))
        AhkTest.AssertEqual(24, stdlib.math.lcm(6, 8))
        AhkTest.AssertEqual(10, stdlib.math.comb(5, 2))
        AhkTest.AssertEqual(5, stdlib.math.hypot(3, 4))
    }

    static RandomUsesStdlibNamespace()
    {
        value := stdlib.random.random()
        choice := stdlib.random.choice(["a", "b"])

        AhkTest.AssertEqual("Float", Type(value))
        AhkTest.AssertTrue(value >= 0.0)
        AhkTest.AssertTrue(value < 1.0)
        AhkTest.AssertTrue(choice = "a" || choice = "b")
        AhkTest.AssertEqual(3, stdlib.random.randint(3, 3))
    }

    static ArrayUsesStdlibNamespace()
    {
        values := stdlib.array.array("i", [1, 2, 3])
        bytes := stdlib.array.array("b", [1, -2, 3])
        bufferInfo := values.buffer_info()

        AhkTest.AssertEqual("bBuhHiIlLqQfd", stdlib.array.typecodes)
        AhkTest.AssertEqual("i", values.typecode)
        AhkTest.AssertEqual(4, values.itemsize)
        AhkTest.AssertSame(stdlib.None, values.append(4))
        AhkTest.AssertEqual([1, 2, 3, 4], values.tolist())
        AhkTest.AssertEqual(4, values[3])
        AhkTest.AssertEqual(3, bufferInfo[2])
        AhkTest.AssertEqual("array('b', [1, -2, 3])", bytes.__Repr())
        AhkTest.AssertEqual(4, values.__Len)
        AhkTest.AssertTrue(stdlib.operator.truth(values))
        AhkTest.AssertFalse(stdlib.operator.truth(stdlib.array.array("i")))
        AhkTest.AssertTrue(stdlib.operator.contains(values, 3))
        AhkTest.AssertTrue(stdlib.operator.eq(values, stdlib.array.array("h", [1, 2, 3, 4])))
        AhkTest.AssertEqual([1, 2, 3, 4, 5], stdlib.operator.add(values, stdlib.array.array("i", [5])).tolist())
        AhkTest.AssertEqual([1, 2, 3, 4, 1, 2, 3, 4], stdlib.operator.mul(2, values).tolist())
    }

    static HashlibUsesStdlibNamespace()
    {
        hash := stdlib.hashlib.md5()
        bytes := Buffer(3, 0)
        StrPut("abc", bytes, "UTF-8")

        AhkTest.AssertEqual("md5", hash.name)
        AhkTest.AssertEqual(16, hash.digest_size)
        AhkTest.AssertEqual(64, hash.block_size)
        AhkTest.AssertEqual("900150983cd24fb0d6963f7d28e17f72", stdlib.hashlib.md5(bytes).hexdigest())
        AhkTest.AssertEqual("a9993e364706816aba3e25717850c26c9cd0d89d", stdlib.hashlib.new("sha1", bytes).hexdigest())
        AhkTest.AssertEqual("", hash.update(bytes))
        AhkTest.AssertEqual("900150983cd24fb0d6963f7d28e17f72", hash.hexdigest())
    }

    static HmacUsesStdlibNamespace()
    {
        key := Buffer(3, 0)
        StrPut("key", key, "UTF-8")
        message := Buffer(7, 0)
        StrPut("message", message, "UTF-8")

        mac := stdlib.hmac.new(key, message, "sha256")

        AhkTest.AssertEqual("hmac-sha256", mac.name)
        AhkTest.AssertEqual(32, mac.digest_size)
        AhkTest.AssertEqual(64, mac.block_size)
        AhkTest.AssertEqual("6e9ef29b75fffc5b7abae527d58fdadb2fe42e7219011976917343065f58ed4a", mac.hexdigest())
        AhkTest.AssertTrue(stdlib.hmac.compare_digest(mac.digest(), stdlib.hmac.digest(key, message, "sha256")))
    }

    static PprintUsesStdlibNamespace()
    {
        stream := stdlib.io.StringIO()
        printer := stdlib.pprint.PrettyPrinter(2, 20)

        AhkTest.AssertEqual("[1, 'two', [3]]", stdlib.pprint.pformat([1, "two", [3]]))
        AhkTest.AssertSame(stdlib.None, stdlib.pprint.pprint(Map("b", 1, "a", 2), stream))
        AhkTest.AssertEqual("{'a': 2, 'b': 1}`n", stream.getvalue())
        AhkTest.AssertEqual("{ 'a': [1, 2, 3],`n  'b': 1}", printer.pformat(Map("b", 1, "a", [1, 2, 3])))
    }

    static AsyncioUsesStdlibNamespace()
    {
        eventLoop := stdlib.asyncio.new_event_loop()
        pending := stdlib.asyncio.Future({ loop: eventLoop })
        finished := stdlib.asyncio.Future()
        cancelled := stdlib.asyncio.Future()

        AhkTest.AssertTrue(stdlib.asyncio.isfuture(pending))
        AhkTest.AssertFalse(stdlib.asyncio.isfuture("x"))
        AhkTest.AssertFalse(pending.done())
        AhkTest.AssertEqual("<Future pending>", pending.__Repr())
        AhkTest.AssertSame(stdlib.None, finished.set_result(42))
        AhkTest.AssertEqual(42, finished.result())
        AhkTest.AssertSame(stdlib.None, finished.exception())
        AhkTest.AssertTrue(cancelled.cancel())
        AhkTest.AssertTrue(cancelled.cancelled())
        AhkTest.Raises(stdlib.asyncio.CancelledError, (*) => cancelled.result())

        loopEvents := []
        AhkTest.AssertFalse(eventLoop.is_running())
        AhkTest.AssertFalse(eventLoop.is_closed())
        AhkTest.AssertEqual("Float", Type(eventLoop.time()))
        eventLoop.call_soon((targetLoop, events) => events.Push(["soon", targetLoop.is_running(), targetLoop.is_closed()]), eventLoop, loopEvents)
        eventLoop.call_at(eventLoop.time(), (events, label) => events.Push(["at", label]), loopEvents, "now")
        spinFuture := eventLoop.create_future()
        eventLoop.call_later(0.01, (future) => future.set_result("spin"), spinFuture)
        AhkTest.AssertEqual("spin", eventLoop.run_until_complete(spinFuture))
        AhkTest.AssertEqual([["soon", true, false], ["at", "now"]], loopEvents)
        AhkTest.AssertSame(stdlib.None, eventLoop.close())
        AhkTest.AssertTrue(eventLoop.is_closed())
        AhkTest.RaisesMatch(RuntimeError, "^Event loop is closed$", (*) => eventLoop.call_soon((*) => stdlib.None))
    }

    static TkinterUsesStdlibNamespace()
    {
        interp := stdlib.tkinter.Tcl()
        variable := stdlib.tkinter.StringVar(interp, "seed")

        AhkTest.AssertEqual(8.6, stdlib.tkinter.TclVersion)
        AhkTest.AssertEqual(8.6, stdlib.tkinter.TkVersion)
        AhkTest.AssertEqual(2, stdlib.tkinter.READABLE)
        AhkTest.AssertEqual(4, stdlib.tkinter.WRITABLE)
        AhkTest.AssertEqual(8, stdlib.tkinter.EXCEPTION)
        AhkTest.AssertTrue(interp is stdlib.tkinter.Tk)
        AhkTest.AssertEqual("3", interp.eval("expr 1 + 2"))
        AhkTest.AssertEqual(stdlib.None, interp.setvar("x", "hello"))
        AhkTest.AssertEqual("hello", interp.getvar("x"))
        AhkTest.AssertEqual(".", String(interp._root()))
        AhkTest.AssertEqual("seed", variable.get())
        AhkTest.AssertRegex(variable._name, "^" Chr(80) Chr(89) "_VAR[0-9]+$")
    }

    static EnumUsesStdlibNamespace()
    {
        Color := stdlib.enum.Enum("Color", "RED GREEN BLUE")
        AutoColor := stdlib.enum.Enum("AutoColor", [["RED", stdlib.enum.auto()], ["GREEN", stdlib.enum.auto()]])

        AhkTest.AssertEqual("Color", Color.__name)
        AhkTest.AssertEqual("RED", Color.RED.name)
        AhkTest.AssertEqual(1, Color.RED.value)
        AhkTest.AssertEqual("Color.RED", String(Color.RED))
        AhkTest.AssertEqual(["RED", "GREEN", "BLUE"], stdlib_bootstrap_enum_member_names(Color))
        AhkTest.AssertEqual([1, 2], stdlib_bootstrap_enum_member_values(AutoColor))
        AhkTest.AssertSame(Color.GREEN, Color["GREEN"])
        AhkTest.AssertSame(Color.GREEN, Color(2))
    }

    static CopyUsesStdlibNamespace()
    {
        values := [1, [2]]
        copy := stdlib.copy.copy(values)
        deep := stdlib.copy.deepcopy(values)

        AhkTest.AssertFalse(copy == values)
        AhkTest.AssertSame(values[2], copy[2])
        AhkTest.AssertFalse(deep == values)
        AhkTest.AssertFalse(deep[2] == values[2])
        AhkTest.AssertSame("abc", stdlib.copy.copy("abc"))
        AhkTest.AssertEqual(42, stdlib.copy.deepcopy(42))
        AhkTest.AssertSame(stdlib.copy.Error, stdlib.copy.error)
        AhkTest.AssertTrue(stdlib.copy.dispatch_table is Map)
        AhkTest.AssertEqual(3, stdlib.copy.dispatch_table.Count)
    }

    static UuidUsesStdlibNamespace()
    {
        fixed := stdlib.uuid.UUID("12345678-1234-5678-1234-567812345678")
        generated := stdlib.uuid.uuid4()

        AhkTest.AssertEqual("12345678-1234-5678-1234-567812345678", String(fixed))
        AhkTest.AssertEqual("12345678123456781234567812345678", fixed.hex)
        AhkTest.AssertEqual("UUID('12345678-1234-5678-1234-567812345678')", fixed.__Repr())
        AhkTest.AssertEqual(4, generated.version)
    }

    static InspectUsesStdlibNamespace()
    {
        lambda := (() => 1)

        AhkTest.AssertTrue(stdlib.inspect.isfunction(stdlib_test_inspect_probe_free))
        AhkTest.AssertTrue(stdlib.inspect.isfunction(lambda))
        AhkTest.AssertFalse(stdlib.inspect.isfunction(StrLen))
        AhkTest.AssertTrue(stdlib.inspect.isclass(StdlibBootstrapInspectProbe))
        AhkTest.AssertFalse(stdlib.inspect.isclass(StdlibBootstrapInspectProbe()))
    }

    static SecretsUsesStdlibNamespace()
    {
        picked := stdlib.secrets.choice("abc")
        token := stdlib.secrets.token_hex(4)

        AhkTest.AssertTrue(picked = "a" || picked = "b" || picked = "c")
        AhkTest.AssertEqual(0, stdlib.secrets.randbelow(1))
        AhkTest.AssertEqual(4, stdlib.secrets.token_bytes(4).Size)
        AhkTest.AssertEqual(8, StrLen(token))
        AhkTest.AssertTrue(stdlib.secrets.compare_digest("same", "same"))
        AhkTest.AssertFalse(stdlib.secrets.compare_digest("same", "diff"))
    }

    static KeywordUsesStdlibNamespace()
    {
        AhkTest.AssertEqual(35, stdlib.keyword.kwlist.Length)
        AhkTest.AssertEqual(["_", "case", "match"], stdlib.keyword.softkwlist)
        AhkTest.AssertTrue(stdlib.keyword.iskeyword("for"))
        AhkTest.AssertTrue(stdlib.keyword.issoftkeyword("match"))
        AhkTest.AssertFalse(stdlib.keyword.iskeyword("match"))
    }

    static FnmatchUsesStdlibNamespace()
    {
        AhkTest.AssertTrue(stdlib.fnmatch.fnmatch("A.TXT", "*.txt"))
        AhkTest.AssertFalse(stdlib.fnmatch.fnmatchcase("A.TXT", "*.txt"))
        AhkTest.AssertEqual(["A.TXT", "b.txt"], stdlib.fnmatch.filter(["A.TXT", "b.txt", "c.bin"], "*.txt"))
        AhkTest.AssertEqual("(?s:.*\.txt)\Z", stdlib.fnmatch.translate("*.txt"))
    }

    static GlobUsesStdlibNamespace()
    {
        AhkTest.AssertEqual("[[][*]][?].txt", stdlib.glob.escape("[*]?.txt"))
        AhkTest.AssertTrue(stdlib.glob.has_magic("*.txt"))
        AhkTest.AssertFalse(stdlib.glob.has_magic("plain.txt"))
    }

    static StringUsesStdlibNamespace()
    {
        AhkTest.AssertEqual("abcdefghijklmnopqrstuvwxyz", stdlib.string.ascii_lowercase)
        AhkTest.AssertEqual("Hello World", stdlib.string.capwords("  hello   world  "))
        AhkTest.AssertEqual("A,,B,", stdlib.string.capwords("a,,b,", ","))
    }

    static TextwrapUsesStdlibNamespace()
    {
        AhkTest.AssertEqual("a`n  b`n", stdlib.textwrap.dedent("    a`n      b`n"))
        AhkTest.AssertEqual("> a`n`n> b", stdlib.textwrap.indent("a`n`nb", "> "))
    }

    static Base64UsesStdlibNamespace()
    {
        bytes := Buffer(3, 0)
        StrPut("abc", bytes, "UTF-8")
        AhkTest.AssertEqual("YWJj", StrGet(stdlib.base64.b64encode(bytes), "UTF-8"))
        AhkTest.AssertEqual("abc", StrGet(stdlib.base64.b64decode("YWJj"), "UTF-8"))
        AhkTest.AssertEqual("YWJj", StrGet(stdlib.base64.standard_b64encode(bytes), "UTF-8"))
        AhkTest.AssertEqual("abc", StrGet(stdlib.base64.standard_b64decode("YWJj"), "UTF-8"))
        AhkTest.AssertEqual("YWJj`n", StrGet(stdlib.base64.encodebytes(bytes), "UTF-8"))
        AhkTest.AssertEqual("abc", StrGet(stdlib.base64.decodebytes(stdlib.base64.encodebytes(bytes)), "UTF-8"))

        binary := Buffer(5, 0)
        NumPut("UChar", 0x41, binary, 0)
        NumPut("UChar", 0x42, binary, 1)
        NumPut("UChar", 0x43, binary, 2)
        NumPut("UChar", 0x00, binary, 3)
        NumPut("UChar", 0xff, binary, 4)
        decoded := stdlib.base64.b16decode("41424300ff", true)
        AhkTest.AssertEqual("41424300FF", StrGet(stdlib.base64.b16encode(binary), "UTF-8"))
        AhkTest.AssertEqual("41424300ff", Format("{:02x}{:02x}{:02x}{:02x}{:02x}"
            , NumGet(decoded, 0, "UChar")
            , NumGet(decoded, 1, "UChar")
            , NumGet(decoded, 2, "UChar")
            , NumGet(decoded, 3, "UChar")
            , NumGet(decoded, 4, "UChar")))
    }

    static BisectUsesStdlibNamespace()
    {
        values := [1, 2, 2, 3]
        arrayValues := stdlib.array.array("i", [1, 2, 2, 3])
        arrayInsert := stdlib.array.array("i", [1, 3])

        AhkTest.AssertEqual(1, stdlib.bisect.bisect_left(values, 2))
        AhkTest.AssertEqual(3, stdlib.bisect.bisect_right(values, 2))
        AhkTest.AssertEqual(3, stdlib.bisect.bisect_right(arrayValues, 2))
        AhkTest.AssertSame(stdlib.None, stdlib.bisect.insort_left(arrayInsert, 2))
        AhkTest.AssertEqual([1, 2, 3], arrayInsert.tolist())
    }

    static GetpassUsesStdlibNamespace()
    {
        saved := EnvGet("USERNAME")
        try {
            EnvSet("LOGNAME", "")
            EnvSet("USER", "")
            EnvSet("LNAME", "")
            EnvSet("USERNAME", "bootstrap_user")
            AhkTest.AssertEqual("bootstrap_user", stdlib.getpass.getuser())
        } finally {
            EnvSet("USERNAME", saved)
        }
    }

    static BinasciiUsesStdlibNamespace()
    {
        bytes := Buffer(3, 0)
        StrPut("abc", bytes, "UTF-8")

        AhkTest.AssertEqual("616263", StrGet(stdlib.binascii.hexlify(bytes), "UTF-8"))
        AhkTest.AssertEqual("abc", StrGet(stdlib.binascii.unhexlify("616263"), "UTF-8"))
        AhkTest.AssertEqual("YWJj`n", StrGet(stdlib.binascii.b2a_base64(bytes), "UTF-8"))
        AhkTest.AssertEqual("abc", StrGet(stdlib.binascii.a2b_base64("YWJj`n"), "UTF-8"))
    }

    static QuopriUsesStdlibNamespace()
    {
        bytes := Buffer(3, 0)
        StrPut("a b", bytes, "UTF-8")

        AhkTest.AssertEqual("a_b", StrGet(stdlib.quopri.encodestring(bytes, stdlib.False, stdlib.True), "UTF-8"))
        AhkTest.AssertEqual("a b=", StrGet(stdlib.quopri.decodestring("a_b=3D", stdlib.True), "UTF-8"))
    }

    static HtmlUsesStdlibNamespace()
    {
        sample := "<tag>&" Chr(34) "'"

        AhkTest.AssertEqual("&lt;tag&gt;&amp;&quot;&#x27;", stdlib.html.escape(sample))
        AhkTest.AssertEqual("<tag>&'" Chr(34), stdlib.html.unescape("&lt;tag&gt;&amp;&#x27;&quot;"))
    }

    static ContextlibUsesStdlibNamespace()
    {
        nullctx := stdlib.contextlib.nullcontext("seed")
        closer := StdlibBootstrapContextlibCloser()
        suppressCtx := stdlib.contextlib.suppress(ValueError)
        events := []
        stream := stdlib.io.StringIO()
        redirect := stdlib.contextlib.redirect_stdout(stream)
        stack := stdlib.contextlib.ExitStack()
        decorator := stdlib.contextlib.ContextDecorator(StdlibBootstrapContextlibDecoratorCore(events))
        decorated := decorator.Call((value) => stdlib_bootstrap_contextlib_decorated(events, value))

        AhkTest.AssertEqual("seed", nullctx.__enter())
        AhkTest.AssertSame(closer, stdlib.contextlib.closing(closer).__enter())
        AhkTest.AssertTrue(suppressCtx.__exit(ValueError, ValueError("x", -1), stdlib.None))
        AhkTest.AssertSame(stream, redirect.__enter())
        redirect.write("captured")
        AhkTest.AssertFalse(redirect.__exit(stdlib.None, stdlib.None, stdlib.None))
        AhkTest.AssertEqual("captured", stream.getvalue())
        stack.callback(stdlib_bootstrap_contextlib_callback, events, "one")
        stack.callback(stdlib_bootstrap_contextlib_callback, events, "two")
        AhkTest.AssertEqual("entered", stack.enter_context(StdlibBootstrapContextlibStackContext(events)))
        AhkTest.AssertFalse(stack.__exit(stdlib.None, stdlib.None, stdlib.None))
        AhkTest.AssertEqual(42, decorated.Call(21))
        AhkTest.AssertEqual([
            "enter",
            ["exit", stdlib.None],
            ["callback", "two"],
            ["callback", "one"],
            "decorator-enter",
            ["decorated-call", 21],
            ["decorator-exit", stdlib.None]
        ], events)
    }

    static ItertoolsUsesStdlibNamespace()
    {
        values := []

        for value in stdlib.itertools.islice(stdlib.itertools.count(1), 4)
            values.Push(value)
        countOptionValues := stdlib_bootstrap_array(stdlib.itertools.islice(stdlib.itertools.count({ start: 3, step: 2 }), 4))
        splitCountOptionValues := stdlib_bootstrap_array(stdlib.itertools.islice(stdlib.itertools.count({ start: 3 }, { step: 2 }), 4))
        rootTrueZeroStepCount := stdlib_bootstrap_array(stdlib.itertools.islice(stdlib.itertools.count(stdlib.True, stdlib.False), 3))
        rootFalseTrueStepCount := stdlib_bootstrap_array(stdlib.itertools.islice(stdlib.itertools.count(stdlib.False, stdlib.True), 4))

        AhkTest.AssertEqual([1, 2, 3, 4], values)
        AhkTest.AssertEqual([3, 5, 7, 9], countOptionValues)
        AhkTest.AssertEqual([3, 5, 7, 9], splitCountOptionValues)
        AhkTest.AssertSame(stdlib.True, rootTrueZeroStepCount[1])
        AhkTest.AssertEqual([1, 1], [rootTrueZeroStepCount[2], rootTrueZeroStepCount[3]])
        AhkTest.AssertEqual([0, 1, 2, 3], rootFalseTrueStepCount)
        AhkTest.RaisesMatch(TypeError, "count\(\) takes at most 2 arguments \(3 given\)", (*) => stdlib.itertools.count(1, 2, { start: 3 }))
        AhkTest.RaisesMatch(TypeError, "'extra' is an invalid keyword argument for count\(\)", (*) => stdlib.itertools.count({ step: 2, extra: 3 }))
        AhkTest.RaisesMatch(TypeError, "count\(\) takes at most 2 keyword arguments \(3 given\)", (*) => stdlib.itertools.count({ start: 1, step: 2, extra: 3 }))
        AhkTest.RaisesMatch(TypeError, "'extra' is an invalid keyword argument for count\(\)", (*) => stdlib.itertools.count({ extra: 3 }))
        AhkTest.RaisesMatch(TypeError, "'extra' is an invalid keyword argument for count\(\)", (*) => stdlib.itertools.count({ start: 1 }, { extra: 3 }))
        AhkTest.RaisesMatch(TypeError, "count\(\) takes at most 2 keyword arguments \(3 given\)", (*) => stdlib.itertools.count({ start: 1 }, { step: 2, extra: 3 }))
        countReprValues := stdlib.itertools.count(10, 2)
        AhkTest.AssertEqual("count(10, 2)", countReprValues.__Repr())
        AhkTest.AssertEqual([10, 12], stdlib_bootstrap_array(stdlib.itertools.islice(countReprValues, 2)))
        AhkTest.AssertEqual("count(14, 2)", countReprValues.__Repr())
        AhkTest.AssertEqual(["x", "x"], stdlib_bootstrap_array(stdlib.itertools.repeat("x", 2)))
        AhkTest.AssertEqual(["x"], stdlib_bootstrap_array(stdlib.itertools.repeat("x", stdlib.True)))
        AhkTest.AssertEqual([], stdlib_bootstrap_array(stdlib.itertools.repeat("x", stdlib.False)))
        repeatReprValues := stdlib.itertools.repeat("x", 3)
        AhkTest.AssertEqual("repeat('x', 3)", repeatReprValues.__Repr())
        AhkTest.AssertEqual(["x", "x"], stdlib_bootstrap_array(stdlib.itertools.islice(repeatReprValues, 2)))
        AhkTest.AssertEqual("repeat('x', 1)", repeatReprValues.__Repr())
        AhkTest.AssertEqual([1, "a", "b"], stdlib_bootstrap_array(stdlib.itertools.chain([1], "ab")))
        AhkTest.AssertEqual([1, 2, "a", "b"], stdlib_bootstrap_array(stdlib.itertools.chain.from_iterable([[1, 2], "ab"])))
        AhkTest.RaisesMatch(TypeError, "chain\.from_iterable\(\) takes no keyword arguments", (*) => stdlib.itertools.chain.from_iterable({ iterable: [[1]] }))
        AhkTest.RaisesMatch(TypeError, "chain\.from_iterable\(\) takes no keyword arguments", (*) => stdlib.itertools.chain.from_iterable("ab", { iterable: [[1]] }))
        AhkTest.AssertRegex(stdlib.itertools.chain([1]).__Repr(), "^<itertools\.chain object at 0x[0-9A-F]+>$")
        AhkTest.AssertRegex(stdlib.itertools.chain.from_iterable([[1]]).__Repr(), "^<itertools\.chain object at 0x[0-9A-F]+>$")
        AhkTest.AssertEqual(["A", "C"], stdlib_bootstrap_array(stdlib.itertools.compress("ABC", [1, 0, 1])))
        AhkTest.RaisesMatch(TypeError, "compress\(\) missing required argument 'selectors' \(pos 2\)", (*) => stdlib_bootstrap_array(stdlib.itertools.compress({ data: "ABC" })))
        AhkTest.RaisesMatch(TypeError, "compress\(\) missing required argument 'selectors' \(pos 2\)", (*) => stdlib_bootstrap_array(stdlib.itertools.compress({ data: "ABC", extra: 1 })))
        AhkTest.RaisesMatch(TypeError, "compress\(\) missing required argument 'data' \(pos 1\)", (*) => stdlib_bootstrap_array(stdlib.itertools.compress({ selectors: [1, 0, 1] })))
        AhkTest.RaisesMatch(TypeError, "compress\(\) takes at most 2 arguments \(3 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.compress("ABC", [1, 0, 1], { selectors: [1, 1, 1] })))
        AhkTest.RaisesMatch(TypeError, "compress\(\) takes at most 2 keyword arguments \(3 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.compress({ data: "ABC", selectors: [1, 0, 1], extra: 1 })))
        AhkTest.AssertRegex(stdlib.itertools.accumulate([1, 2]).__Repr(), "^<itertools\.accumulate object at 0x[0-9A-F]+>$")
        AhkTest.AssertRegex(stdlib.itertools.compress("ABC", [1, 0, 1]).__Repr(), "^<itertools\.compress object at 0x[0-9A-F]+>$")
        AhkTest.AssertRegex(stdlib.itertools.cycle([1]).__Repr(), "^<itertools\.cycle object at 0x[0-9A-F]+>$")
        AhkTest.AssertRegex(stdlib.itertools.islice([1, 2], 1).__Repr(), "^<itertools\.islice object at 0x[0-9A-F]+>$")
        AhkTest.AssertEqual(["A", "D", "F"], stdlib_bootstrap_array(stdlib.itertools.compress("ABCDEFG", [stdlib.True, stdlib.False, [], [1], Map(), Map("x", 1), stdlib.None])))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.itertools.compress(42, [1]))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.itertools.compress([1], 42))
        AhkTest.AssertEqual([0], stdlib_bootstrap_array(stdlib.itertools.takewhile(stdlib_bootstrap_truthiness_result, [0, 1, 2, 3, 4, 5, 6])))
        AhkTest.AssertEqual([], stdlib_bootstrap_array(stdlib.itertools.takewhile(stdlib.operator.truth, [0, 1, 2])))
        badTakewhilePredicate := stdlib.itertools.takewhile(42, [1])
        AhkTest.RaisesMatch(TypeError, "'int' object is not callable", (*) => stdlib_bootstrap_array(badTakewhilePredicate))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.itertools.takewhile(stdlib_bootstrap_truthiness_result, 42))
        AhkTest.RaisesMatch(TypeError, "takewhile\(\) takes no keyword arguments", (*) => stdlib.itertools.takewhile(stdlib_bootstrap_truthiness_result, { iterable: [1] }))
        AhkTest.AssertEqual([3, 7], stdlib_bootstrap_array(stdlib.itertools.starmap(stdlib_bootstrap_add, [[1, 2], [3, 4]])))
        AhkTest.AssertRegex(stdlib.itertools.starmap(stdlib_bootstrap_add, [[1, 2]]).__Repr(), "^<itertools\.starmap object at 0x[0-9A-F]+>$")
        AhkTest.AssertRegex(stdlib.itertools.takewhile(stdlib_bootstrap_truthiness_result, [0]).__Repr(), "^<itertools\.takewhile object at 0x[0-9A-F]+>$")
        AhkTest.AssertRegex(stdlib.itertools.dropwhile(stdlib_bootstrap_less_than_three, [1]).__Repr(), "^<itertools\.dropwhile object at 0x[0-9A-F]+>$")
        AhkTest.AssertRegex(stdlib.itertools.filterfalse(stdlib.None, [0]).__Repr(), "^<itertools\.filterfalse object at 0x[0-9A-F]+>$")
        badStarmapFunction := stdlib.itertools.starmap(42, [[1, 2]])
        AhkTest.RaisesMatch(TypeError, "'int' object is not callable", (*) => stdlib_bootstrap_array(badStarmapFunction))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.itertools.starmap(stdlib_bootstrap_add, 42))
        AhkTest.RaisesMatch(TypeError, "starmap\(\) takes no keyword arguments", (*) => stdlib.itertools.starmap(stdlib_bootstrap_add, [[1, 2]], { iterable: [[3, 4]] }))
        AhkTest.AssertEqual([0, ""], stdlib_bootstrap_array(stdlib.itertools.filterfalse(stdlib.None, [0, 1, "", "x"])))
        AhkTest.AssertEqual([0], stdlib_bootstrap_array(stdlib.itertools.filterfalse(stdlib.operator.truth, [0, 1, 2])))
        AhkTest.RaisesMatch(TypeError, "filterfalse\(\) takes no keyword arguments", (*) => stdlib.itertools.filterfalse(stdlib_bootstrap_truthiness_result, { iterable: [1] }))
        AhkTest.AssertEqual([3, 1], stdlib_bootstrap_array(stdlib.itertools.dropwhile(stdlib_bootstrap_less_than_three, [1, 2, 3, 1])))
        AhkTest.AssertEqual([0, 1, 2], stdlib_bootstrap_array(stdlib.itertools.dropwhile(stdlib.operator.truth, [0, 1, 2])))
        AhkTest.RaisesMatch(TypeError, "dropwhile\(\) takes no keyword arguments", (*) => stdlib.itertools.dropwhile(stdlib_bootstrap_less_than_three, { iterable: [1] }))
        productRows := stdlib_bootstrap_array(stdlib.itertools.product([1, 2], "ab"))
        productRepeatRows := stdlib_bootstrap_array(stdlib.itertools.product([1, 2], { repeat: 2 }))
        AhkTest.AssertRegex(stdlib.itertools.pairwise([1, 2]).__Repr(), "^<itertools\.pairwise object at 0x[0-9A-F]+>$")
        AhkTest.AssertRegex(stdlib.itertools.product([1], [2]).__Repr(), "^<itertools\.product object at 0x[0-9A-F]+>$")
        AhkTest.AssertEqual([1, "a"], stdlib_bootstrap_array(productRows[1]))
        AhkTest.AssertEqual([2, "b"], stdlib_bootstrap_array(productRows[4]))
        AhkTest.AssertEqual([2, 2], stdlib_bootstrap_array(productRepeatRows[4]))
        AhkTest.RaisesMatch(TypeError, "product\(\) takes at most 1 keyword argument \(2 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.product([1, 2], { repeat: 2, iterables: "x" })))
        AhkTest.RaisesMatch(TypeError, "'iterables' is an invalid keyword argument for product\(\)", (*) => stdlib.itertools.product({ iterables: "x" }))
        AhkTest.RaisesMatch(TypeError, "product\(\) takes at most 1 keyword argument \(2 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.product([1], { repeat: 2 }, { extra: 1 })))
        AhkTest.RaisesMatch(TypeError, "product\(\) takes at most 1 keyword argument \(2 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.product({ repeat: 2 }, { extra: 1 })))
        zipLongestRows := stdlib_bootstrap_array(stdlib.itertools.zip_longest([1, 2, 3], "ab"))
        zipLongestFillRows := stdlib_bootstrap_array(stdlib.itertools.zip_longest([1, 2, 3], "ab", { fillvalue: "X" }))
        AhkTest.RaisesMatch(TypeError, "zip_longest\(\) got an unexpected keyword argument", (*) => stdlib_bootstrap_array(stdlib.itertools.zip_longest([1, 2], [3], { fillvalue: "X", iterables: "Y" })))
        AhkTest.RaisesMatch(TypeError, "zip_longest\(\) got an unexpected keyword argument", (*) => stdlib.itertools.zip_longest({ iterables: "x" }))
        AhkTest.RaisesMatch(TypeError, "zip_longest\(\) got an unexpected keyword argument", (*) => stdlib_bootstrap_array(stdlib.itertools.zip_longest([1], { fillvalue: "X" }, { extra: 1 })))
        AhkTest.RaisesMatch(TypeError, "zip_longest\(\) got an unexpected keyword argument", (*) => stdlib_bootstrap_array(stdlib.itertools.zip_longest({ fillvalue: "X" }, { extra: 1 })))
        AhkTest.AssertRegex(stdlib.itertools.zip_longest([1], [2]).__Repr(), "^<itertools\.zip_longest object at 0x[0-9A-F]+>$")
        AhkTest.AssertEqual([1, "a"], stdlib_bootstrap_array(zipLongestRows[1]))
        AhkTest.AssertEqual([3, stdlib.None], stdlib_bootstrap_array(zipLongestRows[3]))
        AhkTest.AssertEqual([3, "X"], stdlib_bootstrap_array(zipLongestFillRows[3]))
        groupbyRows := stdlib_bootstrap_groupby_pairs(stdlib.itertools.groupby("aabb"))
        groupbyKeyRows := stdlib_bootstrap_groupby_pairs(stdlib.itertools.groupby(["ab", "ac", "ba"], { key: stdlib_bootstrap_first_char }))
        groupbyReprIterator := stdlib.itertools.groupby("a")
        groupbyReprEnum := groupbyReprIterator.__Enum(1)
        groupbyReprRow := unset
        AhkTest.AssertTrue(groupbyReprEnum(&groupbyReprRow))
        groupbyReprValues := stdlib_bootstrap_array(groupbyReprRow)
        AhkTest.AssertRegex(groupbyReprIterator.__Repr(), "^<itertools\.groupby object at 0x[0-9A-F]+>$")
        AhkTest.AssertRegex(groupbyReprValues[2].__Repr(), "^<itertools\._grouper object at 0x[0-9A-F]+>$")
        AhkTest.AssertEqual(["a", ["a", "a"]], groupbyRows[1])
        AhkTest.AssertEqual(["b", ["b", "b"]], groupbyRows[2])
        AhkTest.AssertEqual(["a", ["ab", "ac"]], groupbyKeyRows[1])
        AhkTest.AssertEqual(["b", ["ba"]], groupbyKeyRows[2])
        AhkTest.AssertEqual([["a", ["ab", "ac"]], ["b", ["ba"]]], stdlib_bootstrap_groupby_pairs(stdlib.itertools.groupby({ key: stdlib_bootstrap_first_char }, { iterable: ["ab", "ac", "ba"] })))
        AhkTest.RaisesMatch(TypeError, "groupby\(\) missing required argument 'iterable' \(pos 1\)", (*) => stdlib.itertools.groupby({ key: stdlib_bootstrap_first_char }))
        AhkTest.RaisesMatch(TypeError, "'extra' is an invalid keyword argument for groupby\(\)", (*) => stdlib.itertools.groupby({ iterable: "aab", extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "groupby\(\) takes at most 2 keyword arguments \(3 given\)", (*) => stdlib.itertools.groupby({ iterable: "aab", key: stdlib.None, extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "groupby\(\) takes at most 2 arguments \(3 given\)", (*) => stdlib.itertools.groupby(["ab", "ac"], stdlib_bootstrap_first_char, { key: stdlib_bootstrap_first_char }))
        AhkTest.RaisesMatch(TypeError, "'extra' is an invalid keyword argument for groupby\(\)", (*) => stdlib.itertools.groupby({ extra: 1 }, { iterable: "aab" }))
        AhkTest.RaisesMatch(TypeError, "groupby\(\) missing required argument 'iterable' \(pos 1\)", (*) => stdlib.itertools.groupby({ key: stdlib_bootstrap_first_char }, { extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "groupby\(\) takes at most 2 keyword arguments \(3 given\)", (*) => stdlib.itertools.groupby({ key: stdlib_bootstrap_first_char }, { iterable: "aab", extra: 1 }))
        AhkTest.AssertEqual([[false, [0]], [true, [1]], [false, [0]]], stdlib_bootstrap_groupby_pairs(stdlib.itertools.groupby([0, 1, 0], stdlib.operator.truth)))
        combinationRows := stdlib_bootstrap_array(stdlib.itertools.combinations([1, 2, 3], 2))
        rKeywordCombinationRows := stdlib_bootstrap_array(stdlib.itertools.combinations([1, 2, 3], { r: 2 }))
        iterableKeywordCombinationRows := stdlib_bootstrap_array(stdlib.itertools.combinations({ iterable: [1, 2, 3], r: 2 }))
        splitKeywordCombinationRows := stdlib_bootstrap_array(stdlib.itertools.combinations({ iterable: [1, 2, 3] }, { r: 2 }))
        rootTrueCombinationRows := stdlib_bootstrap_array(stdlib.itertools.combinations([1, 2], stdlib.True))
        rootFalseCombinationRows := stdlib_bootstrap_array(stdlib.itertools.combinations([1, 2], stdlib.False))
        AhkTest.AssertEqual([1, 2], stdlib_bootstrap_array(combinationRows[1]))
        AhkTest.AssertEqual([2, 3], stdlib_bootstrap_array(combinationRows[3]))
        AhkTest.AssertEqual([1, 2], stdlib_bootstrap_array(rKeywordCombinationRows[1]))
        AhkTest.AssertEqual([2, 3], stdlib_bootstrap_array(iterableKeywordCombinationRows[3]))
        AhkTest.AssertEqual([2, 3], stdlib_bootstrap_array(splitKeywordCombinationRows[3]))
        AhkTest.RaisesMatch(TypeError, "combinations\(\) missing required argument 'iterable' \(pos 1\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations({ r: 2 })))
        AhkTest.RaisesMatch(TypeError, "combinations\(\) missing required argument 'r' \(pos 2\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations([1, 2, 3], { iterable: [4, 5] })))
        AhkTest.RaisesMatch(TypeError, "combinations\(\) missing required argument 'r' \(pos 2\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations({ iterable: [1, 2], extra: 1 })))
        AhkTest.RaisesMatch(TypeError, "combinations\(\) missing required argument 'r' \(pos 2\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations({ extra: 1 }, { iterable: [1, 2] })))
        AhkTest.RaisesMatch(TypeError, "combinations\(\) takes at most 2 keyword arguments \(3 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations({ iterable: [1, 2], r: 2, extra: 1 })))
        AhkTest.RaisesMatch(TypeError, "combinations\(\) takes at most 2 keyword arguments \(3 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations({ r: 2 }, { iterable: [1, 2], extra: 1 })))
        AhkTest.RaisesMatch(TypeError, "combinations\(\) takes at most 2 arguments \(3 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations([1, 2, 3], 2, { iterable: [4, 5] })))
        AhkTest.RaisesMatch(TypeError, "combinations\(\) takes at most 2 arguments \(3 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations([1, 2], { r: 1, extra: 1 })))
        AhkTest.AssertEqual([1], stdlib_bootstrap_array(rootTrueCombinationRows[1]))
        AhkTest.AssertEqual([2], stdlib_bootstrap_array(rootTrueCombinationRows[2]))
        AhkTest.AssertEqual([], stdlib_bootstrap_array(rootFalseCombinationRows[1]))
        replacementRows := stdlib_bootstrap_array(stdlib.itertools.combinations_with_replacement([1, 2], 2))
        rKeywordReplacementRows := stdlib_bootstrap_array(stdlib.itertools.combinations_with_replacement([1, 2, 3], { r: 2 }))
        iterableKeywordReplacementRows := stdlib_bootstrap_array(stdlib.itertools.combinations_with_replacement({ iterable: [1, 2, 3], r: 2 }))
        splitKeywordReplacementRows := stdlib_bootstrap_array(stdlib.itertools.combinations_with_replacement({ iterable: [1, 2, 3] }, { r: 2 }))
        AhkTest.AssertRegex(stdlib.itertools.combinations([1, 2], 1).__Repr(), "^<itertools\.combinations object at 0x[0-9A-F]+>$")
        AhkTest.AssertRegex(stdlib.itertools.combinations_with_replacement([1, 2], 1).__Repr(), "^<itertools\.combinations_with_replacement object at 0x[0-9A-F]+>$")
        rootTrueReplacementRows := stdlib_bootstrap_array(stdlib.itertools.combinations_with_replacement([1, 2], stdlib.True))
        rootFalseReplacementRows := stdlib_bootstrap_array(stdlib.itertools.combinations_with_replacement([1, 2], stdlib.False))
        AhkTest.AssertEqual([1, 1], stdlib_bootstrap_array(replacementRows[1]))
        AhkTest.AssertEqual([2, 2], stdlib_bootstrap_array(replacementRows[3]))
        AhkTest.AssertEqual([1, 1], stdlib_bootstrap_array(rKeywordReplacementRows[1]))
        AhkTest.AssertEqual([3, 3], stdlib_bootstrap_array(iterableKeywordReplacementRows[6]))
        AhkTest.AssertEqual([3, 3], stdlib_bootstrap_array(splitKeywordReplacementRows[6]))
        AhkTest.RaisesMatch(TypeError, "combinations_with_replacement\(\) missing required argument 'iterable' \(pos 1\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations_with_replacement({ r: 2 })))
        AhkTest.RaisesMatch(TypeError, "combinations_with_replacement\(\) missing required argument 'r' \(pos 2\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations_with_replacement([1, 2, 3], { iterable: [4, 5] })))
        AhkTest.RaisesMatch(TypeError, "combinations_with_replacement\(\) missing required argument 'r' \(pos 2\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations_with_replacement({ extra: 1 }, { iterable: [1, 2] })))
        AhkTest.RaisesMatch(TypeError, "combinations_with_replacement\(\) takes at most 2 keyword arguments \(3 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations_with_replacement({ iterable: [1, 2], r: 2, extra: 1 })))
        AhkTest.RaisesMatch(TypeError, "combinations_with_replacement\(\) takes at most 2 keyword arguments \(3 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations_with_replacement({ r: 2 }, { iterable: [1, 2], extra: 1 })))
        AhkTest.RaisesMatch(TypeError, "combinations_with_replacement\(\) takes at most 2 arguments \(3 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations_with_replacement([1, 2, 3], 2, { iterable: [4, 5] })))
        AhkTest.RaisesMatch(TypeError, "combinations_with_replacement\(\) takes at most 2 arguments \(3 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.combinations_with_replacement([1, 2], { r: 1, extra: 1 })))
        AhkTest.AssertEqual([1], stdlib_bootstrap_array(rootTrueReplacementRows[1]))
        AhkTest.AssertEqual([2], stdlib_bootstrap_array(rootTrueReplacementRows[2]))
        AhkTest.AssertEqual([], stdlib_bootstrap_array(rootFalseReplacementRows[1]))
        permutationRows := stdlib_bootstrap_array(stdlib.itertools.permutations([1, 2, 3], 2))
        AhkTest.AssertRegex(stdlib.itertools.permutations([1, 2]).__Repr(), "^<itertools\.permutations object at 0x[0-9A-F]+>$")
        rKeywordPermutationRows := stdlib_bootstrap_array(stdlib.itertools.permutations([1, 2, 3], { r: 2 }))
        iterableKeywordPermutationRows := stdlib_bootstrap_array(stdlib.itertools.permutations({ iterable: [1, 2, 3], r: 2 }))
        splitKeywordPermutationRows := stdlib_bootstrap_array(stdlib.itertools.permutations({ iterable: [1, 2, 3] }, { r: 2 }))
        rootTruePermutationRows := stdlib_bootstrap_array(stdlib.itertools.permutations([1, 2], stdlib.True))
        rootFalsePermutationRows := stdlib_bootstrap_array(stdlib.itertools.permutations([1, 2], stdlib.False))
        AhkTest.AssertEqual([1, 2], stdlib_bootstrap_array(permutationRows[1]))
        AhkTest.AssertEqual([3, 2], stdlib_bootstrap_array(permutationRows[6]))
        AhkTest.AssertEqual([1, 2], stdlib_bootstrap_array(rKeywordPermutationRows[1]))
        AhkTest.AssertEqual([3, 2], stdlib_bootstrap_array(iterableKeywordPermutationRows[6]))
        AhkTest.AssertEqual([3, 2], stdlib_bootstrap_array(splitKeywordPermutationRows[6]))
        AhkTest.RaisesMatch(TypeError, "permutations\(\) missing required argument 'iterable' \(pos 1\)", (*) => stdlib_bootstrap_array(stdlib.itertools.permutations({ r: 2 })))
        AhkTest.RaisesMatch(TypeError, "'extra' is an invalid keyword argument for permutations\(\)", (*) => stdlib_bootstrap_array(stdlib.itertools.permutations({ extra: 1 }, { iterable: [1, 2, 3] })))
        AhkTest.RaisesMatch(TypeError, "permutations\(\) takes at most 2 keyword arguments \(3 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.permutations({ r: 2 }, { iterable: [1, 2, 3], extra: 1 })))
        AhkTest.RaisesMatch(TypeError, "'extra' is an invalid keyword argument for permutations\(\)", (*) => stdlib_bootstrap_array(stdlib.itertools.permutations({ iterable: [1, 2], extra: 1 })))
        AhkTest.RaisesMatch(TypeError, "argument for permutations\(\) given by name \('iterable'\) and position \(1\)", (*) => stdlib_bootstrap_array(stdlib.itertools.permutations([1, 2, 3], { iterable: [4, 5] })))
        AhkTest.RaisesMatch(TypeError, "permutations\(\) takes at most 2 arguments \(3 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.permutations([1, 2, 3], 2, { iterable: [4, 5] })))
        AhkTest.RaisesMatch(TypeError, "permutations\(\) takes at most 2 arguments \(3 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.permutations([1, 2], { r: 1, extra: 1 })))
        AhkTest.AssertEqual([1], stdlib_bootstrap_array(rootTruePermutationRows[1]))
        AhkTest.AssertEqual([2], stdlib_bootstrap_array(rootTruePermutationRows[2]))
        AhkTest.AssertEqual([], stdlib_bootstrap_array(rootFalsePermutationRows[1]))
        AhkTest.AssertEqual([1, 3, 6], stdlib_bootstrap_array(stdlib.itertools.accumulate([1, 2, 3])))
        AhkTest.AssertEqual([1, 3, 6], stdlib_bootstrap_array(stdlib.itertools.accumulate({ iterable: [1, 2, 3] })))
        AhkTest.AssertEqual([1, 2, 6], stdlib_bootstrap_array(stdlib.itertools.accumulate([1, 2, 3], { func: stdlib_bootstrap_itertools_mul })))
        AhkTest.AssertEqual([10, 10, 20, 60], stdlib_bootstrap_array(stdlib.itertools.accumulate([1, 2, 3], { func: stdlib_bootstrap_itertools_mul, initial: 10 })))
        AhkTest.RaisesMatch(TypeError, "argument for accumulate\(\) given by name \('func'\) and position \(2\)", (*) => stdlib_bootstrap_array(stdlib.itertools.accumulate([1, 2, 3], stdlib_bootstrap_itertools_mul, { func: stdlib_bootstrap_itertools_mul })))
        AhkTest.RaisesMatch(TypeError, "accumulate\(\) missing required argument 'iterable' \(pos 1\)", (*) => stdlib.itertools.accumulate({ func: stdlib_bootstrap_itertools_mul }))
        AhkTest.RaisesMatch(TypeError, "'extra' is an invalid keyword argument for accumulate\(\)", (*) => stdlib.itertools.accumulate({ iterable: [1, 2], extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "accumulate\(\) takes at most 3 keyword arguments \(4 given\)", (*) => stdlib.itertools.accumulate({ iterable: [1, 2], func: stdlib_bootstrap_itertools_mul, initial: 0, extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "accumulate\(\) missing required argument 'iterable' \(pos 1\)", (*) => stdlib.itertools.accumulate({ extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "accumulate\(\) takes at most 3 keyword arguments \(4 given\)", (*) => stdlib.itertools.accumulate({ extra: 1, another: 2, third: 3, fourth: 4 }))
        AhkTest.RaisesMatch(TypeError, "'extra' is an invalid keyword argument for accumulate\(\)", (*) => stdlib_bootstrap_array(stdlib.itertools.accumulate([1, 2], { func: stdlib_bootstrap_itertools_mul, extra: 1 })))
        AhkTest.RaisesMatch(TypeError, "'extra' is an invalid keyword argument for accumulate\(\)", (*) => stdlib_bootstrap_array(stdlib.itertools.accumulate([1, 2], { initial: 0, extra: 1 })))
        AhkTest.RaisesMatch(TypeError, "accumulate\(\) takes at most 3 arguments \(4 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.accumulate([1, 2], { func: stdlib_bootstrap_itertools_mul, initial: 0, extra: 1 })))
        AhkTest.RaisesMatch(TypeError, "accumulate\(\) takes at most 3 arguments \(4 given\)", (*) => stdlib_bootstrap_array(stdlib.itertools.accumulate([1, 2], { iterable: [3, 4], func: stdlib_bootstrap_itertools_mul, initial: 0 })))
        AhkTest.AssertEqual([1, 2, 6], stdlib_bootstrap_array(stdlib.itertools.accumulate([1, 2, 3], stdlib.operator.mul)))
        AhkTest.AssertEqual([10, 10, 20, 60], stdlib_bootstrap_array(stdlib.itertools.accumulate({ iterable: [1, 2, 3], func: stdlib_bootstrap_itertools_mul, initial: 10 })))
        AhkTest.AssertEqual([10, 11, 13], stdlib_bootstrap_array(stdlib.itertools.accumulate([1, 2], { initial: 10 })))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.itertools.accumulate(42))
        AhkTest.RaisesMatch(TypeError, "argument for accumulate\(\) given by name \('iterable'\) and position \(1\)", (*) => stdlib.itertools.accumulate([1, 2, 3], { iterable: [4, 5] }))
        lazyBadFuncAccumulate := stdlib.itertools.accumulate([1, 2], 42)
        lazyBadFuncIterator := lazyBadFuncAccumulate.__Enum(1)
        lazyBadFuncFirst := unset
        AhkTest.AssertTrue(lazyBadFuncIterator(&lazyBadFuncFirst))
        AhkTest.AssertEqual(1, lazyBadFuncFirst)
        AhkTest.RaisesMatch(TypeError, "'int' object is not callable", (*) => lazyBadFuncIterator(&lazyBadFuncFirst))
        lazyTruthInitialAccumulate := stdlib.itertools.accumulate([1, 2], stdlib.operator.truth, { initial: 10 })
        lazyTruthInitialIterator := lazyTruthInitialAccumulate.__Enum(1)
        lazyTruthInitialFirst := unset
        AhkTest.AssertTrue(lazyTruthInitialIterator(&lazyTruthInitialFirst))
        AhkTest.AssertEqual(10, lazyTruthInitialFirst)
        AhkTest.RaisesMatch(TypeError, "_operator\.truth\(\) takes exactly one argument \(2 given\)", (*) => lazyTruthInitialIterator(&lazyTruthInitialFirst))
        AhkTest.AssertEqual([3, 7], stdlib_bootstrap_array(stdlib.itertools.starmap(stdlib.operator.add, [[1, 2], [3, 4]])))
        AhkTest.AssertEqual([1, 2, 1, 2], stdlib_bootstrap_array(stdlib.itertools.islice(stdlib.itertools.cycle([1, 2]), 4)))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.itertools.cycle(42))
        pairwiseRows := stdlib_bootstrap_array(stdlib.itertools.pairwise([1, 2, 3]))
        AhkTest.AssertEqual([1, 2], stdlib_bootstrap_array(pairwiseRows[1]))
        AhkTest.AssertEqual([2, 3], stdlib_bootstrap_array(pairwiseRows[2]))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.itertools.pairwise(42))
        AhkTest.RaisesMatch(TypeError, "pairwise\(\) takes no keyword arguments", (*) => stdlib.itertools.pairwise({ iterable: [1, 2] }))
        AhkTest.RaisesMatch(TypeError, "pairwise\(\) takes no keyword arguments", (*) => stdlib.itertools.pairwise([1, 2], { iterable: [3, 4] }))
        teeCopies := stdlib.itertools.tee([1, 2, 3], 2)
        rootTrueTeeCopies := stdlib.itertools.tee([7, 8], stdlib.True)
        rootFalseTeeCopies := stdlib.itertools.tee(42, stdlib.False)
        teeCloneType := teeCopies[1].__class
        AhkTest.AssertTrue(teeCopies is AhkStdlibTuple)
        AhkTest.AssertEqual([1, 2, 3], stdlib_bootstrap_array(teeCopies[1]))
        AhkTest.AssertEqual([1, 2, 3], stdlib_bootstrap_array(teeCopies[2]))
        AhkTest.AssertRegex(teeCopies[1].__Repr(), "^<itertools\._tee object at 0x[0-9A-F]+>$")
        AhkTest.RaisesMatch(TypeError, "does not support item assignment|readonly", (*) => teeCopies[1] := "x")
        AhkTest.AssertEqual(1, rootTrueTeeCopies.Length)
        AhkTest.AssertEqual([7, 8], stdlib_bootstrap_array(rootTrueTeeCopies[1]))
        AhkTest.AssertEqual([], rootFalseTeeCopies)
        AhkTest.RaisesMatch(TypeError, "tee expected at least 1 argument, got 0", (*) => stdlib.itertools.tee())
        AhkTest.RaisesMatch(TypeError, "tee expected at most 2 arguments, got 3", (*) => stdlib.itertools.tee([1], 1, 2))
        AhkTest.RaisesMatch(TypeError, "'bool' object is not iterable", (*) => stdlib.itertools.tee(stdlib.True, 1))
        AhkTest.RaisesMatch(TypeError, "'bool' object is not iterable", (*) => stdlib.itertools.tee(stdlib.False, 1))
        AhkTest.RaisesMatch(TypeError, "_tee\(\) takes no keyword arguments", (*) => teeCloneType({ iterable: "abc" }))
        AhkTest.RaisesMatch(TypeError, "_tee\(\) takes no keyword arguments", (*) => teeCloneType("abc", { iterable: "def" }))
        AhkTest.RaisesMatch(TypeError, "'tuple' object cannot be interpreted as an integer", (*) => stdlib.itertools.tee([1], stdlib.tuple()))
        AhkTest.RaisesMatch(TypeError, "itertools\.tee\(\) takes no keyword arguments", (*) => stdlib.itertools.tee({ n: 3 }))
        AhkTest.RaisesMatch(TypeError, "itertools\.tee\(\) takes no keyword arguments", (*) => stdlib.itertools.tee([1], { n: 3 }))
        AhkTest.RaisesMatch(TypeError, "itertools\.tee\(\) takes no keyword arguments", (*) => stdlib.itertools.tee([1, 2], { iterable: [3, 4] }))
        AhkTest.RaisesMatch(TypeError, "itertools\.tee\(\) takes no keyword arguments", (*) => stdlib.itertools.tee([1, 2], 2, { n: 3 }))
        AhkTest.RaisesMatch(TypeError, "islice\(\) takes no keyword arguments", (*) => stdlib.itertools.islice([1, 2, 3], { stop: 2 }))
        AhkTest.AssertEqual([2, 4], stdlib_bootstrap_array(stdlib.itertools.islice([1, 2, 3, 4], 1, stdlib.None, 2)))
        AhkTest.AssertEqual([1, 3], stdlib_bootstrap_array(stdlib.itertools.islice([1, 2, 3, 4], stdlib.None, stdlib.None, 2)))
        AhkTest.AssertEqual([1], stdlib_bootstrap_array(stdlib.itertools.islice([1, 2, 3], stdlib.True)))
        AhkTest.AssertEqual([1], stdlib_bootstrap_array(stdlib.itertools.islice([1, 2, 3], stdlib.False, stdlib.True)))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.itertools.islice(42, 2))
        AhkTest.RaisesMatch(ValueError, "Stop argument for islice\(\) must be None or an integer: 0 <= x <= sys\.maxsize\.", (*) => stdlib.itertools.islice(42, -1))
        AhkTest.RaisesMatch(ValueError, "Stop argument for islice\(\) must be None or an integer: 0 <= x <= sys\.maxsize\.", (*) => stdlib.itertools.islice([1, 2, 3], 1, 2.0))
        AhkTest.RaisesMatch(ValueError, "Step for islice\(\) must be a positive integer or None\.", (*) => stdlib.itertools.islice([1, 2, 3], 0, 3, stdlib.False))
        AhkTest.AssertSame(stdlib.None, stdlib.None)
    }

    static RootNamespaceExposesTupleBuiltin()
    {
        empty := stdlib.tuple()
        letters := stdlib.tuple("ab")
        values := stdlib.tuple([1, 2, 3])
        wrapped := stdlib.tuple(values)

        AhkTest.AssertEqual([], empty)
        AhkTest.AssertEqual(["a", "b"], letters)
        AhkTest.AssertEqual([1, 2, 3], values)
        AhkTest.AssertSame(values, wrapped)
        AhkTest.AssertEqual(3, values.Length)
        AhkTest.AssertEqual(0, empty.Length)
        AhkTest.RaisesMatch(TypeError, "does not support item assignment", (*) => values[1] := 9)
        AhkTest.RaisesMatch(TypeError, "'NoneType' object is not iterable", (*) => stdlib.tuple(stdlib.None))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.tuple(42))
        AhkTest.RaisesMatch(TypeError, "'object' object is not iterable", (*) => stdlib.tuple({}))
    }

    static RootNamespaceExposesSliceBuiltin()
    {
        stopOnly := stdlib.slice(3)
        bounded := stdlib.slice(1, 4)
        stepped := stdlib.slice(1, 5, 2)
        reversed := stdlib.slice(stdlib.None, stdlib.None, -1)
        negativeBounds := stdlib.slice(-4, -1)

        AhkTest.AssertSame(stdlib.None, stopOnly.start)
        AhkTest.AssertEqual(3, stopOnly.stop)
        AhkTest.AssertSame(stdlib.None, stopOnly.step)
        AhkTest.AssertEqual("slice(None, 3, None)", stopOnly.__Repr())
        AhkTest.AssertEqual([0, 3, 1], stopOnly.indices(5))
        AhkTest.AssertEqual([1, 4, 1], bounded.indices(5))
        AhkTest.AssertEqual([1, 5, 2], stepped.indices(5))
        AhkTest.AssertEqual([4, -1, -1], reversed.indices(5))
        AhkTest.AssertEqual([1, 4, 1], negativeBounds.indices(5))
        AhkTest.RaisesMatch(ValueError, "^slice step cannot be zero$", (*) => stdlib.slice(stdlib.None, stdlib.None, 0).indices(5))
    }

    static RootNamespaceExposesBooleanBuiltins()
    {
        AhkTest.AssertSame(stdlib.True, stdlib.True)
        AhkTest.AssertSame(stdlib.False, stdlib.False)
        AhkTest.AssertTrue(stdlib.True !== stdlib.False)
        AhkTest.AssertSame(stdlib.True, stdlib.json.True)
        AhkTest.AssertSame(stdlib.False, stdlib.json.False)
        AhkTest.AssertSame(stdlib.True, stdlib.json.Bool(stdlib.True))
        AhkTest.AssertSame(stdlib.False, stdlib.json.Bool(stdlib.False))
        AhkTest.AssertEqual("true", stdlib.json.dumps(stdlib.True))
        AhkTest.AssertEqual("false", stdlib.json.dumps(stdlib.False))
        AhkTest.AssertEqual("[true, false]", stdlib.json.dumps([stdlib.True, stdlib.False]))
        AhkTest.AssertSame(stdlib.True, stdlib.json.loads("true"))
        AhkTest.AssertSame(stdlib.False, stdlib.json.loads("false"))
    }

    static RootNamespaceExposesNotImplementedBuiltin()
    {
        AhkTest.AssertSame(stdlib.NotImplemented, stdlib.NotImplemented)
        AhkTest.RaisesMatch(TypeError, "'NotImplementedType' object is not iterable", (*) => stdlib.tuple(stdlib.NotImplemented))
        AhkTest.RaisesMatch(TypeError, "'NotImplementedType' object cannot be interpreted as an integer", (*) => stdlib.itertools.repeat("x", stdlib.NotImplemented))
        AhkTest.RaisesMatch(TypeError, "'NotImplementedType' object cannot be interpreted as an integer", (*) => stdlib.itertools.product([1], { repeat: stdlib.NotImplemented }))
        AhkTest.RaisesMatch(TypeError, "'NotImplementedType' object cannot be interpreted as an integer", (*) => stdlib.itertools.combinations([1], stdlib.NotImplemented))
    }

    static RootNamespaceExposesErrorBuiltins()
    {
        runtimeError := stdlib.RuntimeError("boom", -1)
        stopIteration := stdlib.StopIteration("done", -1)
        notImplementedError := stdlib.NotImplementedError("todo", -1)
        systemError := stdlib.SystemError("internal", -1)
        keyError := stdlib.KeyError("missing", -1)
        attributeError := stdlib.AttributeError("no attr", -1)
        moduleNotFoundError := stdlib.ModuleNotFoundError("No module named 'pwd'", -1)
        overflowError := stdlib.OverflowError("too large", -1)
        eofError := stdlib.EOFError("read() didn't return enough bytes", -1)
        processLookupError := stdlib.ProcessLookupError("", -1)

        AhkTest.AssertTrue(runtimeError is stdlib.RuntimeError)
        AhkTest.AssertTrue(runtimeError is Error)
        AhkTest.AssertEqual("boom", runtimeError.Message)
        AhkTest.AssertTrue(stopIteration is stdlib.StopIteration)
        AhkTest.AssertTrue(stopIteration is Error)
        AhkTest.AssertEqual("done", stopIteration.Message)
        AhkTest.AssertTrue(notImplementedError is stdlib.NotImplementedError)
        AhkTest.AssertTrue(notImplementedError is Error)
        AhkTest.AssertEqual("todo", notImplementedError.Message)
        AhkTest.AssertTrue(systemError is stdlib.SystemError)
        AhkTest.AssertTrue(systemError is Error)
        AhkTest.AssertEqual("internal", systemError.Message)
        AhkTest.AssertTrue(keyError is stdlib.KeyError)
        AhkTest.AssertTrue(keyError is Error)
        AhkTest.AssertEqual("missing", keyError.Message)
        AhkTest.AssertTrue(attributeError is stdlib.AttributeError)
        AhkTest.AssertTrue(attributeError is Error)
        AhkTest.AssertEqual("no attr", attributeError.Message)
        AhkTest.AssertTrue(moduleNotFoundError is stdlib.ModuleNotFoundError)
        AhkTest.AssertTrue(moduleNotFoundError is Error)
        AhkTest.AssertEqual("No module named 'pwd'", moduleNotFoundError.Message)
        AhkTest.AssertTrue(overflowError is stdlib.OverflowError)
        AhkTest.AssertTrue(overflowError is Error)
        AhkTest.AssertEqual("too large", overflowError.Message)
        AhkTest.AssertTrue(eofError is stdlib.EOFError)
        AhkTest.AssertTrue(eofError is Error)
        AhkTest.AssertEqual("read() didn't return enough bytes", eofError.Message)
        AhkTest.AssertTrue(processLookupError is stdlib.ProcessLookupError)
        AhkTest.AssertTrue(processLookupError is OSError)
        AhkTest.AssertEqual("", processLookupError.Message)
    }

    static RootNamespaceAwaitRunsAsyncioAwaitables()
    {
        eventLoop := stdlib.asyncio.new_event_loop()
        future := eventLoop.create_future()
        future.set_result("future-value")

        AhkTest.AssertEqual("future-value", stdlib.await(future, { loop: eventLoop }))
        AhkTest.AssertEqual("task-result", stdlib.await(StdlibBootstrapAwaitTaskBody()))
        AhkTest.RaisesMatch(RuntimeError, "^stdlib\.await\(\) cannot block while an asyncio loop is already running$", (*) => stdlib.asyncio.run(StdlibBootstrapNestedAwaitBody()))
    }

    static RootNamespaceDecorateAppliesDecoratorOrder()
    {
        events := []
        value := (*) => stdlib_bootstrap_decorated_value(events)
        outer := stdlib_bootstrap_decorator("outer", events)
        inner := stdlib_bootstrap_decorator("inner", events)

        decorated := stdlib.decorate(value, outer, inner)
        classLike := stdlib.decorate(StdlibBootstrapDecoratedTarget, (target) => {
            target: target,
            label: "decorated"
        })

        AhkTest.AssertEqual("outer(inner(value))", decorated.Call())
        AhkTest.AssertEqual(["apply:inner", "apply:outer", "call:outer", "call:inner", "call:value"], events)
        AhkTest.AssertEqual("decorated", classLike.label)
        AhkTest.AssertSame(StdlibBootstrapDecoratedTarget, classLike.target)
    }

    static FunctoolsUsesStdlibNamespace()
    {
        addTwo := stdlib.functools.partial(stdlib_bootstrap_add, 2)
        addTwoThree := stdlib.functools.partial(addTwo, 3)
        addOne := stdlib.functools.partial(stdlib_bootstrap_add_three, 1)
        statefulPartial := stdlib.functools.partial(stdlib_bootstrap_add, 2)
        observedArgs := addTwoThree.args

        AhkTest.AssertEqual(10, stdlib.functools.reduce(stdlib_bootstrap_add, [1, 2, 3, 4]))
        AhkTest.AssertEqual(5, addTwo.Call(3))
        AhkTest.AssertSame(stdlib_bootstrap_add, addTwoThree.func)
        AhkTest.AssertSame(observedArgs, addTwoThree.args)
        AhkTest.AssertEqual([2, 3], addTwoThree.args)
        AhkTest.RaisesMatch(TypeError, "does not support item assignment|readonly", (*) => observedArgs[1] := 99)
        AhkTest.AssertEqual(5, addTwoThree.Call())
        AhkTest.AssertEqual("functools", addTwo.__module)
        AhkTest.AssertEqual("partial(func, *args, **keywords) - new function with partial application`n    of the given arguments and keywords.`n", addTwo.__doc)
        AhkTest.AssertTrue(addTwo.__dict is Map)
        AhkTest.AssertEqual(0, addTwo.__dict.Count)
        AhkTest.AssertSame(addTwo.__dict, addTwo.__dict)
        addTwo.custom := 42
        AhkTest.AssertEqual(42, addTwo.custom)
        AhkTest.AssertTrue(addTwo.__dict.Has("custom"))
        AhkTest.AssertEqual(42, addTwo.__dict["custom"])
        AhkTest.RaisesMatch(TypeError, "__dict must be set to a dictionary, not a 'int'", (*) => addTwo.__dict := 5)
        AhkTest.RaisesMatch(TypeError, "__dict must be set to a dictionary, not a 'list'", (*) => addTwo.__dict := [])
        AhkTest.RaisesMatch(TypeError, "__dict must be set to a dictionary, not a 'NoneType'", (*) => addTwo.__dict := stdlib.None)
        reducedPartial := statefulPartial.__reduce()
        reducedPartialState := reducedPartial[3]
        AhkTest.AssertTrue(reducedPartial is AhkStdlibTuple)
        AhkTest.AssertEqual(3, reducedPartial.Length)
        AhkTest.AssertSame(AhkStdlibFunctoolsPartial, reducedPartial[1])
        AhkTest.AssertEqual([stdlib_bootstrap_add], reducedPartial[2])
        AhkTest.AssertTrue(reducedPartialState is AhkStdlibTuple)
        AhkTest.AssertEqual(4, reducedPartialState.Length)
        AhkTest.AssertSame(stdlib_bootstrap_add, reducedPartialState[1])
        AhkTest.AssertEqual([2], reducedPartialState[2])
        AhkTest.AssertTrue(reducedPartialState[3] is Map)
        AhkTest.AssertEqual(0, reducedPartialState[3].Count)
        AhkTest.AssertSame(stdlib.None, reducedPartialState[4])
        statefulPartial.__setstate(stdlib.tuple([stdlib_bootstrap_add, stdlib.tuple([2]), Map("b", 5), stdlib.None]))
        AhkTest.AssertEqual([2], statefulPartial.args)
        AhkTest.AssertEqual(5, statefulPartial.keywords["b"])
        AhkTest.AssertEqual(7, statefulPartial.Call())
        statefulPartial.__setstate(stdlib.tuple([stdlib_bootstrap_add, stdlib.tuple([2]), Map("b", 5), []]))
        AhkTest.AssertEqual(0, statefulPartial.__dict.Length)
        AhkTest.AssertEqual(7, statefulPartial.Call())
        statefulPartial.__setstate(stdlib.tuple([stdlib_bootstrap_add, stdlib.tuple([2]), Map("b", 5), stdlib.tuple()]))
        AhkTest.AssertEqual(0, statefulPartial.__dict.Length)
        AhkTest.AssertEqual(7, statefulPartial.Call())
        statefulPartial.__setstate(stdlib.tuple([stdlib_bootstrap_add, stdlib.tuple([2]), stdlib.None, stdlib.None]))
        AhkTest.AssertTrue(statefulPartial.keywords is Map)
        AhkTest.AssertEqual(0, statefulPartial.keywords.Count)
        AhkTest.AssertTrue(statefulPartial.__dict is Map)
        AhkTest.AssertEqual(0, statefulPartial.__dict.Count)
        AhkTest.AssertEqual(7, statefulPartial.Call(5))
        statefulPartial.__setstate(stdlib.tuple([stdlib_bootstrap_add, stdlib.tuple([2]), stdlib.None, 5]))
        AhkTest.AssertTrue(statefulPartial.keywords is Map)
        AhkTest.AssertEqual(0, statefulPartial.keywords.Count)
        AhkTest.AssertEqual(5, statefulPartial.__dict)
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => statefulPartial.custom := 42)
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => statefulPartial.custom)
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => statefulPartial.DeleteProp("custom"))
        AhkTest.AssertEqual(7, statefulPartial.Call(5))
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => statefulPartial.__reduce())
        AhkTest.RaisesMatch(TypeError, "partial\.__setstate\(\) takes exactly one argument \(0 given\)", (*) => statefulPartial.__setstate())
        AhkTest.RaisesMatch(TypeError, "invalid partial state", (*) => statefulPartial.__setstate(42))
        AhkTest.AssertRegex(stdlib.functools.partial(stdlib_bootstrap_add, stdlib.True, stdlib.False).__Repr(), "^functools\.partial\(<function stdlib_bootstrap_add at 0x[0-9A-F]+>, True, False\)$")
        addOne.keywords["c"] := 5
        AhkTest.AssertEqual(8, addOne.Call(2))
        AhkTest.RaisesMatch(TypeError, "type 'partial' takes at least one argument", (*) => stdlib.functools.partial())
        AhkTest.RaisesMatch(TypeError, "the first argument must be callable", (*) => stdlib.functools.partial(42))
        AhkTest.RaisesMatch(TypeError, "'bool' object is not callable", (*) => stdlib.functools.reduce(stdlib.True, [1, 2]))
        AhkTest.RaisesMatch(TypeError, "'bool' object is not callable", (*) => stdlib.functools.reduce(stdlib.False, [1, 2]))
        AhkTest.RaisesMatch(TypeError, "'tuple' object is not callable", (*) => stdlib.functools.reduce(stdlib.tuple(), [1, 2]))
    }

    static CalendarUsesStdlibNamespace()
    {
        AhkTest.AssertTrue(stdlib.calendar.isleap(2024))
        AhkTest.AssertEqual([3, 29], stdlib.calendar.monthrange(2024, 2))
        AhkTest.AssertEqual(3, stdlib.calendar.weekday(2024, 2, 29))
        AhkTest.AssertEqual([0, 0, 0, 1, 2, 3, 4], stdlib.calendar.monthcalendar(2024, 2)[1])
        AhkTest.AssertEqual("Mo Tu We Th Fr Sa Su", stdlib.calendar.weekheader(2))
        AhkTest.AssertEqual("Monday", stdlib.calendar.day_name[0])
        AhkTest.AssertEqual("Feb", stdlib.calendar.month_abbr[2])
        AhkTest.AssertEqual(1709168523, stdlib.calendar.timegm([2024, 2, 29, 1, 2, 3]))

        calendar := stdlib.calendar.Calendar(stdlib.calendar.SUNDAY)
        AhkTest.AssertEqual([6, 0, 1, 2, 3, 4, 5], stdlib_bootstrap_array(calendar.iterweekdays()))
        AhkTest.AssertEqual([0, 0, 0, 0, 1, 2, 3], calendar.monthdayscalendar(2024, 2)[1])
    }

    static CollectionsUsesStdlibNamespace()
    {
        counter := stdlib.collections.Counter(Map("a", 1))
        kwargsCounter := stdlib.collections.Counter("ab", { kwargs: Map("a", 2, "c", 3) })
        kwargsUpdateCounter := stdlib.collections.Counter("a")
        kwargsSubtractCounter := stdlib.collections.Counter("a")
        elements := counter.elements()
        iterator := elements.__Enum(1)
        first := unset
        mixedLeft := stdlib.collections.Counter(Map("a", "x"))
        mixedRight := stdlib.collections.Counter(Map("a", 1))
        boolCountElements := stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False, "c", 2)).elements()
        rootTrueCommon := stdlib.collections.Counter("abb").most_common(stdlib.True)
        rootFalseCommon := stdlib.collections.Counter("abb").most_common(stdlib.False)
        counterRepr := stdlib.collections.Counter("abb").__Repr()
        unorderableCounterRepr := stdlib.collections.Counter(Map("a", Map("x", 1), "b", Map("x", 2))).__Repr()
        activeRepeatCounter := stdlib.collections.Counter(Map("a", 2, "b", 1))
        activeRepeatIterator := activeRepeatCounter.elements().__Enum(1)
        activeRepeatFirst := unset
        activeRepeatRest := []
        activeRepeatValue := unset
        singleUseElements := stdlib.collections.Counter("abb").elements()
        singleUseIterator := singleUseElements.__Enum(1)
        singleUseFirst := unset
        setDefaultCounter := stdlib.collections.Counter("ab")
        setDefaultNoneCounter := stdlib.collections.Counter()
        getCounter := stdlib.collections.Counter("ab")
        popCounter := stdlib.collections.Counter("ab")
        popDefaultCounter := stdlib.collections.Counter("ab")
        popItemCounter := stdlib.collections.Counter("ab")
        delItemCounter := stdlib.collections.Counter("ab")
        counterSubclass := StdlibBootstrapCounterSubclass("ab")
        copiedCounterSubclass := counterSubclass.copy()
        clearCounter := stdlib.collections.Counter("abca")
        clearReturned := clearCounter.Clear()
        deque := stdlib.collections.deque([1, 2], 3)
        deque.append(3)
        deque.appendleft(0)
        deque.append(4)
        defaultDict := stdlib.collections.defaultdict((*) => [])
        defaultDict["a"].Push(1)
        ordered := stdlib.collections.OrderedDict([["a", 1], ["b", 2]])
        ordered.move_to_end("a")
        chain := stdlib.collections.ChainMap(Map("a", 1), Map("a", 2, "b", 3))
        pointType := stdlib.collections.namedtuple("Point", "x y")
        point := pointType.Call(2, 3)
        userDict := stdlib.collections.UserDict(Map("a", 1))
        userList := stdlib.collections.UserList([1, 2])
        userString := stdlib.collections.UserString("ahk")
        userDict["b"] := 2
        userList.append(3)

        AhkTest.AssertEqual(1, counter["a"])
        AhkTest.AssertSame(AhkStdlibCollectionsDeque, stdlib.collections.deque)
        AhkTest.AssertSame(AhkStdlibCollectionsDefaultDict, stdlib.collections.defaultdict)
        AhkTest.AssertSame(AhkStdlibCollectionsOrderedDict, stdlib.collections.OrderedDict)
        AhkTest.AssertSame(AhkStdlibCollectionsChainMap, stdlib.collections.ChainMap)
        AhkTest.AssertSame(AhkStdlibCollectionsUserDict, stdlib.collections.UserDict)
        AhkTest.AssertSame(AhkStdlibCollectionsUserList, stdlib.collections.UserList)
        AhkTest.AssertSame(AhkStdlibCollectionsUserString, stdlib.collections.UserString)
        AhkTest.AssertEqual([1, 2, 4], stdlib_bootstrap_array(deque))
        AhkTest.AssertEqual([["a", [1]]], stdlib_bootstrap_pairs(defaultDict))
        AhkTest.AssertSame(defaultDict["missing"], defaultDict["missing"])
        AhkTest.AssertEqual([["b", 2], ["a", 1]], stdlib_bootstrap_pairs(ordered))
        AhkTest.AssertEqual(1, chain["a"])
        AhkTest.AssertEqual(3, chain["b"])
        AhkTest.AssertEqual([2, 3], stdlib_bootstrap_array(point))
        AhkTest.AssertEqual([["x", 2], ["y", 3]], stdlib_bootstrap_pairs(point._asdict()))
        AhkTest.AssertEqual([["a", 1], ["b", 2]], stdlib_bootstrap_pairs(userDict))
        AhkTest.AssertEqual([1, 2, 3], stdlib_bootstrap_array(userList))
        AhkTest.AssertEqual("AHK", userString.upper().data)
        kwargsUpdateCounter.update({ kwargs: Map("a", 2, "b", 3) })
        kwargsSubtractCounter.subtract({ kwargs: Map("a", 2, "b", 3) })
        AhkTest.AssertEqual([["a", 3], ["b", 1], ["c", 3]], stdlib_bootstrap_pairs(kwargsCounter))
        AhkTest.AssertEqual([["a", 3], ["b", 3]], stdlib_bootstrap_pairs(kwargsUpdateCounter))
        AhkTest.AssertEqual([["a", -1], ["b", -3]], stdlib_bootstrap_pairs(kwargsSubtractCounter))
        AhkTest.AssertEqual(1, setDefaultCounter.setdefault("a", 5))
        AhkTest.AssertEqual(5, setDefaultCounter.setdefault("c", 5))
        AhkTest.AssertEqual([["a", 1], ["b", 1], ["c", 5]], stdlib_bootstrap_pairs(setDefaultCounter))
        AhkTest.AssertSame(stdlib.None, setDefaultNoneCounter.setdefault("x"))
        AhkTest.AssertEqual([["x", stdlib.None]], stdlib_bootstrap_pairs(setDefaultNoneCounter))
        AhkTest.AssertEqual(1, getCounter.get("a"))
        AhkTest.AssertSame(stdlib.None, getCounter.get("z"))
        AhkTest.AssertEqual(7, getCounter.get("z", 7))
        AhkTest.AssertEqual(1, popCounter.pop("a"))
        AhkTest.AssertEqual([["b", 1]], stdlib_bootstrap_pairs(popCounter))
        AhkTest.AssertSame(stdlib.None, popDefaultCounter.pop("z", stdlib.None))
        AhkTest.AssertEqual([["a", 1], ["b", 1]], stdlib_bootstrap_pairs(popDefaultCounter))
        AhkTest.AssertTrue(copiedCounterSubclass is StdlibBootstrapCounterSubclass)
        AhkTest.AssertEqual([["a", 1], ["b", 1]], stdlib_bootstrap_pairs(copiedCounterSubclass))
        AhkTest.AssertTrue(stdlib.operator.eq(copiedCounterSubclass, counterSubclass))
        AhkTest.AssertFalse(ObjPtr(copiedCounterSubclass) = ObjPtr(counterSubclass))
        AhkTest.AssertTrue(stdlib.operator.eq(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", 1))))
        AhkTest.AssertFalse(stdlib.operator.ne(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", 1))))
        AhkTest.AssertTrue(stdlib.operator.le(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", 1))))
        AhkTest.AssertTrue(stdlib.operator.ge(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", 1))))
        AhkTest.AssertTrue(stdlib.operator.lt(stdlib.collections.Counter(Map("a", stdlib.False)), stdlib.collections.Counter(Map("a", 1))))
        AhkTest.AssertTrue(stdlib.operator.gt(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", 0))))
        AhkTest.AssertTrue(stdlib.operator.eq(stdlib.collections.Counter(Map("a", stdlib.True)), Map("a", 1)))
        AhkTest.AssertFalse(stdlib.operator.ne(stdlib.collections.Counter(Map("a", stdlib.True)), Map("a", 1)))
        AhkTest.AssertEqual([["a", stdlib.True]], stdlib_bootstrap_pairs(stdlib.operator.pos(stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False, "c", -1)))))
        AhkTest.AssertEqual([["c", 1]], stdlib_bootstrap_pairs(stdlib.operator.neg(stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False, "c", -1)))))
        AhkTest.AssertEqual([["a", 2]], stdlib_bootstrap_pairs(stdlib.operator.add(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.True)))))
        AhkTest.AssertEqual([["a", stdlib.True]], stdlib_bootstrap_pairs(stdlib.operator.add(stdlib.collections.Counter(), stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False)))))
        AhkTest.AssertEqual([["a", stdlib.True]], stdlib_bootstrap_pairs(stdlib.operator.or_(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.False)))))
        AhkTest.AssertEqual([["a", 1]], stdlib_bootstrap_pairs(stdlib.operator.and_(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", 1)))))
        AhkTest.AssertEqual([["a", stdlib.True]], stdlib_bootstrap_pairs(stdlib.operator.and_(stdlib.collections.Counter(Map("a", 1)), stdlib.collections.Counter(Map("a", stdlib.True)))))
        AhkTest.AssertEqual([["a", 1]], stdlib_bootstrap_pairs(stdlib.operator.sub(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.False)))))
        AhkTest.AssertEqual([], stdlib_bootstrap_pairs(stdlib.operator.sub(stdlib.collections.Counter(), stdlib.collections.Counter(Map("a", stdlib.False, "b", stdlib.True)))))
        boolUpdateFromTrue := stdlib.collections.Counter(Map("a", stdlib.True))
        boolUpdateFromInt := stdlib.collections.Counter(Map("a", 1))
        boolSubtractFromTrue := stdlib.collections.Counter(Map("a", stdlib.True))
        boolSubtractFromInt := stdlib.collections.Counter(Map("a", 1))
        boolUpdateFromTrue.update(Map("a", 1))
        boolUpdateFromInt.update(Map("a", stdlib.True))
        boolSubtractFromTrue.subtract(Map("a", 1))
        boolSubtractFromInt.subtract(Map("a", stdlib.True))
        AhkTest.AssertEqual([["a", 2]], stdlib_bootstrap_pairs(boolUpdateFromTrue))
        AhkTest.AssertEqual([["a", 2]], stdlib_bootstrap_pairs(boolUpdateFromInt))
        AhkTest.AssertEqual([["a", 0]], stdlib_bootstrap_pairs(boolSubtractFromTrue))
        AhkTest.AssertEqual([["a", 0]], stdlib_bootstrap_pairs(boolSubtractFromInt))
        AhkTest.AssertEqual(1, stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False)).total())
        AhkTest.AssertEqual([["a", stdlib.True], ["b", stdlib.False]], stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False)).most_common())
        AhkTest.AssertEqual([["a", "3/2"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(stdlib.operator.pos(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2), "b", stdlib.fractions.Fraction(-1, 2)))))))
        AhkTest.AssertEqual([["b", "1/2"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(stdlib.operator.neg(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2), "b", stdlib.fractions.Fraction(-1, 2)))))))
        AhkTest.AssertEqual([["a", "1.5"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(stdlib.operator.pos(stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", stdlib.decimal.Decimal("-0.5")))))))
        AhkTest.AssertEqual([["b", "0.5"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(stdlib.operator.neg(stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", stdlib.decimal.Decimal("-0.5")))))))
        AhkTest.AssertEqual([["a", "3/2"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(stdlib.operator.add(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))))))
        AhkTest.AssertEqual([["a", "1/2"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(stdlib.operator.sub(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))))))
        AhkTest.AssertEqual([["a", "1/2"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(stdlib.operator.and_(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))))))
        AhkTest.AssertEqual([["a", "3/2"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(stdlib.operator.or_(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2)))))))
        AhkTest.AssertEqual([["a", "1.5"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(stdlib.operator.add(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5")))))))
        AhkTest.AssertEqual([["a", "0.5"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(stdlib.operator.sub(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5")))))))
        AhkTest.AssertTrue(stdlib.operator.eq(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5")))))
        AhkTest.AssertFalse(stdlib.operator.ne(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5")))))
        AhkTest.AssertTrue(stdlib.operator.lt(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.75")))))
        AhkTest.AssertTrue(stdlib.operator.le(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5")))))
        AhkTest.AssertTrue(stdlib.operator.gt(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2))), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5")))))
        AhkTest.AssertTrue(stdlib.operator.ge(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5")))))
        boolFractionUpdateCounter := stdlib.collections.Counter(Map("a", stdlib.True))
        fractionBoolUpdateCounter := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))
        boolDecimalUpdateCounter := stdlib.collections.Counter(Map("a", stdlib.True))
        decimalBoolSubtractCounter := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5")))
        boolFractionUpdateCounter.update(Map("a", stdlib.fractions.Fraction(1, 2)))
        fractionBoolUpdateCounter.update(Map("a", stdlib.True))
        boolDecimalUpdateCounter.update(Map("a", stdlib.decimal.Decimal("0.5")))
        decimalBoolSubtractCounter.subtract(Map("a", stdlib.True))
        AhkTest.AssertEqual([["a", "3/2"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(boolFractionUpdateCounter)))
        AhkTest.AssertEqual([["a", "3/2"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(fractionBoolUpdateCounter)))
        AhkTest.AssertEqual([["a", "1.5"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(boolDecimalUpdateCounter)))
        AhkTest.AssertEqual([["a", "0.5"]], stdlib_bootstrap_render_pairs(stdlib_bootstrap_pairs(decimalBoolSubtractCounter)))
        AhkTest.AssertSame(stdlib.None, clearReturned)
        AhkTest.AssertEqual([], stdlib_bootstrap_pairs(clearCounter))
        AhkTest.AssertSame(stdlib.None, clearCounter.get("a"))
        AhkTest.AssertEqual(0, clearCounter["a"])
        clearCounter.update("ba")
        AhkTest.AssertEqual([["b", 1], ["a", 1]], stdlib_bootstrap_pairs(clearCounter))
        stdlib.operator.delitem(delItemCounter, "a")
        AhkTest.AssertEqual([["b", 1]], stdlib_bootstrap_pairs(delItemCounter))
        popItemFirst := popItemCounter.popitem()
        AhkTest.AssertTrue(popItemFirst is AhkStdlibTuple)
        AhkTest.AssertEqual(["b", 1], popItemFirst)
        AhkTest.RaisesMatch(TypeError, "does not support item assignment|readonly", (*) => popItemFirst[1] := "x")
        AhkTest.AssertEqual([["a", 1]], stdlib_bootstrap_pairs(popItemCounter))
        popItemSecond := popItemCounter.popitem()
        AhkTest.AssertTrue(popItemSecond is AhkStdlibTuple)
        AhkTest.AssertEqual(["a", 1], popItemSecond)
        AhkTest.AssertEqual([], stdlib_bootstrap_pairs(popItemCounter))
        AhkTest.AssertFalse(stdlib.operator.eq(counter, 42))
        AhkTest.AssertTrue(stdlib.operator.ne(counter, 42))
        AhkTest.AssertRegex(elements.__Repr(), "^<itertools\.chain object at 0x[0-9A-F]+>$")
        AhkTest.AssertEqual("Counter({'b': 2, 'a': 1})", counterRepr)
        AhkTest.AssertEqual("Counter({'a': {'x': 1}, 'b': {'x': 2}})", unorderableCounterRepr)
        AhkTest.AssertTrue(iterator(&first))
        AhkTest.AssertEqual("a", first)
        AhkTest.AssertEqual(["a", "c", "c"], stdlib_bootstrap_array(boolCountElements))
        AhkTest.AssertEqual([["b", 2]], rootTrueCommon)
        AhkTest.AssertEqual([], rootFalseCommon)
        AhkTest.RaisesMatch(TypeError, "'NoneType' object cannot be interpreted as an integer", (*) => stdlib_bootstrap_array(stdlib.collections.Counter(Map("a", stdlib.None)).elements()))
        AhkTest.AssertTrue(activeRepeatIterator(&activeRepeatFirst))
        AhkTest.AssertEqual("a", activeRepeatFirst)
        activeRepeatCounter["a"] := 4
        activeRepeatCounter["b"] := 3
        while activeRepeatIterator(&activeRepeatValue)
            activeRepeatRest.Push(activeRepeatValue)
        AhkTest.AssertEqual(["a", "b", "b", "b"], activeRepeatRest)
        AhkTest.AssertTrue(singleUseIterator(&singleUseFirst))
        AhkTest.AssertEqual("a", singleUseFirst)
        AhkTest.AssertEqual(["b", "b"], stdlib_bootstrap_array(singleUseElements))
        AhkTest.AssertEqual([], stdlib_bootstrap_array(singleUseElements))
        counter["b"] := 1
        AhkTest.RaisesMatch(Error, "dictionary changed size during iteration", (*) => stdlib_bootstrap_array(elements))
        AhkTest.RaisesMatch(TypeError, "'<=' not supported between instances of 'str' and 'int'", (*) => stdlib.operator.lt(mixedLeft, mixedRight))
        AhkTest.AssertSame(AhkStdlibCollectionsCounter, stdlib.collections.Counter)
        AhkTest.RaisesMatch(NotImplementedError, "Counter\.fromkeys\(\) is undefined\.  Use Counter\(iterable\) instead\.", (*) => stdlib.collections.Counter.fromkeys("ab"))
        AhkTest.RaisesMatch(TypeError, "get expected at least 1 argument, got 0", (*) => stdlib.collections.Counter().get())
        AhkTest.RaisesMatch(TypeError, "get expected at most 2 arguments, got 3", (*) => stdlib.collections.Counter().get("a", 1, 2))
        AhkTest.RaisesMatch(TypeError, "setdefault expected at least 1 argument, got 0", (*) => stdlib.collections.Counter().setdefault())
        AhkTest.RaisesMatch(TypeError, "setdefault expected at most 2 arguments, got 3", (*) => stdlib.collections.Counter().setdefault("a", 1, 2))
        AhkTest.RaisesMatch(stdlib.KeyError, "^'z'$", (*) => stdlib.operator.delitem(stdlib.collections.Counter("ab"), "z"))
        AhkTest.RaisesMatch(stdlib.KeyError, "^'z'$", (*) => stdlib.collections.Counter().pop("z"))
        AhkTest.RaisesMatch(TypeError, "pop expected at least 1 argument, got 0", (*) => stdlib.collections.Counter().pop())
        AhkTest.RaisesMatch(TypeError, "pop expected at most 2 arguments, got 3", (*) => stdlib.collections.Counter().pop("a", 1, 2))
        AhkTest.RaisesMatch(stdlib.KeyError, "^'popitem\(\): dictionary is empty'$", (*) => popItemCounter.popitem())
        AhkTest.RaisesMatch(TypeError, "dict\.popitem\(\) takes no arguments \(1 given\)", (*) => stdlib.collections.Counter().popitem(1))
    }

    static DateTimeUsesStdlibNamespace()
    {
        value := stdlib.datetime.timedelta({ days: 1, seconds: 2 })
        leapDay := stdlib.datetime.date(2024, 2, 29)
        today := stdlib.datetime.date.today()
        moment := stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3, 4)
        clock := stdlib.datetime.time(1, 2, 3, 4)

        AhkTest.AssertEqual(1, value.days)
        AhkTest.AssertEqual(2, value.seconds)
        AhkTest.AssertEqual("1 day, 0:00:02", String(value))
        AhkTest.AssertEqual("2024-02-29", leapDay.isoformat())
        AhkTest.AssertEqual("2024-03-01", String(stdlib.operator.add(leapDay, stdlib.datetime.timedelta({ days: 1 }))))
        AhkTest.AssertEqual(FormatTime(A_Now, "yyyy-MM-dd"), today.isoformat())
        AhkTest.AssertEqual("0001-01-01", stdlib.datetime.date.min.isoformat())
        AhkTest.AssertEqual("2024-02-29", String(stdlib.datetime.date.fromisoformat("2024-02-29")))
        AhkTest.AssertEqual("2024-02-29T01:02:03.000004", moment.isoformat())
        AhkTest.AssertEqual("2024-02-29T01:02:03.000", moment.isoformat("T", "milliseconds"))
        AhkTest.AssertEqual("2024-02-29T01", moment.isoformat("T", "hours"))
        AhkTest.AssertEqual("1970-01-01 08:00:00", String(stdlib.datetime.datetime.fromtimestamp(0)))
        AhkTest.AssertEqual("2024-03-01 01:02:05.000004", String(stdlib.operator.add(moment, stdlib.datetime.timedelta({ days: 1, seconds: 2 }))))
        AhkTest.AssertEqual("2:00:00.000004", String(stdlib.operator.sub(moment, stdlib.datetime.datetime(2024, 2, 28, 23, 2, 3))))
        AhkTest.AssertTrue(stdlib.operator.gt(moment, stdlib.datetime.datetime(2024, 2, 28, 23, 2, 3, 4)))
        AhkTest.AssertEqual("Thu Feb 29 01:02:03 2024", stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3).ctime())
        AhkTest.AssertEqual("2024-02-29 01:02:03", stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3).strftime("%Y-%m-%d %H:%M:%S"))
        AhkTest.AssertEqual(FormatTime(A_Now, "yyyy-MM-dd"), String(stdlib.datetime.datetime.today().date()))
        AhkTest.AssertEqual("1970-01-01 00:00:00", String(stdlib.datetime.datetime.utcfromtimestamp(0)))
        AhkTest.AssertEqual(FormatTime(A_NowUTC, "yyyy-MM-dd"), String(stdlib.datetime.datetime.utcnow().date()))
        AhkTest.AssertEqual("2024-02-29 01:02:03.456789", String(stdlib.datetime.datetime.fromisoformat("2024-02-29T01:02:03.456789")))
        AhkTest.AssertEqual("AhkStdlibDateTimeTimeValue", Type(clock))
        AhkTest.AssertEqual("01:02:03.000004", clock.isoformat())
        AhkTest.AssertEqual("01:02:03", stdlib.datetime.time(1, 2, 3).isoformat("auto"))
        AhkTest.AssertEqual("01:02:03.000", clock.isoformat("milliseconds"))
        AhkTest.AssertEqual("01:02:03.000004", String(stdlib.datetime.time.fromisoformat("01:02:03.000004")))
        AhkTest.AssertEqual("04:05:06.000007", String(clock.replace({ hour: 4, minute: 5, second: 6, microsecond: 7 })))
        AhkTest.AssertTrue(stdlib.operator.lt(clock, stdlib.datetime.time(1, 2, 3, 5)))
        AhkTest.AssertEqual("00:00:00", String(stdlib.datetime.time.min))
        AhkTest.AssertEqual("23:59:59.999999", String(stdlib.datetime.time.max))
        AhkTest.AssertEqual("0:00:00.000001", String(stdlib.datetime.time.resolution))
        AhkTest.AssertEqual("01:02:03.000004", String(moment.time()))
        AhkTest.AssertEqual("2024-02-29 01:02:03.000004", String(stdlib.datetime.datetime.combine(leapDay, stdlib.datetime.time(1, 2, 3, 4))))
        AhkTest.AssertEqual(1, stdlib.datetime.MINYEAR)
        AhkTest.AssertEqual(9999, stdlib.datetime.MAXYEAR)

        tzinfo := stdlib.datetime.tzinfo()
        AhkTest.RaisesMatch(stdlib.NotImplementedError, "a tzinfo subclass must implement utcoffset\(\)", (*) => tzinfo.utcoffset(stdlib.None))

        utc := stdlib.datetime.timezone.utc
        ist := stdlib.datetime.timezone(stdlib.datetime.timedelta({ hours: 5, minutes: 30 }), "IST")
        AhkTest.AssertEqual("UTC", String(utc))
        AhkTest.AssertEqual("0:00:00", String(utc.utcoffset(stdlib.None)))
        AhkTest.AssertSame(stdlib.None, utc.dst(stdlib.None))
        AhkTest.AssertEqual("IST", String(ist))
        AhkTest.AssertEqual("5:30:00", String(ist.utcoffset(stdlib.None)))
    }

    static WarningsUsesStdlibNamespace()
    {
        records := stdlib.warnings.catch_warnings(true).Call(stdlib_bootstrap_warn_deprecated)

        AhkTest.AssertEqual(1, records.Length)
        AhkTest.AssertEqual("deprecated", records[1].message)
        AhkTest.AssertSame(stdlib.warnings.DeprecationWarning, records[1].category)
    }

    static ComParserUsesDirectApi()
    {
        parsed := stdlib.comparser.loads("# comment`nname = stdlib`npath = a=b")

        AhkTest.AssertEqual(2, parsed.Count)
        AhkTest.AssertEqual("stdlib", parsed["name"])
        AhkTest.AssertEqual("a=b", parsed["path"])

        dumped := stdlib.comparser.dumps(Map("host", "localhost", "port", "8080"))
        AhkTest.AssertEqual("host=localhost`nport=8080", dumped)

        AhkTest.AssertEqual("codex", stdlib.comparser.loads("name = codex")["name"])
        AhkTest.AssertThrows(ValueError, (*) => stdlib.comparser.loads("missing delimiter"))
    }

    static JsonUsesStdlibNamespace()
    {
        data := stdlib.json.loads("{`"answer`":42,`"items`":[1,true,null]}")

        AhkTest.AssertEqual(42, data["answer"])
        AhkTest.AssertEqual(1, data["items"][1])
        AhkTest.AssertSame(stdlib.True, data["items"][2])
        AhkTest.AssertSame(stdlib.json.Null, data["items"][3])

        boolRoundTrip := stdlib.json.loads(stdlib.json.dumps(Map("ok", stdlib.True, "no", stdlib.False)))
        AhkTest.AssertSame(stdlib.True, boolRoundTrip["ok"])
        AhkTest.AssertSame(stdlib.False, boolRoundTrip["no"])

        roundTrip := stdlib.json.loads(stdlib.json.dumps(Map("answer", 42)))
        AhkTest.AssertEqual(42, roundTrip["answer"])
    }

    static CsvUsesStdlibNamespace()
    {
        rows := []
        for row in stdlib.csv.reader("`"a,b`",c`n")
            rows.Push(row)

        AhkTest.AssertEqual([["a,b", "c"]], rows)

        writer := stdlib.csv.writer()
        writer.writerow(["a`"b", "c"])
        AhkTest.AssertEqual("`"a`"`"b`",c`r`n", writer.text)

        initialLimit := stdlib.csv.field_size_limit()
        AhkTest.AssertEqual(initialLimit, stdlib.csv.field_size_limit(5))
        AhkTest.RaisesMatch(stdlib.csv.Error, "field larger than field limit \(5\)", (*) => stdlib.csv.reader("abcdef"))
        stdlib.csv.field_size_limit(initialLimit)

        sniffer := stdlib.csv.Sniffer()
        AhkTest.AssertEqual(";", sniffer.sniff("name;score`nAda;7`n").delimiter)
        AhkTest.AssertTrue(sniffer.has_header("name,score`nAda,7`nGrace,8`n"))
    }

    static ConfigParserUsesStdlibNamespace()
    {
        parser := stdlib.configparser.ConfigParser()

        parser.read_string("[Server]`nHost = localhost`nPORT = 8080`n")
        parser.set("Server", "User", "Ada")

        AhkTest.AssertEqual(["Server"], parser.sections())
        AhkTest.AssertEqual("localhost", parser.get("Server", "host"))
        AhkTest.AssertEqual("localhost", parser["Server"]["HOST"])
        AhkTest.AssertEqual(8080, parser.getint("Server", "port"))
        AhkTest.AssertEqual("Ada", parser.get("Server", "USER"))
        AhkTest.AssertTrue(parser.remove_option("Server", "user"))
        AhkTest.AssertFalse(parser.remove_option("Server", "user"))
    }

    static IoUsesStdlibNamespace()
    {
        stream := stdlib.io.StringIO("abc")

        AhkTest.AssertEqual("a", stream.read(1))
        AhkTest.AssertEqual(1, stream.tell())
        AhkTest.AssertEqual(3, stream.seek(0, stdlib.io.SEEK_END))
        AhkTest.AssertEqual(1, stream.write("Z"))
        AhkTest.AssertEqual("abcZ", stream.getvalue())
        stream.close()
        AhkTest.AssertTrue(stream.closed)

        bytes := stdlib.io.BytesIO([65, 66, 10, 67])
        AhkTest.AssertEqual([65, 66], bytes.read(2))
        AhkTest.AssertEqual([10], bytes.readline())
        AhkTest.AssertEqual(4, bytes.seek(0, stdlib.io.SEEK_END))
        AhkTest.AssertEqual(1, bytes.write([255]))
        AhkTest.AssertEqual([65, 66, 10, 67, 255], bytes.getvalue())
    }

    static FractionsUsesStdlibNamespace()
    {
        half := stdlib.fractions.Fraction(2, 4)
        third := stdlib.fractions.Fraction(1, 3)
        negativeHalf := stdlib.fractions.Fraction(-1, 2)
        piApprox := stdlib.fractions.Fraction("3.1415926535")

        AhkTest.AssertEqual(1, half.numerator)
        AhkTest.AssertEqual(2, half.denominator)
        AhkTest.AssertEqual("1/2", String(half))
        AhkTest.AssertEqual("5/6", String(stdlib.operator.add(half, third)))
        AhkTest.AssertEqual("3/2", String(stdlib.operator.add(half, 1)))
        AhkTest.AssertEqual(1.0, stdlib.operator.add(half, 0.5))
        AhkTest.AssertEqual("4", String(stdlib.operator.truediv(2, half)))
        AhkTest.AssertTrue(stdlib.operator.lt(third, half))
        AhkTest.AssertTrue(stdlib.operator.eq(half, 0.5))
        AhkTest.AssertTrue(stdlib.operator.truth(half))
        AhkTest.AssertEqual("1/2", String(stdlib.operator.abs(negativeHalf)))
        AhkTest.AssertEqual("1/2", String(stdlib.fractions.Fraction.from_float(0.5)))
        AhkTest.AssertEqual([1, 2], half.as_integer_ratio())
        AhkTest.AssertEqual("22/7", String(piApprox.limit_denominator(10)))
    }

    static DecimalUsesStdlibNamespace()
    {
        value := stdlib.decimal.Decimal("1.25")
        other := stdlib.decimal.Decimal("2.5")
        trailing := stdlib.decimal.Decimal("2.50")

        AhkTest.AssertEqual("1.25", String(value))
        AhkTest.AssertEqual("Decimal('1.25')", value.__Repr())
        AhkTest.AssertEqual("3.75", String(stdlib.operator.add(value, other)))
        AhkTest.AssertTrue(stdlib.operator.lt(value, other))
        AhkTest.AssertEqual("2.5", String(trailing.normalize()))
        AhkTest.AssertEqual("ROUND_HALF_EVEN", stdlib.decimal.ROUND_HALF_EVEN)
        AhkTest.AssertTrue(stdlib.decimal.HAVE_CONTEXTVAR)
        AhkTest.AssertTrue(stdlib.decimal.DecimalException() is Error)

        original := stdlib.decimal.getcontext().copy()
        custom := stdlib.decimal.Context({ prec: 7, rounding: stdlib.decimal.ROUND_DOWN })
        try {
            AhkTest.AssertSame(stdlib.None, stdlib.decimal.setcontext(custom))
            AhkTest.AssertEqual(7, stdlib.decimal.getcontext().prec)
            localContext := stdlib.decimal.localcontext()
            entered := localContext.__enter()
            entered.prec := 11
            AhkTest.AssertEqual(11, stdlib.decimal.getcontext().prec)
            AhkTest.AssertFalse(localContext.__exit(stdlib.None, stdlib.None, stdlib.None))
            AhkTest.AssertEqual(7, stdlib.decimal.getcontext().prec)
        } finally {
            stdlib.decimal.setcontext(original)
        }
    }

    static LoggingUsesStdlibNamespace()
    {
        stdlib.logging._resetForTests()
        stream := stdlib.io.StringIO()

        stdlib.logging.basicConfig({ stream: stream, level: stdlib.logging.INFO })
        logger := stdlib.logging.getLogger("bootstrap")
        stdlib.logging.debug("hidden debug")
        stdlib.logging.error("root error")
        logger.info("hello")
        logger.critical("boom")

        AhkTest.AssertEqual("bootstrap", logger.name)
        AhkTest.AssertEqual(stdlib.logging.INFO, stdlib.logging.INFO)
        AhkTest.AssertEqual("ERROR:root:root error`nINFO:bootstrap:hello`nCRITICAL:bootstrap:boom`n", stream.getvalue())
        AhkTest.AssertTrue(logger.isEnabledFor(stdlib.logging.INFO))
        AhkTest.AssertFalse(logger.isEnabledFor(stdlib.logging.DEBUG))

        stdlib.logging._resetForTests()
        fallbackLogger := stdlib.logging.getLogger("fallback")
        fallbackLogger.warning("plain fallback")
        AhkTest.AssertEqual(0, stdlib.logging.getLogger().handlers.Length)
    }

    static ReUsesStdlibNamespace()
    {
        match := stdlib.re.search("(\w+)=(\d+)", "name=42")

        AhkTest.AssertEqual("name=42", match.group(0))
        AhkTest.AssertEqual(["name", "42"], match.groups())
        AhkTest.AssertEqual([0, 7], match.span())
        AhkTest.AssertEqual(["1", "22"], stdlib.re.findall("\d+", "a1 b22"))
        AhkTest.AssertEqual("x:<1>", stdlib.re.sub("(\w+)=(\d+)", "\1:<\2>", "x=1"))
        AhkTest.AssertFalse(HasProp(stdlib.re, "NOFLAG"))
    }

    static TomlUsesStdlibStyleDirectApi()
    {
        data := stdlib.toml.loads("title = `"Stdlib`"`nanswer = 42`n[profile]`nactive = true")

        AhkTest.AssertEqual("Stdlib", data["title"])
        AhkTest.AssertEqual(42, data["answer"])
        AhkTest.AssertEqual(1, data["profile"]["active"])

        dumped := stdlib.toml.dumps(Map("title", "Stdlib", "items", ["core", "text"]))
        roundTrip := stdlib.toml.loads(dumped)
        AhkTest.AssertEqual("Stdlib", roundTrip["title"])
        AhkTest.AssertEqual(["core", "text"], roundTrip["items"])

        doc := stdlib.toml.Toml().read("name = `"codex`"`nscore = 7")
        AhkTest.AssertEqual("codex", doc.getString("name"))
        AhkTest.AssertEqual(7, doc.getLong("score"))
        AhkTest.AssertThrows(ValueError, (*) => stdlib.toml.loads("missing equals"))
    }

    static RootNamespaceExposesDirectTextToml()
    {
        data := stdlib.toml.loads("title = `"Stdlib`"`nanswer = 42")

        AhkTest.AssertEqual("Stdlib", data["title"])
        AhkTest.AssertEqual(42, data["answer"])

        dumped := stdlib.toml.dumps(Map("title", "Stdlib", "items", ["core", "text"]))
        roundTrip := stdlib.toml.loads(dumped)
        AhkTest.AssertEqual("Stdlib", roundTrip["title"])
        AhkTest.AssertEqual(["core", "text"], roundTrip["items"])
    }

    static OsSystemUsesStdlibNamespace()
    {
        AhkTest.AssertEqual(0, stdlib.os.system("exit /b 0"))
        AhkTest.AssertEqual(6, stdlib.os.system("exit /b 6"))
    }

    static PlatformUsesStdlibNamespace()
    {
        uname := stdlib.platform.uname()
        versionMethod := Chr(112) Chr(121) "thon_version"
        implementationMethod := Chr(112) Chr(121) "thon_implementation"

        AhkTest.AssertEqual("Windows", stdlib.platform.system())
        AhkTest.AssertEqual(A_ComputerName, stdlib.platform.node())
        AhkTest.AssertEqual("10", stdlib.platform.release())
        AhkTest.AssertEqual(A_OSVersion, stdlib.platform.version())
        AhkTest.AssertEqual("3.10.11", stdlib.platform.%versionMethod%())
        AhkTest.AssertEqual("CPython", stdlib.platform.%implementationMethod%())
        AhkTest.AssertEqual(["64bit", "WindowsPE"], stdlib_bootstrap_array(stdlib.platform.architecture()))
        AhkTest.AssertEqual("Windows-" stdlib.platform.release(), stdlib.platform.platform({ terse: 1 }))
        AhkTest.AssertEqual(["Windows", A_ComputerName, "10", A_OSVersion, A_Is64bitOS ? "AMD64" : "x86", stdlib.platform.processor()], stdlib_bootstrap_array(uname))
    }

    static SocketUsesStdlibNamespace()
    {
        sock := stdlib.socket.socket()
        try {
            AhkTest.AssertEqual(2, stdlib.socket.AF_INET)
            AhkTest.AssertEqual(1, stdlib.socket.SOCK_STREAM)
            AhkTest.AssertEqual(6, stdlib.socket.IPPROTO_TCP)
            AhkTest.AssertEqual(true, stdlib.socket.has_ipv6)
            AhkTest.AssertEqual(A_ComputerName, stdlib.socket.gethostname())
            AhkTest.AssertEqual(stdlib.socket.AF_INET, sock.family)
            AhkTest.AssertEqual(stdlib.socket.SOCK_STREAM, sock.type)
            AhkTest.AssertEqual(0, sock.proto)
            AhkTest.AssertContains("<socket.socket", sock.__Repr())
        } finally {
            sock.close()
        }
        AhkTest.AssertEqual(-1, sock.fileno())
    }

    static TempfileUsesStdlibNamespace()
    {
        root := A_Temp "\stdlib-bootstrap-tempfile-" A_TickCount "-" Random(100000, 999999)
        DirCreate root

        try {
            path := stdlib.tempfile.mkdtemp("", "boot-", root)
            AhkTest.AssertTrue(DirExist(path) != "")
            AhkTest.AssertContains(root "\boot-", path)

            directory := stdlib.tempfile.TemporaryDirectory("", "td-", root)
            AhkTest.AssertTrue(DirExist(directory.name) != "")
            directory.cleanup()
            AhkTest.AssertFalse(DirExist(directory.name) != "")
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TimeUsesStdlibNamespace()
    {
        before := DateDiff(A_NowUTC, "19700101000000", "Seconds") - 2
        value := stdlib.time.time()
        valueNs := stdlib.time.time_ns()
        after := DateDiff(A_NowUTC, "19700101000000", "Seconds") + 2
        utc := stdlib.time.gmtime(0)
        localTime := stdlib.time.localtime(0)
        formatted := stdlib.time.strftime("%Y-%m-%d %H:%M:%S", utc)
        ctimeValue := stdlib.time.ctime(0)

        AhkTest.AssertEqual("Float", Type(value))
        AhkTest.AssertEqual("Integer", Type(valueNs))
        AhkTest.AssertTrue(value >= before)
        AhkTest.AssertTrue(value <= after)
        AhkTest.AssertEqual(1970, utc.tm_year)
        AhkTest.AssertEqual(8, localTime.tm_hour)
        AhkTest.AssertEqual("1970-01-01 00:00:00", formatted)
        AhkTest.AssertEqual("Thu Jan  1 08:00:00 1970", ctimeValue)
    }

    static ShutilUsesStdlibNamespace()
    {
        root := stdlib.tempfile.mkdtemp("", "stdlib-bootstrap-shutil-", stdlib.tempfile.gettempdir())

        try {
            source := stdlib.pathlib.Path(root, "source.txt")
            targetDir := stdlib.pathlib.Path(root, "target")
            source.write_text("payload")
            targetDir.mkdir()

            copied := stdlib.shutil.copy(source, targetDir)
            AhkTest.AssertEqual(String(targetDir.joinpath("source.txt")), copied)
            AhkTest.AssertEqual("payload", targetDir.joinpath("source.txt").read_text())
            AhkTest.AssertTrue(HasBase(stdlib.shutil.SameFileError.Prototype, OSError.Prototype))
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }
}

class StdlibAhkTestCollectedCase
{
    static TestAddsNumbers()
    {
        AhkTest.AssertEqual(4, 2 + 2)
    }

    static TestMatchesStrings()
    {
        AhkTest.AssertEqual("ahktest", "ahk" "test")
    }

    static HelperIsNotCollected()
    {
        AhkTest.Fail("collector should only register methods prefixed with Test")
    }
}

class StdlibAhkTestBrokenCollectedCase
{
    static TestBroken := 1
}

class StdlibCoreBaseSmokeSubject
{
    __New()
    {
        this.name := "kept"
    }
}

class StdlibBootstrapAbcForeign
{
}

class StdlibBootstrapAwaitTaskBody
{
    __New()
    {
        this.StepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.StepIndex = 0 {
            this.StepIndex += 1
            return stdlib.asyncio.sleep(0, "slept")
        }
        return "task-result"
    }
}

class StdlibBootstrapNestedAwaitBody
{
    AhkStdlibAsyncioStep(task, value := unset)
    {
        return stdlib.await(stdlib.asyncio.sleep(0, "nested"))
    }
}

class StdlibBootstrapDecoratedTarget
{
}

stdlib_bootstrap_decorator(label, events)
{
    return (target) => stdlib_bootstrap_decorator_apply(label, events, target)
}

stdlib_bootstrap_decorator_apply(label, events, target)
{
    events.Push("apply:" label)
    return (*) => stdlib_bootstrap_decorator_call(label, events, target)
}

stdlib_bootstrap_decorator_call(label, events, target)
{
    events.Push("call:" label)
    return label "(" target.Call() ")"
}

stdlib_bootstrap_decorated_value(events)
{
    events.Push("call:value")
    return "value"
}

AhkTest.Test("stdlib bootstrap uses <stdlib\\ahktest>", (*) => StdlibBootstrapTest.FrameworkStartsFromStdlibHarness())
AhkTest.Test("stdlib ahktest exposes AHK-named raises helper", (*) => StdlibBootstrapTest.AhkTestRaisesUsesAhkNaming())
AhkTest.Test("stdlib ahktest creates isolated suites", (*) => StdlibBootstrapTest.AhkTestCreatesIsolatedSuites())
AhkTest.Test("stdlib ahktest collects static test methods", (*) => StdlibBootstrapTest.AhkTestCollectsStaticTestMethods())
AhkTest.Test("stdlib ahktest records manual source metadata", (*) => StdlibBootstrapTest.AhkTestRecordsManualSourceMetadata())
AhkTest.Test("stdlib ahktest source here records file and line", (*) => StdlibBootstrapTest.AhkTestSourceHereRecordsFileAndLine())
AhkTest.Test("stdlib ahktest records suite test source automatically", (*) => StdlibBootstrapTest.AhkTestAutoSourceRecordsSuiteTestRegistration())
AhkTest.Test("stdlib ahktest records default test source automatically", (*) => StdlibBootstrapTest.AhkTestAutoSourceRecordsDefaultSuiteRegistration())
AhkTest.Test("stdlib ahktest records outcome source automatically", (*) => StdlibBootstrapTest.AhkTestAutoSourceRecordsSkipXFailAndParametrize())
AhkTest.Test("stdlib ahktest records collect source metadata", (*) => StdlibBootstrapTest.AhkTestCollectRecordsClassMethodSourceMetadata())
AhkTest.Test("stdlib ahktest reports collection errors", (*) => StdlibBootstrapTest.AhkTestReportsCollectionErrors())
AhkTest.Test("stdlib ahktest collection errors use collection failure type", (*) => StdlibBootstrapTest.AhkTestCollectionErrorsUseDedicatedCollectionFailureType())
AhkTest.Test("stdlib ahktest parametrizes rows with readable names", (*) => StdlibBootstrapTest.AhkTestParametrizeExpandsRows())
AhkTest.Test("stdlib ahktest checks exception messages", (*) => StdlibBootstrapTest.AhkTestRaisesMatchChecksMessages())
AhkTest.Test("stdlib ahktest captures warnings", (*) => StdlibBootstrapTest.AhkTestCapturesWarnings())
AhkTest.Test("stdlib ahktest filters warnings by category", (*) => StdlibBootstrapTest.AhkTestFiltersWarningsByCategory())
AhkTest.Test("stdlib ahktest stores warnings on result entries", (*) => StdlibBootstrapTest.AhkTestStoresWarningsOnResultEntries())
AhkTest.Test("stdlib ahktest records warning source metadata", (*) => StdlibBootstrapTest.AhkTestWarningsRecordSourceMetadata())
AhkTest.Test("stdlib ahktest groups warning summaries", (*) => StdlibBootstrapTest.AhkTestResultGroupsWarningSummary())
AhkTest.Test("stdlib ahktest can report warning summaries", (*) => StdlibBootstrapTest.AhkTestTextReportCanShowWarningSummary())
AhkTest.Test("stdlib ahktest warning filters ignore matches", (*) => StdlibBootstrapTest.AhkTestWarningFiltersIgnoreMatchingWarnings())
AhkTest.Test("stdlib ahktest warning filters error matches", (*) => StdlibBootstrapTest.AhkTestWarningFiltersErrorMatchingWarnings())
AhkTest.Test("stdlib ahktest warns captures despite error filters", (*) => StdlibBootstrapTest.AhkTestWarnsCapturesDespiteErrorFilters())
AhkTest.Test("stdlib ahktest warning filter run options override config", (*) => StdlibBootstrapTest.AhkTestWarningFilterRunOptionsOverrideConfig())
AhkTest.Test("stdlib ahktest warning filter last match wins", (*) => StdlibBootstrapTest.AhkTestWarningFilterLastMatchWins())
AhkTest.Test("stdlib ahktest warning filter validates shape", (*) => StdlibBootstrapTest.AhkTestWarningFilterValidatesShape())
AhkTest.Test("stdlib ahktest warning filter default deduplicates exact location", (*) => StdlibBootstrapTest.AhkTestWarningFilterDefaultDeduplicatesExactLocation())
AhkTest.Test("stdlib ahktest warning filter always keeps duplicates", (*) => StdlibBootstrapTest.AhkTestWarningFilterAlwaysKeepsDuplicates())
AhkTest.Test("stdlib ahktest warning filter once deduplicates locations", (*) => StdlibBootstrapTest.AhkTestWarningFilterOnceDeduplicatesAcrossLocations())
AhkTest.Test("stdlib ahktest warning filter source deduplicates lines", (*) => StdlibBootstrapTest.AhkTestWarningFilterSourceDeduplicatesAcrossLines())
AhkTest.Test("stdlib ahktest captures cooperative output", (*) => StdlibBootstrapTest.AhkTestCapturesCooperativeStdoutAndStderr())
AhkTest.Test("stdlib ahktest stores captured output on result entries", (*) => StdlibBootstrapTest.AhkTestStoresCapturedOutputOnResultEntries())
AhkTest.Test("stdlib ahktest reports captured output for failures", (*) => StdlibBootstrapTest.AhkTestReportsCapturedOutputForFailures())
AhkTest.Test("stdlib ahktest can suppress captured output reports", (*) => StdlibBootstrapTest.AhkTestCanSuppressCapturedOutputReports())
AhkTest.Test("stdlib ahktest can select captured output report streams", (*) => StdlibBootstrapTest.AhkTestCanSelectCapturedOutputReportStreams())
AhkTest.Test("stdlib ahktest can report all captured output", (*) => StdlibBootstrapTest.AhkTestCanReportAllCapturedOutput())
AhkTest.Test("stdlib ahktest validates report run option values", (*) => StdlibBootstrapTest.AhkTestValidatesReportRunOptionValues())
AhkTest.Test("stdlib ahktest captures child process output", (*) => StdlibBootstrapTest.AhkTestCapturesChildProcessStdoutAndStderr())
AhkTest.Test("stdlib ahktest captures child process args safely", (*) => StdlibBootstrapTest.AhkTestCapturesChildProcessArgsSafely())
AhkTest.Test("stdlib ahktest capture run args times out child processes", (*) => StdlibBootstrapTest.AhkTestCaptureRunArgsTimesOutChildProcesses())
AhkTest.Test("stdlib ahktest capture run args waits for child processes", (*) => StdlibBootstrapTest.AhkTestCaptureRunArgsWaitsForGuiChildProcess())
AhkTest.Test("stdlib ahktest capture run args drains large output", (*) => StdlibBootstrapTest.AhkTestCaptureRunArgsDrainsLargeOutput())
AhkTest.Test("stdlib ahktest capture run args decodes configured encoding", (*) => StdlibBootstrapTest.AhkTestCaptureRunArgsDecodesConfiguredEncoding())
AhkTest.Test("stdlib ahktest supports runtime skips", (*) => StdlibBootstrapTest.AhkTestSkipNowSkipsRunningTest())
AhkTest.Test("stdlib ahktest provides temporary directories", (*) => StdlibBootstrapTest.AhkTestTempDirCreatesAndCleansFiles())
AhkTest.Test("stdlib ahktest temp path object supports pathlib style operations", (*) => StdlibBootstrapTest.AhkTestTempPathObjectSupportsPathlibStyleOperations())
AhkTest.Test("stdlib ahktest path object exposes path parts and removes entries", (*) => StdlibBootstrapTest.AhkTestPathObjectExposesPathPartsAndRemovesEntries())
AhkTest.Test("stdlib ahktest path mkdir and unlink support pathlib options", (*) => StdlibBootstrapTest.AhkTestPathMkdirAndUnlinkSupportPathlibOptions())
AhkTest.Test("stdlib ahktest provides temp path fixtures", (*) => StdlibBootstrapTest.AhkTestTempPathFixtureIsolatesAndCleansPerTest())
AhkTest.Test("stdlib ahktest provides temp path factories", (*) => StdlibBootstrapTest.AhkTestTempPathFactoryCreatesNumberedDirectories())
AhkTest.Test("stdlib ahktest provides stdlib assertion helpers", (*) => StdlibBootstrapTest.AhkTestAssertionHelpersMirrorStdlibStyle())
AhkTest.Test("stdlib ahktest supports conditional skips", (*) => StdlibBootstrapTest.AhkTestSkipIfRegistersConditionalSkips())
AhkTest.Test("stdlib ahktest tracks expected failures", (*) => StdlibBootstrapTest.AhkTestExpectedFailuresAreTracked())
AhkTest.Test("stdlib ahktest fails strict unexpected passes", (*) => StdlibBootstrapTest.AhkTestStrictExpectedFailuresFailOnUnexpectedPass())
AhkTest.Test("stdlib ahktest can run xfail tests normally", (*) => StdlibBootstrapTest.AhkTestRunXFailTreatsExpectedFailuresAsNormalTests())
AhkTest.Test("stdlib ahktest groups outcome reasons in reports", (*) => StdlibBootstrapTest.AhkTestTextReportGroupsOutcomeReasons())
AhkTest.Test("stdlib ahktest run summary selects reported reasons", (*) => StdlibBootstrapTest.AhkTestRunSummarySelectsReportedReasons())
AhkTest.Test("stdlib ahktest parametrizes rows with custom ids", (*) => StdlibBootstrapTest.AhkTestParametrizeAcceptsCustomIds())
AhkTest.Test("stdlib ahktest stacks parametrized rows", (*) => StdlibBootstrapTest.AhkTestParametrizeStacksRows())
AhkTest.Test("stdlib ahktest skips empty parameter sets", (*) => StdlibBootstrapTest.AhkTestParametrizeSkipsEmptyRows())
AhkTest.Test("stdlib ahktest keeps filter and list results structured", (*) => StdlibBootstrapTest.AhkTestRunFilterAndListKeepResultsStructured())
AhkTest.Test("stdlib ahktest quiet runs suppress failure output", (*) => StdlibBootstrapTest.AhkTestQuietRunSuppressesFailureOutput())
AhkTest.Test("stdlib ahktest exports structured results", (*) => StdlibBootstrapTest.AhkTestResultExportsStructuredMap())
AhkTest.Test("stdlib ahktest exports error location metadata", (*) => StdlibBootstrapTest.AhkTestResultExportsErrorLocationMetadata())
AhkTest.Test("stdlib ahktest text report supports long traceback", (*) => StdlibBootstrapTest.AhkTestTextReportSupportsLongTraceback())
AhkTest.Test("stdlib ahktest text report supports native traceback", (*) => StdlibBootstrapTest.AhkTestTextReportSupportsNativeTraceback())
AhkTest.Test("stdlib ahktest text report supports auto traceback", (*) => StdlibBootstrapTest.AhkTestTextReportSupportsAutoTraceback())
AhkTest.Test("stdlib ahktest text report can suppress tracebacks", (*) => StdlibBootstrapTest.AhkTestTextReportCanSuppressTraceback())
AhkTest.Test("stdlib ahktest text report supports line tracebacks", (*) => StdlibBootstrapTest.AhkTestTextReportSupportsLineTraceback())
AhkTest.Test("stdlib ahktest exports junit xml", (*) => StdlibBootstrapTest.AhkTestResultExportsJUnitXml())
AhkTest.Test("stdlib ahktest exports json", (*) => StdlibBootstrapTest.AhkTestResultExportsJson())
AhkTest.Test("stdlib ahktest writes json and junit result files", (*) => StdlibBootstrapTest.AhkTestResultWritesJsonAndJUnitFiles())
AhkTest.Test("stdlib ahktest reports deselected tests", (*) => StdlibBootstrapTest.AhkTestReportsDeselectedTests())
AhkTest.Test("stdlib ahktest filters by exact node ids", (*) => StdlibBootstrapTest.AhkTestNodeFilterSelectsExactParametrizedNodeIds())
AhkTest.Test("stdlib ahktest supports boolean name filters", (*) => StdlibBootstrapTest.AhkTestSupportsBooleanNameFilters())
AhkTest.Test("stdlib ahktest groups boolean name filters", (*) => StdlibBootstrapTest.AhkTestBooleanNameFiltersSupportOrAndParentheses())
AhkTest.Test("stdlib ahktest filters quoted name phrases", (*) => StdlibBootstrapTest.AhkTestBooleanNameFiltersSupportQuotedPhrases())
AhkTest.Test("stdlib ahktest rejects invalid filter expressions", (*) => StdlibBootstrapTest.AhkTestInvalidFilterExpressionsRaise())
AhkTest.Test("stdlib ahktest stores and filters markers", (*) => StdlibBootstrapTest.AhkTestStoresAndFiltersMarkers())
AhkTest.Test("stdlib ahktest stores marker metadata", (*) => StdlibBootstrapTest.AhkTestStoresMarkerMetadata())
AhkTest.Test("stdlib ahktest supports boolean marker filters", (*) => StdlibBootstrapTest.AhkTestSupportsBooleanMarkerFilters())
AhkTest.Test("stdlib ahktest keeps parameter row markers", (*) => StdlibBootstrapTest.AhkTestParametrizeKeepsRowMarkers())
AhkTest.Test("stdlib ahktest merges parametrized option and row markers", (*) => StdlibBootstrapTest.AhkTestParametrizeMergesOptionAndRowMarkers())
AhkTest.Test("stdlib ahktest exports parameter metadata", (*) => StdlibBootstrapTest.AhkTestParametrizeExportsParameterMetadata())
AhkTest.Test("stdlib ahktest passes fixture params", (*) => StdlibBootstrapTest.AhkTestParametrizePassesFixtureParams())
AhkTest.Test("stdlib ahktest stacks fixture params", (*) => StdlibBootstrapTest.AhkTestParametrizeStacksFixtureParams())
AhkTest.Test("stdlib ahktest skip marks skip tests", (*) => StdlibBootstrapTest.AhkTestSkipMarksSkipDeclaredTests())
AhkTest.Test("stdlib ahktest xfail marks track expected failures", (*) => StdlibBootstrapTest.AhkTestXFailMarksTrackExpectedFailures())
AhkTest.Test("stdlib ahktest strict xfail marks fail xpasses", (*) => StdlibBootstrapTest.AhkTestStrictXFailMarksFailUnexpectedPasses())
AhkTest.Test("stdlib ahktest validates strict marker registration", (*) => StdlibBootstrapTest.AhkTestStrictMarkersRequireRegistration())
AhkTest.Test("stdlib ahktest registers markers from config", (*) => StdlibBootstrapTest.AhkTestConfigRegistersMarkers())
AhkTest.Test("stdlib ahktest config run defaults filter tests", (*) => StdlibBootstrapTest.AhkTestConfigRunDefaultsSelectByFilterExpr())
AhkTest.Test("stdlib ahktest run options override config defaults", (*) => StdlibBootstrapTest.AhkTestRunOptionsOverrideConfiguredRunDefaults())
AhkTest.Test("stdlib ahktest config run defaults disable hooks by id", (*) => StdlibBootstrapTest.AhkTestConfigRunDefaultsDisableHooksById())
AhkTest.Test("stdlib ahktest config run defaults validate shape", (*) => StdlibBootstrapTest.AhkTestConfigRunDefaultsValidateShape())
AhkTest.Test("stdlib ahktest config run defaults accept auto traceback", (*) => StdlibBootstrapTest.AhkTestConfigRunDefaultsAcceptAutoTraceback())
AhkTest.Test("stdlib ahktest config run defaults accept native traceback", (*) => StdlibBootstrapTest.AhkTestConfigRunDefaultsAcceptNativeTraceback())
AhkTest.Test("stdlib ahktest config manifest run defaults filter tests", (*) => StdlibBootstrapTest.AhkTestConfigManifestRunDefaultsSelectByFilterExpr())
AhkTest.Test("stdlib ahktest config manifest normalizes json bool defaults", (*) => StdlibBootstrapTest.AhkTestConfigManifestNormalizesJsonBoolRunDefaults())
AhkTest.Test("stdlib ahktest registers markers on default suite", (*) => StdlibBootstrapTest.AhkTestDefaultSuiteRegistersMarkers())
AhkTest.Test("stdlib ahktest matches reference approx tolerance rules", (*) => StdlibBootstrapTest.AhkTestApproxMatchesReferenceToleranceRules())
AhkTest.Test("stdlib ahktest approx supports nan ok", (*) => StdlibBootstrapTest.AhkTestApproxSupportsNanOk())
AhkTest.Test("stdlib ahktest stops after max fail", (*) => StdlibBootstrapTest.AhkTestRunStopsAfterMaxFail())
AhkTest.Test("stdlib ahktest supports exit first", (*) => StdlibBootstrapTest.AhkTestRunExitFirstStopsAfterFirstFailure())
AhkTest.Test("stdlib ahktest max fail ignores non strict xpass", (*) => StdlibBootstrapTest.AhkTestMaxFailIgnoresNonStrictUnexpectedPass())
AhkTest.Test("stdlib ahktest reruns last failed tests", (*) => StdlibBootstrapTest.AhkTestRerunsLastFailedTests())
AhkTest.Test("stdlib ahktest persists last failed cache", (*) => StdlibBootstrapTest.AhkTestPersistsLastFailedCache())
AhkTest.Test("stdlib ahktest last failed cache uses node ids", (*) => StdlibBootstrapTest.AhkTestLastFailedCacheUsesStableNodeIds())
AhkTest.Test("stdlib ahktest last failed cache distinguishes duplicate source names", (*) => StdlibBootstrapTest.AhkTestLastFailedCacheDistinguishesDuplicateNamesAcrossSources())
AhkTest.Test("stdlib ahktest last failed cache falls back when stale", (*) => StdlibBootstrapTest.AhkTestLastFailedCacheFallsBackToFullRunWhenCachedNodeIdsAreStale())
AhkTest.Test("stdlib ahktest last failed node filter runs explicit selection", (*) => StdlibBootstrapTest.AhkTestLastFailedNodeFilterRunsSelectedNodeOutsideCacheAndPreservesPriorCache())
AhkTest.Test("stdlib ahktest last failed filter expr runs explicit selection", (*) => StdlibBootstrapTest.AhkTestLastFailedFilterExprRunsSelectedTestsOutsideCacheAndPreservesPriorCache())
AhkTest.Test("stdlib ahktest last failed node filter merges new failing selection", (*) => StdlibBootstrapTest.AhkTestLastFailedNodeFilterAddsNewFailingSelectionToExistingCache())
AhkTest.Test("stdlib ahktest last failed node filter array runs explicit selection", (*) => StdlibBootstrapTest.AhkTestLastFailedNodeFilterArrayRunsSelectedNodesOutsideCacheAndPreservesPriorCache())
AhkTest.Test("stdlib ahktest last failed node filter array merges new failing selection", (*) => StdlibBootstrapTest.AhkTestLastFailedNodeFilterArrayAddsNewFailingSelectionToExistingCache())
AhkTest.Test("stdlib ahktest last failed node filter array keeps cached intersection", (*) => StdlibBootstrapTest.AhkTestLastFailedNodeFilterArrayKeepsCachedIntersectionWhenMixedSelectionIncludesCachedNode())
AhkTest.Test("stdlib ahktest stepwise resumes from cached failure", (*) => StdlibBootstrapTest.AhkTestStepwiseResumesFromCachedFailure())
AhkTest.Test("stdlib ahktest stepwise falls back when stale", (*) => StdlibBootstrapTest.AhkTestStepwiseFallsBackToFullRunWhenCachedNodeIdIsStale())
AhkTest.Test("stdlib ahktest stepwise stale cache updates after fallback", (*) => StdlibBootstrapTest.AhkTestStepwiseStaleCacheUpdatesToNewFailureAfterFallbackRun())
AhkTest.Test("stdlib ahktest stepwise falls back to current node filter selection", (*) => StdlibBootstrapTest.AhkTestStepwiseFallsBackToCurrentNodeFilterSelectionWhenCachedNodeIsExcluded())
AhkTest.Test("stdlib ahktest stepwise filtered selection updates cache", (*) => StdlibBootstrapTest.AhkTestStepwiseFilteredSelectionUpdatesCacheWhenNewFailureAppears())
AhkTest.Test("stdlib ahktest stepwise cache distinguishes duplicate source names", (*) => StdlibBootstrapTest.AhkTestStepwiseCacheDistinguishesDuplicateNamesAcrossSources())
AhkTest.Test("stdlib ahktest runs lifecycle hooks", (*) => StdlibBootstrapTest.AhkTestRunsLifecycleHooks())
AhkTest.Test("stdlib ahktest hooks respect priority order", (*) => StdlibBootstrapTest.AhkTestHooksRespectPriorityOrder())
AhkTest.Test("stdlib ahktest run can disable hooks by id", (*) => StdlibBootstrapTest.AhkTestRunCanDisableHooksById())
AhkTest.Test("stdlib ahktest runs suite lifecycle hooks", (*) => StdlibBootstrapTest.AhkTestRunsSuiteLifecycleHooks())
AhkTest.Test("stdlib ahktest collection hooks can modify items", (*) => StdlibBootstrapTest.AhkTestCollectionHooksCanModifyItems())
AhkTest.Test("stdlib ahktest reports collection hook errors", (*) => StdlibBootstrapTest.AhkTestReportsCollectionHookErrors())
AhkTest.Test("stdlib ahktest collection hook errors use collection failure type", (*) => StdlibBootstrapTest.AhkTestCollectionHookErrorsUseDedicatedCollectionFailureType())
AhkTest.Test("stdlib ahktest reports run start hook errors", (*) => StdlibBootstrapTest.AhkTestReportsRunStartHookErrors())
AhkTest.Test("stdlib ahktest reports run finish hook errors", (*) => StdlibBootstrapTest.AhkTestReportsRunFinishHookErrors())
AhkTest.Test("stdlib ahktest runs report finish hooks", (*) => StdlibBootstrapTest.AhkTestRunsReportFinishHooks())
AhkTest.Test("stdlib ahktest reports report finish hook errors", (*) => StdlibBootstrapTest.AhkTestReportsReportFinishHookErrors())
AhkTest.Test("stdlib ahktest reports lifecycle hook errors", (*) => StdlibBootstrapTest.AhkTestReportsLifecycleHookErrors())
AhkTest.Test("stdlib ahktest aggregates finish hook errors", (*) => StdlibBootstrapTest.AhkTestAggregatesFinishHookErrors())
AhkTest.Test("stdlib ahktest injects explicit fixtures", (*) => StdlibBootstrapTest.AhkTestInjectsExplicitFixtures())
AhkTest.Test("stdlib ahktest test fixture override shadows suite fixture", (*) => StdlibBootstrapTest.AhkTestTestFixtureOverrideShadowsSuiteFixture())
AhkTest.Test("stdlib ahktest reports unknown fixtures", (*) => StdlibBootstrapTest.AhkTestReportsUnknownFixtures())
AhkTest.Test("stdlib ahktest resolves fixture dependencies", (*) => StdlibBootstrapTest.AhkTestResolvesFixtureDependencies())
AhkTest.Test("stdlib ahktest cleans fixtures after pass", (*) => StdlibBootstrapTest.AhkTestCleansFixturesAfterPass())
AhkTest.Test("stdlib ahktest fixture context adds cleanup", (*) => StdlibBootstrapTest.AhkTestFixtureContextAddsCleanupAfterFixtureSetup())
AhkTest.Test("stdlib ahktest fixture context cleans setup failures", (*) => StdlibBootstrapTest.AhkTestFixtureContextCleansSetupFailures())
AhkTest.Test("stdlib ahktest reserves fixture context name", (*) => StdlibBootstrapTest.AhkTestFixtureContextNameIsReserved())
AhkTest.Test("stdlib ahktest fixture context gets fixture once", (*) => StdlibBootstrapTest.AhkTestFixtureContextGetsFixtureValueOnce())
AhkTest.Test("stdlib ahktest fixture context get fixture updates fixture names", (*) => StdlibBootstrapTest.AhkTestFixtureContextGetFixtureUpdatesFixtureNamesForDynamicFixtures())
AhkTest.Test("stdlib ahktest fixture context get fixture avoids duplicate fixture names", (*) => StdlibBootstrapTest.AhkTestFixtureContextGetFixtureDoesNotDuplicateDeclaredFixtureNames())
AhkTest.Test("stdlib ahktest fixture context exposes metadata", (*) => StdlibBootstrapTest.AhkTestFixtureContextExposesTestMetadata())
AhkTest.Test("stdlib ahktest fixture context exposes fixture names", (*) => StdlibBootstrapTest.AhkTestFixtureContextExposesFixtureNamesLikePytestRequest())
AhkTest.Test("stdlib ahktest fixture context gets param", (*) => StdlibBootstrapTest.AhkTestFixtureContextGetsParamValue())
AhkTest.Test("stdlib ahktest fixture context exposes fixture param id", (*) => StdlibBootstrapTest.AhkTestFixtureContextExposesFixtureParamId())
AhkTest.Test("stdlib ahktest fixture context reports missing param", (*) => StdlibBootstrapTest.AhkTestFixtureContextGetParamReportsMissing())
AhkTest.Test("stdlib ahktest fixture params expand tests", (*) => StdlibBootstrapTest.AhkTestFixtureParamsExpandTests())
AhkTest.Test("stdlib ahktest fixture params apply row marks", (*) => StdlibBootstrapTest.AhkTestFixtureParamsApplyRowMarks())
AhkTest.Test("stdlib ahktest cleans fixtures after failure", (*) => StdlibBootstrapTest.AhkTestCleansFixturesAfterFailure())
AhkTest.Test("stdlib ahktest cleans dependent fixtures in reverse order", (*) => StdlibBootstrapTest.AhkTestCleansDependentFixturesInReverseOrder())
AhkTest.Test("stdlib ahktest reports fixture dependency cycles", (*) => StdlibBootstrapTest.AhkTestReportsFixtureDependencyCycles())
AhkTest.Test("stdlib ahktest aggregates fixture cleanup errors", (*) => StdlibBootstrapTest.AhkTestAggregatesFixtureCleanupErrors())
AhkTest.Test("stdlib ahktest caches suite scoped fixtures", (*) => StdlibBootstrapTest.AhkTestCachesSuiteScopedFixturesUntilSuiteEnd())
AhkTest.Test("stdlib ahktest isolates suite scoped fixture params", (*) => StdlibBootstrapTest.AhkTestSuiteScopedFixtureParamsUseSeparateCacheEntries())
AhkTest.Test("stdlib ahktest caches suite scoped fixture setup errors", (*) => StdlibBootstrapTest.AhkTestCachesSuiteScopedFixtureSetupErrors())
AhkTest.Test("stdlib ahktest reports suite scoped cleanup errors", (*) => StdlibBootstrapTest.AhkTestReportsSuiteScopedCleanupErrors())
AhkTest.Test("stdlib ahktest caches session scoped fixtures", (*) => StdlibBootstrapTest.AhkTestCachesSessionScopedFixturesUntilExplicitCleanup())
AhkTest.Test("stdlib ahktest isolates session scoped fixtures across suites", (*) => StdlibBootstrapTest.AhkTestSessionScopedFixturesDoNotCollideAcrossSuites())
AhkTest.Test("stdlib ahktest isolates session scoped fixture params", (*) => StdlibBootstrapTest.AhkTestSessionScopedFixtureParamsUseSeparateCacheEntries())
AhkTest.Test("stdlib ahktest caches session scoped fixture setup errors", (*) => StdlibBootstrapTest.AhkTestCachesSessionScopedFixtureSetupErrors())
AhkTest.Test("stdlib ahktest runs autouse fixtures", (*) => StdlibBootstrapTest.AhkTestRunsAutouseFixturesForEveryTest())
AhkTest.Test("stdlib ahktest runs explicit autouse fixtures once", (*) => StdlibBootstrapTest.AhkTestAutouseFixturesRequestedExplicitlyRunOnce())
AhkTest.Test("stdlib ahktest resolves autouse fixture dependencies", (*) => StdlibBootstrapTest.AhkTestAutouseFixturesResolveDependencies())
AhkTest.Test("stdlib ahktest monkeypatch restores env", (*) => StdlibBootstrapTest.AhkTestMonkeyPatchRestoresEnvironmentVariables())
AhkTest.Test("stdlib ahktest monkeypatch restores deleted env", (*) => StdlibBootstrapTest.AhkTestMonkeyPatchRestoresDeletedEnvironmentVariables())
AhkTest.Test("stdlib ahktest monkeypatch prepends path env", (*) => StdlibBootstrapTest.AhkTestMonkeyPatchPrependsPathEnvironmentVariables())
AhkTest.Test("stdlib ahktest monkeypatch restores map values", (*) => StdlibBootstrapTest.AhkTestMonkeyPatchRestoresMapValues())
AhkTest.Test("stdlib ahktest monkeypatch restores object properties", (*) => StdlibBootstrapTest.AhkTestMonkeyPatchRestoresObjectProperties())
AhkTest.Test("stdlib ahktest monkeypatch restores object methods", (*) => StdlibBootstrapTest.AhkTestMonkeyPatchRestoresObjectMethodsAfterFailure())
AhkTest.Test("stdlib ahktest monkeypatch restores cwd", (*) => StdlibBootstrapTest.AhkTestMonkeyPatchRestoresWorkingDirectory())
AhkTest.Test("stdlib assert uses root stdlib namespace", (*) => StdlibBootstrapTest.AssertUsesDirectStdlibApi())
AhkTest.Test("stdlib base check type uses root stdlib namespace", (*) => StdlibBootstrapTest.CoreBaseCheckTypeUsesStdlibNamespace())
AhkTest.Test("stdlib abc uses root stdlib namespace", (*) => StdlibBootstrapTest.AbcUsesStdlibNamespace())
AhkTest.Test("stdlib types uses root stdlib namespace", (*) => StdlibBootstrapTest.CoreTypesUsesStdlibNamespace())
AhkTest.Test("stdlib operator uses root stdlib namespace", (*) => StdlibBootstrapTest.OperatorUsesStdlibNamespace())
AhkTest.Test("stdlib heapq uses root stdlib namespace", (*) => StdlibBootstrapTest.HeapqUsesStdlibNamespace())
AhkTest.Test("stdlib math uses root stdlib namespace", (*) => StdlibBootstrapTest.MathUsesStdlibNamespace())
AhkTest.Test("stdlib random uses root stdlib namespace", (*) => StdlibBootstrapTest.RandomUsesStdlibNamespace())
AhkTest.Test("stdlib array uses root stdlib namespace", (*) => StdlibBootstrapTest.ArrayUsesStdlibNamespace())
AhkTest.Test("stdlib hashlib uses root stdlib namespace", (*) => StdlibBootstrapTest.HashlibUsesStdlibNamespace())
AhkTest.Test("stdlib hmac uses root stdlib namespace", (*) => StdlibBootstrapTest.HmacUsesStdlibNamespace())
AhkTest.Test("stdlib pprint uses root stdlib namespace", (*) => StdlibBootstrapTest.PprintUsesStdlibNamespace())
AhkTest.Test("stdlib asyncio uses root stdlib namespace", (*) => StdlibBootstrapTest.AsyncioUsesStdlibNamespace())
AhkTest.Test("stdlib tkinter uses root stdlib namespace", (*) => StdlibBootstrapTest.TkinterUsesStdlibNamespace())
AhkTest.Test("stdlib enum uses root stdlib namespace", (*) => StdlibBootstrapTest.EnumUsesStdlibNamespace())
AhkTest.Test("stdlib copy uses root stdlib namespace", (*) => StdlibBootstrapTest.CopyUsesStdlibNamespace())
AhkTest.Test("stdlib contextlib uses root stdlib namespace", (*) => StdlibBootstrapTest.ContextlibUsesStdlibNamespace())
AhkTest.Test("stdlib uuid uses root stdlib namespace", (*) => StdlibBootstrapTest.UuidUsesStdlibNamespace())
AhkTest.Test("stdlib inspect uses root stdlib namespace", (*) => StdlibBootstrapTest.InspectUsesStdlibNamespace())
AhkTest.Test("stdlib secrets uses root stdlib namespace", (*) => StdlibBootstrapTest.SecretsUsesStdlibNamespace())
AhkTest.Test("stdlib keyword uses root stdlib namespace", (*) => StdlibBootstrapTest.KeywordUsesStdlibNamespace())
AhkTest.Test("stdlib fnmatch uses root stdlib namespace", (*) => StdlibBootstrapTest.FnmatchUsesStdlibNamespace())
AhkTest.Test("stdlib glob uses root stdlib namespace", (*) => StdlibBootstrapTest.GlobUsesStdlibNamespace())
AhkTest.Test("stdlib string uses root stdlib namespace", (*) => StdlibBootstrapTest.StringUsesStdlibNamespace())
AhkTest.Test("stdlib textwrap uses root stdlib namespace", (*) => StdlibBootstrapTest.TextwrapUsesStdlibNamespace())
AhkTest.Test("stdlib base64 uses root stdlib namespace", (*) => StdlibBootstrapTest.Base64UsesStdlibNamespace())
AhkTest.Test("stdlib bisect uses root stdlib namespace", (*) => StdlibBootstrapTest.BisectUsesStdlibNamespace())
AhkTest.Test("stdlib getpass uses root stdlib namespace", (*) => StdlibBootstrapTest.GetpassUsesStdlibNamespace())
AhkTest.Test("stdlib binascii uses root stdlib namespace", (*) => StdlibBootstrapTest.BinasciiUsesStdlibNamespace())
AhkTest.Test("stdlib quopri uses root stdlib namespace", (*) => StdlibBootstrapTest.QuopriUsesStdlibNamespace())
AhkTest.Test("stdlib html uses root stdlib namespace", (*) => StdlibBootstrapTest.HtmlUsesStdlibNamespace())
AhkTest.Test("stdlib itertools uses root stdlib namespace", (*) => StdlibBootstrapTest.ItertoolsUsesStdlibNamespace())
AhkTest.Test("stdlib root namespace exposes tuple builtin", (*) => StdlibBootstrapTest.RootNamespaceExposesTupleBuiltin())
AhkTest.Test("stdlib root namespace exposes slice builtin", (*) => StdlibBootstrapTest.RootNamespaceExposesSliceBuiltin())
AhkTest.Test("stdlib root namespace exposes boolean builtins", (*) => StdlibBootstrapTest.RootNamespaceExposesBooleanBuiltins())
AhkTest.Test("stdlib root namespace exposes NotImplemented builtin", (*) => StdlibBootstrapTest.RootNamespaceExposesNotImplementedBuiltin())
AhkTest.Test("stdlib root namespace exposes error builtins", (*) => StdlibBootstrapTest.RootNamespaceExposesErrorBuiltins())
AhkTest.Test("stdlib root namespace await runs asyncio awaitables", (*) => StdlibBootstrapTest.RootNamespaceAwaitRunsAsyncioAwaitables())
AhkTest.Test("stdlib root namespace decorate applies decorator order", (*) => StdlibBootstrapTest.RootNamespaceDecorateAppliesDecoratorOrder())
AhkTest.Test("stdlib functools uses root stdlib namespace", (*) => StdlibBootstrapTest.FunctoolsUsesStdlibNamespace())
AhkTest.Test("stdlib calendar uses root stdlib namespace", (*) => StdlibBootstrapTest.CalendarUsesStdlibNamespace())
AhkTest.Test("stdlib collections uses root stdlib namespace", (*) => StdlibBootstrapTest.CollectionsUsesStdlibNamespace())
AhkTest.Test("stdlib datetime uses root stdlib namespace", (*) => StdlibBootstrapTest.DateTimeUsesStdlibNamespace())
AhkTest.Test("stdlib warnings uses root stdlib namespace", (*) => StdlibBootstrapTest.WarningsUsesStdlibNamespace())
AhkTest.Test("stdlib comparser uses root stdlib namespace", (*) => StdlibBootstrapTest.ComParserUsesDirectApi())
AhkTest.Test("stdlib json uses root stdlib namespace", (*) => StdlibBootstrapTest.JsonUsesStdlibNamespace())
AhkTest.Test("stdlib csv uses root stdlib namespace", (*) => StdlibBootstrapTest.CsvUsesStdlibNamespace())
AhkTest.Test("stdlib configparser uses root stdlib namespace", (*) => StdlibBootstrapTest.ConfigParserUsesStdlibNamespace())
AhkTest.Test("stdlib io uses root stdlib namespace", (*) => StdlibBootstrapTest.IoUsesStdlibNamespace())
AhkTest.Test("stdlib decimal uses root stdlib namespace", (*) => StdlibBootstrapTest.DecimalUsesStdlibNamespace())
AhkTest.Test("stdlib fractions uses root stdlib namespace", (*) => StdlibBootstrapTest.FractionsUsesStdlibNamespace())
AhkTest.Test("stdlib logging uses root stdlib namespace", (*) => StdlibBootstrapTest.LoggingUsesStdlibNamespace())
AhkTest.Test("stdlib toml exposes root stdlib direct API", (*) => StdlibBootstrapTest.TomlUsesStdlibStyleDirectApi())
AhkTest.Test("stdlib root namespace exposes direct toml", (*) => StdlibBootstrapTest.RootNamespaceExposesDirectTextToml())
AhkTest.Test("stdlib os system uses stdlib namespace", (*) => StdlibBootstrapTest.OsSystemUsesStdlibNamespace())
AhkTest.Test("stdlib platform uses stdlib namespace", (*) => StdlibBootstrapTest.PlatformUsesStdlibNamespace())
AhkTest.Test("stdlib socket uses stdlib namespace", (*) => StdlibBootstrapTest.SocketUsesStdlibNamespace())
AhkTest.Test("stdlib shutil uses stdlib namespace", (*) => StdlibBootstrapTest.ShutilUsesStdlibNamespace())
AhkTest.Test("stdlib tempfile uses stdlib namespace", (*) => StdlibBootstrapTest.TempfileUsesStdlibNamespace())
AhkTest.Test("stdlib time uses stdlib namespace", (*) => StdlibBootstrapTest.TimeUsesStdlibNamespace())
AhkTest.Test("stdlib pillow uses root stdlib namespace", (*) => StdlibBootstrapTest.PillowUsesStdlibNamespace())

stdlib_test_raise_value_error()
{
    throw ValueError("raised for test", -1)
}

class StdlibBootstrapInspectProbe
{
}

stdlib_test_inspect_probe_free(value := 0)
{
    return value
}

stdlib_bootstrap_array(iterable)
{
    result := []
    for value in iterable
        result.Push(value)
    return result
}

stdlib_bootstrap_groupby_pairs(iterable)
{
    result := []
    for row in iterable {
        values := stdlib_bootstrap_array(row)
        result.Push([values[1], stdlib_bootstrap_array(values[2])])
    }
    return result
}

stdlib_bootstrap_pairs(mapping)
{
    result := []
    for key, value in mapping
        result.Push([key, value])
    return result
}

stdlib_bootstrap_render_pairs(pairs)
{
    result := []
    for pair in pairs
        result.Push([pair[1], String(pair[2])])
    return result
}

stdlib_bootstrap_add(a, b)
{
    return a + b
}

stdlib_bootstrap_add_three(a, b, c)
{
    return a + b + c
}

stdlib_bootstrap_less_than_three(value)
{
    return value < 3
}

stdlib_bootstrap_first_char(value)
{
    return SubStr(value, 1, 1)
}

stdlib_bootstrap_truthiness_result(value)
{
    values := [stdlib.True, stdlib.False, [], [1], Map(), Map("x", 1), stdlib.None]
    return values[value + 1]
}

stdlib_bootstrap_warn_deprecated(records)
{
    stdlib.warnings.simplefilter("always")
    stdlib.warnings.warn("deprecated", stdlib.warnings.DeprecationWarning)
}

stdlib_test_raise_diagnostic_error()
{
    throw ValueError("diagnostic error", -1, "diagnostic-extra")
}

stdlib_test_write_captured_output(capture)
{
    capture.WriteOut("hello")
    capture.WriteErr("problem")
    first := capture.Read()
    AhkTest.AssertEqual("hello", first.Out)
    AhkTest.AssertEqual("problem", first.Err)
    second := capture.Read()
    AhkTest.AssertEqual("", second.Out)
    AhkTest.AssertEqual("", second.Err)
}

stdlib_test_write_unread_captured_output(capture)
{
    capture.WriteOut("stdout text")
    capture.WriteErr("stderr text")
}

stdlib_test_fail_with_captured_output(capture)
{
    capture.WriteOut("stdout before failure")
    capture.WriteErr("stderr before failure")
    AhkTest.Fail("captured failure")
}

stdlib_test_capture_child_process_output(capture)
{
    command := 'echo child stdout & echo child stderr 1>&2 & exit /b 7'
    processResult := capture.Run(command)
    AhkTest.AssertEqual(7, processResult.ExitCode)
    AhkTest.AssertContains("child stdout", processResult.Out)
    AhkTest.AssertContains("child stderr", processResult.Err)
}

stdlib_test_capture_child_process_args(capture)
{
    scriptPath := A_Temp "\ahktest-capture-args-" A_TickCount ".ahk"
    script := '#Requires AutoHotkey v2.0`n#ErrorStdOut "UTF-8"`nFileAppend "stdout:" A_Args[1] "|" A_Args[2] "|" A_Args[3] "``n", "*", "UTF-8"`nFileAppend "stderr:" A_Args[2] "``n", "**", "UTF-8"`nExitApp 9`n'
    try {
        FileAppend script, scriptPath, "UTF-8"
        processResult := capture.RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", scriptPath, "alpha beta", "literal & value", "literal %PATH% value"])
    } finally {
        if FileExist(scriptPath)
            FileDelete scriptPath
    }
    diagnostic := "stdout=" processResult.Out " stderr=" processResult.Err
    AhkTest.AssertEqual(9, processResult.ExitCode, diagnostic)
    AhkTest.AssertContains("stdout:alpha beta|literal & value|literal %PATH% value", processResult.Out, diagnostic)
    AhkTest.AssertContains("stderr:literal & value", processResult.Err, diagnostic)
}

stdlib_test_capture_child_process_timeout(capture)
{
    scriptPath := A_Temp "\ahktest-capture-timeout-" A_TickCount ".ahk"
    script := '#Requires AutoHotkey v2.0`n#ErrorStdOut "UTF-8"`nSleep 1000`nFileAppend "late output``n", "*", "UTF-8"`nExitApp 0`n'
    try {
        FileAppend script, scriptPath, "UTF-8"
        processResult := capture.RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", scriptPath], { TimeoutSeconds: 0.05 })
    } finally {
        if FileExist(scriptPath)
            FileDelete scriptPath
    }
    diagnostic := "stdout=" processResult.Out " stderr=" processResult.Err
    AhkTest.AssertTrue(processResult.TimedOut, diagnostic)
    AhkTest.AssertEqual(-1, processResult.ExitCode, diagnostic)
    AhkTest.AssertContains("capture process timed out after 0.05s", processResult.Err, diagnostic)
    AhkTest.AssertFalse(InStr(processResult.Out, "late output"), diagnostic)
}

stdlib_test_capture_child_process_waits(capture)
{
    scriptPath := A_Temp "\ahktest-capture-wait-" A_TickCount ".ahk"
    markerPath := A_Temp "\ahktest-capture-wait-" A_TickCount ".txt"
    script := '#Requires AutoHotkey v2.0`n#ErrorStdOut "UTF-8"`nSleep 300`nFileAppend "marker:waited", A_Args[1], "UTF-8"`nFileAppend "stdout:waited``n", "*", "UTF-8"`nExitApp 3`n'
    try {
        FileAppend script, scriptPath, "UTF-8"
        processResult := capture.RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", scriptPath, markerPath], { TimeoutSeconds: 2 })
        marker := FileExist(markerPath) ? FileRead(markerPath, "UTF-8") : ""
    } finally {
        if FileExist(scriptPath)
            FileDelete scriptPath
        if FileExist(markerPath)
            FileDelete markerPath
    }
    diagnostic := "exit=" processResult.ExitCode " timedOut=" (processResult.TimedOut ? "true" : "false") " stdout=" processResult.Out " stderr=" processResult.Err " marker=" marker
    AhkTest.AssertFalse(processResult.TimedOut, diagnostic)
    AhkTest.AssertEqual(3, processResult.ExitCode, diagnostic)
    AhkTest.AssertContains("stdout:waited", processResult.Out, diagnostic)
    AhkTest.AssertEqual("", processResult.Err, diagnostic)
    AhkTest.AssertEqual("marker:waited", marker, diagnostic)
}

stdlib_test_capture_child_process_large_output(capture)
{
    scriptPath := A_Temp "\ahktest-capture-large-" A_TickCount ".ahk"
    script := '#Requires AutoHotkey v2.0`n#ErrorStdOut "UTF-8"`npayload := "' stdlib_test_repeat_text("x", 120) '"`nLoop 2048 {`n    FileAppend "stdout-" A_Index ":" payload "``n", "*", "UTF-8"`n    FileAppend "stderr-" A_Index ":" payload "``n", "**", "UTF-8"`n}`nExitApp 0`n'
    try {
        FileAppend script, scriptPath, "UTF-8"
        processResult := capture.RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", scriptPath], { TimeoutSeconds: 2 })
    } finally {
        if FileExist(scriptPath)
            FileDelete scriptPath
    }
    diagnostic := "exit=" processResult.ExitCode " timedOut=" (processResult.TimedOut ? "true" : "false") " stdoutLen=" StrLen(processResult.Out) " stderrLen=" StrLen(processResult.Err)
    AhkTest.AssertFalse(processResult.TimedOut, diagnostic)
    AhkTest.AssertEqual(0, processResult.ExitCode, diagnostic)
    AhkTest.AssertContains("stdout-1:", processResult.Out, diagnostic)
    AhkTest.AssertContains("stdout-2048:", processResult.Out, diagnostic)
    AhkTest.AssertContains("stderr-1:", processResult.Err, diagnostic)
    AhkTest.AssertContains("stderr-2048:", processResult.Err, diagnostic)
}

stdlib_test_capture_child_process_encoding(capture)
{
    scriptPath := A_Temp "\ahktest-capture-encoding-" A_TickCount ".ahk"
    script := '#Requires AutoHotkey v2.0`n#ErrorStdOut "UTF-8"`nFileAppend "stdout:utf16-output``n", "*", "UTF-16-RAW"`nFileAppend "stderr:utf16-error``n", "**", "UTF-16-RAW"`nExitApp 11`n'
    try {
        FileAppend script, scriptPath, "UTF-8"
        processResult := capture.RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", scriptPath], { Encoding: "UTF-16-RAW" })
    } finally {
        if FileExist(scriptPath)
            FileDelete scriptPath
    }
    diagnostic := "exit=" processResult.ExitCode " stdout=" processResult.Out " stderr=" processResult.Err
    AhkTest.AssertEqual(11, processResult.ExitCode, diagnostic)
    AhkTest.AssertContains("stdout:utf16-output", processResult.Out, diagnostic)
    AhkTest.AssertContains("stderr:utf16-error", processResult.Err, diagnostic)
}

stdlib_test_fail_until_cleared(&shouldFail)
{
    if shouldFail
        AhkTest.Fail("still failing")
    AhkTest.AssertTrue(true)
}

stdlib_test_stepwise_maybe_fail(&shouldFail, label)
{
    if shouldFail
        AhkTest.Fail(label " failure")
    AhkTest.AssertTrue(true)
}

stdlib_test_set_flag(&flag)
{
    flag := true
}

stdlib_test_param_add(left, right, expected)
{
    AhkTest.AssertEqual(expected, left + right)
}

stdlib_test_write_temp_path(tmp, paths, text)
{
    AhkTest.AssertTrue(DirExist(tmp.Path))
    path := tmp.File("payload.txt", text)
    AhkTest.AssertEqual(text, FileRead(path, "UTF-8"))
    paths.Push(tmp.Path)
}

stdlib_test_write_utf8_raw(path, text)
{
    if FileExist(path)
        FileDelete path
    FileAppend text, path, "UTF-8-RAW"
}

stdlib_test_repeat_text(text, count)
{
    result := ""
    loop count
        result .= text
    return result
}

stdlib_test_make_temp_paths(factory, captured, label)
{
    first := factory.MakeTemp("case")
    second := factory.MakeTemp("case")
    AhkTest.AssertTrue(DirExist(first.Path))
    AhkTest.AssertTrue(DirExist(second.Path))
    AhkTest.AssertNotEqual(first.Path, second.Path)
    first.File("name.txt", label)
    captured.Push(first.Path)
    captured.Push(second.Path)
}

stdlib_test_nan()
{
    bytes := Buffer(8, 0)
    NumPut("Int64", 0x7ff8000000000000, bytes)
    return NumGet(bytes, "Double")
}

class StdlibBootstrapLengthHintValue
{
    __New(value)
    {
        this.Value := value
    }

    __LengthHint()
    {
        return this.Value
    }
}

class StdlibBootstrapLengthHintTypeError
{
    __LengthHint()
    {
        throw TypeError("bad hint", -1)
    }
}

class StdlibBootstrapContextlibCloser
{
    __New()
    {
        this.closed := false
    }

    close()
    {
        this.closed := true
    }
}

class StdlibBootstrapContextlibStackContext
{
    __New(events)
    {
        this.events := events
    }

    __enter()
    {
        this.events.Push("enter")
        return "entered"
    }

    __exit(excType, exc, tb)
    {
        this.events.Push(["exit", AhkStdlibIsNone(excType) ? stdlib.None : excType])
        return false
    }
}

class StdlibBootstrapContextlibDecoratorCore
{
    __New(events)
    {
        this.events := events
    }

    __enter()
    {
        this.events.Push("decorator-enter")
        return this
    }

    __exit(excType, exc, tb)
    {
        this.events.Push(["decorator-exit", AhkStdlibIsNone(excType) ? stdlib.None : excType])
        return false
    }
}

stdlib_bootstrap_contextlib_callback(events, label)
{
    events.Push(["callback", label])
}

stdlib_bootstrap_contextlib_decorated(events, value)
{
    events.Push(["decorated-call", value])
    return value * 2
}

class StdlibBootstrapLengthHintValueError
{
    __LengthHint()
    {
        throw ValueError("bad hint", -1)
    }
}

stdlib_test_fixture_counter(&calls)
{
    calls += 1
    return calls
}

stdlib_test_cleanup_record(cleaned, name)
{
    cleaned.Push(name)
}

stdlib_test_cleanup_record_and_throw(cleaned, name)
{
    cleaned.Push(name)
    throw Error("cleanup " name " failed", -1)
}

stdlib_test_fixture_context_resource(ctx, events)
{
    ctx.AddCleanup((*) => events.Push("context cleanup"))
    return AhkTest.FixtureResult("payload", (*) => events.Push("result cleanup"))
}

stdlib_test_fixture_context_setup_fails(ctx, events)
{
    events.Push("setup")
    ctx.AddCleanup((*) => events.Push("context cleanup"))
    throw Error("setup failed", -1)
}

stdlib_test_fixture_context_get_base(ctx)
{
    return ctx.GetFixture("base")
}

stdlib_test_assert_dynamic_fixture_names(ctx)
{
    before := ctx.FixtureNames.Clone()
    value := ctx.GetFixture("dynamic")
    again := ctx.GetFixture("dynamic")
    after := ctx.FixtureNames.Clone()

    AhkTest.AssertEqual(["ahk_context"], before)
    AhkTest.AssertEqual("base-dyn", value)
    AhkTest.AssertEqual("base-dyn", again)
    AhkTest.AssertEqual(["ahk_context", "base", "dynamic"], after)
}

stdlib_test_assert_declared_fixture_names(ctx, base)
{
    before := ctx.FixtureNames.Clone()
    value := ctx.GetFixture("base")
    after := ctx.FixtureNames.Clone()

    AhkTest.AssertEqual("base", base)
    AhkTest.AssertEqual("base", value)
    AhkTest.AssertEqual(["ahk_context", "base"], before)
    AhkTest.AssertEqual(["ahk_context", "base"], after)
}

stdlib_test_fixture_context_metadata(ctx)
{
    return Map(
        "FixtureName", ctx.FixtureName,
        "Scope", ctx.Scope,
        "TestName", ctx.TestName,
        "NodeId", ctx.NodeId,
        "ParamId", ctx.ParamId,
        "Params", ctx.Params,
        "Marks", ctx.Marks
    )
}

stdlib_test_fixture_context_fixture_names(ctx)
{
    return ctx.FixtureNames
}

stdlib_test_fixture_context_fixture_name_bundle(ctx, depNames)
{
    return Map(
        "ContextNames", ctx.FixtureNames,
        "DepNames", depNames
    )
}

stdlib_test_fixture_context_param_identity(ctx)
{
    return Map(
        "Value", ctx.GetParam(),
        "FixtureName", ctx.FixtureName,
        "FixtureParamId", ctx.FixtureParamId,
        "ParamId", ctx.ParamId
    )
}

stdlib_test_assert_fixture_context_metadata(label, meta)
{
    AhkTest.AssertEqual("payload", label)
    AhkTest.AssertEqual("meta", meta["FixtureName"])
    AhkTest.AssertEqual("function", meta["Scope"])
    AhkTest.AssertEqual("case small", meta["TestName"])
    AhkTest.AssertEqual("fixture context metadata::case small[small]", meta["NodeId"])
    AhkTest.AssertEqual("small", meta["ParamId"])
    AhkTest.AssertEqual(["payload"], meta["Params"])
    AhkTest.AssertEqual(["suite", "row"], meta["Marks"])
}

stdlib_test_assert_fixture_context_fixture_names(meta)
{
    expected := ["auto", "meta", "ahk_context", "dep"]
    AhkTest.AssertEqual(expected, meta["ContextNames"])
    AhkTest.AssertEqual(expected, meta["DepNames"])
}

stdlib_test_assert_same_fixture_value(child, base)
{
    AhkTest.AssertSame(child, base)
    AhkTest.AssertEqual("root", base.Name)
}

stdlib_test_fixture_from_param(ctx)
{
    return ctx.Param
}

stdlib_test_param_fixture(label, config, seen)
{
    AhkTest.AssertEqual(label, config["mode"])
    seen.Push(label ":" config["port"])
}

stdlib_test_stacked_param_fixture(leftLabel, rightLabel, leftConfig, rightConfig, seen)
{
    AhkTest.AssertEqual(leftLabel, leftConfig["mode"])
    AhkTest.AssertEqual(rightLabel, rightConfig["size"])
    seen.Push(leftConfig["mode"] ":" rightConfig["size"])
}

stdlib_test_fixture_param_value(config, seen)
{
    seen.Push(config["mode"] ":" config["port"])
}

stdlib_test_scoped_fixture(&calls, cleaned, name)
{
    calls += 1
    return AhkTest.FixtureResult({ Id: calls }, (*) => stdlib_test_cleanup_record(cleaned, name))
}

stdlib_test_scoped_param_fixture(ctx, &calls, cleaned, cleanupPrefix)
{
    param := ctx.Param
    calls += 1
    return AhkTest.FixtureResult({ Id: calls, Name: param }, (*) => stdlib_test_cleanup_record(cleaned, cleanupPrefix ":" param))
}

stdlib_test_scoped_setup_fails(ctx, &calls, cleaned, name)
{
    calls += 1
    ctx.AddCleanup((*) => stdlib_test_cleanup_record(cleaned, name))
    throw Error(name " setup failed", -1)
}

stdlib_test_record_scoped_param(label, value, seen)
{
    seen.Push(label ":" value.Name ":" value.Id)
}

stdlib_test_named_scoped_fixture(&calls, cleaned, cleanupName, valueName)
{
    calls += 1
    return AhkTest.FixtureResult({ Id: calls, Name: valueName }, (*) => stdlib_test_cleanup_record(cleaned, cleanupName))
}

stdlib_test_assert_suite_scoped_fixture(value, cleaned)
{
    AhkTest.AssertEqual(1, value.Id)
    AhkTest.AssertEqual(0, cleaned.Length)
}

stdlib_test_autouse_fixture(events)
{
    events.Push("setup")
    return AhkTest.FixtureResult("", (*) => events.Push("cleanup"))
}

stdlib_test_autouse_base(events)
{
    events.Push("base")
    return AhkTest.FixtureResult("root", (*) => events.Push("base cleanup"))
}

stdlib_test_autouse_dependent(events, base)
{
    events.Push("auto:" base)
    return AhkTest.FixtureResult("", (*) => events.Push("auto cleanup"))
}

stdlib_test_patch_env(patch, existingName, missingName)
{
    patch.SetEnv(existingName, "after")
    patch.SetEnv(missingName, "created")
    AhkTest.AssertEqual("after", EnvGet(existingName))
    AhkTest.AssertEqual("created", EnvGet(missingName))
}

stdlib_test_delete_env(patch, name)
{
    patch.DelEnv(name)
    AhkTest.AssertEqual("", EnvGet(name))
}

stdlib_test_prepend_env_path(patch, name)
{
    patch.PrependEnvPath("head", name)
    AhkTest.AssertEqual("head;tail", EnvGet(name))
}

stdlib_test_patch_map(patch, target)
{
    patch.SetMap(target, "existing", "after")
    patch.SetMap(target, "created", "new")
    patch.DelMap(target, "deleted")
    AhkTest.AssertEqual("after", target["existing"])
    AhkTest.AssertEqual("new", target["created"])
    AhkTest.AssertFalse(target.Has("deleted"))
}

stdlib_test_patch_object_props(patch, target)
{
    patch.SetProp(target, "Existing", "after")
    patch.SetProp(target, "Created", "new")
    patch.DelProp(target, "Deleted")
    AhkTest.AssertEqual("after", target.Existing)
    AhkTest.AssertEqual("new", target.Created)
    AhkTest.AssertFalse(target.HasOwnProp("Deleted"))
}

stdlib_test_original_method(this, value)
{
    return "original:" value
}

stdlib_test_replacement_method(this, value)
{
    return "replacement:" value
}

stdlib_test_created_method(this, value)
{
    return "created:" value
}

stdlib_test_patch_object_methods(patch, target)
{
    patch.SetMethod(target, "Existing", stdlib_test_replacement_method)
    patch.SetMethod(target, "Created", stdlib_test_created_method)
    AhkTest.AssertEqual("replacement:value", target.Existing("value"))
    AhkTest.AssertEqual("created:value", target.Created("value"))
    AhkTest.Fail("force cleanup after patched method failure")
}

stdlib_test_patch_cwd(patch, path)
{
    patch.ChDir(path)
    AhkTest.AssertEqual(path, A_WorkingDir)
}

stdlib_bootstrap_itertools_mul(a, b)
{
    return stdlib.operator.mul(a, b)
}

stdlib_bootstrap_enum_member_names(enumType)
{
    result := []
    for name, value in enumType.__members
        result.Push(name)
    return result
}

stdlib_bootstrap_enum_member_values(enumType)
{
    result := []
    for item in enumType
        result.Push(item.value)
    return result
}
