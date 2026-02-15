The experimental JUnit Platform API type `LauncherDiscoveryListener` is currently an abstract class, which makes it less flexible to implement and inconsistent with other listener APIs such as `TestExecutionListener`. Update the API so that `LauncherDiscoveryListener` is an interface.

After this change, user code must be able to implement `LauncherDiscoveryListener` directly (e.g., `class MyListener implements LauncherDiscoveryListener { ... }`) without relying on inheriting from an abstract base class. Existing launcher discovery code that interacts with a `LauncherDiscoveryListener` must continue to work the same way (callbacks are still invoked at the same times during discovery), but the type itself must be an interface.

Ensure the public API remains well-defined:

- Any methods declared by `LauncherDiscoveryListener` must have clearly defined preconditions (e.g., non-null parameters) and must enforce those preconditions consistently (typically via `Preconditions` checks).
- All Javadoc and `@API` annotations must reflect that this is now an interface and must document method contracts.
- Equality semantics for listener instances must behave normally for user implementations (i.e., nothing in the framework should depend on the old abstract base-class identity/behavior).

If there are any existing convenience behaviors previously provided by the abstract class (such as no-op default implementations), they must remain available in a way that does not require subclassing an abstract class (for example, via default methods or an adapter), so that simple implementations can still be written with minimal boilerplate.

The result should compile against updated API usages across the platform and should be covered by automated tests that instantiate a concrete `LauncherDiscoveryListener` implementation and verify that it can be used in discovery without errors.