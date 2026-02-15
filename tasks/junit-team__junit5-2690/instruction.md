JUnit emits a number of log messages at INFO level through its internal logging facade. When users (or tools like IDEs/Gradle) do not explicitly configure logging, Java Util Logging is used by default and INFO messages are emitted to System.err. In environments like IntelliJ IDEA, stderr output is often rendered in red, making normal JUnit operation look like failures or warnings.

The logging produced during normal test execution/discovery needs to be less noisy by default. In particular:

- Messages that report normal, non-error situations (for example, mismatch/exclusion reasons during discovery such as “X containers and Y tests were Method or class mismatch”) should not be logged at INFO level.
- Messages that report routine configuration behavior (for example, when an engine instantiates a default component based on a configuration parameter) should also not be logged at INFO level.

Update JUnit’s logging so that these routine messages are logged at CONFIG level instead of INFO. The change must be applied consistently anywhere JUnit currently calls `Logger.info(...)` for these kinds of messages, switching them to `Logger.config(...)`.

After the change, when a caller installs a `LogRecordListener` (or otherwise captures JUL log records) and triggers the relevant code paths, the created `LogRecord` entries must have level `java.util.logging.Level.CONFIG` (not `Level.INFO`) while preserving the existing message text.

One concrete scenario that must work: when `InstantiatingConfigurationParameterConverter.get(ConfigurationParameters, String)` instantiates a configured class for the key `junit.jupiter.displayname.generator.default`, it should emit a log record at CONFIG level with the message:

"Using default display name generator 'org.junit.jupiter.engine.descriptor.CustomDisplayNameGenerator' set via the 'junit.jupiter.displayname.generator.default' configuration parameter."

The intent is that, with default logging configuration, these messages no longer appear as INFO output on stderr, reducing confusion during normal test runs.