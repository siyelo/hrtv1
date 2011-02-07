if ['staging', 'production'].include? RAILS_ENV
  AWS::S3::Base.establish_connection!(
    :access_key_id     => Settings.paperclip.s3_credentials.access_key_id,
    :secret_access_key => Settings.paperclip.s3_credentials.secret_access_key
  )
end