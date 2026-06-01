#Requires AutoHotkey v2.0

#Include <stdlib\toml>

toml_example_data := stdlib.toml.loads("name = `"stdlib`"`n[features]`ntext = true")
toml_example_name := toml_example_data["name"]
toml_example_text := stdlib.toml.dumps(Map("name", toml_example_name, "items", ["toml", "json"]))
