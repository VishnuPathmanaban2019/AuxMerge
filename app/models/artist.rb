class Artist < ApplicationRecord
    has_many :playlist_artist_relations
    has_many :track_artist_relations
    has_many :artist_room_relations
end