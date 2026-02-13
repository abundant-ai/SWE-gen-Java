Retrofit currently lacks a first-party JSON converter based on Moshi. Implement a Moshi-backed `Converter` so users can serialize Java/Kotlin objects to an `okhttp` `RequestBody` and deserialize an `okhttp` `ResponseBody` back into objects using Moshi.

Create a `MoshiConverter` that is constructed with a `com.squareup.moshi.Moshi` instance and supports these operations:

- `RequestBody toBody(Object value, Type type)` should serialize `value` as JSON using Moshi’s adapter for the supplied `type` (not necessarily `value.getClass()`). For example, if an object is passed whose runtime type is `Impl` but `type` is an interface `Example`, the converter must use the Moshi adapter for `Example`, so that custom Moshi adapters registered for `Example` are applied.
- `Object fromBody(ResponseBody body, Type type)` should read the response body as JSON and return an instance produced by Moshi’s adapter for `type`.

Required behaviors:

1) Serialization should produce JSON for the runtime type when the provided `type` matches that class. For an object `new Impl("value")` serialized with `type = Impl.class`, the JSON should be:

```json
{"theName":"value"}
```

2) Serialization must respect the explicitly provided `type` even when it differs from the runtime type. With a Moshi instance configured with a custom adapter for an `Example` interface which writes JSON as `{ "name": ... }`, serializing `new Impl("value")` with `type = Example.class` must produce:

```json
{"name":"value"}
```

3) Deserialization should round-trip standard Moshi behavior for the requested type. Given a response body containing:

```json
{"theName":"value"}
```

calling `fromBody(..., Impl.class)` must return an `Impl` whose `getName()` returns `"value"`.

The converter should correctly handle IO when reading/writing bodies and use Moshi’s `JsonAdapter` lookup based on the provided `Type` for both directions.