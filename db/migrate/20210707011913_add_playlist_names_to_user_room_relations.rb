class AddPlaylistNamesToUserRoomRelations < ActiveRecord::Migration[6.1]
  def change
    add_column :user_room_relations, :playlist_names, :text
  end
end
