#!/bin/bash

cd /app/src

export CI=true

# Clean Gradle cache to avoid version conflicts
rm -rf /root/.gradle/caches/

# For Oracle: apply fix.patch to restore the entire jaxb3 module
# The bug.patch deleted the entire module, so we need to restore it completely
if [ -f "/solution/fix.patch" ]; then
  patch -p1 --forward --batch < /solution/fix.patch || true

  # fix.patch doesn't restore build.gradle changes, so we need to manually restore them
  # Add jaxb3 version
  sed -i "/      'jaxb': '2.3.1',/a\\      'jaxb3': '3.0.1'," build.gradle

  # Add jaxb3 dependencies
  sed -i "/      'jaxbImpl': \"org.glassfish.jaxb:jaxb-runtime:\${versions.jaxb}\",/a\\      'jaxb3Api': \"jakarta.xml.bind:jakarta.xml.bind-api:\${versions.jaxb3}\",\n      'jaxb3Impl': \"com.sun.xml.bind:jaxb-impl:\${versions.jaxb3}\"," build.gradle

  # Add jaxb3 to animalsniffer exclusion
  sed -i "/            project.path != ':retrofit-converters:jaxb' &&/a\\            project.path != ':retrofit-converters:jaxb3' &&" build.gradle
fi

# Copy HEAD test files from /tests (overwrites BASE state)
# Note: For this task, fix.patch already restores test files, but we copy them anyway
# in case there are any differences
if [ -d "/tests" ]; then
  mkdir -p "retrofit-converters/jaxb3/src/test/java/retrofit2/converter/jaxb"
  cp "/tests/retrofit-converters/jaxb3/src/test/java/retrofit2/converter/jaxb/Contact.java" "retrofit-converters/jaxb3/src/test/java/retrofit2/converter/jaxb/Contact.java" 2>/dev/null || true
  cp "/tests/retrofit-converters/jaxb3/src/test/java/retrofit2/converter/jaxb/JaxbConverterFactoryTest.java" "retrofit-converters/jaxb3/src/test/java/retrofit2/converter/jaxb/JaxbConverterFactoryTest.java" 2>/dev/null || true
  cp "/tests/retrofit-converters/jaxb3/src/test/java/retrofit2/converter/jaxb/PhoneNumber.java" "retrofit-converters/jaxb3/src/test/java/retrofit2/converter/jaxb/PhoneNumber.java" 2>/dev/null || true
  cp "/tests/retrofit-converters/jaxb3/src/test/java/retrofit2/converter/jaxb/Type.java" "retrofit-converters/jaxb3/src/test/java/retrofit2/converter/jaxb/Type.java" 2>/dev/null || true
fi

# Build the modules to ensure test code is compiled (especially important when oracle applies fix)
./gradlew :retrofit-converters:jaxb3:build -x test --console=plain --no-daemon --stacktrace || true

# Run tests for the specific test classes using Gradle
./gradlew :retrofit-converters:jaxb3:test --tests "retrofit2.converter.jaxb.JaxbConverterFactoryTest.*" \
          --console=plain --no-daemon --stacktrace
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
