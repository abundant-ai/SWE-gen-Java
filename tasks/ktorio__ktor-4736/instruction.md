Ktor’s DI plugin should support registering dependencies from application configuration, but currently dependency registration only works through the application/module API. Add support for a string-list configuration key `ktor.application.dependencies` whose entries are fully-qualified references to either a class or a function that should be registered into the DI container.

When `ktor.application.dependencies` is set (for example in YAML):

```yaml
ktor:
  application:
    dependencies:
      - io.ktor.chat.PostgresKt.createDatabase
      - io.ktor.chat.MessagesRepository
```

…the DI plugin must, on first use, lazily load these references and make them available to the `dependencies` resolver. Each entry must be handled as follows:

- If the reference points to a class, DI should be able to construct that class using its constructor, resolving constructor parameters from the DI context.
- If the reference points to a function, DI should call that function to create the dependency, resolving the function parameters from the DI context.
- For functions that are extension functions on `DependencyResolver`, the receiver must be provided as the current resolver.
- For functions that require `ApplicationEnvironment` (or other already-available Ktor application objects), those parameters must be resolvable from the DI context like any other dependency.
- Default parameter values must be respected when arguments are not provided by DI.
- Nullable parameters must be supported: if a nullable dependency cannot be resolved, DI should pass `null` rather than failing, allowing the factory/constructor to decide how to handle it.

The dependencies described by configuration must be constructed lazily (not at install time). Installing the DI plugin should not immediately instantiate these dependencies. They should be created only when the dependencies plugin is first invoked/resolution happens.

Visibility/reflective access errors must be handled predictably: attempting to register or call private/inaccessible callables via configuration should fail with a reflective access exception (for example `IllegalCallableAccessException`) rather than silently succeeding.

The end result should allow mixing configuration-provided dependencies and programmatic `dependencies { provide { ... } }` registrations, and resolving configured items via delegated properties (e.g., `val service: GreetingService by dependencies`) or explicit creation APIs (e.g., `dependencies.create<Foo>()`).