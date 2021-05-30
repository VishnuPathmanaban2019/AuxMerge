class AddHashToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :user_hash, :text
  end
end
