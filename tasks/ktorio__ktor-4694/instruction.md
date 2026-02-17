Canceling an SSE session by canceling collection of `SSESession.incoming` does not reliably disconnect the underlying connection when using the OkHttp-based SSE implementation.

In particular, when a client creates a session via `HttpClient.serverSentEventsSession(...)` and starts collecting `session.incoming`, canceling the collection (or otherwise stopping collection early, e.g. by using `take(1)` / `single()` and then canceling) should close the SSE session and disconnect the network connection. With the OkHttp SSE session, canceling the incoming flow may only cancel the consumer coroutine while leaving the underlying OkHttp `EventSource` running, so the server-sent-events connection remains open.

The behavior should match the default client SSE implementation: stopping/canceling consumption of `SSESession.incoming` must result in the session being disconnected and the session should not keep receiving/holding resources after the consumer stops.

Implement the fix so that:
- `OkHttpSSESession.incoming` behaves as a stable stream for the lifetime of the session (repeated reads of the `incoming` property must refer to the same logical flow, not a new flow instance each time).
- Canceling the collection of `incoming` causes the underlying session to close (including canceling the OkHttp `EventSource`) and the stream should complete.
- If event delivery from OkHttp into the session fails due to `CancellationException` while handling `onEvent(...)`, that cancellation must propagate in a way that triggers normal session shutdown (so `onFailure(...)`/`onClosed(...)` can close the incoming stream and cancel the underlying event source), rather than being swallowed and leaving the connection open.

Example scenario that must work: create a session with `val session = client.serverSentEventsSession(url)`, collect only the first event from `session.incoming` (e.g., via `single()`), then stop collecting and cancel/close the session; the SSE connection must be terminated promptly rather than continuing to stay connected in the background.