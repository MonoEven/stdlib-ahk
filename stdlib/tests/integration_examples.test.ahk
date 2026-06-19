#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>

class StdlibIntegrationExamplesTest
{
    static TestDataPipelineExampleRunsAcrossCommonModules()
    {
        repoRoot := StdlibIntegrationExamplesTest.RepoRoot()
        examplePath := repoRoot "\stdlib\examples\data_pipeline.ahk"
        AhkTest.AssertTrue(FileExist(examplePath), "missing data_pipeline.ahk")

        script := FileRead(examplePath, "UTF-8")
        StdlibIntegrationExamplesTest.AssertNoPopupOrRegexPollution(script, "data_pipeline.ahk")
        for needle in [
            "#Include <stdlib\base64>",
            "#Include <stdlib\collections>",
            "#Include <stdlib\csv>",
            "#Include <stdlib\hashlib>",
            "#Include <stdlib\hmac>",
            "#Include <stdlib\json>",
            "#Include <stdlib\logging>",
            "#Include <stdlib\pathlib>",
            "#Include <stdlib\shutil>",
            "#Include <stdlib\statistics>",
            "#Include <stdlib\tempfile>",
            "#Include <stdlib\textwrap>",
            "stdlib.csv.DictWriter",
            "stdlib.csv.DictReader",
            "stdlib.collections.Counter",
            "stdlib.statistics.mean",
            "stdlib.json.dumps",
            "stdlib.hashlib.sha256",
            "stdlib.hmac.new",
            "stdlib.base64.urlsafe_b64encode",
            "stdlib.shutil.copy2"
        ]
            AhkTest.AssertContains(needle, script, "data_pipeline.ahk")

        result := AhkTest.CaptureFixture().RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", examplePath], { WorkingDir: repoRoot, TimeoutSeconds: 90 })
        diagnostic := "exit=" result.ExitCode " stdout=" result.Out " stderr=" result.Err
        AhkTest.AssertEqual(0, result.ExitCode, diagnostic)
        AhkTest.AssertEqual("", result.Err, diagnostic)

        for needle in [
            "stdlib-data-pipeline-ok",
            "orders=6 paid=4",
            "top_region=west:3",
            "paid_mean=44.00 median=39.50 stdev=13.09",
            "report_sha256=d83a4dc5a6bb0a27a473473d872f86bc6f53276f0f89de6188764496adeff467",
            "signature_b64=ywBFDX57cfGFlj9d8dR6jcVeu_93I3Hi4-j98Hl7FI4=",
            "archive_exists=true",
            "log=INFO:loaded 6 orders | WARNING:cancelled order A104"
        ]
            AhkTest.AssertContains(needle, result.Out, diagnostic)
    }

    static TestDataPipelineExampleBenchmarkModeRunsSamePipeline()
    {
        repoRoot := StdlibIntegrationExamplesTest.RepoRoot()
        examplePath := repoRoot "\stdlib\examples\data_pipeline.ahk"
        AhkTest.AssertTrue(FileExist(examplePath), "missing data_pipeline.ahk")

        result := AhkTest.CaptureFixture().RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", examplePath, "--bench", "3"], { WorkingDir: repoRoot, TimeoutSeconds: 90 })
        diagnostic := "exit=" result.ExitCode " stdout=" result.Out " stderr=" result.Err
        AhkTest.AssertEqual(0, result.ExitCode, diagnostic)
        AhkTest.AssertEqual("", result.Err, diagnostic)
        AhkTest.AssertContains("stdlib-data-pipeline-benchmark", result.Out, diagnostic)
        AhkTest.AssertContains("benchmark_iterations=3", result.Out, diagnostic)
        AhkTest.AssertContains("report_sha256=d83a4dc5a6bb0a27a473473d872f86bc6f53276f0f89de6188764496adeff467", result.Out, diagnostic)
        AhkTest.AssertContains("signature_b64=ywBFDX57cfGFlj9d8dR6jcVeu_93I3Hi4-j98Hl7FI4=", result.Out, diagnostic)
        AhkTest.AssertContains("avg_ms=", result.Out, diagnostic)
    }

    static AssertNoPopupOrRegexPollution(text, label)
    {
        pollutedNamespace := "System.Text." "RegularExpressions"
        pollutedEvaluator := "Match" "Evaluator"
        popupCommand := "Msg" "Box"
        AhkTest.AssertFalse(InStr(text, popupCommand) > 0, label)
        AhkTest.AssertFalse(InStr(text, pollutedNamespace) > 0, label)
        AhkTest.AssertFalse(InStr(text, pollutedEvaluator) > 0, label)
    }

    static RepoRoot()
    {
        SplitPath A_LineFile, , &testsDir
        SplitPath testsDir, , &stdlibDir
        SplitPath stdlibDir, , &repoRoot
        return repoRoot
    }
}

AhkTest.Collect(StdlibIntegrationExamplesTest)
