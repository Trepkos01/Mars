class AddColumnsToIdentities < ActiveRecord::Migration
  def change
		add_column :identities, :user_token, :string
		add_column :identities, :user_secret, :string, null: true
  end
end
