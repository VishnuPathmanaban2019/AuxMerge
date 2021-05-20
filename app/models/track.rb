class Track < ApplicationRecord
    has_many :playlist_track_relations
    has_many :track_artist_relations
    has_many :track_room_relations
end