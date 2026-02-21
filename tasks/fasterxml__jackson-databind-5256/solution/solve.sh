#!/bin/bash

set -euo pipefail
cd /app/src

# Apply the fix patch
patch -p1 < /solution/fix.patch

# Recompile the Java source code (Java is compiled)
./mvnw -B -ntp clean test-compile -DskipTests
