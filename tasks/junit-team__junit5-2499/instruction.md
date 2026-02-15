JUnit Jupiter currently lacks a dedicated assertion for verifying that a value is an instance of a given type while also returning the typed value. Add a new assertion method `Assertions.assertInstanceOf(...)` that is a more informative substitute for `assertTrue(obj instanceof X)`.

The new API must support these overloads:

- `static <T> T assertInstanceOf(Class<T> expectedType, Object actual)`
- `static <T> T assertInstanceOf(Class<T> expectedType, Object actual, String message)`
- `static <T> T assertInstanceOf(Class<T> expectedType, Object actual, Supplier<String> messageSupplier)`

Behavior:

- If `actual` is a non-null instance of `expectedType` (including subclasses / implementing classes), the assertion succeeds and returns `actual` cast to `T`. The returned reference must be the same object as `actual`.
- If `actual` is `null`, the assertion fails by throwing `org.opentest4j.AssertionFailedError`.
- If `actual` is non-null but not an instance of `expectedType`, the assertion fails by throwing `org.opentest4j.AssertionFailedError`.
- The failure message must clearly indicate that the value is not an instance of the expected type and should include both the expected type and the actual runtime type (or `null` when the value is null). The message should be more helpful than a raw `assertTrue(instanceof)` failure.
- When a custom message (string or supplier) is provided, it must be incorporated in the standard JUnit assertion message formatting.

Type-specific scenarios that must behave correctly:

- Expecting a subclass when given a superclass instance must fail (e.g., expecting `SubClass` but value is `BaseClass`).
- Expecting a superclass/interface when given a subclass/implementing instance must succeed.
- The assertion must work for exception types as well (e.g., expecting `RuntimeException` should succeed for an `IllegalArgumentException`, but expecting `IllegalArgumentException` should fail for a plain `RuntimeException`).

Also ensure method preconditions are enforced and documented in Javadoc (e.g., `expectedType` must not be null), and annotate the public API appropriately for JUnit Jupiter.