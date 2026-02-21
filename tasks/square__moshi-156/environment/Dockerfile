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

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/moshi.git src && \
    cd src && \
    (git fetch --depth 1 origin 20a64dff7ebf19a33575cb1df6f6724d8474c732 || git fetch --depth 1 origin "+refs/pull/156/head:refs/remotes/origin/pr/156") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Replace SNAPSHOT dependency with released version (okio 1.8.0-SNAPSHOT is no longer available on snapshot repo)
# Build the moshi module so dependencies are cached in local Maven repo
RUN sed -i 's/1.8.0-SNAPSHOT/1.8.0/g' pom.xml && \
    mvn install -pl moshi -DskipTests -Dcheckstyle.skip

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
# Re-apply the okio version fix after reset since pom.xml is a tracked file
RUN git reset --hard && sed -i 's/1.8.0-SNAPSHOT/1.8.0/g' pom.xml

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/.git

WORKDIR /app/src
