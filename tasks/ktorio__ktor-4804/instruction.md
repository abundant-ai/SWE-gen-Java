Routing’s `Accept` route selector is evaluated incorrectly, causing requests to be routed to the wrong handler (or not routed) when routes are constrained by the request’s `Accept` header.

When an application defines multiple routes that differ only by an `accept(...)` constraint (e.g., one route for `application/json` and another for `text/plain`), a request with an `Accept` header matching one of the constraints should consistently select the corresponding route. Currently, the `Accept` selector evaluation can produce an incorrect match decision, leading to one of these failures:

- A route guarded by `accept(ContentType.Application.Json)` is not selected even though the request includes `Accept: application/json` (or an equivalent value such as `application/json; charset=UTF-8`).
- A route guarded by `accept(...)` is selected even when the request’s `Accept` header does not match that content type.

Fix the `Accept` route selector evaluation so that it matches based on standard HTTP content negotiation rules used by Ktor:

- Matching must respect media type and parameters appropriately (e.g., `application/json` should match `application/json; charset=UTF-8`).
- Quality values (`q=`) must be handled so that a content type with `q=0` is treated as not acceptable.
- Wildcards in the `Accept` header (such as `application/*` and `*/*`) must be honored in a way that does not incorrectly override a more specific mismatch.

After the fix, when multiple routes exist under the same path/method and they differ by `accept(...)`, sending requests with different `Accept` headers must deterministically route to the correct handler, and sending an `Accept` header that does not allow a route’s content type must not select that route.