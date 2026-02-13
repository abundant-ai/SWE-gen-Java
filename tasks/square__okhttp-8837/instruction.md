The MockWebServer API for constructing responses needs to be finalized so that `mockwebserver3.MockResponse` behaves as a stable value object with a builder, while preserving existing MockWebServer behavior used by OkHttp and URLConnection integrations.

Currently, creating and customizing responses via `MockResponse()` is not consistently compatible with the newer “value object + builder” design: some fields are not copied/retained correctly when a response is built or modified, and some previously-supported response customizations no longer affect what the server actually sends (status line, headers, body, and socket behavior). This causes downstream behavior differences in scenarios like HTTP/2 exchanges, URLConnection calls, and HTTPS/SNI-related requests.

Fix `mockwebserver3.MockResponse` so that:

- `MockResponse` is an immutable value object whose observable behavior is fully determined by its fields.
- There is a builder-based way to create and modify responses (for example, `MockResponse.Builder` or an equivalent API such as `newBuilder()`), and building a new instance must preserve all existing configuration from the original instance unless explicitly changed.
- Enqueuing a default `MockResponse()` must continue to produce a valid successful HTTP response that OkHttp clients can execute and treat as successful.
- Response configuration must reliably affect what the server sends, including:
  - status line / response code
  - headers (including multiple header values and header removal/overwrite semantics)
  - body and any body-related metadata used by the server
  - HTTP/2 features exposed by MockWebServer such as push promises (via `mockwebserver3.PushPromise`) when configured
  - socket policies (via `mockwebserver3.SocketPolicy`, such as `DisconnectAtEnd`, `NoResponse`, `ResetStreamAtStart`, `StallSocketAtStart`, etc.)
- The behavior must remain correct under HTTPS where the client uses a different hostname for the TLS handshake (SNI) versus the HTTP `Host` header (domain fronting style). Enqueuing a `MockResponse` must not interfere with the server’s ability to accept the connection, record the request, and expose handshake server names via `RecordedRequest.handshakeServerNames`.

In short: make the new MockResponse API (value object + builder) complete and consistent so that all previously supported response behaviors still work and modifications via the builder produce predictable, fully-applied responses when enqueued.