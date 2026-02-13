Discovery issues that occur while processing selectors are not reliably forwarded/reported when running tests via the JUnit Platform Suite Engine.

When a test engine reports selector processing results through the discovery listener (via `selectorProcessed(UniqueId, DiscoverySelector, SelectorResolutionResult)`), failures are supposed to surface as `DiscoveryIssue` entries so that launchers and higher-level engines can display them. This works in “normal” platform discovery flows where `EngineDiscoveryOrchestrator` later reports all collected discovery issues.

However, the Suite Engine does not perform a traditional discovery phase. Instead, it creates an `EngineDiscoveryRequest` that forwards discovery issues to a parent request. In this flow, discovery issues that are created as a consequence of `selectorProcessed(...)` are not forwarded, because they are created “on the side” rather than being emitted through the same `DiscoveryIssueCollector` mechanism that forwards `issueEncountered(...)` events. As a result, users can observe that a discovery issue exists internally but it is not printed/reported by the launcher when running a suite.

Reproduction scenario:
- A custom `DiscoverySelectorIdentifierParser` parses a selector identifier with prefix `"error"` into a `DiscoverySelector` carrying an error message.
- A test engine’s `discover(EngineDiscoveryRequest, UniqueId)` obtains those selectors and calls `discoveryRequest.getDiscoveryListener().selectorProcessed(engineUniqueId, selector, SelectorResolutionResult.failed(new RuntimeException(message)))`.
- When that engine is included via a suite configuration, the selector failure should be reported as a discovery issue (severity `ERROR`) with a message like `"<selector> resolution failed"`, with the original throwable set as the cause, and with an appropriate `TestSource` derived from the selector type.

Actual behavior:
- The selector failure is converted into a discovery issue in some internal collection, but it is not forwarded through the Suite Engine’s request forwarding and thus not reported to the user.

Expected behavior:
- Any failure reported via `selectorProcessed(...)` must result in a `DiscoveryIssue` that is forwarded in the same way as issues reported via `issueEncountered(...)`, including when running through the Suite Engine.
- The forwarding must ensure the parent discovery request/launcher receives the generated issues so they are printed/reported.

Implement the fix so that issue creation (from selector processing results) is separated from issue collection/forwarding, ensuring that issues derived from `selectorProcessed(...)` are emitted through the same reporting/forwarding channel as other discovery issues. Ensure that `DiscoveryIssueCollector.toNotifier().getAllIssues()` includes explicitly encountered issues, and that `DiscoveryIssueReportingDiscoveryListener` reliably turns a failed `SelectorResolutionResult` into a `DiscoveryIssue` with correct severity, message, cause, and source across supported selector types.