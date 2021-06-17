class RemoveCreatorPlaylistsFromRooms < ActiveRecord::Migration[6.1]
  def change
    remove_column :rooms, :creator_playlists, :text
  end
end
