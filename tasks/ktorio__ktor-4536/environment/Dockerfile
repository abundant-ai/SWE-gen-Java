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
    (git fetch --depth 1 origin a1dba6c300ce8b74e66640264437164c99622485 || git fetch --depth 1 origin "+refs/pull/4536/head:refs/remotes/origin/pr/4536") && \
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
RUN ./gradlew :ktor-utils:compileTestKotlinJvm --no-daemon -x apiCheck 2>&1 || true

# Clean up Gradle daemon registry to prevent stale daemon conflicts at test time
RUN rm -rf /root/.gradle/daemon

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Re-apply gradle.properties with memory limits sized for test container (2GB limit)
RUN echo "org.gradle.jvmargs=-Xms256m -Xmx1500m -XX:MaxMetaspaceSize=512m -XX:+UseParallelGC" >> gradle.properties
RUN echo "kotlin.daemon.jvmargs=-Xms128m -Xmx512m" >> gradle.properties

WORKDIR /app/src
