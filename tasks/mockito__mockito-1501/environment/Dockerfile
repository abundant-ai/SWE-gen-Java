FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 11 (Java 9+ required for module-test subproject)
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/mockito/mockito.git src && \
    cd src && \
    (git fetch --depth 1 origin aa54bd6358daa50aa24dbe56814ee05560f7f31e || git fetch --depth 1 origin "+refs/pull/1501/head:refs/remotes/origin/pr/1501") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Fix jcenter and bintray repositories (both are shut down) and comment out shipkit/build-scan plugins (requires unavailable dependencies)
# Disable error-prone plugin (incompatible with Java 11)
# Fix extTest dependency on publishToMavenLocal
# Fix Kotlin version in kotlinReleaseCoroutinesTest (use 1.3.0 stable instead of 1.3.0-rc-57)
RUN sed -i 's|jcenter()|mavenCentral()|g' build.gradle && \
    (test -f subprojects/osgi-test/osgi-test-bundles.gradle && sed -i 's|jcenter()|mavenCentral()|g' subprojects/osgi-test/osgi-test-bundles.gradle || true) && \
    sed -i '/classpath.*shipkit/s|^|//|' build.gradle && \
    sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle && \
    sed -i '/id.*com.gradle.build-scan/s|^|//|' build.gradle && \
    sed -i '/buildScan {/,/^}/s|^|//|' build.gradle && \
    sed -i '/bintrayUpload/s|^|//|' build.gradle && \
    sed -i '/generatePomFileForJavaLibraryPublication/,/^}/s|^|//|' gradle/java-library.gradle && \
    sed -i '/bintrayUpload\.enabled/s|^|//|' gradle/java-library.gradle && \
    sed -i '/afterEvaluate.*{/,/^}$/{ /publishing\.publications/,/}/s|^|//| }' build.gradle && \
    sed -i '/^description = /i version = "3.0.0"' build.gradle && \
    sed -i '/classpath.*errorprone/s|^|//|' build.gradle && \
    sed -i '/apply from.*errorprone/s|^|//|' build.gradle && \
    sed -i '/apply plugin.*errorprone/s|^|//|' build.gradle && \
    sed -i '/errorprone libraries\.errorprone/s|^|//|' build.gradle && \
    sed -i '/coverage\.gradle/s|^|//|' build.gradle && \
    (test -f subprojects/extTest/extTest.gradle && sed -i '/dependsOn.*publishToMavenLocal/s|^|//|' subprojects/extTest/extTest.gradle || true)

# Download dependencies using Gradle (clear cache first to pick up Kotlin version changes)
RUN rm -rf /root/.gradle/caches && ./gradlew dependencies --no-daemon || true

# Build the project (Java/Kotlin compilation)
RUN ./gradlew build -x test --no-daemon || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Recreate kotlinReleaseCoroutinesTest.gradle (bug.patch deletes it)
COPY kotlinReleaseCoroutinesTest.gradle /app/src/subprojects/kotlinReleaseCoroutinesTest/kotlinReleaseCoroutinesTest.gradle

# Reapply jcenter and bintray fix after patching (git reset undid our changes)
# Disable error-prone plugin again (git reset undid our changes)
# Fix extTest dependency on publishToMavenLocal again
# Re-enable kotlinReleaseCoroutinesTest subproject (bug.patch removes it from settings.gradle)
# Add kotlinVersion_1_3 definition (bug.patch removes it from gradle/dependencies.gradle)
# Note: osgi-test-bundles.gradle is created by the patch, so we fix it conditionally
RUN sed -i "/include 'kotlinTest'/a include 'kotlinReleaseCoroutinesTest'" settings.gradle && \
    sed -i "/^def kotlinVersion = /a def kotlinVersion_1_3 = '1.3.0'" gradle/dependencies.gradle && \
    sed -i 's|jcenter()|mavenCentral()|g' build.gradle && \
    (test -f subprojects/osgi-test/osgi-test-bundles.gradle && sed -i 's|jcenter()|mavenCentral()|g' subprojects/osgi-test/osgi-test-bundles.gradle || true) && \
    sed -i '/classpath.*shipkit/s|^|//|' build.gradle && \
    sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle && \
    sed -i '/id.*com.gradle.build-scan/s|^|//|' build.gradle && \
    sed -i '/buildScan {/,/^}/s|^|//|' build.gradle && \
    sed -i '/bintrayUpload/s|^|//|' build.gradle && \
    sed -i '/generatePomFileForJavaLibraryPublication/,/^}/s|^|//|' gradle/java-library.gradle && \
    sed -i '/bintrayUpload\.enabled/s|^|//|' gradle/java-library.gradle && \
    sed -i '/afterEvaluate.*{/,/^}$/{ /publishing\.publications/,/}/s|^|//| }' build.gradle && \
    sed -i '/^description = /i version = "3.0.0"' build.gradle && \
    sed -i '/classpath.*errorprone/s|^|//|' build.gradle && \
    sed -i '/apply from.*errorprone/s|^|//|' build.gradle && \
    sed -i '/apply plugin.*errorprone/s|^|//|' build.gradle && \
    sed -i '/errorprone libraries\.errorprone/s|^|//|' build.gradle && \
    sed -i '/coverage\.gradle/s|^|//|' build.gradle && \
    (test -f subprojects/extTest/extTest.gradle && sed -i '/dependsOn.*publishToMavenLocal/s|^|//|' subprojects/extTest/extTest.gradle || true)

# Clean and rebuild after applying bug.patch to ensure MockMethodDispatcher.raw is in the correct (buggy) location
# Clear Gradle cache first to pick up Kotlin version changes
RUN rm -rf /root/.gradle/caches && ./gradlew clean --no-daemon || true
RUN ./gradlew build -x test --no-daemon || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
