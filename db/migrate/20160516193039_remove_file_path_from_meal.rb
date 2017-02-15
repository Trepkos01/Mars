class RemoveFilePathFromMeal < ActiveRecord::Migration
  def change
    remove_column :meals, :file_path, :string
  end
end
