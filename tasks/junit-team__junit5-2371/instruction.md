Parameterized test display names can become excessively large when argument values are very long (for example, when a parameter is a multi-megabyte string). This can cause downstream problems such as large build logs and slow remote build cache interactions because the full argument values are embedded into the generated test names.

JUnit Jupiter should automatically truncate argument renderings used in parameterized test display names when they exceed a configurable maximum length.

When a parameterized test uses a display-name pattern with argument placeholders (for example patterns using "{0}", "{1}", "{arguments}", or "{argumentsWithNames}"), any individual argument value that would render to a string longer than the maximum allowed length must be truncated before being inserted into the final display name. The truncation should apply to each argument’s formatted representation (not only to the final concatenated display name), so that a single huge argument does not cause the complete name to explode in size.

Additionally, when the user supplies a display name programmatically (i.e., not via a placeholder pattern), JUnit should still ensure the produced display name is not excessively long by truncating the full produced string to the maximum length.

The behavior must be implemented in the parameterized-test name formatting logic used by JUnit Jupiter (not in user test code). The relevant API involved in formatting is the parameterized name formatter used by the parameterized test extension; specifically, creating a formatter and calling its formatting method (e.g., a class like `ParameterizedTestNameFormatter` with a `format(...)` method, and the parameterized execution path driven by `ParameterizedTestExtension`).

Expected behavior examples:

- Given a pattern like "{0} -> {1}", if the second argument is an extremely long string, the resulting display name should contain a truncated representation of that string rather than the full content.
- Given a pattern that renders the full arguments list (e.g., an arguments placeholder), very long individual argument renderings should be truncated within that list output.
- Truncation must preserve useful context by keeping a prefix of the rendered value and clearly indicating truncation (for example using an ellipsis or a "truncated" marker). The output must be deterministic.
- The maximum length must be configurable (with a sensible default), and the truncation logic must respect that limit.

Currently, JUnit inserts full argument string representations into the display name, which can yield multi-megabyte names. After the fix, formatted display names for parameterized invocations should stay within the configured size limit by truncating long argument values (and, when applicable, the final computed name).