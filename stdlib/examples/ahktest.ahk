#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>

AhkTest.Clear()
AhkTest.Test("example equality", (*) => AhkTest.AssertEqual(3, 1 + 2))
AhkTest.Test("example raises", (*) => AhkTest.Raises(ValueError, (*) => ahktest_example_raise()))
AhkTest.Parametrize("example addition {id}", [
    { Id: "small", Args: [1, 2, 3] },
    { Id: "large", Args: [10, 20, 30] }
], (args*) => AhkTest.AssertEqual(args[3], args[1] + args[2]))

example_suite := AhkTest.CreateSuite("isolated example")
example_suite.SkipIf(true, "example conditional skip", "platform-specific")
example_suite.XFail("example expected failure", (*) => AhkTest.Fail("not ready"), "documented gap")
example_suite.Run({ Quiet: true })

fixture_names_suite := AhkTest.CreateSuite("fixture names example")
fixture_names_suite.Fixture("auto", (*) => "auto", { Autouse: true })
fixture_names_suite.Fixture("dep", (ctx) => ctx.FixtureNames, { Fixtures: ["ahk_context"] })
fixture_names_suite.Fixture("meta", (ctx, depNames) => Map("ContextNames", ctx.FixtureNames, "DepNames", depNames), { Fixtures: ["ahk_context", "dep"] })
fixture_names_suite.Test("request-like fixture names", (meta) => (
    AhkTest.AssertEqual(["auto", "meta", "ahk_context", "dep"], meta["ContextNames"]),
    AhkTest.AssertEqual(["auto", "meta", "ahk_context", "dep"], meta["DepNames"])
), { Fixtures: ["meta"] })
fixture_names_result := fixture_names_suite.Run({ Quiet: true })
if fixture_names_result.ExitCode != 0
    throw Error("ahktest fixture names example failed", -1)

dynamic_fixture_names_suite := AhkTest.CreateSuite("dynamic fixture names example")
dynamic_fixture_names_suite.Fixture("base", (*) => "base")
dynamic_fixture_names_suite.Fixture("dynamic", (base) => base "-dyn", { Fixtures: ["base"] })
dynamic_fixture_names_suite.Test("request-like dynamic fixture names", (ctx) => ahktest_example_assert_dynamic_fixture_names(ctx), { Fixtures: ["ahk_context"] })
dynamic_fixture_names_result := dynamic_fixture_names_suite.Run({ Quiet: true })
if dynamic_fixture_names_result.ExitCode != 0
    throw Error("ahktest dynamic fixture names example failed", -1)

config_manifest_path := A_Temp "\ahktest-example-config-manifest-" A_TickCount ".json"
ahktest_example_discovery_manifest_json := '{`"AhkTest`":{`"DiscoveryRoots`":[`"tests`",`"integration`"]}}'
config_manifest_suite := AhkTest.CreateSuite("manifest config example")
try {
    ahktest_example_write_utf8_raw(config_manifest_path, '{`"AhkTest`":{`"AhkRunDefaults`":{`"FilterExpr`":`"selected`",`"List`":false}}}')
    config_manifest_suite.ConfigureManifest(config_manifest_path)
    config_manifest_suite.Test("selected manifest example", (*) => AhkTest.AssertTrue(true))
    config_manifest_suite.Test("filtered manifest example", (*) => AhkTest.Fail("manifest default should deselect this example"))
    config_manifest_result := config_manifest_suite.Run({ Quiet: true })
    AhkTest.AssertEqual(1, config_manifest_result.Passed)
    AhkTest.AssertEqual(1, config_manifest_result.Deselected)
} finally {
    if FileExist(config_manifest_path)
        FileDelete config_manifest_path
}

