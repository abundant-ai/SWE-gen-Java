Retrofit previously exposed a RequestInterceptor which many users relied on to mutate outgoing requests globally (e.g., adding headers, adding query parameters, changing the path, or adding POST form parameters). This PR removes that interceptor in favor of OkHttp interceptors, but the migration must preserve key behaviors and address two common use cases that were awkward or impossible before.

1) No-value query parameters
Users need to build URLs containing a query key with no value, e.g.

http://example.com/foo?bon=bom&bar

When defining an endpoint method that includes a query parameter for such a “flag” key, Retrofit should be able to emit `&bar` (with no `=` and no value) when requested. Today, supplying something like an empty string or null either omits the parameter entirely or produces `bar=` which is not equivalent for some servers.

The request-building logic should support generating a query parameter that has a name only. This should work for normal GET requests and when query parameters are supplied via `@Query` or `@QueryMap`.

2) Global request mutation without RequestInterceptor
After removing RequestInterceptor, there must be a supported way to apply cross-cutting request changes using OkHttp’s `Interceptor` API:
- Add or replace headers on every request.
- Add query parameters to every request.
- Modify the request path.

In addition, some users previously attempted to add POST parameters from the interceptor to avoid repeating `@Field` declarations. With RequestInterceptor removed, Retrofit should have a clear, consistent behavior for form-encoded requests: request bodies built from `@FormUrlEncoded` + `@Field` / `@FieldMap` must remain correct and should not be broken by the new interception approach (for example, ensuring the form body is still encoded as expected and request construction doesn’t prevent interception from working).

Expected behavior:
- It must be possible to create a request whose URL contains a query parameter key with no value (no trailing `=`) when the caller indicates that intent.
- Replacing RequestInterceptor with OkHttp interceptors must not regress request building: HTTP method selection, URL construction, and handling of form/multipart encodings should behave as before.

Actual behavior to fix:
- There is no reliable way to produce a no-value query parameter like `&bar` using the standard query parameter annotations; attempts result in omission or `bar=`.
- Removal of RequestInterceptor risks breaking existing patterns for adding headers/query/path modifications globally; the new interceptor-based approach must fully support these request mutations.