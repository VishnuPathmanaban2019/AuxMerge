class CreateRooms < ActiveRecord::Migration[6.1]
  def change
    create_table :rooms do |t|
      t.string :password
      t.integer :creator_id

      t.timestamps
    end
  end
end
