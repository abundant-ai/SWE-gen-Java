When using JUnit Jupiter’s `DisplayNameGenerator.IndicativeSentences` (via `@IndicativeSentencesGeneration`), display names for `@Nested` test classes can be generated incorrectly: the beginning of the “indicative sentence” for a nested class may include the enclosing class name (e.g., `EnclosingTest$`) prepended to the nested class’s generated display name. This contradicts the documented behavior, where the nested class’s contribution to the indicative sentence should be based on the nested class’s own display name (for example, after applying `DisplayNameGenerator.ReplaceUnderscores`) and should not be prefixed with the enclosing class name.

Reproduction example:

```java
@IndicativeSentencesGeneration(separator = " -> ", generator = DisplayNameGenerator.ReplaceUnderscores.class)
class DisplayNameGeneratorDemo {

  @Nested
  class A_year_is_a_leap_year {

    @Test
    void if_it_is_divisible_by_4_but_not_by_100() {}
  }
}
```

Expected behavior: the nested container’s display name used as the start (or part) of the indicative sentence is derived solely from the nested class name and generator rules, e.g. `A year is a leap year`, and a nested test would be displayed like `A year is a leap year -> if it is divisible by 4 but not by 100.` (with the configured separator).

Actual behavior: the nested container’s display name incorrectly contains the enclosing class name prefix, e.g. `DisplayNameGeneratorDemo$A year is a leap year`, and the prefixed name then appears in the full indicative sentence output.

Fix `DisplayNameGenerator.IndicativeSentences` (and any related logic it uses to compute container names for indicative sentences) so that, for a test class that forms the beginning of the indicative sentence, the computed display name does not include any enclosing class name prefix. This should work both when `@IndicativeSentencesGeneration` is declared on a top-level test class (and applies to nested classes) and when it is declared directly on a nested test class. The behavior should be consistent for nested containers and their contained tests, honoring the configured `separator` and the configured underlying `DisplayNameGenerator` (such as `ReplaceUnderscores`).