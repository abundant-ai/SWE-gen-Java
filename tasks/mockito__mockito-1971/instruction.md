Mockito’s inline mock maker should be able to create mocks (including construction mocks) without relying on Objenesis / Unsafe-based instantiation. Currently, creating certain mocks depends on bypassing constructors via Objenesis; this breaks (or will break) on platforms where Unsafe is unavailable/deprecated and also makes it hard to mock types whose constructors have side effects.

The mock creation logic needs to support “short-wiring” constructors so that user code inside constructors (and side-effecting super(...) argument evaluation) is not executed when Mockito is creating an instance for mocking.

When Mockito creates a mock instance of a class with a constructor like:

```java
class Foo extends Bar {
  Foo() {
    super(somethingWithSideeffect());
  }
}
```

the mock creation flow should ensure that, while a mocked construction is in progress, the constructor body and any side-effecting argument evaluation are suppressed, and the constructor chain is safely completed by calling super constructors with side-effect-free arguments (e.g., null) until reaching `Object`.

This should be controlled by a dispatcher that can determine, using a thread-local signal, whether the current construction should be short-wired. The decision must apply consistently across the entire constructor call chain (subclass and its superclasses) during the same mocked construction attempt.

Expected behavior:
- Creating a mock via the inline mock maker succeeds even for classes that are not constructable via normal means (e.g., problematic constructors) and for JDK/final types supported by inline mocking.
- During mocked construction, user constructor code is not executed (including side effects in `super(...)` argument evaluation), but the JVM still sees a valid constructor chain up to `Object`.
- Outside mocked construction, constructors behave normally and must not be altered in observable behavior.
- The mechanism must be thread-safe: short-wiring must not leak across threads or between separate mock creations.

Actual behavior to fix:
- Mock creation still relies on constructor-bypassing instantiation (Objenesis/Unsafe) and/or ends up executing user constructor code for certain types, causing failures or side effects during mock creation, and making Mockito incompatible with environments where Unsafe is unavailable.

Implement the constructor short-wiring support in the inline mocking stack so that creating mocks through `InlineByteBuddyMockMaker#createMock(...)` works without Objenesis/Unsafe and without executing user constructors when Mockito is performing a mocked construction.