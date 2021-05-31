class UserRoomRelation < ApplicationRecord
  serialize :selected_playlists, Array

  belongs_to :user
  belongs_to :room
end
