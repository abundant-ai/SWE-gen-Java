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
    openjdk-21-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/FasterXML/jackson-databind.git src && \
    cd src && \
    (git fetch --depth 1 origin 40a20b22fc620a7a08729b3df2f8af1d96958752 || git fetch --depth 1 origin "+refs/pull/5415/head:refs/remotes/origin/pr/5415") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV CI=true
ENV JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Resolve and cache dependencies, then compile (build with tests compiled)
RUN ./mvnw -B -ff -ntp dependency:resolve test-compile -DskipTests || \
    ./mvnw -B -ntp dependency:resolve test-compile -DskipTests

# Reset any files modified during the build process so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Recompile after applying bug.patch (Java requires recompilation)
RUN ./mvnw -B -ff -ntp test-compile -DskipTests || \
    ./mvnw -B -ntp test-compile -DskipTests

RUN rm -rf /app/src/.git

WORKDIR /app/src
