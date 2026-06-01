#Requires AutoHotkey v2.0

#Include <stdlib\json>

json_example_data := stdlib.json.loads("{`"name`":`"stdlib`",`"items`":[1,true,null]}")
json_example_name := json_example_data["name"]
json_example_text := stdlib.json.dumps(Map(
    "name", json_example_name,
    "ok", stdlib.True,
    "null", stdlib.json.Null
))
