When running tests with parallel execution enabled, JUnit’s resource lock resolution performs repeated class-level annotation/provider lookups for every test method. In projects with many tests, nested test classes, and class-level resource lock providers, this leads to redundant reflection/annotation scanning and unnecessary overhead.

JUnit supports declaring resource locks via `@ResourceLock` and also via `@ResourceLock(providers = ...)` where the provider implements `org.junit.jupiter.api.parallel.ResourceLocksProvider`. However, resource lock collection currently re-walks the declaring class and all enclosing classes for each `ResourceLockAware` test descriptor instead of reusing previously discovered class-level resource lock metadata.

Update the resource lock collection behavior so that for a given test hierarchy, each `ResourceLockAware` descriptor reuses (delegates to) the already-computed class-level `ExclusiveResource` information of its ancestors. Class-level `@ResourceLock` annotations and class-level `ResourceLocksProvider` instances should be discovered once per relevant class and then cached and reused for all contained test methods and nested tests.

This must work for all of the following scenarios without changing the externally visible semantics of resource locks:

- A class-level `@ResourceLock(providers = SomeProvider.class)` applies to all test methods in that class.
- The same behavior holds for `@Nested` test classes: if an enclosing class declares a provider or resource lock, nested classes and their test methods must see those locks.
- Method-level providers/locks still apply only to the method they are declared on, and must be combined correctly with any class-level locks inherited from enclosing/declaring classes.

In addition, the provider callbacks should not be invoked redundantly due to repeated lookups. For example, if a class-level provider is responsible for supplying locks for the class, JUnit should not repeatedly create/query provider instances per test method when the effective class-level locks are identical and can be cached.

The end result should be that executing test classes that use class-level and nested class-level `ResourceLocksProvider`s completes successfully with the same locking behavior as before, but avoids multiple class-level annotation/provider lookups per test method by caching at the appropriate descriptor/collector level.