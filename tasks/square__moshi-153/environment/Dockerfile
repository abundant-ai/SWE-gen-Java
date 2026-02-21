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

# Build okio from source at the commit that has select(List<ByteString>) API,
# matching the 1.8.0-SNAPSHOT API that moshi PR #153 was written against.
# Released okio 1.8.0 changed the API to select(Options) which is incompatible.
RUN git clone https://github.com/square/okio.git /tmp/okio && \
    cd /tmp/okio && \
    git checkout 7cfd024caaf78080a5d0d7602767f780f6fe7017 && \
    mvn install -DskipTests && \
    rm -rf /tmp/okio

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/moshi.git src && \
    cd src && \
    (git fetch --depth 1 origin 4925755ffa90aec75c116c6204688314121f71d9 || git fetch --depth 1 origin "+refs/pull/153/head:refs/remotes/origin/pr/153") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Build the moshi module so dependencies are cached in local Maven repo
# The pom.xml uses 1.8.0-SNAPSHOT which we built and installed locally above
RUN mvn install -pl moshi -DskipTests -Dcheckstyle.skip

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/.git

WORKDIR /app/src
