CarrierWave.configure do |config|
  if Rails.env.production? || Rails.env.development?
    config.storage = :aws
    config.aws_bucket = ENV.fetch('S3_BUCKET_NAME')
    config.aws_acl    = 'private'
    config.aws_credentials = {
        access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
        secret_access_key: ENV.fetch('AWS_SECRET_KEY'),
        region: ENV.fetch('AWS_REGION')
    }

    # To let CarrierWave work on heroku
    # config.cache_dir = "#{Rails.root}/tmp/uploads"
  elsif Rails.env.test? || Rails.env.cucumber?
    # For testing, upload files to local `tmp` folder.
    config.storage = :file
    config.enable_processing = false
    config.root = "#{Rails.root}/tmp"
  end
end
