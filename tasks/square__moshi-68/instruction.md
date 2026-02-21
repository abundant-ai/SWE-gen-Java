Moshi supports overriding a field’s JSON name via `@Json(name = "...")`, but this is cumbersome to type and hard to use with IDE autocomplete. Add a new annotation form that allows specifying the JSON name without the `name =` boilerplate, so users can write:

```java
class Customer {
  @Json("full name")
  String fullName;
}
```

When this annotation is present on a field, Moshi must use the provided string as the JSON property name for both serialization and deserialization. For example, serializing a `Customer` instance with `fullName = "Alec"` must emit JSON containing `"full name":"Alec"` rather than `"fullName":"Alec"`, and parsing `{"full name":"Alec"}` must populate `fullName`.

The new annotation must coexist with the existing `@Json(name = "...")` behavior. If both forms are present (direct value and `name =`), Moshi should treat this as a configuration error rather than silently choosing one.

This behavior must work with Moshi’s reflection-based class adapter (the default adapter created for regular Java/Kotlin classes), including typical cases like private fields and fields inherited from superclasses.