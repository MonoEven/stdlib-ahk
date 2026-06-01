#Requires AutoHotkey v2.0

#Include <stdlib\warnings>

warnings_example_records := stdlib.warnings.catch_warnings(true).Call(warnings_example_emit)

warnings_example_emit(records)
{
    stdlib.warnings.simplefilter("always")
    stdlib.warnings.warn("deprecated", stdlib.warnings.DeprecationWarning, 1, "example")
}
