MockWebServer’s MockResponse currently models its response body exclusively as an okio.Buffer. This is too limiting for newer response behaviors (notably duplex responses) and causes incorrect behavior when features like throttling and mid-body disconnect policies are used, because those features assume the body is always a Buffer that can be inspected/replayed.

Introduce a dedicated response-body abstraction named MockResponseBody and update MockResponse (and the server code that writes responses) to use it instead of assuming a Buffer-backed body.

The updated MockResponse must still support existing ways of setting the body (for example, setting a String or Buffer as the response body) but internally it should be represented as a MockResponseBody so that:

- Throttling works correctly even when the response body is not inherently a Buffer. When a response is configured with throttling (bytes per period), the server should emit the response body gradually according to the throttle configuration rather than writing the whole body at once or failing due to missing Buffer operations.

- Disconnect-during-body socket policies behave correctly without requiring the body to be a Buffer. In particular, when the response is configured to disconnect at the end (or to disconnect during the body), the connection should close at the correct point relative to how many response-body bytes have been emitted, and this must continue to work under throttling.

- Duplex responses are supported. When MockResponse is configured for duplex (request and response bodies can be exchanged concurrently), the response body must be able to stream without requiring it to be fully buffered up front, and it must interoperate correctly with throttling and disconnect policies.

Existing behavior that must remain correct:

- A default MockResponse (constructed via MockResponse.Builder()) should still have the same default status line, headers, and empty body semantics as before.

- If a Content-Length is implied/required by the configured body, it should remain consistent with the bytes actually sent. If the response is configured in a way that streams without a known length, the server must behave consistently with that configuration (for example, not claiming a fixed Content-Length while streaming an indeterminate body).

Reproduction scenario (what currently breaks): configure a MockWebServer dispatcher to return a MockResponse that (a) uses duplex mode or otherwise cannot be represented as a prebuilt Buffer, and (b) applies throttling and/or a disconnect-at-end/during-body socket policy. Requests made with OkHttp (including HTTP/2 cases) should receive the throttled/streamed bytes and observe the disconnect behavior at the correct time. Currently, these configurations either don’t throttle properly, don’t disconnect at the right moment, or otherwise mis-handle the response body because it’s assumed to be a Buffer.

Implement MockResponseBody and update the relevant MockResponse APIs and response-writing pipeline so that the above scenarios work reliably across HTTP/1.1 and HTTP/2.