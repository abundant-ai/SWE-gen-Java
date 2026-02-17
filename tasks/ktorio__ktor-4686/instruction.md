Multipart request/response handling has two related correctness issues affecting Ktor’s form/multipart processing.

1) Quoted multipart boundary parameter is not parsed correctly
When handling a multipart Content-Type header whose boundary parameter is quoted, multipart parsing can fail while processing the preamble. For example, a header like:

`Content-Type: multipart/form-data; boundary="some-boundary"`

should be accepted, and the boundary value should be interpreted as `some-boundary` (without quotes). Currently, parsing can throw an exception during multipart processing because the boundary is treated incorrectly.

The expected behavior is that Content-Type parsing properly supports quoted parameter values and multiple parameters in the header. In particular, using `ContentType.parse(String)` on such a header should yield a `ContentType` whose parameters contain a usable `boundary` value, and multipart/form-data processing should succeed with quoted boundaries.

2) Copying a kotlinx-io `Source` is broken in multipart/form-data building/reading
Ktor’s multipart/form-data implementation needs to copy data from a `Source` (and similar streaming inputs) reliably. Currently, the copying logic can behave incorrectly because it relies on `remaining` in places where stream exhaustion should be detected via `exhausted()`. This can lead to truncated output, incorrect boundary framing, or failures when sources are consumed/peeked during multipart processing.

The expected behavior is that multipart content generation and consumption work correctly for a variety of data parts, including:
- Empty channels/sources (must still produce correct multipart framing with the right CRLF placement)
- String and numeric parts (must produce correct `Content-Length` and body formatting)
- Streaming parts where size may be known or unknown

Additionally, copying a `Source` should not consume the original in a way that breaks subsequent reads; the copy operation should use a non-destructive approach (e.g., behavior equivalent to copying via `Source.peek()`), and loops that transfer bytes should terminate based on actual exhaustion rather than an unreliable `remaining` value.

After fixing these issues, multipart/form-data content should serialize deterministically with correct boundaries and headers, and multipart parsing should accept quoted boundary parameters without throwing.