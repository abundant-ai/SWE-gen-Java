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
    (git fetch --depth 1 origin 2da160fd880ff673559b952072a033711440dcb6 || git fetch --depth 1 origin "+refs/pull/4527/head:refs/remotes/origin/pr/4527") && \
    git checkout -f --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Gradle
ENV CI=true
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"

# Override gradle.properties to control JVM memory (for build phase - more memory available)
RUN echo "org.gradle.jvmargs=-Xms512m -Xmx4g -XX:MaxMetaspaceSize=768m -XX:+UseParallelGC" >> gradle.properties
RUN echo "kotlin.daemon.jvmargs=-Xms512m -Xmx2g" >> gradle.properties

# Pre-compile relevant modules and their dependencies to cache compiled artifacts
RUN ./gradlew :ktor-server:ktor-server-servlet-jakarta:compileKotlinJvm \
              :ktor-server:ktor-server-servlet-jakarta:compileTestKotlinJvm \
              :ktor-server:ktor-server-servlet:compileKotlinJvm \
              :ktor-server:ktor-server-servlet:compileTestKotlinJvm \
              :ktor-server:ktor-server-tests:compileKotlinJvm \
              :ktor-server:ktor-server-tests:compileTestKotlinJvm \
              :ktor-client:ktor-client-plugins:ktor-client-encoding:compileKotlinJvm \
              --no-daemon -x apiCheck 2>&1 || true

# Clean up Gradle daemon registry to prevent stale daemon conflicts at test time
RUN rm -rf /root/.gradle/daemon

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Re-apply gradle.properties with memory limits for test container (2GB total)
# Heap + MetaSpace must stay well under 1800m to leave room for OS
RUN echo "org.gradle.jvmargs=-Xms128m -Xmx1200m -XX:MaxMetaspaceSize=384m -XX:+UseParallelGC" >> gradle.properties
RUN echo "kotlin.daemon.jvmargs=-Xms64m -Xmx384m" >> gradle.properties

WORKDIR /app/src
