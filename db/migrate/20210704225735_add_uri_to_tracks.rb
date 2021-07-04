class AddUriToTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :tracks, :uri, :string
  end
end
