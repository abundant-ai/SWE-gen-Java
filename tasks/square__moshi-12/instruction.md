Moshi is missing JSON adapters (“converters”) for some Java primitive types and/or has incomplete behavior differences between primitive types (e.g., `boolean.class`) and boxed types (e.g., `Boolean.class`). As a result, calling `new Moshi.Builder().build().adapter(<primitive type>).lenient()` does not consistently support all primitives, does not serialize/deserialize using the expected JSON representation, and does not enforce null-handling rules correctly.

Implement the missing primitive converters so that Moshi can create `JsonAdapter` instances for all primitive types (and their boxed counterparts) with correct parsing/formatting and correct null behavior.

Required behaviors (examples use `lenient()` but these adapters must work in general):

- Boolean adapters:
  - `moshi.adapter(boolean.class)` must parse JSON booleans case-insensitively when lenient (e.g., `"true"`, `"TRUE"`, `"false"`, `"FALSE"`) and serialize to canonical lowercase (`"true"`/`"false"`).
  - For `boolean.class`, JSON `null` must be rejected on read with `IllegalStateException` whose message is exactly: `Expected a boolean but was NULL at path $`.
  - For `boolean.class`, writing `null` must throw `NullPointerException`.
  - `moshi.adapter(Boolean.class)` must accept JSON `null` on read (returns `null`) and write `null` as the JSON literal `null`.

- Byte adapters:
  - `moshi.adapter(byte.class)` must parse numeric JSON values into a `byte` and serialize a `byte` into its canonical JSON numeric form.
  - Serialization for bytes must use the unsigned canonical representation (0–255). For example, serializing `(byte) -2` must produce the JSON number `254`.
  - Parsing must accept the full range needed to round-trip bytes, including signed values (-128..127) and also unsigned inputs up to 255, mapping them appropriately into a `byte`.
  - As with other primitives, JSON `null` must be rejected when the target type is the primitive (`byte.class`), and writing `null` must throw `NullPointerException`. For boxed `Byte.class`, `null` must be allowed.

- Apply the same primitive-vs-boxed nullability rules consistently across the other missing primitive converters (for example: `short`, `int`, `long`, `char`, `float`, `double` as applicable in this codebase), ensuring:
  - Primitive targets reject JSON `null` on read with an `IllegalStateException` describing the expected type, the actual token `NULL`, and including the JSON path (for top-level values this is `$`).
  - Primitive targets throw `NullPointerException` on write when given `null`.
  - Boxed targets allow `null` on both read and write.

After implementing the missing converters, `Moshi.adapter(Class)` should successfully return working adapters for these primitive classes, with correct serialization/deserialization and consistent error messages/path reporting when encountering invalid `null` values for primitives.