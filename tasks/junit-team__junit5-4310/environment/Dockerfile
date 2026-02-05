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
    (git fetch --depth 1 origin 05c59586b4774df3f512ee984b5e5b4b887ad939 || git fetch --depth 1 origin "+refs/pull/4310/head:refs/remotes/origin/pr/4310") && \
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

WORKDIR /app/src
