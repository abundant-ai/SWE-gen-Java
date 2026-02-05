FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 (Gradle 3.5 compatibility) and Ant (needed for jar task)
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    ca-certificates-java \
    ant \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/mockito/mockito.git src && \
    cd src && \
    (git fetch --depth 1 origin 4003e40771d15ba6ccea5941e00cdf1b231244f3 || git fetch --depth 1 origin "+refs/pull/30/head:refs/remotes/origin/pr/30") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Fix Gradle wrapper to use HTTPS
RUN sed -i 's|http\\://services.gradle.org|https\\://services.gradle.org|g' gradle/wrapper/gradle-wrapper.properties

# Fix Maven Central repository URLs to use HTTPS (HTTP is no longer supported)
RUN find . -name "*.gradle" -type f -exec sed -i 's|http://repo1.maven.org/maven2|https://repo1.maven.org/maven2|g' {} \;

# Fix jcenter and bintray repositories (both are shut down) and comment out shipkit/build-scan plugins (requires unavailable dependencies)
# Disable error-prone plugin (incompatible with Gradle 4.7 + Java 8)
# Disable coverage plugins (cobertura and coveralls) that fail to download
# Fix extTest dependency on publishToMavenLocal
RUN sed -i '/^import org.apache.xalan/s|^|//|' build.gradle && \
    sed -i 's|jcenter()|mavenCentral()|g' build.gradle && \
    (test -f subprojects/osgi-test/osgi-test-bundles.gradle && sed -i 's|jcenter()|mavenCentral()|g' subprojects/osgi-test/osgi-test-bundles.gradle || true) && \
    sed -i '/classpath.*gradle-cobertura-plugin/s|^|//|' build.gradle && \
    sed -i '/classpath.*coveralls-gradle-plugin/s|^|//|' build.gradle && \
    sed -i "/^apply plugin: 'cobertura'/s|^|//|" build.gradle && \
    sed -i "/^apply plugin: 'coveralls'/s|^|//|" build.gradle && \
    sed -i "/^cobertura\\.coverageFormats/s|^|//|" build.gradle && \
    sed -i "/^.*cobertura\\.coverageIgnoreTrivial/s|^|//|" build.gradle && \
    sed -i '/classpath.*mockito-release-tools/s|^|//|' build.gradle && \
    sed -i '/classpath.*bintray/s|^|//|' build.gradle && \
    sed -i '/classpath.*http-builder/s|^|//|' build.gradle && \
    sed -i '/classpath.*shipkit/s|^|//|' build.gradle && \
    sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle && \
    sed -i '/id.*com.gradle.build-scan/s|^|//|' build.gradle && \
    sed -i '/id.*me.champeau.buildscan-recipes/s|^|//|' build.gradle && \
    sed -i '/apply plugin.*me.champeau.buildscan-recipes/s|^|//|' build.gradle && \
    sed -i '/buildScan {/,/^}/s|^|//|' build.gradle && \
    sed -i '/release\.gradle/s|^|//|' build.gradle && \
    sed -i '/release\.mustRunAfter/s|^|//|' build.gradle && \
    sed -i '/publishable-java-library\.gradle/s|^|//|' build.gradle && \
    sed -i '16a apply plugin: "java"' build.gradle && \
    (test -f gradle/java-library.gradle && sed -i '1s/.*/apply plugin: "java"/' gradle/java-library.gradle || true) && \
    sed -i '/bintrayUpload/s|^|//|' build.gradle && \
    (test -f gradle/java-library.gradle && sed -i '/generatePomFileForJavaLibraryPublication/,/^}/s|^|//|' gradle/java-library.gradle || true) && \
    (test -f gradle/java-library.gradle && sed -i '/bintrayUpload\.enabled/s|^|//|' gradle/java-library.gradle || true) && \
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

# Disable buildSrc tests by renaming the test directory
RUN test -d buildSrc/src/test && mv buildSrc/src/test buildSrc/src/test.disabled || true

# Fix kotlinTest dependency on kotlinx-coroutines-core (0.14 no longer available, use 0.19)
RUN test -f subprojects/kotlinTest/build.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/build.gradle || true

# Download dependencies using Gradle
RUN ./gradlew dependencies --no-daemon || true

