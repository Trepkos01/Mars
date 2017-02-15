class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants, id: false do |t|
		## Primary UUID.
		t.string 	:id, 	   						null: false, length: 32, primary_key: true
		
		## Basic restaurant information.
		t.string 	:restaurant_name, 	null: false, default: ""
		t.string 	:address,						null: false, default: ""
		t.float 	:lat,								null: false, default: 0
		t.float 	:lon, 							null: false, default: 0
		
		## Restaurant management information.
		t.string 	:file_path,					null: false, default: ""
		t.boolean :active,						null: false, default: false
		t.timestamps 									null: false
    
		## Relationships
		t.belongs_to :user, 	index: true
		
		end
  end
end
