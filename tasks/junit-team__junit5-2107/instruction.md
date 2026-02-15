JUnit Platform discovery selectors that load classes by name currently always use the default class loading strategy. This causes failures in modular/OSGi-like environments where the default classloader cannot see test classes, even though an explicit bundle/module classloader can.

Add new `DiscoverySelectors` overloads for class- and method-based selection that accept an explicit `ClassLoader`, and propagate that classloader through the selector objects so that class loading is performed with the provided loader.

Concretely:

When creating selectors from class names (for example `DiscoverySelectors.selectClass(String)` and `DiscoverySelectors.selectMethod(String, String)` and any related string-based method-selection variants), there must be additional overloads such as:

```java
DiscoverySelectors.selectClass(String className, ClassLoader classLoader)
DiscoverySelectors.selectMethod(String className, String methodName, ClassLoader classLoader)
```

as well as overloads for any method selector variants that take a parameter signature string.

Behavior requirements:

1) `ClassSelector` and `MethodSelector` must store/expose the `ClassLoader` they will use (for example via a `getClassLoader()` accessor) and must attempt class loading using that loader when resolving the Java `Class` (for example in `getJavaClass()`).

2) Backwards compatibility: if no classloader is explicitly provided, behavior must remain as it is today (i.e., use the default loader strategy).

3) Error handling: when a class cannot be loaded, calling `getJavaClass()` must throw `PreconditionViolationException` with the message:

`"Could not load class with name: <className>"`

and the thrown exception must preserve the original root cause as its `cause` (for example, a `ClassNotFoundException`).

4) When selectors are created from a `Class<?>` instance (for example `new ClassSelector(Class<?>)` and `new MethodSelector(Class<?>, String)`), the selector’s classloader must be the class’s own classloader.

5) Equality and hash code semantics must remain consistent: selectors constructed with equivalent inputs should compare equal and have the same hash code, including cases where the classloader argument is explicitly `null` (which should behave the same as omitting the classloader).

Example scenario that should work after the change:

```java
ClassLoader bundleLoader = ...; // can load com.example.MyTest
var selector = DiscoverySelectors.selectClass("com.example.MyTest", bundleLoader);
selector.getJavaClass(); // must succeed using bundleLoader
```

Currently, the above can fail because the selector uses the default classloader instead of `bundleLoader`.