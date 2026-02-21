#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "spotbugs/src/main/java/edu/umd/cs/findbugs/detect"
cp "/tests/spotbugs/src/main/java/edu/umd/cs/findbugs/detect/InvalidJUnitTest.java" "spotbugs/src/main/java/edu/umd/cs/findbugs/detect/InvalidJUnitTest.java"

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

# Rebuild projects to pick up source changes, excluding SpotBugs analysis tasks
# to avoid pre-existing SpotBugs warnings from causing build failures
./gradlew build -x test -x spotlessCheck -x spotbugsMain -x spotbugsGui -x spotbugsTest --no-daemon

# Check that unused local variables introduced by the bug have been removed from modified files.
# These specific unused locals were introduced by the bug patch and must be absent in the fixed code.
BUGS_FOUND=0

# StackMapAnalyzer: unused 'reg' variable added by bug, removed by fix
if grep -q "int reg = 0;" spotbugs/src/main/java/edu/umd/cs/findbugs/StackMapAnalyzer.java 2>/dev/null; then
  echo "FAIL: unused 'reg' variable still present in StackMapAnalyzer.java" >&2
  BUGS_FOUND=1
fi

# FieldSummary: unused 'fields', 'removed', 'retained' variables added by bug, removed by fix
if grep -q "int fields = 0;" spotbugs/src/main/java/edu/umd/cs/findbugs/ba/FieldSummary.java 2>/dev/null; then
  echo "FAIL: unused 'fields' variable still present in FieldSummary.java" >&2
  BUGS_FOUND=1
fi

# DescriptorFactory: unused 'bad' variable added by bug, removed by fix
if grep -q "int bad = 0;" spotbugs/src/main/java/edu/umd/cs/findbugs/classfile/DescriptorFactory.java 2>/dev/null; then
  echo "FAIL: unused 'bad' variable still present in DescriptorFactory.java" >&2
  BUGS_FOUND=1
fi

# InvalidJUnitTest: unused 'foundTest' variable added by bug, removed by fix
# (Note: test.sh copies HEAD version of this file, which already has this removed)
if grep -q "boolean foundTest = false;" spotbugs/src/main/java/edu/umd/cs/findbugs/detect/InvalidJUnitTest.java 2>/dev/null; then
  echo "FAIL: unused 'foundTest' variable still present in InvalidJUnitTest.java" >&2
  BUGS_FOUND=1
fi

if [ "$BUGS_FOUND" -gt 0 ]; then
  echo 0 > /logs/verifier/reward.txt
  exit 1
else
  echo "PASS: All unused local variables have been removed from modified files" >&2
  echo 1 > /logs/verifier/reward.txt
  exit 0
fi