last_failed_cache := A_Temp "\ahktest-example-last-failed-" A_TickCount ".txt"
last_failed_first_suite := AhkTest.CreateSuite("last failed example first")
last_failed_second_suite := AhkTest.CreateSuite("last failed example second")
last_failed_first_suite.Test("old failing name", (*) => AhkTest.Fail("cached failure"))
last_failed_second_suite.Test("new passing name", (*) => AhkTest.AssertTrue(true))
last_failed_second_suite.Test("other passing name", (*) => AhkTest.AssertTrue(true))
try {
    last_failed_first_result := last_failed_first_suite.Run({ Quiet: true, LastFailedCache: last_failed_cache })
    last_failed_second_result := last_failed_second_suite.Run({ Quiet: true, LastFailed: true, LastFailedCache: last_failed_cache })
    AhkTest.AssertEqual(1, last_failed_first_result.Failed)
    AhkTest.AssertEqual(2, last_failed_second_result.Passed)
    AhkTest.AssertEqual(0, last_failed_second_result.Deselected)
} finally {
    if FileExist(last_failed_cache)
        FileDelete last_failed_cache
}

last_failed_node_filter_cache := A_Temp "\ahktest-example-last-failed-node-filter-" A_TickCount ".txt"
last_failed_node_filter_first_suite := AhkTest.CreateSuite("last failed node filter example")
last_failed_node_filter_second_suite := AhkTest.CreateSuite("last failed node filter example")
last_failed_node_filter_selected_node := "last failed node filter example::selected pass"
last_failed_node_filter_first_suite.Test("old cached failure", (*) => AhkTest.Fail("cached failure"))
last_failed_node_filter_first_suite.Test("selected pass", (*) => AhkTest.AssertTrue(true))
last_failed_node_filter_second_suite.Test("old cached failure", (*) => AhkTest.Fail("node filter should bypass cached-only selection"))
last_failed_node_filter_second_suite.Test("selected pass", (*) => AhkTest.AssertTrue(true))
try {
    last_failed_node_filter_first_result := last_failed_node_filter_first_suite.Run({ Quiet: true, LastFailedCache: last_failed_node_filter_cache })
    last_failed_node_filter_second_result := last_failed_node_filter_second_suite.Run({ Quiet: true, LastFailed: true, LastFailedCache: last_failed_node_filter_cache, NodeFilter: last_failed_node_filter_selected_node })
    last_failed_node_filter_cache_text := FileExist(last_failed_node_filter_cache) ? FileRead(last_failed_node_filter_cache, "UTF-8") : ""
    AhkTest.AssertEqual(1, last_failed_node_filter_first_result.Failed)
    AhkTest.AssertEqual(1, last_failed_node_filter_second_result.Passed)
    AhkTest.AssertEqual(1, last_failed_node_filter_second_result.Deselected)
    AhkTest.AssertContains("last failed node filter example::old cached failure", last_failed_node_filter_cache_text)
} finally {
    if FileExist(last_failed_node_filter_cache)
        FileDelete last_failed_node_filter_cache
}

last_failed_filter_expr_cache := A_Temp "\ahktest-example-last-failed-filter-expr-" A_TickCount ".txt"
last_failed_filter_expr_first_suite := AhkTest.CreateSuite("last failed filter expr example")
last_failed_filter_expr_second_suite := AhkTest.CreateSuite("last failed filter expr example")
last_failed_filter_expr_first_suite.Test("old cached failure", (*) => AhkTest.Fail("cached failure"))
last_failed_filter_expr_first_suite.Test("selected pass", (*) => AhkTest.AssertTrue(true))
last_failed_filter_expr_first_suite.Test("other pass", (*) => AhkTest.AssertTrue(true))
last_failed_filter_expr_second_suite.Test("old cached failure", (*) => AhkTest.Fail("filter expression should bypass cached-only selection"))
last_failed_filter_expr_second_suite.Test("selected pass", (*) => AhkTest.AssertTrue(true))
last_failed_filter_expr_second_suite.Test("other pass", (*) => AhkTest.AssertTrue(true))
try {
    last_failed_filter_expr_first_result := last_failed_filter_expr_first_suite.Run({ Quiet: true, LastFailedCache: last_failed_filter_expr_cache })
    last_failed_filter_expr_second_result := last_failed_filter_expr_second_suite.Run({ Quiet: true, LastFailed: true, LastFailedCache: last_failed_filter_expr_cache, FilterExpr: "selected" })
    last_failed_filter_expr_cache_text := FileExist(last_failed_filter_expr_cache) ? FileRead(last_failed_filter_expr_cache, "UTF-8") : ""
    AhkTest.AssertEqual(1, last_failed_filter_expr_first_result.Failed)
    AhkTest.AssertEqual(1, last_failed_filter_expr_second_result.Passed)
    AhkTest.AssertEqual(2, last_failed_filter_expr_second_result.Deselected)
    AhkTest.AssertContains("last failed filter expr example::old cached failure", last_failed_filter_expr_cache_text)
} finally {
    if FileExist(last_failed_filter_expr_cache)
        FileDelete last_failed_filter_expr_cache
}

