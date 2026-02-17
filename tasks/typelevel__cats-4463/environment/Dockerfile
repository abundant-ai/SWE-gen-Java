FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 (primary version used in CI) and SBT
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    gnupg \
    && echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add - && \
    apt-get update && apt-get install -y sbt && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/typelevel/cats.git src && \
    cd src && \
    (git fetch --depth 1 origin 5c69f839b2ca59d162e74ff85c6a420746cacd52 || git fetch --depth 1 origin "+refs/pull/4463/head:refs/remotes/origin/pr/4463") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Pre-fetch dependencies and compile project including tests
RUN sbt +update && sbt "testsJVM / Test / compile"

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Incrementally recompile only the changed source files
RUN sbt "testsJVM / Test / compile"

RUN rm -rf /app/src/.git

WORKDIR /app/src
