Configuring a Unix domain socket via the HTTP client’s DefaultRequest plugin currently doesn’t reliably apply to requests unless the unixSocket(...) option is set on each individual request.

When a client is created with:

```kotlin
val client = HttpClient(CIO) {
    defaultRequest {
        unixSocket("/tmp/test.sock/")
    }
}
```

and then a request is made without explicitly setting unixSocket in the request builder, the client should connect through the configured Unix domain socket and successfully reach a server bound to that socket. Instead, the request attempts a normal TCP connection (or otherwise fails to use the Unix-socket connector), causing the request to fail or to hit the wrong endpoint.

Implement support for applying unixSocket(...) (and related default request configuration) when it is set inside the DefaultRequest plugin block, so that it becomes the effective default for all requests unless overridden per-request.

Expected behavior:
- If DefaultRequest config sets `unixSocket("/path/to.sock/")`, then `client.get("http://localhost/test")` should use that Unix socket automatically.
- A per-request override like:

```kotlin
client.get("http://localhost/custom") {
    unixSocket("/other.sock/")
}
```

should take precedence over the DefaultRequest setting.
- Requests should return successful HTTP responses (e.g., 200) from routes served over the Unix socket, and response bodies should match the server responses.

Actual behavior:
- The DefaultRequest unixSocket configuration is ignored (or not propagated to the engine), so requests don’t use the Unix socket unless unixSocket(...) is specified directly in the request builder.

The fix should introduce/adjust the DefaultRequest plugin extension so that `defaultRequest { unixSocket(...) }` correctly propagates into the request’s effective configuration used by the CIO engine.