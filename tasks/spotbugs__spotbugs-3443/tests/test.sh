#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "spotbugs-tests/src/test/java/edu/umd/cs/findbugs/detect"
cp "/tests/spotbugs-tests/src/test/java/edu/umd/cs/findbugs/detect/Issue872Test.java" "spotbugs-tests/src/test/java/edu/umd/cs/findbugs/detect/Issue872Test.java"

# Initialize a minimal git repo so eclipsePlugin/build.gradle can call Grgit.open()
# (The .git directory was removed in the Dockerfile after building)
if [ ! -d ".git" ]; then
  git init
  git config user.email "test@test.com"
  git config user.name "Test"
  git add -A
  git commit -m "initial" --allow-empty
fi

# Use a working sonarqube plugin version (6.3.0.5676 is not available in Gradle Central Plugin Repository)
sed -i "s/id 'org.sonarqube' version '6.3.0.5676'/id 'org.sonarqube' version '6.3.1.5724'/" build.gradle

# Replace the unavailable BCEL 6.11.0-SNAPSHOT with the released stable version
sed -i "s|org.apache.bcel:bcel:6.11.0-20250706.125103-7|org.apache.bcel:bcel:6.11.0|g" spotbugs/build.gradle

# Rebuild projects to pick up source changes, excluding SpotBugs analysis tasks
# to avoid pre-existing SpotBugs warnings from causing build failures
./gradlew build -x test -x spotlessCheck -x spotbugsMain -x spotbugsGui -x spotbugsTest --no-daemon

# Run only the specific tests for this PR
./gradlew :spotbugs-tests:test \
  --tests "edu.umd.cs.findbugs.detect.Issue872Test" \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
