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

# jackson-databind needs tools.jackson:jackson-base:3.0.0-rc11-SNAPSHOT (and jackson-core with same version)
# which are snapshots not available in remote repos; build them locally from rc10 tag with version bumped.

# Step 1: Install jackson-bom (parent of jackson-base)
RUN git clone --depth 1 --branch jackson-bom-3.0.0-rc10 https://github.com/FasterXML/jackson-bom.git jackson-bom && \
    cd jackson-bom && \
    sed -i 's/3\.0\.0-rc10/3.0.0-rc11-SNAPSHOT/g' pom.xml base/pom.xml && \
    mvn -B -ntp install -DskipTests -N && \
    cd base && mvn -B -ntp install -DskipTests && \
    cd /app && rm -rf jackson-bom

# Step 2: Install jackson-core (dependency of jackson-databind)
RUN git clone --depth 1 --branch jackson-core-3.0.0-rc10 https://github.com/FasterXML/jackson-core.git jackson-core && \
    cd jackson-core && \
    sed -i 's/3\.0\.0-rc10/3.0.0-rc11-SNAPSHOT/g' pom.xml && \
    mvn -B -ntp install -DskipTests && \
    cd /app && rm -rf jackson-core

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 2771cf8000506c8ec3b2d27e51244a329a2fa397 || git fetch --depth 1 origin "+refs/pull/5324/head:refs/remotes/origin/pr/5324") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Install dependencies and compile (pre-cache Maven artifacts)
RUN mvn -B -ntp compile test-compile -DskipTests

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch
RUN mvn -B -ntp compile test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
