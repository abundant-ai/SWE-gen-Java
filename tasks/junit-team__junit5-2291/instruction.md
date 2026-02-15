JUnit Jupiter’s `org.junit.jupiter.api.Assertions.assertLinesMatch(...)` currently supports comparing ordered lines only via `List<String>` overloads. With Java 11, users commonly work with line content as `Stream<String>` (for example via `String#lines()`), but there are no `Stream<String>` overloads of `assertLinesMatch`, forcing callers to manually collect streams into lists before asserting.

Add new `assertLinesMatch` overloads that accept `Stream<String>` for both expected and actual lines, so callers can write assertions like:

```java
Assertions.assertLinesMatch(Stream.of("first", "second"), "first\nsecond".lines());
```

Implement the following overloads on `org.junit.jupiter.api.Assertions`:

- `assertLinesMatch(Stream<String> expectedLines, Stream<String> actualLines)`
- `assertLinesMatch(Stream<String> expectedLines, Stream<String> actualLines, String message)`
- `assertLinesMatch(Stream<String> expectedLines, Stream<String> actualLines, Supplier<String> messageSupplier)`

Behavior requirements:

- These new overloads must behave identically to the existing `List<String>`-based `assertLinesMatch` methods (same matching semantics for plain equality, regex patterns, and the existing fast-forward markers), differing only in accepted parameter types.
- The methods must enforce the same preconditions as the existing API. In particular, passing `null` for `expectedLines` or `actualLines` must fail with JUnit’s precondition violation mechanism (i.e., a `PreconditionViolationException`), consistent with other JUnit Jupiter assertions.
- The `message` / `messageSupplier` variants must integrate with failure reporting the same way the existing overloads do (message included in the resulting assertion failure), and `messageSupplier` must not be evaluated when the assertion passes.
- The overloads should consume each input stream and compare the collected line sequences in encounter order. (It’s acceptable that a stream can only be consumed once; the API should not attempt to reuse it.)

After this change, users should be able to pass `String#lines()` directly as the actual lines and an arbitrary `Stream<String>` as the expected lines, without having to manually convert either to a list, while getting the same assertion failures and messages as the existing list-based API.