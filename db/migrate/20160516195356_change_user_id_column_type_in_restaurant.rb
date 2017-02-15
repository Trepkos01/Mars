class ChangeUserIdColumnTypeInRestaurant < ActiveRecord::Migration
  def change
		change_column(:restaurants, :user_id, :string)
  end
end
