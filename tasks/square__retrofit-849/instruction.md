Retrofit’s request building does not consistently honor “already encoded” values specified via parameter annotations. When users mark an argument as already URL-encoded (e.g., an encoded path segment, query parameter, form field, or multipart part name/value), the request builder should treat that value as pre-encoded and must not apply additional encoding or normalization that changes the bytes on the wire.

Currently, behavior differs depending on which annotation is used, and in some cases an “encoded” value is still being encoded again (or handled differently than another annotation that also supports encoded values). This leads to requests whose URL or body differs from what the caller intended when they explicitly indicated the value was pre-encoded.

Update request construction so that specifying encoded values via parameter annotations is normalized and consistent across all supported annotations that accept name/value pairs (such as those used for URL paths, query parameters, form-encoded fields, and multipart parts). If a parameter is declared as encoded, the final generated request must include the provided value exactly as-is in the relevant location (URL path, query string, form body, or multipart body), rather than percent-encoding it again.

Reproduction example (illustrative):

- Given a method like:
  - `@GET("/search")`
  - `Response method(@Query(value = "q", encoded = true) String q)`
- When calling it with `q = "a%2Fb"`, the outgoing URL should contain `q=a%2Fb` and not `q=a%252Fb`.

Similarly for encoded path parameters:

- Given `@GET("/item/{id}")` with `@Path(value = "id", encoded = true) String id`
- When called with `id = "foo%2Fbar"`, the resulting path should be `/item/foo%2Fbar` and not `/item/foo%252Fbar`.

The same “no double-encoding” expectation applies to other parameter annotations that support an `encoded` flag, including map variants (e.g., query maps and field maps). Mixed usage (some encoded, some not) should still work: non-encoded parameters should be encoded as usual, while encoded ones must be passed through unchanged.

If encoded values are not allowed for a particular usage, Retrofit should fail fast with a clear `IllegalArgumentException` that identifies the method and parameter causing the issue, rather than silently producing a malformed request.