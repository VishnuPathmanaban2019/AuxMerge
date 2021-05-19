class CreatePlaylistArtistRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :playlist_artist_relations do |t|
      t.references :playlist, null: false, foreign_key: true
      t.references :artist, null: false, foreign_key: true
      t.integer :rank

      t.timestamps
    end
  end
end
