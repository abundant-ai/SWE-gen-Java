Mockito can throw `java.lang.IllegalStateException: The mock object was garbage collected.` during stubbing when using the “one-liner stub” pattern where the mock is created and immediately stubbed/returned without the caller keeping a strong reference until after `getMock()` is called.

This happens in code like:
```java
TestClass m = when(mock(TestClass.class).getStuff())
    .thenReturn("X")
    .getMock();
```
Under memory pressure (e.g., small heap) and/or high iteration counts, the mock may be garbage collected between creating the invocation used for stubbing and calling `getMock()`. When that occurs, `getMock()` (or logic reached while completing the stubbing chain) attempts to resolve the mock via an internal weak reference and fails with:

```
java.lang.IllegalStateException: The mock object was garbage collected. This should not happen in normal circumstances when using public API...
    at org.mockito.internal.invocation.mockref.MockWeakReference.get(...)
    at org.mockito.internal.invocation.InterceptedInvocation.getMock(...)
    at org.mockito.internal.stubbing.InvocationContainerImpl.invokedMock(...)
    ...
```

Expected behavior: one-liner stubbing should be safe; calling `OngoingStubbing.getMock()` after `when(mock(...).method()).thenReturn(...)` should reliably return the created mock and allow subsequent calls on it, even when run in a tight loop and with constrained heap.

Actual behavior: in repeated runs (tens of thousands of iterations) or with large return values that increase GC frequency, the mock can be collected before `getMock()` returns, causing the exception above.

Fix the stubbing flow so that, once `when(...)` has started an ongoing stubbing for an invocation, Mockito maintains a strong reference to the mock for the lifetime of that ongoing stubbing object (i.e., until the user finishes the stubbing call chain and calls `getMock()` or the stubbing object becomes unreachable). `getMock()` must use that strong reference (when available) rather than relying solely on the weak reference stored on the intercepted invocation.

This must work for nested one-liner stubs as well, including patterns where `thenReturn(...)` receives values computed using other one-liner stubs, and cases where a one-liner stub returns another mock created inline. The change should still allow Mockito to avoid long-lived strong references that could reintroduce memory leaks after the stubbing object is no longer in use.