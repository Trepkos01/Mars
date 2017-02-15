class ChangeColumnTypesInMealRecommendations < ActiveRecord::Migration
  def change
		change_column(:meal_recommentations, :user_id, :string)
		change_column(:meal_recommentations, :meal_id, :string)
  end
end
