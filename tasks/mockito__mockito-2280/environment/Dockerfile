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
    (git fetch --depth 1 origin 4807a567c13468ccd787627010bf0f2c1fe9a7f6 || git fetch --depth 1 origin "+refs/pull/2280/head:refs/remotes/origin/pr/2280") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Fix jcenter repository (JCenter is shut down) and remove bintray plugin (not needed for tests)
RUN sed -i 's/jcenter()/mavenCentral()/g' build.gradle && \
    sed -i '/gradle-bintray-plugin/d' build.gradle && \
    sed -i '/apply plugin.*bintray/d' gradle/java-publication.gradle && \
    sed -i '/^bintray {/,/^}/d' gradle/java-publication.gradle && \
    sed -i '/bintrayPublish/d' gradle/shipkit.gradle

# Download dependencies using Gradle
RUN ./gradlew dependencies --no-daemon || true

# Build the project (Java/Kotlin compilation)
RUN ./gradlew build -x test --no-daemon || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Reapply jcenter fix after patching (git reset undid our changes)
RUN sed -i 's/jcenter()/mavenCentral()/g' build.gradle && \
    sed -i '/gradle-bintray-plugin/d' build.gradle && \
    sed -i '/apply plugin.*bintray/d' gradle/java-publication.gradle && \
    sed -i '/^bintray {/,/^}/d' gradle/java-publication.gradle && \
    sed -i '/bintrayPublish/d' gradle/shipkit.gradle

# Rebuild after applying bug.patch (Java/Kotlin needs recompilation)
RUN ./gradlew build -x test --no-daemon || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
