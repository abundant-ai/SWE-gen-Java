Parallel test execution can become flaky when some tests mutate global JVM state (for example, calling Locale.setDefault(...)) while many other tests read that global state concurrently. Currently, making the mutating test run in the same thread (e.g., via SAME_THREAD semantics) is not sufficient, because other tests may still run concurrently with it, leading to nondeterministic failures and wrong-language/wrong-locale assertions.

Add first-class support for “isolated” tests such that an isolated test never runs concurrently with any other test in the same engine execution. The intended behavior is:

- All test descriptors that are direct or indirect children of the engine descriptor must, by default, participate in a single shared global resource lock identified by the key "__global__".
- By default, this global resource is acquired in READ mode so that normal tests can still run concurrently with each other.
- When a test (or container) is marked with the new Jupiter API annotation @Isolated, its acquisition of the global resource must be upgraded to READ_WRITE, ensuring it is mutually exclusive with all other tests (including those that only read global state).

This must work reliably for:

- @Isolated on a test method: the isolated method must run alone, and other tests must not overlap its execution.
- @Isolated on a test class: all tests in that class must be isolated from all other tests.
- @Isolated used within @Nested classes: isolation must apply correctly within nested hierarchies so that the global lock behavior still prevents overlap with unrelated concurrent tests.

The engine’s locking aggregation rules must continue to behave correctly with existing resource locks:

- If a node has no explicit exclusive resources other than the implicit global default, the lock manager should treat it as needing only the global READ lock.
- If a node has additional explicit @ResourceLock declarations, those locks must be combined with the implicit global lock in a deterministic way.
- When both READ and READ_WRITE are requested for the same resource key (including the global key), the effective lock must be READ_WRITE.

After the change, it should be possible to enable parallel execution globally and mark only the global-state-mutating tests as @Isolated, without having to annotate every other test with a global @ResourceLock(READ). Isolated tests must no longer cause random failures in other concurrently running tests that depend on stable global state.