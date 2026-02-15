JUnit Jupiter extensions cannot reliably detect the current parallel execution behavior via the provided ExtensionContext API. Extensions that perform field injection in a BeforeEach callback need to fail fast when tests are executed with ExecutionMode.CONCURRENT while using TestInstance lifecycle PER_CLASS, because multiple test methods may run in parallel against a single test instance and overwrite injected fields, causing cross-thread interference. The ExtensionContext API currently exposes the test instance lifecycle (via getTestInstanceLifecycle()) but does not expose the effective execution mode in force, forcing extensions to inspect annotations and global configuration themselves.

Add a new method to org.junit.jupiter.api.extension.ExtensionContext: ExecutionMode getExecutionMode(). The returned value must represent the actual execution mode that will be used for the current context, taking into account defaults and configuration (for example, global default execution mode and default class execution mode, as applicable) as well as any explicit execution mode set for the current test container/test.

The method must work consistently across concrete ExtensionContext implementations used for engine-, class-, method-, and test-template-based execution. In particular:

- When the configuration’s default execution mode is SAME_THREAD and no explicit mode is specified, getExecutionMode() must return SAME_THREAD.
- When the execution mode is explicitly set to CONCURRENT for the current scope, getExecutionMode() must return CONCURRENT.
- For contexts representing templated/parameterized invocations, getExecutionMode() must reflect the execution mode associated with the underlying descriptor for that invocation.

This API should enable an extension to implement logic like:

```java
ExecutionMode mode = context.getExecutionMode();
Optional<Lifecycle> lifecycle = context.getTestInstanceLifecycle();
if (mode == ExecutionMode.CONCURRENT && lifecycle.orElse(Lifecycle.PER_METHOD) == Lifecycle.PER_CLASS) {
    throw new ExtensionConfigurationException("Field injection is not supported with PER_CLASS lifecycle under CONCURRENT execution.");
}
```

If getExecutionMode() is invoked in a situation where the execution mode cannot be determined, it should fail with a clear precondition violation rather than returning null.