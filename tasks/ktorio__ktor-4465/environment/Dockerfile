FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java JDK 17 for Kotlin/Gradle project
# Kotlin 1.8.22 supports jvmTarget up to 19; JDK 17 is stable and compatible
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/ktorio/ktor.git src && \
    cd src && \
    (git fetch --depth 1 origin aebf4f8dfe8ade47f7787c6886d1c08837b8b4e0 || git fetch --depth 1 origin "+refs/pull/4465/head:refs/remotes/origin/pr/4465") && \
    git checkout -f --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Gradle
ENV CI=true
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"

# Patch buildSrc and main build to use JDK 17 toolchain instead of JDK 8
# Kotlin 1.8.22 supports jvmTarget up to 19, so 17 is safe
# buildSrc uses JavaLanguageVersion.of(8) directly
RUN sed -i 's/JavaLanguageVersion.of(8)/JavaLanguageVersion.of(17)/g' buildSrc/build.gradle.kts
# Main build uses "else -> 8" in setupJvmToolchain; patch to use 17 instead
RUN sed -i '/fun Project.setupJvmToolchain/,/^}/s/else -> 8/else -> 17/' build.gradle.kts

# Override gradle.properties to control JVM memory (for build phase - more memory available)
# Disable git tag lookups since .git will be removed; avoids build failures when git is unavailable
RUN echo "org.gradle.jvmargs=-Xms512m -Xmx4g -XX:MaxMetaspaceSize=768m -XX:+UseParallelGC" >> gradle.properties
RUN echo "kotlin.daemon.jvmargs=-Xms512m -Xmx2g" >> gradle.properties
RUN echo "ktor.develocity.skipGitTags=true" >> gradle.properties

# Pre-warm Gradle caches by running a lightweight compile task
RUN ./gradlew :ktor-client:ktor-client-core:compileTestKotlinJvm \
    --no-daemon 2>&1 || true

# Clean up Gradle daemon registry to prevent stale daemon conflicts at test time
RUN rm -rf /root/.gradle/daemon

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Re-apply toolchain patches after reset
RUN sed -i 's/JavaLanguageVersion.of(8)/JavaLanguageVersion.of(17)/g' buildSrc/build.gradle.kts && \
    sed -i '/fun Project.setupJvmToolchain/,/^}/s/else -> 8/else -> 17/' build.gradle.kts

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Re-apply gradle.properties with memory limits for test container (4GB available)
# UseParallelGC is required by Gradle Doctor check
# skipGitTags avoids git failures when .git directory is absent
RUN echo "org.gradle.jvmargs=-Xms256m -Xmx2g -XX:MaxMetaspaceSize=512m -XX:+UseParallelGC" >> gradle.properties
RUN echo "kotlin.daemon.jvmargs=-Xms128m -Xmx1g" >> gradle.properties
RUN echo "ktor.develocity.skipGitTags=true" >> gradle.properties

RUN rm -rf /app/src/.git

WORKDIR /app/src
