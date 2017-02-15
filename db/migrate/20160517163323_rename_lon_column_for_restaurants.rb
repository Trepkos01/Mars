class RenameLonColumnForRestaurants < ActiveRecord::Migration
  def change
		rename_column :restaurants, :lon, :lng 
  end
end
