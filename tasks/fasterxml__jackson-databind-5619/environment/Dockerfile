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
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin de0a01a7097e7f2f1bf63a899d0468a3d7fd727e || git fetch --depth 1 origin "+refs/pull/5619/head:refs/remotes/origin/pr/5619") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV CI=true
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Download dependencies and compile (cache warming)
RUN mvn -B -ntp dependency:resolve dependency:resolve-plugins -q || true
RUN mvn -B -ntp compile test-compile -DskipTests -q

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Recompile after applying bug.patch
RUN mvn -B -ntp compile test-compile -DskipTests -q

RUN rm -rf /app/src/.git

WORKDIR /app/src
