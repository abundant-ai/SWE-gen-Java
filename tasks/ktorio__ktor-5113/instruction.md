Ktor’s header API currently treats a header field-line containing comma-separated values as a single value. For headers that are semantically lists, this is incorrect: a header like `X-Multi-Header: Value1, Value2` should be exposed as two values, not one.

When working with request/response headers, calling `Headers.getSplitValues(name)` on a list-like header should return a list of individual values split on commas, with surrounding whitespace trimmed. For example, given `X-Multi-Header: Value1, Value2`, `getSplitValues("X-Multi-Header")` should return `listOf("Value1", "Value2")` and the size should be `2`.

This splitting must be done correctly with HTTP quoting rules: commas inside quoted strings must not be treated as delimiters. Additionally, if the same header appears across multiple field-lines, the resulting list must be flattened across all occurrences (i.e., values from each line are combined into a single list in order).

At the same time, known single-value or special-case headers must not be altered by this behavior. For such headers, Ktor should preserve existing semantics so that a single header value remains a single value rather than being split.

The bug shows up in both server-side request headers and server/client response headers: when a client sends `X-Multi-Header: Value1, Value2` and the server responds with the same header value, `getSplitValues("X-Multi-Header")` should produce identical two-element lists for both the request headers and the response headers.

Implement or adjust the relevant header parsing logic so that list-type headers are split on commas outside quotes, combined across multiple header lines, and accessible via `Headers.getSplitValues(name)` as described, while leaving special single-value headers untouched.