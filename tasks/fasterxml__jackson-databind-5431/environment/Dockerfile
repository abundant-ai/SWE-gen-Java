FROM ubuntu:24.04

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
ENV PATH="$JAVA_HOME/bin:$PATH"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 89ff6a3bfe649860ca9f4332378fe0f1b837adc3 || git fetch --depth 1 origin "+refs/pull/5431/head:refs/remotes/origin/pr/5431") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Install dependencies (skip tests and enforcer to avoid snapshot resolution issues)
RUN mvn dependency:resolve -B -DskipTests -Denforcer.skip=true || true

# Build the project
RUN mvn compile -B -DskipTests -Denforcer.skip=true

# Reset any files touched during build so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch
RUN mvn compile -B -DskipTests -Denforcer.skip=true

RUN rm -rf /app/src/.git

WORKDIR /app/src
