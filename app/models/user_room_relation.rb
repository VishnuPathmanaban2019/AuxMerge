class UserRoomRelation < ApplicationRecord
  serialize :selected_playlists, Array
  serialize :playlist_names, Array
  serialize :artist_scores, Hash
  serialize :genre_scores, Hash

  belongs_to :user
  belongs_to :room
end
