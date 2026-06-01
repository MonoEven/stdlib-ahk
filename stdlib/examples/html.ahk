#Requires AutoHotkey v2.0

#Include <stdlib\html>

sample := "<tag>&" Chr(34) "'"
escaped := stdlib.html.escape(sample)
unescaped := stdlib.html.unescape("&lt;tag&gt;&amp;&#x27;&quot;")

MsgBox "escape=" escaped
    . "`nunescape=" unescaped
