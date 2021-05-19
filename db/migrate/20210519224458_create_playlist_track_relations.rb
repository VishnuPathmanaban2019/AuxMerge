class CreatePlaylistTrackRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :playlist_track_relations do |t|
      t.references :playlist, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true
      t.integer :rank

      t.timestamps
    end
  end
end
