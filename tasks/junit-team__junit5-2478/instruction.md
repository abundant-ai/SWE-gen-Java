Console output in the JUnit Platform Console Launcher uses ANSI styling to highlight execution statuses such as SUCCESSFUL, FAILED, ABORTED, and SKIPPED. Today these styles are effectively fixed (e.g., success maps to green and failure to red), which is problematic for accessibility (e.g., red–green color blindness) and for users who need different contrast or text attributes.

Add support for customizing the ANSI styling used by the console launcher without changing the default appearance.

The console printing code should rely on a palette concept that can “paint” text for a given status/style. Introduce a `Style` concept for the set of paintable console statuses (for example: `Style.SUCCESSFUL`, `Style.FAILED`, etc.) and a `ColorPalette` that maps each `Style` to an ANSI SGR sequence. Callers should be able to do:

```java
String rendered = colorPalette.paint(Style.SUCCESSFUL, "text");
```

Expected behavior of `ColorPalette.paint(style, text)`:
- It wraps `text` with an ANSI prefix and the ANSI reset suffix (`\u001B[0m`).
- For default palettes, the mappings must preserve existing behavior (for example, FAILED renders using `\u001B[31m` by default).
- If ANSI output is disabled via the palette, `paint()` should return the original unmodified `text` (no escape sequences).

Add the ability to override palette entries via a properties-formatted input:
- `ColorPalette` must be constructible from a character stream/reader containing properties.
- Each property key corresponds to a `Style` name and is case-insensitive.
- Unknown keys must be ignored (they must not cause errors and must not affect recognized styles).
- Each property value is a semicolon-delimited list of SGR parameters (e.g., `35;1`), and `paint()` must emit them as `"\u001B[<value>m"`.
- If only some styles are specified, unspecified styles must fall back to the default mappings.

Provide two new console launcher command line options:
- `--color-palette <path>`: loads a properties file that overrides any/all style mappings.
- `--single-color`: switches to a built-in palette variant that uses a single consistent style for statuses (intended to improve accessibility).

Default behavior must remain unchanged when neither option is provided.

The updated styling system must be used consistently by existing console output components (for example, tree printing and verbose tree/listener output) so that statuses and related markers are styled via the selected `ColorPalette`.

Edge cases that must work:
- Status text that contains percent signs or format specifiers (e.g., `"%crash"`) must be printed literally and must not be interpreted as a format string during rendering.
- Palette loading must not throw for irrelevant/junk properties keys.
- Style key parsing must treat `"SUCCESSFUL"`, `"successful"`, and mixed-case variants as equivalent.

Overall, users should be able to run the console launcher and either keep the default colors, use `--single-color` for an accessible single-style output, or pass `--color-palette` to supply precise SGR sequences (including attributes like bold/underline) for individual statuses.