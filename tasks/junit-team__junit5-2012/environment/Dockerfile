FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Download and install Java 13 manually (not in Ubuntu 24.04 repos, but needed for Gradle 5.6.2 compatibility)
RUN apt-get update && apt-get install -y wget && \
    wget -q https://download.java.net/java/GA/jdk13.0.2/d4173c853231432d94f001e99d882ca7/8/GPL/openjdk-13.0.2_linux-x64_bin.tar.gz && \
    tar xzf openjdk-13.0.2_linux-x64_bin.tar.gz -C /opt && \
    rm openjdk-13.0.2_linux-x64_bin.tar.gz && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/opt/jdk-13.0.2
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Disable git versioning plugin to avoid grgit dependency issues
ENV GRADLE_PROJECT_release.useLastTag=false

# Disable Kotlin's allWarningsAsErrors to allow deprecated language version warnings
ENV ORG_GRADLE_PROJECT_kotlin.allWarningsAsErrors=false

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/junit-team/junit5.git src && \
    cd src && \
    (git fetch --depth 1 origin eee665b666b03af3939ce516bd06fb0fba2c48e3 || git fetch --depth 1 origin "+refs/pull/2012/head:refs/remotes/origin/pr/2012") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Remove versioning plugin usage from build.gradle.kts to avoid grgit dependency issues
# Replace versioning.info references with dummy values
RUN sed -i '/id("net.nemerosa.versioning")/d' build.gradle.kts && \
    sed -i 's/versioning\.info\.branch/"unknown"/g' build.gradle.kts && \
    sed -i 's/versioning\.info\.commit/"unknown"/g' build.gradle.kts && \
    sed -i 's/versioning\.info\.dirty/false/g' build.gradle.kts && \
    sed -i '/versioning {/,/^}/d' build.gradle.kts

# Remove documentation project from settings.gradle.kts to avoid grgit dependency
RUN sed -i '/include("documentation")/d' settings.gradle.kts

# Build the project - skip tests and problematic tasks (spotless, compileModule)
RUN ./gradlew build -x test -x compileModule -x spotlessKotlin -x spotlessGroovy -x spotlessJava --no-daemon || \
    (sleep 2 && ./gradlew build -x test -x compileModule -x spotlessKotlin -x spotlessGroovy -x spotlessJava --no-daemon) || \
    (sleep 5 && ./gradlew build -x test -x compileModule -x spotlessKotlin -x spotlessGroovy -x spotlessJava --no-daemon)

# Reset tracked files so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch
RUN ./gradlew build publishToMavenLocal -x test --no-daemon || \
    (sleep 2 && ./gradlew build publishToMavenLocal -x test --no-daemon) || \
    (sleep 5 && ./gradlew build publishToMavenLocal -x test --no-daemon)

WORKDIR /app/src
