OkHttp 5.0.0-alpha.12 can pin Java virtual threads when a call releases a connection back to the connection pool. This happens because code holding an intrinsic monitor (a `synchronized` block) calls into scheduling/cleanup logic that uses a `ReentrantLock` (for example via `TaskQueue.schedule(...)`). With `-Djdk.tracePinnedThreads=full`, users can observe pinned-thread stack traces showing `ReentrantLock.lock()` being attempted while a monitor is held, with the stack including:

- `TaskQueue.schedule(...)`
- `RealConnectionPool.connectionBecameIdle(...)`
- `RealCall.callDone(...)` / `RealCall.releaseConnectionNoEvents$okhttp(...)`

The locking strategy for call/connection lifecycle code needs to be made Loom-safe and internally consistent. Specifically, critical sections that currently use `synchronized` and also interact with code paths that may block or take `ReentrantLock`s must be migrated so they do not rely on intrinsic monitors. In the same areas, any use of `wait()`/`notify()` on monitors must be replaced with the equivalent `Condition.await()`/`Condition.signal()` on the same `ReentrantLock` that guards that state.

Currently, there are still places where intrinsic locking (`synchronized` + `wait/notify`) and `ReentrantLock`-based locking are mixed while protecting the same state. That mix can cause incorrect synchronization (splitting the lock so threads don’t actually coordinate) and can also trigger virtual thread pinning when a monitor is held during operations that contend on `ReentrantLock`.

Fix the call/connection/pool synchronization so that:

- The state that coordinates `RealCall`, `RealConnection`, and connection pooling is guarded by a Loom-safe lock consistently (do not split a single logical lock across `synchronized` and `ReentrantLock`).
- Any blocking waits used for coordination in these components use `Condition.await()` and `Condition.signal()` (or `signalAll()` where appropriate) rather than `wait()`/`notify()`.
- Completing a call and releasing/transitioning a connection to idle (via `RealCall.callDone(...)` and `RealCall.releaseConnectionNoEvents$okhttp(...)` leading into `RealConnectionPool.connectionBecameIdle(...)`) must not pin virtual threads under contention.
- Connection pool cleanup scheduling (including scenarios involving idle-connection limits such as `maxIdleConnections`) must work correctly without deadlocks, missed signals, or race conditions.

After the change, running OkHttp with virtual threads under load should no longer report pinned threads in the above call-release/connection-idle path, and the connection pool should still evict idle connections and maintain correct connection counts and reuse behavior.