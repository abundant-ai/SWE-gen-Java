Moshi currently ignores unknown JSON object members during parsing, which can hide integration problems (for example, server adds a field and the client silently drops it). Add new opt-in APIs that allow callers to fail when unknown values are encountered while decoding.

When building adapters via Moshi.Builder and/or configuring a JsonAdapter, developers should be able to enable a “fail on unknown” mode. With this mode enabled, decoding JSON into a target type must throw a JsonDataException when an object contains a name that is not recognized/consumed by the adapter (for example, an extra property that doesn’t correspond to any bound field/parameter). The exception message should be actionable and include the JSON path where the unknown name was encountered (for example, reporting the field name and a path like "$" / "$.a" depending on nesting).

This behavior must be opt-in: existing behavior should remain unchanged unless the new API is used. It should also compose correctly with existing adapter configuration options like lenient() and serializeNulls(), so that enabling fail-on-unknown does not change unrelated parsing/encoding behavior.

Reproduction example:

- Given a type that expects only field "a", decoding from JSON like {"a":1,"b":2} should normally succeed and ignore "b".
- When fail-on-unknown is enabled for that adapter (or globally via the Moshi instance if supported), decoding the same JSON must throw JsonDataException indicating that "b" is unknown at the appropriate path.

Ensure the API is available from public surfaces used to obtain adapters (Moshi / Moshi.Builder / JsonAdapter as appropriate), and that the failure triggers during fromJson(...) when extra names are present in objects.