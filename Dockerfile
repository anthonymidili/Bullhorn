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
    && rm -rf /var/lib/apt/lists/*

# Install mise
RUN curl https://mise.jdx.dev/install.sh | sh
ENV PATH="/root/.local/share/mise/shims:/root/.local/bin:$PATH"

# Copy .tool-versions and install Ruby
COPY .tool-versions ./
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
