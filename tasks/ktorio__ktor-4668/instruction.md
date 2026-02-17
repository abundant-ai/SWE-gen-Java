Ktor’s CIO server currently treats a lone carriage return ("\r") as a valid HTTP line terminator in situations where the HTTP/1.1 specification requires CRLF ("\r\n"). This is observable when parsing chunked transfer encoding: the server may accept chunk-size lines (and related delimiters) that end with "\r" without a following "\n", instead of rejecting them as malformed.

When decoding chunked bodies via `decodeChunked(input: ByteReadChannel, output: ByteWriteChannel)` (or the equivalent CIO chunked decoder entry point), chunk headers and the empty line after the terminating `0\r\n` chunk must be delimited strictly by CRLF. If the input contains a chunk-size line terminated by a bare CR (e.g., `"3\r"` followed by chunk data) or any other request-line style delimiter that is `\r` not followed by `\n`, the decoder should fail rather than silently accepting it.

The line-reading utility used by the decoder (notably `readUTF8Line(...)`) needs to support enforcing the expected line ending. In particular, callers involved in HTTP parsing must be able to require CRLF and treat `\r` without `\n` as an error/EOF condition, rather than accepting it as a delimiter.

Expected behavior:
- Chunked decoding succeeds for well-formed inputs such as `"3\r\n123\r\n0\r\n\r\n"`, producing `"123"`.
- Chunked decoding rejects malformed inputs where `\r` is used alone as a line delimiter in chunked framing, raising an exception rather than producing output.
- Existing behavior for correctly terminated `\r\n` lines remains unchanged (including handling of trailing bytes after the chunked body, which should remain unread in the input channel).

Actual behavior:
- The CIO server accepts `\r` without a following `\n` as a valid line terminator in chunked transfer encoding, allowing malformed requests to be parsed as if they were valid.