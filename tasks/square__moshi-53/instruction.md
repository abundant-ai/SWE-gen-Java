Moshi’s Map handling needs a new public API that allows map keys to be encoded/decoded using normal JsonAdapters (including custom @FromJson/@ToJson methods and @JsonQualifier annotations), rather than being limited to the built-in string/primitive key conversions.

Currently, when serializing or parsing a Map whose key type is not a plain String (or requires a custom adapter/qualifier), Moshi can’t reliably use the key type’s JsonAdapter because JSON object member names are always strings. This prevents users from reusing their existing adapters for key types, and makes qualified key adapters (for example keys annotated with a custom @JsonQualifier) impossible to apply.

Implement a new “magic” Map API so that, when building a JsonAdapter for Map<K, V>, callers can opt into using the JsonAdapter for K to convert between:

- the JSON object member name (a string) and the key value K during parsing
- the key value K and a JSON object member name (a string) during encoding

This must work with:

- key adapters that are implemented via annotated @ToJson/@FromJson methods
- key adapters that use the streaming forms (@ToJson with JsonWriter parameter, @FromJson with JsonReader parameter)
- key adapters that are selected via @JsonQualifier annotations

Behavioral requirements:

1) When reading a JSON object into Map<K, V> using the new API, Moshi must be able to treat each property name as the next JSON value so the key adapter can read it using normal JsonReader methods like nextString(), nextInt(), and nextDouble().

2) JsonReader.promoteNameToValue() must support this workflow correctly:
   - After beginObject() and promoteNameToValue(), peek() must report STRING.
   - nextString()/nextInt()/nextDouble() should consume the promoted name value and leave the reader positioned so the corresponding property value can be read next.
   - Error messages must be consistent with existing reader behavior. For example, calling nextBoolean() when the promoted name is a string must throw JsonDataException with the message: "Expected a boolean but was STRING at path $.<name>" (with the current path).

3) When writing Map<K, V> using the new API, Moshi must use the key adapter to produce the JSON member name. If a map entry’s key is null, writing must fail with JsonDataException: "Map key is null at path $.".

4) Round-trip correctness: for supported key types (including numeric keys like "5" and "5.5" represented as object names), encoding then decoding must preserve keys and values.

Provide the new API surface on Moshi/JsonAdapter creation for Map types (exact naming per PR intent: “new magic API to use type adapters for map keys”), and ensure it integrates with existing adapter resolution (including qualifier-driven adapters).