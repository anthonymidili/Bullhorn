# Use local storage if in development or test
if Rails.env.development? || Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
  end
end

# Use AWS storage if in production
if Rails.env.production?
  CarrierWave.configure do |config|
    config.storage = :fog
  end

  config.fog_credentials = {
      :provider               => 'AWS',                             # required
      :aws_access_key_id      => ENV.fetch('AWS_ACCESS_KEY_ID', ''),            # required
      :aws_secret_access_key  => ENV.fetch('AWS_SECRET_KEY', '')# ,     # required
      # :region                 => 'eu-west-1'                        # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV['S3_BUCKET_NAME']               # required
  #config.fog_host       = 'https://assets.example.com'           # optional, defaults to nil
  #config.fog_public     = false                                  # optional, defaults to true
  # config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}

end
