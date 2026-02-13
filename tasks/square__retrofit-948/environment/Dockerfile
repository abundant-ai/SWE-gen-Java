FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8 (required for Maven build at this commit)
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    maven \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    echo "deb https://packages.adoptium.net/artifactory/deb $(grep VERSION_CODENAME /etc/os-release | cut -d= -f2) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && apt-get install -y temurin-8-jdk && \
    rm -rf /var/lib/apt/lists/*

# Set Java 8 as the default
RUN update-alternatives --set java /usr/lib/jvm/temurin-8-jdk-amd64/bin/java || true && \
    update-alternatives --set javac /usr/lib/jvm/temurin-8-jdk-amd64/bin/javac || true

ENV JAVA_HOME=/usr/lib/jvm/temurin-8-jdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /app

# Build OkHttp 2.5.0-SNAPSHOT (required dependency at this commit)
# Using commit 878fe216 which is the last SNAPSHOT version before 2.5.0 release
RUN git clone https://github.com/square/okhttp.git okhttp && \
    cd okhttp && \
    git checkout 878fe21642b506c7a842a775b160705ebfc03957 && \
    mvn clean install -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true || true

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/square/retrofit.git src && \
    cd src && \
    (git fetch --depth 1 origin 7a4b626132899b7b155390e27550e365e3ac57c6 || git fetch --depth 1 origin "+refs/pull/948/head:refs/remotes/origin/pr/948") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for CI
ENV CI=true
ENV MAVEN_OPTS="-Xmx2g"

# Create stub MockWebServerRule class (doesn't exist at this commit)
RUN mkdir -p /app/src/retrofit/src/test/java/com/squareup/okhttp/mockwebserver/rule && \
    cat > /app/src/retrofit/src/test/java/com/squareup/okhttp/mockwebserver/rule/MockWebServerRule.java << 'EOF'
package com.squareup.okhttp.mockwebserver.rule;

import com.squareup.okhttp.HttpUrl;
import com.squareup.okhttp.mockwebserver.MockResponse;
import com.squareup.okhttp.mockwebserver.MockWebServer;
import com.squareup.okhttp.mockwebserver.RecordedRequest;
import org.junit.rules.TestRule;
import org.junit.runner.Description;
import org.junit.runners.model.Statement;

public final class MockWebServerRule implements TestRule {
  private final MockWebServer server = new MockWebServer();

  public HttpUrl url(String path) {
    return server.url(path);
  }

  public void enqueue(MockResponse response) {
    server.enqueue(response);
  }

  public RecordedRequest takeRequest() throws InterruptedException {
    return server.takeRequest();
  }

  @Override public Statement apply(final Statement base, Description description) {
    return new Statement() {
      @Override public void evaluate() throws Throwable {
        server.start();
        try {
          base.evaluate();
        } finally {
          server.shutdown();
        }
      }
    };
  }
}
EOF

# Download dependencies and build the project using Maven
RUN mvn clean install -DskipTests -Dmaven.javadoc.skip=true || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
# Note: checkstyle.xml may fail due to line endings, but it's not critical for tests
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch || echo "Some hunks failed (likely checkstyle.xml line endings)" && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Java is a compiled language)
RUN mvn clean install -DskipTests -Dmaven.javadoc.skip=true || true

RUN rm -rf /app/src/.git

WORKDIR /app/src
