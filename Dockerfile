# Stage 1: Builder
FROM ubuntu:24.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Node.js 22.x and build dependencies for Ruby
RUN apt-get update && apt-get install -y \
    build-essential curl git libvips-dev libssl-dev libyaml-dev \
    zlib1g-dev libffi-dev libreadline-dev ca-certificates gnupg \
    autoconf bison patch rustc libgmp-dev \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 2. Install ruby-build and compile Ruby 4.0.0
RUN git clone https://github.com/rbenv/ruby-build.git /tmp/ruby-build && \
    cd /tmp/ruby-build && ./install.sh && \
    ruby-build 4.0.0 /usr/local && \
    rm -rf /tmp/ruby-build

# 3. SET WORKDIR
WORKDIR /app

# 4. Install Ruby Gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:4.0.3 && bundle install --jobs 4 --retry 3

# 5. Install JS Dependencies using corepack (built into Node.js)
COPY package.json yarn.lock ./
RUN corepack enable && yarn install --frozen-lockfile

# 6. Copy app and precompile assets
COPY . .
RUN SECRET_KEY_BASE=dummy_for_build bundle exec rake assets:precompile


# Stage 2: Final Runtime Image
FROM ubuntu:24.04

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \
    LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

WORKDIR /app

# Install Node.js 22.x and runtime libraries only
RUN apt-get update && apt-get install -y \
    libvips42 libvips-tools libjemalloc2 curl libyaml-0-2 ca-certificates gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Copy Ruby installation from builder
COPY --from=builder /usr/local /usr/local
COPY --from=builder /app /app

EXPOSE 3000
CMD ["sh", "-c", "exec bundle exec passenger start -e production --port ${PORT:-3000} --address 0.0.0.0"]
