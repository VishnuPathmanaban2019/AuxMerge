class UserRoomRelation < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_many :select_playlists
end
