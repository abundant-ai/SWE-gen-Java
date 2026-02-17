Micrometer HTTP server request metrics currently use a route label derived from a route’s string representation that can include non-path routing nodes (for example nodes inserted by authentication/authorization or HTTP method selectors). This produces noisy and unexpected metric tags such as `/(authenticate "default")/uri` instead of the intended clean path like `/uri`.

Implement a simplified route string that represents only the URL path matched by routing, omitting routing nodes that are not part of the path (such as authentication-related nodes and HTTP method nodes). Expose this as an extension property `val RoutingNode.path: String`.

Update Micrometer metrics configuration so that the `route` tag value is configurable via a function property `transformRoute` on `MicrometerMetricsConfig`. By default, Micrometer should use the simplified route string (i.e., `RoutingNode.path`) for the `route` tag. The configuration must allow users to restore the previous behavior by setting `transformRoute { parent.toString() }` (where `parent` is the routing node used for route labeling).

Expected behavior examples:
- For a GET route registered at `/uri`, the recorded timer for `ktor.http.server.requests` must include the tag `route = "/uri"` (not including any authentication/method selector text).
- Route string building must handle trailing slashes and nested constant segments correctly. For example, the string representations should behave like:
  - root segment `"root"` -> `"/root"`
  - child `"simpleChild"` under root -> `"/root/simpleChild"`
  - trailing slash selector under `"/root"` -> `"/root/"`
  - repeated trailing slash selectors should not produce double slashes (still `"/root/"`)
  - a constant segment under a trailing-slash node should still render as a normal segment (e.g., `"/root/simpleChildInSlash"`)
  - adding a trailing slash under that should render `"/root/simpleChildInSlash/"`

Actual behavior to fix: metrics route tags can include unwanted elements (especially from authentication), making the `route` tag differ from the real request path and reducing metric usability.
