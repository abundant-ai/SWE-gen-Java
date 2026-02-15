Tag expressions currently treat `any()` and `none()` as special cases with limited placement, which prevents using them wherever a normal tag token is allowed. As a result, expressions that include `any()`/`none()` in general tag-expression contexts either fail to parse/tokenize correctly or do not behave consistently when used via `TagFilter.includeTags(String...)`.

Update the tag-expression system so that `any()` and `none()` are handled as regular tag-expression operands (i.e., they can appear in all places a tag name can appear) rather than relying on special handling paths.

Expected parsing/tokenization behavior:
- The tokenizer must recognize `any()` and `none()` as single tokens (not split into `any`, `(`, `)`), and they must be usable inside parentheses and next to other operators. For example, tokenizing `!(any())` should yield the tokens `!`, `(`, `any()`, `)`; likewise for `!(none())`.
- The parser must accept `any()` and `none()` as valid operands and preserve normal operator precedence/associativity with `!`, `&`, `|`, and parentheses.
- Parsing `any()` should produce a `TagExpression` whose string form is exactly `any()`.
- Parsing `! none()` should produce a `TagExpression` whose string form is exactly `!none()` (i.e., `none()` is a valid operand for `!` with standard formatting).

Expected filtering semantics when used through `TagFilter.includeTags(String...)`:
- Using an include tag expression of `any()` or `!none()` must include all *tagged* tests (tests without any tags must still be excluded).
- Using an include tag expression of `none()` or `!any()` must include all *untagged* tests (tests with any tag must be excluded).

Currently, the above behaviors are not consistently supported because `any()`/`none()` are not treated uniformly as normal tag operands throughout the tokenizer, parser, and tag filtering logic. Implement the necessary changes so these expressions parse reliably and produce the expected include-filter results.