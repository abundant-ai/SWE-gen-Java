Reading from a ByteReadChannel is unacceptably slow in workloads that rely on delimiter-based scanning (notably multipart parsing when the request body has no Content-Length). The slowdown is especially severe when using operations that effectively read/scan one byte at a time.

When processing large streams, using delimiter-based reads (via the internal/exposed readUntil-style behavior used by higher-level consumers) can take tens of seconds per gigabyte, which makes receiving multipart bodies without Content-Length extremely slow. Separately, single-byte operations on ByteChannel/ByteReadChannel (for example repeated readByte() calls) are much slower than expected and add significant overhead.

The byte channel implementation should be optimized so that:

- Delimiter-based scanning (the readUntil behavior) does not copy/read bytes sequentially one-by-one when it can avoid it. It should efficiently locate delimiters in buffered data and transfer data in bulk.
- Single-byte reads such as ByteReadChannel.readByte() should not perform redundant state checks on every call; repeated single-byte operations should be materially faster.

Expected behavior: Reading large multipart bodies without Content-Length should complete in a reasonable amount of time (seconds rather than tens of seconds per gigabyte), and repeated ByteChannel/ByteReadChannel single-byte operations should not be disproportionately expensive.

Actual behavior: Multipart processing without Content-Length and other delimiter-heavy reading patterns are extremely slow; repeated readByte()-style usage is also significantly slower than it should be.

Ensure that core ByteReadChannel operations still behave correctly while improving performance, including scenarios like reading large packets, reading remaining content after close, throwing IOException when reading from a cancelled channel, correctly reading fully into arrays with offsets/limits, and correctly skipping a delimiter sequence when present (e.g., skipIfFound(delimiter) returning true and leaving subsequent bytes available to read).