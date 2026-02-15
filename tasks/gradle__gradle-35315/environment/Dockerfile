FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (used by Gradle build and Maven tests)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/gradle/gradle.git src && \
    cd src && \
    (git fetch --depth 1 origin cb0b1692699f959c9a909d49e723e03a42eb85fa || git fetch --depth 1 origin "+refs/pull/35315/head:refs/remotes/origin/pr/35315") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Build and compile the .teamcity Maven project to prepare test dependencies
RUN cd .teamcity && ./mvnw clean compile test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Kotlin code needs recompilation)
RUN cd .teamcity && ./mvnw clean compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
