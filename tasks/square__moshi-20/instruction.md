Moshi currently lacks proper support for serializing and deserializing `Map` types as JSON objects. Add a `JsonAdapter` implementation and factory wiring so that `Moshi` can create adapters for `Map<K, V>` where `K` is `String` (string keys only for now) and `V` is any type supported by Moshi.

When an adapter is requested for a `Map<String, Boolean>` (or other value type), calling `toJson()` should emit a JSON object whose property names are the map’s keys and whose values are encoded using the value adapter. Example behavior:

```java
Map<String, Boolean> map = new LinkedHashMap<>();
map.put("a", true);
map.put("b", false);
map.put("c", null);

String json = moshi.adapter(/* Map<String, Boolean> type */).toJson(map);
// expected: {"a":true,"b":false,"c":null}
```

Calling `fromJson()` on that JSON should produce a `Map` with the same entries, including `null` values.

The adapter must preserve encounter/order semantics when the input map is an ordered map (for example, a `LinkedHashMap`). Serializing such a map should keep the key order stable in the resulting JSON, and deserializing a JSON object should produce a map whose iteration order matches the order of properties in the JSON text.

Null-handling must work as follows:

- If the map value itself is `null`, `toJson()` must write JSON `null`, and `fromJson()` of JSON `null` must return Java `null`.
- If the map contains a `null` key, serialization must fail by throwing `NullPointerException`.
- Empty maps must serialize to `{}` and deserialize from `{}` to an empty map.

This should integrate with the normal `Moshi` lookup mechanism so that requesting an adapter for a `Map` type works the same way as other built-in adapters (including use of nested adapters for the value type).