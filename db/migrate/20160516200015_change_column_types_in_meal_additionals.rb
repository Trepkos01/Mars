class ChangeColumnTypesInMealAdditionals < ActiveRecord::Migration
  def change
		change_column(:meal_additionals, :user_id, :string)
		change_column(:meal_additionals, :meal_id, :string)
  end
end
