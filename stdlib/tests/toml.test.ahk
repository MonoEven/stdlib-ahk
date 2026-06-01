#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\toml>

class StdlibTomlTest
{
    static TestTomlDocumentUsesStdlibModuleNamespace()
    {
        doc := stdlib.toml.Toml().read("name = `"codex`"`nscore = 7")

        AhkTest.AssertEqual("Toml", Type(doc))
        AhkTest.AssertEqual("codex", doc.getString("name"))
        AhkTest.AssertEqual(7, doc.getLong("score"))
    }
}

AhkTest.Collect(StdlibTomlTest)
