When running JHipster generators with a blueprint-provided postWriting task, the task callback receives a context object containing a `source` helper used to apply “needle” modifications (for example adding log entries, translations, Liquibase changelogs, cache entries). After the internal change to “don’t use SourceAll by default”, `source` is no longer reliably available or is typed/constructed incorrectly for non-client generators, so blueprint tasks that previously worked can silently do nothing (because calls are optional-chained like `source.addMainLog?.(...)`) or fail at runtime when a specific `source.addX` method is expected.

The generator task typing/inference layer needs to continue providing the correct `source` API for each generator, even when the default “SourceAll” aggregation is not used. In particular, `asPostWritingTask(...)` must ensure that, when invoked by generators such as server, languages, liquibase, and spring-cache, the task context’s `source` exposes the appropriate needle helpers for that generator so that blueprint code like the following works consistently:

```ts
asPostWritingTask(({ source }) => {
  source.addMainLog?.({ name: 'org.test.logTest', level: 'OFF' });
  source.addEntityTranslationKey?.({ translationKey: 'my_entity_key', translationValue: 'My Entity Value', language: 'en' });
  source.addLiquibaseChangelog?.({ changelogName: 'aNewChangeLog' });
  source.addEntryToCache?.({ entry: 'entry' });
});
```

Expected behavior:
- Running the server generator with a blueprint postWriting task that calls `source.addMainLog` results in the corresponding `<logger .../>` entry being inserted into `logback-spring.xml`.
- Running the languages generator with a blueprint postWriting task that calls `source.addEntityTranslationKey` adds the provided translation keys/values to the appropriate `i18n/<lang>/global.json` files.
- Running the liquibase generator with a blueprint postWriting task that calls `source.addLiquibaseChangelog`, `source.addLiquibaseConstraintsChangelog`, and `source.addLiquibaseIncrementalChangelog` inserts the corresponding `<include .../>` entries into `config/liquibase/master.xml`.
- Running the spring-cache generator with a blueprint postWriting task that calls `source.addEntryToCache` and `source.addEntityToCache` modifies the generated cache configuration so that cache creation lines (for the entry and entity/relationships) are present.

Actual behavior:
- After the change to not use the aggregated SourceAll by default, at least some of these `source.add*` methods are missing from the task context for certain generators, causing blueprint tasks to have no effect (when optional chaining is used) or to throw errors if accessed directly.

Fix the generator type/task inference so that the correct per-generator `source` needle API is available in postWriting tasks across the affected generators, without relying on SourceAll as a default catch-all.