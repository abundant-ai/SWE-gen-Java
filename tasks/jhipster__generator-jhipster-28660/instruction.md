Newly generated JHipster 8 gateway + microservice setups can show an empty/blank Swagger UI at `/admin/docs` (for example when running locally with Docker and OAuth2/Keycloak). The page loads, but no OpenAPI definition is rendered.

The generated application should reliably display API documentation in the Swagger UI when users navigate to `/admin/docs`. If the primary OpenAPI endpoint cannot be loaded (for example due to gateway routing, service discovery timing, or other transient failures), the UI should attempt a sensible fallback URL so that docs are still shown instead of a blank page.

In addition, the reactive stack’s BlockHound integration should not flag Springdoc/OpenAPI-related internal calls as illegal blocking operations. The generated `JHipsterBlockHoundIntegration` (implements `reactor.blockhound.integration.BlockHoundIntegration`) should allow the specific Springdoc method(s) that otherwise trigger BlockHound violations during startup/runtime, so that enabling BlockHound doesn’t break OpenAPI/Swagger behavior.

Finally, server-side exception translation should produce useful logs when errors occur during request handling related to docs endpoints. The `ExceptionTranslator` should log translated exceptions so that when `/admin/docs` fails to render due to backend errors, developers have actionable information in the application logs (instead of silent failures leading to a blank UI).

Reproduction scenario:
1) Generate a JHipster 8 gateway + microservice architecture using OAuth2 (Keycloak) and run locally (often via Docker Compose).
2) Visit `http://localhost:8080/admin/docs`.

Expected behavior:
- Swagger UI renders and shows the OpenAPI definition for the application APIs.
- If the default OpenAPI URL is not reachable, the UI tries a fallback OpenAPI URL and still renders documentation.
- With BlockHound enabled, Springdoc/OpenAPI does not trigger BlockHound errors that prevent docs from working.
- When an error does occur in docs-related requests, `ExceptionTranslator` logs the exception details.

Actual behavior:
- `/admin/docs` displays a blank page with no API documentation rendered, with insufficient logging to diagnose the failure in some setups.