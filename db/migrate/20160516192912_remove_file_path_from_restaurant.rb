class RemoveFilePathFromRestaurant < ActiveRecord::Migration
  def change
    remove_column :restaurants, :file_path, :string
  end
end
