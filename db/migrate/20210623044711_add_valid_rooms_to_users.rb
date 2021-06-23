class AddValidRoomsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :valid_rooms, :text
  end
end
