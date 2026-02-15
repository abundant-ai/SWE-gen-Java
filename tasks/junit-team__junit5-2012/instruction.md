Test discovery in the JUnit Vintage engine becomes extremely slow for large JUnit 4/ScalaTest-style test classes (e.g., tens of thousands of tests). Users report that executing the tests can take only a few seconds, but discovery can take many minutes. Profiling indicates that, during discovery, the engine repeatedly scans a test class hierarchy and enumerates all methods again for every single test method, leading to quadratic runtime behavior.

The slowdown happens when converting a JUnit 4 `org.junit.runner.Description` into a JUnit Platform `org.junit.platform.engine.TestSource`. When `Description` refers to a single test method, the code attempts to locate the corresponding `java.lang.reflect.Method` by repeatedly calling `org.junit.platform.commons.util.ReflectionUtils.findMethods(...)` across the class hierarchy. For large classes, repeatedly enumerating and filtering the same method list dominates discovery time.

Implement a fix so that method enumeration for a given test class is not recomputed for every test method lookup. Introduce/adjust a `TestSourceProvider` used for creating `TestSource` instances such that it caches the list of `Method` objects per test class and reuses it for subsequent lookups. The cache must be bounded (LRU behavior) to avoid unbounded memory growth and must be safe for concurrent access during discovery.

Functional requirements:

- `new TestSourceProvider().findTestSource(description)` must behave as follows:
  - If `description.getTestClass()` is non-null and `description.getMethodName()` is non-null, it should return a `org.junit.platform.engine.support.descriptor.MethodSource` pointing to that class and method when the method can be resolved.
  - If only the class is available (no method name), it should return `org.junit.platform.engine.support.descriptor.ClassSource`.
  - If no test class is available, it should return `null`.

- Parameterized test descriptions may include a suffix like `"testName[0]"`. The method resolution must sanitize such names so that `"testName[0]"` resolves against method `"testName"`.

- Method lookup must work for inherited test methods. For example, if the concrete test class has no declared method `theTest` but its superclass defines `public void theTest()`, resolving `Description.createTestDescription(ConcreteClass.class, "theTest")` must still produce a `MethodSource` with:
  - `className == ConcreteClass.getName()`
  - `methodName == "theTest"`

- If multiple methods with the same name exist (e.g., overloads), method resolution should prefer a single unambiguous result. If multiple matches exist, it should narrow to public methods; if it still cannot pick exactly one method, it should return `null` rather than selecting arbitrarily.

Performance requirement:

- Repeated calls to resolve methods for the same test class must not repeatedly traverse the class hierarchy and enumerate all methods each time. The methods for a class should be computed once and then filtered for each lookup, substantially reducing discovery time for very large test classes.

Supporting utility:

- Provide or adjust an `LruCache<K,V>` utility (used by the method cache) so that it evicts the eldest entry when the configured max size is reached, while keeping the underlying map capacity stable (i.e., it should not continuously grow as entries are added/evicted).