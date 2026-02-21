FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 and Maven (baseline: Java 17 per pom.xml)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone jackson-bom to get jackson-base parent POM (version 3.0.0-rc9-SNAPSHOT)
RUN git clone https://github.com/FasterXML/jackson-bom.git jackson-bom && \
    cd jackson-bom && \
    git checkout deb63af && \
    ./mvnw -B -ff -ntp install -N && \
    ./mvnw -B -ff -ntp -f base/pom.xml install -N

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin aaec5ff873951ae8569bd1327e5b6545428b38ba || git fetch --depth 1 origin "+refs/pull/5264/head:refs/remotes/origin/pr/5264") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set Java build optimization for faster builds (from CI config)
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Download dependencies only (compilation happens in test.sh after patching test files)
RUN ./mvnw -B -ff -ntp dependency:resolve || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Note: After bug.patch, code won't compile due to API incompatibility
# Compilation will happen in test.sh after copying updated test files

RUN rm -rf /app/src/.git

WORKDIR /app/src
