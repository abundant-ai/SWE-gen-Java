FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 (required by mockito build at this commit)
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/mockito/mockito.git src && \
    cd src && \
    (git fetch --depth 1 origin e55f49a413b2eb04b6931500320abf667d7a8f95 || git fetch --depth 1 origin "+refs/pull/2410/head:refs/remotes/origin/pr/2410") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download dependencies using Gradle
RUN ./gradlew dependencies --no-daemon || true

# Build the project (Java/Kotlin compilation)
RUN ./gradlew build -x test --no-daemon || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java/Kotlin needs recompilation)
RUN ./gradlew build -x test --no-daemon || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
