Moshi should support defining JSON adapters using annotated methods on an arbitrary object added via `new Moshi.Builder().add(Object)`. Currently, adding an object that contains `@ToJson` / `@FromJson` methods does not reliably produce a working `JsonAdapter` for the target type, and callers can’t use this concise style to customize serialization/deserialization.

Implement support for “adapter methods” with the following behavior:

When a user adds an instance like `new PointAsListOfIntegersJsonAdapter()` to `Moshi.Builder.add(...)`, Moshi must discover methods annotated with `@ToJson` and `@FromJson` and use them to create a `JsonAdapter` for the relevant types.

Supported method shapes:

1) Value-based conversion
- `@ToJson SomeJsonType toJson(TargetType value)`
- `@FromJson TargetType fromJson(SomeJsonType jsonValue)`
Where `SomeJsonType` is any type Moshi can otherwise adapt (for example `List<Integer>`). Serializing `new Point(5, 8)` using the resulting adapter must yield the JSON that corresponds to the intermediate value (for example `[5,8]`). Deserializing that JSON must call the `@FromJson` method and return the converted value.

2) Streaming conversion
- `@ToJson void toJson(JsonWriter writer, TargetType value)`
- `@FromJson TargetType fromJson(JsonReader reader)`
These methods must be used to write/read JSON directly via `JsonWriter`/`JsonReader`.

Partial adapters must be supported:
- If only an `@ToJson` method is present for a type, serialization should use it, but deserialization must fall back to Moshi’s next applicable adapter (the default reflective/other factory-based adapter).
- If only an `@FromJson` method is present for a type, deserialization should use it, but serialization must fall back to Moshi’s next applicable adapter.

Precedence/interaction requirements:
- Adapter-method based factories must integrate with existing adapter lookup so that asking `moshi.adapter(TargetType.class)` returns an adapter honoring these methods when present.
- The fallback behavior must not recurse back into the same adapter-method implementation; it should delegate to the next adapter in the chain.

Error handling:
- If an `@FromJson` method throws (for example if a list has the wrong size and throws `new Exception("Expected 2 elements but was " + o)`), that exception should propagate to the caller of `JsonAdapter.fromJson(...)`.

A minimal expected usage is:
```java
Moshi moshi = new Moshi.Builder()
    .add(new PointAsListOfIntegersJsonAdapter())
    .build();
JsonAdapter<Point> adapter = moshi.adapter(Point.class);
adapter.toJson(new Point(5, 8)); // should produce "[5,8]"
adapter.fromJson("[5,8]"); // should produce new Point(5, 8)
```
And similarly for the streaming `JsonWriter`/`JsonReader` signatures.