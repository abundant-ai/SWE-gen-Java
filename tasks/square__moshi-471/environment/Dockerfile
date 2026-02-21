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
    (git fetch --depth 1 origin 0c24bd4846d35bad8772ba16f462875b50c64453 || git fetch --depth 1 origin "+refs/pull/471/head:refs/remotes/origin/pr/471") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download Maven dependencies and compile the kotlin-codegen/compiler module (HEAD/fixed state).
RUN mvn install -pl kotlin-codegen/compiler -am -DskipTests -Dcheckstyle.skip

# Pre-install a stub moshi-kotlin-codegen-runtime jar so that the bug.patch state
# (which adds this dependency) can still resolve it. The module was folded into moshi
# in a later commit, so it doesn't exist as a separate module at this SHA.
# Use the already-built moshi jar as the stub (it's API-compatible for compilation purposes).
RUN mvn install:install-file \
    -Dfile=/root/.m2/repository/com/squareup/moshi/moshi/1.6.0-SNAPSHOT/moshi-1.6.0-SNAPSHOT.jar \
    -DgroupId=com.squareup.moshi \
    -DartifactId=moshi-kotlin-codegen-runtime \
    -Dversion=1.6.0-SNAPSHOT \
    -Dpackaging=jar \
    -DgeneratePom=true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# The bug.patch removes kotlin-metadata and other deps from pom.xml, making the main sources
# uncompilable. The pre-built compiler jar from the HEAD state remains in the Maven local repo.
# Rebuilding is intentionally skipped here; the fix.patch restores proper deps for Oracle.

RUN rm -rf /app/src/.git

WORKDIR /app/src
