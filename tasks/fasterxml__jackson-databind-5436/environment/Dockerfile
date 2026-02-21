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

WORKDIR /app

# Build and install jackson-bom (which includes jackson-base) locally.
# jackson-databind 3.0.3-SNAPSHOT depends on jackson-base:3.0.3-SNAPSHOT which
# is not published to the Maven snapshot repository; we use the corresponding
# commit (ada83b5) from the jackson-bom 3.0 branch.
RUN git clone https://github.com/FasterXML/jackson-bom.git jackson-bom && \
    cd jackson-bom && \
    git checkout ada83b5 && \
    mvn -B -ntp install -DskipTests

# Build and install jackson-core:3.0.3-SNAPSHOT locally (not on Maven snapshot repo).
# Uses commit 6b2ae07 (Post-release dep version bump after 3.0.2 release).
RUN git clone https://github.com/FasterXML/jackson-core.git jackson-core && \
    cd jackson-core && \
    git checkout 6b2ae07 && \
    mvn -B -ntp install -DskipTests

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin f645c7c25ea26a0857f05421703ddc65e165b264 || git fetch --depth 1 origin "+refs/pull/5436/head:refs/remotes/origin/pr/5436") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Pre-download dependencies and compile
RUN mvn -B -ntp compile test-compile -DskipTests

# Reset any changes from build steps so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Recompile after applying bug.patch
RUN mvn -B -ntp compile test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
