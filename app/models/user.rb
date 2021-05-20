class User < ApplicationRecord
    has_many :user_room_relations
    has_many :playlists
end
  