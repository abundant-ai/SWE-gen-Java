OSGi bundle manifests produced for JUnit Platform artifacts can contain an invalid (or overly restrictive) version range in the Import-Package header. This shows up when inspecting the bundle’s manifest with bnd/OSGi tooling and attempting to parse the Import-Package attributes: some imported packages have a version attribute that is not a valid OSGi VersionRange (or is constructed with an incorrect upper/lower bound), causing VersionRange parsing to fail.

When iterating over the Import-Package entries from the bundle manifest (e.g., via bnd’s Domain API) and reading the VERSION_ATTRIBUTE ("version"), parsing that string with org.osgi.framework.VersionRange should succeed for every imported package that specifies a version. In other words, for each Import-Package entry where a version attribute is present, this should not throw:

```java
new org.osgi.framework.VersionRange(versionRangeString)
```

Currently, at least one Import-Package entry is emitted with a “bad version range” that breaks this expectation.

Fix the manifest generation so that all Import-Package version attributes use valid OSGi version range syntax and correctly represent the intended compatibility range. After the fix, validating the produced jar manifests should confirm that:

- Every Export-Package entry has a version attribute that can be parsed as an org.osgi.framework.Version.
- Every Import-Package entry that declares a version attribute has a value that can be parsed as an org.osgi.framework.VersionRange without throwing.

The goal is that consuming OSGi tools (and simple validation code using VersionRange) can safely parse all Import-Package version ranges for the published JUnit Platform bundles.