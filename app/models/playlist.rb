class Playlist < ApplicationRecord
    belongs_to :user
    has_many :selected_playlists
    has_many :playlist_track_relations
    has_many :playlist_artist_relations
end