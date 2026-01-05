# Stage 1: Builder
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install Ubuntu system dependencies
RUN apt-get update && apt-get install -y \
    build-essential curl git libvips-dev libssl-dev libyaml-dev \
    zlib1g-dev libffi-dev libreadline-dev nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Install asdf for Ruby and Node management
RUN git clone github.com /root/.asdf --branch v0.14.0 --depth 1
ENV PATH="/root/.asdf/bin:/root/.asdf/shims:$PATH"

WORKDIR /app

# 1. Install Ruby and Node (Must match your .tool-versions)
COPY .tool-versions ./
RUN asdf plugin add ruby && \
    asdf plugin add nodejs && \
    asdf install

# 2. COREPACK: Handles the Yarn version requirement in your package.json
# This replaces the need for Homebrew in the container
RUN corepack enable && corepack prepare yarn@1.22.22 --activate

# 3. Install Ruby Gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:4.0.3 && bundle install --jobs 4 --retry 3

# 4. Install JavaScript dependencies using Yarn
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# 5. Copy app and precompile assets
# Rails will execute "yarn build" and "yarn build:css" from your package.json automatically
COPY . .
RUN SECRET_KEY_BASE=dummy_for_build bundle exec rake assets:precompile


# Stage 2: Final Runtime (Optimized for Railway)
FROM ubuntu:24.04

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \
    LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2 \
    PATH="/root/.asdf/bin:/root/.asdf/shims:$PATH"

WORKDIR /app

# Runtime-only libraries for libvips and jemalloc
RUN apt-get update && apt-get install -y \
    libvips42 libvips-tools libjemalloc2 curl libyaml-0-2 \
    && rm -rf /var/lib/apt/lists/*

# Copy built environment from Stage 1
COPY --from=builder /root/.asdf /root/.asdf
COPY --from=builder /app /app

# Security: Run as non-root user
RUN useradd -m rails && chown -R rails:rails /app
USER rails

EXPOSE 3000

# Railway will look for this command
CMD ["bundle", "exec", "passenger", "start", "-e", "production"]
