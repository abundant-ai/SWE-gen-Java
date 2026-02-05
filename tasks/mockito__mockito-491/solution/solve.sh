#!/bin/bash

set -euo pipefail
cd /app/src

# Apply the patch
patch -p1 < /solution/fix.patch

# Manually delete files that the patch marks as deleted (patch command doesn't auto-delete with git-format patches when .git is removed)
rm -f src/main/java/org/mockito/internal/util/reflection/Whitebox.java
rm -f src/test/java/org/mockito/internal/util/reflection/WhiteboxTest.java
