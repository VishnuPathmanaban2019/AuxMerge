class CreateSelectedPlaylists < ActiveRecord::Migration[6.1]
  def change
    create_table :selected_playlists do |t|
      t.references :user_room_relation, null: false, foreign_key: true
      t.references :playlist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
