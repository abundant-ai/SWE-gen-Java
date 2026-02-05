FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 21 LTS
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/apache/kafka.git src && \
    cd src && \
    (git fetch --depth 1 origin 7b3a9bcf1e99f4b5f70c672f1f421368a4916abf || git fetch --depth 1 origin "+refs/pull/21363/head:refs/remotes/origin/pr/21363") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download Gradle dependencies and compile (skip checkstyle)
# Must compile coordinator-common test classes first since share-coordinator depends on them
RUN ./gradlew --no-daemon :coordinator-common:testClasses :share-coordinator:testClasses -x checkstyleMain -x checkstyleTest

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Save coordinator-common test files before applying bug.patch
# (fix.patch won't revert these, so we need to restore them manually later)
RUN mkdir -p /tmp/head-test-files && \
    cp coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime/MockCoordinator*.java /tmp/head-test-files/

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (skip checkstyle)
RUN ./gradlew --no-daemon :coordinator-common:testClasses :share-coordinator:testClasses -x checkstyleMain -x checkstyleTest

RUN rm -rf /app/src/.git

WORKDIR /app/src
