Micronaut’s AOP/introduction proxy generation can fail to correctly implement all methods of an introduced interface when the interface contains overloaded methods that differ only by an array vs non-array parameter type (or otherwise require correct array type resolution during method matching).

A concrete failure appears when using an intercepted JDBC Connection (e.g., `ContextualConnection$Intercepted`): frameworks calling `java.sql.Connection` methods such as `prepareStatement(String, int)` can throw a runtime error indicating the intercepted class does not implement the resolved method. The observed error is:

`Receiver class io.micronaut.data.connection.jdbc.advice.ContextualConnection$Intercepted does not define or inherit an implementation of the resolved method 'abstract java.sql.PreparedStatement prepareStatement(java.lang.String, int)' of interface java.sql.Connection.`

This happens because Micronaut incorrectly compares method signatures in a way that does not properly respect array parameter types, leading to incorrect method resolution and missing bridge/forwarding implementations in the generated intercepted class.

Reproduction scenario (simplified):
- Define an interface with multiple overloaded methods, including one overload that takes an `int[]` parameter, e.g.:
  - `String process(String str)`
  - `String process(String str, int intParam)`
  - `String process(String str, int[] intArrayParam)`
- Create an introduction advice (`@Introduction`) and an interceptor (`MethodInterceptor`) that uses `context.getExecutableMethod().invoke(target, context.getParameterValues())` to dispatch to a concrete implementation.
- Obtain the bean from the application context and invoke all overloads.

Expected behavior:
- The intercepted bean must expose and correctly implement all overloads, including the array-typed overload.
- Calling `process("abc")` returns `"process1"`.
- Calling `process("abc", 1)` returns `"process2"`.
- Calling `process("abc", new int[]{1, 2})` returns `"process3"`.
- Similarly, for intercepted JDBC connections used by libraries like JDBI, calls to `Connection.prepareStatement(String, int)` and other overloads must succeed without `NoSuchMethodError`/method-resolution failures.

Actual behavior:
- The generated/intercepted class may omit or mis-resolve methods when overloads involve array types, leading to missing method implementations at runtime and failures like the `prepareStatement(String, int)` error above.

Fix requirement:
- Ensure Micronaut’s method signature comparison / executable-method matching logic correctly distinguishes array parameter types from non-array parameter types so that the AOP introduction/interception machinery generates proxies that implement and dispatch to the correct methods for all overloads.