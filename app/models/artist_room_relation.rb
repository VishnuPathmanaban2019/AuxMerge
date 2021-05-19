class ArtistRoomRelation < ApplicationRecord
  belongs_to :artist
  belongs_to :room
end
