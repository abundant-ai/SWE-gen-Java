The CIO HTTP client engine can crash with a NumberFormatException when it receives an HTTP response whose Content-Length header value is malformed (for example, it contains embedded NUL bytes like "10\u0000"). This happens during response processing when the engine attempts to parse Content-Length as a Long using a strict conversion.

When using the CIO engine, making a request to a server that returns an invalid Content-Length should not crash the client with NumberFormatException. Instead, the engine should treat an unparseable Content-Length as “unknown length” and then decide how to read the body based on other response framing signals:

- If Content-Length is invalid/unparseable and the response is not chunked, but the server indicates Connection: close, the client should read the response body until EOF and complete successfully.
- If Content-Length is invalid/unparseable, the response is not chunked, and the server indicates Connection: keep-alive (or otherwise keeps the connection open), the client must fail the call rather than hanging or attempting to read until EOF. The failure should be a controlled client error (not NumberFormatException).

Expected behavior: requests using CIO do not throw NumberFormatException when the Content-Length header contains invalid characters/bytes; they either (a) successfully read to EOF for Connection: close, or (b) fail deterministically for keep-alive without chunked encoding and without a valid Content-Length.

Actual behavior: the client throws NumberFormatException while parsing Content-Length, causing the call to fail even in cases where Connection: close would allow safely reading until EOF.

Reproduction example (server behavior): return an HTTP/1.1 response with a Content-Length header that cannot be parsed as a number (e.g., contains a NUL byte) and a normal body. The CIO engine should not crash during header parsing; it should apply the rules above for reading the body.