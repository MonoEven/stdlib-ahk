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
