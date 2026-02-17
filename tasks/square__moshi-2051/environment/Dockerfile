FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 21 (minimum required by the project)
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/moshi.git src && \
    cd src && \
    (git fetch --depth 1 origin 96faa1983a319b513bfb26372611cd60946f65dc || git fetch --depth 1 origin "+refs/pull/2051/head:refs/remotes/origin/pr/2051") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download Gradle dependencies and compile the project
RUN ./gradlew build -x test --stacktrace

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for compiled languages)
RUN ./gradlew build -x test --stacktrace

RUN rm -rf /app/src/.git

WORKDIR /app/src
