On the Kotlin/JS (browser) engine, HTTP requests made with Ktor’s client cannot use the browser’s cookie storage. As a result, cookies returned by the server are not persisted/sent on subsequent requests, and endpoints that rely on cookie-based state fail even when the server correctly sets cookies and enables credentialed CORS responses.

For example, a server may respond with a Set-Cookie header (e.g., hello-cookie=my-awesome-value) and include headers such as Access-Control-Allow-Credentials: true. After making a request to receive this cookie, a subsequent request to another endpoint on the same host should include the stored cookie in the Cookie header. Currently, requests from the browser engine behave as if cookies are disabled, so follow-up calls that expect cookies either see no cookies at all or fail with authorization/validation errors.

Implement the ability to set browser fetch options on Ktor’s JS client so callers can enable cookie storage by configuring credentials. In particular:

- There must be a supported way to configure the underlying fetch() options used by the JS engine per client or per request.
- It must be possible to set fetch’s credentials option (e.g., "include") so that cookies set by responses are stored by the browser and automatically sent with later requests to the same origin.
- Once enabled, cookie-based flows must work end-to-end: after receiving a cookie from one request, subsequent requests must include it; updating cookie values on the server must be reflected in later requests; sending multiple cookies must preserve all cookie values; and cookie path scoping must be respected (a cookie set for a specific path should be sent for matching subpaths and not for non-matching paths).

The goal is that users of Ktor’s browser client can opt into browser-managed cookies (via fetch credentials/options) without manually parsing Set-Cookie headers and managing cookies themselves.