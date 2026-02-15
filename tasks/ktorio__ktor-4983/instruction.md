On Android (and JVM in general), Ktor’s HTTP client does not reliably discover and apply system/global HTTP proxy settings, so requests that should be routed through a configured system proxy are sent directly instead. This breaks environments where outbound traffic must go through a proxy (e.g., Android devices with a proxy configured in network settings, or JVM environments relying on global proxy properties).

When a global HTTP proxy is configured via standard system properties (e.g., `http.proxyHost` and `http.proxyPort`), a client request like `client.get("http://google.com")` should be routed through that proxy. If the proxy points to a reachable proxy server, the response should come from the proxy (for example, returning a body of `"proxy"` when the proxy server is set up to respond that way). Currently, the client may ignore these global settings and not use the proxy.

Additionally, explicitly configured per-client/per-engine proxy settings must take precedence over any globally discovered proxy settings. If global properties point to an invalid proxy (e.g., `http.proxyHost=localhost` and `http.proxyPort=1`) but the engine is configured with `proxy = ProxyBuilder.http(Url("<valid-proxy-url>"))`, the request must use the explicitly configured proxy and succeed. The global proxy must not override the configured one.

Fix the proxy selection logic so that:

- Global/system proxy settings are discoverable and applied automatically where appropriate (including Android proxy discovery).
- Explicitly configured engine proxy (`proxy = ProxyBuilder.http(...)`, etc.) always has priority over any discovered global/system proxy.
- HTTP requests respect these rules consistently for supported engines (at minimum the CIO engine used in these scenarios).

Reproduction example:

```kotlin
val proxyUrl = Url("http://<proxy-host>:<proxy-port>")
System.setProperty("http.proxyHost", proxyUrl.host)
System.setProperty("http.proxyPort", proxyUrl.port.toString())

val body = client.get("http://google.com").body<String>()
// Expected: request routed through proxy, body == "proxy"
```

Priority example:

```kotlin
System.setProperty("http.proxyHost", "localhost")
System.setProperty("http.proxyPort", "1")

val client = HttpClient(CIO) {
    engine {
        proxy = ProxyBuilder.http(Url("http://<valid-proxy-host>:<valid-proxy-port>"))
    }
}

val body = client.get("http://google.com").body<String>()
// Expected: uses configured proxy, not global one; body == "proxy"
```