class SelectedPlaylist < ApplicationRecord
  belongs_to :user_room_relation
  belongs_to :playlist
end
