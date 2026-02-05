MockWebServer’s `SocketPolicy` currently models some policies as singletons/enum-like values, but several policies actually carry per-response parameters (for example, policies that need an HTTP/2 error code). Because these parameterized policies aren’t represented as distinct classes with stored state, MockWebServer can incorrectly treat different configurations as the “same” policy, or lose the parameter value when the policy is applied.

This shows up when a response is configured with socket policies like:

- `ResetStreamAtStart(<http2ErrorCodeInt>)` for HTTP/2, where the stream should be reset immediately using the provided HTTP/2 error code.
- `DoNotReadRequestBody(<http2ErrorCodeInt>)` (used when the server returns a response without consuming a long request body), where the server-side behavior should incorporate the provided error code and consistently trigger the client-side behavior expected for truncated/ignored request bodies.

Problem behavior: when these socket policies are used, the specific error code passed to the socket policy may be ignored, not preserved, or not applied consistently. This can cause clients to observe the wrong failure mode or message (for example, not failing with a reset-stream error that includes `REFUSED_STREAM`, or not behaving like the server stopped reading the request body under HTTP/2).

Expected behavior:

- Creating a `MockResponse(socketPolicy = ResetStreamAtStart(code))` must reliably reset the HTTP/2 stream at the start of the exchange using exactly the provided code. OkHttp should fail the call with an error that reflects the correct HTTP/2 reset reason (for example, a failure message like `stream was reset: REFUSED_STREAM` when the REFUSED_STREAM code is used).
- Creating a `MockResponse(socketPolicy = DoNotReadRequestBody(code))` must reliably simulate the server not consuming the request body (including on long/slow request bodies), while still allowing the response to be returned as configured. The behavior must be consistent between HTTP/1.1 and HTTP/2 modes where applicable, and the error-code parameter must not be dropped.
- Different instances of parameterized socket policies with different arguments must be treated as distinct configurations (no accidental equality/identity collisions), so that enqueued responses behave according to the parameters they were constructed with.

Implement/adjust `SocketPolicy` so that policies which require parameters are represented as proper classes/instances that retain those parameters, and ensure MockWebServer applies them correctly during connection/stream setup and request-body handling.