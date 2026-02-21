FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 and Maven (this project uses Maven and Java 1.6 target, need Java 8 to compile)
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Use Java 8
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/moshi.git src && \
    cd src && \
    (git fetch --depth 1 origin 93eddc9069e4fe783f5ca5d6b48045556b69f315 || git fetch --depth 1 origin "+refs/pull/4/head:refs/remotes/origin/pr/4") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# This PR depends on okio:1.0.2-SNAPSHOT which no longer exists in the snapshot repo.
# Install okio:1.1.0 (has compatible API with indexOfElement and request) as 1.0.2-SNAPSHOT.
RUN mvn dependency:get -Dartifact=com.squareup.okio:okio:1.1.0 -Ddest=/tmp/okio-1.1.0.jar && \
    mvn install:install-file \
      -Dfile=/tmp/okio-1.1.0.jar \
      -DgroupId=com.squareup.okio \
      -DartifactId=okio \
      -Dversion=1.0.2-SNAPSHOT \
      -Dpackaging=jar

# Install parent POM and moshi module so dependencies are cached in local Maven repo
RUN mvn install -N -Dcheckstyle.skip && \
    mvn install -pl moshi -DskipTests -Dcheckstyle.skip

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/.git

WORKDIR /app/src
