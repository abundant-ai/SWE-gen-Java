When using `CountedByteWriteChannel`, enabling `autoFlush` on the underlying write channel does not make the counted wrapper auto-flush. As a result, small writes can remain buffered until an explicit `flush()`/close occurs, which can cause protocols/tests relying on immediate delivery to stall.

This shows up when a socket’s `openWriteChannel()` is wrapped (directly or indirectly) by `CountedByteWriteChannel`: setting `autoFlush = true` on the original channel is expected to make subsequent `write*` operations flush automatically, but with the counted wrapper the flush never happens unless the caller explicitly flushes.

The root cause is that the counted wrapper cannot reliably access the `autoFlush` property of its delegate due to the current type/inheritance layout (it attempts to reach `autoFlush` via casts that fail for some channel implementations), so the wrapper never observes that auto-flush is enabled.

Fix `CountedByteWriteChannel` so that `autoFlush` is properly supported and propagated/observed across implementations: if `autoFlush` is enabled on the underlying write channel (or enabled via the wrapper), writes through the counted channel should auto-flush consistently, without requiring implementation-specific casts.

Additionally, ensure that TCP socket usage involving repeated accepts and echoing data does not leave the server side running indefinitely: after serving requests, the server and connections should be closed in a way that prevents hanging behavior on JS/Wasm (for example, when a background accept loop is used, it must be terminable and the server must be closed so the test run can finish).

Expected behavior: wrapping a write channel with `CountedByteWriteChannel` must not change flushing semantics—`autoFlush` should work the same as with the original channel, and socket-based echo scenarios should complete without deadlocks/hangs once the client/server are done.

Actual behavior: `autoFlush` on the source channel is ignored once wrapped by `CountedByteWriteChannel`, and a socket-based scenario can hang because the server is not fully shut down.