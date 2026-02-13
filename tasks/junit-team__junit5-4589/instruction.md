The JUnit Platform Console Launcher incorrectly reports that no explicit selectors were provided when the `--uid` / `--select-unique-id` option is used as the only selector.

Reproduction: run the console launcher and provide only a unique-id selector via the dedicated option, for example:

`--uid <UNIQUE-ID>` (or `--select-unique-id <UNIQUE-ID>`) with no other selector options.

Actual behavior: the launcher prints the error message:

`Please specify an explicit selector option or use `--scan-class-path` or `--scan-modules``

and fails as if no explicit selectors were supplied.

Expected behavior: providing one or more unique ids via `--uid` / `--select-unique-id` must count as providing explicit selectors. The launcher should proceed to create a `LauncherDiscoveryRequest` containing `UniqueIdSelector` entries for the provided unique ids, and it must not emit the “Please specify an explicit selector option…” error in this scenario.

A workaround currently exists: using the generic `--select uid:<UNIQUE-ID>` form does not trigger the error. The dedicated unique-id option should behave equivalently to the generic `--select uid:...` form in terms of being recognized as an explicit selector.

In addition, when converting the configured discovery options into a discovery request, the internal selector bookkeeping (including `DiscoverySelectorIdentifier` tracking, if present) must include unique-id selectors so that downstream validation/creation logic treats them the same as other explicit selectors (classes, methods, packages, files, directories, URIs, iterations, etc.).