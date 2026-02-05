Running the Micronaut Core build under newer JDKs (e.g., Java 21) is currently inconsistent: even when the build is launched with a newer JDK, compilation is performed using a Java 17 toolchain, and the test JVM ends up effectively behaving like Java 17 as well. This prevents validating runtime-dependent behavior (such as Loom/virtual-thread related features) under the actual JDK that started the build.

The build must be adjusted so that:

- All Java/Groovy compilation continues to use the Java 17 toolchain (to keep the project’s compilation target consistent).
- Test execution (i.e., the JVM used to run unit/integration tests) uses the same JDK that started the build (the “current JDK”), not the Java 17 toolchain.

This matters because several runtime behaviors and expectations depend on the runtime JDK version. For example:

- `io.micronaut.scheduling.LoomSupport.isSupported()` and runtime detection via `Runtime.version().feature()` must reflect the JDK used to run tests, not the compilation toolchain.
- When running tests on JDK 17, behavior should match the non-virtual-thread environment (e.g., no `virtual` executor configuration; thread selection uses platform executors).
- When running tests on JDKs newer than 17 that support virtual threads, behavior should include the virtual-thread-backed executor where applicable, and thread selection results should reflect that.

Concretely, scenarios that must work:

1) Executor configuration visibility should vary by runtime JDK:
- When an application context is started and executor configurations are queried via `ApplicationContext.getBeansOfType(io.micronaut.scheduling.executor.ExecutorConfiguration)`, the set of executor configuration bean names must include `virtual` only when the runtime JDK supports it; on Java 17 it must not include `virtual`.

2) Thread selection behavior should vary by runtime JDK:
- When using `io.micronaut.scheduling.executor.ThreadSelection.AUTO` or `ThreadSelection.BLOCKING`, blocking routes should run on IO threads on Java 17, but on newer JDKs may run on virtual executor threads (while nonblocking routes remain on the Netty event loop).

3) Java version requirement messages must reflect the runtime JDK:
- When a bean is disabled due to `@Requires(sdk=Requires.Sdk.JAVA, version="800")`, the thrown `io.micronaut.context.exceptions.NoSuchBeanException` message must include the actual runtime major version in the line:
  `- Java major version [<runtime feature version>] must be at least 800`
  where `<runtime feature version>` equals `Runtime.version().feature()` of the JVM executing the tests.

Currently, when the build is started with a newer JDK, these runtime-dependent checks behave as if tests are running on Java 17 (because the test tasks are effectively tied to the toolchain), causing mismatches in executor/threading behavior and in messages that embed `Runtime.version().feature()`.

Update the build/test execution setup so tests run on the current JDK used to start the build, while keeping compilation on the Java 17 toolchain, ensuring all runtime-JDK-dependent behaviors above are validated correctly under Java 21 (or any current JDK) without changing the compilation toolchain.