last_failed_node_filter_array_cache := A_Temp "\ahktest-example-last-failed-node-filter-array-" A_TickCount ".txt"
last_failed_node_filter_array_first_suite := AhkTest.CreateSuite("last failed node filter array example")
last_failed_node_filter_array_second_suite := AhkTest.CreateSuite("last failed node filter array example")
last_failed_node_filter_array_selected_nodes := [
    "last failed node filter array example::selected pass one",
    "last failed node filter array example::selected pass two"
]
last_failed_node_filter_array_first_suite.Test("old cached failure", (*) => AhkTest.Fail("cached failure"))
last_failed_node_filter_array_first_suite.Test("selected pass one", (*) => AhkTest.AssertTrue(true))
last_failed_node_filter_array_first_suite.Test("selected pass two", (*) => AhkTest.AssertTrue(true))
last_failed_node_filter_array_second_suite.Test("old cached failure", (*) => AhkTest.Fail("node filter array should bypass cached-only selection"))
last_failed_node_filter_array_second_suite.Test("selected pass one", (*) => AhkTest.AssertTrue(true))
last_failed_node_filter_array_second_suite.Test("selected pass two", (*) => AhkTest.AssertTrue(true))
try {
    last_failed_node_filter_array_first_result := last_failed_node_filter_array_first_suite.Run({ Quiet: true, LastFailedCache: last_failed_node_filter_array_cache })
    last_failed_node_filter_array_second_result := last_failed_node_filter_array_second_suite.Run({ Quiet: true, LastFailed: true, LastFailedCache: last_failed_node_filter_array_cache, NodeFilter: last_failed_node_filter_array_selected_nodes })
    last_failed_node_filter_array_cache_text := FileExist(last_failed_node_filter_array_cache) ? FileRead(last_failed_node_filter_array_cache, "UTF-8") : ""
    AhkTest.AssertEqual(1, last_failed_node_filter_array_first_result.Failed)
    AhkTest.AssertEqual(2, last_failed_node_filter_array_second_result.Passed)
    AhkTest.AssertEqual(1, last_failed_node_filter_array_second_result.Deselected)
    AhkTest.AssertContains("last failed node filter array example::old cached failure", last_failed_node_filter_array_cache_text)
} finally {
    if FileExist(last_failed_node_filter_array_cache)
        FileDelete last_failed_node_filter_array_cache
}

stale_stepwise_cache := A_Temp "\ahktest-example-stale-stepwise-" A_TickCount ".txt"
stale_stepwise_first_suite := AhkTest.CreateSuite("stale stepwise example first")
stale_stepwise_second_suite := AhkTest.CreateSuite("stale stepwise example second")
stale_stepwise_first_suite.Test("old failing name", (*) => AhkTest.Fail("cached failure"))
stale_stepwise_second_suite.Test("new passing name", (*) => AhkTest.AssertTrue(true))
stale_stepwise_second_suite.Test("other passing name", (*) => AhkTest.AssertTrue(true))
try {
    stale_stepwise_first_result := stale_stepwise_first_suite.Run({ Quiet: true, Stepwise: true, StepwiseCache: stale_stepwise_cache })
    stale_stepwise_second_result := stale_stepwise_second_suite.Run({ Quiet: true, Stepwise: true, StepwiseCache: stale_stepwise_cache })
    stale_stepwise_cache_text := FileExist(stale_stepwise_cache) ? FileRead(stale_stepwise_cache, "UTF-8") : ""
    AhkTest.AssertEqual(1, stale_stepwise_first_result.Failed)
    AhkTest.AssertEqual(2, stale_stepwise_second_result.Passed)
    AhkTest.AssertEqual(0, stale_stepwise_second_result.Deselected)
    AhkTest.AssertContains("stale stepwise example first::old failing name", stale_stepwise_cache_text)
} finally {
    if FileExist(stale_stepwise_cache)
        FileDelete stale_stepwise_cache
}

