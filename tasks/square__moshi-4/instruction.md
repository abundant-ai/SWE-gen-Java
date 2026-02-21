Moshi’s new adapter-based API needs to be implemented so callers can obtain type-specific JSON adapters (optionally customized and composed) and use those adapters to encode/decode values. The central Moshi object should not expose direct toJson/fromJson methods; instead, it must provide an adapter lookup API and support registering custom adapters and factories.

Implement the following behaviors:

When building a Moshi instance via `new Moshi.Builder()...build()`, callers must be able to obtain a `JsonAdapter<T>` using `moshi.adapter(Type)` (including `Class` literals like `int.class`, `Integer.class`, and `String.class`). The returned adapter must support `fromJson(String)` and `toJson(T)`.

Primitive vs boxed null-handling must be correct:

- For `moshi.adapter(int.class)`: decoding JSON `"1"` (as a number token) must produce `1`, and encoding `2` must produce the JSON string `"2"` (without quotes). Decoding the JSON literal `null` must throw `IllegalStateException` with the exact message: `Expected an int but was NULL at path $`. Encoding a Java null for a primitive adapter (calling `moshi.adapter(int.class).toJson(null)`) must throw `NullPointerException`.

- For `moshi.adapter(Integer.class)`: decoding `"1"` must produce `1`, encoding `2` must produce `"2"`, decoding JSON `null` must return Java `null`, and encoding Java `null` must return the JSON literal `"null"`.

- For `moshi.adapter(String.class)`: decoding `"\"a\""` must produce `"a"`, encoding `"b"` must produce `"\"b\""`, decoding JSON `null` must return Java `null`, and encoding Java `null` must produce `"null"`.

Adapters must also support configuration chaining via `JsonAdapter.lenient()`. A lenient adapter must successfully parse/emit JSON in lenient mode while preserving the same semantic behavior for values and nullability as described above.

Custom adapters must be registerable on the builder, including binding an adapter directly to a specific Java type. For example, after `new Moshi.Builder().add(Pizza.class, new PizzaAdapter()).build()`, calling `moshi.adapter(Pizza.class)` must return an adapter that can round-trip objects using the custom JSON shape. Encoding `new Pizza(15, true)` must produce exactly `{"size":15,"extra cheese":true}`, and decoding `{"extra cheese":true,"size":18}` must produce a `Pizza` equal to `new Pizza(18, true)`.

The design must allow composition/delegation of adapters through factories (similar to Gson’s type adapter factories) so that one adapter can wrap another, and annotations must participate in adapter selection (ie, adapter lookup should be able to consider annotated types/elements when resolving which adapter/factory applies).