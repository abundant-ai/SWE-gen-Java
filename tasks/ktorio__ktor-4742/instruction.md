Dependency injection in Ktor tests doesn’t currently support overriding previously registered dependencies when running under the server test engine. In production-style DI behavior, registering the same dependency type twice should raise a conflict (for example, a DuplicateDependencyException). However, when using testApplication { ... } it should be possible to install production dependencies first and then override specific ones with mocks.

Problem:
When DI is installed/used from the test engine, subsequent calls like dependencies { provide<GreetingService> { ... } } should be able to replace earlier declarations of the same key/type without throwing a DuplicateDependencyException. The “last entry wins” behavior should apply specifically to tests (testApplication), while non-test usage should keep strict conflict behavior.

Reproduction example:

```kotlin
fun test() = testApplication {
    application {
        dependencies { provide<GreetingService> { GreetingServiceImpl() } }
        dependencies { provide<GreetingService> { BankGreetingService() } }

        val service: GreetingService by dependencies
        // Expected: uses BankGreetingService
        assertEquals("Hello, customer!", service.hello())
    }
}
```

Expected behavior:
- Under testApplication, providing the same dependency key/type multiple times should not fail; the latest provided binding should be the one resolved (override behavior).
- In non-test contexts (or in a stricter DI test harness), conflicting duplicate registrations should still throw DuplicateDependencyException.

Also ensure existing DI error semantics remain correct:
- Accessing an undeclared dependency via delegated property (e.g., `val service: GreetingService by dependencies`) must throw MissingDependencyException.
- Declaring a dependency after resolving/using the container should still fail with OutOfOrderDependencyException (i.e., adding bindings after resolution has started is not allowed).
- Circular dependency graphs must still be detected and throw CircularDependencyException (including when created via `dependencies.create<T>()`).

JVM reflection-based creation must keep working:
- `dependencies.create<GreetingServiceImpl>()` should construct instances using constructor injection.
- Providing by class reference must be supported (e.g., `provide(GreetingServiceImpl::class)`), and subsequent resolution via delegated property should return a working instance.
- Constructor lookup/creation should be cached so repeated `create<SomeClass>()` calls don’t repeatedly re-run expensive reflection setup (observable by only one reflective creation path invocation across many create calls).