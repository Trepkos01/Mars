## Meal additional metrics have a many-to-one relationship with meals.
class CreateMealAdditionals < ActiveRecord::Migration
  def change
    create_table :meal_additionals do |t|
			## The additional cost/portion information.
			## Expensive/Small = 0, Default/Default = 0.5, Cheap/Large = 1
			t.float :cost,			null: false, default: 0.5
			t.float :portion,		null: false, default: 0.5
			
			## Rating management information.
			t.string :user_agent,	null: false
			t.timestamps 					null: false
			
			## Relationships
			t.belongs_to :meal, 	index: true
			t.belongs_to :user,		index: true
			
			t.timestamps null: false
    end
  end
end
