#Requires AutoHotkey v2.0
#ErrorStdOut "UTF-8"
#Include <stdlib\init>
#Include <stdlib\json>

class AhkTestFailure extends Error
{
    __New(message, expected := unset, actual := unset)
    {
        super.__New(message, -1)
        if IsSet(expected)
            this.Expected := expected
        if IsSet(actual)
            this.Actual := actual
    }
}

class AhkTestSkip extends Error
{
    __New(reason := "")
    {
        super.__New(reason, -1)
        this.Reason := reason
    }
}

class AhkTestCleanupFailure extends Error
{
    __New(errors)
    {
        super.__New("fixture cleanup failed: " errors.Length " error(s)", -1)
        this.Errors := errors
    }
}

class AhkTestHookFailure extends Error
{
    __New(errors)
    {
        super.__New("hook failed: " errors.Length " error(s)", -1)
        this.Errors := errors
    }
}

class AhkTestWarningFailure extends Error
{
    __New(record)
    {
        super.__New("warning treated as error: " record.Category ": " record.Message, -1)
        this.Warning := record
        if HasProp(record, "File")
            this.File := record.File
        if HasProp(record, "Line")
            this.Line := record.Line
        if HasProp(record, "What")
            this.What := record.What
        if HasProp(record, "Extra")
            this.Extra := record.Extra
        if HasProp(record, "Stack")
            this.Stack := record.Stack
    }
}

class AhkTestCollectionError extends Error
{
    __New(detailOrError)
    {
        super.__New("collection failure", -1)
        this.Detail := ""
        if detailOrError is Error {
            this.Cause := detailOrError
            this.Detail := HasProp(detailOrError, "Message") ? detailOrError.Message : detailOrError ""
            if HasProp(detailOrError, "File")
                this.File := detailOrError.File
            if HasProp(detailOrError, "Line")
                this.Line := detailOrError.Line
            if HasProp(detailOrError, "What")
                this.What := detailOrError.What
            if HasProp(detailOrError, "Stack")
                this.Stack := detailOrError.Stack
            detailExtra := HasProp(detailOrError, "Extra") ? detailOrError.Extra : ""
            if this.Detail != "" && detailExtra != ""
                this.Extra := this.Detail "`n" detailExtra
            else if this.Detail != ""
                this.Extra := this.Detail
            else if detailExtra != ""
                this.Extra := detailExtra
            return
        }

        this.Detail := detailOrError ""
        if this.Detail != ""
            this.Extra := this.Detail
    }
}

class AhkTestApprox
{
    static DefaultRelativeTolerance := 0.000001
    static DefaultAbsoluteTolerance := 0.000000000001

    __New(expected, options := unset)
    {
        this.Expected := expected
        this.HasRel := false
        this.HasAbs := false
        this.NanOk := false
        this.Rel := 0
        this.Abs := 0

        if IsSet(options) {
            if HasProp(options, "Rel") {
                this.HasRel := true
                this.Rel := options.Rel
            }
            if HasProp(options, "Abs") {
                this.HasAbs := true
                this.Abs := options.Abs
            }
            if HasProp(options, "NanOk")
                this.NanOk := options.NanOk
        }
    }

    Matches(actual)
    {
        return this.ValueMatches(this.Expected, actual)
    }

    ValueMatches(expected, actual)
    {
        if expected is Array {
            if !(actual is Array) || expected.Length != actual.Length
                return false
            loop expected.Length {
                if !this.ValueMatches(expected[A_Index], actual[A_Index])
                    return false
            }
            return true
        }

        if expected is Map {
            if !(actual is Map) || expected.Count != actual.Count
                return false
            for key, expectedValue in expected {
                if !actual.Has(key)
                    return false
                if !this.ValueMatches(expectedValue, actual[key])
                    return false
            }
            return true
        }

        if !IsNumber(expected) || !IsNumber(actual)
            return AhkTest.AreEqual(expected, actual)

        if this.IsNan(expected) || this.IsNan(actual)
            return this.NanOk && this.IsNan(expected) && this.IsNan(actual)

        return this.NumberMatches(Number(expected), Number(actual))
    }

    NumberMatches(expected, actual)
    {
        if expected == actual
            return true

        return Abs(actual - expected) <= this.ToleranceFor(expected)
    }

    ToleranceFor(expected)
    {
        absoluteTolerance := this.HasAbs ? this.Abs : AhkTestApprox.DefaultAbsoluteTolerance
        if absoluteTolerance < 0
            throw ValueError("absolute tolerance can't be negative: " absoluteTolerance, -1)
        if this.IsNan(absoluteTolerance)
            throw ValueError("absolute tolerance can't be NaN.", -1)

        if this.HasAbs && !this.HasRel
            return absoluteTolerance

        relativeTolerance := (this.HasRel ? this.Rel : AhkTestApprox.DefaultRelativeTolerance) * Abs(expected)
        if relativeTolerance < 0
            throw ValueError("relative tolerance can't be negative: " relativeTolerance, -1)
        if this.IsNan(relativeTolerance)
            throw ValueError("relative tolerance can't be NaN.", -1)

        return Max(relativeTolerance, absoluteTolerance)
    }

    IsNan(value)
    {
        return IsNumber(value) && value != value
    }
}

class AhkTestFixtureResult
{
    __New(value, cleanup := unset)
    {
        this.Value := value
        if IsSet(cleanup)
            this.Cleanup := cleanup
    }
}

class AhkTestFixtureSetupError
{
    __New(err)
    {
        this.Error := err
    }
}

class AhkTestFixtureContext
{
    __New(suite, resolveCleanups, cleanupTarget, resolving, fixtureContext, fixtureName := "", scope := "function")
    {
        this.Suite := suite
        this.ResolveCleanups := resolveCleanups
        this.CleanupTarget := cleanupTarget
        this.Resolving := resolving
        this.FixtureContext := fixtureContext
        this.FixtureName := fixtureName
        this.Scope := scope
        this.FixtureParamId := ""
        this.TestName := HasProp(fixtureContext, "TestName") ? fixtureContext.TestName : ""
        this.NodeId := HasProp(fixtureContext, "NodeId") ? fixtureContext.NodeId : ""
        this.ParamId := HasProp(fixtureContext, "ParamId") ? fixtureContext.ParamId : ""
        this.Params := HasProp(fixtureContext, "Params") ? fixtureContext.Params : []
        this.Marks := HasProp(fixtureContext, "Marks") ? fixtureContext.Marks : []
        this.FixtureNames := HasProp(fixtureContext, "FixtureNames") ? fixtureContext.FixtureNames : []
        if HasProp(fixtureContext, "Source")
            this.Source := fixtureContext.Source
        if HasProp(fixtureContext, "MarkDetails")
            this.MarkDetails := fixtureContext.MarkDetails
    }

    AddCleanup(callback)
    {
        if !HasMethod(callback, "Call")
            throw TypeError("cleanup callback must be callable", -1)
        this.CleanupTarget.Push(callback)
        return callback
    }

    GetFixture(name)
    {
        this.Suite.AppendDynamicFixtureNames(name, this.FixtureContext, this.FixtureNames)
        return this.Suite.ResolveFixture(name, this.ResolveCleanups, this.Resolving, this.FixtureContext)
    }

    GetParam()
    {
        if !HasProp(this, "Param")
            throw ValueError("fixture has no parameter: " this.FixtureName, -1)
        return this.Param
    }
}

class AhkTestCapture
{
    __New()
    {
        this.Out := ""
        this.Err := ""
    }

    Run(command, options := unset)
    {
        if command = ""
            throw ValueError("capture command cannot be empty", -1)

        workingDir := ""
        encoding := "UTF-8"
        if IsSet(options) {
            if !IsObject(options)
                throw TypeError("capture run options must be an object", -1)
            if HasProp(options, "WorkingDir")
                workingDir := options.WorkingDir
            if HasProp(options, "Encoding")
                encoding := options.Encoding
        }

        id := "ahktest-capture-" A_NowUTC "-" A_TickCount
        outFile := A_Temp "\" id ".out.txt"
        errFile := A_Temp "\" id ".err.txt"
        this.DeleteFile(outFile)
        this.DeleteFile(errFile)

        out := ""
        err := ""
        exitCode := 0
        try {
            target := this.BuildShellCommand(command, outFile, errFile)
            exitCode := RunWait(target, workingDir, "Hide")
            if FileExist(outFile)
                out := FileRead(outFile, encoding)
            if FileExist(errFile)
                err := FileRead(errFile, encoding)
        } finally {
            this.DeleteFile(outFile)
            this.DeleteFile(errFile)
        }

        this.WriteOut(out)
        this.WriteErr(err)
        return AhkTestProcessResult(exitCode, out, err)
    }

    RunArgs(executable, args := unset, options := unset)
    {
        if executable = ""
            throw ValueError("capture executable cannot be empty", -1)

        if !IsSet(args)
            args := []
        if !(args is Array)
            throw TypeError("capture args must be an array", -1)

        workingDir := ""
        encoding := "UTF-8"
        timeoutSeconds := 0
        if IsSet(options) {
            if !IsObject(options)
                throw TypeError("capture run options must be an object", -1)
            if HasProp(options, "WorkingDir")
                workingDir := options.WorkingDir
            if HasProp(options, "Encoding")
                encoding := options.Encoding
            if HasProp(options, "TimeoutSeconds") {
                if options.TimeoutSeconds < 0
                    throw ValueError("capture timeout cannot be negative: " options.TimeoutSeconds, -1)
                timeoutSeconds := options.TimeoutSeconds
            }
        }

        id := "ahktest-capture-args-" A_NowUTC "-" A_TickCount
        outFile := A_Temp "\" id ".out.txt"
        errFile := A_Temp "\" id ".err.txt"
        exitFile := A_Temp "\" id ".exit.txt"
        commandFile := A_Temp "\" id ".cmd"
        this.DeleteFile(outFile)
        this.DeleteFile(errFile)
        this.DeleteFile(exitFile)
        this.DeleteFile(commandFile)

        out := ""
        err := ""
        exitCode := 0
        timedOut := false
        try {
            commandLine := this.BuildArgumentCommand(executable, args)
            commandText := this.BuildRedirectCommandFile(commandLine, outFile, errFile, exitFile)
            FileAppend commandText, commandFile, "CP0"
            target := A_ComSpec " /d /c " this.QuoteCommandArgument(commandFile)
            Run target, workingDir, "Hide", &pid
            started := A_TickCount
            while ProcessExist(pid) {
                if timeoutSeconds > 0 && (A_TickCount - started) >= timeoutSeconds * 1000 {
                    timedOut := true
                    this.TerminateProcessTree(pid)
                    break
                }
                Sleep 10
            }
            if !timedOut
                ProcessWaitClose(pid, 0.5)
            if FileExist(outFile)
                out := FileRead(outFile, encoding)
            if FileExist(errFile)
                err := FileRead(errFile, encoding)
            if timedOut {
                exitCode := -1
                err .= "capture process timed out after " this.FormatTimeoutSeconds(timeoutSeconds) "s"
            } else {
                exitCode := this.ReadExitCodeFile(exitFile)
            }
        } finally {
            this.DeleteFile(outFile)
            this.DeleteFile(errFile)
            this.DeleteFile(exitFile)
            this.DeleteFile(commandFile)
        }

        this.WriteOut(out)
        this.WriteErr(err)
        return AhkTestProcessResult(exitCode, out, err, { TimedOut: timedOut })
    }

    WriteOut(text := "")
    {
        this.Out .= text
    }

    WriteErr(text := "")
    {
        this.Err .= text
    }

    Read()
    {
        result := { Out: this.Out, Err: this.Err }
        this.Out := ""
        this.Err := ""
        return result
    }

    Snapshot()
    {
        return { Out: this.Out, Err: this.Err }
    }

    BuildShellCommand(command, outFile, errFile)
    {
        return A_ComSpec ' /c "(' command ') >"' outFile '" 2>"' errFile '""'
    }

    BuildRedirectCommandFile(commandLine, outFile, errFile, exitFile)
    {
        text := "@echo off`r`n"
        text .= this.EscapeCmdBatchCommand(commandLine) " >" this.QuoteCmdRedirectPath(outFile) " 2>" this.QuoteCmdRedirectPath(errFile) "`r`n"
        text .= "set ahktest_exit=%ERRORLEVEL%`r`n"
        text .= "> " this.QuoteCmdRedirectPath(exitFile) " echo %ahktest_exit%`r`n"
        text .= "exit /b %ahktest_exit%`r`n"
        return text
    }

    EscapeCmdBatchCommand(commandLine)
    {
        return StrReplace(commandLine, "%", "%%")
    }

    QuoteCmdRedirectPath(path)
    {
        return '"' StrReplace(path, '"', '""') '"'
    }

    ReadExitCodeFile(path)
    {
        if !FileExist(path)
            return 1
        text := Trim(FileRead(path, "CP0"), "`r`n `t")
        if RegExMatch(text, "^-?\d+$")
            return Integer(text)
        return 1
    }

    BuildArgumentCommand(executable, args)
    {
        command := this.QuoteCommandArgument(executable)
        for arg in args
            command .= " " this.QuoteCommandArgument(arg)
        return command
    }

