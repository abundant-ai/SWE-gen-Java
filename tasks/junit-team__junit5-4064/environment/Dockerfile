FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java JDK 21 and JDK 8 (required by build system)
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    openjdk-8-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/junit-team/junit-framework.git src && \
    cd src && \
    (git fetch --depth 1 origin e477e83cce272a84aa86e06c2962bddd58e4f6f4 || git fetch --depth 1 origin "+refs/pull/4064/head:refs/remotes/origin/pr/4064") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Override toolchain version to use Java 21 instead of 25
RUN echo "toolchainVersion=21" > gradle/gradle-daemon-jvm.properties

# Temporarily change snapshot dependency to M2 milestone for building
RUN sed -i 's/openTestReporting = "0.2.0-SNAPSHOT"/openTestReporting = "0.2.0-M2"/' gradle/libs.versions.toml

# Build the jupiter test modules
RUN ./gradlew :jupiter-tests:testClasses --no-daemon --no-configuration-cache

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Reapply M2 version after bug.patch (bug.patch doesn't touch this line but we need M2 to build)
RUN sed -i 's/openTestReporting = "0.2.0-SNAPSHOT"/openTestReporting = "0.2.0-M2"/' gradle/libs.versions.toml

# Rebuild after applying bug.patch (required for Java)
RUN ./gradlew :jupiter-tests:testClasses --no-daemon --no-configuration-cache

WORKDIR /app/src
