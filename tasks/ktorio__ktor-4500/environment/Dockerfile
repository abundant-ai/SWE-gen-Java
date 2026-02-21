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
    (git fetch --depth 1 origin 92df9a1ea3a2bca913cd6e3d90574b522d544fa3 || git fetch --depth 1 origin "+refs/pull/4500/head:refs/remotes/origin/pr/4500") && \
    git checkout -f --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Gradle
ENV CI=true
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"

# Override gradle.properties to control JVM memory (for build phase - more memory available)
RUN echo "org.gradle.jvmargs=-Xms512m -Xmx4g -XX:MaxMetaspaceSize=768m -XX:+UseParallelGC" >> gradle.properties
RUN echo "kotlin.daemon.jvmargs=-Xms512m -Xmx2g" >> gradle.properties

# Pre-compile buildSrc by running a root-level gradle task (buildSrc compiles automatically)
RUN ./gradlew help --no-daemon 2>&1 || true

# Clean up Gradle daemon registry to prevent stale daemon conflicts at test time
RUN rm -rf /root/.gradle/daemon

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Add explicit foojay plugin version so buildSrc can be compiled as a standalone project
# This enables running ./gradlew -p buildSrc compileKotlin without the full project configuration
RUN sed -i 's/id("org.gradle.toolchains.foojay-resolver-convention")$/id("org.gradle.toolchains.foojay-resolver-convention") version "0.9.0"/' buildSrc/settings.gradle.kts

# Re-apply gradle.properties with memory limits for test container (2GB total)
# Heap + MetaSpace must stay well under 1800m to leave room for OS
RUN echo "org.gradle.jvmargs=-Xms128m -Xmx1200m -XX:MaxMetaspaceSize=384m -XX:+UseParallelGC" >> gradle.properties
RUN echo "kotlin.daemon.jvmargs=-Xms64m -Xmx384m" >> gradle.properties

WORKDIR /app/src
