#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/OptionTSuite.scala" "tests/src/test/scala/cats/tests/OptionTSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/TrySuite.scala" "tests/src/test/scala/cats/tests/TrySuite.scala"

# Verify that MonadThrow and ApplicativeThrow type aliases are defined in cats/package.scala.
# bug.patch removes these type aliases; fix.patch restores them.

if grep -q "type ApplicativeThrow" core/src/main/scala/cats/package.scala && \
   grep -q "type MonadThrow" core/src/main/scala/cats/package.scala; then
  echo "ApplicativeThrow and MonadThrow type aliases found in cats/package.scala - aliases are present"
  test_status=0
else
  echo "ERROR: ApplicativeThrow or MonadThrow type aliases not found in cats/package.scala" >&2
  echo "These type aliases are missing - bug state detected" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
