Retrofit currently defers selecting the response-body Converter until a call is actually executed (or otherwise adapted), rather than resolving it when the service method is parsed. This late lookup can cause inconsistent or surprising behavior: some service method definitions appear to be accepted during `Retrofit.create(...)`, but only fail later at runtime when the response converter is needed. Converter-related errors should be detected deterministically during method parsing so that invalid service methods fail fast.

When creating a service via `Retrofit.create(Service.class)`, Retrofit should resolve the response converter for each method’s declared response type as part of parsing that method (i.e., when building the internal method metadata). If no suitable converter exists for the response type, `Retrofit.create(...)` (or the first attempt to reflectively parse that method) should throw an `IllegalArgumentException` immediately, rather than allowing the service to be created and failing later.

This especially matters for methods like:
- `@GET("/") Call<String> wrongClass()` when the configured `Converter.Factory` cannot convert the declared response type.
- `@GET("/") Call<List<String>> wrongType()` when a converter supports a raw type (e.g., some message class) but not parameterized types like `List<String>`.

The thrown `IllegalArgumentException` should clearly indicate that Retrofit was unable to create a converter for the method’s response type (including the problematic `Type`), and it should occur during method parsing/service creation. Existing valid cases must continue to work, including:
- Request body type resolution for `@Body` parameters (concrete, generic, and wildcard types) reflected in `MethodInfo.requestType`.
- Normal serialization/deserialization using a working converter factory (e.g., a factory that can convert a `Phone` type to/from the HTTP body).

In short: move response `Converter` lookup to happen during method parsing (e.g., `MethodInfo` creation) so misconfigured or unsupported response types fail fast with an `IllegalArgumentException`, while preserving correct behavior for supported request/response types and existing adapter behavior.