node_filter_stepwise_cache := A_Temp "\ahktest-example-stepwise-node-filter-" A_TickCount ".txt"
node_filter_stepwise_suite := AhkTest.CreateSuite("stepwise node filter example")
node_filter_stepwise_fail_middle := true
node_filter_selected_node := "stepwise node filter example::after pass"
node_filter_stepwise_suite.Test("before pass", (*) => AhkTest.AssertTrue(true))
node_filter_stepwise_suite.Test("middle failure", (*) => ahktest_example_stepwise_maybe_fail(&node_filter_stepwise_fail_middle))
node_filter_stepwise_suite.Test("after pass", (*) => AhkTest.AssertTrue(true))
try {
    node_filter_first_result := node_filter_stepwise_suite.Run({ Quiet: true, Stepwise: true, StepwiseCache: node_filter_stepwise_cache })
    node_filter_second_result := node_filter_stepwise_suite.Run({ Quiet: true, Stepwise: true, StepwiseCache: node_filter_stepwise_cache, NodeFilter: node_filter_selected_node })
    node_filter_stepwise_cache_text := FileExist(node_filter_stepwise_cache) ? FileRead(node_filter_stepwise_cache, "UTF-8") : ""
    AhkTest.AssertEqual(1, node_filter_first_result.Failed)
    AhkTest.AssertEqual(1, node_filter_second_result.Passed)
    AhkTest.AssertEqual(2, node_filter_second_result.Deselected)
    AhkTest.AssertContains("stepwise node filter example::middle failure", node_filter_stepwise_cache_text)
} finally {
    if FileExist(node_filter_stepwise_cache)
        FileDelete node_filter_stepwise_cache
}

duplicate_source_last_failed_cache := A_Temp "\ahktest-example-duplicate-source-last-failed-" A_TickCount ".txt"
duplicate_source_last_failed_first_suite := AhkTest.CreateSuite()
duplicate_source_last_failed_second_suite := AhkTest.CreateSuite()
duplicate_source_last_failed_first_source := { Kind: "test", File: "a_duplicate.test.ahk", Line: 1 }
duplicate_source_last_failed_second_source := { Kind: "test", File: "b_duplicate.test.ahk", Line: 1 }
duplicate_source_last_failed_first_suite.Test("duplicate example", (*) => AhkTest.Fail("first source failure"), { Source: duplicate_source_last_failed_first_source })
duplicate_source_last_failed_first_suite.Test("duplicate example", (*) => AhkTest.AssertTrue(true), { Source: duplicate_source_last_failed_second_source })
duplicate_source_last_failed_second_suite.Test("duplicate example", (*) => AhkTest.AssertTrue(true), { Source: duplicate_source_last_failed_first_source })
duplicate_source_last_failed_second_suite.Test("duplicate example", (*) => AhkTest.Fail("second source should stay deselected"), { Source: duplicate_source_last_failed_second_source })
try {
    duplicate_source_last_failed_first_result := duplicate_source_last_failed_first_suite.Run({ Quiet: true, LastFailedCache: duplicate_source_last_failed_cache })
    duplicate_source_last_failed_second_result := duplicate_source_last_failed_second_suite.Run({ Quiet: true, LastFailed: true, LastFailedCache: duplicate_source_last_failed_cache })
    AhkTest.AssertEqual(1, duplicate_source_last_failed_first_result.Failed)
    AhkTest.AssertEqual(1, duplicate_source_last_failed_second_result.Passed)
    AhkTest.AssertEqual(1, duplicate_source_last_failed_second_result.Deselected)
    AhkTest.AssertEqual("a_duplicate.test.ahk", duplicate_source_last_failed_second_result.Entries[1].Source.File)
} finally {
    if FileExist(duplicate_source_last_failed_cache)
        FileDelete duplicate_source_last_failed_cache
}

