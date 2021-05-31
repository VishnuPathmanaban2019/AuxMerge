class Track < ApplicationRecord
    has_many :track_room_relations
    has_many :rooms, through: :track_room_relations
end
