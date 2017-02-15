class CreateCommentsResponseTable < ActiveRecord::Migration
  def change
    create_table :comments_responses do |t|
			# If the comment on the recommendation was helpful or not.
			t.boolean :helpful,				null: false
			
			t.timestamps 							null: false
			
			## Relationships
			t.belongs_to :meal_recommendation, 			index: true
			t.belongs_to :user,											index: true
    end
  end
end
