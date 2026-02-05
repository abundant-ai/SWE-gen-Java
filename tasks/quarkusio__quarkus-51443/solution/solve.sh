#!/bin/bash

set -euo pipefail
cd /app/src

# Apply the fix patch
patch -p1 < /solution/fix.patch

# Rebuild after applying fix (required for Java compiled project)
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation -Dtcks -Prelocations \
    -pl extensions/kubernetes/vanilla/deployment,extensions/kubernetes/openshift/deployment,integration-tests/kubernetes/quarkus-standard-way -am \
    clean install
