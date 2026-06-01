#Requires AutoHotkey v2.0

#Include <stdlib\getpass>

getpass_example_saved_username := EnvGet("USERNAME")
EnvSet("LOGNAME", "")
EnvSet("USER", "")
EnvSet("LNAME", "")
EnvSet("USERNAME", "example_user")
try {
    MsgBox "getuser=" stdlib.getpass.getuser()
} finally {
    EnvSet("USERNAME", getpass_example_saved_username)
}
