WebSocket clients created via Micronaut’s HTTP client currently always install per-message deflate compression using Netty’s default `WebSocketClientCompressionHandler`, which results in significant CPU usage for applications handling many concurrent WebSocket connections (especially for binary payloads on high-bandwidth, CPU-constrained environments). There is no supported way to turn off this compression for the client.

When a user configures the HTTP client with the property `micronaut.http.client.ws.compression.enabled=false`, WebSocket clients should not negotiate/use the per-message deflate extension. The default must remain enabled to preserve existing behavior.

This needs to work both for the global/default `HttpClientConfiguration` and for service-specific client configuration (e.g. under `micronaut.http.services.<service-name>...`) where a service can provide its own WebSocket compression settings. `HttpClientConfiguration` must expose a `getWebSocketCompressionConfiguration()` (with an `enabled` flag) such that reading `config.getWebSocketCompressionConfiguration().isEnabled()` reflects the configured value.

Currently, even after setting the configuration property to disable compression, the WebSocket client pipeline still enables compression (or the configuration object does not reflect the property). Update the WebSocket client setup so that when `HttpClientConfiguration.WebSocketCompressionConfiguration#isEnabled()` is `false`, the client does not add/enable the Netty per-message deflate handler and therefore does not perform deflate/inflate work.

Expected behavior:
- With no configuration, WebSocket per-message deflate remains enabled (backwards compatible).
- With `micronaut.http.client.ws.compression.enabled=false`, the client-side WebSocket compression configuration reports disabled and the WebSocket client does not enable per-message deflate.
- The same property works when applied to a named service HTTP client configuration (`micronaut.http.services.<name>.ws.compression.enabled=false`) and when using a custom `HttpClientConfiguration` subclass that receives a `DefaultHttpClientConfiguration.DefaultWebSocketCompressionConfiguration` instance.

Actual behavior:
- Client WebSocket compression cannot be reliably disabled; per-message deflate is still applied or the configuration does not bind/propagate correctly, causing unnecessary CPU usage.

Implement the missing configuration plumbing and ensure `DefaultHttpClient` honors the `enabled` flag when configuring WebSocket compression.