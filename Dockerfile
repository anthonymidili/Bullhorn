# Stage 1: Build environment
FROM ubuntu:24.04 AS builder

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install only necessary build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libvips-dev \
    libssl-dev \
    libyaml-dev \
    zlib1g-dev \
    libffi-dev \
    libreadline-dev \
    && rm -rf /var/lib/apt/lists/*

# Install asdf and plugins
RUN git clone github.com /root/.asdf --branch v0.14.0
ENV PATH="/root/.asdf/bin:/root/.asdf/shims:$PATH"
RUN asdf plugin add ruby

# Set up app directory
WORKDIR /app

# Cache dependencies: Copy only files needed for install first
COPY .tool-versions Gemfile Gemfile.lock ./
RUN asdf install && \
    gem install bundler:4.0.3 && \
    bundle install --jobs 4 --retry 3

# Copy the rest of the application
COPY . .

# Precompile assets (requires SECRET_KEY_BASE even if dummy)
RUN SECRET_KEY_BASE=dummy bundle exec rake assets:precompile


# Stage 2: Final Runtime Image (Smaller & More Secure)
FROM ubuntu:24.04

WORKDIR /app

# Install only runtime libraries (not build tools)
RUN apt-get update && apt-get install -y \
    libvips42 \
    libjemalloc2 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Ruby and gems from the builder stage
COPY --from=builder /root/.asdf /root/.asdf
COPY --from=builder /app /app

# Set environment paths
ENV PATH="/root/.asdf/bin:/root/.asdf/shims:$PATH"
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true

# Security: Run as a non-root user
RUN useradd -m rails && chown -R rails:rails /app
USER rails

EXPOSE 3000

# Start app with passenger or puma
CMD ["bundle", "exec", "passenger", "start"]
