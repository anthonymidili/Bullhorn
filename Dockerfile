# Stage 1: Builder
FROM ubuntu:24.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential curl git libvips-dev libssl-dev libyaml-dev \
    zlib1g-dev libffi-dev libreadline-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. FIXED: Fully qualified URL for asdf-vm
RUN git clone https://github.com/asdf-vm/asdf.git /root/.asdf --branch v0.14.0 --depth 1
ENV PATH="/root/.asdf/bin:/root/.asdf/shims:$PATH"

# 3. SET WORKDIR: Prevents naming conflicts with system /bin
WORKDIR /app

# 4. Install Ruby and Node (ensure .tool-versions is NOT in your .gitignore)
COPY .tool-versions ./
RUN asdf plugin add ruby && \
    asdf plugin add nodejs && \
    asdf install

# 5. FIXED: Use npm to install yarn globally within asdf. 
# This ensures "yarn" is found globally in subsequent Docker layers.
RUN npm install -g yarn && asdf reshim nodejs

# 6. Install Ruby Gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:4.0.3 && bundle install --jobs 4 --retry 3

# 7. Install JS Dependencies (yarn will now be recognized)
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# 8. Copy app and precompile assets
COPY . .
RUN SECRET_KEY_BASE=dummy_for_build bundle exec rake assets:precompile


# Stage 2: Final Runtime Image
FROM ubuntu:24.04

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \
    LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2 \
    PATH="/root/.asdf/bin:/root/.asdf/shims:$PATH"

WORKDIR /app

# Install runtime libraries for libvips and jemalloc
RUN apt-get update && apt-get install -y \
    libvips42 libvips-tools libjemalloc2 curl libyaml-0-2 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/.asdf /root/.asdf
COPY --from=builder /app /app

RUN useradd -m rails && chown -R rails:rails /app
USER rails

EXPOSE 3000
CMD ["bundle", "exec", "passenger", "start", "-e", "production"]
