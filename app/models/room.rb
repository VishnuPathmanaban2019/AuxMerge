class Room < ApplicationRecord
    has_many :track_room_relations
    has_many :artist_room_relations

    has_many :user_room_relations
    has_many :users, through: :user_room_relations
end