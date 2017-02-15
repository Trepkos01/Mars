## Meals and tags have a many-to-many relationship.
class CreateMealTags < ActiveRecord::Migration
  def change
    create_table :meal_tags, id: false do |t|			
			## The relationship indices.
			t.integer :tag_id
			t.string :meal_id
    end
		add_index :meal_tags, :meal_id
		add_index :meal_tags, :tag_id
  end
end
