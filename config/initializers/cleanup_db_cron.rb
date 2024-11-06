require 'sidekiq-scheduler'

class CleanupDbCron
  include Sidekiq::Job

  def perform
    puts "============================================================="
    puts "Running cleanup db task......................................"
    %x{ bundle exec rake cleanup_db }
    puts "Cleanup db complete.........................................."
    if Rails.env.production?
      puts "Refreshing sitemap..........................................."
      %x{ bundle exec rake sitemap:refresh }
      puts "Refresh sitemap complete....................................."
    else
      puts "Only refresh sitemap in production environment!!!............"
    end
    puts "============================================================="
  end
end
