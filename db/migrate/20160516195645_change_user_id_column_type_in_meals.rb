class ChangeUserIdColumnTypeInMeals < ActiveRecord::Migration
  def change
		change_column(:meals, :user_id, :string)
		change_column(:meals, :restaurant_id, :string)
  end
end
