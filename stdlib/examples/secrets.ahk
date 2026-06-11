#Requires AutoHotkey v2.0

#Include <stdlib\secrets>

picked := stdlib.secrets.choice(["red", "green", "blue"])
belowTen := stdlib.secrets.randbelow(10)
token := stdlib.secrets.token_hex(8)
sameText := stdlib.secrets.compare_digest("alpha", "alpha")
sameBytes := stdlib.secrets.compare_digest(StdlibSecretsExampleBytes("abc"), StdlibSecretsExampleBytes("abc"))

secrets_example_output := "choice=" picked
    . "`nrandbelow(10)=" belowTen
    . "`ntoken_hex(8)=" token
    . "`ncompare text=" (sameText ? "yes" : "no")
    . "`ncompare bytes=" (sameBytes ? "yes" : "no")
FileAppend secrets_example_output "`n", "*", "UTF-8"

StdlibSecretsExampleBytes(text)
{
    size := StrPut(text, "UTF-8") - 1
    bytes := Buffer(size, 0)
    if size > 0
        StrPut(text, bytes, "UTF-8")
    return bytes
}
