FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java JDK 21 for Kotlin/Gradle project
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/ktorio/ktor.git src && \
    cd src && \
    (git fetch --depth 1 origin e0e75db0c7dd5bf3e08d87c764c4ceead1046657 || git fetch --depth 1 origin "+refs/pull/4543/head:refs/remotes/origin/pr/4543") && \
    git checkout -f --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Gradle
ENV CI=true
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"

# Override gradle.properties to control JVM memory (for container)
RUN echo "org.gradle.jvmargs=-Xms512m -Xmx4g -XX:MaxMetaspaceSize=768m -XX:+UseParallelGC" >> gradle.properties
RUN echo "kotlin.daemon.jvmargs=-Xms512m -Xmx2g" >> gradle.properties

# Pre-compile test classes and cache dependencies to speed up test execution
RUN ./gradlew :ktor-server:ktor-server-plugins:ktor-server-sse:compileTestKotlinJvm --no-daemon -x apiCheck 2>&1 || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Re-apply gradle.properties override after patch
RUN echo "org.gradle.jvmargs=-Xms512m -Xmx4g -XX:MaxMetaspaceSize=768m -XX:+UseParallelGC" >> gradle.properties
RUN echo "kotlin.daemon.jvmargs=-Xms512m -Xmx2g" >> gradle.properties

WORKDIR /app/src