    QuoteCommandArgument(value)
    {
        text := value ""
        if text = ""
            return '""'

        needsQuote := RegExMatch(text, '[\s"`&|<>()^]')
        if !needsQuote
            return text

        quoted := '"'
        slashCount := 0
        Loop Parse, text {
            char := A_LoopField
            if char = "\" {
                slashCount += 1
            } else if char = '"' {
                quoted .= this.RepeatString("\", slashCount * 2 + 1) '"'
                slashCount := 0
            } else {
                if slashCount > 0 {
                    quoted .= this.RepeatString("\", slashCount)
                    slashCount := 0
                }
                quoted .= char
            }
        }
        if slashCount > 0
            quoted .= this.RepeatString("\", slashCount * 2)
        quoted .= '"'
        return quoted
    }

    RepeatString(text, count)
    {
        result := ""
        loop count
            result .= text
        return result
    }

    FormatTimeoutSeconds(seconds)
    {
        text := Format("{:.6f}", seconds)
        while InStr(text, ".") && SubStr(text, -1) = "0"
            text := SubStr(text, 1, -1)
        if SubStr(text, -1) = "."
            text := SubStr(text, 1, -1)
        return text
    }

    TerminateProcessTree(pid)
    {
        if pid = ""
            return
        try RunWait(A_ComSpec " /c taskkill /PID " pid " /T /F >nul 2>nul", "", "Hide")
        try ProcessClose(pid)
        try ProcessWaitClose(pid, 0.5)
    }

    DeleteFile(path)
    {
        try {
            if FileExist(path)
                FileDelete path
        }
    }
}

class AhkTestProcessResult
{
    __New(exitCode, out := "", err := "", options := unset)
    {
        this.ExitCode := exitCode
        this.Out := out
        this.Err := err
        if IsSet(options) && HasProp(options, "TimedOut")
            this.TimedOut := options.TimedOut
    }
}

class AhkTestWarningRecord
{
    __New(message, category := "warning", location := unset)
    {
        this.Message := message
        this.Category := category
        if IsSet(location) {
            if HasProp(location, "File")
                this.File := location.File
            if HasProp(location, "Line")
                this.Line := location.Line
            if HasProp(location, "What")
                this.What := location.What
            if HasProp(location, "Extra")
                this.Extra := location.Extra
            if HasProp(location, "Stack")
                this.Stack := location.Stack
        }
    }
}

class AhkTestMark
{
    __New(name, data := unset)
    {
        if name = ""
            throw ValueError("mark name cannot be empty", -1)
        this.Name := name
        if IsSet(data)
            this.Data := data
    }
}

class AhkTestSkipMark
{
    __New(reason := "")
    {
        this.Reason := reason
    }
}

class AhkTestXFailMark
{
    __New(reason := "", options := unset)
    {
        this.Reason := reason
        if IsSet(options) && HasProp(options, "Strict")
            this.Strict := options.Strict
    }
}

class AhkTestFilterExpression
{
    __New(expression)
    {
        this.Expression := expression ""
        this.Tokens := this.Tokenize(this.Expression)
        this.Position := 1
    }

    Matches(target)
    {
        this.Position := 1
        value := this.ParseOr(target)
        if this.Peek() != ""
            this.Invalid("unexpected token: " this.Peek())
        return value
    }

    Tokenize(expression)
    {
        tokens := []
        current := ""
        inQuote := false
        escaped := false
        Loop Parse, expression {
            char := A_LoopField
            if escaped {
                current .= char
                escaped := false
            } else if char = "``" {
                escaped := true
            } else if char = '"' {
                inQuote := !inQuote
                if !inQuote {
                    tokens.Push(current)
                    current := ""
                }
            } else if inQuote {
                current .= char
            } else if char = " " || char = "`t" {
                if current != "" {
                    tokens.Push(current)
                    current := ""
                }
            } else if char = "(" || char = ")" {
                if current != "" {
                    tokens.Push(current)
                    current := ""
                }
                tokens.Push(char)
            } else {
                current .= char
            }
        }
        if inQuote
            this.Invalid("unterminated quoted phrase")
        if current != ""
            tokens.Push(current)
        return tokens
    }

    ParseOr(target)
    {
        value := this.ParseAnd(target)
        while StrLower(this.Peek()) = "or" {
            this.Position += 1
            right := this.ParseAnd(target)
            value := value || right
        }
        return value
    }

    ParseAnd(target)
    {
        value := this.ParseNot(target)
        while StrLower(this.Peek()) = "and" {
            this.Position += 1
            right := this.ParseNot(target)
            value := value && right
        }
        return value
    }

    ParseNot(target)
    {
        if StrLower(this.Peek()) = "not" {
            this.Position += 1
            return !this.ParseNot(target)
        }
        return this.ParseTerm(target)
    }

    ParseTerm(target)
    {
        token := this.Peek()
        if token = ""
            this.Invalid("expected term")
        if token = "(" {
            this.Position += 1
            value := this.ParseOr(target)
            if this.Peek() = ")"
                this.Position += 1
            else
                this.Invalid("expected )")
            return value
        }
        if token = ")"
            this.Invalid("unexpected )")
        lowered := StrLower(token)
        if lowered = "and" || lowered = "or" || lowered = "not"
            this.Invalid("expected term before " token)
        this.Position += 1
        if HasMethod(target, "Call")
            return target.Call(token)
        return InStr(target, token) > 0
    }

    Peek()
    {
        if this.Position > this.Tokens.Length
            return ""
        return this.Tokens[this.Position]
    }

    Invalid(reason)
    {
        throw ValueError("invalid filter expression: " reason, -1)
    }
}

class AhkTestResult
{
    __New(stats, entries)
    {
        this.Total := stats.Total
        this.Passed := stats.Passed
        this.Failed := stats.Failed
        this.Errors := stats.Errors
        this.Skipped := stats.Skipped
        this.Deselected := stats.Deselected
        this.ExpectedFailures := stats.ExpectedFailures
        this.UnexpectedPasses := stats.UnexpectedPasses
        this.Duration := stats.Duration
        this.Entries := entries
        if HasProp(stats, "Name")
            this.Name := stats.Name
    }

    ExitCode {
        get {
            if this.Errors > 0 {
                for entry in this.Entries {
                    if entry.Status = "error" && HasProp(entry, "Error") && Type(entry.Error) = "AhkTestCollectionError"
                        return 2
                }
            }
            return (this.Failed = 0 && this.Errors = 0) ? 0 : 1
        }
    }

    ToMap()
    {
        entries := []
        for entry in this.Entries
            entries.Push(this.EntryToMap(entry))

        return Map(
            "Total", this.Total,
            "Passed", this.Passed,
            "Failed", this.Failed,
            "Errors", this.Errors,
            "Skipped", this.Skipped,
            "Deselected", this.Deselected,
            "ExpectedFailures", this.ExpectedFailures,
            "UnexpectedPasses", this.UnexpectedPasses,
            "Duration", this.Duration,
            "ExitCode", this.ExitCode,
            "OutcomeReasons", this.OutcomeReasons(),
            "WarningSummary", this.WarningSummary(),
            "Entries", entries
        )
    }

    OutcomeReasons()
    {
        groups := []
        for entry in this.Entries {
            if entry.Status != "skip" && entry.Status != "xfail" && entry.Status != "xpass"
                continue
            reason := HasProp(entry, "Reason") ? entry.Reason : ""
            found := false
            for group in groups {
                if group["Status"] = entry.Status && group["Reason"] = reason {
                    group["Count"] += 1
                    found := true
                    break
                }
            }
            if !found
                groups.Push(Map("Status", entry.Status, "Reason", reason, "Count", 1))
        }
        return groups
    }

    WarningSummary()
    {
        groups := []
        for entry in this.Entries {
            if !HasProp(entry, "Warnings")
                continue
            for warning in entry.Warnings {
                found := false
                for group in groups {
                    if group["Category"] = warning.Category && group["Message"] = warning.Message {
                        group["Count"] += 1
                        found := true
                        break
                    }
                }
                if !found
                    groups.Push(Map("Category", warning.Category, "Message", warning.Message, "Count", 1))
            }
        }
        return groups
    }

    ToJson()
    {
        return this.JsonValue(this.ToMap())
    }

    WriteJson(path)
    {
        this.WriteTextFile(path, this.ToJson())
        return path
    }

    JsonValue(value)
    {
        if value is Map {
            parts := []
            for key, item in value
                parts.Push(this.JsonString(key) ":" this.JsonValue(item))
            return "{" AhkTest.Join(parts, ",") "}"
        }
        if value is Array {
            parts := []
            for item in value
                parts.Push(this.JsonValue(item))
            return "[" AhkTest.Join(parts, ",") "]"
        }
        if IsObject(value)
            return this.JsonString(AhkTest.ValueToString(value))
        if Type(value) = "Integer" || Type(value) = "Float"
            return value ""
        if value == true
            return "true"
        if value == false
            return "false"
        return this.JsonString(value)
    }

    JsonString(value)
    {
        text := value ""
        text := StrReplace(text, "\", "\\")
        text := StrReplace(text, '"', '\"')
        text := StrReplace(text, "`r", "\r")
        text := StrReplace(text, "`n", "\n")
        text := StrReplace(text, "`t", "\t")
        return '"' text '"'
    }

    ToJUnitXml(name := "")
    {
        suiteName := name != "" ? name : this.SuiteName()
        xml := '<?xml version="1.0" encoding="UTF-8"?>`n'
        xml .= '<testsuite name="' this.XmlEscape(suiteName) '" tests="' this.Total '" failures="' this.Failed '" errors="' this.Errors '" skipped="' this.Skipped '" time="' this.DurationSeconds() '">`n'
        for entry in this.Entries
            xml .= this.EntryToJUnitXml(entry)
        xml .= '</testsuite>'
        return xml
    }

    WriteJUnitXml(path, name := "")
    {
        this.WriteTextFile(path, this.ToJUnitXml(name))
        return path
    }

    WriteTextFile(path, text)
    {
        parent := this.ParentDir(path)
        if parent != "" && !DirExist(parent)
            DirCreate parent
        if FileExist(path)
            FileDelete path
        FileAppend text, path, "UTF-8"
    }

    ParentDir(path)
    {
        SplitPath path, , &dir
        return dir
    }

    SuiteName()
    {
        if HasProp(this, "Name") && this.Name != ""
            return this.Name
        return "ahktest"
    }

    DurationSeconds()
    {
        return Format("{:.3f}", this.Duration / 1000.0)
    }

    EntryToJUnitXml(entry)
    {
        xml := '  <testcase name="' this.XmlEscape(entry.Name) '" time="' Format("{:.3f}", entry.Duration / 1000.0) '">'
        if entry.Status = "fail" || (entry.Status = "xpass" && HasProp(entry, "Strict") && entry.Strict) {
            message := HasProp(entry, "Error") && HasProp(entry.Error, "Message") ? entry.Error.Message : entry.Status
            typeName := HasProp(entry, "Error") ? Type(entry.Error) : "AhkTestFailure"
            xml .= '<failure type="' this.XmlEscape(typeName) '" message="' this.XmlEscape(message) '"/>'
        } else if entry.Status = "error" {
            message := HasProp(entry, "Error") && HasProp(entry.Error, "Message") ? entry.Error.Message : entry.Status
            typeName := HasProp(entry, "Error") ? Type(entry.Error) : "Error"
            xml .= '<error type="' this.XmlEscape(typeName) '" message="' this.XmlEscape(message) '"/>'
        } else if entry.Status = "skip" || entry.Status = "xfail" {
            message := HasProp(entry, "Reason") ? entry.Reason : entry.Status
            xml .= '<skipped message="' this.XmlEscape(message) '"/>'
        }
        xml .= '</testcase>`n'
        return xml
    }

    XmlEscape(value)
    {
        text := value ""
        text := StrReplace(text, "&", "&amp;")
        text := StrReplace(text, '"', "&quot;")
        text := StrReplace(text, "<", "&lt;")
        text := StrReplace(text, ">", "&gt;")
        text := StrReplace(text, "'", "&apos;")
        return text
    }

    EntryToMap(entry)
    {
        data := Map(
            "Name", entry.Name,
            "Status", entry.Status,
            "Duration", entry.Duration
        )
        if HasProp(entry, "Reason")
            data["Reason"] := entry.Reason
        if HasProp(entry, "NodeId")
            data["NodeId"] := entry.NodeId
        if HasProp(entry, "Source")
            data["Source"] := this.SourceToMap(entry.Source)
        if HasProp(entry, "ParamId")
            data["ParamId"] := entry.ParamId
        if HasProp(entry, "Params")
            data["Params"] := entry.Params
        if HasProp(entry, "Marks")
            data["Marks"] := entry.Marks
        if HasProp(entry, "MarkDetails")
            data["MarkDetails"] := this.MarkDetailsToMaps(entry.MarkDetails)
        if HasProp(entry, "Strict")
            data["Strict"] := entry.Strict
        if HasProp(entry, "Captured")
            data["Captured"] := Map("Out", entry.Captured.Out, "Err", entry.Captured.Err)
        if HasProp(entry, "Warnings")
            data["Warnings"] := this.WarningRecordsToMaps(entry.Warnings)
        if HasProp(entry, "Error") {
            data["ErrorType"] := Type(entry.Error)
            data["ErrorMessage"] := HasProp(entry.Error, "Message") ? entry.Error.Message : entry.Error ""
            if HasProp(entry.Error, "File")
                data["ErrorFile"] := entry.Error.File
            if HasProp(entry.Error, "Line")
                data["ErrorLine"] := entry.Error.Line
            if HasProp(entry.Error, "What")
                data["ErrorWhat"] := entry.Error.What
            if HasProp(entry.Error, "Extra")
                data["ErrorExtra"] := entry.Error.Extra
            if HasProp(entry.Error, "Stack")
                data["ErrorStack"] := entry.Error.Stack
        }
        return data
    }

    WarningRecordsToMaps(records)
    {
        warnings := []
        for record in records {
            data := Map("Message", record.Message, "Category", record.Category)
            if HasProp(record, "File")
                data["File"] := record.File
            if HasProp(record, "Line")
                data["Line"] := record.Line
            if HasProp(record, "What")
                data["What"] := record.What
            if HasProp(record, "Extra")
                data["Extra"] := record.Extra
            if HasProp(record, "Stack")
                data["Stack"] := record.Stack
            warnings.Push(data)
        }
        return warnings
    }

    MarkDetailsToMaps(markDetails)
    {
        details := []
        for mark in markDetails {
            data := Map("Name", mark.Name)
            if HasProp(mark, "Data")
                data["Data"] := mark.Data
            details.Push(data)
        }
        return details
    }

    SourceToMap(source)
    {
        if source is Map
            return source

        data := Map()
        if HasProp(source, "Kind")
            data["Kind"] := source.Kind
        if HasProp(source, "File")
            data["File"] := source.File
        if HasProp(source, "Line")
            data["Line"] := source.Line
        if HasProp(source, "Class")
            data["Class"] := source.Class
        if HasProp(source, "Method")
            data["Method"] := source.Method
        return data
    }
}

class AhkTestSuite
{
    static NextSuiteId := 0
    static SessionValues := Map()
    static SessionCleanups := []

    __New(name := "")
    {
        AhkTestSuite.NextSuiteId += 1
        this.SessionId := AhkTestSuite.NextSuiteId
        this.Name := name
        this.Tests := []
        this.Fixtures := Map()
        this.Hooks := Map()
        this.HookOrder := 0
        this.LastFailedNames := Map()
        this.StepwiseNodeId := ""
        this.RegisteredMarks := Map()
        this.WarningFilters := []
        this.AhkRunDefaults := {}
        this.OutputFile := ""
        this.OutputHandle := ""
        this.BufferedOutput := false
    }

    Test(name, callback, options := unset)
    {
        if name = ""
            throw ValueError("test name cannot be empty", -1)
        if !HasMethod(callback, "Call")
            throw TypeError("test callback must be callable", -1)
        test := { Name: name, Callback: callback, Skip: false }
        hasSource := false
        if IsSet(options) {
            if HasProp(options, "Fixtures")
                test.Fixtures := options.Fixtures
            if HasProp(options, "Marks")
                this.ApplyMarkDeclarations(test, options.Marks)
            if HasProp(options, "Source") {
                test.Source := options.Source
                hasSource := true
            }
            if HasProp(options, "ParamId")
                test.ParamId := options.ParamId
            if HasProp(options, "Params")
                test.Params := options.Params
            if HasProp(options, "FixtureParams")
                test.FixtureParams := options.FixtureParams
            if HasProp(options, "AhkFixtureOverrides")
                test.AhkFixtureOverrides := this.NormalizeFixtureOverrides(options.AhkFixtureOverrides)
        }
        if !hasSource
            test.Source := this.SourceFromLocation("test", Error("source", -1))
        this.Tests.Push(test)
        return callback
    }

    Fixture(name, callback, options := unset)
    {
        if name = ""
            throw ValueError("fixture name cannot be empty", -1)
        if this.IsContextFixtureName(name)
            throw ValueError("reserved fixture name: " name, -1)
        if !HasMethod(callback, "Call")
            throw TypeError("fixture callback must be callable", -1)
        fixture := { Name: name, Callback: callback }
        if IsSet(options) && HasProp(options, "Fixtures")
            fixture.Fixtures := options.Fixtures
        if IsSet(options) && HasProp(options, "Scope")
            fixture.Scope := this.NormalizeFixtureScope(options.Scope)
        if IsSet(options) && HasProp(options, "Autouse")
            fixture.Autouse := options.Autouse
        if IsSet(options) && HasProp(options, "Params") {
            if !(options.Params is Array)
                throw TypeError("fixture params must be an Array", -1)
            fixture.Params := options.Params
        }
        this.Fixtures[name] := fixture
        return callback
    }

    RegisterMark(name, description := "")
    {
        if name = ""
            throw ValueError("mark name cannot be empty", -1)
        this.RegisteredMarks[name] := description
        return name
    }

    Configure(config)
    {
        if !IsObject(config)
            throw TypeError("ahktest config must be an object", -1)
        if HasProp(config, "Marks")
            this.ConfigureMarks(config.Marks)
        if HasProp(config, "WarningFilter")
            this.WarningFilters := this.NormalizeWarningFilters(config.WarningFilter)
        if HasProp(config, "WarningFilters")
            this.WarningFilters := this.NormalizeWarningFilters(config.WarningFilters)
        if HasProp(config, "AhkRunDefaults")
            this.AhkRunDefaults := this.NormalizeAhkRunDefaults(config.AhkRunDefaults)
        return this
    }

    ConfigureManifest(path, sectionName := "AhkTest")
    {
        manifest := stdlib.json.load(path)
        config := this.ManifestConfigSection(manifest, sectionName)
        return this.Configure(this.NormalizeManifestConfigValue(config))
    }

    ManifestConfigSection(manifest, sectionName)
    {
        if sectionName = ""
            return manifest
        if manifest is Map {
            if manifest.Has(sectionName)
                return manifest[sectionName]
        } else if IsObject(manifest) && HasProp(manifest, sectionName) {
            return manifest.%sectionName%
        }
        throw ValueError("config manifest is missing section: " sectionName, -1)
    }

    NormalizeManifestConfigValue(value)
    {
        if AhkStdlibIsBool(value)
            return value.Value ? true : false
        if AhkStdlibJsonIsNull(value)
            return stdlib.None
        if value is Array {
            normalized := []
            for item in value
                normalized.Push(this.NormalizeManifestConfigValue(item))
            return normalized
        }
        if value is Map {
            normalized := {}
            for key, item in value
                normalized.%key% := this.NormalizeManifestConfigValue(item)
            return normalized
        }
        if IsObject(value) && Type(value) = "Object" {
            normalized := {}
            for key, item in value.OwnProps()
                normalized.%key% := this.NormalizeManifestConfigValue(item)
            return normalized
        }
        return value
    }

    ConfigureMarks(marks)
    {
        if marks is Map {
            for name, description in marks
                this.RegisterMark(name, description)
            return
        }

        if IsObject(marks) && Type(marks) = "Object" {
            for name, description in marks.OwnProps()
                this.RegisterMark(name, description)
            return
        }

        if marks is Array {
            for mark in marks {
                if IsObject(mark) && HasProp(mark, "Name") {
                    description := HasProp(mark, "Description") ? mark.Description : ""
                    this.RegisterMark(mark.Name, description)
                } else {
                    this.RegisterMark(mark)
                }
            }
            return
        }

        throw TypeError("config Marks must be a Map or Array", -1)
    }

    SourceFromLocation(kind, location)
    {
        source := { Kind: kind }
        if HasProp(location, "File")
            source.File := location.File
        if HasProp(location, "Line")
            source.Line := location.Line
        if HasProp(location, "What")
            source.What := location.What
        return source
    }

    OptionsWithSource(kind, location, options := unset)
    {
        if IsSet(options) && HasProp(options, "Source")
            return options

        sourcedOptions := {}
        if IsSet(options) {
            for name, value in options.OwnProps()
                sourcedOptions.%name% := value
        }
        sourcedOptions.Source := this.SourceFromLocation(kind, location)
        return sourcedOptions
    }

    NormalizeFixtureOverrides(overrides)
    {
        if !(overrides is Map)
            throw TypeError("fixture overrides must be a Map", -1)
        normalized := Map()
        for name, callback in overrides {
            if name = ""
                throw ValueError("fixture override name cannot be empty", -1)
            if this.IsContextFixtureName(name)
                throw ValueError("reserved fixture name: " name, -1)
            if !HasMethod(callback, "Call")
                throw TypeError("fixture override callback must be callable", -1)
            normalized[name] := { Name: name, Callback: callback, Override: true }
        }
        return normalized
    }

    NormalizeWarningFilters(filters)
    {
        normalized := []
        if filters is Array {
            for filter in filters
                normalized.Push(this.NormalizeWarningFilter(filter))
            return normalized
        }

        normalized.Push(this.NormalizeWarningFilter(filters))
        return normalized
    }

    NormalizeAhkRunDefaults(defaults)
    {
        if !IsObject(defaults)
            throw TypeError("AhkRunDefaults must be an object", -1)

        normalized := {}
        allowed := Map(
            "Filter", true,
            "FilterExpr", true,
            "NodeFilter", true,
            "MarkFilter", true,
            "MarkExpr", true,
            "List", true,
            "Quiet", true,
            "MaxFail", true,
            "ExitFirst", true,
            "LastFailed", true,
            "LastFailedCache", true,
            "Stepwise", true,
            "StepwiseCache", true,
            "StrictMarkers", true,
            "RunXFail", true,
            "WarningSummary", true,
            "Summary", true,
            "Traceback", true,
            "CaptureReport", true,
            "WarningFilter", true,
            "WarningFilters", true,
            "DisableHookIds", true
        )
        for name, value in defaults.OwnProps() {
            if !allowed.Has(name)
                throw ValueError("unknown AhkRunDefaults option: " name, -1)
            if name = "Traceback"
                value := this.NormalizeTracebackOption(value, "AhkRunDefaults Traceback")
            else if name = "CaptureReport"
                value := this.NormalizeCaptureReportOption(value, "AhkRunDefaults CaptureReport")
            else if name = "WarningFilter" || name = "WarningFilters"
                value := this.NormalizeWarningFilters(value)
            else if name = "DisableHookIds"
                value := this.NormalizeHookIdMap(value, "AhkRunDefaults DisableHookIds")
            normalized.%name% := value
        }
        return normalized
    }

    MergeRunOptions(defaults, options := unset)
    {
        merged := {}
        if IsObject(defaults) {
            for name, value in defaults.OwnProps()
                merged.%name% := value
        }
        if IsSet(options) {
            if !IsObject(options)
                throw TypeError("run options must be an object", -1)
            for name, value in options.OwnProps()
                merged.%name% := value
        }
        return merged
    }

    NormalizeTracebackOption(value, optionName := "Traceback")
    {
        normalized := StrLower(value "")
        if normalized = "auto" || normalized = "short" || normalized = "long" || normalized = "native" || normalized = "line" || normalized = "no" || normalized = "none"
            return normalized
        throw ValueError("invalid " optionName " option: " value, -1)
    }

    NormalizeCaptureReportOption(value, optionName := "CaptureReport")
    {
        normalized := StrLower(value "")
        if normalized = "failures" || normalized = "all" || normalized = "none" || normalized = "no" || normalized = "stdout" || normalized = "stderr"
            return normalized
        throw ValueError("invalid " optionName " option: " value, -1)
    }

    NormalizeWarningFilter(filter)
    {
        if !IsObject(filter)
            throw TypeError("warning filter must be an object", -1)
        if !HasProp(filter, "Action")
            throw ValueError("warning filter action is required", -1)

        action := StrLower(filter.Action "")
        if action != "default" && action != "ignore" && action != "error" && action != "always" && action != "once" && action != "source"
            throw ValueError("unsupported warning filter action: " filter.Action, -1)

        normalized := { Action: action, Message: "", Category: "", Source: "", Line: 0 }
        if HasProp(filter, "Message")
            normalized.Message := filter.Message
        if HasProp(filter, "Category")
            normalized.Category := filter.Category
        if HasProp(filter, "Source")
            normalized.Source := filter.Source
        if HasProp(filter, "File")
            normalized.Source := filter.File
        if HasProp(filter, "Line") {
            if filter.Line < 0
                throw ValueError("warning filter line cannot be negative", -1)
            normalized.Line := filter.Line
        }
        return normalized
    }

    NormalizeHookIdMap(ids, optionName := "DisableHookIds")
    {
        normalized := Map()
        if ids is Map {
            for id, enabled in ids {
                if enabled
                    this.AddHookId(normalized, id, optionName)
            }
            return normalized
        }

        if ids is Array {
            for id in ids
                this.AddHookId(normalized, id, optionName)
            return normalized
        }

        this.AddHookId(normalized, ids, optionName)
        return normalized
    }

    AddHookId(ids, id, optionName)
    {
        id := id ""
        if id = ""
            throw ValueError(optionName " cannot contain an empty hook id", -1)
        ids[id] := true
    }

    Skip(name, reason := "", options := unset)
    {
        if name = ""
            throw ValueError("test name cannot be empty", -1)
        test := { Name: name, Callback: (*) => 0, Skip: true, Reason: reason }
        if IsSet(options) && HasProp(options, "Source")
            test.Source := options.Source
        else
            test.Source := this.SourceFromLocation("skip", Error("source", -1))
        this.Tests.Push(test)
    }

    SkipIf(condition, name, callbackOrReason := "", reason := "")
    {
        if condition {
            skipReason := reason != "" ? reason : callbackOrReason
            return this.Skip(name, skipReason)
        }
        if !HasMethod(callbackOrReason, "Call")
            throw TypeError("skip-if callback must be callable when condition is false", -1)
        return this.Test(name, callbackOrReason)
    }

    XFail(name, callback, reason := "", options := unset)
    {
        if name = ""
            throw ValueError("test name cannot be empty", -1)
        if !HasMethod(callback, "Call")
            throw TypeError("test callback must be callable", -1)
        test := { Name: name, Callback: callback, Skip: false, ExpectedFailure: true, Reason: reason }
        hasSource := false
        if IsSet(options) {
            if HasProp(options, "Strict")
                test.Strict := options.Strict
            if HasProp(options, "Marks")
                this.ApplyMarkDeclarations(test, options.Marks)
            if HasProp(options, "Source") {
                test.Source := options.Source
                hasSource := true
            }
            if HasProp(options, "ParamId")
                test.ParamId := options.ParamId
            if HasProp(options, "Params")
                test.Params := options.Params
            if HasProp(options, "FixtureParams")
                test.FixtureParams := options.FixtureParams
        }
        if !hasSource
            test.Source := this.SourceFromLocation("xfail", Error("source", -1))
        this.Tests.Push(test)
        return callback
    }

    Parametrize(nameTemplate, rows, callback, options := unset)
    {
        if nameTemplate = ""
            throw ValueError("test name template cannot be empty", -1)
        if !(rows is Array)
            throw TypeError("parametrize rows must be an Array", -1)
        if !HasMethod(callback, "Call")
            throw TypeError("test callback must be callable", -1)

        if IsSet(options) && HasProp(options, "Stack") && options.Stack {
            this.ParametrizeStacked(nameTemplate, rows, callback, options)
            return
        }

        source := (IsSet(options) && HasProp(options, "Source")) ? options.Source : this.SourceFromLocation("parametrize", Error("source", -1))
        if rows.Length = 0 {
            this.Skip(nameTemplate, "empty parameter set", { Source: source })
            return
        }

        optionMarks := this.ParamOptionMarks(options?)
        for row in rows {
            args := this.ParamArgs(row)
            paramId := this.ParamId(row, args)
            name := this.FormatParamName(nameTemplate, args, paramId)
            marks := this.MergeMarks(optionMarks, this.ParamMarks(row))
            testOptions := { ParamId: paramId, Params: args, Source: source }
            if IsSet(options) && HasProp(options, "Fixtures")
                testOptions.Fixtures := options.Fixtures
            if IsObject(row) && HasProp(row, "FixtureParams")
                testOptions.FixtureParams := row.FixtureParams
            if marks.Length > 0
                testOptions.Marks := marks
            this.Test(name, ObjBindMethod(AhkTestSuite, "_CallParametrized", callback, args), testOptions)
        }
    }

    ParametrizeStacked(nameTemplate, rowGroups, callback, options := unset)
    {
        source := (IsSet(options) && HasProp(options, "Source")) ? options.Source : this.SourceFromLocation("parametrize", Error("source", -1))
        if rowGroups.Length = 0 {
            this.Skip(nameTemplate, "empty parameter set", { Source: source })
            return
        }

        for group in rowGroups {
            if !(group is Array)
                throw TypeError("stacked parametrize rows must contain Array groups", -1)
            if group.Length = 0 {
                this.Skip(nameTemplate, "empty parameter set", { Source: source })
                return
            }
        }

        combinations := []
        this.BuildParametrizeStack(rowGroups, 1, [], "", this.ParamOptionMarks(options?), Map(), combinations)
        for combo in combinations {
            name := this.FormatParamName(nameTemplate, combo.Args, combo.Id)
            testOptions := { ParamId: combo.Id, Params: combo.Args, Source: source }
            if IsSet(options) && HasProp(options, "Fixtures")
                testOptions.Fixtures := options.Fixtures
            if HasProp(combo, "FixtureParams")
                testOptions.FixtureParams := combo.FixtureParams
            if combo.Marks.Length > 0
                testOptions.Marks := combo.Marks
            this.Test(name, ObjBindMethod(AhkTestSuite, "_CallParametrized", callback, combo.Args), testOptions)
        }
    }

    ParamOptionMarks(options := unset)
    {
        if IsSet(options) && HasProp(options, "Marks")
            return this.CloneMarks(options.Marks)
        return []
    }

    CloneMarks(marks)
    {
        cloned := []
        for mark in marks
            cloned.Push(mark)
        return cloned
    }

    MergeMarks(first, second)
    {
        merged := this.CloneMarks(first)
        for mark in second
            merged.Push(mark)
        return merged
    }

    BuildParametrizeStack(rowGroups, groupIndex, args, id, marks, fixtureParams, combinations)
    {
        if groupIndex > rowGroups.Length {
            combination := { Args: args.Clone(), Id: id, Marks: marks.Clone() }
            if fixtureParams.Count > 0
                combination.FixtureParams := this.CloneFixtureParams(fixtureParams)
            combinations.Push(combination)
            return
        }

        for row in rowGroups[groupIndex] {
            rowArgs := this.ParamArgs(row)
            rowId := this.ParamId(row, rowArgs)
            nextArgs := args.Clone()
            for value in rowArgs
                nextArgs.Push(value)
            nextId := id = "" ? rowId : id "-" rowId
            nextMarks := marks.Clone()
            for mark in this.ParamMarks(row)
                nextMarks.Push(mark)
            nextFixtureParams := this.MergeFixtureParams(fixtureParams, row)
            this.BuildParametrizeStack(rowGroups, groupIndex + 1, nextArgs, nextId, nextMarks, nextFixtureParams, combinations)
        }
    }

    CloneFixtureParams(fixtureParams)
    {
        cloned := Map()
        for name, value in fixtureParams
            cloned[name] := value
        return cloned
    }

    MergeFixtureParams(fixtureParams, row)
    {
        merged := this.CloneFixtureParams(fixtureParams)
        if IsObject(row) && HasProp(row, "FixtureParams") {
            for name, value in row.FixtureParams
                merged[name] := value
        }
        return merged
    }

    ExpandFixtureParamItems(tests)
    {
        items := []
        for test in tests {
            paramSets := this.FixtureParamSetsForTest(test)
            if paramSets.Length = 0 {
                items.Push(test)
                continue
            }

            combinations := []
            baseFixtureParams := HasProp(test, "FixtureParams") ? this.CloneFixtureParams(test.FixtureParams) : Map()
            this.BuildFixtureParamCombinations(paramSets, 1, "", [], baseFixtureParams, Map(), [], combinations)
            for combo in combinations
                items.Push(this.CloneTestWithFixtureParams(test, combo))
        }
        return items
    }

    FixtureParamSetsForTest(test)
    {
        sets := []
        seen := Map()
        resolving := Map()
        for fixtureName in this.TestFixtureNames(test)
            this.CollectFixtureParamSets(fixtureName, sets, seen, resolving)
        return sets
    }

    TestFixtureNames(test)
    {
        names := []
        seen := Map()
        for fixtureName in this.AutouseFixtureNames() {
            if !seen.Has(fixtureName) {
                seen[fixtureName] := true
                names.Push(fixtureName)
            }
        }
        if HasProp(test, "Fixtures") {
            for fixtureName in test.Fixtures {
                if !seen.Has(fixtureName) {
                    seen[fixtureName] := true
                    names.Push(fixtureName)
                }
            }
        }
        return names
    }

    CollectFixtureParamSets(fixtureName, sets, seen, resolving)
    {
        if this.IsContextFixtureName(fixtureName)
            return
        if !this.Fixtures.Has(fixtureName)
            return
        if resolving.Has(fixtureName)
            return

        resolving[fixtureName] := true
        fixture := this.Fixtures[fixtureName]
        if HasProp(fixture, "Fixtures") {
            for dependencyName in fixture.Fixtures
                this.CollectFixtureParamSets(dependencyName, sets, seen, resolving)
        }
        resolving.Delete(fixtureName)

        if HasProp(fixture, "Params") && !seen.Has(fixtureName) {
            seen[fixtureName] := true
            sets.Push({ Name: fixtureName, Rows: fixture.Params })
        }
    }

    BuildFixtureParamCombinations(paramSets, paramIndex, id, params, fixtureParams, fixtureParamIds, marks, combinations)
    {
        if paramIndex > paramSets.Length {
            combinations.Push({ Id: id, Params: params.Clone(), FixtureParams: this.CloneFixtureParams(fixtureParams), FixtureParamIds: this.CloneFixtureParams(fixtureParamIds), Marks: marks.Clone() })
            return
        }

        paramSet := paramSets[paramIndex]
        if paramSet.Rows.Length = 0 {
            combinations.Push({ Id: id, Params: params.Clone(), FixtureParams: this.CloneFixtureParams(fixtureParams), FixtureParamIds: this.CloneFixtureParams(fixtureParamIds), Marks: marks.Clone() })
            return
        }

        for row in paramSet.Rows {
            value := this.FixtureParamValue(row)
            rowId := this.FixtureParamId(row, value)
            nextId := id = "" ? rowId : id "-" rowId
            nextParams := params.Clone()
            nextParams.Push(value)
            nextFixtureParams := this.CloneFixtureParams(fixtureParams)
            nextFixtureParams[paramSet.Name] := value
            nextFixtureParamIds := this.CloneFixtureParams(fixtureParamIds)
            nextFixtureParamIds[paramSet.Name] := rowId
            nextMarks := marks.Clone()
            for mark in this.ParamMarks(row)
                nextMarks.Push(mark)
            this.BuildFixtureParamCombinations(paramSets, paramIndex + 1, nextId, nextParams, nextFixtureParams, nextFixtureParamIds, nextMarks, combinations)
        }
    }

    FixtureParamValue(row)
    {
        if IsObject(row) && HasProp(row, "Value")
            return row.Value
        return row
    }

    FixtureParamId(row, value)
    {
        if IsObject(row) && HasProp(row, "Id")
            return row.Id
        return AhkTest.ValueToString(value)
    }

    CloneTestWithFixtureParams(test, combo)
    {
        cloned := this.CloneTest(test)
        if combo.Id != "" {
            baseId := HasProp(test, "ParamId") ? test.ParamId : ""
            cloned.ParamId := baseId != "" ? baseId "-" combo.Id : combo.Id
        }
        baseParams := HasProp(test, "Params") ? test.Params.Clone() : []
        for value in combo.Params
            baseParams.Push(value)
        if baseParams.Length > 0
            cloned.Params := baseParams
        cloned.FixtureParams := combo.FixtureParams
        if HasProp(combo, "FixtureParamIds") && combo.FixtureParamIds.Count > 0
            cloned.FixtureParamIds := combo.FixtureParamIds
        if combo.Marks.Length > 0
            this.ApplyAdditionalMarkDeclarations(cloned, combo.Marks)
        return cloned
    }

    CloneTest(test)
    {
        cloned := { Name: test.Name, Callback: test.Callback, Skip: test.Skip }
        if HasProp(test, "Fixtures")
            cloned.Fixtures := test.Fixtures
        if HasProp(test, "Marks")
            cloned.Marks := test.Marks
        if HasProp(test, "MarkDetails")
            cloned.MarkDetails := test.MarkDetails
        if HasProp(test, "Source")
            cloned.Source := test.Source
        if HasProp(test, "ParamId")
            cloned.ParamId := test.ParamId
        if HasProp(test, "Params")
            cloned.Params := test.Params
        if HasProp(test, "FixtureParams")
            cloned.FixtureParams := test.FixtureParams
        if HasProp(test, "FixtureParamIds")
            cloned.FixtureParamIds := test.FixtureParamIds
        if HasProp(test, "AhkFixtureOverrides")
            cloned.AhkFixtureOverrides := test.AhkFixtureOverrides
        if HasProp(test, "Reason")
            cloned.Reason := test.Reason
        if HasProp(test, "ExpectedFailure")
            cloned.ExpectedFailure := test.ExpectedFailure
        if HasProp(test, "Strict")
            cloned.Strict := test.Strict
        return cloned
    }

    Collect(testClass)
    {
        if !(testClass is Class)
            throw TypeError("collect expects a class", -1)

        names := []
        for name in testClass.OwnProps() {
            if SubStr(name, 1, 4) = "Test"
                names.Push(name)
        }

        names := AhkTest.SortValues(names)
        for name in names {
            fullName := testClass.Prototype.__Class "." name
            source := { Kind: "class", Class: testClass.Prototype.__Class, Method: name }
            if HasMethod(testClass, name)
                this.Test(fullName, ObjBindMethod(AhkTestSuite, "_CallCollected", testClass, name), { Source: source })
            else
                this.Test(fullName, ObjBindMethod(AhkTestSuite, "_RaiseCollectionError", fullName), { Source: source })
        }
    }

    Clear()
    {
        this.Tests.Length := 0
    }

    On(eventName, callback, options := unset)
    {
        if eventName = ""
            throw ValueError("hook event name cannot be empty", -1)
        if !HasMethod(callback, "Call")
            throw TypeError("hook callback must be callable", -1)
        priority := 0
        id := ""
        if IsSet(options) {
            if !IsObject(options)
                throw TypeError("hook options must be an object", -1)
            if HasProp(options, "Priority")
                priority := options.Priority
            if HasProp(options, "Id") {
                id := options.Id ""
                if id = ""
                    throw ValueError("hook id cannot be empty", -1)
            }
        }
        if !this.Hooks.Has(eventName)
            this.Hooks[eventName] := []
        this.HookOrder += 1
        hook := { Callback: callback, Priority: priority, Order: this.HookOrder }
        if id != ""
            hook.Id := id
        this.Hooks[eventName].Push(hook)
        this.SortHooks(eventName)
        return callback
    }

    SortHooks(eventName)
    {
        hooks := this.Hooks[eventName]
        index := 2
        while index <= hooks.Length {
            current := hooks[index]
            scan := index - 1
            while scan >= 1 && this.CompareHooks(hooks[scan], current) > 0 {
                hooks[scan + 1] := hooks[scan]
                scan -= 1
            }
            hooks[scan + 1] := current
            index += 1
        }
    }

    CompareHooks(left, right)
    {
        if left.Priority < right.Priority
            return -1
        if left.Priority > right.Priority
            return 1
        if left.Order < right.Order
            return -1
        if left.Order > right.Order
            return 1
        return 0
    }

    SetOutputFile(path)
    {
        this.CloseOutputFile()
        this.OutputFile := path
        if path != "" && FileExist(path)
            FileDelete path
    }

    Run(options := unset)
    {
        this.BufferedOutput := this.OutputFile != ""
        filter := ""
        filterExpr := ""
        nodeFilter := ""
        markFilter := ""
        markExpr := ""
        listOnly := false
        quiet := false
        maxFail := 0
        lastFailed := false
        lastFailedCache := ""
        stepwise := false
        stepwiseCache := ""
        strictMarkers := false
        runXFail := false
        warningSummary := false
        traceback := "short"
        captureReport := "failures"
        summary := ""
        hasSummary := false
        disabledHookIds := Map()
        warningFilters := this.WarningFilters
        runOptions := this.MergeRunOptions(this.AhkRunDefaults, options?)
        if HasProp(runOptions, "Filter")
            filter := runOptions.Filter
        if HasProp(runOptions, "FilterExpr")
            filterExpr := runOptions.FilterExpr
        if HasProp(runOptions, "NodeFilter")
            nodeFilter := runOptions.NodeFilter
        if HasProp(runOptions, "MarkFilter")
            markFilter := runOptions.MarkFilter
        if HasProp(runOptions, "MarkExpr")
            markExpr := runOptions.MarkExpr
        if HasProp(runOptions, "List")
            listOnly := runOptions.List
        if HasProp(runOptions, "Quiet")
            quiet := runOptions.Quiet
        if HasProp(runOptions, "MaxFail")
            maxFail := runOptions.MaxFail
        if HasProp(runOptions, "ExitFirst") && runOptions.ExitFirst && maxFail = 0
                maxFail := 1
        if HasProp(runOptions, "LastFailed")
            lastFailed := runOptions.LastFailed
        if HasProp(runOptions, "LastFailedCache")
            lastFailedCache := runOptions.LastFailedCache
        if HasProp(runOptions, "Stepwise")
            stepwise := runOptions.Stepwise
        if HasProp(runOptions, "StepwiseCache")
            stepwiseCache := runOptions.StepwiseCache
        if HasProp(runOptions, "StrictMarkers")
            strictMarkers := runOptions.StrictMarkers
        if HasProp(runOptions, "RunXFail")
            runXFail := runOptions.RunXFail
        if HasProp(runOptions, "WarningSummary")
            warningSummary := runOptions.WarningSummary
        if HasProp(runOptions, "Summary") {
            summary := runOptions.Summary
            hasSummary := true
        }
        if HasProp(runOptions, "Traceback")
            traceback := this.NormalizeTracebackOption(runOptions.Traceback)
        if HasProp(runOptions, "CaptureReport")
            captureReport := this.NormalizeCaptureReportOption(runOptions.CaptureReport)
        if HasProp(runOptions, "WarningFilter")
            warningFilters := this.NormalizeWarningFilters(runOptions.WarningFilter)
        if HasProp(runOptions, "WarningFilters")
            warningFilters := this.NormalizeWarningFilters(runOptions.WarningFilters)
        if HasProp(runOptions, "DisableHookIds")
            disabledHookIds := this.NormalizeHookIdMap(runOptions.DisableHookIds)
        warningFilterState := { Default: Map(), Once: Map(), Source: Map() }

        stats := { Name: this.Name, Total: 0, Passed: 0, Failed: 0, Errors: 0, Skipped: 0, Deselected: 0, ExpectedFailures: 0, UnexpectedPasses: 0, Duration: 0 }
        entries := []
        failedKeys := Map()
        executedRerunKeys := Map()
        fixtureContext := { SuiteValues: Map(), SuiteCleanups: [], Captures: [] }
        suiteStart := A_TickCount
        items := this.ExpandFixtureParamItems(this.Tests)
        collectHookError := this.RunHookErrors("collect_finish", { Suite: this, Items: items }, disabledHookIds)
        if collectHookError is Error {
            collectHookError := AhkTestCollectionError(collectHookError)
            duration := A_TickCount - suiteStart
            stats.Errors += 1
            entries.Push({ Name: this.HookEntryName("collect_finish"), Status: "error", Duration: duration, Error: collectHookError })
            stats.Duration := duration
            return AhkTestResult(stats, entries)
        }
        cacheFailedIds := Map()
        if lastFailedCache != ""
            cacheFailedIds := this.LoadLastFailedCache(lastFailedCache)
        filterToCachedFailures := false
        if lastFailed && lastFailedCache != ""
            filterToCachedFailures := this.HasRunnableCachedFailures(items, cacheFailedIds)
        lastFailedSelectionOverride := lastFailed && lastFailedCache != "" && this.ShouldOverrideLastFailedSelection(items, nodeFilter, filter, filterExpr, markFilter, markExpr, cacheFailedIds)
        if lastFailedSelectionOverride
            filterToCachedFailures := false
        stepwiseNodeId := ""
        if stepwise {
            if stepwiseCache != ""
                stepwiseNodeId := this.LoadStepwiseCache(stepwiseCache)
            else
                stepwiseNodeId := this.StepwiseNodeId
        }
        stepwiseNodeIdIsStale := stepwiseNodeId != "" && !this.HasCollectedNodeId(items, stepwiseNodeId)
        stepwiseNodeIdIsExcluded := stepwiseNodeId != "" && !stepwiseNodeIdIsStale && !this.HasSelectedNodeId(items, stepwiseNodeId, filterToCachedFailures, cacheFailedIds, lastFailed, lastFailedCache, nodeFilter, filter, filterExpr, markFilter, markExpr)
        if stepwiseNodeIdIsStale
            stepwiseNodeId := ""
        else if stepwiseNodeIdIsExcluded
            stepwiseNodeId := ""
        stepwiseStarted := stepwiseNodeId = ""
        stepwiseFailureNodeId := ""

        runStartHookError := this.RunHookErrors("run_start", { Suite: this, Tests: items }, disabledHookIds)
        if runStartHookError is Error {
            duration := A_TickCount - suiteStart
            stats.Errors += 1
            entries.Push({ Name: this.HookEntryName("run_start"), Status: "error", Duration: duration, Error: runStartHookError })
            stats.Duration := duration
            return AhkTestResult(stats, entries)
        }

        for test in items {
            nodeId := this.NodeId(test)
            rerunKey := this.RerunKey(test)
            if !this.IsSelectedBeforeStepwise(test, nodeId, filterToCachedFailures, cacheFailedIds, lastFailed, lastFailedCache, nodeFilter, filter, filterExpr, markFilter, markExpr) {
                stats.Deselected += 1
                continue
            }
            if stepwise && !stepwiseStarted {
                if rerunKey != stepwiseNodeId {
                    stats.Deselected += 1
                    continue
                }
                stepwiseStarted := true
            }

            executedRerunKeys[rerunKey] := true

            if listOnly {
                this.WriteLine(test.Name)
                continue
            }

            stats.Total += 1
            started := A_TickCount
            testWarnings := []

            if strictMarkers {
                markerError := this.StrictMarkerError(test)
                if markerError is Error {
                    duration := A_TickCount - started
                    stats.Errors += 1
                    entry := { Name: test.Name, NodeId: nodeId, Status: "error", Duration: duration, Error: markerError, Marks: this.TestMarks(test) }
                    this.AttachSource(entry, test)
                    this.AttachCaptured(entry, fixtureContext)
                    entries.Push(entry)
                    failedKeys[rerunKey] := true
                    this.RunFinishHooks(entry, stats, disabledHookIds)
                    if !quiet {
                        this.WriteLine("ERROR " test.Name " (" duration "ms)")
                        this.WriteError(markerError, traceback)
                    }
                    if stepwise {
                        stepwiseFailureNodeId := rerunKey
                        break
                    }
                    if this.ShouldStopAfterFailure(stats, maxFail)
                        break
                    continue
                }
            }

            if test.Skip {
                stats.Skipped += 1
                entry := {
                    Name: test.Name,
                    NodeId: nodeId,
                    Status: "skip",
                    Duration: 0,
                    Reason: HasProp(test, "Reason") ? test.Reason : "",
                    Marks: this.TestMarks(test)
                }
                this.AttachSource(entry, test)
                this.AttachCaptured(entry, fixtureContext)
                entries.Push(entry)
                this.RunFinishHooks(entry, stats, disabledHookIds)
                if !quiet
                    this.WriteLine("SKIP " test.Name this.FormatReason(entry.Reason))
                continue
            }

            try {
                this.RunHooks("test_start", test, disabledHookIds)
                cleanups := []
                fixtureContext.Captures := []
                AhkTest.WarningStack.Push(testWarnings)
                try {
                    try {
                        this.CallTest(test, cleanups, fixtureContext, nodeId)
                    } finally {
                        this.RunCleanups(cleanups)
                    }
                } finally {
                    AhkTest.WarningStack.Pop()
                }
                duration := A_TickCount - started
                if !runXFail && HasProp(test, "ExpectedFailure") && test.ExpectedFailure {
                    strict := HasProp(test, "Strict") && test.Strict
                    stats.UnexpectedPasses += 1
                    if strict
                        stats.Failed += 1
                    entry := { Name: test.Name, NodeId: nodeId, Status: "xpass", Duration: duration, Reason: HasProp(test, "Reason") ? test.Reason : "", Strict: strict, Marks: this.TestMarks(test) }
                    this.AttachSource(entry, test)
                    this.AttachCaptured(entry, fixtureContext)
                    this.AttachWarnings(entry, testWarnings, warningFilters, warningFilterState)
                    entries.Push(entry)
                    if strict
                        failedKeys[rerunKey] := true
                    this.RunFinishHooks(entry, stats, disabledHookIds)
                    if !quiet
                        this.WriteLine("XPASS " test.Name this.FormatReason(HasProp(test, "Reason") ? test.Reason : ""))
                    if strict && stepwise {
                        stepwiseFailureNodeId := rerunKey
                        break
                    }
                    if this.ShouldStopAfterFailure(stats, maxFail)
                        break
                    continue
                }
                entry := { Name: test.Name, NodeId: nodeId, Status: "pass", Duration: duration, Marks: this.TestMarks(test) }
                this.AttachSource(entry, test)
                this.AttachCaptured(entry, fixtureContext)
                warningResult := this.AttachWarnings(entry, testWarnings, warningFilters, warningFilterState)
                if HasProp(warningResult, "Error") {
                    entry.Status := "error"
                    entry.Error := warningResult.Error
                    stats.Errors += 1
                    failedKeys[rerunKey] := true
                } else {
                    stats.Passed += 1
                }
                entries.Push(entry)
                this.RunFinishHooks(entry, stats, disabledHookIds)
                if !quiet && entry.Status = "pass"
                    this.WriteLine("PASS " test.Name " (" duration "ms)")
                else if !quiet && entry.Status = "error" {
                    this.WriteLine("ERROR " test.Name " (" duration "ms)")
                    this.WriteError(entry.Error, traceback)
                    this.WriteCaptured(entry, captureReport)
                }
            } catch AhkTestSkip as err {
                duration := A_TickCount - started
                stats.Skipped += 1
                reason := err.Reason
                entry := { Name: test.Name, NodeId: nodeId, Status: "skip", Duration: duration, Reason: reason, Marks: this.TestMarks(test) }
                this.AttachSource(entry, test)
                this.AttachCaptured(entry, fixtureContext)
                this.AttachWarnings(entry, testWarnings, warningFilters, warningFilterState)
                entries.Push(entry)
                this.RunFinishHooks(entry, stats, disabledHookIds)
                if !quiet
                    this.WriteLine("SKIP " test.Name this.FormatReason(reason))
            } catch AhkTestFailure as err {
                duration := A_TickCount - started
                if !runXFail && HasProp(test, "ExpectedFailure") && test.ExpectedFailure {
                    stats.ExpectedFailures += 1
                    entry := { Name: test.Name, NodeId: nodeId, Status: "xfail", Duration: duration, Reason: HasProp(test, "Reason") ? test.Reason : "", Error: err, Marks: this.TestMarks(test) }
                    this.AttachSource(entry, test)
                    this.AttachCaptured(entry, fixtureContext)
                    this.AttachWarnings(entry, testWarnings, warningFilters, warningFilterState)
                    entries.Push(entry)
                    this.RunFinishHooks(entry, stats, disabledHookIds)
                    if !quiet
                        this.WriteLine("XFAIL " test.Name this.FormatReason(HasProp(test, "Reason") ? test.Reason : ""))
                    continue
                }
                stats.Failed += 1
                entry := { Name: test.Name, NodeId: nodeId, Status: "fail", Duration: duration, Error: err, Marks: this.TestMarks(test) }
                this.AttachSource(entry, test)
                this.AttachCaptured(entry, fixtureContext)
                this.AttachWarnings(entry, testWarnings, warningFilters, warningFilterState)
                entries.Push(entry)
                failedKeys[rerunKey] := true
                this.RunFinishHooks(entry, stats, disabledHookIds)
                if !quiet {
                    this.WriteLine("FAIL " test.Name " (" duration "ms)")
                    this.WriteError(err, traceback)
                    this.WriteCaptured(entry, captureReport)
                }
                if stepwise {
                    stepwiseFailureNodeId := rerunKey
                    break
                }
                if this.ShouldStopAfterFailure(stats, maxFail)
                    break
            } catch Error as err {
                duration := A_TickCount - started
                if !runXFail && HasProp(test, "ExpectedFailure") && test.ExpectedFailure {
                    stats.ExpectedFailures += 1
                    entry := { Name: test.Name, NodeId: nodeId, Status: "xfail", Duration: duration, Reason: HasProp(test, "Reason") ? test.Reason : "", Error: err, Marks: this.TestMarks(test) }
                    this.AttachSource(entry, test)
                    this.AttachCaptured(entry, fixtureContext)
                    this.AttachWarnings(entry, testWarnings, warningFilters, warningFilterState)
                    entries.Push(entry)
                    this.RunFinishHooks(entry, stats, disabledHookIds)
                    if !quiet
                        this.WriteLine("XFAIL " test.Name this.FormatReason(HasProp(test, "Reason") ? test.Reason : ""))
                    continue
                }
                stats.Errors += 1
                entry := { Name: test.Name, NodeId: nodeId, Status: "error", Duration: duration, Error: err, Marks: this.TestMarks(test) }
                this.AttachSource(entry, test)
                this.AttachCaptured(entry, fixtureContext)
                this.AttachWarnings(entry, testWarnings, warningFilters, warningFilterState)
                entries.Push(entry)
                failedKeys[rerunKey] := true
                this.RunFinishHooks(entry, stats, disabledHookIds)
                if !quiet {
                    this.WriteLine("ERROR " test.Name " (" duration "ms)")
                    this.WriteError(err, traceback)
                    this.WriteCaptured(entry, captureReport)
                }
                if stepwise {
                    stepwiseFailureNodeId := rerunKey
                    break
                }
                if this.ShouldStopAfterFailure(stats, maxFail)
                    break
            }
        }

        this.RunSuiteCleanups(stats, entries, fixtureContext.SuiteCleanups, quiet, traceback)
        this.LastFailedNames := failedKeys
        if lastFailedCache != ""
            if lastFailedSelectionOverride
                this.SaveLastFailedCacheNodeIds(lastFailedCache, this.MergeLastFailedNodeIds(cacheFailedIds, executedRerunKeys, failedKeys))
            else
                this.SaveLastFailedCache(lastFailedCache, failedKeys)
        if stepwise {
            if stepwiseFailureNodeId != ""
                this.StepwiseNodeId := stepwiseFailureNodeId
            else if stepwiseNodeIdIsStale || stepwiseNodeIdIsExcluded
                this.StepwiseNodeId := stepwiseCache != "" ? this.LoadStepwiseCache(stepwiseCache) : this.StepwiseNodeId
            else
                this.StepwiseNodeId := ""
            if stepwiseCache != ""
                this.SaveStepwiseCache(stepwiseCache, stepwiseFailureNodeId != "" ? stepwiseFailureNodeId : ((stepwiseNodeIdIsStale || stepwiseNodeIdIsExcluded) ? this.StepwiseNodeId : ""))
        }
        stats.Duration := A_TickCount - suiteStart
        result := AhkTestResult(stats, entries)
        runFinishHookError := this.RunHookErrors("run_finish", result, disabledHookIds)
        if runFinishHookError is Error {
            duration := A_TickCount - suiteStart
            stats.Errors += 1
            entry := { Name: this.HookEntryName("run_finish"), Status: "error", Duration: duration, Error: runFinishHookError }
            entries.Push(entry)
            stats.Duration := duration
            result.Errors := stats.Errors
            result.Duration := stats.Duration
            result.Entries := entries
            if !listOnly && !quiet {
                this.WriteLine("ERROR " entry.Name " (" duration "ms)")
                this.WriteError(runFinishHookError, traceback)
            }
        }
        reportFinishHookError := this.RunHookErrors("report_finish", { Suite: this, Result: result }, disabledHookIds)
        if reportFinishHookError is Error {
            duration := A_TickCount - suiteStart
            stats.Errors += 1
            entry := { Name: this.HookEntryName("report_finish"), Status: "error", Duration: duration, Error: reportFinishHookError }
            entries.Push(entry)
            stats.Duration := duration
            result.Errors := stats.Errors
            result.Duration := stats.Duration
            result.Entries := entries
            if !listOnly && !quiet {
                this.WriteLine("ERROR " entry.Name " (" duration "ms)")
                this.WriteError(reportFinishHookError, traceback)
            }
        }
        if !listOnly && !quiet {
            this.WriteLine("")
            this.WriteLine("Ran " stats.Total " tests in " stats.Duration "ms")
            this.WriteLine("Passed: " stats.Passed ", Failed: " stats.Failed ", Errors: " stats.Errors ", Skipped: " stats.Skipped)
            if hasSummary {
                this.WriteOutcomeReasonSummary(result, summary)
            } else {
                this.WriteOutcomeReasonSummary(result)
            }
            if warningSummary || (hasSummary && InStr(summary "", "w"))
                this.WriteWarningSummary(result)
        }
        this.CloseOutputFile()
        return result
    }

    HasRunnableCachedFailures(items, cacheFailedIds)
    {
        if cacheFailedIds.Count = 0
            return false
        for test in items {
            if cacheFailedIds.Has(this.RerunKey(test))
                return true
        }
        return false
    }

    HasCollectedNodeId(items, nodeId)
    {
        if nodeId = ""
            return false
        for test in items {
            if this.RerunKey(test) = nodeId
                return true
        }
        return false
    }

    ShouldOverrideLastFailedSelection(items, nodeFilter, filter, filterExpr, markFilter, markExpr, cacheFailedIds)
    {
        selectedRerunKeys := this.SelectedRerunKeysForExplicitRunSelection(items, nodeFilter, filter, filterExpr, markFilter, markExpr)
        if selectedRerunKeys.Length = 0
            return false
        for rerunKey in selectedRerunKeys {
            if cacheFailedIds.Has(rerunKey)
                return false
        }
        return true
    }

    SelectedRerunKeysForExplicitRunSelection(items, nodeFilter, filter, filterExpr, markFilter, markExpr)
    {
        selectedRerunKeys := []
        seen := Map()
        for test in items {
            nodeId := this.NodeId(test)
            rerunKey := this.RerunKey(test)
            if !this.ShouldSelectNodeId(nodeId, nodeFilter)
                continue
            if !this.ShouldSelectTest(test, filter, filterExpr, markFilter, markExpr)
                continue
            if seen.Has(rerunKey)
                continue
            seen[rerunKey] := true
            selectedRerunKeys.Push(rerunKey)
        }
        return selectedRerunKeys
    }

    HasSelectedNodeId(items, nodeId, filterToCachedFailures, cacheFailedIds, lastFailed, lastFailedCache, nodeFilter, filter, filterExpr, markFilter, markExpr)
    {
        if nodeId = ""
            return false
        for test in items {
            currentRerunKey := this.RerunKey(test)
            if currentRerunKey != nodeId
                continue
            currentNodeId := this.NodeId(test)
            if this.IsSelectedBeforeStepwise(test, currentNodeId, filterToCachedFailures, cacheFailedIds, lastFailed, lastFailedCache, nodeFilter, filter, filterExpr, markFilter, markExpr)
                return true
        }
        return false
    }

    IsSelectedBeforeStepwise(test, nodeId, filterToCachedFailures, cacheFailedIds, lastFailed, lastFailedCache, nodeFilter, filter, filterExpr, markFilter, markExpr)
    {
        if filterToCachedFailures && !cacheFailedIds.Has(this.RerunKey(test))
            return false
        if lastFailed && lastFailedCache = "" && !this.LastFailedNames.Has(this.RerunKey(test))
            return false
        if !this.ShouldSelectNodeId(nodeId, nodeFilter)
            return false
        if !this.ShouldSelectTest(test, filter, filterExpr, markFilter, markExpr)
            return false
        return true
    }

    ParamArgs(row)
    {
        if row is Array
            return row
        if IsObject(row) && HasProp(row, "Args")
            return row.Args
        return [row]
    }

    LoadLastFailedCache(path)
    {
        failedIds := Map()
        if !FileExist(path)
            return failedIds
        text := FileRead(path, "UTF-8")
        Loop Parse, text, "`n", "`r" {
            nodeId := A_LoopField
            if nodeId != ""
                failedIds[nodeId] := true
        }
        return failedIds
    }

    LoadStepwiseCache(path)
    {
        if !FileExist(path)
            return ""
        text := FileRead(path, "UTF-8")
        Loop Parse, text, "`n", "`r" {
            nodeId := A_LoopField
            if nodeId != ""
                return nodeId
        }
        return ""
    }

    SaveStepwiseCache(path, nodeId)
    {
        parent := this.ParentDir(path)
        if parent != "" && !DirExist(parent)
            DirCreate parent
        if FileExist(path)
            FileDelete path
        if nodeId != ""
            FileAppend nodeId "`n", path, "UTF-8"
        else
            FileAppend "", path, "UTF-8"
    }

    SaveLastFailedCache(path, failedNames, tests := unset)
    {
        parent := this.ParentDir(path)
        if parent != "" && !DirExist(parent)
            DirCreate parent
        lines := []
        for rerunKey, _ in failedNames
            lines.Push(rerunKey)
        text := AhkTest.Join(AhkTest.SortValues(lines), "`n")
        if FileExist(path)
            FileDelete path
        if text != ""
            FileAppend text "`n", path, "UTF-8"
        else
            FileAppend "", path, "UTF-8"
    }

    SaveLastFailedCacheNodeIds(path, nodeIds)
    {
        parent := this.ParentDir(path)
        if parent != "" && !DirExist(parent)
            DirCreate parent
        lines := []
        for nodeId, _ in nodeIds
            lines.Push(nodeId)
        text := AhkTest.Join(AhkTest.SortValues(lines), "`n")
        if FileExist(path)
            FileDelete path
        if text != ""
            FileAppend text "`n", path, "UTF-8"
        else
            FileAppend "", path, "UTF-8"
    }

    MergeLastFailedNodeIds(existingNodeIds, executedNodeIds, failedNodeIds)
    {
        merged := Map()
        for nodeId, _ in existingNodeIds
            merged[nodeId] := true
        for nodeId, _ in executedNodeIds {
            if merged.Has(nodeId)
                merged.Delete(nodeId)
        }
        for nodeId, _ in failedNodeIds
            merged[nodeId] := true
        return merged
    }

    ParentDir(path)
    {
        SplitPath path, , &dir
        return dir
    }

    NodeId(test)
    {
        nodeId := (this.Name != "" ? this.Name : "default") "::" test.Name
        if HasProp(test, "ParamId") && test.ParamId != ""
            nodeId .= "[" test.ParamId "]"
        return nodeId
    }

    RerunKey(test)
    {
        nodeId := this.NodeId(test)
        if HasProp(test, "Source") && IsObject(test.Source) && HasProp(test.Source, "File") && test.Source.File != ""
            return test.Source.File "::" nodeId
        return nodeId
    }

    ParamId(row, args := unset)
    {
        if IsObject(row) && HasProp(row, "Id")
            return row.Id
        if IsSet(args)
            return this.GeneratedParamId(args)
        return ""
    }

    GeneratedParamId(args)
    {
        values := []
        for value in args
            values.Push(AhkTest.ValueToString(value))
        return AhkTest.Join(values, "-")
    }

    ParamMarks(row)
    {
        if IsObject(row) && HasProp(row, "Marks")
            return row.Marks
        return []
    }

    FormatParamName(nameTemplate, args, id := "")
    {
        name := nameTemplate
        if id != ""
            name := StrReplace(name, "{id}", id)
        for index, value in args
            name := StrReplace(name, "{" index "}", AhkTest.ValueToString(value))
        return name
    }

    FormatReason(reason)
    {
        return reason != "" ? " - " reason : ""
    }

    TestMarks(test)
    {
        if HasProp(test, "Marks")
            return test.Marks
        return []
    }

    AttachSource(entry, test)
    {
        if HasProp(test, "Source")
            entry.Source := test.Source
        if HasProp(test, "ParamId")
            entry.ParamId := test.ParamId
        if HasProp(test, "Params")
            entry.Params := test.Params
        if HasProp(test, "MarkDetails")
            entry.MarkDetails := test.MarkDetails
    }

    ApplyMarkDeclarations(test, marks)
    {
        visibleMarks := []
        markDetails := []
        for mark in marks {
            if mark is AhkTestSkipMark {
                test.Skip := true
                test.Reason := mark.Reason
            } else if mark is AhkTestXFailMark {
                test.ExpectedFailure := true
                test.Reason := mark.Reason
                if HasProp(mark, "Strict")
                    test.Strict := mark.Strict
            } else if mark is AhkTestMark {
                visibleMarks.Push(mark.Name)
                markDetails.Push(mark)
            } else {
                visibleMarks.Push(mark)
            }
        }
        test.Marks := visibleMarks
        if markDetails.Length > 0
            test.MarkDetails := markDetails
    }

    ApplyAdditionalMarkDeclarations(test, marks)
    {
        visibleMarks := this.CloneMarks(this.TestMarks(test))
        markDetails := []
        if HasProp(test, "MarkDetails") {
            for markDetail in test.MarkDetails
                markDetails.Push(markDetail)
        }

        for mark in marks {
            if mark is AhkTestSkipMark {
                test.Skip := true
                test.Reason := mark.Reason
            } else if mark is AhkTestXFailMark {
                test.ExpectedFailure := true
                test.Reason := mark.Reason
                if HasProp(mark, "Strict")
                    test.Strict := mark.Strict
            } else if mark is AhkTestMark {
                visibleMarks.Push(mark.Name)
                markDetails.Push(mark)
            } else {
                visibleMarks.Push(mark)
            }
        }

        test.Marks := visibleMarks
        if markDetails.Length > 0
            test.MarkDetails := markDetails
    }

    TestHasMark(test, mark)
    {
        for value in this.TestMarks(test) {
            if value = mark
                return true
        }
        return false
    }

    StrictMarkerError(test)
    {
        for mark in this.TestMarks(test) {
            if !this.RegisteredMarks.Has(mark)
                return ValueError("unknown mark: " mark, -1)
        }
        return ""
    }

    AttachCaptured(entry, fixtureContext)
    {
        if !HasProp(fixtureContext, "Captures") || fixtureContext.Captures.Length = 0
            return

        outText := ""
        errText := ""
        for capture in fixtureContext.Captures {
            snapshot := capture.Snapshot()
            outText .= snapshot.Out
            errText .= snapshot.Err
        }
        entry.Captured := { Out: outText, Err: errText }
    }

    AttachWarnings(entry, warnings, warningFilters := unset, warningFilterState := unset)
    {
        result := IsSet(warningFilters) ? this.ApplyWarningFilters(warnings, warningFilters, warningFilterState) : { Warnings: warnings.Clone() }
        if result.Warnings.Length > 0
            entry.Warnings := result.Warnings
        return result
    }

    ApplyWarningFilters(warnings, warningFilters, warningFilterState)
    {
        result := { Warnings: [] }
        for warning in warnings {
            action := this.WarningFilterAction(warning, warningFilters)
            if action = "ignore"
                continue
            if action = "error" {
                if !HasProp(result, "Error")
                    result.Error := AhkTestWarningFailure(warning)
                continue
            }
            if action != "always" && this.WarningAlreadySeen(warning, action, warningFilterState)
                continue
            result.Warnings.Push(warning)
        }
        return result
    }

    WarningAlreadySeen(warning, action, warningFilterState)
    {
        if !IsSet(warningFilterState)
            return false
        if action = "once" {
            key := this.WarningKey(warning, "once")
            if warningFilterState.Once.Has(key)
                return true
            warningFilterState.Once[key] := true
            return false
        }
        if action = "source" {
            key := this.WarningKey(warning, "source")
            if warningFilterState.Source.Has(key)
                return true
            warningFilterState.Source[key] := true
            return false
        }
        key := this.WarningKey(warning, "default")
        if warningFilterState.Default.Has(key)
            return true
        warningFilterState.Default[key] := true
        return false
    }

    WarningKey(warning, mode)
    {
        key := warning.Message Chr(31) warning.Category
        if mode = "once"
            return key
        source := HasProp(warning, "File") ? warning.File : ""
        key .= Chr(31) source
        if mode = "source"
            return key
        line := HasProp(warning, "Line") ? warning.Line : 0
        return key Chr(31) line
    }

    WarningFilterAction(warning, warningFilters)
    {
        action := "default"
        for filter in warningFilters {
            if this.WarningFilterMatches(warning, filter)
                action := filter.Action
        }
        return action
    }

    WarningFilterMatches(warning, filter)
    {
        if HasProp(filter, "Category") && filter.Category != "" && warning.Category != filter.Category
            return false
        if HasProp(filter, "Message") && filter.Message != "" && !RegExMatch(warning.Message "", filter.Message "")
            return false
        if HasProp(filter, "Source") && filter.Source != "" && (!HasProp(warning, "File") || !RegExMatch(warning.File "", filter.Source ""))
            return false
        if HasProp(filter, "Line") && filter.Line != 0 && (!HasProp(warning, "Line") || warning.Line != filter.Line)
            return false
        return true
    }

    ShouldSelectNodeId(nodeId, nodeFilter)
    {
        if !IsObject(nodeFilter)
            return nodeFilter = "" || nodeId = nodeFilter
        if nodeFilter is Array {
            for selectedNodeId in nodeFilter {
                if nodeId = selectedNodeId
                    return true
            }
            return false
        }
        throw TypeError("NodeFilter must be a string or Array", -1)
    }

    ShouldSelectTest(test, filter, filterExpr, markFilter, markExpr)
    {
        if filter != "" && !InStr(test.Name, filter)
            return false
        if filterExpr != "" && !AhkTestFilterExpression(filterExpr).Matches(test.Name)
            return false
        if markFilter != "" && !this.TestHasMark(test, markFilter)
            return false
        if markExpr != "" && !AhkTestFilterExpression(markExpr).Matches(ObjBindMethod(this, "TestHasMark", test))
            return false
        return true
    }

    HookDisabled(hook, disabledHookIds)
    {
        return HasProp(hook, "Id") && disabledHookIds.Has(hook.Id)
    }

    RunHooks(eventName, payload, disabledHookIds := unset)
    {
        if !this.Hooks.Has(eventName)
            return
        if !IsSet(disabledHookIds)
            disabledHookIds := Map()
        for hook in this.Hooks[eventName] {
            if this.HookDisabled(hook, disabledHookIds)
                continue
            hook.Callback.Call(payload)
        }
    }

    RunHookErrors(eventName, payload, disabledHookIds := unset)
    {
        if !this.Hooks.Has(eventName)
            return ""
        if !IsSet(disabledHookIds)
            disabledHookIds := Map()

        hookErrors := []
        for hook in this.Hooks[eventName] {
            if this.HookDisabled(hook, disabledHookIds)
                continue
            try {
                hook.Callback.Call(payload)
            } catch Error as err {
                hookErrors.Push(err)
            }
        }
        if hookErrors.Length = 0
            return ""
        return hookErrors.Length = 1 ? hookErrors[1] : AhkTestHookFailure(hookErrors)
    }

    HookEntryName(eventName)
    {
        return this.Name != "" ? this.Name " " eventName " hook" : eventName " hook"
    }

    RunFinishHooks(entry, stats, disabledHookIds := unset)
    {
        if !this.Hooks.Has("test_finish")
            return
        if !IsSet(disabledHookIds)
            disabledHookIds := Map()

        hookErrors := []
        for hook in this.Hooks["test_finish"] {
            if this.HookDisabled(hook, disabledHookIds)
                continue
            try {
                hook.Callback.Call(entry)
            } catch Error as err {
                hookErrors.Push(err)
            }
        }
        if hookErrors.Length = 0
            return

        errors := []
        if HasProp(entry, "Error")
            errors.Push(entry.Error)
        for err in hookErrors
            errors.Push(err)

        errorValue := errors.Length = 1 ? errors[1] : AhkTestHookFailure(errors)
        this.ConvertEntryToError(entry, stats, errorValue)
    }

    ConvertEntryToError(entry, stats, err)
    {
        oldStatus := entry.Status
        if oldStatus = "pass" && stats.Passed > 0
            stats.Passed -= 1
        else if oldStatus = "skip" && stats.Skipped > 0
            stats.Skipped -= 1
        else if oldStatus = "fail" && stats.Failed > 0
            stats.Failed -= 1
        else if oldStatus = "xfail" && stats.ExpectedFailures > 0
            stats.ExpectedFailures -= 1
        else if oldStatus = "xpass" {
            if stats.UnexpectedPasses > 0
                stats.UnexpectedPasses -= 1
            if HasProp(entry, "Strict") && entry.Strict && stats.Failed > 0
                stats.Failed -= 1
        }

        if oldStatus != "error"
            stats.Errors += 1
        entry.Status := "error"
        entry.Error := err
    }

    NormalizeFixtureScope(scope)
    {
        normalized := StrLower(scope "")
        if normalized != "function" && normalized != "suite" && normalized != "session"
            throw ValueError("unsupported fixture scope: " scope, -1)
        return normalized
    }

    FixtureScope(fixture)
    {
        return HasProp(fixture, "Scope") ? fixture.Scope : "function"
    }

    CallTest(test, cleanups, fixtureContext, nodeId := "")
    {
        args := []
        resolving := []
        fixtureContext.TestName := test.Name
        fixtureContext.NodeId := nodeId
        fixtureContext.FunctionValues := Map()
        fixtureContext.ParamId := HasProp(test, "ParamId") ? test.ParamId : ""
        fixtureContext.Params := HasProp(test, "Params") ? test.Params : []
        fixtureContext.Marks := this.TestMarks(test)
        fixtureContext.FixtureNames := this.BuildFixtureNameList(test, fixtureContext)
        if HasProp(test, "Source")
            fixtureContext.Source := test.Source
        else if HasProp(fixtureContext, "Source")
            fixtureContext.DeleteProp("Source")
        if HasProp(test, "MarkDetails")
            fixtureContext.MarkDetails := test.MarkDetails
        else if HasProp(fixtureContext, "MarkDetails")
            fixtureContext.DeleteProp("MarkDetails")
        if HasProp(test, "FixtureParams")
            fixtureContext.FixtureParams := test.FixtureParams
        else if HasProp(fixtureContext, "FixtureParams")
            fixtureContext.DeleteProp("FixtureParams")
        if HasProp(test, "FixtureParamIds")
            fixtureContext.FixtureParamIds := test.FixtureParamIds
        else if HasProp(fixtureContext, "FixtureParamIds")
            fixtureContext.DeleteProp("FixtureParamIds")
        if HasProp(test, "AhkFixtureOverrides")
            fixtureContext.AhkFixtureOverrides := test.AhkFixtureOverrides
        else if HasProp(fixtureContext, "AhkFixtureOverrides")
            fixtureContext.DeleteProp("AhkFixtureOverrides")
        for fixtureName in this.AutouseFixtureNames()
            this.ResolveFixture(fixtureName, cleanups, resolving, fixtureContext)

        if HasProp(test, "Fixtures") {
            for fixtureName in test.Fixtures
                args.Push(this.ResolveFixture(fixtureName, cleanups, resolving, fixtureContext))
        }
        return test.Callback.Call(args*)
    }

    BuildFixtureNameList(test, fixtureContext)
    {
        names := []
        seen := Map()
        for fixtureName in this.AutouseFixtureNames()
            this.AppendFixtureNameGraph(fixtureName, fixtureContext, names, seen)
        if HasProp(test, "Fixtures") {
            for fixtureName in test.Fixtures
                this.AppendFixtureNameGraph(fixtureName, fixtureContext, names, seen)
        }
        return names
    }

    AppendDynamicFixtureNames(name, fixtureContext, names)
    {
        seen := Map()
        for existingName in names
            seen[existingName] := true
        pending := []
        this.CollectDynamicFixtureNames(name, fixtureContext, pending, seen)
        for pendingName in pending
            names.Push(pendingName)
    }

    AppendFixtureNameGraph(name, fixtureContext, names, seen)
    {
        if seen.Has(name)
            return
        seen[name] := true
        names.Push(name)
        if this.IsContextFixtureName(name)
            return
        fixture := this.ResolveFixtureDefinition(name, fixtureContext)
        if !IsObject(fixture) || !HasProp(fixture, "Fixtures")
            return
        for fixtureName in fixture.Fixtures
            this.AppendFixtureNameGraph(fixtureName, fixtureContext, names, seen)
    }

    CollectDynamicFixtureNames(name, fixtureContext, names, seen)
    {
        if seen.Has(name)
            return
        if this.IsContextFixtureName(name) {
            seen[name] := true
            names.Push(name)
            return
        }
        fixture := this.ResolveFixtureDefinition(name, fixtureContext)
        if !IsObject(fixture)
            throw ValueError("unknown fixture: " name, -1)
        if HasProp(fixture, "Fixtures") {
            for fixtureName in fixture.Fixtures
                this.CollectDynamicFixtureNames(fixtureName, fixtureContext, names, seen)
        }
        seen[name] := true
        names.Push(name)
    }

    AutouseFixtureNames()
    {
        names := []
        for name, fixture in this.Fixtures {
            if HasProp(fixture, "Autouse") && fixture.Autouse
                names.Push(name)
        }
        return AhkTest.SortValues(names)
    }

    ResolveFixtureDefinition(name, fixtureContext)
    {
        if HasProp(fixtureContext, "AhkFixtureOverrides") && fixtureContext.AhkFixtureOverrides.Has(name)
            return fixtureContext.AhkFixtureOverrides[name]
        return this.Fixtures.Has(name) ? this.Fixtures[name] : ""
    }

    ResolveFixture(name, cleanups, resolving, fixtureContext, activeFixture := unset)
    {
        if this.IsContextFixtureName(name)
            return this.CreateFixtureContext(cleanups, resolving, fixtureContext, activeFixture?)
        if HasProp(fixtureContext, "AhkFixtureOverrides") && fixtureContext.AhkFixtureOverrides.Has(name) {
            fixture := fixtureContext.AhkFixtureOverrides[name]
        } else if this.Fixtures.Has(name) {
            fixture := this.Fixtures[name]
        } else {
            throw ValueError("unknown fixture: " name, -1)
        }
        scope := this.FixtureScope(fixture)
        scopedKey := this.ScopedFixtureKey(name, fixtureContext)
        if scope = "function" && HasProp(fixtureContext, "FunctionValues") && fixtureContext.FunctionValues.Has(name)
            return fixtureContext.FunctionValues[name]
        if scope = "suite" && fixtureContext.SuiteValues.Has(scopedKey)
            return this.UnwrapFixtureCacheEntry(fixtureContext.SuiteValues[scopedKey])
        sessionKey := ""
        if scope = "session" {
            sessionKey := this.SessionFixtureKey(scopedKey)
            if AhkTestSuite.SessionValues.Has(sessionKey)
                return this.UnwrapFixtureCacheEntry(AhkTestSuite.SessionValues[sessionKey])
        }

        cycleAt := this.IndexOf(resolving, name)
        if cycleAt > 0 {
            cycle := []
            loop resolving.Length - cycleAt + 1
                cycle.Push(resolving[cycleAt + A_Index - 1])
            cycle.Push(name)
            throw ValueError("fixture dependency cycle: " AhkTest.Join(cycle, " -> "), -1)
        }

        resolving.Push(name)
        args := []
        scopedCleanups := cleanups
        if scope = "suite"
            scopedCleanups := fixtureContext.SuiteCleanups
        else if scope = "session"
            scopedCleanups := AhkTestSuite.SessionCleanups
        contextInfo := { Name: name, Scope: scope, CleanupTarget: scopedCleanups }
        try {
            if HasProp(fixture, "Fixtures") {
                for fixtureName in fixture.Fixtures
                    args.Push(this.ResolveFixture(fixtureName, cleanups, resolving, fixtureContext, contextInfo))
            }
            result := fixture.Callback.Call(args*)
        } catch Error as err {
            if scope = "suite"
                fixtureContext.SuiteValues[scopedKey] := AhkTestFixtureSetupError(err)
            else if scope = "session"
                AhkTestSuite.SessionValues[sessionKey] := AhkTestFixtureSetupError(err)
            throw err
        } finally {
            resolving.Pop()
        }
        value := this.UnwrapFixtureResult(result, scopedCleanups)
        if value is AhkTestCapture
            fixtureContext.Captures.Push(value)
        if scope = "function" && HasProp(fixtureContext, "FunctionValues")
            fixtureContext.FunctionValues[name] := value
        else if scope = "suite"
            fixtureContext.SuiteValues[scopedKey] := value
        else if scope = "session"
            AhkTestSuite.SessionValues[sessionKey] := value
        return value
    }

    UnwrapFixtureCacheEntry(entry)
    {
        if entry is AhkTestFixtureSetupError
            throw entry.Error
        return entry
    }

    IsContextFixtureName(name)
    {
        return StrLower(name "") = "ahk_context"
    }

    CreateFixtureContext(cleanups, resolving, fixtureContext, activeFixture := unset)
    {
        cleanupTarget := cleanups
        fixtureName := ""
        scope := "function"
        if IsSet(activeFixture) {
            if HasProp(activeFixture, "CleanupTarget")
                cleanupTarget := activeFixture.CleanupTarget
            if HasProp(activeFixture, "Name")
                fixtureName := activeFixture.Name
            if HasProp(activeFixture, "Scope")
                scope := activeFixture.Scope
        }
        context := AhkTestFixtureContext(this, cleanups, cleanupTarget, resolving, fixtureContext, fixtureName, scope)
        if fixtureName != "" && HasProp(fixtureContext, "FixtureParams") && fixtureContext.FixtureParams.Has(fixtureName)
            context.Param := fixtureContext.FixtureParams[fixtureName]
        if fixtureName != "" && HasProp(fixtureContext, "FixtureParamIds") && fixtureContext.FixtureParamIds.Has(fixtureName)
            context.FixtureParamId := fixtureContext.FixtureParamIds[fixtureName]
        return context
    }

    ScopedFixtureKey(name, fixtureContext)
    {
        if HasProp(fixtureContext, "FixtureParamIds") && fixtureContext.FixtureParamIds.Has(name)
            return name "[" fixtureContext.FixtureParamIds[name] "]"
        return name
    }

    SessionFixtureKey(name)
    {
        return this.SessionId ":" name
    }

    IndexOf(values, needle)
    {
        for index, value in values {
            if value = needle
                return index
        }
        return 0
    }

    UnwrapFixtureResult(result, cleanups)
    {
        if result is AhkTestFixtureResult {
            if HasProp(result, "Cleanup")
                cleanups.Push(result.Cleanup)
            return result.Value
        }
        return result
    }

    RunCleanups(cleanups)
    {
        errors := []
        index := cleanups.Length
        while index >= 1 {
            try {
                cleanups[index].Call()
            } catch Error as err {
                errors.Push(err)
            }
            index -= 1
        }
        if errors.Length > 0
            throw AhkTestCleanupFailure(errors)
    }

    RunSuiteCleanups(stats, entries, cleanups, quiet, traceback := "short")
    {
        if cleanups.Length = 0
            return

        started := A_TickCount
        try {
            this.RunCleanups(cleanups)
        } catch Error as err {
            duration := A_TickCount - started
            stats.Errors += 1
            name := this.Name != "" ? this.Name " suite cleanup" : "suite cleanup"
            entries.Push({ Name: name, Status: "error", Duration: duration, Error: err })
            if !quiet {
                this.WriteLine("ERROR " name " (" duration "ms)")
                this.WriteError(err, traceback)
            }
        }
    }

    CleanupSessionFixtures(options := unset)
    {
        quiet := false
        if IsSet(options) && HasProp(options, "Quiet")
            quiet := options.Quiet

        stats := { Total: 0, Passed: 0, Failed: 0, Errors: 0, Skipped: 0, Deselected: 0, ExpectedFailures: 0, UnexpectedPasses: 0, Duration: 0 }
        entries := []
        started := A_TickCount
        try {
            this.RunCleanups(AhkTestSuite.SessionCleanups)
        } catch Error as err {
            duration := A_TickCount - started
            stats.Errors += 1
            entries.Push({ Name: "session fixture cleanup", Status: "error", Duration: duration, Error: err })
            if !quiet {
                this.WriteLine("ERROR session fixture cleanup (" duration "ms)")
                this.WriteError(err)
            }
        }
        AhkTestSuite.SessionValues := Map()
        AhkTestSuite.SessionCleanups := []
        stats.Duration := A_TickCount - started
        return AhkTestResult(stats, entries)
    }

    ShouldStopAfterFailure(stats, maxFail)
    {
        return maxFail > 0 && (stats.Failed + stats.Errors) >= maxFail
    }

    WriteLine(text := "")
    {
        if this.OutputFile != "" {
            if this.BufferedOutput {
                if this.OutputHandle = ""
                    this.OutputHandle := FileOpen(this.OutputFile, "a", "UTF-8")
                this.OutputHandle.Write(text "`n")
            } else {
                FileAppend(text "`n", this.OutputFile, "UTF-8")
            }
        } else {
            FileAppend(text "`n", "**", "UTF-8")
        }
    }

    CloseOutputFile()
    {
        if this.OutputHandle != "" {
            this.OutputHandle.Close()
            this.OutputHandle := ""
        }
        this.BufferedOutput := false
    }

    WriteError(err, traceback := "short")
    {
        message := HasProp(err, "Message") ? err.Message : err ""
        suppressTraceback := traceback = "no" || traceback = "none"
        if traceback = "line" {
            location := HasProp(err, "File") && err.File != "" ? err.File : "<unknown>"
            if HasProp(err, "Line") && err.Line != ""
                location .= ":" err.Line
            text := location ": " Type(err)
            if message != ""
                text .= ": " message
            if HasProp(err, "Extra") && err.Extra != ""
                text .= " - " err.Extra
            this.WriteLine("  " text)
            return
        }
        if message != ""
            this.WriteLine("  " message)
        if !suppressTraceback && HasProp(err, "File") && err.File != ""
            this.WriteLine("  at " err.File ":" err.Line)
        if HasProp(err, "Extra") && err.Extra != ""
            this.WriteLine("  " err.Extra)
        if !suppressTraceback && (traceback = "long" || traceback = "native") && HasProp(err, "Stack") && err.Stack != "" {
            this.WriteLine("  Stack:")
            this.WriteLine(err.Stack)
        }
    }

    WriteOutcomeReasonSummary(result, selector := unset)
    {
        for item in result.OutcomeReasons() {
            if IsSet(selector) && !this.SummarySelectorIncludesStatus(selector, item["Status"])
                continue
            reason := item["Reason"]
            this.WriteLine(StrUpper(item["Status"]) " [" item["Count"] "]" (reason != "" ? " " reason : ""))
        }
    }

    SummarySelectorIncludesStatus(selector, status)
    {
        text := selector ""
        code := ""
        if status = "skip"
            code := "s"
        else if status = "xfail"
            code := "x"
        else if status = "xpass"
            code := "X"
        else
            return false

        Loop Parse, text {
            if Ord(A_LoopField) = Ord(code)
                return true
        }
        return false
    }

    WriteWarningSummary(result)
    {
        summary := result.WarningSummary()
        if summary.Length = 0
            return
        this.WriteLine("Warnings:")
        for item in summary
            this.WriteLine(item["Category"] " [" item["Count"] "] " item["Message"])
    }

    WriteCaptured(entry, captureReport := "failures")
    {
        if captureReport = "none" || captureReport = "no"
            return
        if !HasProp(entry, "Captured")
            return
        if captureReport != "stderr" && entry.Captured.Out != "" {
            this.WriteLine("  --- captured stdout ---")
            this.WriteLine(entry.Captured.Out)
        }
        if captureReport != "stdout" && entry.Captured.Err != "" {
            this.WriteLine("  --- captured stderr ---")
            this.WriteLine(entry.Captured.Err)
        }
    }

    static _CallCollected(testClass, methodName)
    {
        return testClass.%methodName%()
    }

    static _RaiseCollectionError(name)
    {
        throw AhkTestCollectionError("collected test is not callable: " name)
    }

    static _CallParametrized(callback, args, fixtureArgs*)
    {
        callArgs := args.Clone()
        for value in fixtureArgs
            callArgs.Push(value)
        return callback.Call(callArgs*)
    }
}

class AhkTest
{
    static DefaultSuite := AhkTestSuite("default")
    static WarningStack := []

    static Tests {
        get => this.DefaultSuite.Tests
    }

    static OutputFile {
        get => this.DefaultSuite.OutputFile
        set => this.DefaultSuite.SetOutputFile(value)
    }

    static CreateSuite(name := "")
    {
        return AhkTestSuite(name)
    }

    static Test(name, callback, options := unset)
    {
        sourceOptions := this.DefaultSuite.OptionsWithSource("test", Error("source", -1), options?)
        return this.DefaultSuite.Test(name, callback, sourceOptions)
    }

    static Fixture(name, callback, options := unset)
    {
        return this.DefaultSuite.Fixture(name, callback, options?)
    }

    static RegisterMark(name, description := "")
    {
        return this.DefaultSuite.RegisterMark(name, description)
    }

    static Configure(config)
    {
        return this.DefaultSuite.Configure(config)
    }

    static ConfigureManifest(path, sectionName := "AhkTest")
    {
        return this.DefaultSuite.ConfigureManifest(path, sectionName)
    }

    static On(eventName, callback, options := unset)
    {
        return this.DefaultSuite.On(eventName, callback, options?)
    }

    static SkipMark(reason := "")
    {
        return AhkTestSkipMark(reason)
    }

    static XFailMark(reason := "", options := unset)
    {
        return AhkTestXFailMark(reason, options?)
    }

    static Mark(name, data := unset)
    {
        return AhkTestMark(name, data?)
    }

    static SourceHere(kind := "test")
    {
        location := Error("source", -1)
        source := { Kind: kind }
        if HasProp(location, "File")
            source.File := location.File
        if HasProp(location, "Line")
            source.Line := location.Line
        return source
    }

    static Skip(name, reason := "")
    {
        return this.DefaultSuite.Skip(name, reason, { Source: this.DefaultSuite.SourceFromLocation("skip", Error("source", -1)) })
    }

    static SkipIf(condition, name, callbackOrReason := "", reason := "")
    {
        return this.DefaultSuite.SkipIf(condition, name, callbackOrReason, reason)
    }

    static XFail(name, callback, reason := "", options := unset)
    {
        sourceOptions := this.DefaultSuite.OptionsWithSource("xfail", Error("source", -1), options?)
        return this.DefaultSuite.XFail(name, callback, reason, sourceOptions)
    }

    static Parametrize(nameTemplate, rows, callback, options := unset)
    {
        sourceOptions := this.DefaultSuite.OptionsWithSource("parametrize", Error("source", -1), options?)
        return this.DefaultSuite.Parametrize(nameTemplate, rows, callback, sourceOptions)
    }

    static Collect(testClass)
    {
        return this.DefaultSuite.Collect(testClass)
    }

    static Clear()
    {
        return this.DefaultSuite.Clear()
    }

    static SetOutputFile(path)
    {
        return this.DefaultSuite.SetOutputFile(path)
    }

    static Run(options := unset)
    {
        return this.DefaultSuite.Run(options?)
    }

    static CleanupSessionFixtures(options := unset)
    {
        return this.DefaultSuite.CleanupSessionFixtures(options?)
    }

    static AssertTrue(value, message := "")
    {
        if !value
            throw AhkTestFailure(this.MessageOrDefault(message, "Expected value to be true"))
    }

    static AssertFalse(value, message := "")
    {
        if value
            throw AhkTestFailure(this.MessageOrDefault(message, "Expected value to be false"))
    }

    static AssertEqual(expected, actual, message := "")
    {
        if !this.AreEqual(expected, actual) {
            detail := "Expected " this.ValueToString(expected) ", got " this.ValueToString(actual)
            throw AhkTestFailure(this.MessageOrDefault(message, detail), expected, actual)
        }
    }

    static AssertNotEqual(unexpected, actual, message := "")
    {
        if this.AreEqual(unexpected, actual) {
            detail := "Did not expect " this.ValueToString(actual)
            throw AhkTestFailure(this.MessageOrDefault(message, detail), unexpected, actual)
        }
    }

    static AssertSame(expected, actual, message := "")
    {
        if expected !== actual {
            detail := "Expected same object, got " this.ValueToString(actual)
            throw AhkTestFailure(this.MessageOrDefault(message, detail), expected, actual)
        }
    }

    static AssertContains(needle, haystack, message := "")
    {
        found := false
        if haystack is Map {
            found := haystack.Has(needle)
        } else if haystack is Array {
            for value in haystack {
                if this.AreEqual(needle, value) {
                    found := true
                    break
                }
            }
        } else {
            found := InStr(haystack "", needle "") > 0
        }

        if !found {
            detail := "Expected " this.ValueToString(needle) " to be contained in " this.ValueToString(haystack)
            throw AhkTestFailure(this.MessageOrDefault(message, detail), needle, haystack)
        }
    }

    static AssertNotContains(needle, haystack, message := "")
    {
        try {
            this.AssertContains(needle, haystack)
        } catch AhkTestFailure {
            return
        }

        detail := "Did not expect " this.ValueToString(needle) " to be contained in " this.ValueToString(haystack)
        throw AhkTestFailure(this.MessageOrDefault(message, detail), needle, haystack)
    }

    static AssertRegex(text, pattern, message := "")
    {
        if !RegExMatch(text "", pattern) {
            detail := "Expected " this.ValueToString(text) " to match " this.ValueToString(pattern)
            throw AhkTestFailure(this.MessageOrDefault(message, detail), pattern, text)
        }
    }

    static Approx(expected, options := unset)
    {
        return AhkTestApprox(expected, options?)
    }

    static FixtureResult(value, cleanup := unset)
    {
        return AhkTestFixtureResult(value, cleanup?)
    }

    static CaptureFixture()
    {
        return AhkTestCapture()
    }

    static AssertApprox(expected, actual, options := unset, message := "")
    {
        approx := this.Approx(expected, options?)
        if !approx.Matches(actual) {
            detail := "Expected " this.ValueToString(actual) " to approximately equal " this.ValueToString(expected)
            throw AhkTestFailure(this.MessageOrDefault(message, detail), expected, actual)
        }
    }

    static AssertThrows(expectedType, callback, message := "")
    {
        if !HasMethod(callback, "Call")
            throw TypeError("callback must be callable", -1)

        try {
            callback.Call()
        } catch Error as err {
            if err is expectedType
                return err
            detail := "Expected exception " expectedType.Prototype.__Class ", got " Type(err)
            throw AhkTestFailure(this.MessageOrDefault(message, detail), expectedType, err)
        }

        detail := "Expected exception " expectedType.Prototype.__Class ", but nothing was thrown"
        throw AhkTestFailure(this.MessageOrDefault(message, detail), expectedType)
    }

    static Raises(expectedType, callback, message := "")
    {
        return this.AssertThrows(expectedType, callback, message)
    }

    static RaisesMatch(expectedType, pattern, callback, message := "")
    {
        err := this.AssertThrows(expectedType, callback, message)
        if !RegExMatch(err.Message, pattern) {
            detail := "Expected exception message to match " this.ValueToString(pattern) ", got " this.ValueToString(err.Message)
            throw AhkTestFailure(this.MessageOrDefault(message, detail), pattern, err.Message)
        }
        return err
    }

    static Warn(message, category := "warning")
    {
        location := Error(message, -1)
        record := AhkTestWarningRecord(message, category, location)
        if this.WarningStack.Length > 0 {
            this.WarningStack[this.WarningStack.Length].Push(record)
            return record
        }
        throw location
    }

    static Warns(pattern, callback, options := "")
    {
        if !HasMethod(callback, "Call")
            throw TypeError("callback must be callable", -1)

        message := ""
        category := ""
        if IsObject(options) {
            if HasProp(options, "Message")
                message := options.Message
            if HasProp(options, "Category")
                category := options.Category
        } else {
            message := options
        }

        records := []
        this.WarningStack.Push(records)
        try {
            callback.Call()
        } finally {
            this.WarningStack.Pop()
        }

        if records.Length = 0
            throw AhkTestFailure(this.MessageOrDefault(message, "Expected warning matching " this.ValueToString(pattern) ", but no warnings were emitted"), pattern)

        for record in records {
            if RegExMatch(record.Message, pattern) && (category = "" || record.Category = category)
                return records
        }

        throw AhkTestFailure(this.MessageOrDefault(message, "Expected warning matching " this.ValueToString(pattern)), pattern, records)
    }

    static SkipNow(reason := "")
    {
        throw AhkTestSkip(reason)
    }

    static TempDir(prefix := "ahktest")
    {
        return AhkTestTempDir(prefix)
    }

    static TempPathFixture(prefix := "ahktest")
    {
        temp := this.TempDir(prefix)
        return this.FixtureResult(temp, ObjBindMethod(temp, "Cleanup"))
    }

    static TempPathFactoryFixture(prefix := "ahktest-factory")
    {
        factory := AhkTestTempPathFactory(prefix)
        return this.FixtureResult(factory, ObjBindMethod(factory, "Cleanup"))
    }

    static MonkeyPatchFixture()
    {
        patch := AhkTestMonkeyPatch()
        return this.FixtureResult(patch, ObjBindMethod(patch, "Cleanup"))
    }

    static Fail(message := "Test failed")
    {
        throw AhkTestFailure(message)
    }

    static AreEqual(expected, actual)
    {
        if IsObject(expected) || IsObject(actual) {
            if !IsObject(expected) || !IsObject(actual)
                return false

            if expected is Array && actual is Array {
                if expected.Length != actual.Length
                    return false
                loop expected.Length {
                    if !this.AreEqual(expected[A_Index], actual[A_Index])
                        return false
                }
                return true
            }

            if expected is Map && actual is Map {
                if expected.Count != actual.Count
                    return false
                for key, expectedValue in expected {
                    if !actual.Has(key)
                        return false
                    if !this.AreEqual(expectedValue, actual[key])
                        return false
                }
                return true
            }

            return expected == actual
        }

        return expected == actual
    }

    static ValueToString(value)
    {
        if IsObject(value) {
            if value is Array {
                parts := []
                for item in value
                    parts.Push(this.ValueToString(item))
                return "[" this.Join(parts, ", ") "]"
            }

            if value is Map {
                parts := []
                for key, item in value
                    parts.Push(this.ValueToString(key) ": " this.ValueToString(item))
                return "Map(" this.Join(parts, ", ") ")"
            }

            return "<" Type(value) ">"
        }

        if Type(value) = "String"
            return '"' value '"'
        return value ""
    }

    static Join(values, delimiter := "")
    {
        text := ""
        for index, value in values {
            if index > 1
                text .= delimiter
            text .= value
        }
        return text
    }

    static MessageOrDefault(message, fallback)
    {
        return message != "" ? message : fallback
    }

    static FormatReason(reason)
    {
        return reason != "" ? " - " reason : ""
    }

    static SortValues(values)
    {
        text := this.Join(values, "`n")
        if text = ""
            return []
        sortedText := Sort(text)
        result := []
        Loop Parse, sortedText, "`n", "`r" {
            if A_LoopField != ""
                result.Push(A_LoopField)
        }
        return result
    }

    static WriteLine(text := "")
    {
        return this.DefaultSuite.WriteLine(text)
    }

    static WriteError(err)
    {
        return this.DefaultSuite.WriteError(err)
    }
}

class AhkTestPath
{
    __New(path)
    {
        this.Path := path
    }

    Name
    {
        get {
            SplitPath this.Path, &name
            return name
        }
    }

    Stem
    {
        get {
            SplitPath this.Path, &name, , &extension, &nameNoExt
            if extension = "" || nameNoExt = ""
                return name
            return nameNoExt
        }
    }

    Suffix
    {
        get {
            SplitPath this.Path, &name, , &extension, &nameNoExt
            if extension = "" || nameNoExt = ""
                return ""
            return "." extension
        }
    }

    Exists()
    {
        return FileExist(this.Path) != ""
    }

    IsDir()
    {
        return DirExist(this.Path) != ""
    }

    Join(parts*)
    {
        path := this.Path
        for part in parts
            path := this.JoinPath(path, part)
        return AhkTestPath(path)
    }

    Parent()
    {
        SplitPath this.Path, , &dir
        return AhkTestPath(dir)
    }

    WriteText(text, encoding := "UTF-8")
    {
        parent := this.Parent()
        if parent.Path != "" && !parent.IsDir()
            DirCreate parent.Path
        if FileExist(this.Path) && !DirExist(this.Path)
            FileDelete this.Path
        FileAppend text, this.Path, encoding
        return this
    }

    ReadText(encoding := "UTF-8")
    {
        return FileRead(this.Path, encoding)
    }

    Mkdir(options := unset)
    {
        parents := IsSet(options) && HasProp(options, "Parents") ? options.Parents : false
        existOk := IsSet(options) && HasProp(options, "ExistOk") ? options.ExistOk : false
        if this.IsDir() {
            if existOk
                return this
            throw OSError("directory already exists: " this.Path, -1)
        }
        parent := this.Parent()
        if parent.Path != "" && !parent.IsDir() && !parents
            throw OSError("parent directory does not exist: " parent.Path, -1)
        DirCreate this.Path
        return this
    }

    Unlink(options := unset)
    {
        missingOk := IsSet(options) && HasProp(options, "MissingOk") ? options.MissingOk : false
        if !this.Exists() && missingOk
            return this
        FileDelete this.Path
        return this
    }

    Rmdir()
    {
        DirDelete this.Path
        return this
    }

    JoinPath(left, right)
    {
        return RTrim(left, "\/") "\" RegExReplace(right, "^[\\/]+")
    }
}

class AhkTestTempDir
{
    __New(prefix := "ahktest", path := unset)
    {
        static counter := 0

        if IsSet(path) {
            this.Path := path
            parent := this.ParentDir(this.Path)
            if parent != "" && !DirExist(parent)
                DirCreate parent
            if !DirExist(this.Path)
                DirCreate this.Path
            return
        }

        safePrefix := RegExReplace(prefix, "[^\w.-]", "-")
        counter += 1
        this.Path := A_Temp "\" safePrefix "-" A_NowUTC "-" A_TickCount "-" counter
        DirCreate this.Path
    }

    File(relativePath, text := "", encoding := "UTF-8")
    {
        path := this.PathJoin(relativePath)
        parent := this.ParentDir(path)
        if parent != "" && !DirExist(parent)
            DirCreate parent
        FileAppend text, path, encoding
        return path
    }

    Cleanup()
    {
        if !DirExist(this.Path)
            return
        DirDelete this.Path, true
    }

    PathJoin(parts*)
    {
        path := this.Path
        for part in parts
            path := this.JoinPath(path, part)
        return path
    }

    Join(parts*)
    {
        return AhkTestPath(this.PathJoin(parts*))
    }

    JoinPath(left, right)
    {
        return RTrim(left, "\/") "\" RegExReplace(right, "^[\\/]+")
    }

    ParentDir(path)
    {
        SplitPath path, , &dir
        return dir
    }
}

class AhkTestTempPathFactory
{
    __New(prefix := "ahktest-factory")
    {
        this.Prefix := prefix
        this.Counter := 0
        this.Root := AhkTestTempDir(prefix)
    }

    MakeTemp(prefix := "tmp")
    {
        this.Counter += 1
        path := this.Root.PathJoin(prefix "-" this.Counter)
        return AhkTestTempDir("", path)
    }

    Cleanup()
    {
        this.Root.Cleanup()
    }
}

class AhkTestMonkeyPatch
{
    __New()
    {
        this.EnvRecords := Map()
        this.EnvOrder := []
        this.MapRecords := Map()
        this.MapOrder := []
        this.PropRecords := Map()
        this.PropOrder := []
        this.HasWorkingDir := false
        this.WorkingDir := ""
    }

    SetEnv(name, value)
    {
        if !this.EnvRecords.Has(name) {
            original := EnvGet(name)
            this.EnvRecords[name] := { Exists: original != "", Value: original }
            this.EnvOrder.Push(name)
        }
        EnvSet name, value
    }

    DelEnv(name)
    {
        if !this.EnvRecords.Has(name) {
            original := EnvGet(name)
            this.EnvRecords[name] := { Exists: original != "", Value: original }
            this.EnvOrder.Push(name)
        }
        EnvSet name
    }

    PrependEnvPath(value, name := "PATH", separator := ";")
    {
        current := EnvGet(name)
        if current = ""
            this.SetEnv(name, value)
        else
            this.SetEnv(name, value separator current)
    }

    SetMap(target, key, value)
    {
        this.RememberMapValue(target, key)
        target[key] := value
    }

    DelMap(target, key)
    {
        this.RememberMapValue(target, key)
        if target.Has(key)
            target.Delete(key)
    }

    SetProp(target, name, value)
    {
        this.RememberPropValue(target, name)
        target.%name% := value
    }

    DelProp(target, name)
    {
        this.RememberPropValue(target, name)
        if target.HasOwnProp(name)
            target.DeleteProp(name)
    }

    SetMethod(target, name, callback)
    {
        this.RememberPropValue(target, name)
        target.DefineProp(name, { Call: callback })
    }

    RememberMapValue(target, key)
    {
        recordKey := ObjPtr(target) ":" key
        if this.MapRecords.Has(recordKey)
            return
        exists := target.Has(key)
        record := { Target: target, Key: key, Exists: exists }
        if exists
            record.Value := target[key]
        this.MapRecords[recordKey] := record
        this.MapOrder.Push(recordKey)
    }

    RememberPropValue(target, name)
    {
        recordKey := ObjPtr(target) ":" name
        if this.PropRecords.Has(recordKey)
            return
        exists := target.HasOwnProp(name)
        record := { Target: target, Name: name, Exists: exists }
        if exists
            record.Descriptor := target.GetOwnPropDesc(name)
        this.PropRecords[recordKey] := record
        this.PropOrder.Push(recordKey)
    }

    ChDir(path)
    {
        if !this.HasWorkingDir {
            this.WorkingDir := A_WorkingDir
            this.HasWorkingDir := true
        }
        SetWorkingDir path
    }

    Cleanup()
    {
        index := this.PropOrder.Length
        while index >= 1 {
            record := this.PropRecords[this.PropOrder[index]]
            if record.Exists
                record.Target.DefineProp(record.Name, record.Descriptor)
            else if record.Target.HasOwnProp(record.Name)
                record.Target.DeleteProp(record.Name)
            index -= 1
        }

        index := this.MapOrder.Length
        while index >= 1 {
            record := this.MapRecords[this.MapOrder[index]]
            if record.Exists
                record.Target[record.Key] := record.Value
            else if record.Target.Has(record.Key)
                record.Target.Delete(record.Key)
            index -= 1
        }

        if this.HasWorkingDir
            SetWorkingDir this.WorkingDir

        index := this.EnvOrder.Length
        while index >= 1 {
            name := this.EnvOrder[index]
            record := this.EnvRecords[name]
            if record.Exists
                EnvSet name, record.Value
            else
                EnvSet name
            index -= 1
        }
    }
}
