class User < ApplicationRecord
    serialize :user_hash, Hash

    has_many :user_room_relations
    has_many :rooms, through: :user_room_relations
end
