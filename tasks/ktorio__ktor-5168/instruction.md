OkHttp client engine currently does not support true duplex streaming: when sending a streaming request body (for example, a `ByteChannel` used as the request body), the engine effectively waits for the request body to be fully consumed/sent before the response can be read. This prevents interleaving where the client writes some bytes, flushes, and then immediately reads response bytes produced by the server.

Implement duplex streaming support controlled by an engine setting `duplexStreamingEnabled`.

When `duplexStreamingEnabled = true` and the call is made over an HTTP/2-capable OkHttp configuration, a request with a streaming body must allow request and response to progress concurrently. In particular, the following interaction should work:

- Create a `ByteChannel` and set it as the request body (for example via `setBody(channel)` while preparing a POST).
- Start executing the request and obtain the response body as a channel (for example via `HttpResponse.bodyAsChannel()`).
- Repeatedly write a line to the request body channel and `flush()` it, then immediately read a line from the response channel.

Expected behavior: each client write+flush is promptly observable on the server, and the client can read corresponding response lines without having to close the request body first. This enables a sequence like writing three lines and reading three responses in an interleaved fashion, producing output equivalent to:

```
server: client: 0
server: client: 1
server: client: 2
```

Actual behavior (before the change): the response read blocks until the request body is fully written/closed, or the server does not receive incremental data as it is flushed.

Additionally, when duplex streaming is enabled, exceptions occurring during request-body streaming must propagate to the executing call rather than being lost or leaving the call hanging. If the request streaming fails (for example due to an I/O error or cancellation while writing), the request execution should complete with an exception visible to the caller (e.g., the `execute { ... }` block should fail with that exception or a wrapped equivalent), and resources should be cleaned up.

The implementation must ensure OkHttp is instructed to use duplex mode for streaming request bodies, and that the write side of the streaming body does not block returning/consuming the response. Channel flush behavior should be preserved so that `flush()` on the request body channel results in timely network writes rather than buffering until completion.