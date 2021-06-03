class AddArtistScoresToUserRoomRelations < ActiveRecord::Migration[6.1]
  def change
    add_column :user_room_relations, :artist_scores, :text
  end
end
