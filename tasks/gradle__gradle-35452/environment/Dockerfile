FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (used by CI workflows and Maven build)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/gradle/gradle.git src && \
    cd src && \
    (git fetch --depth 1 origin f37861441140857e59156f995c0e4cbef2d0476c || git fetch --depth 1 origin "+refs/pull/35452/head:refs/remotes/origin/pr/35452") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Install Maven dependencies for .teamcity project
WORKDIR /app/src/.teamcity
RUN ./mvnw dependency:resolve

# Compile the TeamCity Kotlin configuration and test code
RUN ./mvnw compile test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
WORKDIR /app/src
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Kotlin code needs recompilation)
WORKDIR /app/src/.teamcity
RUN ./mvnw compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
