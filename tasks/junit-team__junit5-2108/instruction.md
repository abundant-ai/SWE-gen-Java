When using JUnit Jupiter’s `@ParameterizedTest` without an explicit `name` pattern, the generated invocation display names only show the argument values (for example: `[3] HttpClient4, 127.0.0.1, /127.0.0.1`). This is hard to interpret when there are multiple parameters, because the output does not indicate which value corresponds to which method parameter.

Update parameterized test display-name formatting so that parameter names can be included in generated invocation names.

Add support for a new name-pattern placeholder named `{arguments_with_names}`. When this placeholder is used, the formatted arguments portion must include each argument paired with its corresponding Java method parameter name, in order, like:

`httpImplementation=HttpClient4, targetHost=127.0.0.1, sourceIp=/127.0.0.1`

The index and display-name placeholders must continue to work as before (e.g., `[{index}] ...` and `{displayName}`), and the existing `{arguments}` placeholder must remain unchanged (values only).

Change the default name pattern for `@ParameterizedTest` so that it uses `{arguments_with_names}` instead of `{arguments}`. This means that, by default, a parameterized invocation display name should become something like:

`[3] httpImplementation=HttpClient4, targetHost=127.0.0.1, sourceIp=/127.0.0.1`

Parameter names must only be included when they are actually available from the compiled bytecode (i.e., the method was compiled such that Java reflection can retrieve real parameter names). If parameter names are not present, formatting must fall back to the current behavior (equivalent to `{arguments}`: values only).

Additionally, `{arguments_with_names}` must ignore parameters whose types mean they are not normal indexed arguments. In particular, parameter name/value pairing must not be produced for parameters of type `ArgumentsAccessor` or for parameters using an `ArgumentsAggregator` (including parameters annotated with `@AggregateWith`). In those cases, `{arguments_with_names}` should behave as if names are not available for those arguments and should not try to synthesize names for them.

The name formatter should continue to properly render complex argument values the same way as today (including arrays and nested arrays) and must remain locale-stable where applicable. If an unsupported placeholder is used in a pattern, it should continue to fail with a clear `JUnitException` indicating the unknown placeholder.