Micronaut fails to start when an annotation attribute combines a property placeholder with an evaluated expression in the same annotation, even though each works individually.

A common example is a scheduled job method annotated like:

```java
@Scheduled(fixedRate = "${hello.world.rate}", condition = "#{!this.paused}")
public void doSomething() { }
```

When `hello.world.rate` is provided via configuration (YAML/properties/env/property sources), the `fixedRate` placeholder should be resolved to the configured value (e.g. `100s`) and the `condition` expression should still be processed. Instead, application startup fails while processing the scheduled method with an error similar to:

`Invalid @Scheduled definition for method: ... - Reason: Invalid fixed rate definition: ${hello.world.rate}`

The failure indicates that placeholder resolution for the `fixedRate` attribute is skipped or not applied when the same annotation also contains an expression-based attribute (like `condition = "#{...}"`).

Fix the annotation processing/runtime behavior so that:
- Property placeholders like `${hello.world.rate}` are correctly resolved from the environment/configuration for annotation members such as `Scheduled#fixedRate`.
- Expression-based members in the same annotation (e.g. `Scheduled#condition`) continue to be supported.
- After the environment is populated with `hello.world.rate=100s`, querying the `@Scheduled` annotation value for `fixedRate` on the annotated method yields the resolved string value `"100s"` (not the literal `${hello.world.rate}`), and Micronaut does not throw `SchedulerConfigurationException` during bootstrap for this case.