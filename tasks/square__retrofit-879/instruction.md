Retrofit currently carries a converter/serialization mechanism along with a `Response` even when the HTTP call fails (non-2xx). This mirrors older `RetrofitError` behavior, but it is problematic because Retrofit cannot guarantee the format of an error body, and conversion semantics only make sense for successful responses. As a result, error `Response` objects expose conversion-related state that should not be present and can mislead callers into thinking error bodies are safely deserializable.

Update Retrofit so that when creating or emitting an error `Response` (e.g., via `Response.fromError(int, ResponseBody)` or when a server returns a non-success HTTP status), the `Response` does not include or retain any converter instance. The error `Response` must still retain the raw `ResponseBody` for callers who want to parse it themselves using their own converter.

Expected behavior:
- For successful HTTP responses, `Response` continues to behave as before: `response.isSuccess()` is true and `response.body()` returns the deserialized body.
- For non-2xx HTTP responses, the call should be treated as an error case when adapted to `Observable<T>`: subscribing and attempting to read the first item should terminate with an exception rather than yielding a body value.
- For `Observable<Response<T>>`, both success and non-success HTTP responses should be delivered as `Response` values, but error responses must not carry a converter; only the raw error body should be available.

If a consumer wants to deserialize an error body, they must supply their own converter and read from the `ResponseBody` already present on the `Response`, rather than relying on any converter stored inside the `Response`.