#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>

class StdlibTkinterExamplesTest
{
    static TestTkinterGuiExampleRunsThroughCapture()
    {
        repoRoot := StdlibTkinterExamplesTest.RepoRoot()
        examplePath := repoRoot "\stdlib\examples\tkinter_gui.ahk"
        markerPath := A_Temp "\stdlib-tkinter-gui-example-" A_TickCount "-" Random(100000, 999999) ".marker"
        script := FileRead(examplePath, "UTF-8")

        StdlibTkinterExamplesTest.AssertNoRegexReplacementPollution(script, "tkinter_gui.ahk")
        for needle in [
            "root.mainloop()",
            "--capture",
            "stdlib.tkinter.StringVar",
            "stdlib.tkinter.DoubleVar",
            "stdlib.tkinter.ttk.Style",
            "stdlib.tkinter.ttk.Entry",
            "stdlib.tkinter.ttk.Combobox",
            "stdlib.tkinter.ttk.Scale",
            "stdlib.tkinter.ttk.Progressbar",
            "stdlib.tkinter.ttk.Treeview",
            "stdlib.tkinter.ttk.Notebook",
            "stdlib.tkinter.Canvas",
            "command: refresh_dashboard"
        ]
            AhkTest.AssertContains(needle, script, "tkinter_gui.ahk")

        try {
            try FileDelete markerPath
            result := AhkTest.CaptureFixture().RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", examplePath, "--capture", markerPath], { WorkingDir: repoRoot, TimeoutSeconds: 90 })
            diagnostic := "exit=" result.ExitCode " stdout=" result.Out " stderr=" result.Err
            AhkTest.AssertEqual(0, result.ExitCode, diagnostic)
            AhkTest.AssertEqual("", result.Err, diagnostic)
            AhkTest.AssertTrue(FileExist(markerPath), diagnostic)
            AhkTest.AssertContains("tkinter-gui-example-ok", FileRead(markerPath, "UTF-8"), diagnostic)
        } finally {
            try FileDelete markerPath
        }
    }

    static TestReadmeTkinterExamplesRunAndStayFocused()
    {
        repoRoot := StdlibTkinterExamplesTest.RepoRoot()
        for readmeName in ["README.en.md", "README.zh-CN.md"] {
            readmePath := repoRoot "\" readmeName
            text := FileRead(readmePath, "UTF-8")
            StdlibTkinterExamplesTest.AssertNoRegexReplacementPollution(text, readmeName)
            script := StdlibTkinterExamplesTest.ExtractTkinterBlock(text)
            StdlibTkinterExamplesTest.AssertNoRegexReplacementPollution(script, readmeName)
            StdlibTkinterExamplesTest.AssertReadmeTkinterFeatureSet(script, readmeName)

            lineCount := StrSplit(Trim(script, "`r`n"), "`n").Length
            AhkTest.AssertTrue(lineCount <= 135, readmeName " tkinter example is too long: " lineCount " lines")
            AhkTest.AssertFalse(InStr(script, "theme_create") > 0, readmeName)
            AhkTest.AssertFalse(InStr(script, "element_create") > 0, readmeName)

            script := StrReplace(script, "#Include <stdlib\tkinter>", "#Include `"" repoRoot "\stdlib\tkinter.ahk`"")
            script := StrReplace(script, "root.mainloop()", "root.after(100, (*) => root.destroy())`nroot.mainloop()")
            scriptPath := A_Temp "\stdlib-readme-tkinter-" StrReplace(readmeName, ".", "-") "-" A_TickCount "-" Random(100000, 999999) ".ahk"
            try {
                FileAppend script, scriptPath, "UTF-8"
                result := AhkTest.CaptureFixture().RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", scriptPath], { WorkingDir: repoRoot, TimeoutSeconds: 90 })
            } finally {
                try FileDelete scriptPath
            }
            diagnostic := readmeName " exit=" result.ExitCode " stdout=" result.Out " stderr=" result.Err
            AhkTest.AssertEqual(0, result.ExitCode, diagnostic)
            AhkTest.AssertEqual("", result.Err, diagnostic)
        }
    }

    static AssertReadmeTkinterFeatureSet(script, label)
    {
        for needle in [
            "root.mainloop()",
            "stdlib.tkinter.StringVar",
            "stdlib.tkinter.DoubleVar",
            "stdlib.tkinter.ttk.Style",
            "stdlib.tkinter.ttk.Entry",
            "stdlib.tkinter.ttk.Combobox",
            "stdlib.tkinter.ttk.Scale",
            "stdlib.tkinter.ttk.Progressbar",
            "stdlib.tkinter.ttk.Treeview",
            "stdlib.tkinter.ttk.Notebook",
            "stdlib.tkinter.Canvas",
            "stdlib.tkinter.ttk.Button",
            "command: update_demo",
            ".grid("
        ]
            AhkTest.AssertContains(needle, script, label)
    }

    static AssertNoRegexReplacementPollution(text, label)
    {
        pollutedNamespace := "System.Text." "RegularExpressions"
        pollutedEvaluator := "Match" "Evaluator"
        AhkTest.AssertFalse(InStr(text, pollutedNamespace) > 0, label)
        AhkTest.AssertFalse(InStr(text, pollutedEvaluator) > 0, label)
    }

    static ExtractTkinterBlock(text)
    {
        marker := "#Include <stdlib\tkinter>"
        markerPos := InStr(text, marker)
        if markerPos = 0
            AhkTest.Fail("missing tkinter include")
        fence := Chr(96) Chr(96) Chr(96)
        blockStart := 0
        searchPos := 1
        loop {
            candidate := InStr(text, fence "ahk", false, searchPos)
            if candidate = 0 || candidate > markerPos
                break
            blockStart := candidate
            searchPos := candidate + 1
        }
        blockEnd := InStr(text, fence, false, markerPos + StrLen(marker))
        if blockStart = 0 || blockEnd = 0
            AhkTest.Fail("missing tkinter ahk block")
        contentStart := InStr(text, "`n", false, blockStart) + 1
        return SubStr(text, contentStart, blockEnd - contentStart)
    }

    static RepoRoot()
    {
        SplitPath A_LineFile, , &testsDir
        SplitPath testsDir, , &stdlibDir
        SplitPath stdlibDir, , &repoRoot
        return repoRoot
    }
}

AhkTest.Collect(StdlibTkinterExamplesTest)
