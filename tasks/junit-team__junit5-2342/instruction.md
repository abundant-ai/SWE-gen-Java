JUnit’s CSV-based parameter sources for @ParameterizedTest fail when any CSV column exceeds the univocity parser’s default per-column character limit (4096). In such cases, executing a parameterized test using @CsvSource or @CsvFileSource can throw an exception like:

org.junit.jupiter.params.shadow.com.univocity.parsers.common.TextParsingException: Length of parsed input (4097) exceeds the maximum number of characters defined in your parser settings (4096).
Hint: ... Use settings.setMaxCharsPerColumn(int) ...

There is currently no way for users to configure this maximum characters-per-column limit via JUnit Jupiter’s @CsvSource and @CsvFileSource annotations, so large CSV fields cannot be used even when the user is willing to raise the limit.

Add a new annotation attribute named maxCharsPerColumn to both @CsvSource and @CsvFileSource, so that users can increase (or otherwise configure) the maximum number of characters allowed per CSV column for the underlying CSV parser.

When maxCharsPerColumn is not explicitly set, the behavior must remain unchanged (the effective limit should stay at 4096 characters per column). When maxCharsPerColumn is set to a larger value, CSV input with columns longer than 4096 characters must be parsed successfully for both inline CSV (@CsvSource) and file/resource-based CSV (@CsvFileSource).

The new attribute must be honored by the code that creates/configures the CSV parser used by these providers, so that the configured value is passed through to the underlying parsing settings. Invalid configurations should be rejected via documented preconditions (for example, non-positive values should not be accepted).

Example usage that should work after the change:

@ParameterizedTest
@CsvSource(value = {"<a single column containing more than 4096 characters>"}, maxCharsPerColumn = 10000)
void parsesLongColumns(String value) { ... }

Similarly, @CsvFileSource(maxCharsPerColumn = 10000, resources = "..."/files = "...") should successfully read CSV rows where a column exceeds the default 4096 character limit.