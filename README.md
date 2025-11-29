**BullhornXL**
is a very striped down version of Twitter. This is the sample app
from Michael Hartl's, Ruby on Rails Tutorial. I have made quite a
few changes and continue to add new functionality and features.
v-2.6.2511

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

CI: A GitHub Actions workflow at `.github/workflows/ci.yml` will run tests,
RuboCop and Brakeman on push and pull requests.
