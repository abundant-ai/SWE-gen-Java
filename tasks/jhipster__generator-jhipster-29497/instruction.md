React generation still exposes and/or relies on legacy “needle” APIs (and the legacy control support they depend on), but these legacy APIs are supposed to be fully dropped. After the change, the React generator and its extension points must work without any legacy needle/control API surface, while keeping the supported needle behavior in place via the current (non-legacy) needle mechanisms.

Problem: When running the React generator (including when composed with other generators like a languages generator that customizes webapp translations), the generator must not depend on any legacy needle API or the deprecated legacy control layer. Any attempt to use or load the React generator should succeed without legacy needle/control modules being present or referenced.

Expected behavior: React generation runs successfully using the current needle utilities only. The needle helper functions must continue to support whitespace- and formatting-tolerant content checks and insertions. In particular, the following needle support functions must keep behaving correctly:

- convertToPrettierExpressions(input: string): string should transform patterns so that common Prettier formatting changes do not break matching. For example:
  - "1 2 3" becomes "1[\\s\\n]*2[\\s\\n]*3"
  - ">" becomes ",?\\n?[\\s]*>"
  - "<" becomes "<\\n?[\\s]*"
  - "\\)" becomes ",?\\n?[\\s]*\\)"
  - "\\(" becomes "\\(\\n?[\\s]*"

- checkContentIn(contentToCheck: string, content: string): boolean should throw if either argument is missing, and should return true when contentToCheck is present in content even if whitespace/newlines differ (for example, "bar foo" should be considered present in a string where spacing/newlines were changed).

- createBaseNeedle(...), createNeedleCallback(...), and insertContentBeforeNeedle(...) must remain usable by generators without requiring any legacy needle/control API.

Actual behavior: React generator execution and/or compilation still hits legacy needle/control usage (either through direct imports, legacy wrapper APIs, or legacy control objects passed into tasks). This manifests as failures when legacy APIs are not available, or as type/behavior mismatches where the generator expects legacy control-based injection.

Fix required: Remove the legacy needle API surface for React entirely and ensure React generator code paths use only the current supported needle utilities/callbacks. Ensure generator runs that include shared application setup and composed generators (e.g., a languages generator that overrides translation resolution) still complete successfully after legacy APIs are removed.