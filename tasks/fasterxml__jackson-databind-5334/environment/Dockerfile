FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 and Maven
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
ENV CI=true

WORKDIR /app

# Build jackson-bom (provides jackson-base:3.0.0-rc11-SNAPSHOT) from source
# This SNAPSHOT is not published; must be installed locally before building jackson-databind
RUN git clone --branch 3.x https://github.com/FasterXML/jackson-bom.git jackson-bom && \
    cd jackson-bom && \
    git checkout 47c3612b5e && \
    mvn -B -ff -ntp -DskipTests install && \
    cd /app && rm -rf jackson-bom

# Build jackson-core:3.0.0-rc11-SNAPSHOT from source and install to local Maven repo.
# Use commit 699243ee5e where JsonGenerator.getPrettyPrinter() is abstract, requiring
# explicit implementations in TokenBuffer and TreeBuildingGenerator (added by this PR).
RUN git clone --branch 3.x https://github.com/FasterXML/jackson-core.git jackson-core && \
    cd jackson-core && \
    git checkout 699243ee5e && \
    mvn -B -ff -ntp -DskipTests install && \
    cd /app && rm -rf jackson-core

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin dbf8d9f6214fcbbd05ce7354c9694e3f5a4e5ce5 || git fetch --depth 1 origin "+refs/pull/5334/head:refs/remotes/origin/pr/5334") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Compile main and test sources using locally installed SNAPSHOT dependencies
RUN ./mvnw -B -ff -ntp -DskipTests compile test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Note: Do NOT recompile after applying bug.patch. With jackson-core at 699243ee5e,
# TokenBuffer and TreeBuildingGenerator are missing required implementations of the
# abstract JsonGenerator.getPrettyPrinter() method. Compilation will fail until the
# fix is applied. The test.sh recompile step will catch this failure for NOP runs.

RUN rm -rf /app/src/.git

WORKDIR /app/src
