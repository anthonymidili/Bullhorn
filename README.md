**BullhornXL**
is a very striped down version of Twitter. This is the sample app
from Michael Hartl's, Ruby on Rails Tutorial. I have made quite a
few changes and continue to add new functionality and features.
v-2.6.2511

Getting Started
---------------

After cloning the repository, follow these steps to get the app up and running:

```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies
yarn install

# Create environment file (copy and update with your credentials)
cp .env.example .env
# Edit .env and add your database credentials, API keys, etc.

# Set up the database
bin/rails db:setup

# Build assets
yarn build

# Start the development server
bin/dev
```

The application will be available at `http://localhost:3000`

Running tests
-------------

To run the Rails test suite locally:

```bash
# install gems
bundle install

# prepare the test database
bundle exec rails db:prepare RAILS_ENV=test

# run all tests
bin/rails test
```

Static analysis:

```bash
# rubocop (style)
bin/rubocop

# brakeman (security)
bin/brakeman
```
