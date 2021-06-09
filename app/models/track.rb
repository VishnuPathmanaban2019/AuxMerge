class Track < ApplicationRecord
    serialize :authors, Array
    serialize :genres, Array

    has_many :track_room_relations
    has_many :rooms, through: :track_room_relations
end
