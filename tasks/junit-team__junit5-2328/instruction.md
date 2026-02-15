JUnit Jupiter’s JRE-based execution conditions do not recognize Java 16 as a distinct supported runtime. As a result, conditional annotations that target specific Java versions (or ranges) cannot correctly enable/disable tests when running on Java 16.

Extend the JUnit Jupiter JRE model to include Java 16 and ensure all JRE-based conditions behave correctly on Java 16.

Specifically:

- Extend the `org.junit.jupiter.api.condition.JRE` enum with a new constant `JAVA_16`.
- Ensure the JRE-detection logic used by Jupiter’s conditions can map a Java 16 runtime to `JRE.JAVA_16`.
- Ensure `@EnabledOnJre(JRE.JAVA_16)` evaluates to enabled when running on Java 16.
- Ensure `@DisabledOnJre(JRE.JAVA_16)` evaluates to disabled when running on Java 16.
- Ensure range-based conditions handle Java 16 correctly:
  - `@EnabledForJreRange(min = JAVA_10)` should be enabled on Java 16.
  - `@DisabledForJreRange(min = JAVA_10)` should be disabled on Java 16.
  - Ranges with `max = JAVA_12` should not treat Java 16 as within the range.

The behavior should remain unchanged for existing versions (`JAVA_8` through `JAVA_15`) and `OTHER`. The goal is that all JRE-conditional annotations (enabled/disabled, single-version and range-based) correctly classify and respond to Java 16 the same way they do for prior feature releases.