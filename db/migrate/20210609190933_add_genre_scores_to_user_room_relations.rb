class AddGenreScoresToUserRoomRelations < ActiveRecord::Migration[6.1]
  def change
    add_column :user_room_relations, :genre_scores, :text
  end
end
