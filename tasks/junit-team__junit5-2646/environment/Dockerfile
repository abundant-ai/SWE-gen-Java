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

# Disable git versioning plugin to avoid grgit dependency issues
ENV GRADLE_PROJECT_release.useLastTag=false

# Disable Kotlin's allWarningsAsErrors to allow deprecated language version warnings
ENV ORG_GRADLE_PROJECT_kotlin.allWarningsAsErrors=false

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/junit-team/junit-framework.git src && \
    cd src && \
    (git fetch --depth 1 origin 921e2043744c8e10d9a4f1e205b489c03a60404d || git fetch --depth 1 origin "+refs/pull/2646/head:refs/remotes/origin/pr/2646") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Update Gradle wrapper to 7.2 for better Java 17 support
RUN sed -i 's|gradle-[0-9.]*-rc-[0-9]*-bin.zip|gradle-7.2-bin.zip|g' gradle/wrapper/gradle-wrapper.properties && \
    sed -i 's|gradle-[0-9.]*-bin.zip|gradle-7.2-bin.zip|g' gradle/wrapper/gradle-wrapper.properties && \
    sed -i 's/distributionSha256Sum=.*/distributionSha256Sum=f581709a9c35e9cb92e16f585d2c4bc99b2b1a5f85d2badbd3dc6bff59e1e6dd/g' gradle/wrapper/gradle-wrapper.properties

# Patch settings.gradle.kts and buildSrc/build.gradle.kts to use stable version of test-distribution plugin instead of rc versions
RUN sed -i 's/version "2.1.1-rc-[0-9]*"/version "2.1.1"/' settings.gradle.kts && \
    sed -i 's/2.1.1-rc-[0-9]*/2.1.1/g' buildSrc/build.gradle.kts

# Disable Kotlin's allWarningsAsErrors to allow deprecated language version warnings
RUN sed -i 's/allWarningsAsErrors = true/allWarningsAsErrors = false/g' buildSrc/src/main/kotlin/kotlin-library-conventions.gradle.kts && \
    sed -i 's/allWarningsAsErrors = true/allWarningsAsErrors = false/g' buildSrc/build.gradle.kts

# Create a Gradle init script to add mavenLocal and grgit backup repository for dependency resolution
RUN mkdir -p ~/.gradle/init.d && \
    echo "settingsEvaluated { settings ->" > ~/.gradle/init.d/temp-repo.gradle && \
    echo "    settings.pluginManagement {" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "        repositories {" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "            mavenCentral()" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "            gradlePluginPortal()" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "            maven { url 'https://ajoberstar.org/bintray-backup/' }" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "        }" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "    }" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "}" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "allprojects {" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "    buildscript {" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "        repositories {" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "            mavenCentral()" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "            gradlePluginPortal()" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "            maven { url 'https://ajoberstar.org/bintray-backup/' }" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "        }" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "    }" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "    repositories {" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "        mavenLocal()" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "        maven { url = uri(rootProject.file('build/repo')) }" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "        mavenCentral()" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "        maven {" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "            url = uri('https://oss.sonatype.org/content/repositories/snapshots')" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "            mavenContent { snapshotsOnly() }" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "        }" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "        maven { url 'https://ajoberstar.org/bintray-backup/' }" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "    }" >> ~/.gradle/init.d/temp-repo.gradle && \
    echo "}" >> ~/.gradle/init.d/temp-repo.gradle

# First, publish all modules to local maven repository to resolve SNAPSHOT dependencies
# Skip compileModule tasks that have -Werror issues with UniqueIdTrackingListener
RUN ./gradlew publishToMavenLocal -x compileModule --no-daemon --no-parallel || \
    (sleep 2 && ./gradlew publishToMavenLocal -x compileModule --no-daemon --no-parallel) || \
    (sleep 5 && ./gradlew publishToMavenLocal -x compileModule --no-daemon --no-parallel)

# Build the required test classes (with retry due to Gradle jar cache race condition)
RUN ./gradlew :junit-jupiter-engine:testClasses -x compileModule --no-daemon --no-parallel || \
    (sleep 2 && ./gradlew :junit-jupiter-engine:testClasses -x compileModule --no-daemon --no-parallel) || \
    (sleep 5 && ./gradlew :junit-jupiter-engine:testClasses -x compileModule --no-daemon --no-parallel)

# Reset tracked files so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Update Gradle wrapper to 7.2 for better Java 17 support (reapply after bug.patch)
RUN sed -i 's|gradle-[0-9.]*-rc-[0-9]*-bin.zip|gradle-7.2-bin.zip|g' gradle/wrapper/gradle-wrapper.properties && \
    sed -i 's|gradle-[0-9.]*-bin.zip|gradle-7.2-bin.zip|g' gradle/wrapper/gradle-wrapper.properties && \
    sed -i 's/distributionSha256Sum=.*/distributionSha256Sum=f581709a9c35e9cb92e16f585d2c4bc99b2b1a5f85d2badbd3dc6bff59e1e6dd/g' gradle/wrapper/gradle-wrapper.properties

# Patch settings.gradle.kts and buildSrc/build.gradle.kts to use stable version of test-distribution plugin instead of rc versions
# This is done after bug.patch so it's not undone by git reset
RUN sed -i 's/version "2.1.1-rc-[0-9]*"/version "2.1.1"/' settings.gradle.kts && \
    sed -i 's/2.1.1-rc-[0-9]*/2.1.1/g' buildSrc/build.gradle.kts

# Disable Kotlin's allWarningsAsErrors to allow deprecated language version warnings (reapply after bug.patch)
RUN sed -i 's/allWarningsAsErrors = true/allWarningsAsErrors = false/g' buildSrc/src/main/kotlin/kotlin-library-conventions.gradle.kts && \
    sed -i 's/allWarningsAsErrors = true/allWarningsAsErrors = false/g' buildSrc/build.gradle.kts

# Rebuild after applying bug.patch - republish and build test classes
RUN ./gradlew publishToMavenLocal -x compileModule --no-daemon --no-parallel || \
    (sleep 2 && ./gradlew publishToMavenLocal -x compileModule --no-daemon --no-parallel) || \
    (sleep 5 && ./gradlew publishToMavenLocal -x compileModule --no-daemon --no-parallel)

RUN ./gradlew :junit-jupiter-engine:testClasses -x compileModule --no-daemon --no-parallel || \
    (sleep 2 && ./gradlew :junit-jupiter-engine:testClasses -x compileModule --no-daemon --no-parallel) || \
    (sleep 5 && ./gradlew :junit-jupiter-engine:testClasses -x compileModule --no-daemon --no-parallel)

RUN rm -rf /app/src/.git

WORKDIR /app/src
