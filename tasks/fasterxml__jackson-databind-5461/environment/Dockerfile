FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    git curl ca-certificates patch build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 21 (required for test sources that use Java 21 features)
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin fdafbdd0671078214267fcb8e685b4d3f3f28fe9 || \
     git fetch --depth 1 origin "+refs/pull/5461/head:refs/remotes/origin/pr/5461") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV CI=true

# Pre-download Maven dependencies and compile (skipping tests)
RUN ./mvnw -B -ntp -DskipTests dependency:resolve compile test-compile

RUN git reset --hard

COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch
RUN ./mvnw -B -ntp -DskipTests compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
