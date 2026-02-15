Stopping a Ktor server running on the Netty engine can intermittently throw/log a `java.util.concurrent.RejectedExecutionException` during shutdown (notably reproducible on macOS, and not limited to development mode). This happens due to a race in the engine stop sequence where some channel/connection work (such as closing channels or writing a response) is still being scheduled after the relevant Netty worker/event loop executors have already begun shutting down.

When calling `NettyApplicationEngine.stop(gracePeriodMillis, timeoutMillis)` on a running engine, shutdown must be ordered so that:

1) The server stops accepting new incoming connections before the worker groups are torn down (it should be possible for the server to use a quiet period of 0 for the connection pool so no new connections are accepted during shutdown).

2) Existing connections/channels are allowed to close cleanly, and the engine waits for connection shutdown and worker shutdown to complete before shutting down the call/event handling group used to execute request handling.

3) The engine must not attempt to write a response (or otherwise schedule channel work) once the underlying `Channel` is inactive/closed. In these cases, response writing should be skipped/aborted rather than triggering Netty to schedule tasks on an executor that is already shutting down.

4) If a request handler/call coroutine is associated with a channel pipeline handler, then when that handler is unregistered the corresponding call coroutine should be cancelled so that it does not continue executing and attempt to interact with an already-closed channel.

5) Calling `stop()` more than once must not cause additional shutdown sequences to run concurrently or repeatedly. Repeated calls should be idempotent (subsequent calls should be a no-op or otherwise safely handled) and must not introduce new `RejectedExecutionException` occurrences.

6) Any asynchronous shutdown operations must surface errors properly. If the engine awaits shutdown completion (for example by awaiting/syncing Netty futures), exceptions must not be silently ignored; failures should be observed and logged.

Expected behavior: Starting the engine (`start(wait = false)`) and stopping it (`stop(gracePeriodMillis, timeoutMillis)`) should reliably terminate Netty event loop groups without producing `RejectedExecutionException`, and configured event loop groups provided via `NettyApplicationEngine.Configuration.configureBootstrap` must be shut down gracefully using the provided grace/timeout values.

Actual behavior: Under load or specific timing (including on macOS), calling `stop()` can result in `RejectedExecutionException` originating from Netty attempting to schedule tasks on an event loop that is shutting down, and shutdown ordering can leave channels being closed/written after workers are already terminated.

Reproduction sketch:
- Start an `embeddedServer(Netty, port = 0) { ... }`.
- Perform at least one request (or have an in-flight response/write).
- Call `server.stop(gracePeriodMillis, timeoutMillis)` (and/or call it twice in quick succession).
- Observe intermittent `RejectedExecutionException` during shutdown and/or incomplete orderly shutdown.

Implement the corrected shutdown sequencing and safeguards described above in the Netty engine so that shutdown is deterministic and free of task rejections, while ensuring event loop groups are always terminated and configured groups are shutdown gracefully with the provided timeouts.