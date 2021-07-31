class AddValidUsersToRooms < ActiveRecord::Migration[6.1]
  def change
    add_column :rooms, :valid_users, :text
  end
end
