#!/bin/bash

set -euo pipefail
cd /app/src

patch -p1 < /solution/fix.patch

# Fix.patch is missing the build.gradle change to add opentest4j to dependencies
# Add it manually
sed -i 's|compileOnly libraries.junit4, libraries.hamcrest$|compileOnly libraries.junit4, libraries.hamcrest, libraries.opentest4j|' build.gradle
