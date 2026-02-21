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
# Install with the actual pom so transitive deps (kotlin-compiler-embeddable) are resolved.
RUN curl -fsSL "https://repo1.maven.org/maven2/me/eugeniomarletti/kotlin/metadata/kotlin-metadata/1.3.0/kotlin-metadata-1.3.0.jar" \
        -o /tmp/kotlin-metadata.jar && \
    curl -fsSL "https://repo1.maven.org/maven2/me/eugeniomarletti/kotlin/metadata/kotlin-metadata/1.3.0/kotlin-metadata-1.3.0.pom" \
        -o /tmp/kotlin-metadata.pom && \
    mvn install:install-file \
        -Dfile=/tmp/kotlin-metadata.jar \
        -DpomFile=/tmp/kotlin-metadata.pom \
        -DgroupId=me.eugeniomarletti \
        -DartifactId=kotlin-metadata \
        -Dversion=1.2.1 \
        -Dpackaging=jar && \
    rm /tmp/kotlin-metadata.jar /tmp/kotlin-metadata.pom

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/moshi.git src && \
    cd src && \
    (git fetch --depth 1 origin 31b11f06ec0856c579ce92b2186c18ad9e75a93d || git fetch --depth 1 origin "+refs/pull/435/head:refs/remotes/origin/pr/435") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Build the moshi core module first so we have the jar available.
RUN mvn install -pl moshi -DskipTests -Dcheckstyle.skip

# Pre-install a stub moshi-kotlin-codegen-runtime jar so the compiler (which depends on it
# at HEAD) can build. At HEAD the runtime was folded into moshi itself; the compiler still
# declares the dependency but the classes now live in moshi. Use the moshi jar as a stub.
RUN mvn install:install-file \
    -Dfile=/root/.m2/repository/com/squareup/moshi/moshi/1.6.0-SNAPSHOT/moshi-1.6.0-SNAPSHOT.jar \
    -DgroupId=com.squareup.moshi \
    -DartifactId=moshi-kotlin-codegen-runtime \
    -Dversion=1.6.0-SNAPSHOT \
    -Dpackaging=jar \
    -DgeneratePom=true

# Now build the compiler (and remaining dependencies) with the stub runtime available.
RUN mvn install -pl kotlin-codegen/compiler -am -DskipTests -Dcheckstyle.skip

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# The bug.patch introduces a new runtime module and modifies integration-test to use
# MoshiSerializable/MoshiSerializableFactory. The pre-built compiler jar and stub runtime
# jar remain in the Maven local repo for use during tests.

RUN rm -rf /app/src/.git

WORKDIR /app/src
