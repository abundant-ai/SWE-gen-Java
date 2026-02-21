When using Moshi’s Okio-based JSON APIs, parsing can consume more bytes from the upstream stream than the caller expects. This is problematic when JSON is embedded in a larger stream/protocol (for example: JSON followed by additional framed data), because after decoding a single JSON value the caller expects the underlying stream to be positioned immediately after that value. Currently, constructing a JSON reader around an Okio stream may buffer and read ahead beyond the end of the JSON value, making subsequent reads from the same stream observe missing/consumed bytes.

Fix the Okio integration so Moshi never buffers more than necessary for the JSON value being read. In particular:

- Update the JsonReader API so callers can provide and retain control of the buffering layer rather than Moshi implicitly buffering. The JsonReader constructor should accept an Okio BufferedSource (not just a raw Source), so the caller decides how buffering is done and can share the same BufferedSource with other protocol parsing.
- Ensure any JsonAdapter Okio overloads (reading/writing) work correctly with Okio streams while respecting this rule: decoding a value must not consume bytes beyond the JSON value being decoded.
- Writing should similarly expose an Okio Sink type in a way that allows callers to control buffering/streaming when emitting JSON.

After the change, it should be possible to:

1) Create a BufferedSource that contains a JSON value followed by extra bytes.
2) Decode exactly one value via Moshi (either directly via JsonReader or via a JsonAdapter overload).
3) Verify that the extra bytes are still present and readable from the same BufferedSource immediately after decoding.

If the JSON is the literal null and lenient mode is enabled, calling JsonAdapter.toJson(JsonWriter, null) must emit the string "null", and JsonAdapter.fromJson(JsonReader) must return null, without consuming any trailing non-JSON bytes.

The public API should make Sink/BufferedSource usage explicit via constructor/overload signatures so callers can supply their own Okio BufferedSource/Sink and avoid unintended buffering behavior.