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

# Install asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
ENV PATH="/root/.asdf/bin:/root/.asdf/shims:$PATH"
RUN asdf plugin add ruby
RUN asdf plugin add nodejs

# Set versions
RUN echo "ruby 4.0.0" >> ~/.tool-versions && echo "nodejs 22.11.0" >> ~/.tool-versions

# Install Ruby and Node
RUN asdf install

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
