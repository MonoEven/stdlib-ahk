#Requires AutoHotkey v2.0

#Include <stdlib\uuid>

fixed := stdlib.uuid.UUID("12345678-1234-5678-1234-567812345678")
generated := stdlib.uuid.uuid4()

uuid_example_output := "fixed=" String(fixed)
    . "`nhex=" fixed.hex
    . "`nurn=" fixed.urn
    . "`nvariant=" fixed.variant
    . "`nversion=" (fixed.version = stdlib.None ? "None" : fixed.version)
    . "`n`ngenerated=" String(generated)
    . "`nrepr=" generated.__Repr()
FileAppend uuid_example_output "`n", "*", "UTF-8"
