FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    git curl ca-certificates patch build-essential \
    openjdk-17-jdk maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV CI=true

WORKDIR /app

RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 90a1df133466b145ea12af214b5bc70366704fd6 || \
     git fetch --depth 1 origin "+refs/pull/5382/head:refs/remotes/origin/pr/5382") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download dependencies and compile (skip tests)
RUN mvn -B -ntp -DskipTests install

RUN git reset --hard

COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Recompile after applying bug.patch
RUN mvn -B -ntp -DskipTests compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
