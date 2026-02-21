FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 and Maven (this project uses Maven and Java 1.7 target, need Java 8 to compile)
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Use Java 8 for BASE state (needed to compile to Java 1.7 target)
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Pre-install me.eugeniomarletti:kotlin-metadata:1.2.1 using 1.3.0 from Maven Central as a substitute.
# JCenter (original host of 1.2.1) is defunct. Version 1.3.0 on Maven Central is API-compatible
# (same packages, uses original org.jetbrains.kotlin.serialization.ProtoBuf, has getPropertyOrNull).
RUN curl -fsSL "https://repo1.maven.org/maven2/me/eugeniomarletti/kotlin/metadata/kotlin-metadata/1.3.0/kotlin-metadata-1.3.0.jar" \
        -o /tmp/kotlin-metadata.jar && \
    mvn install:install-file \
        -Dfile=/tmp/kotlin-metadata.jar \
        -DgroupId=me.eugeniomarletti \
        -DartifactId=kotlin-metadata \
        -Dversion=1.2.1 \
        -Dpackaging=jar \
        -DgeneratePom=true && \
    rm /tmp/kotlin-metadata.jar

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/moshi.git src && \
    cd src && \
    (git fetch --depth 1 origin b3d7dfd6030ee4443e723e143c94e0c2970277ea || git fetch --depth 1 origin "+refs/pull/472/head:refs/remotes/origin/pr/472") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download Maven dependencies and compile the modules needed for kotlin-codegen tests.
# Includes kotlin-codegen/compiler (annotation processor) and kotlin-codegen/integration-test.
RUN mvn install -pl kotlin-codegen/compiler,kotlin-codegen/integration-test -am -DskipTests -Dcheckstyle.skip

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for compiled languages)
RUN mvn install -pl kotlin-codegen/compiler,kotlin-codegen/integration-test -am -DskipTests -Dcheckstyle.skip

RUN rm -rf /app/src/.git

WORKDIR /app/src
