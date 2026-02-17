`io.ktor.network.sockets.InetSocketAddress` currently doesn’t expose the resolved numeric IP address for the socket address, which makes it hard to retrieve the actual resolved bytes after DNS resolution (e.g., to log or compare the concrete IP used for a connection).

Add a new API `InetSocketAddress.resolveAddress(): ByteArray?` that returns the resolved IP address in network-byte-order form.

The behavior must be platform-specific:

- On JVM, when an `InetSocketAddress` is backed by a resolved `java.net.InetAddress`, `resolveAddress()` should return the result of `InetAddress.getAddress()` (a `ByteArray` of length 4 for IPv4 or 16 for IPv6). If the address is not resolved, it should return `null`.

- On POSIX targets, `resolveAddress()` should return the resolved address bytes when the native socket address has a numeric `ipString`. The implementation must correctly support both IPv4 and IPv6 textual forms by parsing the `ipString` into bytes. If the `ipString` is not a valid IPv4/IPv6 literal, `resolveAddress()` must return `null` rather than throwing.

- On WASM/JS targets, `resolveAddress()` must always return `null`.

To support the POSIX behavior, implement utilities that parse IP literals:

- `parseIPv4String(value: String): ByteArray?` should return a 4-byte array for valid dotted-decimal IPv4 strings (e.g. `"127.0.0.1"`, `"0.0.0.0"`, `"255.255.255.255"`) and return `null` for invalid inputs such as negative octets, octets > 255, non-numeric strings, partial addresses, or IPv6 strings.

- `parseIPv6String(value: String): ByteArray?` should return a 16-byte array for valid IPv6 strings, including zero compression (`"::"`, `"::1"`, `"fe80::1"`, and fully/partially expanded forms like `"2001:db8::ff00:42:8329"`). It must return `null` for invalid inputs such as malformed compression (`":"`, `":::"`), invalid group counts, invalid hex digits (e.g. `"g::1"`), out-of-range groups, empty strings, or IPv4 strings.

Expected behavior examples:

- `parseIPv4String("127.0.0.1")` returns bytes `[127, 0, 0, 1]`.
- `parseIPv4String("256.0.0.0")` returns `null`.
- `parseIPv6String("::")` returns 16 zero bytes.
- `parseIPv6String("2001:0db8:85a3::8a2e:0370:7334")` returns a 16-byte representation of that IPv6 address.
- `parseIPv6String("not an IPv6 string")` returns `null`.

Once implemented, calling `InetSocketAddress.resolveAddress()` on JVM/POSIX should provide the correct resolved IP bytes when available, and return `null` when resolution is unavailable/unsupported or when parsing fails.