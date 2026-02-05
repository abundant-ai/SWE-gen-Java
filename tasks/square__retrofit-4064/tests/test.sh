#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
# Note: bug.patch renamed these files, so we copy them back to the new location
mkdir -p "retrofit-converters/kotlinx-serialization/src/test/java/retrofit2/converter/kotlinx/serialization"
cp "/tests/retrofit-converters/kotlinx-serialization/src/test/retrofit2/converter/kotlinx/serialization/KotlinSerializationConverterFactoryBytesTest.kt" "retrofit-converters/kotlinx-serialization/src/test/java/retrofit2/converter/kotlinx/serialization/KotlinSerializationConverterFactoryBytesTest.kt"
cp "/tests/retrofit-converters/kotlinx-serialization/src/test/retrofit2/converter/kotlinx/serialization/KotlinSerializationConverterFactoryStringTest.kt" "retrofit-converters/kotlinx-serialization/src/test/java/retrofit2/converter/kotlinx/serialization/KotlinSerializationConverterFactoryStringTest.kt"
cp "/tests/retrofit-converters/kotlinx-serialization/src/test/retrofit2/converter/kotlinx/serialization/KotlinxSerializationConverterFactoryContextualListTest.kt" "retrofit-converters/kotlinx-serialization/src/test/java/retrofit2/converter/kotlinx/serialization/KotlinxSerializationConverterFactoryContextualListTest.kt"
cp "/tests/retrofit-converters/kotlinx-serialization/src/test/retrofit2/converter/kotlinx/serialization/KotlinxSerializationConverterFactoryContextualTest.kt" "retrofit-converters/kotlinx-serialization/src/test/java/retrofit2/converter/kotlinx/serialization/KotlinxSerializationConverterFactoryContextualTest.kt"

# Touch the files to update timestamps so Gradle recognizes the changes
touch "retrofit-converters/kotlinx-serialization/src/test/java/retrofit2/converter/kotlinx/serialization/KotlinSerializationConverterFactoryBytesTest.kt"
touch "retrofit-converters/kotlinx-serialization/src/test/java/retrofit2/converter/kotlinx/serialization/KotlinSerializationConverterFactoryStringTest.kt"
touch "retrofit-converters/kotlinx-serialization/src/test/java/retrofit2/converter/kotlinx/serialization/KotlinxSerializationConverterFactoryContextualListTest.kt"
touch "retrofit-converters/kotlinx-serialization/src/test/java/retrofit2/converter/kotlinx/serialization/KotlinxSerializationConverterFactoryContextualTest.kt"

# Clean and recompile test classes after copying
rm -rf retrofit-converters/kotlinx-serialization/build/
./gradlew :retrofit-converters:kotlinx-serialization:compileTestKotlin --no-daemon

# Run only the specific test classes
./gradlew :retrofit-converters:kotlinx-serialization:test --tests "retrofit2.converter.kotlinx.serialization.KotlinSerializationConverterFactoryBytesTest" --tests "retrofit2.converter.kotlinx.serialization.KotlinSerializationConverterFactoryStringTest" --tests "retrofit2.converter.kotlinx.serialization.KotlinxSerializationConverterFactoryContextualListTest" --tests "retrofit2.converter.kotlinx.serialization.KotlinxSerializationConverterFactoryContextualTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
