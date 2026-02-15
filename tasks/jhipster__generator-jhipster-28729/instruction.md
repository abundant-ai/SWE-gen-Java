The Spring Boot “isAuthenticated()” endpoint used to respond with HTTP 204 No Content when the caller is authenticated. This behavior is being flagged as a security/API clarity problem (Sonar: user-controlled data risk) and is also ambiguous for clients because there is no response body to confirm what the endpoint represents.

The endpoint is exposed as `GET /api/authenticate` and is implemented by a controller method named `isAuthenticated()`. When a valid JWT Bearer token is provided, the endpoint should return HTTP 200 OK with a non-empty, explicit response body that indicates authentication succeeded (for example, a plain text message like `"authenticated"`). The response must not include any user-specific information (no username, roles, claims, or token details) to avoid exposing user-controlled or sensitive data.

When the JWT is invalid (expired, malformed, or has an invalid signature), the endpoint must continue to return HTTP 401 Unauthorized.

Concrete expected behavior:
- `GET /api/authenticate` with a valid `Authorization: Bearer <token>` returns `200 OK` and a simple fixed message in the response body (e.g., `authenticated`).
- `GET /api/authenticate` with an invalid/expired/malformed token returns `401 Unauthorized`.
- The endpoint should remain safe and deterministic: it should not echo any request-derived data and should not leak identity information.

Currently, the authenticated case returns `204 No Content`, which must be changed to the explicit `200 OK` response described above while preserving the unauthorized behavior for bad tokens.