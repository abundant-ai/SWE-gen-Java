JUnit Platform discovery selectors currently cannot express a position within a file (line/column), which prevents file-based test engines (e.g., those executing a single scenario within a feature file) from selecting and running only the test(s) at a specific location.

Add support for a file position (line, and optional column) to discovery selectors so callers can discover a subset of tests inside a single file/resource.

Implement a new public value object `FilePosition` with:

- Factory methods:
  - `FilePosition.from(int line)`
  - `FilePosition.from(int line, int column)`
- Preconditions:
  - `line` must be > 0
  - `column` (when provided) must be > 0
  - Violations must throw `org.junit.platform.commons.PreconditionViolationException`.
- Accessors:
  - `int getLine()`
  - `Optional<Integer> getColumn()` (empty when only a line is provided)
- Parsing support:
  - `static Optional<FilePosition> fromQuery(String query)` parses URI query strings and extracts file position.
  - It must recognize `line=<int>` (required for a position) and optionally `column=<int>`.
  - Unknown parameters must be ignored.
  - If `line` is missing or not a valid positive integer, return `Optional.empty()`.
  - If `line` is valid but `column` is missing or invalid, still return a `FilePosition` with only the line.

Extend `FileSelector` and `ClasspathResourceSelector` to carry an optional `FilePosition`:

- Their constructors must accept the additional `FilePosition` parameter (nullable/optional).
- Each selector must expose the position via an accessor (e.g., `Optional<FilePosition> getFilePosition()` or equivalent), and their equality/hash code must take the file position into account.
  - Two selectors pointing to the same path/resource but different `FilePosition` values must not be equal.
  - Two selectors with the same path/resource and same `FilePosition` must be equal.

Update selector factory methods in `DiscoverySelectors` to allow creating selectors with file positions:

- Ensure it is possible to create a `FileSelector` and `ClasspathResourceSelector` with a `FilePosition`.
- Ensure URI-based selection can express the position through the query string, e.g. `...?line=42` and `...?line=42&column=99`, by using `FilePosition.fromQuery(...)` when building/reading selectors.

Expected behavior examples:

- `FilePosition.from(42).getLine()` returns `42` and `getColumn()` is empty.
- `FilePosition.from(42, 99).getColumn()` contains `99`.
- `FilePosition.fromQuery("line=42")` returns a position with line 42.
- `FilePosition.fromQuery("line=42&column=ZZ")` returns a position with line 42 and no column.
- `FilePosition.fromQuery("?!")` returns empty.
- `new FileSelector("/example/foo.txt", FilePosition.from(1))` must not be equal to `new FileSelector("/example/foo.txt", null)` and must not be equal to `new FileSelector("/example/foo.txt", FilePosition.from(2))`.

The goal is that a caller can select a single test or group of tests within a file-based test resource by specifying a line (and optionally column), without needing to construct engine-specific unique IDs.