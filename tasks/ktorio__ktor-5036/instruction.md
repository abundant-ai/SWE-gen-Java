Ktor’s Netty server engine should support HTTP/2 without TLS (h2c), but currently it only supports HTTP/2 when TLS is enabled (h2). When an application runs with the Netty engine and HTTP/2 is enabled, clients should be able to establish an h2c connection in both of the standard cleartext modes:

1) Cleartext upgrade from HTTP/1.1: if a client connects over plain TCP using HTTP/1.1 and sends a request including `Upgrade: h2c` (and the required HTTP/2 upgrade headers), the server should perform the HTTP/1.1 → HTTP/2 upgrade and continue handling the connection as HTTP/2.

2) Prior knowledge: if a client connects over plain TCP and immediately starts the connection with the HTTP/2 prior-knowledge preface (without sending an HTTP/1.1 request first), the server should detect this and handle the connection as HTTP/2.

At the same time, because HTTP/2 is enabled by default in the Netty engine configuration, the server must still correctly handle plain HTTP/1.1 connections that do not attempt an upgrade: an HTTP/1.1 request without `Upgrade: h2c` must continue to be served normally, rather than being misclassified or rejected due to HTTP/2 pipeline initialization.

Expected behavior:
- Starting a Netty server with HTTP/2 enabled should allow h2c connections (upgrade and prior-knowledge) over cleartext.
- Regular HTTP/1.1 requests over cleartext must still work when HTTP/2 is enabled.
- If HTTP/2 is explicitly disabled in configuration, the server must not negotiate or accept h2c; upgrade attempts should not switch the protocol to HTTP/2 and prior-knowledge prefaces should not be treated as valid HTTP/2 sessions.

Actual behavior to fix:
- h2c connections (either via `Upgrade: h2c` or prior knowledge) fail to negotiate and/or are handled as HTTP/1.1 only.
- Enabling HTTP/2 can break or mis-handle non-upgrade HTTP/1.1 cleartext connections because the pipeline doesn’t provide a correct HTTP/1.1 fallback path.

The fix should ensure Netty’s server pipeline initialization and configuration correctly support cleartext HTTP/2 negotiation while preserving HTTP/1.1 behavior, controlled by the existing Netty engine configuration flag that enables/disables HTTP/2.