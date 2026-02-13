Retrofit’s asynchronous callback API needs to be updated to use new method names. The existing `Callback<T>` interface currently exposes `success(...)` and `failure(...)` methods, but these should be renamed to `onSuccess(...)` and `onFailure(...)`.

After this change, any asynchronous execution path that notifies a `Callback` (including `Call.enqueue(Callback<T>)` and any call adapters/executors that dispatch callback events on an `Executor`) must invoke `onSuccess` when a response is successful and `onFailure` when the call fails due to an `IOException`, unexpected error, or cancellation.

Right now, code that expects the new callback names will fail to compile or will not receive callback events because Retrofit still calls `success()`/`failure()`. Update the callback interface and all internal call/adapter implementations so that:

- Implementations of `Callback<T>` override `onSuccess(Response<T> response, Retrofit retrofit)` (or the library’s equivalent success signature) instead of `success(...)`.
- Implementations of `Callback<T>` override `onFailure(Throwable t)` (or the library’s equivalent failure signature) instead of `failure(...)`.
- When an HTTP call completes successfully and produces a `Response<T>` (including non-2xx HTTP responses that are still delivered as a `Response` object), the callback is notified via `onSuccess(...)`.
- When a call cannot produce a response due to an error (e.g., network `IOException`), the callback is notified via `onFailure(...)`.
- Executor-based callback dispatch still runs the callback methods on the configured executor and does not introduce duplicate notifications or missed notifications.

The end result should be that user code written against `Callback.onSuccess()`/`Callback.onFailure()` works correctly for both synchronous-to-asynchronous adaptation and normal `enqueue` usage, without any remaining references to `success()`/`failure()` in the public API surface.