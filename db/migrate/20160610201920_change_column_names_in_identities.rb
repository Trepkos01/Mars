class ChangeColumnNamesInIdentities < ActiveRecord::Migration
  def change
		rename_column :identities, :user_token, :access_token 
		rename_column :identities, :user_secret, :access_secret 
  end
end
