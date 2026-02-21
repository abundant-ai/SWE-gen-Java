#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "spotbugs-tests/src/test/java/edu/umd/cs/findbugs/detect"
cp "/tests/spotbugs-tests/src/test/java/edu/umd/cs/findbugs/detect/MultipleInstantiationsOfSingletonsTest.java" "spotbugs-tests/src/test/java/edu/umd/cs/findbugs/detect/MultipleInstantiationsOfSingletonsTest.java"

# Initialize a minimal git repo so eclipsePlugin/build.gradle can call Grgit.open()
# (The .git directory was removed in the Dockerfile after building)
if [ ! -d ".git" ]; then
  git init
  git config user.email "test@test.com"
  git config user.name "Test"
  git add -A
  git commit -m "initial" --allow-empty
fi

# Rebuild projects to pick up any source changes from fix.patch
./gradlew build -x test -x spotlessCheck --no-daemon

# Run only the specific test classes for this PR
./gradlew :spotbugs-tests:test --tests "edu.umd.cs.findbugs.detect.MultipleInstantiationsOfSingletonsTest" --no-daemon -x spotlessCheck
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
