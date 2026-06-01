#Requires AutoHotkey v2.0

#Include <stdlib\comparser>

comparser_example_config := stdlib.comparser.loads("# sample`nhost = localhost`nport = 8080")
comparser_example_text := stdlib.comparser.dumps(Map("host", comparser_example_config["host"], "port", comparser_example_config["port"]))
