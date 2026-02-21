Moshi’s in-repo JSON streaming APIs need to behave consistently after replacing/decoupling from Gson-derived behavior. Several externally-visible behaviors are currently incorrect or missing.

1) JsonWriter must NOT serialize null values by default.

When using JsonWriter to write an object property whose value is null, the property should be omitted from the output unless explicitly configured otherwise.

Example:

```java
StringWriter out = new StringWriter();
JsonWriter writer = new JsonWriter(out);
writer.beginObject();
writer.name("a");
writer.nullValue();
writer.endObject();
writer.close();
// Expected: {}
```

Actual behavior currently includes the key by default (or otherwise fails to match the expected omission semantics).

JsonWriter must support an opt-in configuration to include nulls. When enabled, the same sequence should produce `{"a":null}`:

```java
JsonWriter writer = new JsonWriter(out);
writer.setSerializeNulls(true);
...
// Expected: {"a":null}
```

2) JsonReader must support construction directly from a JSON string and correctly maintain path reporting during traversal.

A new constructor is required:

```java
JsonReader reader = new JsonReader(String json);
```

Using this constructor, JsonReader must correctly parse arrays/objects and keep `getPath()` accurate as the cursor advances through nested arrays/objects.

The `getPath()` value must reflect the current location in a JSONPath-like format, including:
- Root path is `$`.
- After beginning an object at the root, the path becomes `$.`.
- When positioned on a property name, the path includes the property name like `$.a`.
- When inside arrays, the path uses bracketed indices like `$.a[0]`, `$.a[1]`, etc.
- When descending into nested objects/arrays, the path composes, such as `$.a[5].c` and `$.a[5][0]`.
- After consuming values and closing scopes with `endObject()` / `endArray()`, the path must correctly return to the enclosing scope.
- Calling `peek()` must not advance the reader and must not change `getPath()`.

3) JsonWriter and JsonReader must enforce state errors consistently.

JsonWriter should throw `IllegalStateException` for invalid write sequences such as:
- Writing a top-level value without an enclosing array/object.
- Writing two consecutive `name(...)` calls without a value.
- Ending an object when a name has been written but no value has been provided.
- Writing a value in an object without first calling `name(...)`.

JsonReader should continue to correctly handle standard streaming operations (`beginArray`, `endArray`, `beginObject`, `endObject`, `nextName`, `nextString`, `nextInt`, `nextBoolean`, `nextNull`, `skipValue`, `hasNext`, and `peek`) when reading from the new String-based constructor.

Overall expected behavior is that these streaming APIs are fully functional without relying on Gson-specific behaviors (such as non-execute prefixes or HTML-safe escaping) and that the default null-handling and path reporting match the semantics described above.