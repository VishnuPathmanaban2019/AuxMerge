class CreateArtistRoomRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :artist_room_relations do |t|
      t.references :artist, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.integer :score

      t.timestamps
    end
  end
end
