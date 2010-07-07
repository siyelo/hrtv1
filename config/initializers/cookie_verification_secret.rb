# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

# TODO - MOVE THIS FROM THE CODEBASE TO AN ENV VARIABLE (or untracked file)
ActionController::Base.cookie_verifier_secret = '0cf70cf1c875a9942dab90096a415174255046e4dcc2a5337076662c49a731795b395e9044ec7456c3e4c25ba1bc7c8fb032de961f37505c2ba4fdd94f98e829';
