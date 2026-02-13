#!/bin/bash

set -euo pipefail
cd /app/src

patch -p1 < /solution/fix.patch

# Remove leftover Stream-related files that were created by bug.patch but not cleaned up by fix.patch
rm -f mockwebserver/src/main/kotlin/mockwebserver3/StreamHandler.kt
rm -f mockwebserver/src/main/kotlin/mockwebserver3/internal/duplex/MockStreamHandler.kt
