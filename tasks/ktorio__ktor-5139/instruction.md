Ktor’s server DI plugin needs three related fixes/enhancements.

1) Allow DI configuration to be read from application configuration files.
Currently, DI settings can’t be configured via the standard file-backed ApplicationConfig mechanism. Add support for reading the following keys from config:
- `ktor.di.keyMapping`
- `ktor.di.conflictPolicy`

These values must be parsed from configuration (for example from HOCON/Typesafe config via `ConfigFactory`, or any other `ApplicationConfig` implementation) and applied when the DI plugin is installed so that a user can configure DI behavior without hardcoding it in code.

2) Add a new DI conflict policy: `OverridePrevious`.
At the moment, DI conflict handling does not provide a way to override an already-registered binding with a newer one. Introduce a conflict policy option named `OverridePrevious` that causes later registrations for the same dependency key to replace earlier ones.

Expected behavior:
- When conflict policy is `OverridePrevious`, registering the same dependency key multiple times should result in the last registration being used by `resolve(...)`/`create(...)`.
- Other conflict policies must keep their current behavior.

3) Fix cancellation errors during DI cleanup.
During application shutdown / DI cleanup, cancellation-related exceptions (notably `CancellationException`, which can surface as `JobCancellationException`) can be thrown and should not be treated as failures.

Expected behavior:
- When DI is being disposed/cleaned up and a dependency’s cleanup/close logic encounters coroutine cancellation, the cleanup process should suppress/ignore `CancellationException`-type failures rather than propagating them.
- Non-cancellation exceptions during cleanup should still be surfaced as errors (i.e., do not blanket-swallow all exceptions).

The change should ensure that a server using the DI plugin can:
- Configure `ktor.di.keyMapping` and `ktor.di.conflictPolicy` purely via application config,
- Select `OverridePrevious` to allow overrides of existing bindings,
- Shut down cleanly without spurious `CancellationException` / `JobCancellationException` failures coming from DI cleanup.