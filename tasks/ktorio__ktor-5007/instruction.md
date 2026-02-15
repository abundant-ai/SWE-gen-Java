The server ShutdownUrl plugin has been unable to shut down the server since Ktor 3.2.0 due to a deadlock introduced by structured concurrency changes. When the shutdown endpoint is called, the plugin launches the shutdown coroutine on the application’s coroutine context and then waits for that same context to complete (join), which can block forever and prevent the shutdown from finishing.

Fix the ShutdownUrl plugin so that calling the configured shutdown URL reliably initiates shutdown without deadlocking, even when there are active requests running.

Expected behavior:
- When `ShutDownUrl.ApplicationCallPlugin` is installed with `shutDownUrl = "/shutdown"`, a request to `/shutdown` must respond with HTTP 410 Gone.
- The plugin must call the configured `exit` callback with the value returned by `exitCodeSupplier`.
  - Example: if `exitCodeSupplier = { 42 }`, then `exit(42)` must be invoked.
- If `exitCodeSupplier` throws an exception, shutdown should still proceed and `exit` must be called with exit code `1`.
  - Example: if `exitCodeSupplier = { throw IllegalStateException("Something went wrong") }`, then `exit(1)` must be invoked.
- Shutdown must work under load: if multiple slow requests are in-flight when `/shutdown` is called, the shutdown should complete promptly and any jobs associated with those in-flight requests should be canceled (i.e., those request coroutines should not remain active after shutdown completes).

Actual behavior (current regression):
- Calling the shutdown URL can hang indefinitely and not trigger `exit`, because the shutdown coroutine is launched in a way that waits on the application context that it is itself running on, causing a deadlock.