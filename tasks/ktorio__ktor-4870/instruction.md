`StringValuesBuilder` currently supports appending values via `append(name, value)` and `appendAll(name, values)`, but it is awkward to mutate it from common map-shaped data.

Implement additional `StringValuesBuilder.appendAll(...)` overloads so callers can append entries from maps directly:

1) Support appending a map of single values:

```kotlin
val values = StringValues.build {
    appendAll(mapOf("foo" to "bar", "baz" to "qux"))
}
```

This should behave the same as calling `append(key, value)` for each map entry.

2) Support appending a map of multiple values per key:

```kotlin
val values = StringValues.build {
    appendAll(mapOf("test" to listOf("1", "2", "3")))
}
```

This should behave the same as calling `appendAll(key, iterableValues)` for each entry, preserving the existing semantics of `appendAll(key, values)` (including the behavior for empty iterables).

These overloads should work anywhere a `StringValuesBuilder` is used (for example, URL parameter building via `URLBuilder(...).parameters`). After appending, building a URL should produce repeated query parameters for multi-valued entries (e.g., `test=1&test=2&test=3`).

Expected behavior details:
- For `Map<String, String>`, each map entry results in exactly one value appended under that key.
- For `Map<String, Iterable<String>>`, each map entry appends all provided values for that key; if the iterable is empty, the key should still be present with an empty list of values (consistent with existing `appendAll(key, emptyList())` behavior).
- The overloads must coexist with existing `appendAll(name, values)` APIs without ambiguity for typical call sites.