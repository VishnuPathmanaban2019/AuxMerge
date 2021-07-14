class AddDownloadedToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :downloaded, :boolean, :default => false
  end
end
