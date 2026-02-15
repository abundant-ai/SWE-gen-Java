Executing the same JUnit Platform `TestPlan` instance more than once currently leads to engine-internal failures, especially for `@ParameterizedTest`/test template invocations. A common symptom is a `java.lang.NullPointerException` thrown during the second execution (for example originating from `TestTemplateInvocationTestDescriptor.populateNewExtensionRegistry(...)`), even though the first execution succeeds.

The `Launcher` should detect and reject attempts to execute a previously executed `TestPlan` and fail fast with a descriptive error message instead of letting execution proceed into undefined behavior.

Reproduction scenario (conceptual):
1. Use `Launcher.discover(...)` to obtain a `TestPlan`.
2. Call `Launcher.execute(TestPlan, ...)` once: execution succeeds.
3. Call `Launcher.execute(TestPlan, ...)` again with the same `TestPlan` instance: currently, execution proceeds and can crash with `NullPointerException` (or other engine errors) during test execution.

Required behavior:
- On the second attempt to execute the same `TestPlan` instance, `Launcher.execute(TestPlan, ...)` must throw a precondition-style exception (i.e., a `PreconditionViolationException`) indicating that a `TestPlan` must not be executed more than once.
- The exception message must be descriptive (explicitly stating that the supplied `TestPlan` has already been executed and cannot be executed again).
- The `Launcher` API documentation (Javadoc) must clearly state this constraint as a precondition for the execute method overload(s) that accept a `TestPlan`.

The goal is to replace the current late, engine-specific `NullPointerException`/undefined behavior with an early, consistent, user-facing error when reusing a `TestPlan` for multiple executions.