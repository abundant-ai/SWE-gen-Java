FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (Temurin distribution)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/resilience4j/resilience4j.git src && \
    cd src && \
    (git fetch --depth 1 origin 93f502ed5c4121907622d7bb6d08050255f1b16d || git fetch --depth 1 origin "+refs/pull/2249/head:refs/remotes/origin/pr/2249") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Install dependencies and compile Java code
RUN ./gradlew compileJava compileTestJava --no-daemon

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after patching Java source files
RUN ./gradlew compileJava compileTestJava --no-daemon

RUN rm -rf /app/src/.git

WORKDIR /app/src
