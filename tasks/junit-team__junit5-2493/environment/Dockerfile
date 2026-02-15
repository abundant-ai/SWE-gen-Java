FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java JDK 15 (default toolchain version for this commit)
RUN apt-get update && apt-get install -y \
    wget \
    && wget https://download.java.net/java/GA/jdk15.0.2/0d1cfde4252546c6931946de8db48ee2/7/GPL/openjdk-15.0.2_linux-x64_bin.tar.gz \
    && tar -xzf openjdk-15.0.2_linux-x64_bin.tar.gz -C /opt \
    && rm openjdk-15.0.2_linux-x64_bin.tar.gz \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/opt/jdk-15.0.2
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Disable git versioning plugin to avoid grgit dependency issues
ENV GRADLE_PROJECT_release.useLastTag=false

# Disable Kotlin's allWarningsAsErrors to allow deprecated language version warnings
ENV ORG_GRADLE_PROJECT_kotlin.allWarningsAsErrors=false

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/junit-team/junit-framework.git src && \
    cd src && \
    (git fetch --depth 1 origin b3ba5f651a62fd34c16235fd5dcc51e8bae3380f || git fetch --depth 1 origin "+refs/pull/2493/head:refs/remotes/origin/pr/2493") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

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

# Publish all modules to local maven repository to resolve SNAPSHOT dependencies
RUN ./gradlew publishToMavenLocal -x compileModule --no-daemon --no-parallel || \
    (sleep 2 && ./gradlew publishToMavenLocal -x compileModule --no-daemon --no-parallel) || \
    (sleep 5 && ./gradlew publishToMavenLocal -x compileModule --no-daemon --no-parallel)

# Reset tracked files so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Disable Kotlin's allWarningsAsErrors to allow deprecated language version warnings (reapply after bug.patch)
RUN sed -i 's/allWarningsAsErrors = true/allWarningsAsErrors = false/g' buildSrc/src/main/kotlin/kotlin-library-conventions.gradle.kts && \
    sed -i 's/allWarningsAsErrors = true/allWarningsAsErrors = false/g' buildSrc/build.gradle.kts

# Rebuild after applying bug.patch - republish modules
RUN ./gradlew publishToMavenLocal -x compileModule --no-daemon --no-parallel || \
    (sleep 2 && ./gradlew publishToMavenLocal -x compileModule --no-daemon --no-parallel) || \
    (sleep 5 && ./gradlew publishToMavenLocal -x compileModule --no-daemon --no-parallel)

RUN rm -rf /app/src/.git

WORKDIR /app/src
