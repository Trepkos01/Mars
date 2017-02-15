## Meal recommendations have a many-to-one relationship with meals.
class CreateMealRecommentations < ActiveRecord::Migration
  def change
    create_table :meal_recommentations do |t|
			## The actual rating, true = recommended, false = not recommended.
			t.boolean :rating,				null: false
			
			## Rating management information.
			t.string :user_agent,		null: false
			t.timestamps 						null: false
			
			## Relationships
			t.belongs_to :meal, 			index: true
			t.belongs_to :user,				index: true
		end
  end
end
