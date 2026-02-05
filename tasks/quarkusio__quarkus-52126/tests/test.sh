#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
# No test files to copy

# The fix.patch removed the main AppArtifact classes but didn't delete the test file
# We need to manually delete it as it's part of the fix
rm -f independent-projects/bootstrap/app-model/src/test/java/io/quarkus/bootstrap/model/AppArtifactCoordsTest.java

# Verify that the deprecated AppArtifact classes have been removed
# The fix should have deleted these files
deprecated_classes=(
  "independent-projects/bootstrap/app-model/src/main/java/io/quarkus/bootstrap/model/AppArtifact.java"
  "independent-projects/bootstrap/app-model/src/main/java/io/quarkus/bootstrap/model/AppArtifactCoords.java"
  "independent-projects/bootstrap/app-model/src/main/java/io/quarkus/bootstrap/model/AppArtifactKey.java"
  "independent-projects/bootstrap/app-model/src/main/java/io/quarkus/bootstrap/model/AppDependency.java"
  "independent-projects/bootstrap/app-model/src/test/java/io/quarkus/bootstrap/model/AppArtifactCoordsTest.java"
)

all_removed=true
for class_file in "${deprecated_classes[@]}"; do
  if [ -f "$class_file" ]; then
    echo "FAIL: Deprecated class still exists: $class_file" >&2
    all_removed=false
  fi
done

# Also verify that the references to AppArtifactKey have been removed from other files
if grep -q "AppArtifactKey" core/deployment/src/main/java/io/quarkus/deployment/ApplicationArchive.java; then
  echo "FAIL: AppArtifactKey reference still exists in ApplicationArchive.java" >&2
  all_removed=false
fi

if grep -q "AppArtifactKey" core/deployment/src/main/java/io/quarkus/deployment/ApplicationArchiveImpl.java; then
  echo "FAIL: AppArtifactKey reference still exists in ApplicationArchiveImpl.java" >&2
  all_removed=false
fi

if [ "$all_removed" = true ]; then
  echo "PASS: All deprecated AppArtifact classes and references have been removed" >&2
  echo 1 > /logs/verifier/reward.txt
  exit 0
else
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi
