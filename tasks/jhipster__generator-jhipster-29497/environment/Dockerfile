FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x (project requires Node.js 22.17.0)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Java 17 (required for JHipster generated projects)
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/jhipster/generator-jhipster.git src && \
    cd src && \
    (git fetch --depth 1 origin c2e6ef2c97fcaa1d3a5ce1b4f44db66f91b5f79f || git fetch --depth 1 origin "+refs/pull/29497/head:refs/remotes/origin/pr/29497") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for testing
ENV CI=true
ENV NODE_ENV=test

# Install dependencies
RUN npm ci

# Build the project (TypeScript compilation)
RUN npm run build

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (TypeScript requires recompilation)
RUN npm run build

RUN rm -rf /app/src/.git

WORKDIR /app/src
