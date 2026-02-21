Moshi’s enum JSON adapter currently accepts unrecognized enum constants during deserialization instead of failing fast. This can silently map unexpected JSON values to an incorrect result (or otherwise proceed without clearly signaling that the input doesn’t match any constant), which hides data/compatibility problems.

When deserializing JSON into an enum type using Moshi (via `new Moshi.Builder().build().adapter(MyEnum.class)` and calling `fromJson(...)`), if the JSON string value does not correspond to any constant of that enum (including values specified via `@Json(name = ...)`), Moshi should throw an exception rather than returning a value.

For example, given an enum `Color { RED, GREEN }`, calling:

```java
Moshi moshi = new Moshi.Builder().build();
JsonAdapter<Color> adapter = moshi.adapter(Color.class);
adapter.fromJson("\"BLUE\"");
```

should throw a `JsonDataException` indicating that the value is not one of the accepted enum values, and the message must include the JSON path (for example ending with `at path $`).

This stricter behavior should apply consistently to all enum adapters Moshi provides, including adapters used transitively when enums appear as fields inside other decoded objects. The exception should be thrown at the point of reading the unknown value (not deferred), and it must not be affected by calling `lenient()` on the adapter (lenient mode may relax JSON syntax, but it must not allow unknown enum constants).

Additionally, the built-in enum adapter should be treated as a standard/built-in adapter (i.e., supplied by Moshi’s standard adapters set) so that it’s available consistently alongside other core adapters, without requiring special-case registration by users.