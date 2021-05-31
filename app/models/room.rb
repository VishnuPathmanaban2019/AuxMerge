class Room < ApplicationRecord
    serialize :creator_playlists, Array

    has_many :user_room_relations
    has_many :users, through: :user_room_relations

    has_many :track_room_relations
    has_many :tracks, through: :track_room_relations
end
