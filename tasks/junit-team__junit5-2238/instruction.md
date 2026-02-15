Dynamic tests executed via the hierarchical engine infrastructure cannot currently be run with a custom `EngineExecutionListener` (e.g., to suppress per-child reporting) while still getting correct execution semantics such as failure propagation to the parent and cancellation of remaining child work. Engines that want to “execute silently” are forced to use the global platform listener, which results in every dynamic child being reported individually (potentially thousands of test entries) instead of being aggregated under the parent.

Implement support for running dynamic tests with an explicit listener by adding a new overload on `Node.DynamicTestExecutor`:

```java
Future<?> execute(TestDescriptor testDescriptor, EngineExecutionListener listener);
```

When `execute(...)` is called, the submitted dynamic test must be scheduled and executed in the same way as existing dynamic execution, but all notifications for that dynamic test must be sent to the provided `EngineExecutionListener` instead of implicitly using the default listener.

To enable silent execution, provide an `EngineExecutionListener.NOOP` constant that can be passed to this new overload. `NOOP` must be safe to use anywhere a listener is required and must perform no actions for all listener callbacks.

Additionally, dynamic execution must correctly communicate outcomes back to the parent/container: if any dynamic child execution fails (i.e., results in `TestExecutionResult.Status.FAILED`), the overall parent/container execution must be marked as failed in a way that reflects the child failure even when a custom listener such as `NOOP` is used. Aborted children (e.g., via `TestAbortedException`) must map to an aborted result without incorrectly failing the parent.

Finally, once a failing dynamic child is detected for a given parent, any other pending dynamic child executions for that parent must be cancelled (or prevented from running) so that the system does not continue executing unnecessary work. The `Future` returned from `execute(...)` must allow callers to wait for completion or cancel the submitted dynamic test, and cancellation must not produce spurious listener events.

Error handling requirements: if the provided listener throws an exception during notification, that exception must not crash the executor; it must result in a failed execution outcome being reported for the relevant test/container while still ensuring pending dynamic executions are cancelled appropriately.

Preconditions: `testDescriptor` and `listener` must be validated (non-null), and the API must be documented so that engine authors understand that passing `EngineExecutionListener.NOOP` suppresses per-child reporting while preserving correct parent failure semantics and cancellation behavior.