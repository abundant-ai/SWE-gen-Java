FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# jackson-databind needs jackson-base:2.20.1-SNAPSHOT as parent, which is not published
# to Maven Central snapshots. Build and install the parent POMs (jackson-bom + jackson-base)
# from source at the commit that has the 2.20.1-SNAPSHOT version.
RUN git clone https://github.com/FasterXML/jackson-bom.git jackson-bom && \
    cd jackson-bom && \
    git checkout 59a2e4a && \
    mvn install -N -B -q && \
    cd base && \
    mvn install -N -B -q

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin ecdee654457abea3a6a7d7fbff02032c2303698a || git fetch --depth 1 origin "+refs/pull/5311/head:refs/remotes/origin/pr/5311") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Install dependencies and compile (parent POM already installed locally above)
RUN mvn compile -B -q -Dmaven.test.skip=true

# Reset any generated files so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch
RUN mvn compile -B -q -Dmaven.test.skip=true

RUN rm -rf /app/src/.git

WORKDIR /app/src
