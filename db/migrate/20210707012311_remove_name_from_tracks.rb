class RemoveNameFromTracks < ActiveRecord::Migration[6.1]
  def change
    remove_column :tracks, :name, :string
  end
end
