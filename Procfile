web: bundle exec passenger start -p $PORT --max-pool-size $RAILS_MAX_THREADS -e production
worker: bundle exec sidekiq -c 1 -t 25 -e production