# Build the project (Java/Kotlin compilation)
RUN ./gradlew build -x test --no-daemon || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Normalize line endings to LF to ensure patch applies cleanly
RUN apt-get update && apt-get install -y dos2unix && rm -rf /var/lib/apt/lists/* && \
    find . -name "*.java" -type f -exec dos2unix {} \; 2>/dev/null || true

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Disable errorprone and kotlinReleaseCoroutinesTest subprojects again after patching (git reset undid the rename)
RUN test -d subprojects/errorprone && mv subprojects/errorprone subprojects/errorprone.disabled || true
RUN test -d subprojects/kotlinReleaseCoroutinesTest && mv subprojects/kotlinReleaseCoroutinesTest subprojects/kotlinReleaseCoroutinesTest.disabled || true

# Disable buildSrc tests by renaming the test directory
RUN test -d buildSrc/src/test && mv buildSrc/src/test buildSrc/src/test.disabled || true

# Fix kotlinTest dependency on kotlinx-coroutines-core again (git reset undid our changes)
RUN test -f subprojects/kotlinTest/build.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/build.gradle || true

# Fix Gradle wrapper to use HTTPS again (git reset undid our changes)
RUN sed -i 's|http\\://services.gradle.org|https\\://services.gradle.org|g' gradle/wrapper/gradle-wrapper.properties

# Fix Maven Central repository URLs to use HTTPS again (git reset undid our changes)
RUN find . -name "*.gradle" -type f -exec sed -i 's|http://repo1.maven.org/maven2|https://repo1.maven.org/maven2|g' {} \;

# Reapply jcenter and bintray fix after patching (git reset undid our changes)
# Disable error-prone plugin again (git reset undid our changes)
# Disable coverage plugins again (git reset undid our changes)
# Fix extTest dependency on publishToMavenLocal again
RUN sed -i '/^import org.apache.xalan/s|^|//|' build.gradle && \
    sed -i 's|jcenter()|mavenCentral()|g' build.gradle && \
    (test -f subprojects/osgi-test/osgi-test-bundles.gradle && sed -i 's|jcenter()|mavenCentral()|g' subprojects/osgi-test/osgi-test-bundles.gradle || true) && \
    sed -i '/classpath.*gradle-cobertura-plugin/s|^|//|' build.gradle && \
    sed -i '/classpath.*coveralls-gradle-plugin/s|^|//|' build.gradle && \
    sed -i "/^apply plugin: 'cobertura'/s|^|//|" build.gradle && \
    sed -i "/^apply plugin: 'coveralls'/s|^|//|" build.gradle && \
    sed -i "/^cobertura\\.coverageFormats/s|^|//|" build.gradle && \
    sed -i "/^.*cobertura\\.coverageIgnoreTrivial/s|^|//|" build.gradle && \
    sed -i '/classpath.*mockito-release-tools/s|^|//|' build.gradle && \
    sed -i '/classpath.*bintray/s|^|//|' build.gradle && \
    sed -i '/classpath.*http-builder/s|^|//|' build.gradle && \
    sed -i '/classpath.*shipkit/s|^|//|' build.gradle && \
    sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle && \
    sed -i '/id.*com.gradle.build-scan/s|^|//|' build.gradle && \
    sed -i '/id.*me.champeau.buildscan-recipes/s|^|//|' build.gradle && \
    sed -i '/apply plugin.*me.champeau.buildscan-recipes/s|^|//|' build.gradle && \
    sed -i '/buildScan {/,/^}/s|^|//|' build.gradle && \
    sed -i '/release\.gradle/s|^|//|' build.gradle && \
    sed -i '/release\.mustRunAfter/s|^|//|' build.gradle && \
    sed -i '/publishable-java-library\.gradle/s|^|//|' build.gradle && \
    sed -i '16a apply plugin: "java"' build.gradle && \
    (test -f gradle/java-library.gradle && sed -i '1s/.*/apply plugin: "java"/' gradle/java-library.gradle || true) && \
    sed -i '/bintrayUpload/s|^|//|' build.gradle && \
    (test -f gradle/java-library.gradle && sed -i '/generatePomFileForJavaLibraryPublication/,/^}/s|^|//|' gradle/java-library.gradle || true) && \
    (test -f gradle/java-library.gradle && sed -i '/bintrayUpload\.enabled/s|^|//|' gradle/java-library.gradle || true) && \
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
