class ChangeColumnTypeInIdentities < ActiveRecord::Migration
  def change
		change_column(:identities, :user_id, :string)
  end
end
