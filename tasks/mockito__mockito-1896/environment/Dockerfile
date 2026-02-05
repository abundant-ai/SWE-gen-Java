FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 (required by mockito build at this commit)
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/mockito/mockito.git src && \
    cd src && \
    (git fetch --depth 1 origin 01d4ebe25f6ed4dc8dd49dd70aaf88a125edddfa || git fetch --depth 1 origin "+refs/pull/1896/head:refs/remotes/origin/pr/1896") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Fix jcenter repository (JCenter is shut down) and comment out shipkit plugin (requires unavailable dependencies)
# Also disable kotlinReleaseCoroutinesTest subproject (requires unavailable Kotlin 1.3.0-rc-57 from defunct bintray)
RUN sed -i 's|jcenter()|mavenCentral()|g' build.gradle && \
    sed -i '/classpath.*shipkit/s|^|//|' build.gradle && \
    sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle && \
    sed -i '/bintrayUpload/s|^|//|' build.gradle && \
    sed -i '/generatePomFileForJavaLibraryPublication/,/^}/s|^|//|' gradle/java-library.gradle && \
    sed -i '/afterEvaluate.*{/,/^}$/{ /publishing\.publications/,/}/s|^|//| }' build.gradle && \
    sed -i '/^description = /i version = "3.0.0"' build.gradle && \
    sed -i '/kotlinReleaseCoroutinesTest/s|^|//|' settings.gradle.kts

# Download dependencies using Gradle
RUN ./gradlew dependencies --no-daemon || true

# Build the project (Java/Kotlin compilation)
RUN ./gradlew build -x test --no-daemon || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Reapply jcenter fix after patching (git reset undid our changes)
# Also disable kotlinReleaseCoroutinesTest subproject again (git reset undid our changes)
RUN sed -i 's|jcenter()|mavenCentral()|g' build.gradle && \
    sed -i '/classpath.*shipkit/s|^|//|' build.gradle && \
    sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle && \
    sed -i '/bintrayUpload/s|^|//|' build.gradle && \
    sed -i '/generatePomFileForJavaLibraryPublication/,/^}/s|^|//|' gradle/java-library.gradle && \
    sed -i '/afterEvaluate.*{/,/^}$/{ /publishing\.publications/,/}/s|^|//| }' build.gradle && \
    sed -i '/^description = /i version = "3.0.0"' build.gradle && \
    sed -i '/kotlinReleaseCoroutinesTest/s|^|//|' settings.gradle.kts

# Rebuild after applying bug.patch (Java/Kotlin needs recompilation)
RUN ./gradlew build -x test --no-daemon || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
