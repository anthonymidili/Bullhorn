# Stage 1: Builder
FROM ubuntu:24.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential curl git libvips-dev libssl-dev libyaml-dev \
    zlib1g-dev libffi-dev libreadline-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. FIXED: Fully qualified URL for asdf-vm
RUN git clone https://github.com/asdf-vm/asdf.git /opt/asdf --branch v0.14.0 --depth 1
ENV PATH="/opt/asdf/bin:/opt/asdf/shims:$PATH"

# 3. SET WORKDIR: Prevents naming conflicts with system /bin
WORKDIR /app

# 4. Install Ruby and Node (ensure .tool-versions is NOT in your .gitignore)
COPY .tool-versions ./
RUN asdf plugin add ruby && \
    asdf plugin add nodejs && \
    asdf install

# 5. Install Ruby Gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:4.0.3 && bundle install --jobs 4 --retry 3

# 6. Install JS Dependencies using corepack (built into Node.js)
COPY package.json yarn.lock ./
RUN corepack enable && asdf reshim nodejs && yarn install --frozen-lockfile

# 7. Copy app and precompile assets
COPY . .
RUN SECRET_KEY_BASE=dummy_for_build bundle exec rake assets:precompile


# Stage 2: Final Runtime Image
FROM ubuntu:24.04

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \
    LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2 \
    PATH="/opt/asdf/bin:/opt/asdf/shims:$PATH"

WORKDIR /app

# Install runtime libraries for libvips and jemalloc
RUN apt-get update && apt-get install -y \
    libvips42 libvips-tools libjemalloc2 curl libyaml-0-2 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/asdf /opt/asdf
COPY --from=builder /app /app

RUN useradd -m rails && chown -R rails:rails /app
USER rails

EXPOSE 3000
CMD ["bundle", "exec", "passenger", "start", "-e", "production", "--port", "3000", "--address", "0.0.0.0"]
