OAuth authentication currently only supports non-suspending (synchronous) configuration for resolving provider settings and callback URLs. In particular, `OAuthAuthenticationProvider` accepts `providerLookup` and `urlProvider` as regular lambdas, which prevents fetching OAuth/OpenID provider configuration asynchronously (for example, loading per-tenant clientId/clientSecret/endpoints from a database or remote service based on the incoming request).

When building multi-tenant OAuth, developers need to be able to compute these values per request using suspendable code. However, attempting to use suspend functions for `providerLookup` and/or `urlProvider` is not supported by the API and the authentication flow cannot safely invoke asynchronous lookups.

Update the OAuth server auth provider so that both `providerLookup` and `urlProvider` can be provided as suspendable lambdas and are invoked from within the OAuth authentication pipeline in a coroutine context.

The updated behavior should allow configurations like:

```kotlin
install(Authentication) {
  oauth("oauth") {
    providerLookup = { call ->
      // suspendable fetch of OAuthServerSettings based on the request
      resolveSettings(call)
    }
    urlProvider = { call ->
      // suspendable computation of callback URL
      computeCallbackUrl(call)
    }
  }
}
```

Expected behavior:
- `providerLookup` must be able to suspend and return the appropriate `OAuthServerSettings` for the current request.
- `urlProvider` must be able to suspend and return the callback URL for the current request.
- These suspendable providers must be used during the OAuth redirect/authorization initiation flow and any subsequent steps that require the settings/URL.
- Existing configurations that use non-suspending lambdas must continue to work without changes (backward compatibility).

Actual behavior (before the fix):
- Only non-suspending lambdas are supported for `providerLookup` and `urlProvider`, making it impossible to implement asynchronous per-request configuration and blocking multi-tenant setups.

Implement the API changes on `OAuthAuthenticationProvider` (and any related configuration/DSL types used to configure OAuth) to accept suspendable variants while preserving existing non-suspending usage, and ensure the authentication flow correctly calls these suspendable providers per request.