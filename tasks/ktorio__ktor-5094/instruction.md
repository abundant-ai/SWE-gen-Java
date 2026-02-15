When using the Ktor HTTP client with the Apache5 engine, configuring connection pooling currently requires users to create and set a custom Apache `ConnectionManager` via `customizeClient { setConnectionManager(...) }`. Doing this replaces the connection manager that Ktor configures internally, which can silently break Ktor features that rely on that manager. A common symptom is that installing `HttpTimeout` has no effect (for example, `socketTimeoutMillis` is ignored), because the custom connection manager overrides Ktor’s managed configuration.

Add a new engine configuration API `Apache5EngineConfig.configureConnectionManager { ... }` that lets users tune the Apache connection manager (pool sizes, default connection config, etc.) without replacing the Ktor-managed connection manager.

Expected behavior:
- A user should be able to write:
  ```kotlin
  HttpClient(Apache5) {
      engine {
          configureConnectionManager {
              setMaxConnPerRoute(1_000)
              setMaxConnTotal(2_000)
          }
      }
      install(HttpTimeout) {
          socketTimeoutMillis = 1000
      }
  }
  ```
  and `HttpTimeout` must still be applied. In a streaming response that does not send data for longer than the socket timeout, the request should fail with a `ClosedByteChannelException` whose root cause is a `SocketTimeoutException`.

- If the user configures an explicit socket timeout at the Apache connection-manager level (for example via `setDefaultConnectionConfig(ConnectionConfig.custom().setSocketTimeout(Timeout.ofMilliseconds(10000)).build())` inside `configureConnectionManager { ... }`), that engine-level socket timeout should override the `HttpTimeout` plugin’s `socketTimeoutMillis`. In that case, a request that waits ~2 seconds for the first SSE line should still succeed and return the first expected line (e.g. `"data: hello"`) rather than timing out.

Actual behavior to fix:
- Today, achieving pool configuration requires setting a new `ConnectionManager`, which overrides Ktor’s managed one and causes Ktor plugin timeouts (notably `HttpTimeout`) to be ignored.

Implement `configureConnectionManager` so that it configures the internally managed Apache5 connection manager builder/instance instead of replacing it, while preserving the precedence rules described above (explicit engine connection config timeout overrides `HttpTimeout`; otherwise `HttpTimeout` is honored).