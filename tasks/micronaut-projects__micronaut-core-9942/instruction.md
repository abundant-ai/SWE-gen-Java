Two related issues need to be fixed in Micronaut’s annotation metadata processing and configuration builder binding.

1) Annotation alias propagation order is wrong

When an annotation introduces aliases (via `@AliasFor`) through stereotypes, the aliased values are currently applied too late in stereotype processing. In practice, this means aliases do not override values from stereotypes that were processed earlier, producing incorrect effective annotation metadata.

This is observable with custom stereotype annotations that combine `@ConfigurationReader` and `@AliasFor(annotation = ConfigurationReader.class, member = "value")`. For example, a stereotype like:

```java
@ConfigurationReader("default")
public @interface MyStereotypeWithDefaultValue {
  @AliasFor(annotation = ConfigurationReader.class, member = "value")
  String value() default "default";
}
```

When such stereotypes are used in combination with other stereotypes / inherited annotation setups that influence property paths, the resolved `@Property(name=...)` can be wrong because the alias does not take precedence.

Expected behavior: aliased members introduced by alias annotations must be applied with higher priority so that they can override previously-seen stereotype values when building the effective annotation metadata. Property path resolution for configuration reader/property annotations must reflect the alias override.

Actual behavior: the alias values are applied after other stereotypes, so they fail to override earlier metadata and the final resolved property name/prefix can be incorrect.

2) `@ConfigurationBuilder` incorrectly prefers zero-arg methods when prefixes are empty

`@ConfigurationBuilder` should bind configuration properties to a builder by selecting the appropriate write method. When a builder type defines both a getter-like method and a setter-like method with the same name (empty prefix), and the getter is declared before the setter, Micronaut currently calls the zero-argument method instead of the one-argument fluent setter.

Reproduction scenario:

- A configuration properties class exposes a builder field annotated with `@ConfigurationBuilder(prefixes = [""])`.
- The builder interface contains both:
  - `Integer maxConcurrency()` (0 args)
  - `Builder maxConcurrency(Integer maxConcurrency)` (1 arg returning the builder)
- A property `pool.max-concurrency` is present.

Expected behavior: Micronaut should invoke the one-argument method `maxConcurrency(Integer)` (the write method) so the builder gets configured from the property value.

Actual behavior: Micronaut invokes the zero-argument method `maxConcurrency()` instead.

This appears to be related to builder introspection/property resolution incorrectly allowing zero-argument methods as writable candidates even though configuration builder binding is intended to disallow that by default.

Implement the fix so that, for configuration builder binding with empty prefixes, the one-argument fluent setter is selected over a zero-arg method of the same name, even when the zero-arg method appears first in declaration order. Also ensure the default behavior for configuration builder binding does not treat zero-argument methods as write methods unless explicitly enabled.

After the fix, constructing an `ApplicationContext`, adding a property source like `pool.max-concurrency=123`, and retrieving the configuration properties bean should complete without errors and should result in the builder being configured via the setter method rather than invoking the getter.