JUnit Jupiter’s @TempDir currently always cleans up temporary directories after a test run, which makes it difficult to keep generated output around when developing/debugging tests or when creating “golden files”. Add support for configuring whether temp directories created via @TempDir are deleted.

Introduce a cleanup mode concept for @TempDir so users can declare the desired behavior directly on the annotation and have the engine honor it during cleanup. The API should support a CleanupMode enum with at least these values:

- CleanupMode.ALWAYS: temp directories are deleted after use (current behavior).
- CleanupMode.NEVER: temp directories are not deleted.
- CleanupMode.ON_SUCCESS: temp directories are deleted only when the test execution is considered successful; if a test is aborted (e.g., a TestAbortedException) or fails, the temp directory must be preserved.

Users must be able to use the new option like:

```java
@Test
void example(@TempDir(cleanup = CleanupMode.ON_SUCCESS) Path tempDir) {
}
```

and similarly for field injection.

The cleanup decision must be applied when closing the internal representation of the temp directory (e.g., TempDirectory.CloseablePath) so that calling close() deletes or preserves the directory based on the configured CleanupMode and the execution outcome available from ExtensionContext. In particular:

- For ALWAYS, close() must delete the directory.
- For NEVER, close() must not delete the directory.
- For ON_SUCCESS, close() must delete the directory only if ExtensionContext reports no execution exception; if ExtensionContext.getExecutionException() contains a TestAbortedException, it must not delete the directory.

Add a configuration parameter to control the default cleanup mode globally (used when @TempDir does not specify a cleanup mode). The engine configuration layer (e.g., JupiterConfiguration and its caching implementation) should expose the default cleanup mode and cache it like other configuration values.

Also ensure that invalid @TempDir parameter types continue to fail with a ParameterResolutionException with a message indicating that only java.nio.file.Path or java.io.File are supported.

After implementing this, @TempDir should support the cleanup attribute consistently for both parameter and field injection, and the configured cleanup mode should be honored in nested test classes as well, with the effective cleanup mode determined by the closest applicable declaration or the global default.