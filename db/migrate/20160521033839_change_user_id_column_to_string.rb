class ChangeUserIdColumnToString < ActiveRecord::Migration
  def change
		change_column(:issues, :user_id, :string)
  end
end
