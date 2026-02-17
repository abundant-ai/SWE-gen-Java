The server DI plugin lacks robust cleanup support during application shutdown. Users need a way to register cleanup actions for dependencies (especially AutoCloseable resources) and have them run reliably during shutdown without causing coroutine cancellation errors.

Currently, DI-related cleanup can fail during shutdown with errors like a JobCancellationException because shutdown happens after the parent application coroutine scope is already destroyed. In addition, accessing deferred DI results during shutdown can require the original coroutine scope even if the deferred is not awaited, so cleanup logic that runs too late in the lifecycle can crash or silently skip work.

Implement DI cleanup support with these behaviors:

When configuring DI via DependencyInjectionConfig, it must be possible to define an onShutdown hook. By default, onShutdown should close any DI-provided declarations that are AutoCloseable. Users must be able to replace/override onShutdown to provide custom shutdown behavior.

The DI registry must also support registering cleanup hooks for individual declarations, via a cleanup function in the registry/DSL, so a user can attach per-dependency shutdown actions to run when the server stops.

Shutdown execution must be triggered early enough in the application lifecycle so that cleanup can still safely access DI-managed values without requiring a coroutine scope that has already been cancelled/destroyed. Specifically, cleanup must run before the application’s parent scope is torn down (i.e., it should be initiated on ApplicationStopping rather than ApplicationStopped).

Expected behavior:
- Declared AutoCloseable dependencies are closed automatically on shutdown (unless the user overrides this behavior).
- Custom cleanup hooks registered via the DI DSL/registry are invoked exactly once when the server is shutting down.
- Shutdown cleanup does not throw JobCancellationException due to lifecycle timing or coroutine-scope destruction.
- DI resources used during shutdown can still be retrieved/accessed by cleanup logic even if they were provided via deferred/lazy mechanisms.

Provide any necessary API surface (e.g., DependencyInjectionConfig.onShutdown and registry cleanup registration) so that application code can express this cleanly in the DI DSL.