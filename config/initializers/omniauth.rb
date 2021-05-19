require 'rspotify/oauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, "2ae492828b34413f8e96d2eaacb8a085", "b02d1ce8c1af4f0ca7fa5be622adac21", scope: 'ugc-image-upload user-read-recently-played user-top-read playlist-modify-public playlist-modify-private playlist-read-private playlist-read-collaborative user-library-modify user-library-read user-read-email'
end