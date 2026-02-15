OkHttp-based SSE requests don’t reliably use the common SSE session implementation and can leak the underlying OkHttp connection when the SSE coroutine is cancelled. Historically the OkHttp engine had its own SSE session type (OkHttpSSESession), but that implementation has diverged from the default SSE behavior and does not support newer SSE functionality consistently.

When using the SSE client plugin with the OkHttp engine, creating an SSE session should use the same session behavior as other engines (the default client SSE session implementation). In addition, cancelling an SSE request after the connection is established must fully close/cancel the underlying HTTP call so that OkHttp doesn’t keep an idle connection around.

Reproduction scenario:

- Create an OkHttpClient instance and pass it as a preconfigured engine client.
- Create an HttpClient(OkHttp) and install the SSE plugin.
- Start an SSE request to an endpoint that emits multiple events over time (for example, a URL like `/sse/hello?times=20&interval=100`).
- Once the SSE session is open, cancel the coroutine/job that initiated the request.
- Either (a) start collecting `incoming` until completion, or (b) never read from `incoming` and just wait briefly.

Expected behavior:

- The SSE session created for OkHttp behaves like the default client SSE session used by other engines.
- Cancelling the request cancels the SSE session and closes the underlying OkHttp call/response body.
- After cancellation completes, evicting OkHttp idle connections (via `connectionPool.evictAll()`) should leave the connection pool empty (connection count equals 0).

Actual behavior:

- OkHttp uses an OkHttp-specific SSE session rather than the default shared SSE session, leading to inconsistent behavior across engines.
- Cancelling an SSE request can leave the underlying OkHttp connection open/idle, so the connection pool still reports active/idle connections even after the request coroutine and the call coroutine complete.

Implement the fix so that OkHttp SSE sessions are created as the default client SSE session (not an OkHttp-specific session), and ensure cancellation properly propagates to and closes the underlying OkHttp connection even if the client cancels immediately after connecting and regardless of whether `incoming` is being collected.