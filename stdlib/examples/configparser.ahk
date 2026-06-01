#Requires AutoHotkey v2.0

#Include <stdlib\configparser>

configparser_example_parser := stdlib.configparser.ConfigParser()
configparser_example_parser.read_string("[DEFAULT]`nHost = localhost`nflag = yes`n[Server]`nPORT = 8080`nratio = 0.5`ninvalid_port = nope`n")
configparser_example_parser.set("Server", "User", "Ada")
configparser_example_parser.set("Server", "AliasPort", "8080")
configparser_example_sections := configparser_example_parser.sections()
configparser_example_host := configparser_example_parser.get("Server", "HOST")
configparser_example_default_host := configparser_example_parser.get("DEFAULT", "host")
configparser_example_port := configparser_example_parser.getint("Server", "port")
configparser_example_ratio := configparser_example_parser.getfloat("Server", "ratio")
configparser_example_invalid_port_text := configparser_example_parser.get("Server", "invalid_port")
configparser_example_flag := configparser_example_parser.getboolean("Server", "flag")
configparser_example_user := configparser_example_parser["Server"]["user"]
configparser_example_section_default_host := configparser_example_parser["Server"]["host"]
configparser_example_section_items := configparser_example_parser["Server"].items()
configparser_example_section_keys := configparser_example_parser["Server"].keys()
configparser_example_section_values := configparser_example_parser["Server"].values()
configparser_example_alias_port := configparser_example_parser.get("Server", "aliasport")
configparser_example_items := configparser_example_parser.items("Server")
configparser_example_options := configparser_example_parser.options("Server")
configparser_example_default_items := configparser_example_parser.items("DEFAULT")
configparser_example_removed_default_host := configparser_example_parser.remove_option("DEFAULT", "host")
configparser_example_has_host := configparser_example_parser.has_option("Server", "HOST")
configparser_example_has_missing := configparser_example_parser.has_option("Server", "missing")
configparser_example_has_missing_section := configparser_example_parser.has_option("Missing", "host")
