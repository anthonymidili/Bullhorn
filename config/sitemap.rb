require "rubygems"
require "aws-sdk-s3"
require "sitemap_generator"

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://bullhornxl.com"
SitemapGenerator::Sitemap.compress = false
SitemapGenerator::Sitemap.sitemaps_host = "https://#{Rails.application.credentials.dig(:aws, :region)}.console.aws.amazon.com/s3/buckets/#{Rails.application.credentials.dig(:sitemap, :s3_bucket)}"
SitemapGenerator::Sitemap.public_path = "tmp/"
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/bullhorn/"

# Disable automatic search engine pinging (causes cgi/session error in Ruby 3.3+)
SitemapGenerator::Sitemap.search_engines = {}

# Use AwsSdkAdapter for S3 uploads
SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(
  Rails.application.credentials.dig(:sitemap, :s3_bucket),
  access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
  secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
  region: Rails.application.credentials.dig(:aws, :region)
)

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  # Article.find_each do |article|
  #   add article_path(article), :lastmod => article.updated_at
  # end
  add "/"
end
