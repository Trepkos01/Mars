## Meals have a many-to-one relationship with restaurants and a many-to-one
## relationship with users.
class CreateMeals < ActiveRecord::Migration
  def change
    create_table :meals, id: false  do |t|
		## Primary UUID.
		t.string 	:id, 	   			null: false, length: 32, primary_key: true
		
		## Basic meal information.
		t.string 	:meal_name, 	null: false, default: ""
		t.string 	:description,	null: false, default: ""
		
		## Meal management information.
		t.string 	:file_path,		null: false, default: ""
		t.boolean :active,			null: false, default: false
		t.timestamps 						null: false
		
		## Relationships
		t.belongs_to :user, 				index: true
		t.belongs_to :restaurant, 	index: true
    
    end
  end
end
