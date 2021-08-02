class AddPlaylistNameToRooms < ActiveRecord::Migration[6.1]
  def change
    add_column :rooms, :playlist_name, :string
  end
end
