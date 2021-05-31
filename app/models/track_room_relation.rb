class TrackRoomRelation < ApplicationRecord
  serialize :listeners, Array

  belongs_to :track
  belongs_to :room
end
