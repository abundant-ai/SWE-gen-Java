There is an infinite recursion when Micronaut tries to instantiate a bean via reflective constructor invocation in the bean introspection/instantiation utilities.

A reproducible scenario is when a class is included for introspection via an outer holder annotated with `@Introspected(classes = SomeType.class)` (i.e., not necessarily part of the shared introspector cache) and `SomeType` has a non-public (e.g., package-private) constructor. In this case, requesting the introspection and then attempting to instantiate the type triggers reflective constructor logic that repeatedly calls itself until it overflows.

When a `BeanIntrospection` (or `BeanIntrospectionReference`) for such a type is obtained through `BeanIntrospector` and the type is instantiated (directly via the introspection’s instantiation APIs, or indirectly via `InstantiationUtils`), construction should either:

- succeed by invoking the correct constructor reflectively (respecting accessibility rules that Micronaut supports for introspected types), or
- fail once with a clear `io.micronaut.core.reflect.exception.InstantiationException` (or similar) describing that the constructor cannot be invoked.

Actual behavior: the reflective constructor call enters an infinite recursion path, resulting in a `StackOverflowError` (or equivalent runaway recursion) instead of a single successful instantiation or a single well-formed failure.

Fix the reflective constructor instantiation pathway so that invoking a constructor reflectively cannot recurse indefinitely. Ensure the behavior is correct specifically for:

- types introspected via `@Introspected(classes = ...)` (not only those already present in `BeanIntrospector.SHARED`), and
- types with package-private constructors.

After the fix, constructing such an introspected type through Micronaut’s introspection/instantiation APIs should complete deterministically (success or single exception) without recursion/stack overflow.