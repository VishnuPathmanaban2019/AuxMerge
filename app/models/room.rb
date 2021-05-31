class Room < ApplicationRecord
    has_many :user_room_relations
    has_many :users, through: :user_room_relations
end
