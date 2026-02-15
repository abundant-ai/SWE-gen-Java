#!/bin/bash

set -euo pipefail
cd /app/src

patch -p1 < /solution/fix.patch

# Remove files that were renamed by bug.patch but aren't removed by fix.patch
rm -f junit-platform-launcher/src/main/java/org/junit/platform/launcher/tagexpression/ShuntingYardBasedParser.java
rm -f platform-tests/src/test/java/org/junit/platform/launcher/tagexpression/ShuntingYardBasedParserErrorTests.java
rm -f platform-tests/src/test/java/org/junit/platform/launcher/tagexpression/ShuntingYardBasedParserTests.java
