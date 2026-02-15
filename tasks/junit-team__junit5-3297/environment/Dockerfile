FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java JDK 17 (required by build system for this commit)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/junit-team/junit-framework.git src && \
    cd src && \
    (git fetch --depth 1 origin 91a81c60d5fb3e5c7abf7afcf7c05ff31fe60d6f || git fetch --depth 1 origin "+refs/pull/3297/head:refs/remotes/origin/pr/3297") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Build the jupiter-engine and jupiter-params modules
RUN ./gradlew :junit-jupiter-engine:testClasses :junit-jupiter-params:testClasses --no-daemon --no-configuration-cache

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for Java)
RUN ./gradlew :junit-jupiter-engine:testClasses :junit-jupiter-params:testClasses --no-daemon --no-configuration-cache

WORKDIR /app/src
