Static content responses currently don’t provide a straightforward way to participate in HTTP conditional requests based on resource versioning metadata. As a result, applications serving files/resources via Ktor’s static content helpers can’t easily attach an RFC 9110-compliant `ETag` header or a `Last-Modified` header that the `ConditionalHeaders` plugin can use to evaluate `If-None-Match` / `If-Modified-Since` and respond with `304 Not Modified` when appropriate.

Add support for configuring ETag and Last-Modified for static content via `StaticContentConfig` so users can do:

```kotlin
staticFiles("/static", filesDir) {
    etag { resource -> /* compute or fetch etag */ }
    lastModified { resource -> /* compute or fetch last modified */ }
}
```

When `ConditionalHeaders` is installed, static content responses must expose the configured ETag/Last-Modified values so that conditional requests work correctly. In particular, when a client sends `If-None-Match` matching the resource’s ETag, the server should return `304 Not Modified` and include the `ETag` header in the response.

Also add a predefined ETag provider that auto-generates a strong ETag from the resource contents using SHA-256, exposed as `ETagProvider.StrongSha256`, and allow a convenience configuration form:

```kotlin
staticFiles("/static", filesDir) {
    etag(ETagProvider.StrongSha256)
}
```

This provider must compute the ETag based on the SHA-256 digest of the served resource content, and the produced value must be a valid strong ETag for use with `EntityTagVersion`/`ETag` handling (including proper quoting in the actual HTTP header).

Expected behavior:
- Static resources can be configured to supply ETag and/or Last-Modified values.
- With `ConditionalHeaders` installed, requests without preconditions return `200 OK` and include the configured `ETag` (and `Last-Modified` if configured).
- With `If-None-Match` equal to the configured ETag, the response is `304 Not Modified` and includes `ETag`.
- The built-in `ETagProvider.StrongSha256` generates deterministic ETags based solely on file/resource content (same content => same ETag; changed content => different ETag).