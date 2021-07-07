class RemovePlaylistNamesFromUserRoomRelations < ActiveRecord::Migration[6.1]
  def change
    remove_column :user_room_relations, :playlist_names, :text
  end
end
