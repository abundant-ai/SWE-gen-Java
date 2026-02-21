FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 and Maven
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 58f326dec9204c13fa5bcfd42518ebca93af022b || git fetch --depth 1 origin "+refs/pull/5404/head:refs/remotes/origin/pr/5404") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV CI=true

# Copy helper script to fix the parent POM version
COPY fix_parent_pom.py /tmp/fix_parent_pom.py

# The project's parent POM (jackson-base:2.19.5-SNAPSHOT) is not yet published.
# Patch parent version to the last stable release so Maven can resolve it.
RUN python3 /tmp/fix_parent_pom.py pom.xml

# Cache Maven dependencies and compile at HEAD (with fix applied)
RUN mvn -B -ff -ntp compile test-compile -DskipTests

# Reset tracked files so bug.patch applies cleanly; pom.xml reverts to SNAPSHOT version
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Re-apply parent POM fix after reset (all deps already cached, this is fast)
RUN python3 /tmp/fix_parent_pom.py pom.xml

# Recompile after applying bug.patch
RUN mvn -B -ff -ntp compile test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
