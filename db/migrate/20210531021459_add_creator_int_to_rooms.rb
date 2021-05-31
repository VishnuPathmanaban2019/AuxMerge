class AddCreatorIntToRooms < ActiveRecord::Migration[6.1]
  def change
    add_column :rooms, :creator_int, :integer
  end
end
