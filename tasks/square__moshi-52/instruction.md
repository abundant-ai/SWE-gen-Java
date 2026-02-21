Moshi currently lacks correct support for using a JsonAdapter<Object> as a truly “runtime typed” adapter. When a caller asks for an adapter for Object.class, serialization and deserialization should behave like a generic JSON value: writing should delegate to the runtime type of the actual value, and reading should produce only primitive/collection/map structures (not user-defined model types).

Implement/adjust the behavior of `Moshi.adapter(Object.class)` so that:

When calling `JsonAdapter<Object>.toJson(Object value)`:
- The adapter must encode based on the *runtime class* of `value`, not based on `Object.class`.
- For example, if `value` is an instance of a user type like `Delivery` that contains fields (including nested objects and lists), `toJson(value)` should emit a JSON object with those fields. If a field is declared as `Object` but contains (at runtime) a `Pizza` instance, it must be encoded as a JSON object with the `Pizza` fields rather than as `{}`.
- For list contents typed as `Object`, elements must be encoded using each element’s runtime type. Example: a list containing a `Pizza` instance and the string "Pepsi" must serialize to an array with an object for the pizza and a JSON string for "Pepsi".
- If `value` is a plain `new Object()` with no properties, it should serialize to `{}` (not crash, and not include class metadata).

When calling `JsonAdapter<Object>.fromJson(String json)`:
- The adapter must parse arbitrary JSON into only these Java types:
  - `Map` for JSON objects (with string keys)
  - `List` for JSON arrays
  - `String` for JSON strings
  - `Boolean` for JSON booleans
  - `Double` for JSON numbers (numbers must be represented as `Double`, even for integers like `0` or `1`)
  - `null` for JSON null
- Parsing an object like `{"address":"1455 Market St.","items":[{"diameter":12,"extraCheese":true},"Pepsi"]}` should produce a `Map` where "items" is a `List` whose first element is a `Map` (with numeric values as `Double`) and second element is a `String`.

This Object runtime adapter must integrate cleanly with Moshi’s existing adapter lookup/delegation so it does not break circular adapter resolution for regular model classes. In particular, creating adapters for normal classes (and classes that refer to each other) must still work without stack overflows or incorrect adapter reuse, even if some properties are typed as `Object` and therefore use the runtime adapter at runtime.

The end result is that callers can reliably use `Moshi moshi = new Moshi.Builder().build(); JsonAdapter<Object> adapter = moshi.adapter(Object.class);` to round-trip arbitrary JSON values into Maps/Lists/primitives on read, and to serialize arbitrary object graphs on write by using the runtime type of each encountered value.