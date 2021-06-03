class AddAuthorsToTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :tracks, :authors, :text
  end
end
