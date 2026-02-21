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
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV CI=true

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin ce745de9f100c63a90c06d20e51e3576761fa31b || git fetch --depth 1 origin "+refs/pull/5565/head:refs/remotes/origin/pr/5565") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download dependencies and build (parent jackson-base SNAPSHOT is resolved from
# the snapshot repo configured in pom.xml at central.sonatype.com)
RUN mvn -B -ff -ntp dependency:resolve -DskipTests || true
RUN mvn -B -ff -ntp compile test-compile -DskipTests

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for compiled Java)
RUN mvn -B -ff -ntp compile test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
