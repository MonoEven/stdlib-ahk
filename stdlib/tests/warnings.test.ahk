#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\warnings>

class StdlibWarningsTest
{
    static TestCatchWarningsRecordsDefaultWarning()
    {
        records := stdlib.warnings.catch_warnings(true).Call(stdlib_warnings_test_warn_default)

        AhkTest.AssertEqual(1, records.Length)
        AhkTest.AssertEqual("deprecated", records[1].message)
        AhkTest.AssertSame(stdlib.warnings.UserWarning, records[1].category)
    }

    static TestWarnRecordsCustomCategoryAndSource()
    {
        records := stdlib.warnings.catch_warnings(true).Call(stdlib_warnings_test_warn_custom)

        AhkTest.AssertEqual(1, records.Length)
        AhkTest.AssertEqual("old api", records[1].message)
        AhkTest.AssertSame(stdlib.warnings.DeprecationWarning, records[1].category)
        AhkTest.AssertEqual("legacy", records[1].source)
    }

    static TestWarnRecordsCallsite()
    {
        stdlib.warnings.catch_warnings(true).Call(stdlib_warnings_test_warn_records_callsite)
    }

    static TestWarnStacklevelReportsOuterCaller()
    {
        stdlib.warnings.catch_warnings(true).Call(stdlib_warnings_test_warn_stacklevel_wrapper)
    }

    static TestSimplefilterErrorRaisesWarningCategoryAndCatchRestores()
    {
        AhkTest.RaisesMatch(stdlib.warnings.DeprecationWarning, "old api", (*) => stdlib.warnings.catch_warnings().Call(stdlib_warnings_test_error_filter))

        records := stdlib.warnings.catch_warnings(true).Call(stdlib_warnings_test_warn_custom)

        AhkTest.AssertEqual(1, records.Length)
        AhkTest.AssertSame(stdlib.warnings.DeprecationWarning, records[1].category)
    }

    static TestDefaultFilterDeduplicatesSameWarningSite()
    {
        records := stdlib.warnings.catch_warnings(true).Call(stdlib_warnings_test_default_filter_repeats_same_site)

        AhkTest.AssertEqual(1, records.Length)
        AhkTest.AssertEqual("repeat", records[1].message)
    }

    static TestAlwaysFilterRecordsRepeatedWarningSite()
    {
        records := stdlib.warnings.catch_warnings(true).Call(stdlib_warnings_test_always_filter_repeats_same_site)

        AhkTest.AssertEqual(2, records.Length)
        AhkTest.AssertEqual("repeat", records[1].message)
        AhkTest.AssertEqual("repeat", records[2].message)
    }

    static TestWarnRejectsNonWarningCategory()
    {
        AhkTest.RaisesMatch(TypeError, "category must be a Warning subclass", (*) => stdlib.warnings.warn("bad", ValueError))
    }

    static TestSimplefilterMatchesWarningSubclasses()
    {
        AhkTest.RaisesMatch(StdlibWarningsCustomDeprecationWarning, "old api", (*) => stdlib.warnings.catch_warnings().Call(stdlib_warnings_test_subclass_error_filter))
    }

    static TestSimplefilterLinenoOnlyMatchesWarningLocation()
    {
        records := stdlib.warnings.catch_warnings(true).Call(stdlib_warnings_test_lineno_mismatch_filter)

        AhkTest.AssertEqual(1, records.Length)
        AhkTest.AssertEqual("line mismatch", records[1].message)
    }

    static TestNewCategoriesExtendWarning()
    {
        AhkTest.AssertTrue(HasBase(stdlib.warnings.FutureWarning.Prototype, stdlib.warnings.Warning.Prototype))
        AhkTest.AssertTrue(HasBase(stdlib.warnings.RuntimeWarning.Prototype, stdlib.warnings.Warning.Prototype))
        AhkTest.AssertTrue(HasBase(stdlib.warnings.SyntaxWarning.Prototype, stdlib.warnings.Warning.Prototype))
        AhkTest.AssertTrue(HasBase(stdlib.warnings.ImportWarning.Prototype, stdlib.warnings.Warning.Prototype))
        AhkTest.AssertTrue(HasBase(stdlib.warnings.UnicodeWarning.Prototype, stdlib.warnings.Warning.Prototype))
        AhkTest.AssertTrue(HasBase(stdlib.warnings.BytesWarning.Prototype, stdlib.warnings.Warning.Prototype))
        AhkTest.AssertTrue(HasBase(stdlib.warnings.ResourceWarning.Prototype, stdlib.warnings.Warning.Prototype))
        AhkTest.AssertTrue(HasBase(stdlib.warnings.PendingDeprecationWarning.Prototype, stdlib.warnings.Warning.Prototype))
    }

    static TestFormatwarningBasicAndWithLine()
    {
        ; py -3.10: 'a/b.py:3: DeprecationWarning: boom\n'
        AhkTest.AssertEqual("a/b.py:3: DeprecationWarning: boom`n"
            , stdlib.warnings.formatwarning("boom", stdlib.warnings.DeprecationWarning, "a/b.py", 3))
        ; py -3.10: 'a/b.py:3: DeprecationWarning: boom\n  x = 1\n' (line stripped, 2-space indent)
        AhkTest.AssertEqual("a/b.py:3: DeprecationWarning: boom`n  x = 1`n"
            , stdlib.warnings.formatwarning("boom", stdlib.warnings.DeprecationWarning, "a/b.py", 3, "   x = 1  "))
    }

    static TestWarnExplicitRecordsExplicitLocation()
    {
        records := stdlib.warnings.catch_warnings(true).Call(stdlib_warnings_test_warn_explicit)

        AhkTest.AssertEqual(1, records.Length)
        AhkTest.AssertEqual("boom", records[1].message)
        AhkTest.AssertEqual("myfile.py", records[1].filename)
        AhkTest.AssertEqual(42, records[1].lineno)
        AhkTest.AssertSame(stdlib.warnings.UserWarning, records[1].category)
    }

