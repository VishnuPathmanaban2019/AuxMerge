class AddCreatorPlaylistsToRooms < ActiveRecord::Migration[6.1]
  def change
    add_column :rooms, :creator_playlists, :text
  end
end
