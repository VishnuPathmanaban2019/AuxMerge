class CreateTrackRoomRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :track_room_relations do |t|
      t.references :track, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.integer :score

      t.timestamps
    end
  end
end
