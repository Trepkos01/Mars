class AddProviderFieldToUsers < ActiveRecord::Migration
  def change
		add_column :users, :provider, :string, null: false, default: "default"
  end
end
