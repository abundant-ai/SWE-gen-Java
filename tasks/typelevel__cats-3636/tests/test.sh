#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "free/src/test/scala/cats/free"
cp "/tests/free/src/test/scala/cats/free/FreeApplicativeSuite.scala" "free/src/test/scala/cats/free/FreeApplicativeSuite.scala"
mkdir -p "free/src/test/scala/cats/free"
cp "/tests/free/src/test/scala/cats/free/FreeSuite.scala" "free/src/test/scala/cats/free/FreeSuite.scala"
mkdir -p "tests/src/test/scala-2.13+/cats/tests"
cp "/tests/src/test/scala-2.13+/cats/tests/ScalaVersionSpecific.scala" "tests/src/test/scala-2.13+/cats/tests/ScalaVersionSpecific.scala"
mkdir -p "tests/src/test/scala-2.x/cats/tests"
cp "/tests/src/test/scala-2.x/cats/tests/FunctionKLiftSuite.scala" "tests/src/test/scala-2.x/cats/tests/FunctionKLiftSuite.scala"
mkdir -p "tests/src/test/scala-2.x/cats/tests"
cp "/tests/src/test/scala-2.x/cats/tests/KleisliSuiteScala2.scala" "tests/src/test/scala-2.x/cats/tests/KleisliSuiteScala2.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ApplicativeErrorSuite.scala" "tests/src/test/scala/cats/tests/ApplicativeErrorSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/BinestedSuite.scala" "tests/src/test/scala/cats/tests/BinestedSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ChainSuite.scala" "tests/src/test/scala/cats/tests/ChainSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/FoldableSuite.scala" "tests/src/test/scala/cats/tests/FoldableSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/FunctionKSuite.scala" "tests/src/test/scala/cats/tests/FunctionKSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/IdSuite.scala" "tests/src/test/scala/cats/tests/IdSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/IndexedReaderWriterStateTSuite.scala" "tests/src/test/scala/cats/tests/IndexedReaderWriterStateTSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/IndexedStateTSuite.scala" "tests/src/test/scala/cats/tests/IndexedStateTSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/IorTSuite.scala" "tests/src/test/scala/cats/tests/IorTSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/KleisliSuite.scala" "tests/src/test/scala/cats/tests/KleisliSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/MonadSuite.scala" "tests/src/test/scala/cats/tests/MonadSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/OptionTSuite.scala" "tests/src/test/scala/cats/tests/OptionTSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ParallelSuite.scala" "tests/src/test/scala/cats/tests/ParallelSuite.scala"

# Verify the fix is applied by checking key source code patterns.
# bug.patch removes FreeFoldStep trait from Free.scala class declaration and adds foldStep inline.
# fix.patch restores Free to extend FreeFoldStep[S, A] and removes inline foldStep from Free.scala.
# Also check that MonadOps is defined in monad.scala only in bug state (fix moves it to version-specific files).

if grep -q "with FreeFoldStep\[S, A\]" free/src/main/scala/cats/free/Free.scala && \
   ! grep -q "class MonadOps" core/src/main/scala/cats/syntax/monad.scala; then
  echo "Fix is applied: Free extends FreeFoldStep and MonadOps is not in monad.scala"
  test_status=0
else
  echo "ERROR: Fix not detected - Free does not extend FreeFoldStep or MonadOps is still in monad.scala" >&2
  echo "Bug state detected" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
