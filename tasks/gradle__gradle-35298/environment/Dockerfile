FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (required for Gradle build)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/gradle/gradle.git src && \
    cd src && \
    (git fetch --depth 1 origin 07148ab59d205be948a12a3087cecce57eca24c2 || git fetch --depth 1 origin "+refs/pull/35298/head:refs/remotes/origin/pr/35298") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Configure Gradle to use system Java instead of auto-downloading
ENV ORG_GRADLE_PROJECT_org.gradle.java.installations.auto-detect=false

# Build the declarative-dsl-core module to prepare test dependencies
RUN ./gradlew :declarative-dsl-core:compileTestKotlin

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Kotlin code needs recompilation)
RUN ./gradlew :declarative-dsl-core:compileTestKotlin

RUN rm -rf /app/src/.git

WORKDIR /app/src
