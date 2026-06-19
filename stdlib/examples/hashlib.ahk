#Requires AutoHotkey v2.0

#Include <stdlib\hashlib>

hashlib_example_md5 := stdlib.hashlib.md5()
hashlib_example_bytes := Buffer(3, 0)
StrPut("abc", hashlib_example_bytes, "UTF-8")
hashlib_example_md5_update_result := hashlib_example_md5.update(hashlib_example_bytes)
hashlib_example_md5_hex := hashlib_example_md5.hexdigest()
hashlib_example_md5_digest_bytes := []
for index in [0, 1, 2, 3]
    hashlib_example_md5_digest_bytes.Push(NumGet(hashlib_example_md5.digest(), index, "UChar"))
hashlib_example_sha1_hex := stdlib.hashlib.new("sha1", hashlib_example_bytes).hexdigest()
hashlib_example_sha256_hex := stdlib.hashlib.sha256(hashlib_example_bytes).hexdigest()
hashlib_example_sha3_hex := stdlib.hashlib.sha3_256(hashlib_example_bytes).hexdigest()
hashlib_example_shake_hex := stdlib.hashlib.shake_128(hashlib_example_bytes).hexdigest(16)
hashlib_example_blake2s_hex := stdlib.hashlib.blake2s(hashlib_example_bytes, { key: StdlibHashlibExampleBytes("secret") }).hexdigest()
hashlib_example_pbkdf2 := stdlib.hashlib.pbkdf2_hmac("sha256", StdlibHashlibExampleBytes("pw"), StdlibHashlibExampleBytes("salt"), 1000, 16)
hashlib_example_pbkdf2_hex := StdlibHashlibExampleHex(hashlib_example_pbkdf2)
hashlib_example_scrypt := stdlib.hashlib.scrypt(StdlibHashlibExampleBytes("password"), { salt: StdlibHashlibExampleBytes("NaCl"), n: 2, r: 1, p: 1, dklen: 16 })
hashlib_example_scrypt_hex := StdlibHashlibExampleHex(hashlib_example_scrypt)
hashlib_example_copy := hashlib_example_md5.copy()
hashlib_example_d_bytes := Buffer(1, 0)
StrPut("d", hashlib_example_d_bytes, "UTF-8")
hashlib_example_copy_update_result := hashlib_example_copy.update(hashlib_example_d_bytes)
hashlib_example_copy_hex := hashlib_example_copy.hexdigest()
hashlib_example_algorithms_guaranteed := stdlib.hashlib.algorithms_guaranteed
hashlib_example_bad_algorithm_error := ""
try {
    stdlib.hashlib.new("crc32")
} catch ValueError as err {
    hashlib_example_bad_algorithm_error := err.Message
}
hashlib_example_string_input_error := ""
try {
    stdlib.hashlib.md5("abc")
} catch TypeError as err {
    hashlib_example_string_input_error := err.Message
}

StdlibHashlibExampleBytes(text)
{
    size := StrPut(text, "UTF-8") - 1
    bytes := Buffer(size, 0)
    if size > 0
        StrPut(text, bytes, "UTF-8")
    return bytes
}

StdlibHashlibExampleHex(bytes)
{
    text := ""
    loop bytes.Size
        text .= Format("{:02x}", NumGet(bytes, A_Index - 1, "UChar"))
    return text
}
