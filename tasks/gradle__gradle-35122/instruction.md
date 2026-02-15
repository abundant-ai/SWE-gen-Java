Smoke tests need to be able to publish a Develocity (build scan) from inside the smoke-test-run Gradle build so that long-running tests (notably the Santa Tracker smoke test) can be diagnosed. Currently, smoke tests can take a very long time (up to ~30 minutes) with no build scan available to understand what happened during the build.

Implement support for publishing a build scan during smoke test execution by applying the Develocity plugin to the smoke test build scripts in a safe, deterministic way. Provide a utility that can modify a Gradle settings script file by inserting a `plugins { ... }` block that applies:

```groovy
id("com.gradle.develocity") version("<AutoAppliedDevelocityPlugin.VERSION>")
id("io.github.gradle.develocity-conventions-plugin").version("<AutoAppliedDevelocityPlugin.CONVENTIONS_PLUGIN_VERSION>")
```

The insertion must preserve existing script content and follow these rules:

- If the script starts with a `pluginManagement { ... }` block, the new `plugins { ... }` block must be inserted immediately after that `pluginManagement` block (keeping the original `pluginManagement` block unchanged).
- If there is no `pluginManagement { ... }` block, the new `plugins { ... }` block must be inserted at the top of the file.
- Existing statements (e.g., `includeBuild '../lib'`) must remain exactly as they were, and the resulting script must contain appropriate blank lines between blocks.

When the Santa Tracker smoke test publishes a build scan, it must be tagged with `SantaTrackerSmokeTest` so the scan can be located and filtered by tag.

After the change, running the smoke tests should reliably publish a build scan (when build scan publishing is enabled for the environment) and the settings script modification should produce correct output for both a plain settings script and one that already contains a `pluginManagement` block.