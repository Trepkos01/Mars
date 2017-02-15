class CorrectMealRecommendationTableName < ActiveRecord::Migration
  def change
    rename_table :meal_recommentations, :meal_recommendations
  end
end
