FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 11 (required for Scala/SBT) and SBT
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    gnupg \
    && echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add - && \
    apt-get update && apt-get install -y sbt && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/typelevel/cats.git src && \
    cd src && \
    (git fetch --depth 1 origin 8335f18a2fda9cabf01e370a61c0ef2defe7b131 || git fetch --depth 1 origin "+refs/pull/3292/head:refs/remotes/origin/pr/3292") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Override JVM options to fit within container memory limits (container has 4096 MB)
RUN echo "-Dfile.encoding=UTF8" > /app/src/.jvmopts && \
    echo "-Xms512M" >> /app/src/.jvmopts && \
    echo "-Xmx3G" >> /app/src/.jvmopts && \
    echo "-XX:ReservedCodeCacheSize=256M" >> /app/src/.jvmopts && \
    echo "-XX:+TieredCompilation" >> /app/src/.jvmopts

# Pre-fetch SBT dependencies and compile HEAD test sources to warm up ivy/coursier cache
RUN sbt "testsJVM/Test/compile"

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# NOTE: We intentionally do NOT recompile after applying bug.patch.
# The HEAD artifacts from above allow the oracle agent (which reverts to HEAD via fix.patch)
# to use incremental compilation - only the changed test file needs recompilation.
# NOP tests will also benefit: buggy core files + HEAD test file = fast compile failure.

RUN rm -rf /app/src/.git

WORKDIR /app/src
