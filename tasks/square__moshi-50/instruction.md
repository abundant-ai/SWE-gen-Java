Moshi’s exception types are currently inconsistent when decoding/encoding values that are structurally valid JSON but don’t match the expected Java/Kotlin type. In these mismatch cases, Moshi sometimes throws an IllegalStateException (or another non-JsonDataException) even though the JSON is well-formed and the caller is using the API correctly.

The library should use these exception categories consistently:

When the application code is internally inconsistent (for example, using a JsonReader/JsonWriter after it has been closed, or otherwise violating the reader/writer state machine), the API should throw IllegalStateException.

When the input JSON is structurally invalid (for example, malformed JSON like an unquoted string in strict mode), parsing should throw an IOException.

When the JSON is well-formed and the application code is correct, but the JSON’s value does not match what the adapter expects (type mismatch, unexpected token, null where not allowed, etc.), Moshi should throw JsonDataException.

Fix Moshi so that type/token mismatch scenarios consistently throw JsonDataException across adapters and reader operations. For example, when using a primitive adapter such as moshi.adapter(boolean.class).lenient() and calling adapter.fromJson("null"), it must throw JsonDataException with the message:

"Expected a boolean but was NULL at path $"

More generally, any operation that reports “Expected X but was Y at path …” due to a mismatched JSON token/value must raise JsonDataException (not IllegalStateException), while malformed JSON remains IOException and invalid API usage remains IllegalStateException.