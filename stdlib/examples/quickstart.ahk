#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>

quickstart_result := AhkTest.AreEqual(["stdlib", "bootstrap"], ["stdlib", "bootstrap"])

; This quickstart tracks the reset stdlib bootstrap surface. As modules are
; promoted to direct, expand this file using only <stdlib\...> includes.
