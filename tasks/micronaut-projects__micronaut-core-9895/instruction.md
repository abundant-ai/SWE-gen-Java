When troubleshooting service health, it’s currently difficult to see which specific health indicator is preventing the overall status from being UP unless HTTP-level debug logging is enabled (e.g., enabling `io.micronaut.http` debug). The management health components should emit targeted logs for individual health indicator results so operators can diagnose failures even when `endpoints.health.details-visible` (or exposing details in the HTTP response) is unavailable.

Implement trace/debug logging for health check results in both the health aggregation flow and the periodic health monitoring flow.

In `io.micronaut.management.health.aggregator.DefaultHealthAggregator`, after computing each individual health indicator result that contributes to the aggregated health response, log a single line per indicator:

- At INFO level: no health-result logs should be emitted.
- At DEBUG level: emit exactly one log line per indicator in the form:
  - `Health result for <indicatorName>: status <STATUS>`
  Where `<indicatorName>` is the health indicator identifier (examples include `diskSpace`, `jdbc`, `jdbc:h2:mem:oneDb`, `liveness`, `readiness`, `service`, and `compositeDiscoveryClient()`) and `<STATUS>` is the computed status (e.g., `UP`).
- At TRACE level: emit exactly one log line per indicator that includes details as well:
  - `Health result for <indicatorName>: status <STATUS>, details <DETAILS>`
  `<DETAILS>` must render as a map-like structure, e.g. `details { ... }`, and for indicators without details it should still log `details {}`.

In `io.micronaut.management.health.monitor.HealthMonitorTask`, emit similar logs for results produced by the monitor:

- At INFO level: no health-monitor logs should be emitted.
- At DEBUG level:
  - Emit `Starting health monitor check` when a monitor run begins.
  - Emit one line per indicator result in the form:
    - `Health monitor result for <indicatorName>: status <STATUS>`
- At TRACE level: similarly include details:
  - `Health monitor result for <indicatorName>: status <STATUS>, details <DETAILS>`
  Details must be present in the message and empty details must render as `details {}`.

The logging must be gated strictly by the logger level so that INFO produces no messages, DEBUG produces only the status-only messages (plus the monitor start message), and TRACE produces the status+details form. The log output should be stable and not introduce additional extra log lines beyond those described above, because consumers rely on these messages for troubleshooting.