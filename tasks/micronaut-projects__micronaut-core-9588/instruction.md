When Micronaut is used as an API gateway with `ProxyHttpClient` (proxying requests to another Micronaut service), proxied HTTP/1.1 responses can end up with invalid or stale transfer headers. In particular, responses may include both `Content-Length` and `Transfer-Encoding` at the same time, which causes clients (e.g., Postman / some HTTP stacks) to fail parsing the response with an error like:

`Parse Error: "Content-Length" and "Transfer-Encoding" can't be present in the response headers together`

In addition to client-facing parse failures, the backend/server can log Netty and Micronaut errors that indicate the response/request lifecycle is getting corrupted, especially for larger payloads (reported around >150KiB). Observed errors include Netty reference-counting warnings such as:

`Failed to release a message: DefaultFullHttpResponse ... IllegalReferenceCountException: refCnt: 0, decrement: 1`

and Micronaut server pipeline errors like:

`java.lang.IllegalStateException: onComplete before request?` originating from `io.micronaut.http.server.netty.handler.PipeliningServerHandler$StreamingOutboundHandler.onComplete`.

The server must ensure it sends correct and mutually exclusive transfer headers for all responses, including proxied responses where the upstream service may have set one header and the proxying layer may have introduced the other (or left stale headers on the outbound response). The handling must be robust even when the response has been modified/rewritten by proxying.

Expected behavior: the final response written by the server must never contain both `Content-Length` and `Transfer-Encoding` simultaneously. If `Transfer-Encoding: chunked` is used, `Content-Length` must be absent. If a fixed `Content-Length` is used (e.g., for a fully-buffered small body like "foo"), `Transfer-Encoding` must be absent. This must hold for both direct controller responses and for responses produced by proxying via `ProxyHttpClient`, including cases where the upstream response explicitly sets one of these headers.

Reproduction scenario: run a Micronaut server that exposes endpoints returning small bodies with explicit `Content-Length` or explicit `Transfer-Encoding`, and also exposes proxy endpoints that forward to those endpoints using `ProxyHttpClient`. When requesting the proxied endpoints, the response must remain parseable by standard HTTP clients and must conform to the header rules above, rather than emitting both headers or leaving stale values.

Implement/adjust the logic in the Netty server outbound pipeline (notably `PipeliningServerHandler` and its outbound/streaming response handling) so that, except for special cases like file responses and intentionally chunked streaming, the server always overwrites/normalizes `Content-Length` and `Transfer-Encoding` based on the actual encoding strategy being used for the final outbound response, removing the conflicting header when necessary.