# require 'rspotify/oauth'

# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :spotify, "2ae492828b34413f8e96d2eaacb8a085", "b02d1ce8c1af4f0ca7fa5be622adac21", scope: 'ugc-image-upload user-read-recently-played user-top-read user-read-playback-position user-read-playback-state user-modify-playback-state user-read-currently-playing app-remote-control streaming playlist-modify-public playlist-modify-private playlist-read-private playlist-read-collaborative user-follow-modify user-follow-read user-library-modify user-library-read user-read-email user-read-private'
# end

require 'rspotify/oauth'

OmniAuth.config.allowed_request_methods = [:post, :get]

Rails.application.config.to_prepare do
  OmniAuth::Strategies::Spotify.include SpotifyOmniauthExtension
end 

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify,
    "2ae492828b34413f8e96d2eaacb8a085",
    "b02d1ce8c1af4f0ca7fa5be622adac21",
    scope: 'ugc-image-upload user-read-recently-played user-top-read user-read-playback-position user-read-playback-state user-modify-playback-state user-read-currently-playing app-remote-control streaming playlist-modify-public playlist-modify-private playlist-read-private playlist-read-collaborative user-follow-modify user-follow-read user-library-modify user-library-read user-read-email user-read-private'
end