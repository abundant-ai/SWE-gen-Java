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

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/junit-team/junit-framework.git src && \
    cd src && \
    (git fetch --depth 1 origin 85493ee638e535cf7c47f75be26413dc3033e045 || git fetch --depth 1 origin "+refs/pull/2729/head:refs/remotes/origin/pr/2729") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

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
RUN ./gradlew publishToMavenLocal --no-daemon --no-parallel || \
    (sleep 2 && ./gradlew publishToMavenLocal --no-daemon --no-parallel) || \
    (sleep 5 && ./gradlew publishToMavenLocal --no-daemon --no-parallel)

# Build the required test classes (with retry due to Gradle jar cache race condition)
RUN ./gradlew :junit-jupiter-engine:testClasses :documentation:testClasses --no-daemon --no-parallel || \
    (sleep 2 && ./gradlew :junit-jupiter-engine:testClasses :documentation:testClasses --no-daemon --no-parallel) || \
    (sleep 5 && ./gradlew :junit-jupiter-engine:testClasses :documentation:testClasses --no-daemon --no-parallel)

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch - republish and build test classes
RUN ./gradlew publishToMavenLocal --no-daemon --no-parallel || \
    (sleep 2 && ./gradlew publishToMavenLocal --no-daemon --no-parallel) || \
    (sleep 5 && ./gradlew publishToMavenLocal --no-daemon --no-parallel)

RUN ./gradlew :junit-jupiter-engine:testClasses :documentation:testClasses --no-daemon --no-parallel || \
    (sleep 2 && ./gradlew :junit-jupiter-engine:testClasses :documentation:testClasses --no-daemon --no-parallel) || \
    (sleep 5 && ./gradlew :junit-jupiter-engine:testClasses :documentation:testClasses --no-daemon --no-parallel)

RUN rm -rf /app/src/.git

WORKDIR /app/src
