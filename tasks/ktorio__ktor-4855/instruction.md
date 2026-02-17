The server Dependency Injection plugin needs first-class coroutine support so that dependency initialization can be suspending and dependency resolution is async by default.

Currently, DI supports only synchronous initializers via `provide { ... }` and synchronous `resolve<T>()`. This prevents creating services whose construction must call suspend functions (for example, connecting to a remote service, reading configuration asynchronously, or any operation that needs a coroutine). Users need to be able to register providers whose initializer is `suspend` and then resolve those services from other providers and from request handlers without deadlocks or ordering failures.

Implement async DI support with these behaviors:

- It must be possible to register dependencies with a suspending initializer. The API should allow writing providers like:
  ```kotlin
  provide<MyService> {
      // suspending initialization allowed
      val ds = resolve<DataSource>()
      ds.connect()
      MyService(ds)
  }
  ```
  This initializer must be allowed to call other dependencies via `resolve()`.

- `resolve<T>()` must be a suspending operation (so it can wait for an async initializer to complete). Resolving a dependency that has an async initializer must suspend until the instance is ready.

- When a dependency is missing, `resolve<T>()` must still fail deterministically with `MissingDependencyException` (rather than hanging indefinitely). This should also apply when a dependency cycle is present or when resolution cannot be satisfied.

- Async initialization must be structured: if the application is shutting down or the DI scope is cancelled, pending resolutions/initializations should be cancelled promptly (propagating coroutine cancellation rather than leaking jobs).

- Module loading must support an optional “concurrent module loading” mode: if enabled, modules/providers may be registered out of order, and consumers may suspend until their provider becomes available. If disabled (the default), the behavior should remain like typical DI libraries: dependencies must be registered before they are resolved, and out-of-order resolution should fail rather than waiting.

- The DI plugin must support a service-locator style extension point so that the dependency map can be extended/bridged by an external container (e.g., a third-party DI framework). Users should be able to declare and resolve dependencies exclusively via the external container, or combine it with the Ktor DI plugin without tightly coupling the two.

Reproduction example to validate behavior:

1) Register a `ConnectionConfig` and `FakeLogger` synchronously.
2) Register a `DataSource` with a suspending initializer that calls `connect()` and logs a message.
3) Resolve the `DataSource` from within a route handler (or from another provider) using `resolve<DataSource>()`.

Expected behavior:
- The request succeeds and the `DataSource.connect()` suspend function runs during initialization.
- The logger contains the expected line (e.g., "Connecting to <url>...").
- If `DataSource` is resolved without being provided (and concurrent module loading is disabled), `MissingDependencyException` is thrown.
- If concurrent module loading is enabled and the provider is registered later, the earlier resolution suspends until registration completes, then succeeds.
- Cancelling the application/DI context cancels pending resolutions and does not deadlock shutdown.