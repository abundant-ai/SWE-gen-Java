FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 (compatible with Java 8+ baseline)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Install parent POM hierarchy: oss-parent (70) -> jackson-parent (2.20-SNAPSHOT) -> jackson-bom (2.20.0-SNAPSHOT) -> jackson-databind
# Install oss-parent version 70
RUN git clone https://github.com/FasterXML/oss-parent.git oss-parent && \
    cd oss-parent && \
    git checkout oss-parent-70 && \
    ./mvnw -B -ff -ntp clean install -N

# Install jackson-parent version 2.20-SNAPSHOT
RUN git clone https://github.com/FasterXML/jackson-parent.git jackson-parent && \
    cd jackson-parent && \
    git checkout a2eefeb && \
    ./mvnw -B -ff -ntp clean install -N

# Install jackson-bom with matching 2.20.0-SNAPSHOT version
RUN git clone https://github.com/FasterXML/jackson-bom.git jackson-bom && \
    cd jackson-bom && \
    git checkout 53289b1 && \
    ./mvnw -B -ff -ntp clean install -DskipTests

# Install jackson-core 2.20.0 (dependency of jackson-databind)
RUN git clone https://github.com/FasterXML/jackson-core.git jackson-core && \
    cd jackson-core && \
    git checkout jackson-core-2.20.0 && \
    ./mvnw -B -ff -ntp clean install -DskipTests

# Install jackson-annotations 2.20 (dependency of jackson-databind)
RUN git clone https://github.com/FasterXML/jackson-annotations.git jackson-annotations && \
    cd jackson-annotations && \
    git checkout jackson-annotations-2.20 && \
    ./mvnw -B -ff -ntp clean install -DskipTests

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin aff7599d00c06ec67cf2f20b64cbd8a3ae6c3e07 || git fetch --depth 1 origin "+refs/pull/5282/head:refs/remotes/origin/pr/5282") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Maven
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Override dependency versions to match what we have installed (2.20.0 and 2.20 releases)
# Update jackson-core dependency version from 2.20.0-SNAPSHOT to 2.20.0
RUN sed -i 's/<version>${jackson.version.core}<\/version>/<version>2.20.0<\/version>/g' pom.xml

# Update jackson-annotations dependency version from 2.20.0-SNAPSHOT to 2.20
RUN sed -i 's/<version>${jackson.version.annotations}<\/version>/<version>2.20<\/version>/g' pom.xml

# Build the project (compile main and test classes)
RUN ./mvnw -B -ff -ntp clean compile test-compile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Re-apply dependency version overrides (reverted by git reset)
RUN sed -i 's/<version>${jackson.version.core}<\/version>/<version>2.20.0<\/version>/g' pom.xml && \
    sed -i 's/<version>${jackson.version.annotations}<\/version>/<version>2.20<\/version>/g' pom.xml

# Rebuild after applying bug.patch (required for compiled languages like Java)
RUN ./mvnw -B -ff -ntp compile test-compile

RUN rm -rf /app/src/.git

WORKDIR /app/src
