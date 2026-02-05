FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (compatible with Gradle 7.6.2 used in this commit)
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    echo "deb https://packages.adoptium.net/artifactory/deb $(grep VERSION_CODENAME /etc/os-release | cut -d= -f2) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && apt-get install -y temurin-17-jdk && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/retrofit.git src && \
    cd src && \
    (git fetch --depth 1 origin 48b98a9d02c78050bc5af905f37b215f0e5c78d1 || git fetch --depth 1 origin "+refs/pull/3411/head:refs/remotes/origin/pr/3411") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for CI
ENV CI=true
ENV GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false -Dorg.gradle.logging.stacktrace=full"

# Download dependencies and build the project
RUN ./gradlew build --no-daemon -x test || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java is a compiled language)
RUN ./gradlew build --no-daemon -x test || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
