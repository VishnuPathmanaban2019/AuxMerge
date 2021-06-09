class AddGenresToTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :tracks, :genres, :text
  end
end
