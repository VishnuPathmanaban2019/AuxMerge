class TrackRoomRelation < ApplicationRecord
  belongs_to :track
  belongs_to :room
  belongs_to :user
end
