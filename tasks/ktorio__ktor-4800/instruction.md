`CountedByteWriteChannel` does not respect `autoFlush` when the wrapped/source channel is configured to auto-flush. This breaks expected behavior in networking and streaming scenarios where callers rely on automatic flushing to make data visible to readers without explicitly calling `flush()`.

When a write channel is wrapped in a `CountedByteWriteChannel`, setting `autoFlush = true` on the underlying channel should make the counted wrapper auto-flushing as well (and vice versa if the wrapper is the surface API). Currently, `autoFlush` can be ignored because the wrapper relies on casting the underlying channel to a specific implementation type (such as `ByteChannel`) to access `autoFlush`. That cast is not valid for some channel implementations due to the inheritance hierarchy, so the wrapper fails to propagate the setting and behaves as if `autoFlush` is false.

The bug shows up as writes not being delivered until an explicit `flush()`/`flushAndClose()` happens, and can lead to hanging reads in client/server socket interactions that expect data to be flushed automatically.

Fix the channel API/implementation so that `autoFlush` is available at a level that all relevant write-channel implementations can access, and ensure `CountedByteWriteChannel` correctly forwards `autoFlush` semantics to the underlying channel without relying on an unsafe cast. After the change:

- If `autoFlush` is enabled on the source/wrapped channel, writing through `CountedByteWriteChannel` must flush automatically.
- Enabling/disabling `autoFlush` through the counted wrapper must affect the underlying channel’s flushing behavior.
- Network echo scenarios using `openWriteChannel()` should not require explicit `flush()` to prevent the peer from blocking on reads when `autoFlush` is enabled.
- Closing/flushing behavior must not leave server-side resources open in a way that causes coroutine-based socket tests to hang (server connections and server sockets should be closed cleanly after use).