The CIO server engine does not reliably perform a graceful shutdown when `stopSuspend(gracePeriodMillis, timeoutMillis)` is invoked while there are in-flight requests.

A reproducible case is a handler that delays before responding (for example, `GET /` delays ~100ms and then responds with `"OK"`). If a client starts such a request and, shortly after (for example ~20ms later), the application calls `CIOApplicationEngine.stopSuspend(gracePeriodMillis = 10_000, timeoutMillis = 20_000)`, the request can be cancelled as part of shutdown and the client never receives the expected response body.

Expected behavior: calling `stopSuspend()` should stop accepting new connections, but allow already accepted connections and their request-handling coroutines to complete within the configured grace/timeout window. In the scenario above, the client request that was already in progress should still complete and receive the full response body `"OK"`.

Actual behavior: shutdown cancels server jobs in a way that immediately cancels request handling in the connection scope, causing the in-flight request to be aborted during shutdown.

Fix the CIO engine shutdown flow so that stopping the accept loop does not immediately cancel in-flight request processing. In particular, ensure the server waits for active request jobs to complete (up to the configured time limits) rather than cancelling them immediately as part of shutdown.