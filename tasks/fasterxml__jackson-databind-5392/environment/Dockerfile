FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 21 and Maven
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 6e31494c715e3ccfbd671e2be2c72bc513f88a51 || git fetch --depth 1 origin "+refs/pull/5392/head:refs/remotes/origin/pr/5392") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV CI=true

# Download dependencies and compile (to populate Maven local repo cache)
RUN ./mvnw -B dependency:resolve dependency:resolve-plugins -q || true
RUN ./mvnw -B compile test-compile -q || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Recompile after applying bug.patch
RUN ./mvnw -B compile test-compile -q || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
