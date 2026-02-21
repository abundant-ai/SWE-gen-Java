JSON encoding/decoding order is inconsistent between Moshi’s Java reflective adapter and the Kotlin reflective adapter, causing ordering-sensitive JSON comparisons to fail during migrations.

When using Moshi’s reflective class adapter (often referred to as a “ClassJsonAdapter”/class-based adapter), fields are serialized in a deterministic alphabetical order (including across inherited fields). However, when using the Kotlin reflective adapter ("KotlinJsonAdapter"), object/map-like field ordering differs because it preserves insertion order (for example via a LinkedHashMap) rather than sorting keys. As a result, the same logical object encoded via the Java vs Kotlin adapter can produce JSON with different key order, and decoding behavior can also differ in how it records/iterates fields.

Update the Kotlin adapter so that it matches the ordering behavior of the class-based adapter:

- Encoding must output JSON object fields in alphabetical order by JSON name.
- Ordering must be stable and match Java/Kotlin parity for the same type.
- This must also work correctly with type hierarchies (fields declared on subclasses and superclasses), producing a single alphabetically ordered set of JSON fields.
- If multiple properties/fields resolve to the same JSON name (for example via annotations or naming policies), the adapter should detect the collision deterministically and fail early with a clear exception rather than silently choosing one.

After the change, code like the following should produce the same JSON ordering regardless of whether the reflective adapter in use is the Java/class-based one or the Kotlin one:

```java
class DessertPizza extends BasePizza {
  boolean chocolate;
}
class BasePizza {
  int diameter;
}

// Expected JSON (alphabetical):
// {"chocolate":true,"diameter":13}
```

And for a simple class:

```java
class BasicPizza {
  int diameter;
  boolean extraCheese;
}

// Expected JSON:
// {"diameter":13,"extraCheese":true}
```

Currently, using Kotlin reflection can yield different ordering (and may not match the Java adapter), which should be corrected to ensure ordering parity.