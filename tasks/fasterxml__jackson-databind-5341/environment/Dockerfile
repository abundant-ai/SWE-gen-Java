FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (JDK) and Maven
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Build and install jackson-bom (provides jackson-base parent POM) at 3.0.1-SNAPSHOT
# Clone at the 3.0.1 tag, bump version to SNAPSHOT, then install to local repo
RUN git clone --depth 1 --branch jackson-bom-3.0.1 https://github.com/FasterXML/jackson-bom.git jackson-bom && \
    cd jackson-bom && \
    sed -i 's|<version>3.0.1</version>|<version>3.0.1-SNAPSHOT</version>|g' pom.xml base/pom.xml && \
    mvn -B -ntp -q install -DskipTests

# Build and install jackson-annotations at 2.20
RUN git clone --depth 1 --branch jackson-annotations-2.20 https://github.com/FasterXML/jackson-annotations.git jackson-annotations && \
    cd jackson-annotations && \
    mvn -B -ntp -q install -DskipTests

# Build and install jackson-core at 3.0.1-SNAPSHOT
# Clone at the 3.0.1 tag, bump version to SNAPSHOT, then install
RUN git clone --depth 1 --branch jackson-core-3.0.1 https://github.com/FasterXML/jackson-core.git jackson-core && \
    cd jackson-core && \
    sed -i 's|<version>3.0.1</version>|<version>3.0.1-SNAPSHOT</version>|g' pom.xml && \
    sed -i 's|<version>3.0.1</version>|<version>3.0.1-SNAPSHOT</version>|g' pom.xml || true && \
    mvn -B -ntp -q install -DskipTests

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 2ed454423ea4f18bcaaaa2d5cb48b5353ae00d9a || git fetch --depth 1 origin "+refs/pull/5341/head:refs/remotes/origin/pr/5341") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV CI=true

# Download dependencies and compile
RUN mvn -B -ntp -q compile test-compile

# If build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Recompile after applying bug.patch
RUN mvn -B -ntp -q compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
