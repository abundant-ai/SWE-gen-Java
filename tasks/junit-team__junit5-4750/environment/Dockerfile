FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java JDK 21 (required by build system)
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/junit-team/junit-framework.git src && \
    cd src && \
    (git fetch --depth 1 origin 8fa464e2c8286f3e80b1fd5205a7fb38eb9ad25e || git fetch --depth 1 origin "+refs/pull/4750/head:refs/remotes/origin/pr/4750") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Override toolchain version to use Java 21 instead of 25
RUN echo "toolchainVersion=21" > gradle/gradle-daemon-jvm.properties

# Build the project using Gradle with Java 21
RUN ./gradlew testClasses --no-daemon --no-configuration-cache

# Reset files so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for Java)
RUN ./gradlew testClasses --no-daemon --no-configuration-cache

# Add a test file that requires covariant return types to compile
# This file will fail to compile in the buggy state but succeed after fix.patch
COPY <<EOF /app/src/junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/extension/CovariantReturnTypeTestExtension.java
package org.junit.jupiter.engine.extension;

import java.util.stream.Stream;
import org.junit.jupiter.api.extension.ExtensionContext;
import org.junit.jupiter.api.extension.TestTemplateInvocationContext;
import org.junit.jupiter.api.extension.TestTemplateInvocationContextProvider;

/**
 * Test extension that uses covariant return types.
 * This should only compile if the interface supports Stream<? extends TestTemplateInvocationContext>.
 */
class CovariantReturnTypeTestExtension implements TestTemplateInvocationContextProvider {

    private static class MyInvocationContext implements TestTemplateInvocationContext {
        @Override
        public String getDisplayName(int invocationIndex) {
            return "Test " + invocationIndex;
        }
    }

    @Override
    public boolean supportsTestTemplate(ExtensionContext context) {
        return true;
    }

    @Override
    public Stream<MyInvocationContext> provideTestTemplateInvocationContexts(ExtensionContext context) {
        return Stream.generate(MyInvocationContext::new).limit(1);
    }
}
EOF

WORKDIR /app/src
