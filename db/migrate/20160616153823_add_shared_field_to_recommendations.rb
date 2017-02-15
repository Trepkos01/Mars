class AddSharedFieldToRecommendations < ActiveRecord::Migration
  def change
		add_column :meal_recommendations, :shared, :boolean, null: false, default: false
		add_column :meal_recommendations, :comments, :text, null: true
  end
end
