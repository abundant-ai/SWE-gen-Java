FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (used by Gradle build and Maven)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/gradle/gradle.git src && \
    cd src && \
    (git fetch --depth 1 origin ff3f8ecda49edbb432e93826d0f13cb0a8ba0925 || git fetch --depth 1 origin "+refs/pull/33826/head:refs/remotes/origin/pr/33826") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
# binary files in the patch cannot be applied with shallow clone, but text patches work fine
COPY bug.patch /tmp/bug.patch
RUN patch -p1 --forward --force < /tmp/bug.patch || true
RUN rm /tmp/bug.patch

# Build and compile the .teamcity subproject using Maven (after applying bug.patch)
RUN cd .teamcity && ./mvnw compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
