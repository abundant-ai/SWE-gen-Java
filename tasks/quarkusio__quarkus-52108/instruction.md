When using `quarkus-websocket-next` together with the `quarkus-test-security` extension in test mode, the `SecurityIdentity` associated with a WebSocket connection can incorrectly become anonymous during message handling, even though the HTTP upgrade request was authenticated (for example via an OIDC cookie or another mechanism). This breaks applications that inject `SecurityIdentity` into a WebSocket endpoint and expect the authenticated principal/roles to be available.

Example:

```java
@WebSocket(path = "/heartbeat")
@RolesAllowed("admin")
public class HeartbeatSocket {

    @Inject
    SecurityIdentity identity;

    @OnTextMessage
    public void onMessage(String message) {
        // expected: authenticated user name
        // actual in test mode with quarkus-test-security enabled: anonymous/null user
        Log.infof("Message from %s: %s", identity.getPrincipal().getName(), message);
    }
}
```

Currently, in test mode with `@TestSecurity`, some WebSocket Next scenarios ignore the identity stored on the WebSocket connection and/or only consider the identity that was available at HTTP upgrade time. In particular:

1) If the WebSocket connection has an identity stored on it (from the upgrade/authentication step), WebSocket message invocations should consistently use that identity rather than unexpectedly resolving to an anonymous identity.

2) If proactive authentication is disabled and authentication is performed lazily, WebSockets must also fall back to using `CurrentIdentityAssociation.getDeferredIdentity()` as an identity source (not just the identity captured at upgrade time), so that a non-anonymous identity is available when the endpoint first needs it.

3) With `@TestSecurity(user=...)`, the behavior must be consistent between `CurrentIdentityAssociation.getIdentity()` and `CurrentIdentityAssociation.getDeferredIdentity()`: when the underlying/delegate identity is anonymous (and path-based authentication is not in effect), both direct and deferred identity resolution should return the test identity, not an anonymous identity.

4) Authorization based on annotations such as `@RolesAllowed`, `@Authenticated`, `@PermissionsAllowed`, and custom `@PermissionChecker` must work for WebSockets in test mode with `@TestSecurity`, including cases where path-based authentication is not enabled and the user does not explicitly provide an access token.

The bug is considered fixed when, in Quarkus test mode with `quarkus-test-security` enabled:

- A WebSocket endpoint that injects `SecurityIdentity` observes the authenticated principal (or the `@TestSecurity` identity when applicable) during `@OnOpen` and `@OnTextMessage` execution.
- Attempts to connect to endpoints protected by security annotations are rejected when no identity is available, and accepted when `@TestSecurity` provides an appropriate identity.
- Deferred (lazy) authentication works for WebSockets the same way it works for HTTP: if the identity is not available immediately, it is resolved via `getDeferredIdentity()` and then used for subsequent authorization/injection.
- `@PermissionChecker`-based decisions are applied correctly under `@TestSecurity` in WebSocket scenarios where authentication is not strictly path-based.