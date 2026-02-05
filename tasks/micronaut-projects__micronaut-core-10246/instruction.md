The Netty HTTP server should correctly handle compressed HTTP request bodies when request pipelining is enabled, but currently requests with a Content-Encoding (e.g., gzip/deflate/snappy) are not decompressed within the pipelined request handling path.

When a client sends a request whose body is compressed and includes a supported Content-Encoding header, the server should transparently decompress the inbound HttpContent before the request body is made available to routing/controllers. This decompression should occur in the pipelined request handler itself (the class responsible for handling pipelined HTTP requests), rather than requiring a separate Netty HttpContentDecompressor in the pipeline.

Currently, with pipelining enabled, sending a compressed request can result in the application receiving compressed bytes (or failing to parse/consume the body correctly) because the pipelined handler does not apply the same decompression logic as the standard Netty decompressor.

Implement decompression support in the server’s PipeliningServerHandler so that:
- Supported encodings include at least gzip, deflate (zlib), and snappy.
- The handler recognizes the request’s Content-Encoding, wraps/decodes inbound HttpContent appropriately, and passes decompressed content downstream.
- After decompression, request processing should behave as if the client had sent the uncompressed body: controllers reading the body should see the original uncompressed bytes.
- For requests without Content-Encoding (uncompressed requests), there should be effectively no performance regression (i.e., avoid unnecessary buffering/decoding work).

A practical way to validate the behavior is: if a controller returns random bytes and a client requests a compressed response using Accept-Encoding (gzip/deflate/snappy), the response bytes should be correctly decodable back to the original payload; similarly, if a client sends a compressed request body with Content-Encoding, the server should see the original uncompressed content.

Ensure the pipelined handler matches the semantics of Netty’s HttpContentDecompressor for supported encodings, including correct handling of streaming/chunked HttpContent.