    static TestFilterwarningsMessageRegexIsCaseInsensitive()
    {
        ; py -3.10: error filter on message 'hello' (case-insensitive) raises for "HELLO world",
        ; records "say hello" (no match anchored at start)
        AhkTest.RaisesMatch(stdlib.warnings.UserWarning, "HELLO world", (*) => stdlib.warnings.catch_warnings().Call(stdlib_warnings_test_message_filter_error))

        records := stdlib.warnings.catch_warnings(true).Call(stdlib_warnings_test_message_filter_record)
        AhkTest.AssertEqual(1, records.Length)
        AhkTest.AssertEqual("say hello", records[1].message)
    }

    static TestFilterwarningsModuleRegexMatches()
    {
        records := stdlib.warnings.catch_warnings(true).Call(stdlib_warnings_test_module_filter)
        AhkTest.AssertEqual(1, records.Length)
        AhkTest.AssertEqual("kept", records[1].message)
    }

    static TestFilterwarningsAppendOrdersAfterExisting()
    {
        records := stdlib.warnings.catch_warnings(true).Call(stdlib_warnings_test_append_order)
        ; first matching filter wins; 'always' inserted first then 'ignore' appended -> recorded
        AhkTest.AssertEqual(1, records.Length)
        AhkTest.AssertEqual("ordered", records[1].message)
    }

    static TestFilterwarningsRejectsBadAction()
    {
        AhkTest.RaisesMatch(ValueError, "invalid action", (*) => stdlib.warnings.filterwarnings("bogus"))
    }

    static TestFilterwarningsRejectsNonStringMessage()
    {
        AhkTest.RaisesMatch(TypeError, "message must be a string", (*) => stdlib.warnings.filterwarnings("ignore", 5))
    }
}

stdlib_warnings_test_warn_default(records)
{
    stdlib.warnings.warn("deprecated")
}

stdlib_warnings_test_warn_custom(records)
{
    stdlib.warnings.simplefilter("always")
    stdlib.warnings.warn("old api", stdlib.warnings.DeprecationWarning, 1, "legacy")
}

stdlib_warnings_test_warn_records_callsite(records)
{
    stdlib.warnings.simplefilter("always")
    expectedFile := A_LineFile
    expectedLine := A_LineNumber + 1
    stdlib.warnings.warn("located")
    AhkTest.AssertEqual(expectedFile, records[1].filename)
    AhkTest.AssertEqual(expectedLine, records[1].lineno)
}

stdlib_warnings_test_warn_stacklevel_wrapper(records)
{
    stdlib.warnings.simplefilter("always")
    expectedFile := A_LineFile
    expectedLine := A_LineNumber + 1
    stdlib_warnings_test_emit_stacklevel_two()
    AhkTest.AssertEqual(expectedFile, records[1].filename)
    AhkTest.AssertEqual(expectedLine, records[1].lineno)
}

stdlib_warnings_test_emit_stacklevel_two()
{
    stdlib.warnings.warn("wrapped", unset, 2)
}

stdlib_warnings_test_error_filter(records)
{
    stdlib.warnings.simplefilter("error", stdlib.warnings.DeprecationWarning)
    stdlib.warnings.warn("old api", stdlib.warnings.DeprecationWarning)
}

class StdlibWarningsCustomDeprecationWarning extends AhkStdlibWarningsDeprecationWarning
{
}

stdlib_warnings_test_subclass_error_filter(records)
{
    stdlib.warnings.simplefilter("error", stdlib.warnings.DeprecationWarning)
    stdlib.warnings.warn("old api", StdlibWarningsCustomDeprecationWarning)
}

stdlib_warnings_test_lineno_mismatch_filter(records)
{
    stdlib.warnings.simplefilter("error", stdlib.warnings.UserWarning, 999999)
    stdlib.warnings.warn("line mismatch")
}

stdlib_warnings_test_default_filter_repeats_same_site(records)
{
    stdlib.warnings.simplefilter("default")
    Loop 2
        stdlib.warnings.warn("repeat")
}

stdlib_warnings_test_always_filter_repeats_same_site(records)
{
    stdlib.warnings.simplefilter("always")
    Loop 2
        stdlib.warnings.warn("repeat")
}

stdlib_warnings_test_warn_explicit(records)
{
    stdlib.warnings.simplefilter("always")
    stdlib.warnings.warn_explicit("boom", stdlib.warnings.UserWarning, "myfile.py", 42)
}

stdlib_warnings_test_message_filter_error(records)
{
    stdlib.warnings.filterwarnings("error", "hello")
    stdlib.warnings.warn("HELLO world")
}

stdlib_warnings_test_message_filter_record(records)
{
    stdlib.warnings.filterwarnings("error", "hello")
    stdlib.warnings.filterwarnings("always", "say")
    stdlib.warnings.warn("say hello")
}

stdlib_warnings_test_module_filter(records)
{
    stdlib.warnings.filterwarnings("always", "", stdlib.warnings.UserWarning, "myfile")
    stdlib.warnings.filterwarnings("ignore", , , , , true)
    stdlib.warnings.warn_explicit("kept", stdlib.warnings.UserWarning, "myfile.py", 1)
    stdlib.warnings.warn_explicit("dropped", stdlib.warnings.UserWarning, "other.py", 1)
}

stdlib_warnings_test_append_order(records)
{
    stdlib.warnings.filterwarnings("always")
    stdlib.warnings.filterwarnings("ignore", , , , , true)
    stdlib.warnings.warn("ordered")
}

AhkTest.Collect(StdlibWarningsTest)
