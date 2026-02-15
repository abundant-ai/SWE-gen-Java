When using the Ktor HTTP client with the `HttpRequestRetry` plugin configured for a retry count larger than 20, requests can fail with `SendCountExceedException` even though the retry configuration is valid.

This happens because the `HttpSend` plugin enforces its own `maxSendCount` limit (default 20) independently of `HttpRequestRetry.maxRetries`. If a user configures `HttpRequestRetry { maxRetries = N }` (or an equivalent retry configuration that results in more than 20 send attempts), the retry loop can exceed `HttpSend`’s default limit and throw `SendCountExceedException` before the retry policy completes.

Reproduction example:
```kotlin
val client = HttpClient(MockEngine) {
    engine {
        // return server errors enough times to trigger many retries
    }
    install(HttpRequestRetry) {
        // configure retries so that total attempts can exceed 20
        // e.g., retryOnServerErrors(25)
        delay { }
    }
}

client.get("/")
```

Expected behavior: configuring `HttpRequestRetry` for more than 20 retries should not fail due to `HttpSend`’s default `maxSendCount`. The request should be allowed to perform up to the configured retry limit (plus the initial attempt), and succeed or fail according to the retry policy.

Actual behavior: after 20 send attempts, the client throws `SendCountExceedException` coming from the `HttpSend` plugin, preventing `HttpRequestRetry` from applying the configured number of retries.

Fix required: ensure that when `HttpRequestRetry` is installed and configured with a retry limit that implies more send attempts than `HttpSend`’s default, the effective send-attempt limit used by `HttpSend` is adjusted to accommodate the retry configuration (i.e., `HttpSend` should not cap attempts below what `HttpRequestRetry.maxRetries` requires when retries are configured). User-provided `HttpSend { maxSendCount = ... }` configuration should still be respected if explicitly set.