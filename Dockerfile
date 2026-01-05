FROM ubuntu:24.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libvips42 \
    libjemalloc2 \
    nodejs \
    npm \
    curl \
    git \
    libssl-dev \
    libyaml-dev \
    zlib1g-dev \
    libffi-dev \
    libreadline-dev \
    && rm -rf /var/lib/apt/lists/*

# Install mise
RUN curl -L https://github.com/jdx/mise/releases/download/v2025.12.13/mise-v2025.12.13-linux-x64.tar.gz | tar -xz -C /usr/local/bin && chmod +x /usr/local/bin/mise
ENV PATH="/usr/local/bin:$PATH"
ENV MISE_RUBY_VERSION=4.0.0
ENV MISE_NODEJS_VERSION=22.11.0

# Install Ruby and Node
RUN mise install

# Set environment variables
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Copy the rest of the app
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Expose port
EXPOSE 3000

# Start the app
CMD ["bundle", "exec", "passenger", "start", "-e", "production"]
