Ktor’s HttpCache client can throw an InvalidCacheStateException when a cached entry exists for a URL and a subsequent response for the same URL returns a different Vary header value (commonly when the first response is 200 and a later revalidation response is 304 Not Modified). This is overly strict in practice because clients cannot control server behavior, and it causes normal requests against misbehaving or inconsistent servers to fail.

Reproduction scenario:
- Make a GET request to a URL that returns 200 OK and includes a Vary header with multiple fields (for example: "Accept-Encoding, Language").
- Later, make another GET that results in a 304 Not Modified for the same URL but the response’s Vary header differs (for example: "Accept-Encoding" only, or otherwise different ordering/entries).

Current behavior:
- The HttpCache plugin treats this as an invalid cache state and throws InvalidCacheStateException, interrupting the request/response flow.

Expected behavior:
- The HttpCache plugin should be lenient when Vary headers differ between cached and revalidated responses.
- Instead of throwing InvalidCacheStateException, it should continue processing by selecting and returning the “best matching” cached response available for the request’s vary keys.
- The mismatch should be reported via logging with a clear message explaining that the server returned inconsistent Vary values and that the client is returning the best matching cache entry (which may not be the correct one per spec).

This must work with typical caching flows using ETag revalidation (304 responses) and should not break normal caching semantics for No-Store/No-Cache/Max-Age cases. The public/private cache storages used by HttpCache should remain usable after such a mismatch (i.e., no exceptions that prevent subsequent requests from succeeding).