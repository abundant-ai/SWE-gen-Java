Moshi supports custom adapter classes with methods annotated with @ToJson and @FromJson. These “adapter methods” are discovered reflectively and used to convert values to/from JSON.

Currently, adapter-method selection does not correctly account for nullability annotations on the adapter method parameters/return types. As a result, a @ToJson/@FromJson method intended to apply only to nullable values may be incorrectly used for non-null values, or a method intended for non-null values may be incorrectly used for nullable values.

Update adapter-method discovery and matching so that @Nullable is part of the method signature matching rules:

When an adapter method’s parameter (for @ToJson) or return type / parameter (for @FromJson, depending on the method shape) is annotated with @Nullable, that method must only be selected when Moshi is adapting a nullable type (i.e., when the requested adapter is for a type that permits null). Conversely, when @Nullable is not present, that method must not be selected for nullable adaptation.

This should work for the common adapter method forms, including:

- @ToJson methods that return a value (e.g., returning a List<Integer> for a Point).
- @FromJson methods that take a value and return a converted value.
- @ToJson methods that take (JsonWriter, T) and write directly.
- @FromJson methods that take (JsonReader) and return T.

Expected behavior: if both nullable and non-null adapter methods exist for the same logical conversion, Moshi must choose the one whose nullability matches the requested adapter type. If only one exists, it should be used only when its nullability matches; otherwise Moshi should fall back to its default behavior or report that no suitable adapter method exists.

The key requirement is: when the @Nullable annotation is present, the adapter method is used; when it isn’t, it isn’t (for nullable adaptation).