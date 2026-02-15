When running tests via `EngineTestKit` (aka TestEngineKit), the execution currently picks up implicit configuration parameters from the environment (for example, values coming from system properties or `junit-platform.properties`). This is surprising for a test utility and can make engine-kit based verification flaky, e.g., when a build enables parallel execution globally via `junit.jupiter.execution.parallel.*` properties.

The problem: `EngineTestKit.engine("junit-jupiter")...execute()` should not, by default, inherit implicit configuration parameters from the host environment. Only configuration parameters explicitly provided to the EngineTestKit builder should be used unless the user explicitly opts in.

Reproduction scenario:
- Set a system property with some key `KEY` (any unique key string).
- Execute a Jupiter test class via `EngineTestKit.engine("junit-jupiter")` where an extension calls `ExtensionContext.getConfigurationParameter(KEY)` and, if present, publishes it as a report entry.
- Currently, the report entry is published because the configuration parameter is resolved from the system property (implicit provider), even though the EngineTestKit builder was not given that parameter.

Expected behavior:
- By default, `ExtensionContext.getConfigurationParameter(KEY)` should be empty when running through EngineTestKit unless `KEY` was explicitly provided via the EngineTestKit builder.
- EngineTestKit must provide an opt-in switch to re-enable implicit configuration parameters. The builder API should support enabling/disabling this behavior, e.g. `EngineTestKit.Builder.enableImplicitConfigurationParameters(boolean enabled)`.
- With `enableImplicitConfigurationParameters(true)`, implicit configuration parameters (such as system properties) must be visible again; with `enableImplicitConfigurationParameters(false)`, they must remain hidden.

In other words, `EngineTestKit` must ignore implicit configuration parameter providers by default, while still allowing advanced users to explicitly enable them when needed.