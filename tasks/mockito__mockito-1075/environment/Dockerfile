FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 (Gradle 3.5 compatibility)
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    ca-certificates-java \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/mockito/mockito.git src && \
    cd src && \
    (git fetch --depth 1 origin dad7a9ad85e85ccaedb6285b0ff747f48bd7919c || git fetch --depth 1 origin "+refs/pull/1075/head:refs/remotes/origin/pr/1075") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Fix jcenter and bintray repositories (both are shut down) and comment out shipkit/build-scan plugins (requires unavailable dependencies)
# Disable error-prone plugin (incompatible with Gradle 4.7 + Java 8)
# Fix extTest dependency on publishToMavenLocal
RUN sed -i 's|jcenter()|mavenCentral()|g' build.gradle && \
    (test -f subprojects/osgi-test/osgi-test-bundles.gradle && sed -i 's|jcenter()|mavenCentral()|g' subprojects/osgi-test/osgi-test-bundles.gradle || true) && \
    sed -i '/classpath.*mockito-release-tools/s|^|//|' build.gradle && \
    sed -i '/classpath.*shipkit/s|^|//|' build.gradle && \
    sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle && \
    sed -i '/id.*com.gradle.build-scan/s|^|//|' build.gradle && \
    sed -i '/buildScan {/,/^}/s|^|//|' build.gradle && \
    sed -i '/release\.gradle/s|^|//|' build.gradle && \
    sed -i '1s/.*/apply plugin: "java"/' gradle/java-library.gradle && \
    sed -i '/^allprojects {$/a\    apply from: "$rootProject.projectDir/gradle/dependencies.gradle"' build.gradle && \
    sed -i 's|compileOnly "junit:junit:4.12"|compileOnly libraries.junit4|' build.gradle && \
    sed -i "s|testCompile 'org.assertj:assertj-core:2.6.0'|testCompile libraries.assertj|" build.gradle && \
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
    (test -f subprojects/extTest/extTest.gradle && sed -i '/dependsOn.*publishToMavenLocal/s|^|//|' subprojects/extTest/extTest.gradle || true) && \
    (test -f settings.gradle && sed -i "s/include 'errorprone'/\\/\\/ include 'errorprone'/" settings.gradle || true)

# Disable errorprone and kotlinReleaseCoroutinesTest subprojects by renaming their directories
RUN test -d subprojects/errorprone && mv subprojects/errorprone subprojects/errorprone.disabled || true
RUN test -d subprojects/kotlinReleaseCoroutinesTest && mv subprojects/kotlinReleaseCoroutinesTest subprojects/kotlinReleaseCoroutinesTest.disabled || true

# Download dependencies using Gradle
RUN ./gradlew dependencies --no-daemon || true

# Build the project (Java/Kotlin compilation)
RUN ./gradlew build -x test --no-daemon || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Disable errorprone and kotlinReleaseCoroutinesTest subprojects again after patching (git reset undid the rename)
RUN test -d subprojects/errorprone && mv subprojects/errorprone subprojects/errorprone.disabled || true
RUN test -d subprojects/kotlinReleaseCoroutinesTest && mv subprojects/kotlinReleaseCoroutinesTest subprojects/kotlinReleaseCoroutinesTest.disabled || true

# Reapply jcenter and bintray fix after patching (git reset undid our changes)
# Disable error-prone plugin again (git reset undid our changes)
# Fix extTest dependency on publishToMavenLocal again
RUN sed -i 's|jcenter()|mavenCentral()|g' build.gradle && \
    (test -f subprojects/osgi-test/osgi-test-bundles.gradle && sed -i 's|jcenter()|mavenCentral()|g' subprojects/osgi-test/osgi-test-bundles.gradle || true) && \
    sed -i '/classpath.*mockito-release-tools/s|^|//|' build.gradle && \
    sed -i '/classpath.*shipkit/s|^|//|' build.gradle && \
    sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle && \
    sed -i '/id.*com.gradle.build-scan/s|^|//|' build.gradle && \
    sed -i '/buildScan {/,/^}/s|^|//|' build.gradle && \
    sed -i '/release\.gradle/s|^|//|' build.gradle && \
    sed -i '1s/.*/apply plugin: "java"/' gradle/java-library.gradle && \
    sed -i '/^allprojects {$/a\    apply from: "$rootProject.projectDir/gradle/dependencies.gradle"' build.gradle && \
    sed -i 's|compileOnly "junit:junit:4.12"|compileOnly libraries.junit4|' build.gradle && \
    sed -i "s|testCompile 'org.assertj:assertj-core:2.6.0'|testCompile libraries.assertj|" build.gradle && \
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
    (test -f subprojects/extTest/extTest.gradle && sed -i '/dependsOn.*publishToMavenLocal/s|^|//|' subprojects/extTest/extTest.gradle || true) && \
    (test -f settings.gradle && sed -i "s/include 'errorprone'/\\/\\/ include 'errorprone'/" settings.gradle || true)

RUN rm -rf /app/src/.git

WORKDIR /app/src
