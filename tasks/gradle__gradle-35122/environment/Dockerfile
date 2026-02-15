FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (required for Gradle build)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/gradle/gradle.git src && \
    cd src && \
    (git fetch --depth 1 origin d8b39d051cc61b36e36bd79a27d8d34f54944f0d || git fetch --depth 1 origin "+refs/pull/35122/head:refs/remotes/origin/pr/35122") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Build the Gradle project including the internal-integ-testing module
RUN ./gradlew :testing:internal-integ-testing:compileGroovy :testing:internal-integ-testing:compileTestGroovy --no-daemon || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Groovy/Java code needs recompilation)
RUN ./gradlew :testing:internal-integ-testing:compileGroovy :testing:internal-integ-testing:compileTestGroovy --no-daemon || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
