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

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV CI=true
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

WORKDIR /app

# Build and install jackson-bom + jackson-base 3.0.1-SNAPSHOT
# (required parent POM not available in public snapshot repos; must be built from source)
RUN git clone https://github.com/FasterXML/jackson-bom.git /app/jackson-bom && \
    cd /app/jackson-bom && \
    git checkout 410ff87 && \
    mvn -B -ntp install -N -q && \
    mvn -B -ntp install -pl base -q && \
    rm -rf /app/jackson-bom

# Build and install jackson-core 3.0.1-SNAPSHOT
RUN git clone https://github.com/FasterXML/jackson-core.git /app/jackson-core && \
    cd /app/jackson-core && \
    git checkout a6f16ef2 && \
    mvn -B -ntp install -DskipTests -q && \
    rm -rf /app/jackson-core

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 4acae8d600510a6195fb5f4b68688a1f7997704e || git fetch --depth 1 origin "+refs/pull/5349/head:refs/remotes/origin/pr/5349") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Pre-download dependencies and compile to warm up Maven cache
RUN mvn -B -ntp dependency:resolve dependency:resolve-plugins -q
RUN mvn -B -ntp compile test-compile -DskipTests -q

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Recompile after applying bug.patch
RUN mvn -B -ntp compile test-compile -DskipTests -q

RUN rm -rf /app/src/.git

WORKDIR /app/src
