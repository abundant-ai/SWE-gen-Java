Base64 helper functions in Ktor currently have ambiguous decoding behavior: they may accept both the standard Base64 alphabet (using "+" and "/") and the URL-safe Base64 alphabet (using "-" and "_") in the same decoding API. This ambiguity can lead to incorrect interoperability expectations and also to the original reported problem: decoding should be strict and should fail for strings that are not valid Base64 rather than silently accepting/producing unexpected results.

Update Ktor’s Base64 utilities so that decoding is strict and the alphabet is well-defined.

The public helpers involved include:
- `ByteArray.encodeBase64(): String`
- `String.decodeBase64Bytes(): ByteArray`

The expected behavior is:
- `ByteArray(3).encodeBase64()` must produce the standard Base64 encoding and return `"AAAA"`.
- Decoding `"AAAA"` must return a `ByteArray(3)`.
- Decoding must be strict: when `String.decodeBase64Bytes()` (or any newly introduced strict decoding API it delegates to) is given a non-Base64 string, it must throw an error rather than accepting it.
- The decoding behavior must not be ambiguous across alphabets. Either:
  1) Provide separate decoding functions for standard vs URL-safe Base64 (and ensure the default helper has clearly defined behavior), or
  2) Define `decodeBase64Bytes()` to try strict standard decoding first and, only if that fails due to alphabet mismatch, try strict URL-safe decoding; however, it must still fail for inputs that are not valid Base64 at all.

Additionally, the previously ambiguous Base64 encode/decode helpers should be deprecated in favor of the new, clearly-defined behavior (while keeping existing code working where possible).