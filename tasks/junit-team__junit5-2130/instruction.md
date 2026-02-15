JUnit Platform tag filtering does not currently support a way to select only untagged tests (or only tagged tests) using a tag expression. Users want to be able to run the majority of tests that have no @Tag annotations, while excluding any tests that are tagged (e.g., @Tag("slow"), @Tag("fast")). Existing workarounds require discovering all declared tags and excluding them manually.

Implement support for two special reserved tag expressions, `any()` and `none()`, that can be used anywhere a tag expression is accepted (for example, via `TagFilter.includeTags(String...)`).

Required behavior:

- `any()` must evaluate to true for a test/container that has at least one tag, and false for untagged tests.
- `none()` must evaluate to true for a test/container that has no tags, and false for anything tagged.
- Negation must work with these keywords: `!none()` must be equivalent to `any()`, and `!any()` must be equivalent to `none()`.
- The tokenizer and parser must recognize `any()` and `none()` as reserved keywords/tokens (not as normal tag names split into multiple tokens). These expressions must be parsable both standalone (e.g., `any()`) and inside parentheses and negations (e.g., `!(none())`).
- Parsing must preserve the existing operator precedence and associativity rules (`!` higher than `&`, `&` higher than `|`, `!` right-associative, `&` and `|` left-associative). For example, parsing `! foo & bar` must produce an AST equivalent to `(!foo & bar)`, and `foo | bar & baz` must be equivalent to `(foo | (bar & baz))`.

End-to-end expectations with `TagFilter.includeTags(...)` when executing a test class containing methods with tags `tag1`, `tag2`, one method tagged with both, and one untagged method:

- `includeTags("any()")` and `includeTags("!none()")` must execute all tagged tests (including the doubly-tagged one) and must not execute the untagged test.
- `includeTags("none()")` and `includeTags("!any()")` must execute only the untagged test and must not execute any tagged tests.
- Existing expressions such as `includeTags("tag1")` must continue to work unchanged.

If `any()`/`none()` are not handled correctly, users will observe that tagged/untagged selection via these expressions either matches nothing, matches everything, or fails to parse. Ensure the implementation parses these keywords and evaluates them according to the definitions above.