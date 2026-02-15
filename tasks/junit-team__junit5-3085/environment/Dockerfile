FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java JDK 17 (LTS version compatible with this codebase)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/junit-team/junit-framework.git src && \
    cd src && \
    (git fetch --depth 1 origin e232d6c13bbb465d152329bc83374da99343a4c1 || git fetch --depth 1 origin "+refs/pull/3085/head:refs/remotes/origin/pr/3085") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Build the required test classes (with retry due to Gradle jar cache race condition)
RUN ./gradlew :junit-jupiter-params:testClasses --no-daemon --no-parallel || \
    (sleep 2 && ./gradlew :junit-jupiter-params:testClasses --no-daemon --no-parallel) || \
    (sleep 5 && ./gradlew :junit-jupiter-params:testClasses --no-daemon --no-parallel)

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for Java, with retry)
RUN ./gradlew :junit-jupiter-params:testClasses --no-daemon --no-parallel || \
    (sleep 2 && ./gradlew :junit-jupiter-params:testClasses --no-daemon --no-parallel) || \
    (sleep 5 && ./gradlew :junit-jupiter-params:testClasses --no-daemon --no-parallel)

WORKDIR /app/src