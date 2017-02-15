class RemoveTagIdFromMeals < ActiveRecord::Migration
  def change
		drop_table :meal_tags
  end
end
