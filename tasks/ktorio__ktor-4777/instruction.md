Ktor server responses that are compressed based on the incoming `Accept-Encoding` request header are missing the correct `Vary` header handling.

When the server applies the `Compression` plugin and chooses a `Content-Encoding` based on the client’s `Accept-Encoding`, the response should include `Vary: Accept-Encoding` so that caches do not incorrectly reuse a compressed/uncompressed variant for different clients.

Currently, when requesting a route that returns text (for example via `call.respondText(...)`) with `Compression` installed:
- If the client sends `Accept-Encoding: gzip` and the response is actually compressed (e.g., `Content-Encoding: gzip`), the response may omit `Vary` entirely or not include `Accept-Encoding`.
- If the client does not send `Accept-Encoding`, or sends only unknown encodings that do not result in compression, the response should not add `Vary: Accept-Encoding` (because the selected representation did not vary by that header).

This also needs to work for static content when serving pre-compressed assets (for example via `staticResources { preCompressed(CompressedFileType.BROTLI) }`):
- A request without `Accept-Encoding` should not include a `Vary` header.
- A request with `Accept-Encoding: br` that results in serving the pre-compressed Brotli variant should include `Vary: Accept-Encoding`.

If a response already has a `Vary` header for other reasons, `Accept-Encoding` must be appended (not replace existing values), and duplicate `Accept-Encoding` entries must be avoided (case-insensitive).