Retrofit’s `Call` cancellation behavior is inconsistent depending on when `cancel()` is invoked. Calling `Call.cancel()` should be safe and effective at any time: before `execute()`, after `execute()` has started, before `enqueue(Callback)` is called, after `enqueue()` has started, and during response body streaming.

Currently, canceling at certain times can still allow the underlying HTTP request to be created or proceed, and can lead to callbacks being invoked as if the call were not canceled (or to other inconsistent outcomes). This is especially problematic for asynchronous calls and for streaming responses where the body read may block or continue even after cancellation.

Update the `Call` implementation so that:

- If `cancel()` is called before `execute()` or `enqueue(...)`, the call must not perform network I/O. A subsequent `execute()` should fail as a canceled call (throwing `IOException` consistent with cancellation), and a subsequent `enqueue(...)` should notify the callback with a failure consistent with cancellation.
- If `cancel()` is called while a synchronous `execute()` is in progress, the in-flight request must be canceled and `execute()` must terminate by throwing `IOException` reflecting cancellation.
- If `cancel()` is called while an asynchronous `enqueue(...)` is in progress, the in-flight request must be canceled and the callback must be notified via `onFailure` with an `IOException` reflecting cancellation (and must not later receive `onResponse`).
- Cancellation must also interrupt/abort streaming response consumption: if a call returning `ResponseBody` (including streaming usage) is canceled while the body is being read, the read should fail promptly with an `IOException` rather than continuing to read to completion.

The `Call.isCanceled()` state should accurately reflect whether cancellation has been requested, and cancellation should be idempotent (calling `cancel()` multiple times should not cause additional side effects or multiple callback invocations).