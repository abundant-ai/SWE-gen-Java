#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp-dnsoverhttps/src/test/java/okhttp3/dnsoverhttps"
cp "/tests/okhttp-dnsoverhttps/src/test/java/okhttp3/dnsoverhttps/DnsRecordCodecTest.kt" "okhttp-dnsoverhttps/src/test/java/okhttp3/dnsoverhttps/DnsRecordCodecTest.kt"

# Rebuild test classes to pick up the changes
./gradlew :okhttp-dnsoverhttps:testClasses --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false

# Run the specific test class from this PR using wildcard pattern
./gradlew :okhttp-dnsoverhttps:test \
    --tests "*DnsRecordCodecTest*" \
    --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
