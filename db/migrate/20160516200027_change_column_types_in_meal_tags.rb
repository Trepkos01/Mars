class ChangeColumnTypesInMealTags < ActiveRecord::Migration
  def change
		change_column(:meal_tags, :meal_id, :string)
  end
end
