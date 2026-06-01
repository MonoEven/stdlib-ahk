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

AhkTest.Collect(StdlibWarningsTest)
