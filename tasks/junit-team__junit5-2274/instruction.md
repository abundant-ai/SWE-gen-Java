JUnit Jupiter currently requires annotating each test class with @TestMethodOrder to control method ordering. There is no supported way to set a global default method orderer for the whole JUnit Platform/Jupiter engine.

Add support for a new configuration parameter named "junit.jupiter.testmethod.order.default" that allows users to configure the default test method order globally.

When constructing/using the Jupiter configuration (e.g., via DefaultJupiterConfiguration and any caching wrapper such as CachingJupiterConfiguration), add a new accessor for the configured default MethodOrderer (for example, a method like getDefaultTestMethodOrderer() returning an Optional<MethodOrderer> or returning a MethodOrderer that falls back to the engine’s built-in default). The behavior must be:

- If the configuration parameter is not set, is empty/blank, or contains an invalid value, the system must behave exactly as before (i.e., use the built-in default test method ordering and do not fail).
- If the configuration parameter is set to a valid fully-qualified class name of a MethodOrderer implementation, Jupiter must instantiate and use that MethodOrderer as the default for all tests that do not explicitly declare @TestMethodOrder.
- The configured class must be validated to be assignable to org.junit.jupiter.api.MethodOrderer. If it is not assignable, cannot be loaded, or cannot be instantiated, it must be treated as invalid and ignored (fall back to the built-in default).
- Preconditions must be enforced where applicable (for example, creating the default configuration with null ConfigurationParameters must throw a PreconditionViolationException with the message "ConfigurationParameters must not be null").
- The configuration should be cached consistently (if there is a caching JupiterConfiguration implementation, repeated calls to the accessor for the default MethodOrderer must not repeatedly query the delegate).
- Logging should mirror existing configuration-parameter-based instantiation behavior: when a valid class is configured and used, emit an INFO log indicating that the default test method orderer is being used and that it was set via the "junit.jupiter.testmethod.order.default" configuration parameter; invalid/blank values should not break execution.

Example of expected usage:
- Setting configuration parameter "junit.jupiter.testmethod.order.default" to "com.example.MyOrderer" (where MyOrderer implements MethodOrderer) should make that orderer apply to all test classes that don’t specify @TestMethodOrder.
- Setting it to "bogus" or a class that does not implement MethodOrderer should not change behavior and should not crash the engine.