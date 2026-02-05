Server-side HTTP filters cannot currently be disabled on a per-request basis, which prevents optimizing routing/filter execution and makes it impossible to skip expensive filters when they are not applicable. Add support for conditionally enabling/disabling a server filter based on the current HttpRequest.

A filter bean may implement io.micronaut.http.filter.ConditionalFilter and provide boolean isEnabled(HttpRequest<?> request). When a request is processed, the framework must call isEnabled(request) and only apply the filter’s @RequestFilter and @ResponseFilter methods if isEnabled returns true for that request.

Reproduction scenario:
- Define a @ServerFilter matching all requests, but implement ConditionalFilter.isEnabled(request) to return true only when the request path starts with "/my-filter".
- The filter also has a @RequestFilter method that records an event like "request <uri>" and a @ResponseFilter method that records "response <uri> <status>".

Expected behavior:
- For a request to "/my-filter/index", the filter is enabled and both the request and response filter methods run.
- For a request to "/other-filter/index", the filter is disabled and neither the request filter nor the response filter runs.

Additionally, isEnabled(request) is expected to be consulted during the request lifecycle (including both request and response phases) so that disabled filters do not execute their request/response hooks for that request.

Example expected observable behavior using an event log in the filter:
- After requesting "/my-filter/index", the filter event list should include entries indicating isEnabled was checked for that URI and that both request and response hooks executed.
- After requesting "/other-filter/index", the filter event list should include only entries indicating isEnabled was checked for that URI, and must not include any request/response hook entries.

Implement the necessary changes so that ConditionalFilter.isEnabled(HttpRequest) is respected by the server filter chain for each request.