When using JUnit Jupiter’s `@TempDir`, multiple injection points currently receive the same temporary directory within the same test context (e.g., within a single test method). This is counter-intuitive and breaks use cases where a test needs two independent temporary roots.

Reproduction example:

```java
@Test
void copyFileFromSourceToTarget(@TempDir Path source, @TempDir Path target) throws IOException {
    Path sourceFile = source.resolve("test.txt");
    Files.writeString(sourceFile, "hello");

    Path targetFile = Files.copy(sourceFile, target.resolve("test.txt"));

    // expected: source and target are different temp directories, so these are not the same path
    assertNotEquals(sourceFile, targetFile);
}
```

Actual behavior: `source` and `target` refer to the same directory, causing operations intended to be isolated (source vs target) to collide and making `sourceFile` and `targetFile` potentially refer to the same location.

Expected behavior: each distinct `@TempDir` declaration (each annotated field or each annotated parameter) must receive its own newly created temporary directory. In particular, two parameters in the same method signature annotated with `@TempDir` must result in two different directories.

The change must preserve correct lifecycle semantics and cleanup:

- Parameter injection: each `@TempDir` parameter gets its own directory.
- Field injection: each `@TempDir` field declaration gets its own directory.
- Static `@TempDir` fields remain shared for the scope they currently represent (i.e., reused across tests according to JUnit’s existing static field semantics), but should still be “per declaration” (two different static fields annotated with `@TempDir` should not silently share one directory).
- Temporary directories created for a declaration must be deleted at the appropriate time (matching the existing extension’s cleanup behavior).

Misconfiguration and error reporting must continue to behave sensibly:

- Unsupported targets for `@TempDir` should still trigger `ExtensionConfigurationException`.
- Failures to create or delete temp directories should still surface as `ParameterResolutionException` (for parameter injection) or equivalent extension failures for field injection.

Implement the updated behavior in the `TempDirectory` extension so that it creates and tracks temp directories per `@TempDir` declaration rather than reusing a single directory per test context, while maintaining existing behavior where sharing is explicitly intended (e.g., the same static field reused across multiple test methods).