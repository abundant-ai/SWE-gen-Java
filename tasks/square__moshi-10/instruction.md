Moshi currently lacks a built-in JsonAdapter for Java array types. As a result, calling Moshi.adapter(...) with an array type (for example, String[].class, int[].class, or a generic array type obtained via reflection) does not correctly serialize/deserialize JSON arrays.

Implement array handling so that Moshi can read and write JSON arrays for any supported component type.

When a caller requests an adapter for an array type via Moshi.adapter(Type) (or Moshi.adapter(Class)), Moshi should return an adapter that:
- Deserializes a JSON array like "[1,2,3]" into the corresponding Java array type.
- Serializes a Java array value into a JSON array string.
- Delegates element conversion to Moshi’s existing adapter for the component type (including any annotations on the type), so that custom adapters and built-in adapters are honored for each element.
- Correctly handles primitive arrays (for example, int[]), including rejecting null elements where the primitive type cannot represent null.
- Correctly handles object arrays (for example, Integer[] and String[]) where null elements are permitted, including round-tripping arrays that contain nulls.
- Produces appropriate error messages and paths when encountering type mismatches while reading (for example, when the JSON token is NULL or an object instead of an array).

The resulting behavior should make array types work similarly to existing Collection/List handling: arrays should be supported as first-class types in Moshi’s adapter resolution and should interoperate with lenient() and other standard JsonAdapter behaviors.