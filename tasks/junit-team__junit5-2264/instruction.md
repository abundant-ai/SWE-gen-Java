Selecting individual tests by method name fails for Spock-based tests when using a `MethodSelector`. Spock generates test methods via a Groovy AST transform, so the `MethodSelector` cannot always resolve a backing `java.lang.reflect.Method`. In those cases, calling `MethodSelector.getJavaMethod()` throws, which currently breaks method-based selection and can also cause engine discovery to fail when both the Vintage and Jupiter engines are on the classpath.

The failure happens in two related scenarios:

1) Vintage + Spock: When a discovery request selects a test method by name (i.e., using `DiscoverySelectors.selectMethod(testClass, "methodName")`), the Vintage engine attempts to obtain the selected method name via `MethodSelector.getJavaMethod().getName()`. For Spock-generated methods, `getJavaMethod()` throws an exception, so filtering cannot be applied correctly and the selected method cannot be executed as intended.

2) Jupiter present alongside Vintage: When both engines are available, a `MethodSelector` for a non-Jupiter test class (e.g., a Spock spec) can still be seen during Jupiter discovery. Jupiter’s method-selector resolution currently attempts to resolve `MethodSelector.getJavaMethod()` unconditionally, which can throw for Spock-generated methods and cause Jupiter discovery to fail even though the class is not a Jupiter test.

Implement the following behavior:

- The Vintage engine must not depend on `MethodSelector.getJavaMethod()` to obtain the method name. It should use `MethodSelector.getMethodName()` (or an equivalent safe path that does not require resolving a reflective `Method`) so that method selection by source-level name works even when the underlying `Method` cannot be produced.

- Jupiter’s `MethodSelectorResolver` (or equivalent selector-resolution component) must avoid calling `MethodSelector.getJavaMethod()` for classes that are not Jupiter test classes. When a `MethodSelector` targets a class that is not recognized as a Jupiter test class, Jupiter should not attempt to resolve the Java `Method` and must not fail discovery; it should leave the selector unresolved for Jupiter so other engines can handle it.

After the fix:

- Selecting a Spock test method by name via `MethodSelector` must succeed for Vintage execution/filtering.
- When both Vintage and Jupiter are present, creating a `MethodSelector` for a Spock test must not cause Jupiter engine discovery to throw; Jupiter should only resolve method selectors when the target class is a valid Jupiter test class.