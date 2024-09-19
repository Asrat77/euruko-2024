Rails.application.configure do
  litestream_credentials = Rails.application.credentials.litestream

  config.litestream.replica_bucket = Rails.application.credentials.litestream.replica_bucket
  config.litestream.replica_key_id = Rails.application.credentials.litestream.replica_key_id
  config.litestream.replica_access_key = Rails.application.credentials.litestream.replica_access_key
end
