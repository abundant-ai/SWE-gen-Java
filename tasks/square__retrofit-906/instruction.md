Retrofit’s converter integration is currently passing insufficient type information to converters. When a service method returns or accepts a parameterized type (for example `Call<List<String>>` or more complex nested generics like `List<Record<Person>>`), Retrofit ends up providing only the runtime class (e.g., `ArrayList.class`) to the converter rather than the generic `Type` declared on the service method. This prevents converters from correctly validating supported types and can cause incorrect converter selection or confusing runtime failures.

Retrofit should pass the exact `java.lang.reflect.Type` derived from the service interface method declaration into the converter when creating request bodies and when converting response bodies. This must work for both the response type (`Call<T>`) and for `@Body` parameters.

After this change, converters are expected to behave based on the declared type, not the runtime implementation type. For example:

- A protobuf converter like `WireConverter` should successfully serialize and deserialize a `Phone` message when calling `Call<Phone> post(@Body Phone impl)` and should set the request `Content-Type` to `application/x-protobuf`.
- Deserializing an empty response body for `Call<Phone> get()` should return a `Phone` instance with `number == null`.
- Calling an endpoint declared as `Call<String> wrongClass()` while the server returns protobuf bytes must fail with an `IllegalArgumentException` indicating that the type is not supported by that converter (rather than attempting to parse using an incorrect or fallback type).
- Calling an endpoint declared as `Call<List<String>> wrongType()` must also fail with an `IllegalArgumentException` indicating the declared generic type is unsupported.

Similarly, an XML converter like `SimpleXmlConverter` should correctly serialize and deserialize a simple object when declared as `Call<MyObject> post(@Body MyObject impl)`, including using the correct `Content-Type` header of `application/xml; charset=UTF-8`, and it must surface deserialization errors (such as malformed or unexpected XML structure) as conversion failures rather than silently succeeding.

Overall, ensure that converter lookup and invocation throughout Retrofit uses the method-declared `Type` (including generic parameters) so that installed converters can make correct decisions and handle complex types reliably.