FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (as required by CI config)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/moshi.git src && \
    cd src && \
    (git fetch --depth 1 origin 82b6831d6107ba3f954169bec253f503eac92880 || git fetch --depth 1 origin "+refs/pull/1550/head:refs/remotes/origin/pr/1550") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download Gradle dependencies and compile the project
RUN ./gradlew build -x test --stacktrace

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for compiled languages)
RUN ./gradlew build -x test --stacktrace

RUN rm -rf /app/src/.git

WORKDIR /app/src
