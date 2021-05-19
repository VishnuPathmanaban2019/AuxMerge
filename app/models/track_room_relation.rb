class TrackRoomRelation < ApplicationRecord
  belongs_to :track
  belongs_to :room
end
