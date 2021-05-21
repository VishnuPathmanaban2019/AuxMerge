class UsersController < ApplicationController
    def spotify
      spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
      # Now you can access user's private data, create playlists and much more
      @email = spotify_user.email
      @top_artists = spotify_user.top_artists
      @top_tracks = spotify_user.top_tracks(time_range: 'short_term')
    end
  end