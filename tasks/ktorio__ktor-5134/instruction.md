OAuth authentication currently mishandles certain real OAuth failures by responding with an authentication challenge (401) instead of falling back to the next authentication mechanism/route logic.

In particular, when an OAuth2 flow fails due to an error during token exchange (for example, the OAuth provider rejects the client credentials and the token endpoint returns an error such as invalid client/invalid client secret), the Ktor OAuth authentication provider treats this as a normal authentication challenge failure and immediately produces a 401 response. This prevents applications from implementing alternative handling (for example, trying another authentication provider, or continuing the request as an unauthenticated user in a controlled way).

Ktor already supports `authenticate(optional = true)`, but that behavior is not correct for OAuth failure handling: `optional` is intended to skip challenges only when no credentials were provided at all (guest requests), not when an actual OAuth attempt happened and failed.

The OAuth authentication provider should distinguish between authentication failure causes and apply fallback behavior only for the “error” case:

- When the failure cause is `AuthenticationFailedCause.NoCredential`, it should behave as the start of the OAuth flow (i.e., initiate the OAuth redirect/challenge as it does today).
- When the failure cause is `AuthenticationFailedCause.InvalidCredentials`, it should behave as a restart of the OAuth flow (i.e., initiate the OAuth redirect/challenge as it does today).
- When the failure cause is `AuthenticationFailedCause.Error`, it should not immediately produce a 401 challenge response. Instead, it should trigger fallback so that the authentication pipeline can continue and other authentication providers (or subsequent application logic) can run.

After this change, an OAuth token exchange failure (such as invalid client secret) must no longer force a 401 response by default; it must be possible for the request to proceed to fallback behavior based on `AuthenticationFailedCause.Error`.

This should work for OAuth2 (and the OAuth auth feature generally) in a way that preserves existing redirect behavior for “no credential” and “invalid credentials” cases while enabling fallback only for the “error” case.