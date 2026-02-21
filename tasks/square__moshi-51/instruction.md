Add support for reporting the current JSON “writer path” from JsonWriter, similar to how JsonReader can report where it is in a document. A new public method `JsonWriter.getPath()` is needed so callers can include a precise location when throwing exceptions due to data mismatch while writing.

`getPath()` must return a JSONPath-like string that describes the writer’s current location, starting at the document root as `$`.

The path must update correctly as the writer enters/exits arrays and objects and as it writes names and values. In particular:

- Immediately after creating a new `JsonWriter`, `getPath()` must return `$`.
- After `beginObject()`, the path must indicate you are inside an object and ready for a name: `$.` at the root, or for nested objects like `$[0].`.
- After calling `name("a")` (before writing the value for that name), the path must include the property name with dot notation, like `$.a`.
- After `beginArray()` as the value for a name, the path must include the name and the next array index to be written, starting at 0, like `$.a[0]`.
- Each call that writes an array element (`value(...)` for numbers/booleans/strings, and `nullValue()`, and also `beginObject()`/`beginArray()` as elements) must advance the array index so that `getPath()` reports the next element index (e.g., after writing the first element at `[0]`, `getPath()` becomes `[1]`).
- When an object is written as an array element, immediately after `beginObject()` the path must reflect that array index plus object context, like `$.a[5].`, and after `name("c")` it must become `$.a[5].c`.
- After writing a property value inside an object (for example after `value("d")` for property `c`), `getPath()` should remain at that property path (e.g., still `$.a[5].c`) until the writer moves out of that property context.
- After `endObject()` or `endArray()`, the path must return to the enclosing container and, if that container is an array, reflect the next element index to be written. For example, if an object was written at `$.a[5]`, after `endObject()` the path should be `$.a[6]`.
- After finishing an array that was the value of an object property, the path should return to the property itself (e.g., after `endArray()` for property `a`, the path becomes `$.a`). After subsequently ending the root object, it must return to `$`.

This needs to work for nested arrays (e.g., after starting a nested array as an element, paths like `$.a[6][0]` should be reported) and for arrays of objects at the top level (e.g., after `beginArray()` at the root, the path should start at `$[0]`, and after `beginObject()` for an element it should become `$[0].`).