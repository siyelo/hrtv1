# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_resource_tracking_session',
  :secret      => '90dbb48c074a333bc4c46293cdf4aeb02dd117e7cc8cc894e22be2226f46a9b56b8497f1855b88fc4409d7fa9f35bf1e1c254d2d5ce32fb03adb1baf257b64ae'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
