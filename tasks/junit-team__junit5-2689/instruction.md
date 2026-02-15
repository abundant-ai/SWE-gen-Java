JUnit Jupiter’s JRE-based execution conditions are missing explicit support for Java 18. As a result, users cannot reference a `JAVA_18` constant in `org.junit.jupiter.api.condition.JRE`, and JRE range conditions do not correctly model Java 18 when evaluating annotations like `@EnabledOnJre`, `@DisabledOnJre`, `@EnabledForJreRange`, and `@DisabledForJreRange`.

Problem: attempts to use Java 18 in JRE conditions (for example `@DisabledOnJre(JRE.JAVA_18)` or `import static org.junit.jupiter.api.condition.JRE.JAVA_18`) should compile and work, but currently fail because `JAVA_18` is not available (and Java 18 is not treated as a first-class value in the JRE condition logic).

Implement support for Java 18 by adding a `JAVA_18` enum constant to `org.junit.jupiter.api.condition.JRE` and ensuring that all JRE-based condition evaluation correctly recognizes Java 18 as its own version.

Expected behavior:
- `JRE` provides a `JAVA_18` constant that can be referenced from user code.
- When running on Java 18, `JRE.currentVersion()` (or the equivalent internal/current-version lookup used by the conditions) should resolve to `JRE.JAVA_18` rather than `OTHER`.
- `@EnabledOnJre(JRE.JAVA_18)` should enable a test on Java 18 and disable it on other Java versions.
- `@DisabledOnJre(JRE.JAVA_18)` should disable a test on Java 18 and allow it to run on other Java versions.
- Range-based annotations must treat Java 18 correctly in comparisons:
  - `@EnabledForJreRange(min = JRE.JAVA_18, max = JRE.JAVA_18)` enables only on Java 18.
  - `@EnabledForJreRange(min = JRE.JAVA_8, max = JRE.JAVA_18)` includes Java 18.
  - `@DisabledForJreRange(min = JRE.JAVA_8, max = JRE.JAVA_18)` disables on Java 18 as part of the range.

Actual behavior to fix:
- `JAVA_18` cannot be imported/referenced from `JRE` (compilation failure), and/or
- Java 18 is not detected as `JRE.JAVA_18`, causing JRE-specific and range-based enable/disable conditions to behave incorrectly on Java 18.

After the change, Java 18 must be supported consistently across the JRE enum API and all JRE condition evaluations so that enable/disable decisions and version range checks behave as expected on Java 18.