duplicate_source_stepwise_cache := A_Temp "\ahktest-example-duplicate-source-stepwise-" A_TickCount ".txt"
duplicate_source_stepwise_first_suite := AhkTest.CreateSuite()
duplicate_source_stepwise_second_suite := AhkTest.CreateSuite()
duplicate_source_stepwise_first_source := { Kind: "test", File: "a_duplicate.test.ahk", Line: 1 }
duplicate_source_stepwise_second_source := { Kind: "test", File: "b_duplicate.test.ahk", Line: 1 }
duplicate_source_stepwise_third_source := { Kind: "test", File: "c_after.test.ahk", Line: 1 }
duplicate_source_stepwise_first_suite.Test("duplicate example", (*) => AhkTest.AssertTrue(true), { Source: duplicate_source_stepwise_first_source })
duplicate_source_stepwise_first_suite.Test("duplicate example", (*) => AhkTest.Fail("second source failure"), { Source: duplicate_source_stepwise_second_source })
duplicate_source_stepwise_first_suite.Test("after example", (*) => AhkTest.AssertTrue(true), { Source: duplicate_source_stepwise_third_source })
duplicate_source_stepwise_second_suite.Test("duplicate example", (*) => AhkTest.Fail("first source should stay deselected"), { Source: duplicate_source_stepwise_first_source })
duplicate_source_stepwise_second_suite.Test("duplicate example", (*) => AhkTest.AssertTrue(true), { Source: duplicate_source_stepwise_second_source })
duplicate_source_stepwise_second_suite.Test("after example", (*) => AhkTest.Fail("after resumed failure"), { Source: duplicate_source_stepwise_third_source })
try {
    duplicate_source_stepwise_first_result := duplicate_source_stepwise_first_suite.Run({ Quiet: true, Stepwise: true, StepwiseCache: duplicate_source_stepwise_cache })
    duplicate_source_stepwise_second_result := duplicate_source_stepwise_second_suite.Run({ Quiet: true, Stepwise: true, StepwiseCache: duplicate_source_stepwise_cache })
    AhkTest.AssertEqual(2, duplicate_source_stepwise_first_result.Total)
    AhkTest.AssertEqual(2, duplicate_source_stepwise_second_result.Total)
    AhkTest.AssertEqual(1, duplicate_source_stepwise_second_result.Deselected)
    AhkTest.AssertEqual("b_duplicate.test.ahk", duplicate_source_stepwise_second_result.Entries[1].Source.File)
    AhkTest.AssertEqual("c_after.test.ahk", duplicate_source_stepwise_second_result.Entries[2].Source.File)
} finally {
    if FileExist(duplicate_source_stepwise_cache)
        FileDelete duplicate_source_stepwise_cache
}

collection_error_suite := AhkTest.CreateSuite("collection error example")
collection_error_suite.Collect(AhkTestExampleBrokenCollectedCase)
collection_error_result := collection_error_suite.Run({ Quiet: true })
AhkTest.AssertEqual(1, collection_error_result.Errors)
AhkTest.AssertEqual(2, collection_error_result.ExitCode)
AhkTest.AssertEqual("AhkTestCollectionError", Type(collection_error_result.Entries[1].Error))
AhkTest.AssertEqual("collection failure", collection_error_result.Entries[1].Error.Message)
AhkTest.AssertContains("collected test is not callable", collection_error_result.Entries[1].Error.Extra)

example_temp := AhkTest.TempDir("ahktest-example")
try {
    example_file := example_temp.File("data.txt", "payload")
    AhkTest.AssertEqual("payload", FileRead(example_file, "UTF-8"))
} finally {
    example_temp.Cleanup()
}

example_result := AhkTest.Run({ Quiet: true })

if example_result.ExitCode != 0
    throw Error("ahktest example failed", -1)

ahktest_example_raise()
{
    throw ValueError("example", -1)
}

ahktest_example_assert_dynamic_fixture_names(ctx)
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

ahktest_example_stepwise_maybe_fail(&shouldFail)
{
    if shouldFail
        AhkTest.Fail("cached failure")
}

ahktest_example_write_utf8_raw(path, text)
{
    if FileExist(path)
        FileDelete path
    FileAppend text, path, "UTF-8-RAW"
}

class AhkTestExampleBrokenCollectedCase
{
    static TestBroken := 1
}
