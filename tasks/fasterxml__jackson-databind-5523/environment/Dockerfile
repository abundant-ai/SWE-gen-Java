FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 JDK (required by pom.xml and CI config)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 764344b65304a541fe164279f28f8b6e500f8251 || git fetch --depth 1 origin "+refs/pull/5523/head:refs/remotes/origin/pr/5523") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV CI=true

# Pre-download Maven dependencies (using the bundled mvnw wrapper)
RUN ./mvnw -B -ntp dependency:resolve dependency:resolve-plugins -q || true

# Compile the project to verify build works
RUN ./mvnw -B -ntp compile test-compile -q

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after patching (required for Java compiled language)
RUN ./mvnw -B -ntp compile test-compile -q

RUN rm -rf /app/src/.git

WORKDIR /app/src
