#Requires AutoHotkey v2.0

#Include <stdlib\hmac>

hmac_example_key := StdlibHmacExampleBytes("key")
hmac_example_message := StdlibHmacExampleBytes("message")

hmac_example_sha256 := stdlib.hmac.new(hmac_example_key, hmac_example_message, "sha256")
hmac_example_name := hmac_example_sha256.name
hmac_example_digest_size := hmac_example_sha256.digest_size
hmac_example_block_size := hmac_example_sha256.block_size
hmac_example_hex := hmac_example_sha256.hexdigest()

hmac_example_streamed := stdlib.hmac.new(hmac_example_key, , "sha256")
hmac_example_streamed.update(StdlibHmacExampleBytes("mes"))
hmac_example_copy := hmac_example_streamed.copy()
hmac_example_streamed.update(StdlibHmacExampleBytes("sage"))
hmac_example_copy.update(StdlibHmacExampleBytes("sage"))
hmac_example_copy_matches := stdlib.hmac.compare_digest(hmac_example_streamed.hexdigest(), hmac_example_copy.hexdigest())

hmac_example_digest := stdlib.hmac.digest(hmac_example_key, hmac_example_message, "sha1")
hmac_example_bytes_match := stdlib.hmac.compare_digest(hmac_example_digest, stdlib.hmac.new(hmac_example_key, hmac_example_message, "sha1").digest())

StdlibHmacExampleBytes(text)
{
    size := StrPut(text, "UTF-8") - 1
    bytes := Buffer(size, 0)
    if size > 0
        StrPut(text, bytes, "UTF-8")
    return bytes
}
