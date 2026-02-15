JUnit Platform’s `ConfigurationParameters` API does not currently provide a supported way for engine/launcher implementations to enumerate all available configuration parameter keys. This makes it difficult for engine providers to detect unknown/misspelled configuration keys (for example keys with a given prefix like `"jqwik."`) and warn users about configuration mistakes.

Add a new method `keySet()` to `org.junit.platform.engine.ConfigurationParameters` that returns the set of all configuration parameter keys available through that `ConfigurationParameters` instance.

Behavior requirements:
- `ConfigurationParameters.keySet()` must return a `Set<String>` containing every key that `get(String)` could resolve from the underlying configuration sources (explicit parameters, configuration file properties, system properties, inherited/parent parameters where applicable).
- For an instance with no available parameters, `keySet()` must be empty.
- The returned set must not contain keys that are not actually present in the configuration (e.g., after calling `get("some.key")` on an empty configuration, `keySet()` must still not contain `"some.key"`).
- `keySet()` must enforce the same general contract quality as other public API in this area (non-null return, stable behavior, no exceptions for normal usage).

In addition, `ConfigurationParameters.size()` should be deprecated in favor of `keySet().size()`.

Implementations/wrappers must behave correctly:
- `PrefixedConfigurationParameters` must continue to delegate all `get(...)` variants to its underlying `ConfigurationParameters` using the full prefixed key (e.g. prefix `"foo.bar."` and requested key `"qux"` must query `"foo.bar.qux"`).
- Any existing delegation for `size()` in `PrefixedConfigurationParameters` must remain functional (even though `size()` is deprecated).
- `PrefixedConfigurationParameters.keySet()` must expose keys relative to the prefix: if the delegate contains keys `"foo.bar.a"` and `"foo.bar.b"` and also `"other.c"`, then calling `keySet()` on a `PrefixedConfigurationParameters(delegate, "foo.bar.")` must return exactly `{ "a", "b" }`.
- `PrefixedConfigurationParameters` must keep its existing constructor preconditions: it must reject a null delegate, and it must reject a null/blank prefix (throwing `PreconditionViolationException`).

`LauncherConfigurationParameters` (and any other `ConfigurationParameters` implementations used by the platform/launcher) must implement `keySet()` consistently across configuration sources:
- When configuration is built from an empty map and no additional sources provide values, `size()` must be 0, `get(key)` must be empty, and `keySet()` must not contain that key.
- When a parameter is explicitly provided (e.g. in the map), `get(key)` must return the explicit value and `keySet()` must contain the key.
- When a parameter is provided via configuration file properties and/or system properties, `get(key)` must resolve according to the existing precedence rules, and `keySet()` must include the key if it is available from any active source.
- `ConfigurationParameters.get(String)` must continue to enforce its existing preconditions (reject null/blank keys with `PreconditionViolationException`).

The goal is that engine providers can safely enumerate `ConfigurationParameters.keySet()` (or use `PrefixedConfigurationParameters`) to validate configuration keys and provide meaningful feedback for unknown keys or spelling mistakes, without needing internal access to configuration internals.