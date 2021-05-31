class AddSelectedPlaylistsToUserRoomRelations < ActiveRecord::Migration[6.1]
  def change
    add_column :user_room_relations, :selected_playlists, :text
  end
end
