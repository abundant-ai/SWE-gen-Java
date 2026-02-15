JWT-based authentication should expose the current user’s database id directly from the access token so applications can retrieve it without an extra request.

Currently, when a JWT is issued/used, the token only reliably contains the username (subject) and authorities. Calling a security helper to obtain the current user id is not supported or returns empty/incorrect results because the JWT does not include a dedicated user-id claim and/or the utility does not read it.

Implement support for a user id claim in JWT and expose it through the security utilities:

- Add a constant claim name for the user id (for example `SecurityUtils.USER_ID_CLAIM`).
- When generating/encoding JWTs for authenticated users, include the authenticated user’s id as a claim under `USER_ID_CLAIM`.
- Add a public API to retrieve the current user id from the Spring Security context when authentication is JWT-based:
  - Imperative stack: `SecurityUtils.getCurrentUserId()` should return an `Optional` containing the id when the current `Authentication` holds a `Jwt` with the `USER_ID_CLAIM` claim, otherwise it should return `Optional.empty()`.
  - Reactive stack: `SecurityUtils.getCurrentUserId()` should return a `Mono` emitting the id when available from a `Jwt` claim, otherwise it should complete empty.

Expected behavior:

- If the current authentication principal is a `Jwt` containing the `USER_ID_CLAIM` claim, `SecurityUtils.getCurrentUserId()` returns that id value (same type as the user primary key used by the application).
- If the claim is missing, or authentication is not JWT-based, `getCurrentUserId()` should not throw and should return empty.
- JWTs created for authenticated users must carry this claim so downstream services can consistently read it.

A minimal example of the desired JWT content is a token with claims including `sub` (login) and `USER_ID_CLAIM` (user id). When such a token is set as the current authentication, calling `SecurityUtils.getCurrentUserId()` should yield the exact id stored in the claim.