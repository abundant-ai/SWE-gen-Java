#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "alleycats-core/src/test/scala/alleycats"
cp "/tests/alleycats-core/src/test/scala/alleycats/SyntaxSuite.scala" "alleycats-core/src/test/scala/alleycats/SyntaxSuite.scala"

# Compile alleycatsCore test sources (SBT will incrementally compile only what changed)
# This will fail in BASE state because SyntaxSuite.scala imports catsSyntaxExtract which doesn't exist
# This will succeed in HEAD state because fix.patch restores the ExtractSyntax trait and extract.scala file
sbt "alleycatsCoreJVM / Test / compile"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
