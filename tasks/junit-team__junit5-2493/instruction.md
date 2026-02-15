JUnit Jupiter’s JRE-based execution conditions need to recognize Java 17 as a first-class runtime.

Currently, when running tests on a Java 17 JVM, the JRE detection used by the JRE-based conditions does not map the running runtime to a dedicated `JRE.JAVA_17` value. As a result, conditions and annotations that are configured to enable/disable on Java 17 behave incorrectly (often treating Java 17 as `OTHER`, or as an out-of-range version), which can cause tests annotated for Java 17 to be unexpectedly skipped or executed.

Implement `JRE.JAVA_17` end-to-end so that JUnit’s JRE conditions work correctly on Java 17:

- The `org.junit.jupiter.api.condition.JRE` enum must include a `JAVA_17` constant.
- The logic that detects the current runtime and resolves it to a `JRE` value must correctly return `JRE.JAVA_17` when the JVM is Java 17.
- The JRE-based annotations/conditions must correctly honor Java 17 in all supported forms:
  - `@EnabledOnJre(JRE.JAVA_17)` should evaluate to enabled when running on Java 17.
  - `@DisabledOnJre(JRE.JAVA_17)` should evaluate to disabled when running on Java 17.
  - Range-based conditions must correctly include/exclude Java 17 depending on bounds:
    - `@EnabledForJreRange(min = ..., max = ...)` should enable when Java 17 is within the range.
    - `@DisabledForJreRange(min = ..., max = ...)` should disable when Java 17 is within the range.
    - Open-ended ranges (only `min` or only `max`) must treat Java 17 consistently with other versions.

The change must ensure that Java 17 is treated as its own version (not `OTHER`) and that comparisons/order used for range checks place Java 17 after Java 16 and before any future/unknown versions.