Shutting down an OkHttpClient’s dispatcher executor while many async calls are queued can crash the dispatcher thread with a StackOverflowError. This happens when a large number of enqueued calls exist (e.g., 10,000), and then `okhttp.dispatcher.executorService.shutdown()` is invoked. In this state, `RealCall.AsyncCall.executeOn(...)` can encounter a rejected task submission (because the executor is shutting down) and falls back to a recursive handling path that repeatedly triggers `Dispatcher.finished(...)` / `Dispatcher.promoteAndExecute(...)` in a way that grows the stack until it overflows.

Reproduction example:

```kotlin
val okhttp = OkHttpClient()
val callback = object : Callback {
  override fun onFailure(call: Call, e: IOException) {}
  override fun onResponse(call: Call, response: Response) { response.close() }
}
repeat(10_000) {
  okhttp.newCall(Request.Builder().url("https://example.com").build()).enqueue(callback)
}
okhttp.dispatcher.executorService.shutdown()
```

Actual behavior: the dispatcher thread may crash with an error like:

```
Exception in thread "OkHttp Dispatcher" java.lang.StackOverflowError
  at okhttp3.Dispatcher.promoteAndExecute(...)
  at okhttp3.Dispatcher.finished(...)
  at okhttp3.internal.connection.RealCall$AsyncCall.executeOn(...)
  ... repeated ...
```

Expected behavior: calling `Dispatcher.executorService.shutdown()` while there are hundreds/thousands of enqueued async calls should not cause recursion or a StackOverflowError. The client should handle executor rejection during shutdown gracefully: queued/running calls should be finished/cleaned up without unbounded recursive re-entry between `RealCall.AsyncCall.executeOn(...)` and `Dispatcher.finished(...)`/`Dispatcher.promoteAndExecute(...)`. The shutdown should complete without crashing the dispatcher thread.