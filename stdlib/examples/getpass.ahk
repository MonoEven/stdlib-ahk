#Requires AutoHotkey v2.0

#Include <stdlib\getpass>

getpass_example_saved_username := EnvGet("USERNAME")
EnvSet("LOGNAME", "")
EnvSet("USER", "")
EnvSet("LNAME", "")
EnvSet("USERNAME", "example_user")
try {
    getpass_example_output := "getuser=" stdlib.getpass.getuser()
    FileAppend getpass_example_output "`n", "*", "UTF-8"
} finally {
    EnvSet("USERNAME", getpass_example_saved_username)
}
