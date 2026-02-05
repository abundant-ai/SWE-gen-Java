OkHttp’s connection setup code includes an argument named `tunnelProxy` that is no longer used, but it is still part of the internal call chain for creating connections through proxies (including HTTPS-over-HTTP proxy tunneling). This unused parameter is being threaded through multiple methods/constructors, creating API noise and making it harder to evolve platform/SSL behavior.

Remove the unused `tunnelProxy` argument from the relevant internal APIs and ensure all call sites are updated accordingly, without changing runtime behavior.

After this change, core TLS/JSSE/OpenJSSE flows must still work as before:

- A client must be able to establish an HTTPS connection to a server using JSSE and negotiate the expected TLS version (including TLS 1.3 on supported runtimes) and HTTP/2 when available.
- OpenJSSE support must continue to work: `OpenJSSEPlatform.buildIfSupported()` should return a non-null platform when OpenJSSE is present, and requests made using that platform should successfully complete handshakes.
- Hostname-based “insecure host” configuration must continue to behave correctly: connections to hosts listed as insecure should succeed even when untrusted, but connections with certificates that are invalid for the host should still fail with an `SSLException`.

The change should be purely API cleanup: removing `tunnelProxy` must not introduce regressions in proxy tunneling, TLS negotiation, protocol selection, or handshake/cipher reporting returned by OkHttp’s `Response.handshake` and `Response.protocol` fields.