Ktor’s server DI plugin needs to support more ergonomic provider registration and correctly resolve certain ambiguous dependency graphs involving Kotlin delegation.

1) Add DI lambda/provider overloads so constructor and function references can be used directly.
Currently, registering dependencies typically requires explicitly writing lambdas like `provide<Foo> { FooImpl(...) }`. The DI DSL should also accept class references and callable references so users can do things like:

```kotlin
dependencies {
    provide(GreetingServiceImpl::class)
    provide(::SomeServiceImpl) // constructor reference
    provide(::someFactoryFunction) // function reference
}
```

After registering a class reference, it must be possible to resolve it via property delegation and via explicit creation:

```kotlin
val service: GreetingService by dependencies
val impl: GreetingServiceImpl = dependencies.create()
```

Constructor resolution must be cached so repeated `dependencies.create<GreetingServiceImpl>()` calls do not repeatedly re-run reflective constructor discovery/creation plumbing.

2) Fix DI resolution when delegate-pattern types create ambiguity.
If a class uses Kotlin delegation (for example `class BankTeller(...) : GreetingService by greetingService, BankService by bankService`), DI resolution can become ambiguous when evaluating providers for interfaces implemented via delegation. The container should resolve this ambiguity during provider evaluation by using an already-registered implementation when there is exactly one previously registered candidate that can be used to disambiguate. However:
- If the ambiguous type is requested directly by the user (not as part of resolving another provider), the container must still throw an `AmbiguousDependencyException` rather than silently picking one.
- The existing ambiguous exception behavior must be preserved for true ambiguity cases (multiple viable candidates with no single previously registered implementation to select).

3) Circular dependency detection must still work when using `create()`.
When creating an object graph via `dependencies.create<T>()` that contains a circular reference (for example, `WorkExperience -> List<PaidWork> -> PaidWork -> WorkExperience`), the call must fail with `CircularDependencyException`.

Overall expected behavior: class/callable reference registration works with both delegated resolution (`val x: T by dependencies`) and `dependencies.create<T>()`; constructor lookup is cached; delegate-pattern ambiguity is resolved only when safe during provider evaluation; and direct ambiguous requests still throw `AmbiguousDependencyException` while circular graphs throw `CircularDependencyException`.