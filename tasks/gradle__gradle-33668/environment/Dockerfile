FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (used by Gradle build)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/gradle/gradle.git src && \
    cd src && \
    (git fetch --depth 1 origin 7e3d97c72892094e17643c0215aa0143220fa578 || git fetch --depth 1 origin "+refs/pull/33668/head:refs/remotes/origin/pr/33668") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Pre-warm Gradle by running the tests (downloads Gradle, builds build-logic, compiles all needed modules)
# This caches all dependencies so the verifier can run tests quickly
RUN ./gradlew :dependency-management:test --tests "org.gradle.api.internal.catalog.ProjectAccessorsSourceGeneratorTest" --tests "org.gradle.api.internal.notations.ProjectDependencyFactoryTest" :core:test --tests "org.gradle.api.internal.artifacts.dependencies.DefaultProjectDependencyConstraintTest" --no-daemon || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/.git

WORKDIR /app/src
