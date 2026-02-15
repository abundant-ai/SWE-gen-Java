Routing trace output currently mixes path selectors and non-path/constraint selectors into a single route rendering, producing hard-to-read traces such as `/route/LocalPortRouteSelector(port=80)/port` where constraint-like selectors appear inline with the path. This makes it difficult to understand which parts of a route are actual path segments versus additional constraints (method, header, port, etc.).

Update routing tracing so that route rendering in traces separates selectors into two groups: (1) path selectors that contribute to the URL path, and (2) constraint selectors that should be displayed as annotations on the path.

When generating the trace text (the per-node lines like `... -> SUCCESS @ ...`), the displayed “@ ...” route should follow the format:

`<path> [<constraint1>, <constraint2>, ...]`

where `<path>` is composed only of path selectors (segments, parameters, wildcards, etc.), and the bracketed list contains all non-path selectors/constraints in a stable, readable form. If there are no constraints, the brackets should be omitted.

For example, a route that conceptually represents `/bar` constrained by HTTP method GET should be rendered like:

`/bar [(method:GET)]`

and a route like `/` constrained by a header should be rendered like:

`/ [(header:a = x)]`

Similarly, a route using local port constraints should be rendered as a normal path with the port constraint in brackets, e.g. `/route/port [LocalPortRouteSelector(port=80)]` (not interleaved within the path).

This change must apply consistently across the full trace output, including both successful and failed branches, and it must not change routing resolution behavior—only the trace formatting. Existing trace lines that previously embedded constraint selectors into the path should now render with the new `path [constraints...]` structure while preserving other trace details such as segment indices, parameter reporting (e.g., `SUCCESS; Parameters [param=[bar]]`), and failure reasons (e.g., `FAILURE "Selector didn't match"`, `FAILURE "Better match was already found"`, `FAILURE "Not all segments matched"`).