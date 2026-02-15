Configuration deserialization using Ktor’s config APIs incorrectly fails when a property is missing but the target Kotlinx-serialization model allows it (nullable or has a default value). This affects both HOCON-backed configs and Map-backed configs.

When decoding a configuration object via the config helpers (for example, calling `ApplicationConfig.propertyOrNull("test")?.getAs<MyConfig>()` for HOCON, or using `MapConfigDecoder` with `MyConfig.serializer().deserialize(decoder)` for Map-based configs), the decoder currently treats a missing key as a hard error and terminates decoding. As a result, models with optional elements cannot be deserialized if those fields are omitted from the configuration.

Reproduction example:

```kotlin
@kotlinx.serialization.Serializable
data class NullableTypes(
    val nullableString: String? = null,
    val nullableInt: Int? = null,
)

val content = """
    test {
        nullableString = "Not null"
        # nullableInt intentionally omitted
    }
""".trimIndent()

val parsed = parseConfig(content)
val decoded = parsed.propertyOrNull("test")?.getAs<NullableTypes>()
```

Expected behavior: `decoded` is not null; `decoded.nullableString == "Not null"`; and `decoded.nullableInt == null` (or its default value if defined).

Actual behavior: decoding fails because the missing `nullableInt` is treated as a fatal missing-property condition, even though the element is optional according to the serializer descriptor.

Implement proper optional-element handling in the decoders used by config deserialization so that:
- Missing configuration keys do not abort decoding when the corresponding element is optional (nullable and/or has a default value).
- Required (non-optional) fields still fail clearly when absent.
- This behavior is consistent for both HOCON-based decoding (via `ApplicationConfig.getAs` / `propertyOrNull`) and Map-based decoding (via `MapConfigDecoder` and `deserialize`).