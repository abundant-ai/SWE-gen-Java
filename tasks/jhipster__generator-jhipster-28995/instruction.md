Adding nested properties to the generated Spring Boot `ApplicationProperties` class is currently more complex than necessary and is error-prone when programmatically extending the generated Java source.

When customizing generation using the source API, calling `source.addApplicationPropertiesClass({...})` with a nested `classStructure` should reliably add (or merge) the requested properties into `ApplicationProperties` in a predictable way.

Reproduction example:

```js
source.addApplicationPropertiesClass({
  propertyType: 'SomeNestedProperties',
  classStructure: { enabled: ['Boolean', 'true'], tag: 'String' },
});
```

Expected behavior:
- The generated `ApplicationProperties` Java class includes a nested properties type named `SomeNestedProperties`.
- That nested structure contains:
  - an `enabled` property of type `Boolean` with default value `true`
  - a `tag` property of type `String`
- The result is stable and deterministic (running generation multiple times yields the same `ApplicationProperties` content).
- If `addApplicationPropertiesClass` is invoked multiple times for the same `propertyType`, properties should be merged rather than producing duplicated fields/classes or conflicting definitions.

Actual behavior:
- Adding properties to `ApplicationProperties` requires unnecessary complexity in the generator internals, and the resulting Java output is not reliably produced in the expected structure in some scenarios (e.g., nested properties/merging), making extension via `addApplicationPropertiesClass` fragile.

Fix `source.addApplicationPropertiesClass` and any related Spring Boot generator code so that the above call produces the correct `ApplicationProperties` content (including nested properties and defaults) and remains consistent across runs and repeated invocations.