#!/bin/bash

set -euo pipefail
cd /app/src

patch -p1 < /solution/fix.patch

# Rebuild after applying fix.patch (required for Java)
./mvnw -B install -DskipTests=true -Dmaven.javadoc.skip=true -pl guava,guava-testlib,guava-tests -am
./mvnw -B install -DskipTests=true -Dmaven.javadoc.skip=true -f android/pom.xml -pl guava,guava-testlib,guava-tests -am
